"""Use case para enviar order por email"""

from fastapi import HTTPException, status
from loguru import logger

from decimal import Decimal

from app.application.usecases.use_case import UseCase
from app.application.service.email_service import EmailService
from app.application.service.email.template.order_template import order_html
import envs
from app.domain.models.company_model import Company
from app.application.service.order_creation_service import IPI_ALIQUOTA, create_order_with_items
from app.infrastructure.repositories.company_repository_interface import ICompanyRepository
from app.infrastructure.repositories.impl.company_repository_impl import CompanyRepositoryImpl
from app.infrastructure.repositories.order_repository_interface import IOrderRepository
from app.infrastructure.repositories.impl.order_repository_impl import OrderRepositoryImpl
from app.infrastructure.repositories.product_repository_interface import IProductRepository
from app.infrastructure.repositories.impl.product_repository_impl import ProductRepositoryImpl
from app.domain.models.dtos.send_order_email_dto import (
    SendOrderEmailUseCaseRequest,
    SendOrderEmailUseCaseResponse,
    FormaPagamentoEnum
)


def _map_payment_method(forma_pagamento: FormaPagamentoEnum) -> str:
    """Mapeia forma de pagamento para texto legível"""
    mapping = {
        FormaPagamentoEnum.AVISTA: "À Vista",
        FormaPagamentoEnum.DIAS_30: "30 Dias",
        FormaPagamentoEnum.DIAS_60: "60 Dias"
    }
    return mapping.get(forma_pagamento, forma_pagamento.value)


class SendOrderEmailUseCase(UseCase[SendOrderEmailUseCaseRequest, SendOrderEmailUseCaseResponse]):
    """Use case para enviar order por email"""

    def __init__(self):
        self.company_repository: ICompanyRepository = CompanyRepositoryImpl()
        self.email_service: EmailService = EmailService()
        self.order_repository: IOrderRepository = OrderRepositoryImpl()
        self.product_repository: IProductRepository = ProductRepositoryImpl()

    def execute(self, request: SendOrderEmailUseCaseRequest, session=None) -> SendOrderEmailUseCaseResponse:
        """Executa o caso de uso de envio de order por email"""
        try:
            logger.info(f"=== Enviando order para empresa {request.company_id} ===")

            # Valida e busca empresa com relacionamentos
            company = self._get_company_with_relations(request.company_id, session)
            
            # Valida email da empresa
            email_empresa = self._validate_company_email(company)
            
            # Processa itens (código enriquecido pelo banco quando ausente no request) e subtotal
            itens_formatados, subtotal_sem_ipi = self._process_order_items(request.itens, session)

            subtotal_dec = Decimal(str(subtotal_sem_ipi))
            valor_ipi_dec = (subtotal_dec * IPI_ALIQUOTA).quantize(Decimal("0.01"))
            total_com_ipi_dec = subtotal_dec + valor_ipi_dec
            valor_ipi = float(valor_ipi_dec)
            total_com_ipi = float(total_com_ipi_dec)
            
            # Mapeia forma de pagamento
            forma_pagamento_texto = _map_payment_method(request.forma_pagamento)

            # Envia email
            self._send_order_email(
                company=company,
                itens=itens_formatados,
                subtotal_sem_ipi=subtotal_sem_ipi,
                valor_ipi=valor_ipi,
                total_com_ipi=total_com_ipi,
                forma_pagamento=forma_pagamento_texto,
                email_empresa=email_empresa
            )

            # Cria o order no banco de dados (valor total = produtos + IPI)
            order = create_order_with_items(
                company_id=request.company_id,
                itens=request.itens,
                session=session,
                order_repository=self.order_repository,
            )

            logger.info(f"✅ Order {order.id_pedido} criado com sucesso no banco de dados")

            # Busca order criado novamente para garantir dados completos
            order_created = self.order_repository.get_by_id(order.id_pedido, session)

            return SendOrderEmailUseCaseResponse(
                message="Order enviado por email com sucesso",
                email_enviado=email_empresa,
                valor_total=total_com_ipi,
                quantidade_itens=len(itens_formatados),
                empresa=company.nome_fantasia or company.razao_social,
                forma_pagamento=forma_pagamento_texto
            )

        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"❌ Erro ao enviar order por email: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao enviar order por email: {str(e)}"
            )

    def _get_company_with_relations(self, company_id: int, session) -> Company:
        """Busca empresa com relacionamentos (endereços e contatos)"""
        company = self.company_repository.get_by_id(company_id, session)
        if not company:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Empresa com ID {company_id} não encontrada"
            )
        return company

    def _validate_company_email(self, company: Company) -> str:
        """Valida se empresa tem email cadastrado"""
        if not company.contatos or len(company.contatos) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Empresa não possui contato com email cadastrado"
            )

        email_empresa = company.contatos[0].email
        if not email_empresa:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Empresa não possui email cadastrado nos contatos"
            )
        return email_empresa

    def _resolve_codigos_produto(self, itens: list, session) -> dict[int, str]:
        """Carrega códigos do banco para ids cujo código não veio no request."""
        ids_sem_codigo = []
        for item in itens:
            if not (item.codigo or "").strip():
                ids_sem_codigo.append(item.id_produto)
        if not session or not ids_sem_codigo:
            return {}
        unique_ids = list(dict.fromkeys(ids_sem_codigo))
        products = self.product_repository.get_by_ids(unique_ids, session)
        codigo_por_id = {p.id_produto: p.codigo for p in products}
        missing = set(unique_ids) - codigo_por_id.keys()
        for pid in missing:
            logger.warning(
                f"Produto id={pid} não encontrado ao enriquecer código para e-mail do pedido"
            )
        return codigo_por_id

    def _process_order_items(self, itens: list, session) -> tuple[list, float]:
        """Processa itens do carrinho, garante código (request ou banco) e calcula subtotal sem IPI."""
        codigo_por_id = self._resolve_codigos_produto(itens, session)
        itens_formatados = []
        subtotal_sem_ipi = 0.0

        for item in itens:
            codigo = (item.codigo or "").strip()
            if not codigo:
                codigo = codigo_por_id.get(item.id_produto) or "N/A"
            itens_formatados.append({
                'codigo': codigo,
                'nome': item.nome,
                'quantidade': item.quantidade_pedida,
                'preco_unitario': float(item.valor_unitario),
                'subtotal': float(item.valor_total),
                'categoria': item.categoria or 'N/A',
                'subcategoria': item.subcategoria or 'N/A'
            })
            subtotal_sem_ipi += float(item.valor_total)

        if not itens_formatados:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Nenhum produto encontrado no carrinho"
            )

        return itens_formatados, subtotal_sem_ipi

    def _send_order_email(
        self,
        company: Company,
        itens: list,
        subtotal_sem_ipi: float,
        valor_ipi: float,
        total_com_ipi: float,
        forma_pagamento: str,
        email_empresa: str
    ) -> None:
        """Envia email do order para a empresa"""
        endereco_principal = company.enderecos[0] if company.enderecos else None
        contato_principal = company.contatos[0] if company.contatos else None

        html_email = order_html(
            itens=itens,
            subtotal_sem_ipi=subtotal_sem_ipi,
            valor_ipi=valor_ipi,
            total_com_ipi=total_com_ipi,
            forma_pagamento=forma_pagamento,
            empresa_nome=company.nome_fantasia or company.razao_social,
            endereco=endereco_principal,
            contato=contato_principal
        )

        subject = (
            f"Novo Order - {company.nome_fantasia or company.razao_social} "
            f"- Total: R$ {total_com_ipi:.2f}"
        )
        
        # Prepara lista de cópias (CC)
        cc_emails = []
        mail_order_copy = envs.MAIL_USERNAME_ORDER
        if mail_order_copy:
            cc_emails.append(mail_order_copy)
        
        # Tenta enviar email (não quebra a aplicação se falhar)
        # O order será criado mesmo se o email falhar
        try:
            # Envia email com cópia se configurado
            if cc_emails:
                self.email_service.send_email(email_empresa, html_email, subject, cc=cc_emails)
                logger.info(f"✅ Email de order enviado com sucesso para {email_empresa} com cópia para {', '.join(cc_emails)}")
            else:
                self.email_service.send_email(email_empresa, html_email, subject)
                logger.info(f"✅ Email de order enviado com sucesso para {email_empresa}")
        except Exception as e:
            # Loga o erro mas não quebra a aplicação
            # O order será criado mesmo sem o email
            logger.warning(f"⚠️  Erro ao enviar email de order para {email_empresa}: {e}")
            logger.info("💡 Order será criado mesmo sem envio de email.")

