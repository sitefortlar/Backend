import os
from typing import Optional, List
from loguru import logger

import envs

# Tenta importar Resend (recomendado para produção - funciona na Render)
try:
    import resend
    RESEND_AVAILABLE = True
except ImportError:
    RESEND_AVAILABLE = False
    # Warning será mostrado apenas se RESEND_API_KEY estiver configurado

# Fallback para SMTP (apenas para desenvolvimento local)
if not RESEND_AVAILABLE:
    import smtplib
    import ssl
    from email.message import EmailMessage


class EmailService:
    """
    Serviço de envio de emails.
    
    Em produção (Render.com): usa Resend (HTTP) - funciona perfeitamente
    Em desenvolvimento local: pode usar SMTP como fallback
    """
    
    def __init__(self):
        # Configuração do Resend (recomendado para produção)
        self.resend_api_key = os.getenv("RESEND_API_KEY")
        
        # Se RESEND_API_KEY está configurado mas resend não está instalado, mostra warning
        if self.resend_api_key and not RESEND_AVAILABLE:
            logger.warning(
                "⚠️  RESEND_API_KEY configurado mas Resend não está instalado. "
                "Instale com: pip install resend"
            )
        
        self.use_resend = RESEND_AVAILABLE and self.resend_api_key
        
        if self.use_resend:
            try:
                # Configura a API key do Resend (forma de módulo conforme documentação)
                resend.api_key = self.resend_api_key
                
                # Obtém o email "from" configurado
                configured_from = os.getenv("RESEND_FROM_EMAIL", envs.MAIL_FROM or "vendas@fortlar.com.br")
                
                # Domínios públicos que NÃO são permitidos pelo Resend (precisam ser verificados)
                # O Resend permite apenas domínios verificados ou o email de teste (resend.dev)
                public_email_domains = ['gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'live.com', 'icloud.com', 'aol.com']
                
                # Extrai o domínio do email
                if '@' in configured_from:
                    email_domain = configured_from.split('@')[-1].lower()
                else:
                    email_domain = ''
                
                # Se o domínio é um domínio público não verificado, usa o email de teste do Resend
                if email_domain in public_email_domains:
                    self.from_email = "onboarding@resend.dev"
                    logger.warning(
                        f"⚠️  Email 'from' configurado ({configured_from}) usa domínio público não verificado. "
                        f"Usando email de teste do Resend: {self.from_email}. "
                        f"Para produção, configure RESEND_FROM_EMAIL com um domínio verificado no Resend (https://resend.com/domains)."
                    )
                elif email_domain == 'resend.dev':
                    # Domínio de teste do Resend - sempre permitido
                    self.from_email = configured_from
                    logger.info(f"✅ EmailService inicializado com Resend (HTTP) - From: {self.from_email} (email de teste)")
                else:
                    # Assume que é um domínio verificado ou customizado
                    self.from_email = configured_from
                    logger.info(f"✅ EmailService inicializado com Resend (HTTP) - From: {self.from_email}")
            except Exception as e:
                logger.error(f"❌ Erro ao inicializar Resend: {e}")
                self.use_resend = False
        
        # Fallback para SMTP (apenas se Resend não estiver disponível)
        if not self.use_resend:
            is_production = os.getenv('RENDER') or os.getenv('RENDER_SERVICE_NAME')
            if is_production:
                # Em produção, só mostra warning se não tiver RESEND_API_KEY configurado
                if not self.resend_api_key:
                    logger.warning(
                        "⚠️  Usando SMTP como fallback (bloqueado na Render). "
                        "Configure RESEND_API_KEY para enviar emails."
                    )
            else:
                # Em desenvolvimento, apenas loga info
                logger.debug("Usando SMTP como fallback (desenvolvimento local)")
            
            self.username = envs.MAIL_USERNAME
            self.password = envs.MAIL_PASSWORD
            self.mail_from = envs.MAIL_FROM
            self.mail_server = envs.MAIL_SERVER
            self.mail_port = envs.MAIL_PORT
            self.use_tls = True

    def send_email(
        self, 
        recipient: str, 
        template_html: str, 
        subject: str, 
        cc: Optional[List[str]] = None
    ):
        """
        Envia email usando Resend (HTTP) ou SMTP (fallback).
        
        Args:
            recipient: Email do destinatário
            template_html: Conteúdo HTML do email
            subject: Assunto do email
            cc: Lista de emails para cópia (opcional)
        """
        if self.use_resend:
            return self._send_with_resend(recipient, template_html, subject, cc)
        else:
            return self._send_with_smtp(recipient, template_html, subject, cc)

    def _send_with_resend(
        self, 
        recipient: str, 
        template_html: str, 
        subject: str, 
        cc: Optional[List[str]] = None
    ):
        """Envia email usando Resend (HTTP) - funciona na Render"""
        try:
            params = {
                "from": self.from_email,
                "to": [recipient],
                "subject": subject,
                "html": template_html,
            }
            
            # Adiciona cópias se houver
            if cc:
                params["cc"] = cc
            
            # Envia via Resend usando a forma de módulo conforme documentação
            response = resend.Emails.send(params)
            
            logger.info(f"✅ Email enviado via Resend para {recipient} (ID: {response.get('id', 'N/A')})")
            if cc:
                logger.info(f"   Cópias enviadas para: {', '.join(cc)}")
            
            return response
            
        except Exception as e:
            logger.error(f"❌ Erro ao enviar email via Resend: {e}")
            logger.error(f"   Detalhes do erro: {str(e)}")
            if hasattr(e, 'response'):
                logger.error(f"   Response: {e.response}")
            raise

    def _send_with_smtp(
        self, 
        recipient: str, 
        template_html: str, 
        subject: str, 
        cc: Optional[List[str]] = None
    ):
        """Envia email usando SMTP (fallback - pode não funcionar na Render)"""
        # IMPORTANTE: Verifica produção ANTES de tentar conectar (Render bloqueia SMTP)
        # Isso evita tentar conectar e causar erro que quebra a aplicação
        is_production = os.getenv('RENDER') or os.getenv('RENDER_SERVICE_NAME')
        
        if is_production:
            # Na Render, SMTP é bloqueado - loga debug (warning já foi mostrado no __init__)
            logger.debug(
                f"Tentativa de enviar email via SMTP na Render (bloqueado). "
                f"Email não enviado para: {recipient}"
            )
            # Não levanta exceção - permite que a aplicação continue funcionando
            return None
        
        # Em desenvolvimento local, tenta enviar via SMTP
        try:
            # Monta mensagem
            msg = EmailMessage()
            msg["Subject"] = subject
            msg["From"] = self.mail_from or self.username
            msg["To"] = recipient
            if cc:
                msg["Cc"] = ", ".join(cc)
            msg.set_content("Seu cliente de email não suporta HTML.")
            msg.add_alternative(template_html, subtype="html")

            # Contexto SSL
            context = ssl.create_default_context()

            # Decide entre SSL e TLS
            if self.mail_port == 465:
                with smtplib.SMTP_SSL(self.mail_server, self.mail_port, context=context) as server:
                    server.login(self.username, self.password)
                    server.send_message(msg)
            else:
                with smtplib.SMTP(self.mail_server, self.mail_port) as server:
                    if self.use_tls:
                        server.starttls(context=context)
                    server.login(self.username, self.password)
                    server.send_message(msg)

            if cc:
                logger.info(f"✅ Email enviado via SMTP para {recipient} com cópia para {', '.join(cc)}")
            else:
                logger.info(f"✅ Email enviado via SMTP para {recipient}")

        except OSError as e:
            # Erro de rede (ex: Network is unreachable)
            # Se ainda assim tentou conectar em produção, trata silenciosamente
            if is_production or "Network is unreachable" in str(e) or "Errno 101" in str(e):
                logger.debug(
                    f"SMTP bloqueado (OSError: {e}). "
                    f"Email não enviado para: {recipient}"
                )
                return None
            else:
                # Em desenvolvimento, levanta a exceção normalmente
                logger.error(f"❌ Erro ao enviar email via SMTP: {e}")
                raise
        except Exception as e:
            logger.error(f"❌ Erro ao enviar email via SMTP: {e}")
            # Se for erro de rede em produção, não quebra
            if is_production or "Network is unreachable" in str(e) or "Errno 101" in str(e):
                logger.debug(f"SMTP bloqueado. Email não enviado.")
                return None
            # Outros erros em desenvolvimento, levanta exceção
            raise
