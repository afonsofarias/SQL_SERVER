/* ELEI��O CIPA - (APURA��O DE VOTOS) */

/* TRAS O TOTAL DE FUNCIONARIOS*/
SELECT VVOTACAOCIPA.CODCOLIGADA,
       VVOTACAOCIPA.CODCOMISSAO,
       VCOMISSAO.NOME                                     AS COMISSAO,
       PFUNC.CHAPA,
       PFUNC.NOME,
       PSECAO.DESCRICAO                                   AS SETOR,
       PFUNCAO.NOME                                       AS FUNCAO,
       CONVERT (CHAR(10), VVOTACAOCIPA.RECCREATEDON, 103) AS DATA_VOTO,
       CAST(VVOTACAOCIPA.RECCREATEDON AS TIME(0))         AS HORA_VOTO,
       'SIM'                                              AS VOTOU
FROM   PFUNC,
       PSECAO,
       PFUNCAO,
       VCOMISSAO,
       VELEICAO,
       VVOTACAOCIPA
WHERE  PFUNC.CODCOLIGADA = PSECAO.CODCOLIGADA
       AND PFUNC.CODSECAO = PSECAO.CODIGO
       AND PFUNC.CODCOLIGADA = PFUNCAO.CODCOLIGADA
       AND PFUNC.CODFUNCAO = PFUNCAO.CODIGO
       AND VVOTACAOCIPA.CODCOLIGADA = VCOMISSAO.CODCOLIGADA
       AND VVOTACAOCIPA.CODCOMISSAO = VCOMISSAO.CODCOMISSAO
       AND VVOTACAOCIPA.CODCOMISSAO = '002/2024' 
       AND VELEICAO.CODELEICAO = 2024
       AND VVOTACAOCIPA.CODCOLIGADA = VELEICAO.CODCOLIGADA
       AND VVOTACAOCIPA.CODELEICAO = VELEICAO.CODELEICAO
       AND VVOTACAOCIPA.CODCOMISSAO = VELEICAO.CODCOMISSAO
       AND PFUNC.CODCOLIGADA = VVOTACAOCIPA.CODCOLIGADA
       AND PFUNC.CODPESSOA = VVOTACAOCIPA.CODPESSOA
       AND PFUNC.CODSITUACAO NOT IN ( 'D', 'P' )
       AND PFUNC.CODTIPO IN ('N','Z','T') /*INCLUIDO NO DIA 02/08*/
       AND PFUNC.CODCOLIGADA = 2
       AND PFUNC.CODFILIAL = 2

UNION
/*TRAS AS PESSOAS QUE VOTARAM*/
SELECT PFUNC.CODCOLIGADA,
       '002/2024'                       AS CODCOMISSAO,
       'GEST�O CIPA'               AS COMISSAO,
       PFUNC.CHAPA,
       PFUNC.NOME,
       PSECAO.DESCRICAO            AS SETOR,
       PFUNCAO.NOME                AS FUNCAO,
       CONVERT (CHAR(10), '', 103) AS DATA_VOTO,
       CAST('' AS TIME(0))         AS HORA_VOTO,
       'NAO'                       AS VOTOU
FROM   PFUNC,
       PSECAO,
       PFUNCAO
WHERE  PFUNC.CODCOLIGADA = PSECAO.CODCOLIGADA
       AND PFUNC.CODSECAO = PSECAO.CODIGO
       AND PFUNC.CODCOLIGADA = PFUNCAO.CODCOLIGADA
       AND PFUNC.CODFUNCAO = PFUNCAO.CODIGO
       AND PFUNC.CODSITUACAO NOT IN ( 'D', 'P' )
       AND PFUNC.CODTIPO IN ('N','Z','T') /*INCLUIDO NO DIA 02/08*/
       AND PFUNC.CODCOLIGADA = 2
       AND PFUNC.CODFILIAL = 2
       AND PFUNC.CHAPA NOT IN (SELECT PFUNC.CHAPA
                               FROM   PFUNC,
                                      PSECAO,
                                      PFUNCAO,
                                      VCOMISSAO,
                                      VELEICAO,
                                      VVOTACAOCIPA
                               WHERE  PFUNC.CODCOLIGADA = PSECAO.CODCOLIGADA
                                      AND PFUNC.CODSECAO = PSECAO.CODIGO
                                      AND PFUNC.CODCOLIGADA = PFUNCAO.CODCOLIGADA
                                      AND PFUNC.CODFUNCAO = PFUNCAO.CODIGO
                                      AND VVOTACAOCIPA.CODCOLIGADA = VCOMISSAO.CODCOLIGADA
                                      AND VVOTACAOCIPA.CODCOMISSAO = VCOMISSAO.CODCOMISSAO
                                      AND VVOTACAOCIPA.CODCOMISSAO =  '002/2024'
                                      AND VELEICAO.CODELEICAO = 2024
                                      AND VVOTACAOCIPA.CODCOLIGADA = VELEICAO.CODCOLIGADA
                                      AND VVOTACAOCIPA.CODELEICAO = VELEICAO.CODELEICAO
                                      AND VVOTACAOCIPA.CODCOMISSAO = VELEICAO.CODCOMISSAO
                                      AND PFUNC.CODCOLIGADA = VVOTACAOCIPA.CODCOLIGADA
                                      AND PFUNC.CODPESSOA = VVOTACAOCIPA.CODPESSOA
                                      AND PFUNC.CODSITUACAO NOT IN ( 'D', 'P' )
                                       AND PFUNC.CODTIPO IN ('N','Z','T')
                                      AND PFUNC.CODCOLIGADA = 2
                                      AND PFUNC.CODFILIAL = 2)
ORDER  BY VOTOU 
