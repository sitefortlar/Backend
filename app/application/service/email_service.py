import os
from typing import Optional, List
from loguru import logger

import envs

# Tenta importar Resend (recomendado para produção - funciona na Render)
try:
    from resend import Resend
    RESEND_AVAILABLE = True
except ImportError:
    RESEND_AVAILABLE = False
    logger.warning("⚠️  Resend não instalado. Instale com: pip install resend")

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
        self.use_resend = RESEND_AVAILABLE and self.resend_api_key
        
        if self.use_resend:
            try:
                self.resend_client = Resend(api_key=self.resend_api_key)
                # Usa RESEND_FROM_EMAIL se configurado, senão usa MAIL_FROM
                self.from_email = os.getenv("RESEND_FROM_EMAIL", envs.MAIL_FROM or "noreply@fortlar.com.br")
                logger.info(f"✅ EmailService inicializado com Resend (HTTP) - From: {self.from_email}")
            except Exception as e:
                logger.error(f"❌ Erro ao inicializar Resend: {e}")
                self.use_resend = False
        
        # Fallback para SMTP (apenas se Resend não estiver disponível)
        if not self.use_resend:
            logger.warning("⚠️  Usando SMTP como fallback (pode não funcionar na Render)")
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
            
            # Envia via Resend
            response = self.resend_client.emails.send(params)
            
            logger.info(f"✅ Email enviado via Resend para {recipient} (ID: {response.get('id', 'N/A')})")
            if cc:
                logger.info(f"   Cópias enviadas para: {', '.join(cc)}")
            
            return response
            
        except Exception as e:
            logger.error(f"❌ Erro ao enviar email via Resend: {e}")
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
            # Na Render, SMTP é bloqueado - loga aviso mas não quebra a aplicação
            logger.warning(
                f"⚠️  Tentativa de enviar email via SMTP na Render (bloqueado). "
                f"Configure RESEND_API_KEY para usar Resend (HTTP). "
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
                logger.warning(
                    f"⚠️  SMTP bloqueado (OSError: {e}). "
                    f"Configure RESEND_API_KEY para enviar emails. "
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
                logger.warning(f"⚠️  SMTP bloqueado. Configure RESEND_API_KEY.")
                return None
            # Outros erros em desenvolvimento, levanta exceção
            raise
