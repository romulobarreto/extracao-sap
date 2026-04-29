"""
Módulo responsável pela extração de dados do Snowflake via ODBC.
"""

from pathlib import Path
from typing import Final

import pandas as pd
import pyodbc

# Constantes
SQL_DIR: Final[Path] = Path(__file__).parent / "sql"
DSN_NAME: Final[str] = "Snowflake_EQTL"


def get_connection() -> pyodbc.Connection:
    """
    Cria e retorna uma conexão ODBC com o Snowflake utilizando
    autenticação via external browser.
    """
    connection_string = (
        f"DSN={DSN_NAME};"
        "authenticator=externalbrowser;"
    )

    return pyodbc.connect(
        connection_string,
        autocommit=True,
    )


def read_sql_file(sql_file_name: str) -> str:
    """
    Lê um arquivo SQL localizado na pasta sql/ e retorna o conteúdo como string.

    :param sql_file_name: Nome do arquivo SQL (ex: 'rel_os_aberto.sql')
    :return: Conteúdo do arquivo SQL
    """
    sql_path = SQL_DIR / sql_file_name

    if not sql_path.exists():
        raise FileNotFoundError(f"Arquivo SQL não encontrado: {sql_path}")

    return sql_path.read_text(encoding="utf-8")


def run_query(sql_file_name: str) -> pd.DataFrame:
    """
    Executa uma query SQL a partir de um arquivo e retorna o resultado
    como DataFrame do pandas.

    :param sql_file_name: Nome do arquivo SQL
    :return: DataFrame com o resultado da query
    """
    query = read_sql_file(sql_file_name)

    with get_connection() as connection:
        dataframe = pd.read_sql_query(query, connection)

    return dataframe


def extract_os_abertas() -> pd.DataFrame:
    """
    Extrai os dados de OS abertas.
    """
    return run_query("rel_os_aberto.sql")


def extract_os_concluidas() -> pd.DataFrame:
    """
    Extrai os dados de OS concluídas.
    """
    return run_query("fisc_ptfis_concluidas.sql")