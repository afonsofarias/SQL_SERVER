DECLARE @IDMOV AS INT;
SET @IDMOV = 575059;	--movimento a ser usado

WITH Recursiva AS (
    SELECT 
        IDMOVORIGEM,
        IDMOVDESTINO,
        1 AS Nivel
    FROM 
        TITMMOVRELAC
    WHERE 
        IDMOVORIGEM = @IDMOV OR IDMOVDESTINO = @IDMOV

    UNION ALL

    SELECT 
        m.IDMOVORIGEM,
        m.IDMOVDESTINO,
        r.Nivel + 1 AS Nivel
    FROM 
        TITMMOVRELAC m
    JOIN 
        Recursiva r ON (m.IDMOVORIGEM = r.IDMOVDESTINO AND r.Nivel < 4)
                     OR (m.IDMOVDESTINO = r.IDMOVORIGEM AND r.Nivel < 4)
),
UltimoDestino AS (
    SELECT TOP 1
        IDMOVDESTINO
    FROM 
        Recursiva
    WHERE
        IDMOVDESTINO NOT IN (SELECT IDMOVORIGEM FROM Recursiva)
    ORDER BY 
        Nivel DESC
)
SELECT 
    IDMOVORIGEM,
    IDMOVDESTINO
FROM 
    (
        SELECT 
            IDMOVORIGEM,
            IDMOVDESTINO,
            ROW_NUMBER() OVER (PARTITION BY IDMOVORIGEM, IDMOVDESTINO ORDER BY IDMOVORIGEM) AS RowNum
        FROM 
            Recursiva
        
        UNION ALL
        
        SELECT 
            IDMOVDESTINO,
            CASE 
                WHEN IDMOVDESTINO = (SELECT IDMOVDESTINO FROM UltimoDestino) THEN NULL 
                ELSE IDMOVDESTINO 
            END AS IDMOVDESTINO,
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
        FROM 
            Recursiva
        WHERE 
            IDMOVDESTINO = (SELECT IDMOVDESTINO FROM UltimoDestino)
    ) AS Resultado
WHERE 
    RowNum = 1
ORDER BY 
    CASE WHEN IDMOVDESTINO IS NULL THEN 1 ELSE 0 END, -- Coloca os valores NULL por último
    IDMOVORIGEM, 
    IDMOVDESTINO; -- Ordenando os resultados
