with source as (

    select *
    from {{ ref('dim_holidays') }}

),

cleaned as (

    select
        cast(date as date) as holiday_date,
        trim(holiday_name) as holiday_name,
        trim(holiday_type) as holiday_type
    from source

)

select *
from cleaned