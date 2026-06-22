select *
from {{ ref('stg_traffic') }}
where count < 0