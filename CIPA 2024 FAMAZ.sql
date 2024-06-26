/* Elei��o CIPA - (Apura��o de Votos) */
SELECT VCOMISSAO.NOME + ' 2024 - SIM'		AS COMISSAO,
       Count(PFUNC.CHAPA)					AS QUANT,
       'SIM'								AS VOTOU
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
       AND VELEICAO.CODELEICAO = '002/2024'
       AND VVOTACAOCIPA.CODCOLIGADA = VELEICAO.CODCOLIGADA
       AND VVOTACAOCIPA.CODELEICAO = VELEICAO.CODELEICAO
       AND VVOTACAOCIPA.CODCOMISSAO = VELEICAO.CODCOMISSAO
       AND PFUNC.CODCOLIGADA = VVOTACAOCIPA.CODCOLIGADA
       AND PFUNC.CODPESSOA = VVOTACAOCIPA.CODPESSOA
       AND PFUNC.CODSITUACAO NOT IN ( 'D', 'P' )
       AND PFUNC.CODCOLIGADA = '2'
       AND PFUNC.CODFILIAL = '2'
GROUP  BY VCOMISSAO.NOME
UNION
SELECT 'EUROAM - UNIFAMAZ 2024 - N�O' AS COMISSAO,
       Count(PFUNC.CHAPA)					AS QUANT,
       'NAO'								AS VOTOU
FROM   PFUNC,
       PSECAO,
       PFUNCAO
WHERE  PFUNC.CODCOLIGADA = PSECAO.CODCOLIGADA
       AND PFUNC.CODSECAO = PSECAO.CODIGO
       AND PFUNC.CODCOLIGADA = PFUNCAO.CODCOLIGADA
       AND PFUNC.CODFUNCAO = PFUNCAO.CODIGO
       AND PFUNC.CODSITUACAO NOT IN ( 'D', 'P' )
       AND PFUNC.CODCOLIGADA = '2'
       AND PFUNC.CODFILIAL = '2'
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
                                      AND VVOTACAOCIPA.CODCOMISSAO = '002/2024'
                                      AND VELEICAO.CODELEICAO = '002/2024'
                                      AND VVOTACAOCIPA.CODCOLIGADA = VELEICAO.CODCOLIGADA
                                      AND VVOTACAOCIPA.CODELEICAO = VELEICAO.CODELEICAO
                                      AND VVOTACAOCIPA.CODCOMISSAO = VELEICAO.CODCOMISSAO
                                      AND PFUNC.CODCOLIGADA = VVOTACAOCIPA.CODCOLIGADA
                                      AND PFUNC.CODPESSOA = VVOTACAOCIPA.CODPESSOA
                                      AND PFUNC.CODSITUACAO NOT IN ( 'D', 'P' )
                                      AND PFUNC.CODCOLIGADA = '2'
                                      AND PFUNC.CODFILIAL = '2')
GROUP  BY PFUNC.CODCOLIGADA 