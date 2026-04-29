"""
Módulo responsável pela exportação de DataFrames para arquivos Excel.
"""

from datetime import date
from pathlib import Path

import pandas as pd


DEFAULT_OUTPUT_DIR = Path("output")


def ensure_output_dir(output_dir: Path) -> None:
    """
    Garante que o diretório de saída exista.
    """
    output_dir.mkdir(parents=True, exist_ok=True)


def export_dataframe_to_excel(
    dataframe: pd.DataFrame,
    file_prefix: str,
    output_dir: Path = DEFAULT_OUTPUT_DIR,
) -> Path:
    """
    Exporta um DataFrame para um arquivo Excel com data no nome.

    :param dataframe: DataFrame a ser exportado
    :param file_prefix: Prefixo do arquivo (ex: 'os_abertas')
    :param output_dir: Diretório de saída dos arquivos
    :return: Caminho do arquivo gerado
    """
    ensure_output_dir(output_dir)

    today_str = date.today().strftime("%Y%m%d")
    file_name = f"{file_prefix}_{today_str}.xlsx"
    file_path = output_dir / file_name

    dataframe.to_excel(
        file_path,
        index=False,
        engine="openpyxl",
    )

    return file_path
