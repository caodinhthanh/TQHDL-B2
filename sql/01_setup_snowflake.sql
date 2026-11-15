-- Run as a role with CREATE WAREHOUSE and CREATE DATABASE privileges.
create warehouse if not exists TRANSFORM
    warehouse_size = 'SMALL'
    auto_suspend = 60
    auto_resume = true
    initially_suspended = true;
create database if not exists RAW;
create database if not exists ANALYTICS;
create schema if not exists RAW.GLOBALMART;
create schema if not exists ANALYTICS.GLOBALMART;
create file format if not exists RAW.GLOBALMART.CSV_FORMAT
    type = CSV
    skip_header = 1
    field_optionally_enclosed_by = '"'
    date_format = 'YYYY/MM/DD'
    empty_field_as_null = true
    encoding = 'UTF8';
create stage if not exists RAW.GLOBALMART.UPLOAD
    file_format = RAW.GLOBALMART.CSV_FORMAT;
create table if not exists RAW.GLOBALMART.CUSTOMERS (
    customerid varchar, customername varchar, segment varchar,
    country varchar, state varchar
);
create table if not exists RAW.GLOBALMART.PRODUCTS (
    category varchar, productid varchar, productname varchar, subcategory varchar
);
create table if not exists RAW.GLOBALMART.ORDERS (
    orderid integer, orderdate date, shipdate date, shipmode varchar,
    customerid varchar, productid varchar,
    ordercostprice number(18,2), ordersellingprice number(18,2)
);
