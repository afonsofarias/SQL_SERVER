SELECT
	DBO.FUNC_MINUTOS_HORAMINUTO(TOTVSAUDIT.AABONFUN.HORAINICIO),
	DBO.FUNC_MINUTOS_HORAMINUTO(TOTVSAUDIT.AABONFUN.HORAFIM),
	*
FROM
	TOTVSAUDIT.AABONFUN
--	TOTVSAUDIT.AVISITA
--	TOTVSAUDIT.AEXTRAFUN
--	TOTVSAUDIT.AEAUTFUN
--	TOTVSAUDIT.AAFDT
--	TOTVSAUDIT.AABONO
--	TOTVSAUDIT.AABONOFUTURO
--	TOTVSAUDIT.AABONOFUNAM
--	TOTVSAUDIT.AABONOFUN

WHERE
		1=1
	AND TOTVSAUDIT.AABONFUN.CHAPA = '005171'
--	AND	CONVERT(VARCHAR, AABONFUN.DATA, 103) BETWEEN '01/03/2024' AND '31/03/2024'
