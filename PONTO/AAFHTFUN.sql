SELECT 
	AAFHTFUN.CODCOLIGADA, 
	AAFHTFUN.CHAPA, 
	CONVERT(VARCHAR, AAFHTFUN.[DATA], 103), 
	AAFHTFUN.ATRASO, 
	AAFHTFUN.FALTA, 
	AAFHTFUN.HTRAB,
	AAFHTFUN.EXTRAEXECUTADO, 
	AAFHTFUN.ADICIONAL, 
	AAFHTFUN.ABONO, 
	AAFHTFUN.BASE, 
	AAFHTFUN.EXTRAAUTORIZADO,
	AAFHTFUN.TEMPOREF, 
	AAFHTFUN.ATRASONUCL, 
	AAFHTFUN.COMPENSADO, 
	AAFHTFUN.DESCANSO, 
	AAFHTFUN.FERIADO
	,CASE 
		WHEN DATEPART(weekday, AAFHTFUN.[DATA]) = 1 THEN 'Dom'
		WHEN DATEPART(weekday, AAFHTFUN.[DATA]) = 2 THEN 'Seg'
		WHEN DATEPART(weekday, AAFHTFUN.[DATA]) = 3 THEN 'Ter'
		WHEN DATEPART(weekday, AAFHTFUN.[DATA]) = 4 THEN 'Qua'
		WHEN DATEPART(weekday, AAFHTFUN.[DATA]) = 5 THEN 'Qui'
		WHEN DATEPART(weekday, AAFHTFUN.[DATA]) = 6 THEN 'Sex'
		WHEN DATEPART(weekday, AAFHTFUN.[DATA]) = 7 THEN 'Sab'
	 END AS SEMANA
FROM 
	AAFHTFUN (NOLOCK)
WHERE 
		((AAFHTFUN.CODCOLIGADA = 1)
	AND (AAFHTFUN.CHAPA = '005755')
	AND (AAFHTFUN.DATA BETWEEN '2024-03-01' AND '2024-03-30')) /*AND*/ 
GROUP BY
	AAFHTFUN.CODCOLIGADA, 
	AAFHTFUN.CHAPA, 
	AAFHTFUN.DATA, 
	AAFHTFUN.ATRASO, 
	AAFHTFUN.FALTA, 
	AAFHTFUN.HTRAB,
	AAFHTFUN.EXTRAEXECUTADO, 
	AAFHTFUN.ADICIONAL, 
	AAFHTFUN.ABONO, 
	AAFHTFUN.BASE, 
	AAFHTFUN.EXTRAAUTORIZADO,
	AAFHTFUN.TEMPOREF, 
	AAFHTFUN.ATRASONUCL, 
	AAFHTFUN.COMPENSADO, 
	AAFHTFUN.DESCANSO, 
	AAFHTFUN.FERIADO
ORDER BY 
	AAFHTFUN.DATA