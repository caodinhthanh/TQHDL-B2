select
    (select sum(ordersellingprice - ordercostprice) from {{ ref('raw_orders') }}) as source_profit,
    (select sum(orderprofit) from {{ ref('stg_orders') }}) as staging_profit
where abs(source_profit - staging_profit) > 0.01
