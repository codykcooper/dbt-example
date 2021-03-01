
with pe_by_state_age as(
    select * from {{ ref('unpivot_pre_existing')}}
)

select
    state,
    sum(value) as num_pre_existing
from pe_by_state_age
group by state