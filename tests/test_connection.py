"""
Testa a conexão ODBC com Snowflake utilizando External Browser.
"""

import pyodbc


def get_connection() -> pyodbc.Connection:
    """
    Cria e retorna uma conexão ODBC com o Snowflake.
    """
    connection_string = (
        "DSN=Snowflake_EQTL;"
        "authenticator=externalbrowser;"
    )

    return pyodbc.connect(
        connection_string,
        autocommit=True,
    )


def test_connection() -> None:
    """
    Executa uma query simples para validar a conexão.
    """
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute(
        """
        SELECT
            CURRENT_USER(),
            CURRENT_ROLE(),
            CURRENT_WAREHOUSE()
        """
    )

    result = cursor.fetchone()
    print(result)

    cursor.close()
    connection.close()


if __name__ == "__main__":
    test_connection()
