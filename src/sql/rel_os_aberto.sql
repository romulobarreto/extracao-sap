SELECT
    /* instalação sem zeros à esquerda, como número */
    TRY_TO_NUMBER(LTRIM(a.instalacao, '0')) AS instalacao,

    b.status_comercial AS status,

    /* nota sem zeros à esquerda */
    TRY_TO_NUMBER(LTRIM(a.nota, '0')) AS nota,

    a.status_ccs AS status_sap,
    a.criado_por AS usuario,

    /* data de abertura */
    CAST(a.data_criacao AS DATE) AS abertura,

    a.codificacao AS workflow,

    /* workcenter derivado */
    CASE
        WHEN a.codificacao = 'OPAT' AND b.regional = 'SUL'
        THEN 'RECEATSU'
        WHEN a.codificacao = 'OPAT' AND b.regional = 'NORTE'
        THEN 'RECEATNT'
        WHEN a.codificacao <> 'OPAT' AND b.regional = 'SUL'
        THEN 'RECEBOSU'
        WHEN a.codificacao <> 'OPAT' AND b.regional = 'NORTE'
        THEN 'RECEBONT'
    END AS workcenter,

    b.grupo_tensao AS grupo,

    /* medidor sem prefixo */
    CASE
        WHEN b.medidor IS NOT NULL
             AND LEFT(b.medidor, 2) BETWEEN 'AA' AND 'ZZ'
        THEN SUBSTR(b.medidor, 3)
        ELSE b.medidor
    END AS medidor,

    b.fase,
    b.micro_gerador AS mmgd,

    /* endereço tratado */
    CASE
        WHEN b.complemento IS NULL OR b.complemento = ''
        THEN b.endereco || ' ' || b.numero
        ELSE b.endereco || ' ' || b.numero || ' ' || b.complemento
    END AS endereco,

    /* bairro tratado */
    REGEXP_REPLACE(TRIM(b.bairro), '^[0-9]+\\s*', '') AS bairro,

    b.municipio,

    c.texto AS observacao

FROM eqtlinfo_prd.eqtl_rs.notas_servicos a

LEFT JOIN eqtlinfo_prd.eqtl_rs.tab_cadastro b
    ON TRY_TO_NUMBER(LTRIM(a.instalacao, '0'))
       = TRY_TO_NUMBER(LTRIM(b.instalacao, '0'))

LEFT JOIN eqtlinfo_prd.eqtl_rs.texto_obs_notas c
    ON TRY_TO_NUMBER(LTRIM(a.nota, '0'))
       = TRY_TO_NUMBER(LTRIM(c.nota, '0'))

WHERE a.tipo_nota = 'FS'
  AND a.status_ccs = 'ATIV'
  AND a.codificacao <> 'PEAF'

ORDER BY abertura DESC;
