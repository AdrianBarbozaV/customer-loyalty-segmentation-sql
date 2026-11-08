/*
 • Calcular la fecha global más reciente de alquiler (MAX(rental_date)) como referencia para medir la recencia de cada 
cliente.
*/
with
 max_global_date as (
    select max(rental_date) as global_date--columna
    from rental
    )
 
       /*
     Crear un resumen por cliente que incluya:
 • ID y nombre del cliente.
 • País.
 • Fecha del último alquiler.• Cantidad total de alquileres. • Monto total pagado.• Fecha global máxima de alquiler (desde el paso 1)
*/
,customer_info AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS full_name, -- alias creado
        co.country AS country,
        m.global_date,
        MAX(r.rental_date) AS last_rental_date,
        COUNT(r.rental_id) AS total_rentals,
        SUM(p.amount) AS total_paid
    FROM payment p
    JOIN customer c ON c.customer_id = p.customer_id
    JOIN address a ON c.address_id = a.address_id
    JOIN city ct ON ct.city_id = a.city_id
    JOIN country co ON co.country_id = ct.country_id
    JOIN rental r ON r.rental_id = p.rental_id
    CROSS JOIN max_global_date m
    GROUP BY 1,2,3,4
)


,calc_1 as(
    select
        *,
julianday(global_date) - julianday(last_rental_date) as days_since_last_rental
from
customer_info

)
    
--Calcular los promedios GLOBALES de
--Monto total pagado, Total de alquileres, Dia desde el último alquuiler
,global_avg as(
    select
    *
    ,round(avg(total_rentals),2) as avg_total_rentals
     ,round(avg(total_paid),2) as avg_total_paid
      ,round(avg(days_since_last_rental),2)as avg_days_since_last_rental
      from calc_1
)

,point_calc AS (
    SELECT
        c.customer_id,
        c.full_name,
        c.country,
        c.global_date,
        c.last_rental_date,
        c.total_rentals,
        c.total_paid,
        c.days_since_last_rental,
        g.avg_total_rentals,
        g.avg_total_paid,
        g.avg_days_since_last_rental,
        CASE WHEN c.total_rentals > g.avg_total_rentals THEN 1 ELSE 0 END AS rentals_over_avg,
        CASE WHEN c.total_paid > g.avg_total_paid THEN 1 ELSE 0 END AS payment_over_avg,
        CASE WHEN c.days_since_last_rental < g.avg_days_since_last_rental THEN 1 ELSE 0 END AS last_rental_over_avg,
        (CASE WHEN c.total_rentals > g.avg_total_rentals THEN 1 ELSE 0 END +
         CASE WHEN c.total_paid > g.avg_total_paid THEN 1 ELSE 0 END +
         CASE WHEN c.days_since_last_rental < g.avg_days_since_last_rental THEN 1 ELSE 0 END) AS total_points
    FROM calc_1 c
    CROSS JOIN global_avg g
)


,loyalty_flag AS (
    SELECT
        *,
        CASE
            WHEN total_points = 3 THEN 'Estrella'
            WHEN total_points = 2 THEN 'Leal'
            WHEN total_points = 1 THEN 'Potencial'
            ELSE 'Inactivo'
        END AS categoria_lealtad,
        CASE
            WHEN total_points = 1 AND payment_over_avg = 1 THEN 'Compra mucho y poco frecuente'
            WHEN total_points = 1 AND rentals_over_avg = 1 THEN 'Alquila mucho, pero en compras pequeñas'
            WHEN total_points = 1 AND last_rental_over_avg = 1 THEN 'Cliente nuevo o compra reciente'
            ELSE NULL
        END AS subsegmento
    FROM point_calc
)



  



   select *
   from
 -- max_global_date
 -- customer_info
   --calc_1
  -- golbal_avg
   --point_calc
  loyalty_flag
    ;
    
    