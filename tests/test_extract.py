"""
Testes do módulo extract.py.
"""

from src.extract import extract_os_abertas, extract_os_concluidas


def test_extract_os_abertas() -> None:
    """
    Valida a extração de OS abertas.
    """
    dataframe = extract_os_abertas()

    assert not dataframe.empty
    assert "INSTALACAO" in dataframe.columns


def test_extract_os_concluidas() -> None:
    """
    Valida a extração de OS concluídas.
    """
    dataframe = extract_os_concluidas()

    assert not dataframe.empty
    assert "INSTALACAO" in dataframe.columns
