"""
Módulo responsável pelo envio de e-mails com anexos via SMTP (Office 365).
"""

import os
import smtplib
from datetime import date
from email.message import EmailMessage
from pathlib import Path
from typing import Iterable

from dotenv import load_dotenv

# Carrega variáveis do arquivo .env, se existir
load_dotenv()


def build_email_message(
    sender: str,
    recipients: Iterable[str],
    subject: str,
    body: str,
    attachments: Iterable[Path],
) -> EmailMessage:
    """
    Monta a mensagem de e-mail com anexos.

    :param sender: E-mail do remetente
    :param recipients: Lista de destinatários
    :param subject: Assunto do e-mail
    :param body: Corpo do e-mail
    :param attachments: Caminhos dos arquivos a serem anexados
    :return: Objeto EmailMessage
    """
    message = EmailMessage()
    message["From"] = sender
    message["To"] = ", ".join(recipients)
    message["Subject"] = subject
    message.set_content(body)

    for attachment in attachments:
        message.add_attachment(
            attachment.read_bytes(),
            maintype="application",
            subtype="octet-stream",
            filename=attachment.name,
        )

    return message


def send_email(
    sender: str,
    recipients: Iterable[str],
    smtp_server: str,
    smtp_port: int,
    attachments: Iterable[Path],
) -> None:
    """
    Envia um e-mail com anexos utilizando SMTP com TLS.

    A senha deve estar definida na variável de ambiente SMTP_PASSWORD.

    :param sender: E-mail do remetente
    :param recipients: Lista de destinatários
    :param smtp_server: Servidor SMTP
    :param smtp_port: Porta do servidor SMTP
    :param attachments: Arquivos a serem anexados
    """
    password = os.getenv("SMTP_PASSWORD")
    if not password:
        raise RuntimeError(
            "Variável de ambiente SMTP_PASSWORD não definida."
        )

    today_str = date.today().strftime("%d/%m/%Y")

    subject = "Relatório SAP - OS abertas e concluídas"
    body = (
        "Segue o relatório de OS concluídas e de OS abertas "
        f"no SAP até o dia {today_str}."
    )

    message = build_email_message(
        sender=sender,
        recipients=recipients,
        subject=subject,
        body=body,
        attachments=attachments,
    )

    with smtplib.SMTP(smtp_server, smtp_port) as smtp:
        smtp.starttls()
        smtp.login(sender, password)
        smtp.send_message(message)
