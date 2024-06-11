DECLARE @IDORCAMENTO AS INT = 315304
DECLARE @IDMOV AS INT = 584435
DECLARE @IDPERIODO AS INT = 24
DECLARE @IDITMPERIODO AS INT = 5


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
	AND TITMORCAMENTO.IDITMPERIODO = @IDITMPERIODO

/*	VERIFICA VALORES NO PRODUTO DO OR�AMENTO	*/
SELECT 
	TMOVORCAMENTO.CODCOLIGADA, TMOVORCAMENTO.IDORCAMENTO, TMOVORCAMENTO.IDMOV, TMOVORCAMENTO.IDMOVORCAMENTO, TMOVORCAMENTO.IDPERIODO, TMOVORCAMENTO.IDITMPERIODO,	
	TMOVORCAMENTO.VALORORCADO, TMOVORCAMENTO.VALORREAL, TMOVORCAMENTO.VALOROPCIONAL2 AS COMPROMETIDO,	
	TMOVORCAMENTO.VALORRECEBIDO, TMOVORCAMENTO.VALORCEDIDO, TMOVORCAMENTO.VALOREXCEDENTE 
FROM 
	TMOVORCAMENTO (NOLOCK)
WHERE 
		1=1 
	AND TMOVORCAMENTO.IDMOV = @IDMOV 
	AND TMOVORCAMENTO.IDORCAMENTO = @IDORCAMENTO 