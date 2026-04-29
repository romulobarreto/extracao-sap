SELECT
    /* INSTALAÇÃO sem zeros à esquerda, como número */
    TRY_TO_NUMBER(LTRIM(a.instalacao, '0')) AS instalacao,

    b.status_comercial AS status,

    /* NOTA sem zeros à esquerda, como número */
    TRY_TO_NUMBER(LTRIM(a.notificatn, '0')) AS nota,

    a.status_ccs AS status_sap,
    a.usu_criacao_ns AS usuario,

    /* Data de abertura sem hora */
    CAST(a.dta_origem_ns AS DATE) AS abertura,

    a.nfcat_code AS workflow,
    a.workcenter,
    b.grupo_tensao AS grupo,

    /* Medidor sem prefixo (MD, RG, etc.) */
    CASE
        WHEN b.medidor IS NOT NULL
             AND LEFT(b.medidor, 2) BETWEEN 'AA' AND 'ZZ'
        THEN SUBSTR(b.medidor, 3)
        ELSE b.medidor
    END AS medidor,

    b.fase,
    b.micro_gerador,

    /* Endereço tratado como texto */
    CASE
        WHEN b.complemento IS NULL OR b.complemento = ''
            THEN b.endereco || ' ' || b.numero
        ELSE b.endereco || ' ' || b.numero || ' ' || b.complemento
    END AS endereco,

    b.bairro,
    b.municipio,
    c.texto AS observacao

FROM sb_perdas.eqtl_rs.gp_fiscalizacoes a

LEFT JOIN eqtlinfo_prd.eqtl_rs.tab_cadastro b
    ON TRY_TO_NUMBER(LTRIM(a.instalacao, '0'))
       = TRY_TO_NUMBER(LTRIM(b.instalacao, '0'))

LEFT JOIN eqtlinfo_prd.eqtl_rs.texto_obs_notas c
    ON TRY_TO_NUMBER(LTRIM(a.notificatn, '0'))
    = TRY_TO_NUMBER(LTRIM(c.nota, '0'))

WHERE a.tipo_nota = 'FS'
  AND a.status_ccs = 'ATIV';