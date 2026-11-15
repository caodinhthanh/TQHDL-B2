select orderid, productid, count(*) as row_count
from {{ ref('raw_orders') }}
group by orderid, productid
having count(*) > 1
