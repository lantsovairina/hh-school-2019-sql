--Для запроса из задачи 4 
create index resume_creation_month_idx on resume(
    extract(
        month
        from
            creation_time
    )
);