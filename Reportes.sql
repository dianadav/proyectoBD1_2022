/*

4. Las consultas o insumos de información que se obtendrán a través de consultas
SQL deben cumplir con los siguientes requisitos:


a. Realizar una consulta que haga uso del operador LIKE
b. Hacer uso de subconsultas para obtener información de dos o más tablas.
c. Una consulta que haga uso del INNER JOIN.
d. Una consulta que haga uso del LEFT JOIN.
e. Una consulta que haga uso del RIGHT JOIN
f. Una consulta que haga uso del GROUP BY y el HAVING
g. Realizar una consulta que haga uso del operador BETWEEN
h. Realizar una consulta que haga uso del operador IN
i. Realizar una consulta que haga uso de la función de agregación SUM junto a
GROUP BY
j. Realizar una consulta que haga uso de la sentencia CASE


*/
/*A.*/
--Cuales son las personas que su nombre empieza con ANDREA
SELECT * FROM PERSONA WHERE nombre LIKE 'ANDREA%';

--Cuales son las personas que viven en una colonia (Col)
SELECT * FROM PERSONA WHERE Ubicacion LIKE 'Col%';

--Cuales son las personas que viven en la ciudad de Tegucigalpa
SELECT * FROM PERSONA WHERE Ciudad = 'Tegucigalpa';


/*B. C. D. I.*/
--Disponibilidad de productos
WITH ventas as
(
SELECT SUM(cantidad) cantidad_Vendidos, iddetallemedicamento
  FROM CorrespondeFactura GROUP BY iddetallemedicamento
)

SELECT med.nombre,tipoMed.nombre as Tipo, inv.cantidad cantidad_Inventario, detm.precio, ven.cantidad_Vendidos, (inv.cantidad - ven.cantidad_Vendidos) cantidad_existencia FROM  DETALLEMEDICAMENTO detm
INNER JOIN MEDICAMENTO med ON med.idmedicamento= detm.idmedicamento
INNER JOIN TIPOMEDICAMENTO tipoMed ON tipoMed.idtipomedicamento = detm.idtipomedicamento
INNER JOIN  INVENTARIO inv ON  inv.iddetallemedicamento= detm.iddetallemedicamento
LEFT JOIN ventas ven ON ven.iddetallemedicamento = detm.iddetallemedicamento;

/*E. */
--Cantidad de empleados que tienen las sucursales 
SELECT suc.nombre, COUNT(emp.dni) cantidad_empleados FROM EMPLEADO emp
 RIGHT JOIN SUCURSAL suc ON emp.idsucursal= suc.idsucursal
 GROUP BY suc.idsucursal, suc.nombre;
 
 /*F. */
 /*Mostrar los dni de los clientes cuya compra más alta en el total ha sido mayor a 8000*/
SELECT MAX (Total), DniCliente 
FROM  Factura 
GROUP BY  DniCliente  
HAVING MAX (Total) > 8000 ;

 /*G. */
/*Cuales son los dni de los empleados que han hecho ventas mayores a 10000 en el mes de abril 2022*/
SELECT MAX (Total), DniEmpleado
FROM  Factura 
WHERE Fecha Between to_date('01/04/2022', 'DD/MM/YYYY') and to_date('30/04/2022', 'DD/MM/YYYY')
GROUP BY  DniEmpleado  
HAVING MAX (Total) > 10000 ;
 /*H. */
/* Cuales son las personas que viven la ciudad de San Pedro Sula y Comayagua*/
SELECT * FROM PERSONA WHERE Ciudad IN ('San Pedro Sula', 'Comayagua');

-- Traer la cantidad de detalles medicamentos del inventario
 /*J. */
WITH ventas as
(
SELECT SUM(cantidad) cantidad_Vendidos, iddetallemedicamento
  FROM CorrespondeFactura GROUP BY iddetallemedicamento
)

SELECT med.nombre,tipoMed.nombre as Tipo, inv.cantidad cantidad_Inventario, ven.cantidad_Vendidos, 
CASE    
     WHEN (inv.cantidad - ven.cantidad_Vendidos)<600 THEN 'NECESITA ABASTECER' 
     ELSE 'AL DIA'  
END AS EstadoInventario

FROM  DETALLEMEDICAMENTO detm
INNER JOIN MEDICAMENTO med ON med.idmedicamento= detm.idmedicamento
INNER JOIN TIPOMEDICAMENTO tipoMed ON tipoMed.idtipomedicamento = detm.idtipomedicamento
INNER JOIN  INVENTARIO inv ON  inv.iddetallemedicamento= detm.iddetallemedicamento
LEFT JOIN ventas ven ON ven.iddetallemedicamento = detm.iddetallemedicamento;


/*Mostrar mensaje 'PROXIMO A VENCER' a registros que esten del año 2024 para atras a vencer*/
SELECT med.nombre,tipoMed.nombre as Tipo, inv.fechacaducidad, to_number(to_char(inv.fechacaducidad, 'YYYY')) anio,
CASE    
     WHEN fechacaducidad<'31/12/2024' THEN 'PROXIMO A VENCER' 
     ELSE 'PUEDE ESPERAR'  
END AS mensajeVencimiento

FROM  INVENTARIO inv
INNER JOIN  DETALLEMEDICAMENTO detm ON  inv.iddetallemedicamento= detm.iddetallemedicamento
INNER JOIN MEDICAMENTO med ON med.idmedicamento= detm.idmedicamento
INNER JOIN TIPOMEDICAMENTO tipoMed ON tipoMed.idtipomedicamento = detm.idtipomedicamento;



--Adicional defensa


    SELECT SUM (fac.Descuento) cantidadDescuentoOtorgados, pers.Nombre,
    fac.DniEmpleado
    FROM  Factura fac
    INNER JOIN Empleado emp ON fac.dniEmpleado= emp.dni
    INNER JOIN Persona pers ON pers.dni= emp.dni
    WHERE Descuento>0 
    GROUP BY  fac.DniEmpleado ,  pers.Nombre 
    order by SUM (fac.Descuento) desc
    