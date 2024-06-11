WITH VW_TMOVORCAMENTO AS (
/*	VERIFICA VALORES NO PRODUTO DO OR�AMENTO	*/
	SELECT 
		TMOVORCAMENTO.CODCOLIGADA, 
		TMOVORCAMENTO.IDORCAMENTO, 
		TMOVORCAMENTO.IDPERIODO, 
		TMOVORCAMENTO.IDITMPERIODO,	
		SUM(TMOVORCAMENTO.VALORORCADO)	AS VALORORCADO, 
		SUM(TMOVORCAMENTO.VALORREAL)	AS VALORREAL,
		SUM(TITMMOV.VALORTOTALITEM) AS TITMMOV_VALORTOTALITEM,
		SUM(TMOVORCAMENTO.VALOROPCIONAL2) AS COMPROMETIDO,	
		SUM(TMOVORCAMENTO.VALORRECEBIDO)	AS VALORRECEBIDO, 
		SUM(TMOVORCAMENTO.VALORCEDIDO)	AS VALORCEDIDO, 
		SUM(TMOVORCAMENTO.VALOREXCEDENTE)	AS VALOREXCEDENTE 
	FROM 
			TMOVORCAMENTO (NOLOCK)
		LEFT JOIN  TITMMOV (NOLOCK) ON TMOVORCAMENTO.CODCOLIGADA =  TITMMOV.CODCOLIGADA AND TMOVORCAMENTO.IDMOV = TITMMOV.IDMOV
	WHERE 
			1=1 
		AND TMOVORCAMENTO.TIPO = 'I'
		--AND TMOVORCAMENTO.IDORCAMENTO = 512900--513273
		AND TMOVORCAMENTO.IDPERIODO = 28
		AND TMOVORCAMENTO.IDITMPERIODO IN (1,2,3,4,5,6)--,7,8,9,10,11,12)
	
	GROUP BY
		TMOVORCAMENTO.CODCOLIGADA, 
		TMOVORCAMENTO.IDORCAMENTO,  
		TMOVORCAMENTO.IDPERIODO, 
		TMOVORCAMENTO.IDITMPERIODO

),
VW_TITMORCAMENTO AS (
/*	VERIFICA VALORES NO MOVIMENTO	*/
	SELECT 
		TITMORCAMENTO.CODCOLIGADA, TITMORCAMENTO.IDORCAMENTO, TITMORCAMENTO.IDPERIODO, TITMORCAMENTO.IDITMPERIODO,	
		TITMORCAMENTO.VALORORCADO, TITMORCAMENTO.VALORREAL, TITMORCAMENTO.VALOROPCIONAL2 AS COMPROMETIDO,	
		TITMORCAMENTO.VALORRECEBIDO, TITMORCAMENTO.VALORCEDIDO, TITMORCAMENTO.VALOREXCEDENTE
	FROM 
		TITMORCAMENTO (NOLOCK)
	WHERE 
			1=1 
		--AND TITMORCAMENTO.IDORCAMENTO = 512900--513273
		AND TITMORCAMENTO.IDPERIODO = 28
		AND TITMORCAMENTO.IDITMPERIODO IN (1,2,3,4,5,6)--,7,8,9,10,11,12)
),
VW_TAB AS (
	SELECT 
		   TAB.CODCOLIGADA,
		   TAB.EMPRESA,
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
		   TAB.CODCCUSTO                                             AS 'CODCCUSTO',
		   TAB.CENTRODECUSTO                                         AS 'CENTRO DE CUSTO',
		   TAB.CODNATUREZA + '-' + TAB.NATUREZA                      AS 'NATUREZA',
		   TAB.CODNATUREZA											 AS	'CODNATUREZA'/*        ,CASE WHEN SUM(TAB.VALORORCADO) = 0 OR SUM(TAB.VALORREALIZADO) = 0 THEN SUM(TAB.VALORREALIZADO) ELSE  SUM(TAB.VALORORCADO) END AS 'VALOR ORCADO'        */,
		   TAB.IDORCAMENTO,
		   TAB.IDPERIODO,
		   TAB.IDITMPERIODO,
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
				   TITMORCAMENTO.IDORCAMENTO			 AS 'IDORCAMENTO',
				   TITMORCAMENTO.IDPERIODO				 AS 'IDPERIODO',
				   TITMORCAMENTO.IDITMPERIODO			 AS	'IDITMPERIODO',
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
				   --AND  CONVERT(VARCHAR(6), TITMPERIODOORCAMENTO.DATAINICIO, 112) BETWEEN '2024' + '01' AND '2024' + '12'
				   --AND	TORCAMENTO.CODCCUSTO = '01.04.02.01.02.006'	--'01.04.02.01.02.012'
				   --AND	TTBORCAMENTO.CODTBORCAMENTO = '2.7.01.001'	--'2.3.03.009'
				   AND  TITMORCAMENTO.IDPERIODO = 28
				   AND  TITMORCAMENTO.IDITMPERIODO IN (1,2,3,4,5,6)--,7,8,9,10,11,12)
				   --AND  TITMORCAMENTO.CODCOLIGADA = 2
				   --AND  TITMORCAMENTO.IDORCAMENTO = 512900--513273
			
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
					  TITMORCAMENTO.IDORCAMENTO,
					  TITMORCAMENTO.IDPERIODO,
					  TITMORCAMENTO.IDITMPERIODO,
					  TITMORCAMENTO.VALORORCADO,
					  TITMORCAMENTO.VALOROPCIONAL1,
					  TITMORCAMENTO.VALORRECEBIDO,
					  TITMORCAMENTO.VALOREXCEDENTE,
					  TITMORCAMENTO.VALORCEDIDO,
					  TITMORCAMENTO.VALOROPCIONAL2,
					  TITMORCAMENTO.VALORREAL
					  ) AS TAB

	GROUP  BY 
			  TAB.CODCOLIGADA,
			  TAB.EMPRESA,
			  TAB.FILIAL,
			  TAB.ANO,
			  TAB.MES,
			  TAB.CODCCUSTO,
			  TAB.CENTRODECUSTO,
			  TAB.CODNATUREZA,
			  TAB.NATUREZA,
			  TAB.IDORCAMENTO,
			  TAB.IDPERIODO,
			  TAB.IDITMPERIODO
), VW_ANTIGO AS (
	SELECT 
		TMOV.CODCOLIGADA,
		TMOV.CODFILIAL,
		TITMMOV.CODTBORCAMENTO AS CODTBORCAMENTO,
		MONTH(TITMMOV.DATAORCAMENTO) AS IDITMPERIODO,
		CASE WHEN YEAR(TITMMOV.DATAORCAMENTO) = 2024 AND TMOV.CODCOLIGADA = 1 THEN 24
			 WHEN YEAR(TITMMOV.DATAORCAMENTO) = 2024 AND TMOV.CODCOLIGADA = 2 THEN 28
		END AS IDPERIODO,
		TMOV.CODCCUSTO,
		CASE WHEN TMOV.CODTMV LIKE '1.2%' THEN TITMMOV.VALORTOTALITEM ELSE 0 END AS VALOR_REALIZADO 

    
	FROM 
			TMOV
		INNER JOIN TITMMOV ON TITMMOV.CODCOLIGADA = TMOV.CODCOLIGADA AND TITMMOV.IDMOV = TMOV.IDMOV
		INNER JOIN TTBORCAMENTO ON TTBORCAMENTO.CODTBORCAMENTO = TITMMOV.CODTBORCAMENTO
		LEFT JOIN FCFO ON FCFO.CODCOLIGADA = TMOV.CODCOLCFO AND FCFO.CODCFO = TMOV.CODCFO
		INNER JOIN GCCUSTO ON GCCUSTO.CODCOLIGADA = TMOV.CODCOLIGADA AND GCCUSTO.CODCCUSTO = TMOV.CODCCUSTO
		LEFT JOIN FLAN ON FLAN.CODCOLIGADA = TMOV.CODCOLIGADA AND FLAN.IDMOV = TMOV.IDMOV
		INNER JOIN TTMV ON TTMV.CODCOLIGADA = TMOV.CODCOLIGADA AND TTMV.CODTMV = TMOV.CODTMV
		INNER JOIN TITMTMV ON TITMTMV.CODCOLIGADA = TTMV.CODCOLIGADA AND TITMTMV.CODTMV = TTMV.CODTMV
	WHERE
			1=1
		AND TMOV.STATUS <> 'C'
		AND TMOV.VALORLIQUIDO > 0
		AND TITMTMV.EFEITOSALDOORCA NOT IN ('N')
		AND YEAR(TITMMOV.DATAORCAMENTO) BETWEEN 2024 AND 2024
		AND MONTH(TITMMOV.DATAORCAMENTO) BETWEEN 1 AND 6
		AND TMOV.CODCOLIGADA = 2
		--AND TITMMOV.CODTBORCAMENTO = '2.3.03.006'
		--AND TMOV.CODCCUSTO = '01.04.02.02.03.003'
	GROUP BY
		TITMMOV.CODTBORCAMENTO,
		TITMMOV.DATAORCAMENTO,
		TMOV.CODCCUSTO,
		TMOV.CODCOLIGADA,
		TMOV.CODFILIAL,
		TMOV.CODTMV,
		TITMMOV.VALORTOTALITEM
    
)
	SELECT
		VW_TMOVORCAMENTO.CODCOLIGADA,
		VW_TAB.EMPRESA,
		VW_TAB.FILIAL,
		VW_TAB.ANO,
		VW_TAB.MES,
		VW_TAB.CODCCUSTO,
		VW_TAB.CODNATUREZA,
		VW_TMOVORCAMENTO.IDORCAMENTO, 
		VW_TMOVORCAMENTO.IDPERIODO, 
		VW_TMOVORCAMENTO.IDITMPERIODO,
		VW_TAB.[VALOR ORCADO] AS CUBO_ORCADO,
		VW_TITMORCAMENTO.VALORORCADO AS TITM_ORCADO, 
		VW_TMOVORCAMENTO.VALORORCADO AS TMOV_ORCADO,
		VW_TMOVORCAMENTO.TITMMOV_VALORTOTALITEM AS TITMMOV_VALORTOTALITEM,
		SUM(VW_ANTIGO.VALOR_REALIZADO) AS ANTIGO_REAL,
		VW_TAB.[VALOR REALIZADO] AS CUBO_REAL,
		VW_TITMORCAMENTO.VALORREAL AS TITMORCAMENTO_REAL,
		VW_TMOVORCAMENTO.VALORREAL AS TMOVORCAMENTO_REAL, 
		VW_TAB.COMPROMETIDO AS CUBO_COMPROMETIDO,
		VW_TITMORCAMENTO.COMPROMETIDO AS TITM_COMPROMETIDO,
		VW_TMOVORCAMENTO.COMPROMETIDO AS TMOV_COMPROMETIDO,	
		VW_TAB.RECEBIDO AS CUBO_RECEBIDO,
		VW_TITMORCAMENTO.VALORRECEBIDO AS TITM_RECEBIDO, 
		VW_TMOVORCAMENTO.VALORRECEBIDO AS TMOV_RECEBIDO, 
		VW_TAB.CEDIDO AS CUBO_CEDIDO,
		VW_TITMORCAMENTO.VALORCEDIDO AS TITM_CEDIDO,
		VW_TMOVORCAMENTO.VALORCEDIDO AS TMOV_CEDIDO,
		VW_TAB.EXCEDENTE_REGRA AS CUBO_REGRA,
		VW_TAB.EXCEDENTE AS CUBO_EXCEDENTE,
		VW_TITMORCAMENTO.VALOREXCEDENTE AS TITM_EXCEDENTE,
		VW_TMOVORCAMENTO.VALOREXCEDENTE AS TMOV_EXCEDENTE 
	FROM 
		VW_TMOVORCAMENTO
		JOIN VW_TITMORCAMENTO	ON VW_TMOVORCAMENTO.CODCOLIGADA = VW_TITMORCAMENTO.CODCOLIGADA 
								AND VW_TMOVORCAMENTO.IDORCAMENTO = VW_TITMORCAMENTO.IDORCAMENTO 
								AND VW_TMOVORCAMENTO.IDPERIODO = VW_TITMORCAMENTO.IDPERIODO 
								AND VW_TMOVORCAMENTO.IDITMPERIODO = VW_TITMORCAMENTO.IDITMPERIODO
		JOIN VW_TAB				ON VW_TMOVORCAMENTO.CODCOLIGADA = VW_TAB.CODCOLIGADA
								AND VW_TMOVORCAMENTO.IDORCAMENTO = VW_TAB.IDORCAMENTO 
								AND VW_TMOVORCAMENTO.IDPERIODO = VW_TAB.IDPERIODO 
								AND VW_TMOVORCAMENTO.IDITMPERIODO = VW_TAB.IDITMPERIODO
		JOIN VW_ANTIGO			ON VW_TMOVORCAMENTO.CODCOLIGADA = VW_ANTIGO.CODCOLIGADA
								AND VW_TMOVORCAMENTO.IDPERIODO = VW_ANTIGO.IDPERIODO 
								AND VW_TMOVORCAMENTO.IDITMPERIODO = VW_ANTIGO.IDITMPERIODO
								AND VW_TAB.CODCCUSTO = VW_ANTIGO.CODCCUSTO 
								AND VW_TAB.CODNATUREZA = VW_ANTIGO.CODTBORCAMENTO
	WHERE
			1=1
		AND (
					VW_TITMORCAMENTO.VALORORCADO <> VW_TMOVORCAMENTO.VALORORCADO	
				OR  VW_TITMORCAMENTO.VALORREAL <> VW_TMOVORCAMENTO.VALORREAL
				OR  VW_TMOVORCAMENTO.TITMMOV_VALORTOTALITEM <> VW_TMOVORCAMENTO.VALORREAL
				OR  VW_TMOVORCAMENTO.TITMMOV_VALORTOTALITEM <> VW_TITMORCAMENTO.VALORREAL
				OR  VW_TITMORCAMENTO.COMPROMETIDO <> VW_TMOVORCAMENTO.COMPROMETIDO	
				OR  VW_TITMORCAMENTO.VALORRECEBIDO <> VW_TMOVORCAMENTO.VALORRECEBIDO	
				OR  VW_TITMORCAMENTO.VALORCEDIDO <> VW_TMOVORCAMENTO.VALORCEDIDO	
				OR  VW_TITMORCAMENTO.VALOREXCEDENTE <> VW_TMOVORCAMENTO.VALOREXCEDENTE 
		
				OR	VW_TITMORCAMENTO.VALORORCADO <> VW_TAB.[VALOR ORCADO]
				OR  VW_TITMORCAMENTO.VALORREAL <> VW_TAB.[VALOR REALIZADO]
				OR  VW_TMOVORCAMENTO.TITMMOV_VALORTOTALITEM <> VW_TAB.[VALOR REALIZADO]
				OR  VW_TITMORCAMENTO.COMPROMETIDO <> VW_TAB.COMPROMETIDO	
				OR  VW_TITMORCAMENTO.VALORRECEBIDO <> VW_TAB.RECEBIDO 	
				OR  VW_TITMORCAMENTO.VALORCEDIDO <> VW_TAB.RECEBIDO 	
				OR  VW_TITMORCAMENTO.VALOREXCEDENTE <> VW_TAB.EXCEDENTE
				OR  VW_TITMORCAMENTO.VALOREXCEDENTE <> VW_TAB.EXCEDENTE_REGRA
				OR	VW_TAB.EXCEDENTE <> VW_TAB.EXCEDENTE_REGRA

				OR	VW_TMOVORCAMENTO.VALORORCADO <> VW_TAB.[VALOR ORCADO]
				OR  VW_TMOVORCAMENTO.VALORREAL <> VW_TAB.[VALOR REALIZADO]
				OR  VW_TMOVORCAMENTO.COMPROMETIDO <> VW_TAB.COMPROMETIDO	
				OR  VW_TMOVORCAMENTO.VALORRECEBIDO <> VW_TAB.RECEBIDO 	
				OR  VW_TMOVORCAMENTO.VALORCEDIDO <> VW_TAB.RECEBIDO 	
				OR  VW_TMOVORCAMENTO.VALOREXCEDENTE <> VW_TAB.EXCEDENTE
				OR  VW_TMOVORCAMENTO.VALOREXCEDENTE <> VW_TAB.EXCEDENTE_REGRA	
			)
	GROUP BY
		VW_TMOVORCAMENTO.CODCOLIGADA,
		VW_TAB.EMPRESA,
		VW_TAB.FILIAL,
		VW_TAB.ANO,
		VW_TAB.MES,
		VW_TAB.CODCCUSTO,
		VW_TAB.CODNATUREZA,
		VW_TMOVORCAMENTO.IDORCAMENTO, 
		VW_TMOVORCAMENTO.IDPERIODO, 
		VW_TMOVORCAMENTO.IDITMPERIODO,
		VW_TAB.[VALOR ORCADO],
		VW_TITMORCAMENTO.VALORORCADO,
		VW_TMOVORCAMENTO.VALORORCADO,
		VW_TMOVORCAMENTO.TITMMOV_VALORTOTALITEM,
		VW_TAB.[VALOR REALIZADO],
		VW_TITMORCAMENTO.VALORREAL,
		VW_TMOVORCAMENTO.VALORREAL, 
		VW_TAB.COMPROMETIDO,
		VW_TITMORCAMENTO.COMPROMETIDO,
		VW_TMOVORCAMENTO.COMPROMETIDO,	
		VW_TAB.RECEBIDO,
		VW_TITMORCAMENTO.VALORRECEBIDO, 
		VW_TMOVORCAMENTO.VALORRECEBIDO, 
		VW_TAB.CEDIDO,
		VW_TITMORCAMENTO.VALORCEDIDO,
		VW_TMOVORCAMENTO.VALORCEDIDO,
		VW_TAB.EXCEDENTE_REGRA,
		VW_TAB.EXCEDENTE,
		VW_TITMORCAMENTO.VALOREXCEDENTE,
		VW_TMOVORCAMENTO.VALOREXCEDENTE
	HAVING (
				SUM(VW_ANTIGO.VALOR_REALIZADO) <> VW_TMOVORCAMENTO.VALORREAL
			OR	SUM(VW_ANTIGO.VALOR_REALIZADO) <> VW_TMOVORCAMENTO.TITMMOV_VALORTOTALITEM
			OR	SUM(VW_ANTIGO.VALOR_REALIZADO) <> VW_TITMORCAMENTO.VALORREAL
			OR	SUM(VW_ANTIGO.VALOR_REALIZADO) <> VW_TAB.[VALOR REALIZADO]
				
		   )
	ORDER BY
		VW_TMOVORCAMENTO.CODCOLIGADA, 
		VW_TMOVORCAMENTO.IDORCAMENTO, 
		VW_TMOVORCAMENTO.IDPERIODO, 
		VW_TMOVORCAMENTO.IDITMPERIODO


