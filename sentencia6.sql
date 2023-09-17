WITH Meses AS (
    SELECT generate_series(
        date_trunc('month', '2023-01-01'::date), 
        date_trunc('month', CURRENT_DATE), 
        interval '1 month'
    ) AS Mes
)
SELECT
    EXTRACT(MONTH FROM Mes.Mes) AS Mes,
    VD.ID_VENDEDOR,
    E.nombre AS NombreVendedor,
    COUNT(*) AS VentasDelMes
FROM Meses Mes
LEFT JOIN Venta V ON EXTRACT(YEAR FROM Mes.Mes) = EXTRACT(YEAR FROM V.fecha) 
                  AND EXTRACT(MONTH FROM Mes.Mes) = EXTRACT(MONTH FROM V.fecha)
LEFT JOIN Prod_Venta PV ON V.ID_VENTA = PV.ID_VENTA
LEFT JOIN Vendedor VD ON PV.ID_VENDEDOR = VD.ID_VENDEDOR
LEFT JOIN Empleado E ON VD.ID_EMPLEADO = E.ID_EMPLEADO
GROUP BY EXTRACT(MONTH FROM Mes.Mes), VD.ID_VENDEDOR, E.nombre
ORDER BY EXTRACT(MONTH FROM Mes.Mes), VentasDelMes DESC;