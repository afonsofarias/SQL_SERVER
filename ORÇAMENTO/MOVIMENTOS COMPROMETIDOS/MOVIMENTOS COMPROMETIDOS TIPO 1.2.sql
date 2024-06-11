 SELECT DISTINCT
	TITMTMV.CODCOLIGADA																																			AS 'CODCOLIGADA',
	TMOV.CODCCUSTO																																				AS 'CC',
	TITMMOV.CODTBORCAMENTO																																		AS 'COD_NATUREZA',
	MONTH(TITMMOV.DATAORCAMENTO)																																AS 'MES', 
	TMOVORCAMENTO.IDITMPERIODO																																	AS 'IDITMPERIODO',
	YEAR(TITMMOV.DATAORCAMENTO)																																	AS 'ANO', 
	TMOVORCAMENTO.IDPERIODO																																		AS 'IDPERIODO',
	TITMTMV.CODTMV																																				AS 'CODTMV', 
	TMOVORCAMENTO.IDORCAMENTO																																	AS 'IDORCAMENTO',
	TMOV.IDMOV																																					AS 'IDMOV',
	--TITMORCAMENTO.VALOROPCIONAL2																																AS 'COMP_TITMORCAMENTO',
	TMOVORCAMENTO.VALOROPCIONAL2																																AS 'COMP_TMOVORCAMENTO',
	(TITMMOV.VALORBRUTOITEM)																																	AS 'REALIZADO',
	CASE 
        WHEN TITMTMV.EFEITOSALDOORCA = 'T' THEN 'AUMENTA O COMPROMETIDO' 
        WHEN TITMTMV.EFEITOSALDOORCA = 'N' THEN 'NENHUM EFEITO NO OR�AMENTO' 
        WHEN TITMTMV.EFEITOSALDOORCA = 'M' THEN 'AUMENTA O EMPENHADO' 
        WHEN TITMTMV.EFEITOSALDOORCA = 'D' THEN 'DIMINUI O REALIZADO' 
        WHEN TITMTMV.EFEITOSALDOORCA = 'A' THEN 'AUMENTA O REALIZADO' 
    END																																							AS 'EFEITO',
    CASE WHEN TTMVEXT.BUSCARNATORCDEFAULTPRD = 'D' THEN 'DESPESA' 
		 WHEN TTMVEXT.BUSCARNATORCDEFAULTPRD = 'R' THEN 'RECEITA' 
		 ELSE TTMVEXT.BUSCARNATORCDEFAULTPRD							
	END																																							AS 'BUSCAR DEFAULT DO PRODUTO',
	 CASE 
        WHEN TITMTMV.LIMESTOUROORCAMENTO = 'A' THEN 'AVISA' 
        WHEN TITMTMV.LIMESTOUROORCAMENTO = 'L' THEN 'BLOQUEIA' 
    END																																							AS 'LIMITE DE ESTOURO DO OR�AMENTO',
	CASE TTMV.CONTABILLAN
		WHEN 'N' THEN 'N�o Cont�bil'
		WHEN 'B' THEN 'Baixa Cont�bil'
		WHEN 'C' THEN 'Cont�bil'
		WHEN 'A' THEN 'A Contabilizar'
		ELSE 'Sem parametriza��o'
	END																																							AS 'CONT_FINANCEIRO'

FROM 
					TMOV			(NOLOCK)
	LEFT JOIN		TTMV			(NOLOCK) ON TTMV.CODCOLIGADA = TMOV.CODCOLIGADA AND TTMV.CODTMV = TMOV.CODTMV
	LEFT JOIN		TITMTMV			(NOLOCK) ON TTMV.CODCOLIGADA = TITMTMV.CODCOLIGADA AND TTMV.CODTMV = TITMTMV.CODTMV
	LEFT JOIN		TMOVORCAMENTO	(NOLOCK) ON TMOV.CODCOLIGADA = TMOVORCAMENTO.CODCOLIGADA AND TMOV.IDMOV = TMOVORCAMENTO.IDMOV
	LEFT JOIN		TITMORCAMENTO	(NOLOCK) ON TMOVORCAMENTO.CODCOLIGADA = TITMORCAMENTO.CODCOLIGADA AND TMOVORCAMENTO.IDORCAMENTO = TITMORCAMENTO.IDORCAMENTO
	LEFT JOIN		TITMMOV			(NOLOCK) ON TITMMOV.CODCOLIGADA = TMOV.CODCOLIGADA AND TITMMOV.IDMOV = TMOV.IDMOV
	LEFT JOIN		TTMVEXT			(NOLOCK) ON TTMVEXT.CODCOLIGADA = TTMV.CODCOLIGADA AND TTMVEXT.CODTMV = TTMV.CODTMV
	LEFT JOIN		TMOTIVOREFMOV	(NOLOCK) ON TMOTIVOREFMOV.CODCOLIGADA = TTMVEXT.CODCOLIGADA AND TMOTIVOREFMOV.IDMOTIVOREF = TTMVEXT.IDMOTIVOREF

WHERE 
		1=1
	--AND TITMTMV.CODCOLIGADA IN (1, 2)
	AND TITMTMV.CODTMV LIKE '1.2.%'
	AND TITMTMV.EFEITOSALDOORCA <> 'A'
	--AND TMOVORCAMENTO.IDORCAMENTO = 514546
	AND TMOVORCAMENTO.VALOROPCIONAL2 > 0
ORDER BY 
	TITMTMV.CODCOLIGADA,
	TITMTMV.CODTMV




	/*
	
	SELECT * FROM GCAMPOS WHERE COLUNA = 'CODTBORCAMENTO'
	
	*/