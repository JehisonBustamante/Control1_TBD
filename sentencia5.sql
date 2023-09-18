SELECT t.nombre AS nombre_tienda, COUNT(te.ID_EMPLEADO) AS cantidad_empleados
FROM Tienda AS t
LEFT JOIN Tienda_Empleado AS te ON t.ID_TIENDA = te.ID_TIENDA
GROUP BY t.nombre
HAVING COUNT(te.ID_EMPLEADO) = (
    SELECT MIN(cantidad_empleados)
    FROM (
        SELECT COUNT(te.ID_EMPLEADO) AS cantidad_empleados
        FROM Tienda AS t
        LEFT JOIN Tienda_Empleado AS te ON t.ID_TIENDA = te.ID_TIENDA
        GROUP BY t.nombre
    ) AS subconsulta
);
