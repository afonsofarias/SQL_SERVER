DECLARE @ANOINICIAL AS VARCHAR(4)
DECLARE @ANOFINAL AS VARCHAR(4)
DECLARE @MESINICIAL AS VARCHAR(2)
DECLARE @MESFINAL AS VARCHAR(2)

SET @ANOINICIAL = :ano_inicial
SET @ANOFINAL = :ano_final
SET @MESINICIAL = :mes_inicial
SET @MESFINAL = :mes_final


SELECT TAB.EMPRESA,
       TAB.FILIAL,
       TAB.ANO,
       TAB.MES,
       TAB.REF,
       (SELECT N1.CODTBORCAMENTO + ' - ' + N1.DESCRICAO
        FROM   TTBORCAMENTO AS N1 (NOLOCK)
        WHERE  CODCOLIGADA = N1.CODCOLIGADA
               AND LEFT(TAB.CODNATUREZA, 1) = N1.CODTBORCAMENTO) AS 'GRUPON1_COD',
       (SELECT N2.CODTBORCAMENTO + ' - ' + N2.DESCRICAO
        FROM   TTBORCAMENTO AS N2 (NOLOCK)
        WHERE  CODCOLIGADA = N2.CODCOLIGADA
               AND LEFT(TAB.CODNATUREZA, 3) = N2.CODTBORCAMENTO) AS 'GRUPON2_COD',
       (SELECT N3.CODTBORCAMENTO + ' - ' + N3.DESCRICAO
        FROM   TTBORCAMENTO AS N3 (NOLOCK)
        WHERE  CODCOLIGADA = N3.CODCOLIGADA
               AND LEFT(TAB.CODNATUREZA, 6) = N3.CODTBORCAMENTO) AS 'GRUPON3_COD',
       TAB.CODCCUSTO                                             AS 'COD. CCUSTO',
       TAB.CENTRODECUSTO                                         AS 'CENTRO DE CUSTO',
       TAB.CODNATUREZA + '-' + TAB.NATUREZA                      AS 'NATUREZA',
       TAB.CODNATUREZA											 AS	'CODNATUREZA '/*        ,CASE WHEN SUM(TAB.VALORORCADO) = 0 OR SUM(TAB.VALORREALIZADO) = 0 THEN SUM(TAB.VALORREALIZADO) ELSE  SUM(TAB.VALORORCADO) END AS 'VALOR ORCADO'        */,
       SUM(TAB.VALORORCADO)                                      AS 'VALOR ORCADO',
       SUM(TAB.REALIZADO)                                        AS 'VALOR REALIZADO',
       SUM(TAB.VALORORCADO - ( TAB.EMPENHADO + TAB.COMPROMETIDO + TAB.REALIZADO ) - TAB.CEDIDO + TAB.RECEBIDO + (-TAB.EXCEDENTE))	
																 AS 'SALDO',
                /* VALOR ORÇADO – (VALOR OPCIONAL 1 + VALOR OPCIONAL 2 + VALOR REALIZADO) - VLR CEDIDO + VLR RECEBIDO + VLR EXCEDENTE */
       SUM(TAB.COMPROMETIDO)                                     AS 'COMPROMETIDO',
       TAB.EMPENHADO                                             AS 'EMPENHADO',
       TAB.RECEBIDO                                              AS 'RECEBIDO',
       TAB.EXCEDENTE                                             AS 'EXCEDENTE',
       TAB.CEDIDO                                                AS 'CEDIDO',
	   TAB.FORNECEDOR											 AS 'FORNECEDOR'
FROM   
	   (SELECT GCOLIGADA.CODCOLIGADA,
               GCOLIGADA.NOMEFANTASIA                'EMPRESA',
               0                                     AS REF,
               CASE
                 WHEN CHARINDEX('-', GCCUSTO.NOME) >= 1 THEN LEFT(GCCUSTO.NOME, CHARINDEX('-', GCCUSTO.NOME) - 1)
                 ELSE GCCUSTO.NOME
               END                                   AS FILIAL,
               YEAR(TITMPERIODOORCAMENTO.DATAINICIO)  AS 'ANO',
               MONTH(TITMPERIODOORCAMENTO.DATAINICIO) AS 'MES',
               TORCAMENTO.CODCCUSTO                  AS 'CODCCUSTO',
               GCCUSTO.NOME                          AS	'CENTRODECUSTO',
               TTBORCAMENTO.CODTBORCAMENTO           AS	'CODNATUREZA',
               TTBORCAMENTO.DESCRICAO                AS	'NATUREZA',
               TITMORCAMENTO.VALORORCADO             AS	'VALORORCADO',
               0                                     AS 'REALIZADO',
               0                                     AS 'COMPROMETIDO',
               TITMORCAMENTO.VALOROPCIONAL1          AS 'EMPENHADO',
               TITMORCAMENTO.VALORRECEBIDO           AS 'RECEBIDO',
               TITMORCAMENTO.VALOREXCEDENTE          AS 'EXCEDENTE',
               TITMORCAMENTO.VALORCEDIDO             AS 'CEDIDO',
			   'VALOR ORÇADO'						 AS 'FORNECEDOR'
        FROM   TORCAMENTO (NOLOCK)
               INNER JOIN GCOLIGADA (NOLOCK)
                       ON TORCAMENTO.CODCOLIGADA = GCOLIGADA.CODCOLIGADA
               INNER JOIN GCCUSTO (NOLOCK)
                       ON TORCAMENTO.CODCOLIGADA = GCCUSTO.CODCOLIGADA
                          AND TORCAMENTO.CODCCUSTO = GCCUSTO.CODCCUSTO
                          AND LEN(GCCUSTO.CODCCUSTO) >= 18
               INNER JOIN TTBORCAMENTO (NOLOCK)
                       ON TORCAMENTO.CODCOLTBORCAMENTO = TTBORCAMENTO.CODCOLIGADA
                          AND TORCAMENTO.CODTBORCAMENTO = TTBORCAMENTO.CODTBORCAMENTO
               INNER JOIN TITMORCAMENTO (NOLOCK)
                       ON TITMORCAMENTO.CODCOLIGADA = TORCAMENTO.CODCOLIGADA
                          AND TITMORCAMENTO.IDORCAMENTO = TORCAMENTO.IDORCAMENTO
                          AND TITMORCAMENTO.IDPERIODO = TORCAMENTO.IDPERIODO
               INNER JOIN TITMPERIODOORCAMENTO (NOLOCK)
                       ON TITMORCAMENTO.CODCOLIGADA = TITMPERIODOORCAMENTO.CODCOLIGADA
                          AND TITMORCAMENTO.IDPERIODO = TITMPERIODOORCAMENTO.IDPERIODO
                          AND TITMORCAMENTO.IDITMPERIODO = TITMPERIODOORCAMENTO.IDITMPERIODO
               INNER JOIN TPERIODOORCAMENTO (NOLOCK)
                       ON TITMPERIODOORCAMENTO.CODCOLIGADA = TPERIODOORCAMENTO.CODCOLIGADA
                          AND TITMPERIODOORCAMENTO.IDPERIODO = TPERIODOORCAMENTO.IDPERIODO
        WHERE  1 = 1
               AND ( TITMORCAMENTO.VALORORCADO > 0
                      OR TITMORCAMENTO.VALOROPCIONAL1 > 0 )
               AND CONVERT(VARCHAR(6), TITMPERIODOORCAMENTO.DATAINICIO, 112) BETWEEN @ANOINICIAL + @MESINICIAL AND @ANOFINAL + @MESFINAL
        GROUP  BY GCOLIGADA.CODCOLIGADA,
                  GCOLIGADA.NOMEFANTASIA,
                  TITMPERIODOORCAMENTO.DATAINICIO,
                  CASE
                    WHEN CHARINDEX('-', GCCUSTO.NOME) >= 1 THEN LEFT(GCCUSTO.NOME, CHARINDEX('-', GCCUSTO.NOME) - 1)
                    ELSE GCCUSTO.NOME
                  END,
                  YEAR(TITMPERIODOORCAMENTO.DATAINICIO),
                  MONTH(TITMPERIODOORCAMENTO.DATAINICIO),
                  TORCAMENTO.CODCCUSTO,
                  GCCUSTO.NOME,
                  TTBORCAMENTO.CODTBORCAMENTO,
                  TTBORCAMENTO.DESCRICAO,
                  TITMORCAMENTO.VALORORCADO,
                  TITMORCAMENTO.VALOROPCIONAL1,
                  TITMORCAMENTO.VALORRECEBIDO,
                  TITMORCAMENTO.VALOREXCEDENTE,
                  TITMORCAMENTO.VALORCEDIDO

        UNION ALL
        SELECT GCOLIGADA.CODCOLIGADA,
               GCOLIGADA.NOMEFANTASIA      'EMPRESA',
               FLAN.IDLAN                  AS REF,
               CASE
                 WHEN CHARINDEX('-', GCCUSTO.NOME) >= 1 THEN LEFT(GCCUSTO.NOME, CHARINDEX('-', GCCUSTO.NOME) - 1)
                 ELSE GCCUSTO.NOME
               END                         AS FILIAL,
               YEAR(FLANBAIXA.DATABAIXA)   'ANO',
               MONTH(FLANBAIXA.DATABAIXA)  'MES',
               GCCUSTO.CODCCUSTO           AS 'CODCCUSTO',
               GCCUSTO.NOME                'CENTRODECUSTO',
               TTBORCAMENTO.CODTBORCAMENTO 'CODNATUREZA',
               TTBORCAMENTO.DESCRICAO      'NATUREZA',
               0                           'VALORORCADO',
               FLANBAIXARATCCU.VALOR       AS 'REALIZADO',
               0                           AS 'COMPROMETIDO',
               0                           AS 'EMPENHADO',
               0                           AS 'RECEBIDO',
               0                           AS 'EXCEDENTE',
               0                           AS 'CEDIDO',
			   FCFO.NOME				   AS 'FORNECEDOR'
        FROM   FLAN (NOLOCK)
               INNER JOIN GCOLIGADA (NOLOCK)
                       ON FLAN.CODCOLIGADA = GCOLIGADA.CODCOLIGADA
               INNER JOIN FLANBAIXA (NOLOCK)
                       ON FLAN.CODCOLIGADA = FLANBAIXA.CODCOLIGADA
                          AND FLAN.IDLAN = FLANBAIXA.IDLAN
               INNER JOIN FLANBAIXARATCCU (NOLOCK)
                       ON FLANBAIXA.CODCOLIGADA = FLANBAIXARATCCU.CODCOLIGADA
                          AND FLANBAIXA.IDBAIXA = FLANBAIXARATCCU.IDBAIXA
               INNER JOIN GCCUSTO (NOLOCK)
                       ON FLANBAIXARATCCU.CODCOLIGADA = GCCUSTO.CODCOLIGADA
                          AND FLANBAIXARATCCU.CODCCUSTO = GCCUSTO.CODCCUSTO
                          AND LEN(GCCUSTO.CODCCUSTO) >= 18
               INNER JOIN TTBORCAMENTO (NOLOCK)
                       ON FLANBAIXARATCCU.CODCOLNATFINANCEIRA = TTBORCAMENTO.CODCOLIGADA
                          AND FLANBAIXARATCCU.CODNATFINANCEIRA = TTBORCAMENTO.CODTBORCAMENTO
			   INNER JOIN FCFO (NOLOCK)
					   ON FLAN.CODCOLCFO = FCFO.CODCOLIGADA
						  AND FLAN.CODCFO = FCFO.CODCFO	
        WHERE  1 = 1
               AND FLAN.PAGREC = 2
               AND FLANBAIXA.STATUS = 0
               AND FLANBAIXARATCCU.VALOR > 0
               AND CONVERT(VARCHAR(6), FLANBAIXA.DATABAIXA, 112) BETWEEN @ANOINICIAL + @MESINICIAL AND @ANOFINAL + @MESFINAL
               AND FLAN.NFOUDUP IN ( 0, 2 )
               AND FLAN.CLASSIFICACAO <> 4
               AND FLAN.STATUSLAN <> 2
        GROUP  BY GCOLIGADA.CODCOLIGADA,
                  GCOLIGADA.NOMEFANTASIA,
                  FLAN.IDLAN,
                  CASE
                    WHEN CHARINDEX('-', GCCUSTO.NOME) >= 1 THEN LEFT(GCCUSTO.NOME, CHARINDEX('-', GCCUSTO.NOME) - 1)
                    ELSE GCCUSTO.NOME
                  END,
                  YEAR(FLANBAIXA.DATABAIXA),
                  MONTH(FLANBAIXA.DATABAIXA),
                  GCCUSTO.CODCCUSTO,
                  GCCUSTO.NOME,
                  TTBORCAMENTO.CODTBORCAMENTO,
                  TTBORCAMENTO.DESCRICAO,
                  FLAN.DATAEMISSAO,
                  FLANBAIXARATCCU.VALOR,
				  FCFO.NOME

        UNION ALL
        SELECT GCOLIGADA.CODCOLIGADA,
               GCOLIGADA.NOMEFANTASIA      'EMPRESA',
               FLAN.IDLAN                  AS REF,
               CASE
                 WHEN CHARINDEX('-', GCCUSTO.NOME) >= 1 THEN LEFT(GCCUSTO.NOME, CHARINDEX('-', GCCUSTO.NOME) - 1)
                 ELSE GCCUSTO.NOME
               END                         AS FILIAL,
               YEAR(FLAN.DATAVENCIMENTO)   AS ANO,
               MONTH(FLAN.DATAVENCIMENTO)  AS MES,
               GCCUSTO.CODCCUSTO           AS CODCCUSTO,
               GCCUSTO.NOME                AS CENTRODECUSTO,
               TTBORCAMENTO.CODTBORCAMENTO AS 'CODNATUREZA',
               TTBORCAMENTO.DESCRICAO      AS 'NATUREZA',
               0                           AS 'VALORORCADO',
               0                           AS 'REALIZADO',
               FLANRATCCU.VALOR            AS 'COMPROMETIDO',
               0                           AS 'EMPENHADO',
               0                           AS 'RECEBIDO',
               0                           AS 'EXCEDENTE',
               0                           AS 'CEDIDO',
			   FCFO.NOME				   AS 'FORNECEDOR'
        FROM   FLAN
               INNER JOIN GFILIAL FILIAL (NOLOCK)
                       ON FILIAL.CODCOLIGADA = FLAN.CODCOLIGADA
                          AND FILIAL.CODFILIAL = FLAN.CODFILIAL
               INNER JOIN FLANRATCCU (NOLOCK)
                       ON FLANRATCCU.CODCOLIGADA = FLAN.CODCOLIGADA
                          AND FLANRATCCU.IDLAN = FLAN.IDLAN
               LEFT JOIN FLANBAIXA (NOLOCK)
                      ON FLAN.CODCOLIGADA = FLANBAIXA.CODCOLIGADA
                         AND FLAN.IDLAN = FLANBAIXA.IDLAN
                         AND FLANBAIXA.STATUS = 0
               INNER JOIN TTBORCAMENTO (NOLOCK)
                       ON FLANRATCCU.CODCOLNATFINANCEIRA = TTBORCAMENTO.CODCOLIGADA
                          AND FLANRATCCU.CODNATFINANCEIRA = TTBORCAMENTO.CODTBORCAMENTO
               INNER JOIN GCCUSTO (NOLOCK)
                       ON FLANRATCCU.CODCOLIGADA = GCCUSTO.CODCOLIGADA
                          AND FLANRATCCU.CODCCUSTO = GCCUSTO.CODCCUSTO
                          AND LEN(GCCUSTO.CODCCUSTO) >= 18
               INNER JOIN GCOLIGADA (NOLOCK)
                       ON FLAN.CODCOLIGADA = GCOLIGADA.CODCOLIGADA
			   INNER JOIN FCFO (NOLOCK)
					   ON FLAN.CODCOLCFO = FCFO.CODCOLIGADA
						  AND FLAN.CODCFO = FCFO.CODCFO	
        WHERE  FLAN.PAGREC = 2
               AND FLAN.NFOUDUP IN ( 0, 2 )
               AND FLAN.CLASSIFICACAO <> 4
               AND FLAN.STATUSLAN <> 2
               AND CONVERT(VARCHAR(6), FLAN.DATAVENCIMENTO, 112) BETWEEN @ANOINICIAL + @MESINICIAL AND @ANOFINAL + @MESFINAL
               AND FLANBAIXA.DATABAIXA IS NULL
        GROUP  BY GCOLIGADA.CODCOLIGADA,
                  GCOLIGADA.NOMEFANTASIA,
                  FLAN.IDLAN,
                  FLAN.CODFILIAL,
                  FILIAL.NOMEFANTASIA,
                  TTBORCAMENTO.CODTBORCAMENTO,
                  TTBORCAMENTO.DESCRICAO,
                  FLAN.DATAVENCIMENTO,
                  GCCUSTO.CODCCUSTO,
                  GCCUSTO.NOME,
                  FLANBAIXA.DATABAIXA,
                  FLAN.DATAEMISSAO,
				  FCFO.NOME,
                  FLANRATCCU.VALOR) AS TAB

WHERE  TAB.CODCCUSTO IN ( '01.01.01.07.01.001', '01.01.01.07.02.001', '01.01.01.07.03.001', '01.01.01.07.04.001',
                          '01.01.01.08.01.004', '01.01.01.08.01.005', '01.02.01.01.02.001', '01.02.01.01.02.011',
                          '01.02.01.01.02.012', '01.02.01.01.02.024', '01.02.01.01.02.027', '01.02.02.01.02.001',
                          '01.02.02.01.02.011', '01.02.02.01.02.024', '01.02.04.01.02.001', '01.02.04.01.02.011',
                          '01.02.04.01.02.012', '01.02.04.01.02.024', '01.02.04.01.02.027', '01.02.06.01.02.001',
                          '01.02.06.01.02.011', '01.02.06.01.02.012', '01.02.06.01.02.024', '01.02.06.01.02.027',
                          '01.02.08.01.02.001', '01.02.08.01.02.011', '01.02.08.01.02.012', '01.02.08.01.02.024',
                          '01.02.08.01.02.027', '01.03.01.01.02.001', '01.03.01.01.02.011', '01.03.01.01.02.012',
                          '01.03.01.01.02.024', '01.03.01.01.02.027', '01.03.04.01.02.001', '01.03.04.01.02.011',
                          '01.03.04.01.02.012', '01.03.04.01.02.024', '01.03.04.01.02.027', '01.04.02.01.02.001',
                          '01.04.02.01.02.011', '01.04.02.01.02.012', '01.04.02.01.02.024', '01.04.02.01.02.027',
                          '01.05.05.01.02.001', '01.05.05.01.02.011', '01.05.05.01.02.012', '01.05.05.01.02.024',
                          '01.05.05.01.02.027', '01.06.06.01.02.001', '01.06.06.01.02.011', '01.06.06.01.02.012',
                          '01.06.06.01.02.024', '01.06.06.01.02.027','01.01.01.07.02.002' )					

GROUP  BY TAB.EMPRESA,
          TAB.FILIAL,
          TAB.ANO,
          TAB.MES,
          TAB.REF,
          TAB.CODCCUSTO,
          TAB.CENTRODECUSTO,
          TAB.CODNATUREZA,
          TAB.NATUREZA,
          TAB.EMPENHADO,
          TAB.RECEBIDO,
          TAB.EXCEDENTE,
          TAB.CEDIDO,
		  TAB.FORNECEDOR
HAVING SUM(VALORORCADO) > 0
        OR SUM(REALIZADO) > 0
        OR SUM(COMPROMETIDO) > 0
