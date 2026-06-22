select
    cast(timestamp as timestamp) as event_ts,
    camera_name,
    lower(label) as vehicle_type,
    line,
    cast(count as integer) as vehicle_count,
    cast(unique_count as integer) as unique_count,
    upper(direction) as direction
from {{ ref('lootsa_valukoja_02_2026') }}