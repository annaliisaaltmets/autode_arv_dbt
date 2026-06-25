select *
from {{ ref('stg_traffic') }}
where vehicle_count < 0