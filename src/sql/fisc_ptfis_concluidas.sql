SELECT
    /* INSTALAÇÃO sem zeros à esquerda, como número */
    TRY_TO_NUMBER(LTRIM(a.instalacao, '0')) AS instalacao,

    c.status_comercial AS status,

    c.move_in AS inicio_contr,
    c.move_out AS fim_contr,

    /* NOTA sem zeros à esquerda, como número */
    TRY_TO_NUMBER(LTRIM(a.notificatn, '0')) AS nota,

    a.status_ccs AS status_sap,

    /* Datas sem hora */
    CAST(a.dta_modifica_ns AS DATE) AS data_conclusao,
    CAST(b.data_final_servico AS DATE) AS data_fiscalizacao,

    a.nfcat_code AS workflow,
    a.workcenter,
    a.grupo,

    /* Irregularidade como número */
    TRY_TO_NUMBER(a.cod_irreg) AS irreg,

    a.cod_parecer AS parecer_tec,
    a.med_altera_equip,

    /* Medidor sem prefixo */
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
WHERE a.status_ccs = 'FINL'
  AND a.tipo_nota = 'FS';
