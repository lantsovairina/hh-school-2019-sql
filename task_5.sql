select
	name
from
	vacancy v
	join vacancy_body vb using(vacancy_body_id)
	left join response r using(vacancy_id)
where
	r.creation_time - v.creation_time < '1 week' :: interval
	or r.response_id is null
group by
	vacancy_id,
	name
having
	count(r.response_id) < 5
order by
	1;