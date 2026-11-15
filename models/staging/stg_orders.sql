-- The source contains conflicting names for the same ProductID.
-- Choose the alphabetically first name deterministically; retain all raw rows.
with product_dimension as (
    select productid, min(productname) as productname,
           min(category) as category, min(subcategory) as subcategory
    from {{ ref('raw_products') }}
    group by productid
)
select
    o.orderid,
    o.orderdate,
    o.shipdate,
    o.shipmode,
    o.ordersellingprice - o.ordercostprice as orderprofit,
    o.ordercostprice,
    o.ordersellingprice,
    o.customerid,
    c.customername,
    c.segment,
    c.country,
    o.productid,
    p.category,
    p.productname,
    p.subcategory
from {{ ref('raw_orders') }} as o
left join {{ ref('raw_customers') }} as c on o.customerid = c.customerid
left join product_dimension as p on o.productid = p.productid
