with totals as (
    select coalesce(sum(orderprofit), 0) as amount from {{ ref('stg_orders') }}
), customers as (
    select coalesce(sum(profit), 0) as amount from {{ ref('customer_profit') }}
), products as (
    select coalesce(sum(profit), 0) as amount from {{ ref('product_profit') }}
)
select totals.amount, customers.amount, products.amount
from totals cross join customers cross join products
where abs(totals.amount - customers.amount) > 0.01
   or abs(totals.amount - products.amount) > 0.01
