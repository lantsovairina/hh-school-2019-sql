select	
(select	extract(month from creation_time) as month_with_max_resumes
	from
		resume r
	group by
		extract(month from creation_time)
	order by
		count(resume_id) desc
	limit 1),
(select	extract(month from creation_time) as month_with_max_vacancies
	from
		vacancy v
	group by
		extract(month from creation_time)
	order by
		count(vacancy_id) desc
	limit 1);