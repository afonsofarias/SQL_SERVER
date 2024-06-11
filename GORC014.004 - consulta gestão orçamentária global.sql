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
       (	SELECT N1.CODTBORCAMENTO + ' - ' + N1.DESCRICAO
			FROM   TTBORCAMENTO AS N1 (NOLOCK)
			WHERE  CODCOLIGADA = N1.CODCOLIGADA
               AND LEFT(TAB.CODNATUREZA, 1) = N1.CODTBORCAMENTO) 
																 AS 'GRUPON1_COD',
       (	SELECT N2.CODTBORCAMENTO + ' - ' + N2.DESCRICAO
			FROM   TTBORCAMENTO AS N2 (NOLOCK)
			WHERE  CODCOLIGADA = N2.CODCOLIGADA
               AND LEFT(TAB.CODNATUREZA, 3) = N2.CODTBORCAMENTO)	
																 AS 'GRUPON2_COD',
       (	SELECT N3.CODTBORCAMENTO + ' - ' + N3.DESCRICAO
			FROM   TTBORCAMENTO AS N3 (NOLOCK)
			WHERE  CODCOLIGADA = N3.CODCOLIGADA
               AND LEFT(TAB.CODNATUREZA, 6) = N3.CODTBORCAMENTO) 
																 AS 'GRUPON3_COD',
       TAB.CODCCUSTO                                             AS 'COD. CCUSTO',
       TAB.CENTRODECUSTO                                         AS 'CENTRO DE CUSTO',
       TAB.CODNATUREZA + '-' + TAB.NATUREZA                      AS 'NATUREZA',
       TAB.CODNATUREZA											 AS	'CODNATUREZA '/*        ,CASE WHEN SUM(TAB.VALORORCADO) = 0 OR SUM(TAB.VALORREALIZADO) = 0 THEN SUM(TAB.VALORREALIZADO) ELSE  SUM(TAB.VALORORCADO) END AS 'VALOR ORCADO'        */,
       SUM(TAB.VALORORCADO)                                      AS 'VALOR ORCADO',
       SUM(TAB.REALIZADO)                                        AS 'VALOR REALIZADO',

       SUM(TAB.COMPROMETIDO)                                     AS 'COMPROMETIDO',
       SUM(TAB.EMPENHADO)                                        AS 'EMPENHADO',
       SUM(TAB.RECEBIDO)										 AS 'RECEBIDO',
	   /*SUM((TAB.VALORORCADO + TAB.RECEBIDO) - TAB.REALIZADO - TAB.EMPENHADO - TAB.COMPROMETIDO - TAB.CEDIDO)*/
       SUM(TAB.CEDIDO)                                           AS 'CEDIDO',
       SUM(TAB.EXCEDENTE)                                        AS 'EXCEDENTE',
	   
	   CASE WHEN	SUM(TAB.VALORORCADO) + SUM(TAB.RECEBIDO)
					< 
					SUM(TAB.REALIZADO) + SUM(TAB.EMPENHADO) + SUM(TAB.COMPROMETIDO) + SUM(TAB.CEDIDO)
			
			THEN	( (SUM(TAB.REALIZADO) + SUM(TAB.EMPENHADO) + SUM(TAB.COMPROMETIDO))  - SUM(TAB.VALORORCADO) + SUM(TAB.CEDIDO) - SUM(TAB.RECEBIDO) )
			
			WHEN	SUM(TAB.VALORORCADO) + SUM(TAB.RECEBIDO)
					>= 
					SUM(TAB.REALIZADO) + SUM(TAB.EMPENHADO) + SUM(TAB.COMPROMETIDO) + SUM(TAB.CEDIDO)
			THEN	0
	   END														 AS	'EXCEDENTE_REGRA',
	   
	   SUM(TAB.VALORORCADO - ( TAB.EMPENHADO   + TAB.COMPROMETIDO + TAB.REALIZADO  ) - TAB.CEDIDO + TAB.RECEBIDO)/* + TAB.EXCEDENTE)	PARA O SALDO MOSTRAR VALOR NEGATIVO QUANDO EXCEDER*/
																	AS 'SALDO'
/*		   VALOR OR�ADO    � (VALOR OPCIONAL 1 + VALOR OPCIONAL 2 + VALOR REALIZADO) - VLR CEDIDO + VLR RECEBIDO + VLR EXCEDENTE		***FORMULA TDN***	*/

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
               TITMORCAMENTO.VALORREAL               AS 'REALIZADO',
               TITMORCAMENTO.VALOROPCIONAL2          AS 'COMPROMETIDO',
               TITMORCAMENTO.VALOROPCIONAL1          AS 'EMPENHADO',
               TITMORCAMENTO.VALORRECEBIDO           AS 'RECEBIDO',
               TITMORCAMENTO.VALOREXCEDENTE          AS 'EXCEDENTE',
               TITMORCAMENTO.VALORCEDIDO             AS 'CEDIDO'
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
				AND	(		TITMORCAMENTO.VALORORCADO >= 0
						OR 
							TITMORCAMENTO.VALOROPCIONAL1 >= 0	)
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
                  TITMORCAMENTO.VALORCEDIDO,
				  TITMORCAMENTO.VALOROPCIONAL2,
				  TITMORCAMENTO.VALORREAL
                  ) AS TAB

GROUP  BY TAB.EMPRESA,
          TAB.FILIAL,
          TAB.ANO,
          TAB.MES,
          TAB.CODCCUSTO,
          TAB.CENTRODECUSTO,
          TAB.CODNATUREZA,
          TAB.NATUREZA