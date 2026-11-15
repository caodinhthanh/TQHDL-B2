select (select count(*) from {{ ref('raw_orders') }}) as raw_count,
       (select count(*) from {{ ref('stg_orders') }}) as staging_count
where raw_count <> staging_count
