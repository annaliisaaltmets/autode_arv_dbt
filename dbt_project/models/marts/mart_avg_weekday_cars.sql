

with daily_car_counts as (

    select
        event_date,
        week_start,
        sum(vehicle_count) as vehicle_count
    from {{ ref('int_traffic') }}
    where
        vehicle_type = 'car'
        and is_workday = true
    group by
        event_date,
        week_start
)

select
    week_start,
    round(avg(vehicle_count), 0) as avg_weekly_cars,
    round(percentile_cont(0.5) within group (order by vehicle_count)::numeric,0) as median_weekly_cars
from daily_car_counts
group by week_start
order by week_start