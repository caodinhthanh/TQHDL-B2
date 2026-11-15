# Bài thực hành 2 — ELT với dbt và Snowflake

Nạp dữ liệu GlobalMart vào RAW.GLOBALMART, tạo 3 bảng raw trong ANALYTICS.GLOBALMART, nối đơn hàng với khách hàng và sản phẩm, rồi tạo 2 view báo cáo lợi nhuận.

## Nội dung

- `data/`: 3 CSV gốc từ Drive được dẫn trong đề.
- `sql/`: tạo warehouse TRANSFORM, database, schema, stage, nạp CSV và kiểm tra báo cáo.
- `models/raw/`: raw_customers, raw_orders, raw_products; lưu thành table.
- `models/staging/stg_orders.sql`: view đơn hàng có ORDERPROFIT.
- `models/reporting/`: customer_profit và product_profit; lưu thành view.
- `tests/`: kiểm tra khóa dòng đơn hàng, quan hệ, tránh nhân bản khi JOIN và đối soát lợi nhuận.
- `docs/`: báo cáo, lineage và kết quả kiểm tra cục bộ.

## Chạy trên Snowflake và dbt Studio

1. Chạy `sql/01_setup_snowflake.sql` bằng role có quyền tạo warehouse/database. Warehouse Small tự dừng sau 60 giây để tiết kiệm chi phí.
2. Trong Snowsight, tải 3 CSV từ `data/` vào stage `RAW.GLOBALMART.UPLOAD`.
3. Chạy `sql/02_load_data.sql`. Dữ liệu là CSV; chỉ dẫn chọn JSON trong đề là lỗi diễn đạt.
4. Kết nối repo này trong dbt Studio. Cấu hình Snowflake: warehouse TRANSFORM, database ANALYTICS, schema GLOBALMART. Role chạy dbt cần SELECT trên nguồn, USAGE trên warehouse/database/schema, CREATE TABLE/VIEW trên schema đích.
5. Chạy `dbt build`, rồi `dbt docs generate` (đây là lệnh tạo tài liệu đúng).
6. Xem Lineage Graph và chạy `sql/03_verify_results.sql`.

## Chạy bằng dbt Core trên Windows

```powershell
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
New-Item -ItemType Directory -Force profiles
Copy-Item profiles.yml.example profiles/profiles.yml
$env:SNOWFLAKE_ACCOUNT = 'your-org-your-account'
$env:SNOWFLAKE_USER = 'your-user'
$env:SNOWFLAKE_ROLE = 'SYSADMIN'
.\.venv\Scripts\dbt.exe debug --profiles-dir profiles
.\.venv\Scripts\dbt.exe build --profiles-dir profiles
.\.venv\Scripts\dbt.exe docs generate --profiles-dir profiles
.\.venv\Scripts\dbt.exe docs serve --profiles-dir profiles
```

Profile mẫu xác thực qua trình duyệt; điều chỉnh theo phương thức tài khoản hỗ trợ. Không commit mật khẩu, private key hoặc profile thật.

## Kiểm tra cục bộ không cần Snowflake

```powershell
py -s scripts/verify_local.py
```

Script chạy trực tiếp SQL model trên SQLite với toàn bộ CSV gốc và xuất top 10 vào `docs/`. Kết quả cục bộ không thay thế việc chạy dbt trên Snowflake. Đã kiểm tra thành công `dbt parse` bằng profile giả, không kết nối cloud. Phiên bản kiểm tra: dbt-core 1.13.0b1, dbt-snowflake 1.12.5.

## Vấn đề dữ liệu gốc

- 793 khách hàng, 9.800 dòng đơn hàng, 1.893 dòng sản phẩm.
- 32 ProductID có hai tên khác nhau. Trước JOIN, chọn tên nhỏ nhất theo thứ tự chữ trong mỗi ProductID để tránh cộng trùng lợi nhuận. Đây là quy tắc kỹ thuật xác định; tên đúng cần được đối chiếu với chủ dữ liệu. Raw giữ nguyên.
- OrderID 1418 có hai ProductID khác nhau; kiểm tra khóa `(orderid, productid)`.
- 5 dòng thiếu CustomerID, 8 dòng thiếu OrderSellingPrice. Giữ NULL và cảnh báo, không điền giá trị giả. LEFT JOIN giữ đơn hàng thiếu khách hàng trong nhóm NULL.
- SUM bỏ qua lợi nhuận NULL. Tổng **670.743,00** chỉ phản ánh các dòng đủ giá bán và giá vốn; chưa phải lợi nhuận đầy đủ của tất cả đơn hàng. Dữ liệu không nêu đơn vị tiền tệ.

## Trạng thái

Đã tạo mã nguồn, SQL, kiểm thử và báo cáo cục bộ. Chưa chạy trên Snowflake/dbt Studio vì chưa có kết nối tài khoản. Các ảnh bằng chứng cần chụp sau khi chạy thật theo `docs/bao_cao.md`.

Tham khảo: [dbt Snowflake setup](https://docs.getdbt.com/docs/local/connect-data-platform/snowflake-setup), [dbt Snowflake quickstart](https://docs.getdbt.com/guides/snowflake).
