SELECT 
	AAVISOCALCULADO.CODCOLIGADA, 
	AAVISOCALCULADO.CHAPA, 
	AAVISOCALCULADO.DATAREFERENCIA, 
	AAVISOCALCULADO.IDJORNADA, 
	AAVISOCALCULADO.CODAVISO, 
	(AAVISO.DESCRICAO) AS DESCRICAO, 
	AAVISOCALCULADO.VALIDADO,
	AAVISOCALCULADO.DATAINICIO, 
	AAVISOCALCULADO.DATAFIM 
FROM 
	AAVISOCALCULADO(NOLOCK), AAVISO(NOLOCK) 
WHERE 
		AAVISOCALCULADO.CODAVISO = AAVISO.CODAVISO 
	AND (	
			AAVISOCALCULADO.CODCOLIGADA = 2 
			AND AAVISOCALCULADO.CHAPA = '000295' 
			AND ( 
					(	
							AAVISOCALCULADO.DATAREFERENCIA >= '2024-03-01' 
						AND AAVISOCALCULADO.DATAREFERENCIA <= '2024-03-30'
					)
				OR
					(
							AAVISOCALCULADO.CODAVISO = 10 
						AND AAVISOCALCULADO.DATAFIM >= '2024-03-30' 
						AND AAVISOCALCULADO.DATAINICIO <= '2024-03-01'
					) 
				)
		) 