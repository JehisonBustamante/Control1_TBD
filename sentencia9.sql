-- EMPLEADOS CON MAYOR SUELDO POR MES
WITH sueldos_mensuales AS (SELECT DISTINCT ON (date_trunc('year', S.fecha_pago), date_trunc('month', S.fecha_pago), S.cantidad)
       date_trunc('year', S.fecha_pago) AS Anio,
       date_trunc('month', S.fecha_pago) AS Mes,
       Emp.Nombre AS Empleado_Con_Mayor_Sueldo,
       S.cantidad AS Sueldo_Mensual
FROM Sueldo as S
INNER JOIN Empleado as Emp ON S.id_empleado = Emp.id_empleado
ORDER BY date_trunc('year', S.fecha_pago), date_trunc('month', S.fecha_pago), S.cantidad DESC),

RankSueldosMes AS (
    SELECT Anio, Mes, Empleado_Con_Mayor_Sueldo, Sueldo_Mensual,
    RANK() OVER (PARTITION BY Mes ORDER BY Sueldo_Mensual DESC) AS ranking
    FROM sueldos_mensuales
)

SELECT Anio, Mes, Empleado_Con_Mayor_Sueldo, Sueldo_Mensual
FROM RankSueldosMes
WHERE ranking = 1;