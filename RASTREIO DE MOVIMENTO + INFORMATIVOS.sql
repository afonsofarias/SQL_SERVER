DECLARE @IDMOV AS INT;
SET @IDMOV = 575059;	-- MOVIMENTO A SER USADO

WITH RECURSIVA AS (
    SELECT 
        IDMOVORIGEM,
        IDMOVDESTINO,
        1 AS NIVEL
    FROM 
        TITMMOVRELAC
    WHERE 
        IDMOVORIGEM = @IDMOV OR IDMOVDESTINO = @IDMOV

    UNION ALL

    SELECT 
        M.IDMOVORIGEM,
        M.IDMOVDESTINO,
        R.NIVEL + 1 AS NIVEL
    FROM 
        TITMMOVRELAC M
    JOIN 
        RECURSIVA R ON (M.IDMOVORIGEM = R.IDMOVDESTINO AND R.NIVEL < 4)
                     OR (M.IDMOVDESTINO = R.IDMOVORIGEM AND R.NIVEL < 4)
),
ULTIMODESTINO AS (
    SELECT TOP 1
        IDMOVDESTINO
    FROM 
        RECURSIVA
    ORDER BY 
        NIVEL DESC
)
SELECT 
	TTMVEXT.CODCOLIGADA,
	TMOV.IDMOV,
	TTMVEXT.CODTMV,
	TTMV.NOME,
	TTMVEXT.CODFRMVALORUNTORCAMENTO,
	CASE WHEN TITMTMV.HABILITAORCAMENTO = 1 THEN 'ATIVO' ELSE 'INATIVO' END AS 'HABILITA OR�AMENTO',
	CASE 
		WHEN TTMV.DATAORCAMENTO = 0 THEN 'DATA EMISS�O' 
		WHEN TTMV.DATAORCAMENTO = 1 THEN 'DATA ENTRADA/SAIDA' 
	END 'DATA DEFAULT DO OR�AMENTO',
	CASE WHEN TTMVEXT.EDICAOTBORCAMENTOIT = 'M' THEN 'MOSTRA'
		 WHEN TTMVEXT.EDICAOTBORCAMENTOIT = 'O' THEN 'EDITA'
		 END AS 'EDITAR NATUREZA OR�AMENT�RIA/FINANCEIRA NO ITEM',
	CASE WHEN TTMVEXT.BUSCARNATORCDEFAULTPRD = 'D' THEN 'DESPESA' ELSE 'RECEITA' END AS 'BUSCAR DEFAULT DO PRODUTO',
	CASE 
		WHEN TITMTMV.LIMESTOUROORCAMENTO = 'A' THEN 'AVISA' 
		WHEN TITMTMV.LIMESTOUROORCAMENTO = 'L' THEN 'BLOQUEIA' 
		END AS 'LIMITE DE ESTOURO DO OR�AMENTO',
	CASE 
		WHEN TITMTMV.EFEITOSALDOORCA = 'T' THEN 'AUMENTA O COMPROMETIDO' 
		WHEN TITMTMV.EFEITOSALDOORCA = 'N' THEN 'NENHUM EFEITO NO OR�AMENTO' 
		WHEN TITMTMV.EFEITOSALDOORCA = 'M' THEN 'AUMENTA O EMPENHADO' 
		WHEN TITMTMV.EFEITOSALDOORCA = 'D' THEN 'DIMINUI O REALIZADO' 
		WHEN TITMTMV.EFEITOSALDOORCA = 'A' THEN 'AUMENTA O REALIZADO' 
		END AS 'EFEITO NO SALDO DO OR�AMENTO',
	TITMTMV.TIPOCONTROLEORCAMENTO AS 'TIPO DO CONTROLE DO OR�AMENTO'
FROM 
	TTMVEXT (NOLOCK)
	JOIN TTMV (NOLOCK) ON TTMV.CODCOLIGADA = TTMVEXT.CODCOLIGADA AND TTMV.CODTMV = TTMVEXT.CODTMV
	JOIN TITMTMV (NOLOCK) ON TITMTMV.CODCOLIGADA = TTMVEXT.CODCOLIGADA AND TITMTMV.CODTMV = TTMVEXT.CODTMV
	JOIN TMOV (NOLOCK) ON TTMV.CODCOLIGADA = TMOV.CODCOLIGADA AND TTMV.CODTMV = TMOV.CODTMV
WHERE 
	TTMVEXT.CODCOLIGADA = 1
	AND TITMTMV.HABILITAORCAMENTO = 1
	AND TMOV.IDMOV IN (
		SELECT IDMOVORIGEM
		FROM RECURSIVA
	)
ORDER BY 
	TTMVEXT.CODTMV ASC;
