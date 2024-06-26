SELECT 
	TITMORCAMENTO.CODCOLIGADA,
	TMOV.CODCCUSTO,
	TITMMOV.CODTBORCAMENTO,
	TMOV.CODTMV,
	TITMORCAMENTO.IDORCAMENTO,
	TMOVORCAMENTO.IDMOVORCAMENTO,
	TMOVORCAMENTO.IDMOV,
	TITMORCAMENTO.IDPERIODO,
	TITMORCAMENTO.IDITMPERIODO,
	TMOVORCAMENTO.VALOROPCIONAL1 AS 'EMPENHADO TMOVORCAMENTO',
	TITMORCAMENTO.VALOROPCIONAL1 AS 'EMPENHADO TITMORCAMENTO'

FROM 
			TMOVORCAMENTO	(NOLOCK)
	JOIN	TMOV			(NOLOCK) ON TMOVORCAMENTO.CODCOLIGADA = TMOV.CODCOLIGADA AND TMOVORCAMENTO.IDMOV = TMOV.IDMOV
	JOIN	TITMMOV			(NOLOCK) ON TITMMOV.CODCOLIGADA = TMOV.CODCOLIGADA AND TITMMOV.IDMOV = TMOV.IDMOV
	JOIN	TITMORCAMENTO	(NOLOCK) ON TMOVORCAMENTO.CODCOLIGADA = TITMORCAMENTO.CODCOLIGADA AND TMOVORCAMENTO.IDORCAMENTO = TITMORCAMENTO.IDORCAMENTO AND TMOVORCAMENTO.IDITMPERIODO = TITMORCAMENTO.IDITMPERIODO

WHERE
		1=1
	AND TITMORCAMENTO.IDPERIODO IN (24, 28)
	AND (TMOVORCAMENTO.VALOROPCIONAL1 < 0 OR TITMORCAMENTO.VALOROPCIONAL1 < 0)

ORDER BY
	TITMORCAMENTO.CODCOLIGADA,
	TITMORCAMENTO.IDORCAMENTO,
	TMOVORCAMENTO.IDMOVORCAMENTO
;

SELECT CODCOLIGADA, IDORCAMENTO, IDPERIODO, IDITMPERIODO, VALOROPCIONAL1 FROM TITMORCAMENTO WHERE IDORCAMENTO = 314808 AND IDPERIODO = 24 AND IDITMPERIODO = 3;

/*
BEGIN TRANSACTION
	UPDATE TITMORCAMENTO SET VALOROPCIONAL1 = 0 WHERE IDORCAMENTO = 314808 AND IDPERIODO = 24 AND IDITMPERIODO = 3 AND VALOROPCIONAL1 = -1795.1400
ROLLBACK
*/