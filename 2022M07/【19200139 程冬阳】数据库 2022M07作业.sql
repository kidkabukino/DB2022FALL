alter table 图书 alter column 价格 set default 10.00;

alter table 读者 alter column 证件状态 set default '可用';

alter table 读者 drop column 联系方式;

alter table 读者 add 电话 char(12);

alter table 图书 
	alter column 图书名称 type varchar(50) using 图书名称::varchar(50);
alter table 图书
    alter column 图书名称 drop not null;

drop table 图书类型 CASCADE;

create view 计算机图书
as
	select 图书.*,图书类型.图书分类名称
	from 图书,图书类型
	where 图书.图书分类号=图书类型.图书分类号
		and 图书类型.图书分类名称 like '计算机%'

create view 读者借书情况表(读者证件号，读者姓名，图书名称，借书日期)
as
	select 读者.证件号,读者.姓名,图书.图书名称,借阅.借阅日期
	from 读者,图书,借阅
	where 读者.证件号=借阅.证件号
		and 图书.图书编号=借阅.图书编号;

drop view 计算机图书;

create index BookBorrowInfo_ZJH_JYRQ
ON 借阅(证件号,借阅日期);

create index BookBorrowInfo_FLH on 图书(图书分类号);
create index BookBorrowInfo_TSMC on 图书(图书名称);
create index BookBorrowInfo_CBS on 图书(出版社);

select 图书名称,出版社,价格 from 图书 where 作者='杨万华';

select distinct 图书名称,价格 
from 图书 
where 图书名称='计算机主板维修从业技能全程通';

select 图书名称,count(*) 总馆藏量
from 图书 
group by 图书名称
order by 总馆藏量 desc;

select 姓名,图书名称,借阅.借阅日期,借阅.归还日期
from 图书,读者,借阅 
where 读者.证件号=借阅.证件号 and 图书.图书编号=借阅.图书编号
	and 姓名='王小虎';

select 读者.姓名,count(*) 借书数量
from 读者,借阅 
where 读者.证件号=借阅.证件号
group by 读者.姓名;

select 姓名 as 不可借阅读书的读者,证件状态
from 读者 
where 证件状态='失效'

select 读者.证件号,读者.姓名
from 读者,借阅
where 读者.证件号=借阅.证件号
	and 借阅.应还日期<借阅.归还日期;

select 读者.证件号,读者.姓名
from 读者,借阅
where CURRENT_DATE>应还日期
	and 读者.证件号=借阅.证件号
	and 借阅.归还日期 is NULL;

select count(*) 借书总量
from 借阅
where 借阅日期<'2015-09-01'

update 读者
set 证件状态='可用'
where 姓名='陈晓琪';

delete from 借阅
where 证件号=(select 证件号 from 读者 where 姓名='李涵');

insert into 图书(图书编号,图书名称,图书分类号,作者,出版社,价格)
values('9787115231011','C++程序设计','TP301','谭浩强','清华大学出版社',24.0000);

insert into 借阅(证件号,图书编号,借阅日期,应还日期,归还日期,罚款金)
values('J200902002','9787115231011', '2015/10/13','2015/11/13',NULL,0.0000);

update 借阅
set 罚款金=0.1*(select CURRENT_DATE-归还日期 超期天数
			 	from 借阅
			 	where 证件号='W200912004' and 图书编号='9787115224996')
where 证件号='W200912004' and 图书编号='9787115224996';

CREATE FUNCTION trigger_function ()
  RETURNS trigger
AS $$
BEGIN
if(select count(*) from 读者,inserted where 读者.证件号=inserted.证件号)=0
then
	raise notice '没有该读者信息';
	rollback;
end if;
END; $$
LANGUAGE plpgsql;

create trigger Insert_借阅 before insert
on 借阅
for each row 
execute procedure trigger_function();

CREATE FUNCTION trigger_update ()
  RETURNS trigger
AS $$
BEGIN
	raise notice '不能手工修改借阅日期';
	rollback;
END; $$
LANGUAGE plpgsql;

create trigger update_借阅 before update of "借阅日期"
on 借阅
for each row
execute procedure trigger_update();

CREATE FUNCTION trigger_delete ()
  RETURNS trigger
AS $$
BEGIN
	delete from 借阅 
	where 证件号 in
	(select 证件号 from deleted);
END; $$
LANGUAGE plpgsql;

create trigger delete_借阅 before delete
on 借阅
for each row
execute procedure trigger_delete();
