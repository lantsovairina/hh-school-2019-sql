select
    month_with_max_resumes,
    month_with_max_vacancies
from
    (
        select
            extract(
                month
                from
                    creation_time
            ) as month_with_max_resumes,
            count(resume_id) as resumes
        from
            resume r
        group by
            extract(
                month
                from
                    creation_time
            )
        order by
            2 desc
        limit
            1
    ) as rr
    cross join (
        select
            extract(
                month
                from
                    creation_time
            ) as month_with_max_vacancies,
            count(vacancy_id) as vacancies
        from
            vacancy v
        group by
            extract(
                month
                from
                    creation_time
            )
        order by
            2 desc
        limit
            1
    ) as vv;