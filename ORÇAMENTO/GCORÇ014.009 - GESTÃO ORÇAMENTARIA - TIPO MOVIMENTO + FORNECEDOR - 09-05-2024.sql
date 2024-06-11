DECLARE @ANO_ AS INTEGER;
DECLARE @MES_INICIAL_ AS SMALLINT;
DECLARE @MES_FINAL_ AS SMALLINT;
DECLARE @CODCOLIGADA_ AS SMALLINT;
DECLARE	@CODFILIAL_ AS SMALLINT;

SET @ANO_ = 2024
SET @MES_INICIAL_ = 1
SET @MES_FINAL_ = 1
SET @CODCOLIGADA_ = 1
SET @CODFILIAL_ = 6;


WITH VW_ORCAMENTO AS (
SELECT
		TMOVORCAMENTO.CODCOLIGADA,
		TMOV.CODFILIAL												AS	'CODFILIAL',
		GFILIAL.NOMEFANTASIA										AS	'FILIAL',
		TMOVORCAMENTO.IDITMPERIODO									AS	'MES',
		TMOVORCAMENTO.IDMOV,
		TMOVORCAMENTO.IDORCAMENTO									AS	'ID_ORCAMENTO',
		TMOVORCAMENTO.IDPERIODO,			
		TORCAMENTO.CODCCUSTO										AS	'COD_CC',
		GCCUSTO.NOME												AS	'CENTRO_CUSTO',
		TPRODUTODEF.CODTBORCAMENTO									AS	'COD_NATUREZA',
		TTBORCAMENTO.DESCRICAO										AS	'NATUREZA_ORCAMENTARIA',
		TMOV.CODTMV													AS	'CODTMV',
		CONCAT(TMOV.CODTMV,' - ',TTMV.NOME)							AS	'TIPO_MOV',
		CASE 
        WHEN TITMTMV.EFEITOSALDOORCA = 'T' THEN 'AUMENTA O COMPROMETIDO'
        WHEN TITMTMV.EFEITOSALDOORCA = 'N' THEN 'NENHUM EFEITO NO OR�AMENTO'
        WHEN TITMTMV.EFEITOSALDOORCA = 'M' THEN 'AUMENTA O EMPENHADO'
        WHEN TITMTMV.EFEITOSALDOORCA = 'D' THEN 'DIMINUI O REALIZADO' 
        WHEN TITMTMV.EFEITOSALDOORCA = 'A' THEN 'AUMENTA O REALIZADO' 
		END															AS	'EFEITO',
		TITMMOV.IDPRD												AS	'COD_PRDT',
		TPRD.DESCRICAO												AS	'DESC_PRODUTO',
		COALESCE(FCFO.NOME, 'MOVIMENTO SEM FORNECEDOR')				AS	'FORNCECEDOR',
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
			JOIN TPRD (NOLOCK)
				ON TPRD.IDPRD = TITMMOV.IDPRD
					AND TPRD.CODCOLIGADA = TITMMOV.CODCOLIGADA 
			JOIN TPRODUTODEF (NOLOCK) 
				ON TPRD.CODCOLIGADA = TPRODUTODEF.CODCOLIGADA 
					AND TPRD.IDPRD = TPRODUTODEF.IDPRD
			JOIN TTBORCAMENTO (NOLOCK)
				ON TPRODUTODEF.CODCOLTBORCAMENTO = TTBORCAMENTO.CODCOLIGADA		/*	TTBORCAMENTO.CODTBORCAMENTO = TITMMOV.CODTBORCAMENTO	*/
					AND TPRODUTODEF.CODTBORCAMENTO = TTBORCAMENTO.CODTBORCAMENTO
			JOIN GFILIAL (NOLOCK)
				ON	TMOV.CODCOLIGADA = GFILIAL.CODCOLIGADA
					AND	TMOV.CODFILIAL = GFILIAL.CODFILIAL
			JOIN TTMV	(NOLOCK)
				ON	TMOV.CODCOLIGADA = TTMV.CODCOLIGADA
					AND	TMOV.CODTMV	= TTMV.CODTMV
			JOIN TTMVEXT (NOLOCK) 
				ON TTMV.CODCOLIGADA = TTMVEXT.CODCOLIGADA 
					AND TTMV.CODTMV = TTMVEXT.CODTMV
			JOIN TITMTMV (NOLOCK) 
				ON TITMTMV.CODCOLIGADA = TTMVEXT.CODCOLIGADA 
					AND TITMTMV.CODTMV = TTMVEXT.CODTMV
	WHERE
		TMOVORCAMENTO.CODCOLIGADA = @CODCOLIGADA_
		AND TMOVORCAMENTO.IDPERIODO = CASE	
											WHEN TMOVORCAMENTO.CODCOLIGADA = 1 THEN 24
											WHEN TMOVORCAMENTO.CODCOLIGADA = 2 THEN 28
									  END
		AND	TMOVORCAMENTO.IDITMPERIODO BETWEEN @MES_INICIAL_ AND @MES_FINAL_
		AND TMOVORCAMENTO.IDMOV IS NOT NULL
		AND TMOVORCAMENTO.TIPO = 'I'
		AND TMOV.CODCOLIGADA	= @CODCOLIGADA_
		AND	YEAR(TMOV.DATAEMISSAO)	= @ANO_			
		AND	MONTH(TMOV.DATAEMISSAO)	BETWEEN @MES_INICIAL_ AND @MES_FINAL_
		AND TMOV.CODFILIAL = @CODFILIAL_
	GROUP BY 
		TMOVORCAMENTO.CODCOLIGADA,
		TMOVORCAMENTO.IDITMPERIODO,
		TMOVORCAMENTO.IDMOV,
		TMOVORCAMENTO.IDORCAMENTO,
		TMOVORCAMENTO.IDPERIODO,
		TORCAMENTO.CODCCUSTO,
		TPRODUTODEF.CODTBORCAMENTO,
		TMOV.CODTMV,
		TTMV.NOME,
		TITMMOV.IDPRD,
		TPRD.DESCRICAO,
		FCFO.NOME,
		GCCUSTO.NOME,
		TTBORCAMENTO.DESCRICAO,
		TMOV.CODFILIAL,
		GFILIAL.NOMEFANTASIA,
		TITMTMV.EFEITOSALDOORCA
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
	VW_ORCAMENTO.*,
	(	SELECT N2.CODTBORCAMENTO + ' - ' + N2.DESCRICAO
			FROM   TTBORCAMENTO AS N2 (NOLOCK)
			WHERE  CODCOLIGADA = N2.CODCOLIGADA
               AND LEFT(VW_ORCAMENTO.COD_NATUREZA, 3) = N2.CODTBORCAMENTO
	)															AS 'GRUPO'
FROM
	VW_ORCAMENTO
		JOIN VW_RELAC
			ON VW_RELAC.CODCOLIGADA = VW_ORCAMENTO.CODCOLIGADA
				AND VW_RELAC.IDMOV_RELAC = VW_ORCAMENTO.IDMOV
WHERE	1=1

ORDER BY VW_ORCAMENTO.IDMOV,
		 VW_ORCAMENTO.CODTMV
				