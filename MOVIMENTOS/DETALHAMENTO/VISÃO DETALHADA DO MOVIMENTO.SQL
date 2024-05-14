SELECT 
    TMOV.CODCOLIGADA                            AS  'CODCOLIGADA',
    TMOV.CODFILIAL                              AS  'CODFILIAL',
    CONVERT(VARCHAR, TMOV.DATAEMISSAO, 103)     AS  'DATAEMISSAO',
    TMOV.IDMOV                                  AS  'IDMOV',
    CASE    WHEN TMOV.[STATUS] = 'A' AND TMOV.IDMOV LIKE '1.1%' THEN CONCAT(TMOV.[STATUS],' - Pendente')
            WHEN TMOV.[STATUS] = 'A' AND TMOV.IDMOV LIKE '2.1%' THEN CONCAT(TMOV.[STATUS],' - A Faturar')
            WHEN TMOV.[STATUS] = 'B'                            THEN CONCAT(TMOV.[STATUS],' - Bloqueado')
            WHEN TMOV.[STATUS] = 'C'                            THEN CONCAT(TMOV.[STATUS],' - Cancelado')
            WHEN TMOV.[STATUS] = 'F' AND TMOV.IDMOV LIKE '1.2%' THEN CONCAT(TMOV.[STATUS],' - Recebido')
            WHEN TMOV.[STATUS] = 'F' AND TMOV.IDMOV LIKE '2.2%' THEN CONCAT(TMOV.[STATUS],' - Faturado')
            WHEN TMOV.[STATUS] = 'F'                            THEN CONCAT(TMOV.[STATUS],' - A Pagar / A Receber')
            WHEN TMOV.[STATUS] = 'G'                            THEN CONCAT(TMOV.[STATUS],' - Parcialmente Recebido / Faturado')
            WHEN TMOV.[STATUS] = 'N'                            THEN CONCAT(TMOV.[STATUS],' - Normal')
            WHEN TMOV.[STATUS] = 'P'                            THEN CONCAT(TMOV.[STATUS],' - Parcialmente Quitado')
            WHEN TMOV.[STATUS] = 'Q'                            THEN CONCAT(TMOV.[STATUS],' - Quitado')
            WHEN TMOV.[STATUS] = 'R'                            THEN CONCAT(TMOV.[STATUS],' - Não Processado')
            WHEN TMOV.[STATUS] = 'U'                            THEN CONCAT(TMOV.[STATUS],' - Em Faturamento')
            WHEN TMOV.[STATUS] = 'O'                            THEN CONCAT(TMOV.[STATUS],' - Aguardando Análise')
            WHEN TMOV.[STATUS] = 'Y'                            THEN CONCAT(TMOV.[STATUS],' - Não Iniciado')
            WHEN TMOV.[STATUS] = 'E'                            THEN CONCAT(TMOV.[STATUS],' - Em Andamento')
            WHEN TMOV.[STATUS] = 'Z'                            THEN CONCAT(TMOV.[STATUS],' - Terminado')
    END                                         AS  'STATUS',
    TMOV.*

FROM TMOV

WHERE 
        1=1
    AND MONTH(TMOV.DATAEMISSAO) = 5
    AND YEAR(TMOV.DATAEMISSAO) = 2024