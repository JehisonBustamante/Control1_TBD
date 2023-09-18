WITH VentasPorVendedor AS (
    SELECT
        EXTRACT(YEAR FROM V.fecha) AS Anio,
        T.ID_TIENDA AS ID_Tienda,
        PV.ID_VENDEDOR AS ID_Vendedor,
        SUM(P.valor) AS Total_Recaudado
    FROM Venta V
	
    INNER JOIN Prod_Venta PV ON V.ID_VENTA = PV.ID_VENTA
    INNER JOIN Producto P ON PV.ID_PROD = P.ID_PROD
    INNER JOIN Tienda T ON V.ID_TIENDA = T.ID_TIENDA
    
	GROUP BY
        EXTRACT(YEAR FROM V.fecha),
        T.ID_TIENDA,
        PV.ID_VENDEDOR
)

SELECT
    Anio,
    T.nombre AS Nombre_Tienda,
    E.nombre AS Nombre_Vendedor,
    Total_Recaudado
FROM (
    SELECT 
		Anio,
		ID_Tienda,
	    ID_Vendedor,
        RANK() OVER (PARTITION BY Anio, ID_Tienda ORDER BY Total_Recaudado DESC) AS Ranking,
        Total_Recaudado
    FROM VentasPorVendedor VPV
) AS RankedSales

INNER JOIN Tienda T ON RankedSales.ID_Tienda = T.ID_TIENDA
INNER JOIN Vendedor VPV ON RankedSales.ID_Vendedor = VPV.ID_VENDEDOR
INNER JOIN Empleado E ON VPV.ID_EMPLEADO = E.ID_EMPLEADO
WHERE Ranking = 1;
