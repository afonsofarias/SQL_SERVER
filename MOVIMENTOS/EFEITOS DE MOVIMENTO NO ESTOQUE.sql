SELECT
	CASE TTMV.CLASSIFICACAO		WHEN '04.04.04' THEN 'Estoque > Requisi��o de Material'		WHEN '04.04.05' THEN 'Estoque > Baixa de Estoque'		WHEN '04.04.06' THEN 'Estoque > Transfer�ncias'		WHEN '04.04.08' THEN 'Estoque > Produ��o > Movimenta��o'		WHEN '04.06.01' THEN 'Compras > Solicita��o de Compra'		WHEN '04.06.02' THEN 'Compras > Cota��o'		WHEN '04.06.04' THEN 'Compras > Ordem de Compras'		WHEN '04.06.05' THEN 'Compras > Recebimento de Materiais'		WHEN '04.06.06' THEN 'Compras > Importa��o'		WHEN '04.06.07' THEN 'Compras > Aquisi��o de Servi�os'		WHEN '04.06.08' THEN 'Compras > Devolu��o de Compras'		WHEN '04.07'    THEN 'Outras Movimenta��es > Controle de Imobilizado'		WHEN '04.08.01' THEN 'Vendas > Pedido de Vendas'		WHEN '04.08.02' THEN 'Vendas > Faturamento > Movimenta��o'		WHEN '04.08.03' THEN 'Vendas > Exporta��es'		WHEN '04.08.04' THEN 'Vendas > Devolu��o de Vendas'		WHEN '04.09'    THEN 'Outras Movimenta��es > Outras Movimenta��es'		ELSE TTMV.CLASSIFICACAO + ' - A localizar'
	END																																							AS 'LOCAL', 
	TITMTMV.CODTMV																																				AS 'CODTMV', 
	TTMV.NOME																																					AS 'NOME',
	CASE TITMTMV.EFEITOSALDOA1 WHEN 'N' THEN 'Nada' WHEN 'A' THEN 'Aumenta' WHEN 'D' THEN 'Diminui' ELSE 'xxx' END												AS 'SALDO_BALANCO',
	CASE TITMTMV.EFEITOSALDOA2 WHEN 'N' THEN 'Nada' WHEN 'A' THEN 'Aumenta' WHEN 'D' THEN 'Diminui' ELSE 'xxx' END												AS 'SALDO_ATUAL',
	CASE TITMTMV.EFEITOSALDOA3 WHEN 'N' THEN 'Nada' WHEN 'A' THEN 'Aumenta' WHEN 'D' THEN 'Diminui' ELSE 'xxx' END												AS 'PEDIDO_FORNECEDOR',
	CASE TITMTMV.EFEITOSALDOA4 WHEN 'N' THEN 'Nada' WHEN 'A' THEN 'Aumenta' WHEN 'D' THEN 'Diminui' ELSE 'xxx' END												AS 'PEDITO_CLIENTE',
	CASE TITMTMV.EFEITOSALDOA5 WHEN 'N' THEN 'Nada' WHEN 'A' THEN 'Aumenta' WHEN 'D' THEN 'Diminui' ELSE 'xxx' END												AS 'SALDO5',
	CASE TITMTMV.EFEITOSALDOA6 WHEN 'N' THEN 'Nada' WHEN 'A' THEN 'Aumenta' WHEN 'D' THEN 'Diminui' ELSE 'xxx' END												AS 'SALDO6',
	CASE TITMTMV.EFEITOSALDOA7 WHEN 'N' THEN 'Nada' WHEN 'A' THEN 'Aumenta' WHEN 'D' THEN 'Diminui' ELSE 'xxx' END												AS 'SALDO7',
	CASE TITMTMV.EFEITOSALDOA8 WHEN 'N' THEN 'Nada' WHEN 'A' THEN 'Aumenta' WHEN 'D' THEN 'Diminui' ELSE 'xxx' END												AS 'SALDO8',
	CASE TITMTMV.EFEITOSALDOA9 WHEN 'N' THEN 'Nada' WHEN 'A' THEN 'Aumenta' WHEN 'D' THEN 'Diminui' ELSE 'xxx' END												AS 'SALDO9',
	CASE TITMTMV.EFEITOSALDOA10 WHEN 'N' THEN 'Nada' WHEN 'A' THEN 'Aumenta' WHEN 'D' THEN 'Diminui' ELSE 'xxx' END												AS 'SALDO10',
	CASE TTMV.FATURA WHEN 1 THEN 'Gera Financeiro' ELSE 'N�o Gera' END																							AS 'GERA_FINANCEIRO',
	CASE TTMV.CONTABILLAN
		WHEN 'N' THEN 'N�o Cont�bil'
		WHEN 'B' THEN 'Baixa Cont�bil'
		WHEN 'C' THEN 'Cont�bil'
		WHEN 'A' THEN 'A Contabilizar'
		ELSE 'Sem parametriza��o'
	END																																							AS 'CONT_FINANCEIRO',
	CASE TITMTMV.GERAESCRITURACAO	WHEN 1								THEN 'Gera Escritura��o'	ELSE 'N�o Gera'			END									AS 'ESCRITURACAO',
	CASE							WHEN TTMV.USAREVC BETWEEN 1 AND 3	THEN 'Contabiliza'			ELSE 'N�o Contabiliza'	END									AS 'CONTABILIZACAO',
	CASE TITMTMV.USATRBIT			WHEN 1								THEN 'Sim'					ELSE 'N�o'				END									AS 'TRIBUTACAO_ITEM',
	CASE TTMV.USATRBMOV				WHEN 1								THEN 'Sim'					ELSE 'N�o'				END									AS 'TRIBUTACAO_MOVIMENTO',
	CASE TTMVEXT.NFEESTADUAL		WHEN 1								THEN 'Gera manual' 
									WHEN 2								THEN 'Gera Autom�tico'		ELSE 'N�o'				END									AS 'NOTA_ESTADUAL',
	CASE TTMVEXT.NFEMUNICIPAL		WHEN 1								THEN 'Gera manual' 
									WHEN 2								THEN 'Gera Autom�tico'		ELSE 'N�o'				END									AS 'NOTA_MUNICIPAL',
	CASE TTMVEXT.NFCE				WHEN 1								THEN 'Gera manual' 
									WHEN 2								THEN 'Gera Autom�tico'		ELSE 'N�o'				END									AS 'NFCe',
	TMOTIVOREFMOV.DESCRICAO																																		AS 'MOTIVO_REFERENCIA',
	CASE TITMTMV.INTEGRARBONUM WHEN 1 THEN 'Integrado Patrim�nio' ELSE 'N�o Integrado' END																		AS 'PATRIMONIO',
	CONVERT(VARCHAR(15), (SELECT MAX(TMOV.DATAEMISSAO) FROM TMOV WITH (NOLOCK) WHERE TMOV.CODCOLIGADA = TTMV.CODCOLIGADA AND TMOV.CODTMV = TTMV.CODTMV), 103)	AS 'ULTIMO_MOVIMENTO'

FROM 
				TITMTMV			WITH (NOLOCK)
	JOIN		TTMV			WITH (NOLOCK) ON TTMV.CODCOLIGADA = TITMTMV.CODCOLIGADA AND TTMV.CODTMV = TITMTMV.CODTMV
	JOIN		TTMVEXT			WITH (NOLOCK) ON TTMVEXT.CODCOLIGADA = TTMV.CODCOLIGADA AND TTMVEXT.CODTMV = TTMV.CODTMV
	LEFT JOIN	TMOTIVOREFMOV	WITH (NOLOCK) ON TMOTIVOREFMOV.CODCOLIGADA = TTMVEXT.CODCOLIGADA AND TMOTIVOREFMOV.IDMOTIVOREF = TTMVEXT.IDMOTIVOREF

WHERE 
	TITMTMV.CODCOLIGADA = 1

ORDER BY 
	TITMTMV.CODTMV