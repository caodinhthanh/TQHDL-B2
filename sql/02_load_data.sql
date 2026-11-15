-- Upload data/customers.csv, orders.csv, products.csv into RAW.GLOBALMART.UPLOAD
-- using Snowsight first. COPY uses CSV, not JSON. Do not use FORCE=TRUE on reruns.
use warehouse TRANSFORM;
copy into RAW.GLOBALMART.CUSTOMERS
from @RAW.GLOBALMART.UPLOAD
files = ('customers.csv') file_format = (format_name = RAW.GLOBALMART.CSV_FORMAT)
on_error = 'ABORT_STATEMENT';
copy into RAW.GLOBALMART.PRODUCTS
from @RAW.GLOBALMART.UPLOAD
files = ('products.csv') file_format = (format_name = RAW.GLOBALMART.CSV_FORMAT)
on_error = 'ABORT_STATEMENT';
copy into RAW.GLOBALMART.ORDERS
from @RAW.GLOBALMART.UPLOAD
files = ('orders.csv') file_format = (format_name = RAW.GLOBALMART.CSV_FORMAT)
on_error = 'ABORT_STATEMENT';
select 'CUSTOMERS' as table_name, count(*) as row_count from RAW.GLOBALMART.CUSTOMERS
union all select 'PRODUCTS', count(*) from RAW.GLOBALMART.PRODUCTS
union all select 'ORDERS', count(*) from RAW.GLOBALMART.ORDERS;
