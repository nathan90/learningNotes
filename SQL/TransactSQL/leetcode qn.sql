use tempdb;
go
set nocount on;

if object_id('t', 'U') is not null
drop table t;
go

create table t
(
    id int primary key identity,
    [when] datetime,
    data int
)
go

insert into t([when], data) values ('20130801', 1);
insert into t([when], data) values ('20130802', 121);
insert into t([when], data) values ('20130803', 132);
insert into t([when], data) values ('20130804', 15);
insert into t([when], data) values ('20130805', 9);
insert into t([when], data) values ('20130806', 1435);
insert into t([when], data) values ('20130807', 143);
insert into t([when], data) values ('20130808', 18);
insert into t([when], data) values ('20130809', 19);
insert into t([when], data) values ('20130810', 1);
insert into t([when], data) values ('20130811', 1234);
insert into t([when], data) values ('20130812', 124);
insert into t([when], data) values ('20130813', 6);

select * from t;

SELECT tt.*
     ,(SELECT COUNT(id) FROM t WHERE data <= 10 AND ID < tt.ID) AS cnt
FROM  t AS tt
WHERE data > 10
select count(1) from t where id <10

select tt.id, t.id as tid from t tt

select * from t;
SELECT COUNT(id) FROM t WHERE data <= 10 AND ID < 3

select t.* FROM t