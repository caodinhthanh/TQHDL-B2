select customerid from {{ ref('raw_customers') }} group by customerid having count(*) > 1
