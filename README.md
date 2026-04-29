
# 📊 Relatório Automático de OS — SAP (Snowflake + Excel + Email)

> Extração diária de Ordens de Serviço **abertas** e **concluídas** diretamente do Snowflake, com geração de relatórios em Excel e envio automático por e‑mail.

![Python](https://img.shields.io/badge/Python-3.12-2E3079?logo=python&logoColor=white)
![Poetry](https://img.shields.io/badge/Poetry-Enabled-6763AC?logo=poetry&logoColor=white)
![Tests](https://img.shields.io/badge/Tests-Pytest-0A9EDC?logo=pytest&logoColor=white)
![Snowflake](https://img.shields.io/badge/Data-Snowflake-29B5E8?logo=snowflake&logoColor=white)

---

## 🚀 Por que esse projeto existe?

Automatizar a extração de OS abertas e concluídas diretamente do Snowflake, eliminando processos manuais em Excel e envio manual por e‑mail.

---

## 🎯 O que ele faz?

1. Conecta no Snowflake  
2. Executa duas consultas SQL  
3. Gera dois arquivos Excel  
4. Envia os arquivos por e‑mail  
5. Registra logs da execução  

---

## 🛠️ Execução

```bash
poetry install
task run
```

## 👨🏻‍💻 Autor
Rômulo Barreto da Silva