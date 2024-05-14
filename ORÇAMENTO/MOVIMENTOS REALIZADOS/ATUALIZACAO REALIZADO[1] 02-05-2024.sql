DECLARE @ANO_ AS INTEGER;
DECLARE @MES_INICIAL_ AS SMALLINT;
DECLARE @MES_FINAL_ AS SMALLINT;
DECLARE @CODCOLIGADA_ AS SMALLINT;

SET @ANO_ = 2024;
SET @MES_INICIAL_ = 1;
SET @MES_FINAL_ = 4;
SET @CODCOLIGADA_ = 2;

WITH VW_ORCAMENTO AS (
SELECT
		TMOVORCAMENTO.CODCOLIGADA,
		TMOVORCAMENTO.IDITMPERIODO,
		TMOVORCAMENTO.IDMOV,
		TMOVORCAMENTO.IDORCAMENTO,
		TMOVORCAMENTO.IDPERIODO,
		TORCAMENTO.CODCCUSTO										AS	'COD_CC',
		TORCAMENTO.CODTBORCAMENTO									AS	'COD_NATUREZA',
		TMOV.CODTMV													AS	'TIPO_MOV',
		TITMMOV.IDPRD												AS	'COD_PRDT',
		TPRD.NOMEFANTASIA											AS	'DESC_PRODUTO',
		GCCUSTO.NOME												AS	'CENTRO_CUSTO',
		TTBORCAMENTO.DESCRICAO										AS	'NATUREZA_ORCAMENTARIA',
		COALESCE(FCFO.NOMEFANTASIA, 'MOVIMENTO SEM FORNECEDOR')		AS	'FORNCECEDOR',
		AVG(TITMMOV.QUANTIDADETOTAL)								AS	'QTD_PRDT',
		AVG(TITMMOV.PRECOUNITARIO)									AS	'VLR_UND_PRDT',
		AVG(TITMMOV.VALORBRUTOITEM)									AS	'VLR_TOTAL_ITEM'
		
	FROM
		TMOVORCAMENTO (NOLOCK)
			JOIN TITMORCAMENTO (NOLOCK)
				ON TITMORCAMENTO.CODCOLIGADA = TMOVORCAMENTO.CODCOLIGADA
					AND TITMORCAMENTO.IDORCAMENTO = TMOVORCAMENTO.IDORCAMENTO
					AND TITMORCAMENTO.IDITMPERIODO = TMOVORCAMENTO.IDITMPERIODO
					AND TITMORCAMENTO.IDPERIODO = TMOVORCAMENTO.IDPERIODO
					
			JOIN TORCAMENTO (NOLOCK)
				ON TORCAMENTO.CODCOLIGADA = TITMORCAMENTO.CODCOLIGADA
					AND TORCAMENTO.IDPERIODO = TITMORCAMENTO.IDPERIODO
					AND TORCAMENTO.IDORCAMENTO = TITMORCAMENTO.IDORCAMENTO
			JOIN TMOV (NOLOCK) 
				ON TMOV.CODCOLIGADA = TMOVORCAMENTO.CODCOLIGADA	
					AND TMOV.IDMOV = TMOVORCAMENTO.IDMOV
			LEFT JOIN FCFO (NOLOCK)
				ON FCFO.CODCFO = TMOV.CODCFO
			JOIN TITMMOV (NOLOCK)
				ON TITMMOV.CODCOLIGADA = TMOV.CODCOLIGADA
					AND TITMMOV.IDMOV = TMOV.IDMOV
					AND	TITMMOV.CODTBORCAMENTO = TORCAMENTO.CODTBORCAMENTO
			JOIN GCCUSTO (NOLOCK)
				ON GCCUSTO.CODCOLIGADA = TITMMOV.CODCOLIGADA
					AND GCCUSTO.CODCCUSTO = TITMMOV.CODCCUSTO
			JOIN TTBORCAMENTO (NOLOCK)
				ON TTBORCAMENTO.CODTBORCAMENTO = TITMMOV.CODTBORCAMENTO
			JOIN TPRD (NOLOCK)
				ON TPRD.IDPRD = TITMMOV.IDPRD
					AND TPRD.CODCOLIGADA = TITMMOV.CODCOLIGADA 

			
	WHERE
		TMOVORCAMENTO.CODCOLIGADA = @CODCOLIGADA_
		AND TMOVORCAMENTO.IDPERIODO = CASE	WHEN TMOVORCAMENTO.CODCOLIGADA = 1 THEN 24
											WHEN TMOVORCAMENTO.CODCOLIGADA = 2 THEN 28
									  END
		AND	TMOVORCAMENTO.IDITMPERIODO BETWEEN @MES_INICIAL_ AND @MES_FINAL_
		AND TMOVORCAMENTO.IDMOV IS NOT NULL
		AND TMOVORCAMENTO.TIPO = 'I'
		AND TMOV.CODCOLIGADA	= @CODCOLIGADA_
		AND	YEAR(TMOV.DATAEMISSAO)	= @ANO_			
		AND	MONTH(TMOV.DATAEMISSAO)	BETWEEN @MES_INICIAL_ AND @MES_FINAL_
		AND TORCAMENTO.CODCCUSTO = '01.03.04.01.02.019'
		--AND TORCAMENTO.CODTBORCAMENTO = '3.1.02.003'
		AND TMOV.CODTMV IN ('1.2.01','1.2.02','1.2.03','1.2.04','1.2.05','1.2.06','1.2.07','1.2.08',
								 '1.2.09','1.2.10', '1.2.14', '1.2.15','1.2.17','1.2.18','1.2.26','1.2.33','1.2.34')
	GROUP BY 
		TMOVORCAMENTO.CODCOLIGADA,
		TMOVORCAMENTO.IDITMPERIODO,
		TMOVORCAMENTO.IDMOV,
		TMOVORCAMENTO.IDORCAMENTO,
		TMOVORCAMENTO.IDPERIODO,
		TORCAMENTO.CODCCUSTO,
		TORCAMENTO.CODTBORCAMENTO,
		TMOV.CODTMV,
		TITMMOV.IDPRD,
		TPRD.NOMEFANTASIA,
		FCFO.NOMEFANTASIA,
		GCCUSTO.NOME,
		TTBORCAMENTO.DESCRICAO

),
VW_RELAC AS (
SELECT DISTINCT
	TMOV.CODCOLIGADA,
	TMOV.IDMOV,
	TMOV.DATAEMISSAO,
	(	SELECT MAX(RASTREIAMOVIMENTOS.IDMOV) 
			FROM RASTREIAMOVIMENTOS(TMOV.CODCOLIGADA,TMOV.IDMOV)) AS 'IDMOV_RELAC'
		
FROM
	TMOV (NOLOCK)
WHERE
		1 						= 1
	AND TMOV.CODCOLIGADA		= @CODCOLIGADA_
	AND	YEAR(TMOV.DATAEMISSAO)	= @ANO_			
	AND	MONTH(TMOV.DATAEMISSAO) BETWEEN @MES_INICIAL_ AND @MES_FINAL_
)
SELECT DISTINCT	
	VW_ORCAMENTO.CODCOLIGADA,
	VW_ORCAMENTO.COD_CC,
	VW_ORCAMENTO.COD_NATUREZA,
	VW_ORCAMENTO.TIPO_MOV,
	VW_ORCAMENTO.IDMOV,
	VW_ORCAMENTO.IDORCAMENTO,
	VW_ORCAMENTO.IDITMPERIODO,
	VW_ORCAMENTO.IDPERIODO,
	AVG(VW_ORCAMENTO.VLR_TOTAL_ITEM) AS REALIZADO

FROM
	VW_ORCAMENTO
		JOIN VW_RELAC
			ON VW_RELAC.CODCOLIGADA = VW_ORCAMENTO.CODCOLIGADA
				AND VW_RELAC.IDMOV_RELAC = VW_ORCAMENTO.IDMOV
GROUP BY
	VW_ORCAMENTO.CODCOLIGADA,
	VW_ORCAMENTO.COD_CC,
	VW_ORCAMENTO.COD_NATUREZA,
	VW_ORCAMENTO.IDORCAMENTO,
	VW_ORCAMENTO.IDITMPERIODO,
	VW_ORCAMENTO.IDPERIODO,
	VW_ORCAMENTO.TIPO_MOV,
	VW_ORCAMENTO.IDMOV
