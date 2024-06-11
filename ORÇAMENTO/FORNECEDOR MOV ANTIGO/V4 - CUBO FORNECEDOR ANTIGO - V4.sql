WITH REALIZADO AS
(
SELECT DISTINCT 
	TMOVORCAMENTO.CODCOLIGADA,
	TMOV.CODFILIAL,
	TMOV.DATAEMISSAO,
	TMOVORCAMENTO.IDITMPERIODO,
	TMOVORCAMENTO.IDPERIODO,
	TMOVORCAMENTO.IDORCAMENTO,
	TMOVORCAMENTO.IDMOV,
	TMOV.CODTMV,
	TMOVORCAMENTO.IDMOVORCAMENTO,
	TMOVORCAMENTO.VALORREAL,
	TITMORCAMENTO.VALOROPCIONAL2,
	CASE WHEN FCFO.CODCFO IS NULL THEN CONCAT('N�O INFORMADO NO MOVIMENTO ',TMOV.CODTMV) ELSE FCFO.CODCFO END	AS CODCFO,
	CASE WHEN FCFO.NOME IS NULL THEN CONCAT('N�O INFORMADO NO MOVIMENTO ',TMOV.CODTMV) ELSE FCFO.NOME END 		AS FORNECEDOR
	
FROM 
	TMOVORCAMENTO (NOLOCK)
	JOIN TITMORCAMENTO (NOLOCK) ON TMOVORCAMENTO.CODCOLIGADA = TITMORCAMENTO.CODCOLIGADA AND TMOVORCAMENTO.IDORCAMENTO = TITMORCAMENTO.IDORCAMENTO AND TMOVORCAMENTO.IDITMPERIODO = TITMORCAMENTO.IDITMPERIODO
	JOIN TMOV (NOLOCK) ON TMOV.CODCOLIGADA = TMOVORCAMENTO.CODCOLIGADA AND TMOV.IDMOV = TMOVORCAMENTO.IDMOV
	JOIN TITMMOV (NOLOCK) ON TMOV.CODCOLIGADA = TITMMOV.CODCOLIGADA	AND TMOV.IDMOV = TITMMOV.IDMOV
	LEFT JOIN FCFO (NOLOCK) ON FCFO.CODCFO = TMOV.CODCFO	
WHERE
		1=1
	AND TMOVORCAMENTO.IDPERIODO = 24
	AND TMOVORCAMENTO.IDITMPERIODO = 1
	AND TMOVORCAMENTO.IDMOV IS NOT NULL
	AND TITMMOV.CODTBORCAMENTO = '2.2.01.003' --'2.4.01.003'
	AND TITMMOV.CODCCUSTO = '01.02.01.01.02.001'	--'2.2.01.002'
	AND (TMOVORCAMENTO.VALORREAL > 0)
		
),
COMPROMETIDO AS
(
SELECT DISTINCT
	TMOVORCAMENTO.CODCOLIGADA,
	TMOV.CODFILIAL,
	TMOV.DATAEMISSAO,
	TMOVORCAMENTO.IDITMPERIODO,
	TMOVORCAMENTO.IDPERIODO,
	TMOVORCAMENTO.IDORCAMENTO,
	TMOVORCAMENTO.IDMOV,
	TMOV.CODTMV,
	TMOVORCAMENTO.IDMOVORCAMENTO,
	TMOVORCAMENTO.VALORREAL,
	TITMORCAMENTO.VALOROPCIONAL2,
	CASE WHEN FCFO.CODCFO IS NULL THEN CONCAT('N�O INFORMADO NO MOVIMENTO ',TMOV.CODTMV) ELSE FCFO.CODCFO END	AS CODCFO,
	CASE WHEN FCFO.NOME IS NULL THEN CONCAT('N�O INFORMADO NO MOVIMENTO ',TMOV.CODTMV) ELSE FCFO.NOME END 		AS FORNECEDOR
	
FROM 
	TMOVORCAMENTO (NOLOCK)
	JOIN TITMORCAMENTO (NOLOCK) ON TMOVORCAMENTO.CODCOLIGADA = TITMORCAMENTO.CODCOLIGADA AND TMOVORCAMENTO.IDORCAMENTO = TITMORCAMENTO.IDORCAMENTO AND TMOVORCAMENTO.IDITMPERIODO = TITMORCAMENTO.IDITMPERIODO
	JOIN TMOV (NOLOCK) ON TMOV.CODCOLIGADA = TMOVORCAMENTO.CODCOLIGADA AND TMOV.IDMOV = TMOVORCAMENTO.IDMOV
	JOIN TITMMOV (NOLOCK) ON TMOV.CODCOLIGADA = TITMMOV.CODCOLIGADA	AND TMOV.IDMOV = TITMMOV.IDMOV
	LEFT JOIN FCFO (NOLOCK) ON FCFO.CODCFO = TMOV.CODCFO	
WHERE
		1=1
	AND TMOVORCAMENTO.IDPERIODO = 24
	AND TMOVORCAMENTO.IDITMPERIODO = 5
	AND TMOVORCAMENTO.IDMOV IS NOT NULL
	AND TMOV.CODCCUSTO = '01.01.01.03.01.001'	--'01.02.01.01.02.012'
	AND TITMMOV.CODTBORCAMENTO = '2.4.01.003'	--'2.2.01.002'
	AND (TMOVORCAMENTO.VALORREAL > 0)
		
)
SELECT  DISTINCT 
	REALIZADO.IDMOV,
	REALIZADO.IDORCAMENTO,
	REALIZADO.VALORREAL,
	COMPROMETIDO.VALOROPCIONAL2
FROM
	REALIZADO
	,COMPROMETIDO
	--JOIN COMPROMETIDO ON REALIZADO.CODCOLIGADA = COMPROMETIDO.CODCOLIGADA AND REALIZADO.CODFILIAL = COMPROMETIDO.CODFILIAL
