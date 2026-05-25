SELECT DISTINCT
    /* instalação sem zeros à esquerda, como número */
    TRY_TO_NUMBER(LTRIM(a.instalacao, '0')) AS instalacao,

    c.status_comercial AS status,

    c.move_in AS inicio_contr,
    c.move_out AS fim_contr,

    /* nota sem zeros à esquerda, como número */
    TRY_TO_NUMBER(LTRIM(a.notificatn, '0')) AS nota,

    a.status_ccs AS status_sap,

    /* datas sem hora */
    TO_DATE(TO_VARCHAR(f.data_baixa), 'YYYYMMDD') AS data_baixa,
    CAST(b.data_final_servico AS DATE) AS data_fiscalizacao,

    d.toi,
    d.toi_assinado,

    a.nfcat_code AS workflow,
    a.workcenter,
    a.grupo,

    /* irregularidade como número */
    CASE   
        WHEN e.irregularidade IS NOT NULL
        THEN TRY_TO_NUMBER(LTRIM(e.irregularidade, '0'))
        ELSE 300
    END AS irreg,

    CASE
        WHEN a.cod_parecer IS NOT NULL 
        THEN a.cod_parecer
        ELSE '0001'
    END AS parecer_tec,

    CASE
        WHEN a.med_altera_equip IS NOT NULL
        THEN a.med_altera_equip
        ELSE 'MANTEM'
    END AS med_altera_equip,

    /* medidor sem prefixo */
    CASE
        WHEN c.medidor IS NOT NULL
             AND LEFT(c.medidor, 2) BETWEEN 'AA' AND 'ZZ'
        THEN SUBSTR(c.medidor, 3)
        ELSE c.medidor
    END AS medidor,

    a.usu_bx_medida_fs AS usuario_baixa,
    a.viatura AS placa

FROM sb_perdas.eqtl_rs.gp_fiscalizacoes a

LEFT JOIN eqtlinfo_prd.eqtl_rs.visitas_notas b
    ON TRY_TO_NUMBER(LTRIM(a.notificatn, '0'))
       = TRY_TO_NUMBER(LTRIM(b.nota, '0'))

LEFT JOIN eqtlinfo_prd.eqtl_rs.tab_cadastro c
    ON TRY_TO_NUMBER(LTRIM(a.instalacao, '0'))
       = TRY_TO_NUMBER(LTRIM(c.instalacao, '0'))

LEFT JOIN eqtlinfo_prd.eqtl_rs.info_gerais_notas d
    ON TRY_TO_NUMBER(LTRIM(a.notificatn, '0'))
       = TRY_TO_NUMBER(LTRIM(d.nota, '0'))

LEFT JOIN eqtlinfo_prd.eqtl_rs.notas_fiscalizacao e
    ON TRY_TO_NUMBER(LTRIM(a.notificatn, '0'))
       = TRY_TO_NUMBER(LTRIM(e.nota, '0'))

INNER JOIN eqtlinfo_prd.eqtl_rs.acoes_perdas f
    ON TRY_TO_NUMBER(LTRIM(a.notificatn, '0'))
       = TRY_TO_NUMBER(LTRIM(f.nota, '0'))

WHERE a.status_ccs = 'FINL'
  AND a.tipo_nota = 'FS'

ORDER BY data_baixa DESC;