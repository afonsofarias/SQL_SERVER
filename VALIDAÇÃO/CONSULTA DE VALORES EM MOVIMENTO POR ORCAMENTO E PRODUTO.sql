DECLARE @IDORCAMENTO AS INT = 513273
DECLARE @IDMOV AS INT = 585212
DECLARE @IDPERIODO AS INT = 28
--DECLARE @IDITMPERIODO AS INT = 1


/*	VERIFICA VALORES NO MOVIMENTO	*/
SELECT 
	TITMORCAMENTO.CODCOLIGADA, TITMORCAMENTO.IDORCAMENTO, TITMORCAMENTO.IDPERIODO, TITMORCAMENTO.IDITMPERIODO,	
	TITMORCAMENTO.VALORORCADO, TITMORCAMENTO.VALORREAL, TITMORCAMENTO.VALOROPCIONAL2 AS COMPROMETIDO,	
	TITMORCAMENTO.VALORRECEBIDO, TITMORCAMENTO.VALORCEDIDO, TITMORCAMENTO.VALOREXCEDENTE
FROM 
	TITMORCAMENTO (NOLOCK)
WHERE 
		1=1 
	AND TITMORCAMENTO.IDORCAMENTO = @IDORCAMENTO 
	AND TITMORCAMENTO.IDPERIODO = @IDPERIODO 
	--AND TITMORCAMENTO.IDITMPERIODO = @IDITMPERIODO

/*	VERIFICA VALORES NO PRODUTO DO OR�AMENTO	*/
SELECT 
	TMOVORCAMENTO.CODCOLIGADA, TMOVORCAMENTO.IDORCAMENTO, TMOVORCAMENTO.IDMOVORCAMENTO, TMOVORCAMENTO.IDMOV, TMOVORCAMENTO.IDPERIODO, TMOVORCAMENTO.IDITMPERIODO,	
	TMOVORCAMENTO.VALORORCADO, TITMMOV.RATEIOCCUSTODEPTO, TMOVORCAMENTO.VALORREAL, TMOVORCAMENTO.VALOROPCIONAL2 AS COMPROMETIDO,	
	TMOVORCAMENTO.VALORRECEBIDO, TMOVORCAMENTO.VALORCEDIDO, TMOVORCAMENTO.VALOREXCEDENTE 
FROM 
	TMOVORCAMENTO (NOLOCK)
	LEFT JOIN  TITMMOV (NOLOCK) ON TMOVORCAMENTO.CODCOLIGADA =  TITMMOV.CODCOLIGADA AND TMOVORCAMENTO.IDMOV = TITMMOV.IDMOV
WHERE 
		1=1 
	--AND TMOVORCAMENTO.IDMOV = @IDMOV 
	AND TMOVORCAMENTO.IDORCAMENTO = @IDORCAMENTO 
	AND TMOVORCAMENTO.IDPERIODO = @IDPERIODO
	--AND TMOVORCAMENTO.IDITMPERIODO = @IDITMPERIODO
ORDER BY 
	TMOVORCAMENTO.IDITMPERIODO
--SELECT
--	RATEIOCCUSTODEPTO,
--	DATAORCAMENTO,
--	*
--FROM 
--	TITMMOV 
--WHERE
--		1=1
--	AND YEAR(DATAORCAMENTO) = 2024
--	--AND	MONTH(DATAORCAMENTO) = 1--@IDITMPERIODO
--	AND IDMOV IN (453964,
--453965,
--453966,
--453968,
--453969,
--453970,
--453971,
--453972,
--453973,
--455025,
--455026,
--455027,
--455028,
--455029,
--455030,
--455032,
--455033,
--455034)


--SELECT
--150000.0000
--+150000.0000
--+150000.0000
--+150000.0000
--+150000.0000
--+62500.0000
--+62500.0000
--+62500.0000
--+62500.0000
--+150000.0000
--+150000.0000
--+150000.0000
--+150000.0000
--+150000.0000
--+62500.0000
--+62500.0000
--+62500.0000
--+62500.0000