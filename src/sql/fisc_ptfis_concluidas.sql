SELECT DISTINCT
    /* instalação sem zeros à esquerda, como número */
    TRY_TO_NUMBER(LTRIM(a.instalacao, '0')) AS instalacao,

    b.status_comercial AS status,

    b.move_in AS inicio_contr,
    b.move_out AS fim_contr,
    b.municipio,
    b.grupo_tensao AS grupo,

    /* medidor sem prefixo */
    CASE
        WHEN b.medidor IS NOT NULL
             AND LEFT(b.medidor, 2) BETWEEN 'AA' AND 'ZZ'
        THEN SUBSTR(b.medidor, 3)
        ELSE b.medidor
    END AS medidor,

    CASE
        WHEN e.med_altera_equip IS NOT NULL
        THEN e.med_altera_equip
        ELSE 'MANTEM'
    END AS med_altera_equip,

    /* nota sem zeros à esquerda */
    TRY_TO_NUMBER(LTRIM(a.nota, '0')) AS nota,

    LEFT(a.data_baixa, 6) AS cmpt,

    /* datas tratadas */
    TO_DATE(TO_VARCHAR(a.data_baixa), 'YYYYMMDD') AS data_baixa,
    TO_DATE(TO_VARCHAR(a.data_execucao), 'YYYYMMDD') AS data_fiscalizacao,

    c.toi,
    c.toi_assinado,

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

    /* irregularidade tratada */
    CASE
        WHEN TRY_TO_NUMBER(LTRIM(a.codigo_irregularidade, '0')) IS NULL
             AND a.grupo_medida = 'EFECADAS'
        THEN 154
        WHEN TRY_TO_NUMBER(LTRIM(a.codigo_irregularidade, '0')) IS NULL
        THEN 300
        ELSE TRY_TO_NUMBER(LTRIM(a.codigo_irregularidade, '0'))
    END AS irreg,

    /* classificação da irregularidade */
    CASE
        WHEN a.codificacao = 'OPAT'
             AND TRY_TO_NUMBER(LTRIM(a.codigo_irregularidade, '0')) IN
                 (109,115,129,131,132,136,143,146,154,156,164,165,168,171,172,174,175,176,188)
        THEN 'C100'

        WHEN a.codificacao = 'OPAT'
             AND TRY_TO_NUMBER(LTRIM(a.codigo_irregularidade, '0')) IN
                 (201,202,203,204,205,206,207,209,210,211,212,214,215,216,218,220,221,300,301,302,303,305,306,307,308,309,310,311,312,313,314,315)
        THEN 'ACAO'

        WHEN a.codificacao = 'OPAT'
             AND TRY_TO_NUMBER(LTRIM(a.codigo_irregularidade, '0')) IS NULL
        THEN 'ACAO'

        WHEN a.codificacao IN ('ALDS', 'ALCL')
             AND TRY_TO_NUMBER(LTRIM(a.codigo_irregularidade, '0')) IN (175, 154)
        THEN 'REGU'

        WHEN a.grupo_medida = 'EFECADAS'
             AND TRY_TO_NUMBER(LTRIM(a.codigo_irregularidade, '0')) IS NULL
        THEN 'REGU'

        WHEN a.codificacao <> 'OPAT'
             AND TRY_TO_NUMBER(LTRIM(a.codigo_irregularidade, '0')) IN
                 (109,115,129,154,164,165,168,171,172,174,175,176,188)
        THEN 'C100'

        WHEN a.codificacao <> 'OPAT'
             AND TRY_TO_NUMBER(LTRIM(a.codigo_irregularidade, '0')) IN
                 (201,202,203,204,210,211,212,214,215,221)
        THEN 'C200'

        WHEN a.codificacao <> 'OPAT'
             AND TRY_TO_NUMBER(LTRIM(a.codigo_irregularidade, '0')) IN
                 (307,308,310,311)
        THEN 'C300'

        WHEN a.codificacao <> 'OPAT'
             AND TRY_TO_NUMBER(LTRIM(a.codigo_irregularidade, '0')) IN
                 (300,301,302,303,305,306,309,312,314,315)
        THEN 'ACAO'

        WHEN a.codificacao <> 'OPAT'
             AND TRY_TO_NUMBER(LTRIM(a.codigo_irregularidade, '0')) IS NULL
        THEN 'ACAO'
    END AS classifica_irreg,

    /* validação de status */
    CASE
        WHEN TRY_TO_NUMBER(LTRIM(a.codigo_irregularidade, '0')) = 306
             AND b.status_comercial <> 'DS'
             AND b.move_in < TO_DATE(TO_VARCHAR(a.data_execucao), 'YYYYMMDD')
        THEN 'DESLIGAR'

        WHEN TRY_TO_NUMBER(LTRIM(a.codigo_irregularidade, '0')) = 314
             AND b.status_comercial <> 'DS'
             AND b.move_in < TO_DATE(TO_VARCHAR(a.data_execucao), 'YYYYMMDD')
        THEN 'DESLIGAR'

        WHEN TRY_TO_NUMBER(LTRIM(a.codigo_irregularidade, '0')) = 175
             AND b.status_comercial = 'DS'
             AND b.move_out < TO_DATE(TO_VARCHAR(a.data_execucao), 'YYYYMMDD')
        THEN 'LIGAR'
    END AS verif_status,

    a.grupo_medida,
    a.codigo_medida AS parecer_tec,

    d.nr_viatura AS placa,
    e.usu_bx_medida_fs AS usuario_baixa


/* tabelas */
FROM eqtlinfo_prd.eqtl_rs.acoes_perdas a

INNER JOIN eqtlinfo_prd.eqtl_rs.tab_cadastro b
    ON TRY_TO_NUMBER(LTRIM(a.instalacao, '0'))
       = TRY_TO_NUMBER(LTRIM(b.instalacao, '0'))

LEFT JOIN eqtlinfo_prd.eqtl_rs.info_gerais_notas c
    ON TRY_TO_NUMBER(LTRIM(a.nota, '0'))
       = TRY_TO_NUMBER(LTRIM(c.nota, '0'))

LEFT JOIN eqtlinfo_prd.eqtl_rs.visitas_notas d
    ON TRY_TO_NUMBER(LTRIM(a.nota, '0'))
       = TRY_TO_NUMBER(LTRIM(d.nota, '0'))

LEFT JOIN sb_perdas.eqtl_rs.gp_fiscalizacoes e
    ON TRY_TO_NUMBER(LTRIM(a.nota, '0'))
       = TRY_TO_NUMBER(LTRIM(e.notificatn, '0'))


/* condições */
WHERE a.data_baixa >= '20260401'


/* ordenação */
ORDER BY data_baixa DESC;
