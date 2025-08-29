

commit;


show user;


desc tbl_employee;

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


------------------------------------------------------------------------------------------------------------------
DROP SEQUENCE seq_tbl_employee;

create sequence seq_tbl_employee
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;


----------------------------------------- 사원 데이터 새로 입력 -----------------------------------------------------
-- ========================
-- 재직자
-- ========================
INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '서영학', '1', '10000', 'kimhj@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-1234-5677',
        TO_DATE('19651205','YYYYMMDD'), '3520077777777', '신한은행',
        TO_DATE('20000101','YYYYMMDD'), '재직',
        'emp01.png','emp01_saved.png', 204800);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '박한빈', '3', '10111', 'mashyu815@naver.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-1234-5671',
        TO_DATE('19950915','YYYYMMDD'), '3520011111111', '농협',
        TO_DATE('20220115','YYYYMMDD'), '재직',
        'emp02.png','emp02_saved.png', 185312);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '김강민', '2', '10211', 'okm3211@naver.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com',  '010-1234-5672',
        TO_DATE('19940220','YYYYMMDD'), '3520022222222', '국민은행',
        TO_DATE('20210310','YYYYMMDD'), '재직',
        'emp03.png','emp03_saved.png', 199221);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '이근창', '4', '10311', 'mushroom8507@naver.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-1234-5673',
        TO_DATE('19980110','YYYYMMDD'), '3520033333333', '신한은행',
        TO_DATE('20230105','YYYYMMDD'), '재직',
        'emp04.png','emp04_saved.png', 210004);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '이유림', '4', '10411', 'a1006psm@naver.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-1234-5674',
        TO_DATE('19961125','YYYYMMDD'), '3520044444444', '하나은행',
        TO_DATE('20240220','YYYYMMDD'), '재직',
        'emp05.png','emp05_saved.png', 176320);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '박규민', '5', '10511', 'pgm1016@naver.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-1234-5675',
        TO_DATE('19930508','YYYYMMDD'), '3520055555555', '우리은행',
        TO_DATE('20230525','YYYYMMDD'), '재직',
        'emp06.png','emp06_saved.png', 223104);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '최서현', '5', '10100', 'emp08@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0001',
        TO_DATE('19940312','YYYYMMDD'), '3520080000001', '국민은행',
        TO_DATE('20210302','YYYYMMDD'), '재직',
        'emp07.png','emp07_saved.png', 188416);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '장도윤', '6', '10102', 'emp09@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0002',
        TO_DATE('19970225','YYYYMMDD'), '3520090000002', '신한은행',
        TO_DATE('20220315','YYYYMMDD'), '재직',
        'emp08.png','emp08_saved.png', 201728);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '오지현', '6', '10103', 'emp10@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0003',
        TO_DATE('19981011','YYYYMMDD'), '3520100000003', '우리은행',
        TO_DATE('20240201','YYYYMMDD'), '재직',
        'emp09.png','emp09_saved.png', 194560);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '윤태훈', '7', '10111', 'emp11@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0004',
        TO_DATE('19951207','YYYYMMDD'), '3520110000004', '하나은행',
        TO_DATE('20230103','YYYYMMDD'), '재직',
        'emp10.png','emp10_saved.png', 208896);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '서다인', '7', '10112', 'emp12@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0005',
        TO_DATE('19990330','YYYYMMDD'), '3520120000005', '농협',
        TO_DATE('20220718','YYYYMMDD'), '재직',
        'emp11.png','emp11_saved.png', 172032);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '문지호', '7', '10202', 'emp14@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0007',
        TO_DATE('19981121','YYYYMMDD'), '3520140000007', '카카오뱅크',
        TO_DATE('20211129','YYYYMMDD'), '재직',
        'emp12.png','emp12_saved.png', 231424);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '배유진', '8', '10203', 'emp15@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0008',
        TO_DATE('19960109','YYYYMMDD'), '3520150000008', '토스뱅크',
        TO_DATE('20230612','YYYYMMDD'), '재직',
        'emp13.png','emp13_saved.png', 163840);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '임하늘', '8', '10211', 'emp16@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0009',
        TO_DATE('19931003','YYYYMMDD'), '3520160000009', '신한은행',
        TO_DATE('20191202','YYYYMMDD'), '재직',
        'emp14.png','emp14_saved.png', 219136);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '하준서', '8', '10212', 'emp17@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0010',
        TO_DATE('19970619','YYYYMMDD'), '3520170000010', '국민은행',
        TO_DATE('20220509','YYYYMMDD'), '재직',
        'emp15.png','emp15_saved.png', 200704);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '심예린', '9', '10300', 'emp18@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0011',
        TO_DATE('19981228','YYYYMMDD'), '3520180000011', '우리은행',
        TO_DATE('20210405','YYYYMMDD'), '재직',
        'emp16.png','emp16_saved.png', 182272);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '홍가온', '9', '10302', 'emp19@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0012',
        TO_DATE('19940909','YYYYMMDD'), '3520190000012', '농협',
        TO_DATE('20240108','YYYYMMDD'), '재직',
        'emp17.png','emp17_saved.png', 226304);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '정시윤', '9', '10311', 'emp21@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0014',
        TO_DATE('19921027','YYYYMMDD'), '3520210000014', '하나은행',
        TO_DATE('20230206','YYYYMMDD'), '재직',
        'emp18.png','emp18_saved.png', 175104);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '손도연', '10', '10312', 'emp22@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0015',
        TO_DATE('19991005','YYYYMMDD'), '3520220000015', '신한은행',
        TO_DATE('20230703','YYYYMMDD'), '재직',
        'emp19.png','emp19_saved.png', 167936);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '안서현', '10', '10400', 'emp23@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0016',
        TO_DATE('19930623','YYYYMMDD'), '3520230000016', '국민은행',
        TO_DATE('20210510','YYYYMMDD'), '재직',
        'emp20.png','emp20_saved.png', 190464);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '송유나', '10', '10402', 'emp24@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0017',
        TO_DATE('19970202','YYYYMMDD'), '3520240000017', '우리은행',
        TO_DATE('20240318','YYYYMMDD'), '재직',
        'emp21.png','emp21_saved.png', 205312);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '백태환', '10', '10403', 'emp25@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0018',
        TO_DATE('19961116','YYYYMMDD'), '3520250000018', '농협',
        TO_DATE('20220104','YYYYMMDD'), '재직',
        'emp22.png','emp22_saved.png', 214016);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '노수민', '10', '10500', 'emp26@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0019',
        TO_DATE('19940214','YYYYMMDD'), '3520260000019', '기업은행',
        TO_DATE('20221010','YYYYMMDD'), '재직',
        'emp23.png','emp23_saved.png', 160512);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '유시온', '10', '10502', 'emp27@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0020',
        TO_DATE('19981108','YYYYMMDD'), '3520270000020', '하나은행',
        TO_DATE('20230522','YYYYMMDD'), '재직',
        'emp24.png','emp24_saved.png', 198656);

-- ========================
-- 퇴직자
-- ========================
INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, resigndate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '이사퇴', '5', '10512', 'leest@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-9999-9999',
        TO_DATE('19850101','YYYYMMDD'), '3520000000999', '국민은행',
        TO_DATE('20100101','YYYYMMDD'), TO_DATE('20220101','YYYYMMDD'), '퇴직',
        'emp99.png','emp99_saved.png', 207872);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, resigndate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '한성우', '6', '10200', 'emp13@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0006',
        TO_DATE('19920614','YYYYMMDD'), '3520130000006', '기업은행',
        TO_DATE('20200106','YYYYMMDD'), TO_DATE('20231231','YYYYMMDD'), '퇴직',
        'emp98.png','emp98_saved.png', 192512);

INSERT INTO tbl_employee (emp_no, emp_pwd, emp_name, fk_rank_no, fk_dept_no, ex_email, emp_email, phone_num, birthday,
                          emp_account, emp_bank, hiredate, resigndate, emp_status,
                          emp_origin_filename, emp_save_filename, emp_filesize)
VALUES (TO_CHAR(seq_tbl_employee.nextval), 'qwer1234$', '공민재', '7', '10303', 'emp20@gr.com', TO_CHAR(seq_tbl_employee.currval) || '@hanb.com', '010-5555-0013',
        TO_DATE('19950517','YYYYMMDD'), '3520200000013', '기업은행',
        TO_DATE('20200914','YYYYMMDD'), TO_DATE('20221130','YYYYMMDD'), '퇴직',
        'emp97.png','emp97_saved.png', 216064);


commit;



select * from tab;

select * from TBL_EMAIL;
desc tbl_email;

select * from TBL_EMAIL_FILE;

select * from TBL_EMAIL_RECEIVED;

select * from tab;

SELECT *
  FROM all_sequences;
  


select * from tab;

select * from TBL_EMAIL;
desc tbl_email;

select * from TBL_EMAIL_FILE;

select * from TBL_EMAIL_RECEIVED;

select * from tab;

SELECT *
  FROM all_sequences;
  
create sequence seq_tbl_email
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;


create sequence seq_tbl_email_file
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

create sequence seq_TBL_EMAIL_RECEIVED
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;



select *
from tbl_email;

select *
from tbl_department ;

select * 
from tbl_employee;

desc TBL_TASK_PRIORITY;

select *
from tbl_task;

select * from tab;

DESC tbl_task_priority;


create sequence seq_tbl_task
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;
-- Sequence SEQ_TBL_TASK이(가) 생성되었습니다.




-- 업무테이블 임의 insert --
INSERT INTO tbl_task (
  task_no, task_title, task_detail, start_date, end_date, fk_register_emp_no
) VALUES (
  TO_CHAR(seq_tbl_task.nextval),
  '분기 실적 보고서',
  '3분기 실적 취합 및 보고서 작성',
  TO_DATE('2025-09-01 09:00','YYYY-MM-DD HH24:MI'),
  TO_DATE('2025-09-10 18:00','YYYY-MM-DD HH24:MI'),
  '3'
);

select * from tbl_task;

update TBL_EMAIL_RECEIVED set is_read = 'Y'
where fk_email_no = 0000000015;

commit;


select * from tbl_employee;

select * from tbl_board_category;

delete from tbl_board_category
where board_category_no = '10311';

commit;

INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('5010', '법무팀', 'Y', 'Y');

INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('5010', 'DEPT', '5010', 'READ');

INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('5010', 'DEPT', '5010', 'WRITE');

commit;

-- ==============================
-- 경영지원부 (10)
-- ==============================
INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('10', '경영지원부', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('10', 'DEPT', '10', 'READ');

INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('1010', '기획팀', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('1010', 'DEPT', '1010', 'READ');

INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('1011', '인사/총무팀', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('1011', 'DEPT', '1011', 'READ');

INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('1012', '재무/회계팀', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('1012', 'DEPT', '1012', 'READ');

-- ==============================
-- 영업/마케팅부 (20)
-- ==============================
INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('20', '영업/마케팅부', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('20', 'DEPT', '20', 'READ');

INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('2010', '영업팀', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('2010', 'DEPT', '2010', 'READ');

INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('2011', '마케팅팀', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('2011', 'DEPT', '2011', 'READ');

INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('2012', '고객지원팀', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('2012', 'DEPT', '2012', 'READ');

-- ==============================
-- 기술/연구부 (30)
-- ==============================
INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('30', '기술/연구부', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('30', 'DEPT', '30', 'READ');

INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('3010', '개발팀', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('3010', 'DEPT', '3010', 'READ');

INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('3011', 'QA팀', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('3011', 'DEPT', '3011', 'READ');

INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('3012', 'R&D팀', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('3012', 'DEPT', '3012', 'READ');

-- ==============================
-- 생산/운영부 (40)
-- ==============================
INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('40', '생산/운영부', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('40', 'DEPT', '40', 'READ');

INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('4010', '생산팀', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('4010', 'DEPT', '4010', 'READ');

INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('4011', '물류팀', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('4011', 'DEPT', '4011', 'READ');

INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('4012', '공정관리팀', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('4012', 'DEPT', '4012', 'READ');

-- ==============================
-- 기타 지원부 (50)
-- ==============================
INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('50', '기타 지원부', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('50', 'DEPT', '50', 'READ');

INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('5011', 'IT/보안팀', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('5011', 'DEPT', '5011', 'READ');

INSERT INTO tbl_board_category (board_category_no, board_category_name, is_comment_enabled, is_read_enabled)
VALUES ('5012', '홍보/PR팀', 'Y', 'Y');
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('5012', 'DEPT', '5012', 'READ');

-- 우선순위
INSERT INTO tbl_task_priority (fk_task_no, fk_emp_no, priority)
VALUES (TO_CHAR(seq_tbl_task.CURRVAL), '5', 20);
INSERT INTO tbl_task_priority (fk_task_no, fk_emp_no, priority)
VALUES (TO_CHAR(seq_tbl_task.CURRVAL), '4',  40);


-- ==============================
-- 경영지원부 (10)
-- ==============================
INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('10', 'DEPT', '10', 'WRITE');

select * from tbl_task_priority;

-- 열람범위
INSERT INTO tbl_task_access (fk_task_no, target_type, target_no)
VALUES (TO_CHAR(seq_tbl_task.CURRVAL), 'dept', '4010');
INSERT INTO tbl_task_access (fk_task_no, target_type, target_no)
VALUES (TO_CHAR(seq_tbl_task.CURRVAL), 'emp', '4');

select * from tbl_task_access;

-- 담당부서
INSERT INTO tbl_task_department (fk_task_no, fk_dept_no, task_dept_role)
VALUES (TO_CHAR(seq_tbl_task.CURRVAL), '4010', '협력');



select * from tbl_task_department;

commit;

-- 특정 사용자(emp_no='E000000001' 예시)의 안읽음 메일 수
SELECT COUNT(*)
FROM TBL_EMAIL_RECEIVED r
JOIN TBL_EMAIL e ON e.EMAIL_NO = r.FK_EMAIL_NO
WHERE r.FK_EMP_NO = 2
  AND r.IS_DELETED = 'N'
  AND r.IS_READ = 'N';

INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('1010', 'DEPT', '1010', 'WRITE');

INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('1011', 'DEPT', '1011', 'WRITE');

INSERT INTO tbl_board_permission (fk_board_category_no, target_type, target_no, permission_type)
VALUES ('1012', 'DEPT', '1012', 'WRITE');

select * from tbl_employee
order by to_number(fk_dept_no);
select * from tbl_board_category;
select * from tbl_comment;

-- 전사공지/전사알림 : 댓글 비허용
UPDATE tbl_board_category SET is_comment_enabled = 'N'
 WHERE board_category_name IN ('전사공지','전사알림');
 
 UPDATE tbl_board_category SET is_comment_enabled = 'Y'
 WHERE board_category_name = '자유게시판'
    OR board_category_name NOT IN ('전사공지','전사알림');
    COMMIT;

select * from TBL_WIDGET_LAYOUT;

desc TBL_WIDGET_LAYOUT;

select * from tbl_department;

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> refs/heads/main
select * from tbl_employee
where fk_dept_no = 01;

<<<<<<< HEAD
>>>>>>> refs/heads/main
=======
=======
>>>>>>> refs/heads/main

<<<<<<< HEAD
>>>>>>> refs/heads/main
>>>>>>> refs/heads/kimgm

select * from tbl_employee_position
order by to_number(fk_position_no);

select * from tbl_department;

select * from tbl_rank;

select * from tbl_position
order by to_number(position_no);


SELECT e.emp_no         AS empNo
     , e.emp_name       AS name
     , p.position_name  AS title
     , e.EMP_ORIGIN_FILENAME AS image     -- 없으면 NULL
FROM   tbl_employee e
JOIN   tbl_employee_position ep
       ON ep.fk_emp_no = e.emp_no
JOIN   tbl_position p
       ON p.position_no = ep.fk_position_no
WHERE  p.position_no IN ('1', '2')           -- 1:대표이사, 2:CEO
  AND  e.emp_status = '재직'                 -- (있다면) 재직자만
ORDER BY CASE p.position_no WHEN '1' THEN '0' ELSE '1' END
FETCH FIRST 1 ROWS ONLY;
=======
-- 설문 메타
CREATE SEQUENCE seq_survey START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE tbl_survey (
    survey_id          VARCHAR2(20)   NOT NULL,
    mongo_survey_id    VARCHAR2(64)   NOT NULL,              -- Mongo 문서 ID
    owner_emp_no       VARCHAR2(10)   NOT NULL,
    start_date         DATE           NOT NULL,
    end_date           DATE           NOT NULL,
    result_public_yn   CHAR(1)        DEFAULT 'Y' NOT NULL,
    closed_yn          CHAR(1)        DEFAULT 'N' NOT NULL,
    deleted_yn         CHAR(1)        DEFAULT 'N' NOT NULL,
    target_scope       VARCHAR2(10)   DEFAULT 'ALL' NOT NULL, -- ALL/DEPT/DIRECT
    created_at         DATE           DEFAULT SYSDATE NOT NULL,
    updated_at         DATE           DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_tbl_survey PRIMARY KEY (survey_id),
    CONSTRAINT fk_tbl_survey_owner FOREIGN KEY (owner_emp_no)
        REFERENCES tbl_employee(emp_no),
    CONSTRAINT chk_tbl_survey_flags CHECK (
        result_public_yn IN ('Y','N') AND
        closed_yn        IN ('Y','N') AND
        deleted_yn       IN ('Y','N') AND
        target_scope     IN ('ALL','DEPT','DIRECT')
    )
);

CREATE OR REPLACE TRIGGER trg_tbl_survey_bi
BEFORE INSERT ON tbl_survey
FOR EACH ROW
BEGIN
  IF :NEW.survey_id IS NULL THEN
    :NEW.survey_id := 'SV' || TO_CHAR(SYSDATE,'YYYYMMDD') || LPAD(seq_survey.NEXTVAL, 4, '0');
  END IF;
  :NEW.updated_at := SYSDATE;
END;
/

CREATE OR REPLACE TRIGGER trg_tbl_survey_bu
BEFORE UPDATE ON tbl_survey
FOR EACH ROW
BEGIN
  :NEW.updated_at := SYSDATE;
END;
/


-- (3) 설문 대상: ALL/DEPT/EMP(=DIRECT) 를 한 테이블로 표현
CREATE TABLE tbl_survey_target (
    target_id       NUMBER          NOT NULL,
    survey_id       VARCHAR2(20)    NOT NULL,
    target_type     CHAR(1)         NOT NULL,        -- 'A'(ALL), 'D'(DEPT), 'E'(EMP)
    target_dept_no  VARCHAR2(10),                    -- target_type='D'일 때 사용
    target_emp_no   VARCHAR2(10),                    -- target_type='E'일 때 사용
    CONSTRAINT pk_tbl_survey_target PRIMARY KEY (target_id),
    CONSTRAINT fk_svt_survey FOREIGN KEY (survey_id)
        REFERENCES tbl_survey(survey_id),
    CONSTRAINT fk_svt_dept FOREIGN KEY (target_dept_no)
        REFERENCES tbl_department(dept_no),
    CONSTRAINT fk_svt_emp FOREIGN KEY (target_emp_no)
        REFERENCES tbl_employee(emp_no),
    CONSTRAINT chk_svt_type CHECK (target_type IN ('A','D','E')),
    CONSTRAINT chk_svt_cols CHECK (
        (target_type = 'A' AND target_dept_no IS NULL AND target_emp_no IS NULL) OR
        (target_type = 'D' AND target_dept_no IS NOT NULL AND target_emp_no IS NULL) OR
        (target_type = 'E' AND target_emp_no  IS NOT NULL AND target_dept_no IS NULL)
    )
);

CREATE SEQUENCE seq_survey_target START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_tbl_survey_target_bi
BEFORE INSERT ON tbl_survey_target
FOR EACH ROW
BEGIN
  IF :NEW.target_id IS NULL THEN
    :NEW.target_id := seq_survey_target.NEXTVAL;
  END IF;
END;
/

-- (4) 답변(집계용): 멀티선택은 옵션별로 한 행씩 저장
CREATE TABLE tbl_survey_answer (
    survey_id     VARCHAR2(20) NOT NULL,
    emp_no        VARCHAR2(10) NOT NULL,
    question_key  VARCHAR2(64) NOT NULL,  -- Mongo의 질문 id (혹은 path key)
    option_key    VARCHAR2(64) NOT NULL,  -- Mongo의 보기 id
    answered_at   DATE         DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_sva_survey FOREIGN KEY (survey_id)
        REFERENCES tbl_survey(survey_id),
    CONSTRAINT fk_sva_emp FOREIGN KEY (emp_no)
        REFERENCES tbl_employee(emp_no),
    CONSTRAINT pk_tbl_survey_answer PRIMARY KEY (survey_id, emp_no, question_key, option_key)
);

-- 조회 성능 인덱스
CREATE INDEX ix_survey_answer_1 ON tbl_survey_answer (survey_id, question_key, option_key);
CREATE INDEX ix_survey_answer_2 ON tbl_survey_answer (survey_id, emp_no);

commit;
<<<<<<< HEAD
>>>>>>> refs/heads/main




select * from tbl_rank;

select * from tbl_position;

select * from tbl_employee;

select * from tbl_department where dept_no = '1011';


update tbl_employee set fk_dept_no = '10' where emp_no = '4';
update tbl_employee set fk_dept_no = '20' where emp_no = '2';
update tbl_employee set fk_dept_no = '30' where emp_no = '3';
update tbl_employee set fk_dept_no = '40' where emp_no = '5';
update tbl_employee set fk_dept_no = '50' where emp_no = '6';

commit;

update tbl_employee set fk_dept_no = '1011' where emp_no = '16';
update tbl_employee set fk_dept_no = '2011' where emp_no = '20';
update tbl_employee set fk_dept_no = '3010' where emp_no = '23';

commit;

update tbl_employee set fk_dept_no = '5010' where emp_no = '17';
update tbl_employee set fk_dept_no = '5011' where emp_no = '38';
update tbl_employee set fk_dept_no = '5011' where emp_no = '37';
update tbl_employee set fk_dept_no = '5012' where emp_no = '34';

commit;

update tbl_employee set fk_dept_no = '4011' where emp_no = '29';
update tbl_employee set fk_dept_no = '4012' where emp_no = '35';
update tbl_employee set fk_dept_no = '4010' where emp_no = '19';

commit;
select * from tbl_employee where fk_dept_no = '1010';

select * from tbl_schedule;

 SELECT
      e.emp_no         AS empNo,
      e.emp_name       AS empName,
      e.fk_dept_no     AS deptNo,
      r.rank_name      AS rankName,
      r.rank_level     AS rankLevel,   -- ★ 대표자 선출용 직급레벨
      e.emp_status     AS empStatus,
      (
        SELECT LISTAGG(p.position_name, ', ')
               WITHIN GROUP (ORDER BY p.position_no)
        FROM   tbl_employee_position ep
        JOIN   tbl_position p ON p.position_no = ep.fk_position_no
        WHERE  ep.fk_emp_no = e.emp_no
      )                AS positions
  FROM   tbl_employee e
  JOIN   tbl_rank r
         ON r.rank_no = e.fk_rank_no
  JOIN   tbl_department d
         ON d.dept_no = e.fk_dept_no
        AND d.dept_active = 'Y'     -- 활성 부서만
  WHERE  e.emp_status = '재직'      -- 재직자만
    AND  e.fk_dept_no IS NOT NULL
  ORDER BY
         e.fk_dept_no,
         r.rank_level ASC,          -- 직급 상위 먼저
         e.hiredate ASC,
         e.emp_no
         
         
         
SELECT
	      d.dept_no        AS deptNo,
	      d.dept_name      AS deptName,
	      d.parent_dept_no AS parentDeptNo
	  FROM   tbl_department d
	  WHERE  d.dept_active = 'Y'
	    AND EXISTS (
	      SELECT 1
	      FROM   tbl_employee e
	      WHERE  e.fk_dept_no = d.dept_no
	        AND  e.emp_status = '재직'
	    )
	  ORDER BY d.dept_no         
         
=======


select * from 
tbl_board_category;
>>>>>>> branch 'main' of https://github.com/Kgangmin/FinalProject.git
