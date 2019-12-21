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
		(old.resume_id,	now(), json_build_object('name', old.name, 'text', old.text, 'desire_salary', old.desire_salary));

	if new is null then return old;
	else return new;
	end if;
end;
$ save_resume_history $ language plpgsql;

create trigger save_resume_history before
update or delete on resume for each row execute procedure save_resume_history();