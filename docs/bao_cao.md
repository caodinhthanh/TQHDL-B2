# Báo cáo thực hành buổi 2

**Tên bài:** Tối ưu hóa quy trình ELT bằng dbt trên Snowflake.

## 1. Nạp ba tập dữ liệu

CSV gốc được tải từ đường dẫn trong đề, đặt ở `data/`: 793 khách hàng, 9.800 dòng đơn hàng và 1.893 dòng sản phẩm. File product.csv được đổi tên thành products.csv.

Đã chuẩn bị SQL tạo warehouse TRANSFORM, database RAW và ANALYTICS, schema GLOBALMART, stage UPLOAD, định dạng CSV và ba bảng nguồn. Chạy hai script SQL đầu tiên để nạp vào Snowflake.

## 2. Cấu trúc dự án dbt

Ba model raw lưu thành table. stg_orders dùng ref() để nối các model raw, tính orderprofit = ordersellingprice - ordercostprice và lưu thành view. Hai view customer_profit và product_profit cộng lợi nhuận theo khách hàng và sản phẩm.

## 3. Kết quả kiểm tra

`dbt parse` thành công bằng profile giả, không kết nối Snowflake. SQL model chạy trên toàn bộ CSV gốc qua SQLite. Sáu kiểm tra nghiệp vụ đạt: khóa khách hàng, khóa dòng đơn hàng, quan hệ nguồn, giữ số dòng sau JOIN, bảo toàn lợi nhuận nguồn và đối soát lợi nhuận giữa các báo cáo. Hai cảnh báo phát hiện 32 mã sản phẩm có tên xung đột và 13 dòng đơn hàng thiếu dữ liệu.

Staging giữ đủ 9.800 dòng. Báo cáo có 794 nhóm khách hàng (bao gồm nhóm thiếu mã) và 1.861 sản phẩm. Tổng lợi nhuận đã biết ở staging và hai báo cáo cùng bằng **670.743,00**, chưa xác định đơn vị tiền tệ.

32 mã sản phẩm có tên khác nhau được chọn tên đầu tiên theo thứ tự chữ trước JOIN. Đây là giả định kỹ thuật cần xác minh với chủ dữ liệu. 5 dòng thiếu mã khách hàng và 8 dòng thiếu giá bán được giữ nguyên; lợi nhuận NULL không tham gia tổng.

Bằng chứng kiểm tra: local_validation.json. Hai file customer_profit_top10.csv và product_profit_top10.csv chứa top 10 cục bộ. Các kết quả này không phải bằng chứng đã chạy trên Snowflake.

## 4. Lineage

Xem lineage.md. Khi chạy trên Snowflake, dùng dbt docs generate để tạo lineage thực tế có source và model.

## 5. Trạng thái và bằng chứng còn cần

Chưa có kết nối tài khoản Snowflake, nên chưa nạp cloud hoặc chạy dbt build trên Snowflake. Sau khi kết nối, cần chụp:

1. Ba bảng nguồn trong RAW.GLOBALMART.
2. Cấu trúc thư mục trên dbt Studio.
3. Kết quả dbt build và cảnh báo dữ liệu.
4. Lineage Graph trong tài liệu dbt.
5. Preview STG_ORDERS có ORDERPROFIT và hai view báo cáo có PROFIT.
6. Repository: https://github.com/VuHuuThinh05/TQHDL-B2
