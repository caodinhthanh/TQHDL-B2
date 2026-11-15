select o.* from {{ ref('raw_orders') }} o
left join {{ ref('raw_customers') }} c on o.customerid = c.customerid
left join {{ ref('raw_products') }} p on o.productid = p.productid
where (o.customerid is not null and c.customerid is null)
   or p.productid is null
