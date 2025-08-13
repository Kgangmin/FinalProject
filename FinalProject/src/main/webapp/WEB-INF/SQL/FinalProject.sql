<<<<<<< HEAD
show user;


desc tbl_employee;
=======
<<<<<<< HEAD
show user;

select * 
from tbl_employee;

create table tbl_schedule
(
    schedule_no     varchar2(10)    not null,
    fk_emp_no       varchar2(10)    not null,
    schedule_title  varchar2(50)    not null,
    start_date      date            not null,
    end_date        date            not null,
    schedule_detail varchar2(200),
    loc             varchar2(30),
    constraint      pk_tbl_schedule_schedule_no
        primary key (schedule_no),
    constraint      fk_tbl_schedule_fk_emp_no
        foreign key (fk_emp_no)
        references  tbl_employee(emp_no)
);

create sequence seq_tbl_schedule
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;
-- Sequence SEQ_TBL_SCHEDULE이(가) 생성되었습니다.   

insert into tbl_schedule values(to_char(seq_tbl_schedule.nextval), '5', '운동하기', '2025-08-20 20:00', '2025-08-20 22:00', '등, 어깨', '헬스장');
insert into tbl_schedule values(to_char(seq_tbl_schedule.nextval), '5', '영화보기', '2025-08-16 13:00', '2025-08-16 15:20', '좀비딸', 'CGV');
insert into tbl_schedule values(to_char(seq_tbl_schedule.nextval), '5', '저녁약속', '2025-08-22 19:00', '2025-08-22 21:00', '메뉴는 삼겹살', 'HB하우스');















=======
select * from tab;

select * from TBL_EMAIL;
desc tbl_email;

select * from TBL_EMAIL_FILE;

select * from TBL_EMAIL_RECEIVED;

select * from tab;

SELECT *
  FROM all_sequences
  

