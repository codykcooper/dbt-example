
with pivot_insur_data as(
    select
        destination, 
        {{
            dbt_utils.pivot('agency_type',
            dbt_utils.get_column_values(source('insur_data', 'travel_insurance'), 'agency_type'),
            then_value = 'commision'
            )
        }}
    from {{ source('insur_data', 'travel_insurance') }}
    group by destination
)

select * from pivot_insur_data

