with res_vac_spec(resume_id, specialization_id, count) as (
	select
		resume_id,
		specialization_id,
		count(vacancy_id)
	from
		resume r
		left join response using(resume_id)
		left join vacancy using(vacancy_id)
		left join vacancy_body_specialization vs using(vacancy_body_id)
	where
		vs.specialization_id is not null
	group by
		resume_id,
		vs.specialization_id
)
select
	resume_id,
	rs.specialization_id,
	array_agg(resume_specialization.specialization_id) as specializations
from
	(
		select
			distinct on (res_vac_spec.resume_id) res_vac_spec.resume_id,
			specialization_id
		from
			res_vac_spec
			left join (
				select
					resume_id,
					max(count) as mcount
				from
					res_vac_spec
				group by
					resume_id
			) temp on res_vac_spec.resume_id = temp.resume_id
			and res_vac_spec.count = temp.mcount
	) rs
	join resume_specialization using(resume_id)
group by
	resume_id,
	rs.specialization_id;