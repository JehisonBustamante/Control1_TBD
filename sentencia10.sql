WITH Meses AS (
    SELECT generate_series(
        date_trunc('month', '2023-01-01'::date), 
        date_trunc('month', CURRENT_DATE), 
        interval '1 month'
    ) AS Mes
)
SELECT
    EXTRACT(MONTH FROM Mes.Mes) AS Mes,
    T.ID_TIENDA,
    T.nombre AS NombreTienda,
    SUM(TD.precio_total) AS RecaudacionDelMes
FROM Meses Mes
LEFT JOIN Venta V ON EXTRACT(YEAR FROM Mes.Mes) = EXTRACT(YEAR FROM V.fecha) 
                  AND EXTRACT(MONTH FROM Mes.Mes) = EXTRACT(MONTH FROM V.fecha)
LEFT JOIN Tienda T ON V.ID_TIENDA = T.ID_TIENDA
LEFT JOIN Tipo_Doc TD ON V.ID_DOC = TD.ID_DOC
GROUP BY EXTRACT(MONTH FROM Mes.Mes), T.ID_TIENDA, T.nombre
ORDER BY EXTRACT(MONTH FROM Mes.Mes), RecaudacionDelMes ASC;