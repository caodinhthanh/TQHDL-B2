{{ config(severity='warn') }}
select productid, count(distinct productname) as name_count
from {{ ref('raw_products') }}
group by productid
having count(distinct productname) > 1
