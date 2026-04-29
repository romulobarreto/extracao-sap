"""
Ponto de entrada do projeto de extração e envio de relatórios SAP.
"""

from datetime import datetime
from pathlib import Path
import logging
import sys

from extract import extract_os_abertas, extract_os_concluidas
from export_excel import export_dataframe_to_excel
from send_email import send_email
from config import (
    EMAIL_RECIPIENTS,
    SENDER_EMAIL,
    SMTP_SERVER,
    SMTP_PORT,
)


def setup_logging() -> None:
    """
    Configura logging para arquivo e console.
    """
    logs_dir = Path("logs")
    logs_dir.mkdir(exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = logs_dir / f"extracao_{timestamp}.log"

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s | %(levelname)s | %(message)s",
        handlers=[
            logging.FileHandler(log_file, encoding="utf-8"),
            logging.StreamHandler(sys.stdout),
        ],
    )

    logging.info("Logging inicializado")
    logging.info("Arquivo de log: %s", log_file)


def main() -> None:
    """
    Executa o fluxo completo:
    - extrai dados do Snowflake
    - gera arquivos Excel
    - envia e-mail com os anexos
    """
    setup_logging()

    try:
        logging.info("Início do processo de extração SAP")

        logging.info("Extraindo OS abertas...")
        df_abertas = extract_os_abertas()
        logging.info("OS abertas extraídas: %d registros", len(df_abertas))

        logging.info("Extraindo OS concluídas...")
        df_concluidas = extract_os_concluidas()
        logging.info("OS concluídas extraídas: %d registros", len(df_concluidas))

        logging.info("Exportando arquivos Excel...")
        file_abertas = export_dataframe_to_excel(
            dataframe=df_abertas,
            file_prefix="os_abertas",
        )
        file_concluidas = export_dataframe_to_excel(
            dataframe=df_concluidas,
            file_prefix="os_concluidas",
        )

        logging.info("Arquivos gerados:")
        logging.info(" - %s", file_abertas)
        logging.info(" - %s", file_concluidas)

        logging.info("Enviando e-mail...")
        send_email(
            sender=SENDER_EMAIL,
            recipients=EMAIL_RECIPIENTS,
            smtp_server=SMTP_SERVER,
            smtp_port=SMTP_PORT,
            attachments=[file_abertas, file_concluidas],
        )

        logging.info("E-mail enviado com sucesso")
        logging.info("Processo finalizado com sucesso ✅")

    except Exception as exc:  # noqa: BLE001
        logging.exception("Erro durante a execução do processo")
        raise exc


if __name__ == "__main__":
    main()