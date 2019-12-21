create table resume_history (
	resume_history_id serial primary key,
	resume_id integer not null,
	last_change_time timestamp not null,
	json jsonb not null
);

create function save_resume_history() returns trigger as $ save_resume_history $ begin
	insert into
		resume_history (resume_id, last_change_time, json)
	values
		(old.resume_id,	now(), to_json(old.*));

	if new is null then return old;
	else return new;
	end if;
end;
$ save_resume_history $ language plpgsql;

create trigger save_resume_history before
update or delete on resume for each row execute procedure save_resume_history();

select 
	resume_id, 
	last_change_time, 
	json ->> 'name' as old_name, 
	case when lead(json->>'name') over (partition by resume_id) is null 
		then (select name from resume r where r.resume_id = rh.resume_id)
		else lead(json->>'name') over (partition by resume_id) end 
		as new_name
from resume_history rh where resume_id = 1 order by resume_id, last_change_time;

