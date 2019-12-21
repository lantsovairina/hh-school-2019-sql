-- Заполнение таблицы vacancy_body
insert into
	vacancy_body(
		name,
		text,
		area_id,
		address_id,
		work_experience,
		compensation_from,
		test_solution_required,
		work_schedule_type,
		employment_type,
		compensation_gross
	)
select
	(
		select
			string_agg(
				substr(
					'      abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789',
					(random() * 77) :: integer + 1,
					1
				),
				''
			)
		from
			generate_series(1, 1 + (random() * 25 + i % 10) :: integer)
	) as name,
	(
		select
			string_agg(
				substr(
					'      abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789',
					(random() * 77) :: integer + 1,
					1
				),
				''
			)
		from
			generate_series(1, 1 + (random() * 50 + i % 10) :: integer)
	) as text,
	(random() * 1000) :: int as area_id,
	(random() * 50000) :: int as address_id,
	(random() * 10) :: int as work_experience,
	25000 + (random() * 150000) :: int as compensation_from,
	(random() > 0.5) as test_solution_required,
	floor(random() * 4) :: int as work_schedule_type,
	floor(random() * 4) :: int as employment_type,
	(random() > 0.5) as compensation_gross
from
	generate_series(1, 10000) as g(i);

update
	vacancy_body
set
	compensation_to = compensation_from + (random() * 50000) :: int;

update
	vacancy_body
set
	compensation_from = null
where
	vacancy_body_id in (
		select
			vacancy_body_id
		from
			vacancy_body vb
		order by
			random()
		limit
			1000
	);

update
	vacancy_body
set
	compensation_to = null
where
	vacancy_body_id in (
		select
			vacancy_body_id
		from
			vacancy_body vb
		order by
			random()
		limit
			1000
	);

-- Заполнение таблицы vacancy
insert into
	vacancy (
		vacancy_body_id,
		creation_time,
		expire_time,
		employer_id,
		disabled,
		visible
	)
select
	-- random in last 5 years
	vb.vacancy_body_id as vacancy_body_id,
	now() -(random() * 365 * 24 * 3600 * 5) * '1 second' :: interval as creation_time,
	now() -(random() * 365 * 24 * 3600 * 5) * '1 second' :: interval as expire_time,
	(random() * 1000000) :: int as employer_id,
	(random() > 0.5) as disabled,
	(random() > 0.5) as visible
from
	vacancy_body vb
order by
	vb.vacancy_body_id;

-- update invalid records
update
	vacancy
set
	expire_time = creation_time + (random() * 365 * 24 * 3600 * 5) * '1 second' :: interval
where
	expire_time <= creation_time;

-- Заполнение таблицы resume
insert into
	resume(name, text, desire_salary, creation_time)
select
	(
		select
			string_agg(
				substr(
					'      abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789',
					(random() * 77) :: integer + 1,
					1
				),
				''
			)
		from
			generate_series(1, 1 + (random() * 25 + i % 10) :: integer)
	) as name,
	(
		select
			string_agg(
				substr(
					'      abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789',
					(random() * 77) :: integer + 1,
					1
				),
				''
			)
		from
			generate_series(1, 1 + (random() * 25 + i % 10) :: integer)
	) as text,
	40000 + random() * 150000 as desire_salary,
	now() -(random() * 365 * 24 * 3600 * 5) * '1 second' :: interval as creation_time
from
	generate_series(1, 100000) as g(i);

-- Заполнение таблицы response  
insert into
	response (vacancy_id, resume_id, status, creation_time)
select
	vacancy_id,
	resume_id,
	status,
	creation_time
from
	(
		(
			select
				row_number() over () as response_id,
				(random() * 9999 + 1) :: int as num_vacancy
			from
				generate_series(1, 50000) as g(i)
		) as nv
		join (
			select
				row_number() over () as num_vacancy,
				vacancy_id
			from
				vacancy
		) as nvv using(num_vacancy)
	) as QV
	join (
		(
			select
				row_number() over () as response_id,
				(random() * 99999 + 1) :: int as num_resume
			from
				generate_series(1, 50000) as g(i)
		) as nr
		join (
			select
				row_number() over () as num_resume,
				resume_id
			from
				resume
		) as nrr using(num_resume)
	) as QR using(response_id)
	join (
		select
			row_number() over () as response_id,
			(random() * 5) :: int as status
		from
			generate_series(1, 50000) as g(i)
	) as SR using(response_id)
	join (
		select
			row_number() over () as response_id,
			now() -(random() * 365 * 24 * 3600 * 5) * '1 second' :: interval as creation_time
		from
			generate_series(1, 50000) as g(i)
	) as T using(response_id);

/* Свой вариант заполнения таблицы response (работает ~ 300 c)
 
 create function insert_response() returns integer as $$
 declare
 vacancy record;
 begin
 for vacancy in
 select vacancy_id from vacancy
 loop
 insert into response (vacancy_id, resume_id, status, creation_time) 
 select vacancy.vacancy_id, resume_id, 0 as status, now() as creation_time from resume order by random() limit (random() * 10)::int;
 end loop;
 return 1;
 end;
 $$ language plpgsql;
 select * from insert_response();
 update response set status = (random()*5) ::int;
 update response set creation_time = now()-(random() * 365 * 24 * 3600 * 5) * '1 second'::interval;
 */
-- Заполнение таблицы specialization  
insert into
	specialization(name)
select
	(
		select
			string_agg(
				substr(
					'      abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789',
					(random() * 77) :: integer + 1,
					1
				),
				''
			)
		from
			generate_series(1, 1 + (random() * 25 + i % 10) :: integer)
	) as name
from
	generate_series(1, 100) as g(i);

-- Заполнение таблицы vacansy_body_specialization 
insert into
	vacancy_body_specialization (vacancy_body_id, specialization_id)
select
	vacancy_body_id,
	specialization_id
from
	(
		(
			select
				row_number() over () as row,
				(random() * 9999 + 1) :: int as num_vacancy
			from
				generate_series(1, 20000) as g(i)
		) as nv
		join (
			select
				row_number() over () as num_vacancy,
				vacancy_body_id
			from
				vacancy_body
		) as nvv using(num_vacancy)
	) as QV
	join (
		(
			select
				row_number() over () as row,
				(random() * 99 + 1) :: int as num_spec
			from
				generate_series(1, 20000) as g(i)
		) as ns
		join (
			select
				row_number() over () as num_spec,
				specialization_id
			from
				specialization s
		) as nss using(num_spec)
	) as QR using(row);

-- Заполнение таблицы resume_specialization 
insert into
	resume_specialization (resume_id, specialization_id)
select
	resume_id,
	specialization_id
from
	(
		(
			select
				row_number() over () as row,
				(random() * 99999 + 1) :: int as num_resume
			from
				generate_series(1, 20000) as g(i)
		) as nr
		join (
			select
				row_number() over () as num_resume,
				resume_id
			from
				resume
		) as nrr using(num_resume)
	) as QV
	join (
		(
			select
				row_number() over () as row,
				(random() * 99 + 1) :: int as num_spec
			from
				generate_series(1, 20000) as g(i)
		) as ns
		join (
			select
				row_number() over () as num_spec,
				specialization_id
			from
				specialization s
		) as nss using(num_spec)
	) as QR using(row);