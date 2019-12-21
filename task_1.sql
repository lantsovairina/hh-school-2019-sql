create table vacancy_body (
    vacancy_body_id serial primary key,
    name varchar(220) not null,
    text text,
    area_id integer,
    address_id integer,
    work_experience integer default 0 not null,
    compensation_from bigint,
    compensation_to bigint,
    test_solution_required boolean default false not null,
    work_schedule_type integer default 0 not null,
    employment_type integer default 0 not null,
    compensation_gross boolean,
    driver_license_types varchar(5)[],
    constraint vacancy_body_work_employment_type_validate check ((employment_type = any (array[0, 1, 2, 3, 4]))),
    constraint vacancy_body_work_schedule_type_validate check ((work_schedule_type = any (array[0, 1, 2, 3, 4])))
);

create table vacancy (
    vacancy_id serial primary key,
    creation_time timestamp not null,
    expire_time timestamp not null,
    employer_id integer default 0 not null,    
    disabled boolean default false not null,
    visible boolean default true not null,
    vacancy_body_id integer references vacancy_body(vacancy_body_id)
);

create table specialization (
	specialization_id serial primary key,
	name varchar(200) not null
);

create table vacancy_body_specialization (
    vacancy_body_specialization_id serial primary key,
    vacancy_body_id integer references vacancy_body(vacancy_body_id),
    specialization_id integer references specialization(specialization_id)
);

create table resume (
	resume_id serial primary key,
	name varchar(200) not null,
	text text not null,
	desire_salary integer,
	creation_time timestamp not null
);

create table resume_specialization (
	resume_specialization_id serial primary key,
	resume_id integer references resume(resume_id),
	specialization_id integer references specialization(specialization_id)
);

create table response (
	response_id serial primary key,
	vacancy_id integer references vacancy(vacancy_id),
	resume_id integer references resume(resume_id),
	status integer not null,
	creation_time timestamp not null	
);

