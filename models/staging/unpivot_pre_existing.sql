
with unpivot_table as(
    {{ dbt_utils.unpivot(
        source('insur_data','state_prexisting_by_age'), 
        cast_to='integer', 
        exclude=['state']) }}
)

select * from unpivot_table
where 
    field_name != 'percent_of_nonelderly_pre_existing' and 
    field_name != 'nonelderly_pre_existing'
