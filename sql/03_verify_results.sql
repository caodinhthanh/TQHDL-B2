use warehouse TRANSFORM;
select * from ANALYTICS.GLOBALMART.STG_ORDERS limit 20;
select * from ANALYTICS.GLOBALMART.CUSTOMER_PROFIT order by profit desc limit 10;
select * from ANALYTICS.GLOBALMART.PRODUCT_PROFIT order by profit desc limit 10;
select 'orders' as source, sum(orderprofit) as profit from ANALYTICS.GLOBALMART.STG_ORDERS
union all select 'customers', sum(profit) from ANALYTICS.GLOBALMART.CUSTOMER_PROFIT
union all select 'products', sum(profit) from ANALYTICS.GLOBALMART.PRODUCT_PROFIT;
