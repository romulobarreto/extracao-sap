"""
Testes do módulo de exportação para Excel.
"""

from pathlib import Path

import pandas as pd

from src.export_excel import export_dataframe_to_excel


def test_export_dataframe_to_excel(tmp_path: Path) -> None:
    """
    Deve gerar um arquivo Excel no diretório de saída informado.
    """
    # Arrange
    dataframe = pd.DataFrame(
        {
            "INSTALACAO": [123, 456],
            "STATUS": ["ATIV", "FINL"],
        }
    )

    output_dir = tmp_path / "output"

    # Act
    file_path = export_dataframe_to_excel(
        dataframe=dataframe,
        file_prefix="os_teste",
        output_dir=output_dir,
    )

    # Assert
    assert file_path.exists()
    assert file_path.suffix == ".xlsx"
    assert file_path.parent == output_dir
    assert file_path.stat().st_size > 0
