with traffic as (
    select *
    from {{ ref('stg_traffic') }}

),

holidays as (
    select *
    from {{ ref('stg_riigipuha') }}

)

select
    t.event_ts,
    cast(t.event_ts as date) as event_date,
    date_trunc('week', t.event_ts)::date as week_start,
    extract(isodow from t.event_ts) as weekday,
    h.holiday_date,
    h.holiday_name,
    case
        when h.holiday_date is not null then true
        else false
    end as is_holiday,
    case
        when extract(isodow from t.event_ts) between 1 and 5
         and h.holiday_date is null
        then true
        else false
    end as is_workday,
    t.camera_name,
    t.vehicle_type,
    t.line,
    t.direction,
    t.vehicle_count,
    t.unique_count
from traffic t
left join holidays h
    on cast(t.event_ts as date) = h.holiday_date