{{ config(severity='warn') }}
select * from {{ ref('raw_orders') }}
where customerid is null or ordersellingprice is null
