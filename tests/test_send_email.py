"""
Testes do módulo de envio de e-mails.
"""

from pathlib import Path
from unittest.mock import MagicMock, patch

from src.send_email import build_email_message, send_email


def test_build_email_message(tmp_path: Path) -> None:
    """
    Deve montar corretamente a mensagem de e-mail com anexos.
    """
    # Arrange
    fake_file = tmp_path / "arquivo.xlsx"
    fake_file.write_text("conteudo")

    message = build_email_message(
        sender="teste@empresa.com",
        recipients=["destino@empresa.com"],
        subject="Teste",
        body="Mensagem de teste",
        attachments=[fake_file],
    )

    # Assert
    assert message["From"] == "teste@empresa.com"
    assert "destino@empresa.com" in message["To"]
    assert message["Subject"] == "Teste"
    assert message.get_content_maintype() == "multipart"


@patch("smtplib.SMTP")
def test_send_email(mock_smtp: MagicMock, tmp_path: Path) -> None:
    """
    Deve enviar uma mensagem usando SMTP sem erro.
    """
    # Arrange
    fake_file = tmp_path / "arquivo.xlsx"
    fake_file.write_text("conteudo")

    smtp_instance = mock_smtp.return_value.__enter__.return_value

    # Act
    send_email(
        sender="teste@empresa.com",
        recipients=["destino@empresa.com"],
        smtp_server="smtp.empresa.com",
        smtp_port=25,
        attachments=[fake_file],
    )

    # Assert
    smtp_instance.send_message.assert_called_once()