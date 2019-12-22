select 
	area_id, 
	avg(compensation_from * coeff) as avg_from, 
	avg(compensation_to * coeff) as avg_to, 
	avg((compensation_from + compensation_to)/2 * coeff) as avg_mean
from 
	(select 
		area_id, 
		compensation_from, 
		compensation_to, 
		case when compensation_gross = true then 0.87 else 1 end as coeff 
	from vacancy_body vb) as vac
group by area_id order by area_id;
