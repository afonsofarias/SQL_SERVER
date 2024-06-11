SELECT GUSUARIO.CODUSUARIO, GSISTEMA.DESCRICAO, GUSRPERFIL.CODPERFIL, GPERFIL.NOME, GPERFIL.IDPERFIL, GUSRPERFIL.CODSISTEMA, GSISTEMA.NOMESISTEMA
FROM GUSRPERFIL INNER JOIN GUSUARIO ON GUSRPERFIL.CODUSUARIO = GUSUARIO.CODUSUARIO INNER JOIN GSISTEMA ON GUSRPERFIL.CODSISTEMA = GSISTEMA.CODSISTEMA INNER JOIN GPERFIL ON GUSRPERFIL.CODSISTEMA = GPERFIL.CODSISTEMA AND GUSRPERFIL.CODPERFIL = GPERFIL.CODPERFIL
WHERE 
		GUSUARIO.STATUS = 1	-- USUARIO ATIVO = 1
	AND (GUSUARIO.DATAEXPIRACAO IS NULL OR GUSUARIO.DATAEXPIRACAO > GETDATE())-- GARANTE QUE N�O ESTA COM VALIDADE EXPIRADA NO USUARIO
	--AND GUSUARIO.NOME LIKE '%AFONSO%%JANSEN%'		-- BUSCA POR NOME DE USUARIO
	AND GUSRPERFIL.CODPERFIL NOT LIKE '%ALUNO%'		-- GARANTE QUE O USUARIO N�O � UM ALUNO
	AND GUSUARIO.CODUSUARIO = '2-060169'																																																																																																																																											-- BUSCA POR CHAPA

ORDER BY GUSUARIO.NOME
