-- First build a schema to play with:
-- https://www.ibm.com/docs/en/i/7.5?topic=tables-sample

call qsys.create_sql_sample ('sqlr2r');

-- setting the schema, 
set schema sqlr2r;

-- Now you can use it qualified or unqualified
select * from sqlr2r.systables where table_type = 'T';
select * from systables        where table_type = 'T'; 


select * from employee;
select * from sqlr2r.employee;
select * from sqlr2r.org;
select * from sqlr2r.IN_TRAY;
select * from sqlr2r.EMP_RESUME;

select * from sqlr2r.systables;

-- and we need a litte trace table to see the payloads we send to the ai and the responses we get back.
create or replace  table sqlr2r.trace (
    id int generated always as identity,
    text clob,
    created_at timestamp default current_timestamp
);
