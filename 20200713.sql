--0713 SQL CLASS
제약 조건 쓰는 이유
- 데이터의 무결성을 지켜주는 도구

P.17

제약조건 생성 방법
1. 테이블 생성시, 컬럼 옆에 기술하는 경우
    * 상대적으로 세세하게 제어 불가

2. 테이블 생성시, 모든 컬럼을 기술하고 나서 제약조건만 별도로 기술
    1.방법보다 세세하게 제어 가능
    
3. 테이블 생성 이후 객체 수정명령 통해 제약조건 추가

--2. 실습-----------------------------------------------------
테이블 생성시, 모든 컬럼을 기술하고 나서 제약조건만 별도로 기술
dept_test 테이블의 deptno 컬럼을 대상으로 PRIMARY KEY 제약 조건 생성하기

CREATE TABLE dept_test (
    deptno NUMBER(2), 
    dname VARCHAR2(14), 
    loc VARCHAR2(13), 
    CONSTRAINT pk_dept_test PRIMARY KEY (deptno)
);

dept_test테이블에 deptno 동일한 값을 갖는 insert 쿼리 두개 만들어서 테스트 해보기

SELECT *
FROM dept_test;

DELETE dept_test;
INSERT INTO dept_test VALUES(99, 'sales', 'LONDON');
INSERT INTO dept_test VALUES(99, 'marketing', 'PARIS');
>>오류 : ORA-00001: unique constraint (JINNY.PK_DEPT_TEST) violated

---------------------------------------------------------------------------
DROP TABLE dept_test;


☆NOT NULL 제약 조건 : 컬럼 레벨에 기술, 테이블 기술 없음, 테이블 수정시 변경 가능

dname 컬럼에 NOT NULL 제약 주기
CREATE TABLE dept_test (
    deptno NUMBER(2) CONSTRAINT pk_dept_test PRIMARY KEY,
    dname VARCHAR2(14) NOT NULL, 
    loc VARCHAR2(13)
);

INSERT INTO dept_test VALUES(99, NULL, 'PARIS');
>>오류 : ORA-01400: cannot insert NULL into ("JINNY"."DEPT_TEST"."DNAME")


☆UNIQUE 제약 조건 
: 해당 컬럼의 값이 다른 행에 나오지 않도록(중복되지 않도록) 데이터 무결성을 지켜주는 조건
(ex: 사번, 학번,...) 
수업시간 UNIQUE 제약조건 명명규칙 : uk_테이블명_해당컬럼명
DROP TABLE dept_test;

CREATE TABLE dept_test (
    deptno NUMBER(2),
    dname VARCHAR2(14),
    loc VARCHAR2(13),    
    CONSTRAINT uk_dept_test_dname_loc UNIQUE (dname, loc) -- 복수 컬럼 사용가능(복합 컬럼) 
);
==> dname, loc를 결합해서 중복되는 데이터가 없으면 됨
ex) ddit, daejeon / ddit, 대전 은 다른 데이터로 인식
    ddit, deajeon / ddit, deajeon 일 경우 제약  ==> AND 개념
    
INSERT INTO dept_test VALUES (99, 'ddit', 'daejeon');   
INSERT INTO dept_test VALUES (98, 'ddit', 'daejeon'); -- 에러(UNIQUE 제약 조건)
INSERT INTO dept_test VALUES (98, 'ddit', 'PARIS'); -- 실행 됨

----------------------------------------------------------------------------------------------
☆FOREIGN KEY (참조키)
: 한 테이블의 컬럼의 값의 참조하는 테이블의 컬럼 값 중에 존재하는 값만 입력 되도록 제어하는 제약 조건
즉, FOREIGN KEY 경우 두개의 테이블간의 제약조건
*참조되는 테이블의 컬럼에는(dept_test.deptno) 에는 인덱스가 있어야 함 (인덱스 곧 배울 예정)

CREATE TABLE dept_test (
    deptno NUMBER(2),
    dname VARCHAR2(14), 
    loc VARCHAR2(13),
     CONSTRAINT pk_dept_test PRIMARY KEY (deptno)
);

--테스트 데이터 준비
INSERT INTO dept_test VALUES(1, 'ddit', 'daejeon');

dept_test테이블의 detpno 컬럼을 참조하는 emp_test 테이블 생성
(사번, 사원이름, 부서번호)

CREATE TABLE emp_test ( 
    empno NUMBER(4),
    dname VARCHAR(10),
    deptno NUMBER(2) REFERENCES dept_test (deptno)
);

1. dept_test에는 deptno가 1번인 부서가 존재
2. emp_test테이블의 deptno는 dept_test의 deptno를 참조
  ==> emp_test의 deptno컬럼에는 dept_test.deptno에 존재하는 값만 입력하는 것이 가능
  
- dept_test 테이블에 존재하는 부서번호로 emp_test테이블에 입력하는 경우:
INSERT INTO emp_test VALUES(9999, 'brown', 1);

- dept_test 테이블에 존재하지 않는 부서번호로 emp_test테이블에 입력하는 경우:
INSERT INTO emp_test VALUES(9998, 'sally', 2);
>>오류: ORA-02291: integrity constraint (JINNY.SYS_C007091) violated - parent key not found

-FOREIGN KEY 제약조건(FK) 테이블 컬럼 기술 이후에 별도로 작성
CONSTRAINT 제약조건명 제약조건타입 (대상컬럼명) REFERENCES 참조테이블명 (참조테이블의 컬럼명)
수업시간 명명규칙: FK_타겟테이블명_참조테이블명[index]
DROP TABLE emp_test;	

CREATE TABLE emp_test ( 
    empno NUMBER(4),
    dname VARCHAR(10),
    deptno NUMBER(2),
    CONSTRAINT FK_emp_test_dept_test FOREIGN KEY (deptno) REFERENCES dept_test (deptno)
);
- dept_test 테이블에 존재하는 부서번호로 emp_test테이블에 입력하는 경우:
INSERT INTO emp_test VALUES(9999, 'brown', 1);

- dept_test 테이블에 존재하지 않는 부서번호로 emp_test테이블에 입력하는 경우:
INSERT INTO emp_test VALUES(9998, 'sally', 2);
>> 오류: integrity constraint (JINNY.FK_EMP_TEST_DEPT_TEST) violated - parent key not found

☆FOREIGN KEY OPTION
dept : 부모 테이블
emp : 자식 테이블

참조 무결성) 
참조되고 있는 부모쪽 데이터를 삭제하는 경우 
: dept_test테이블에 1번 부서 존재
: emp_test 테이블의 brown  사원이 1번 부서에 속한 상태에서
dept_test에서 1번 부서를 삭제하는 경우 

SELECT *
FROM emp_test;

SELECT *
FROM dept_test;

DELETE dept_test
WHERE deptno=1;
>>삭제 불가 오류 : integrity constraint (JINNY.FK_EMP_TEST_DEPT_TEST) violated - child record found
>> FOREIGN KEY 기본 설정이기 때문에 에러발생

(쌤은 비추함)
FX 생성시 옵션
0. DEFAULT : 무결성이 위배되는 경우 에러
1. ON DELETE CASCADE : 부모 데이터 삭제할 경우, 참조하고 있던 자식 데이터를 같이 삭제
    (dept_test 테이블의 1번 부서번호를 삭제시, 참조 하고 있던 emp_test의 1번 부서에 소속된 brown 사원도 삭제)
2. ON DELETE SET NULL :  부모 데이터 삭제할 경우, 참조하고 있던 자식 데이터의 값을 NULL로 설정

DROP TABLE emp_test;	

CREATE TABLE emp_test ( 
    empno NUMBER(4),
    dname VARCHAR(10),
    deptno NUMBER(2),
    CONSTRAINT fk_emp_test_dept_test FOREIGN KEY (deptno) REFERENCES dept_test (deptno) ON DELETE CASCADE
);
    
INSERT INTO emp_test VALUES(9999, 'brown', 1);

--부모쪽 데이터 삭제하기
DELETE dept_test
WHERE deptno = 1; --삭제가 된다

SELECT *
FROM emp_test;

-----ON DELETE SET NULL------- 
DROP TABLE emp_test;	

CREATE TABLE emp_test ( 
    empno NUMBER(4),
    dname VARCHAR(10),
    deptno NUMBER(2),
    CONSTRAINT fk_emp_test_dept_test FOREIGN KEY (deptno) REFERENCES dept_test (deptno) ON DELETE SET NULL
);

INSERT INTO dept_test VALUES(1, 'sales', 'daejeon');
INSERT INTO emp_test VALUES (9999, 'sales', 1);   

--부모쪽 데이터 삭제하기
DELETE dept_test
WHERE deptno = 1; --삭제가 된다

SELECT *
FROM emp_test;

---------------------------------------------------------------------
☆CHECK 제약조건
: 컬럼에 입력되는 값을 검증하는 제약 조건
(ex: salary 컬럼이 음수가 입력되는 것은 부자연스럽기 때문에 salary > 0 이라는 제약 조건 줄 수 있다
     성별 컬럼에 남, 여가 아닌 값이 들어오는 것을 막는다
     직원 구분이 정직원, 임시직 2개가 존재할 때 다른 값이 들어오면 논리적으로 어긋남)


DROP TABLE emp_test;	

CREATE TABLE emp_test ( 
    empno NUMBER(4),
    ename VARCHAR(10),
    --sal NUMBER(7, 2) CHECK (sal > 0) --NUMBER(7,2 ) : 00000.00
    sal NUMBER(7, 2) CONSTRAINT sal_no_zero CHECK (sal > 0) --제약 조건 이름 붙이기
                                                            -- NOT NULL 제약조건 : CHECK (sal IS NOT NULL)
);

INSERT INTO emp_test VALUES (9999, 'sally', -1000);
>> 오류 ORA-02290: check constraint (JINNY.SAL_NO_ZERO) violated




----------------------------------------------------------------------------------------
테이블 생성 + [제약 조건 포함]
: a.k.a. "CTAS"
특징: not null 제약 조건이외의 제약 조건은 복사 안됨
CREATE TABLE        AS
SUBQUERY


SELECT *
FROM emp_test;

백업/테스트용
CREATE TABLE member_20200713 AS
SELECT *
FROM member;

CTAS 명령을 통해 emp 테이블의 모든 데이터를 바탕으로 emp_test 테이블 생성

DROP TABLE emp_test;

CREATE TABLE emp_test AS
SELECT *
FROM emp;

SELECT *
FROM emp_test;

CREATE TABLE emp_test2 AS
SELECT *
FROM emp
WHERE 1 != 1; -- 테이블 틀(emp 컬럼만) 복사하고 싶을 때 이런식으로 쓴다. 

SELECT *
FROM emp_test2;
테이블 컬럼 구조만 복사하고 싶을 때,  WHERE절에 항상 false가 되는 조건을 기술해 생성 가능

DROP TABLE emp_test2;

-------------------------------------------------------------------------------------------
☆☆ 생성된 테이블 변경
- 컬럼 작업
1. 존재하지 않았던 새로운 컬럼 추가
    ** 단, 테이블의 컬럼 기술 순서를 제어하는 것은 불가
    ** 신규 추가하는 컬럼의 경우, 컬럼 순서가 항상 테이블 컬럼의 맨 마지막 
    ** 설계할 때, 컬럼 순서 충분히 고려, 누락된 컬럼 없는지 고려해야 함

2. 존재하는 컬럼 삭제
    **제약 조건(FOREIGN KEY) 주의**
    
3. 존재하는 컬럼 변경
   * 컬럼명 변경 ==> FK와 관계없이 알아서 적용해 줌
   ** 그 외적인 부분에서는 사실상 불가능 함
     (이미 데이터가 들어가 있는 테이블에서는 힘듦.)
     ex) 컬럼 사이즈, 타입 변경 
     => 설계시 충분한 고려 필요
     
☆☆제약 조건 변경
1. 제약조건 추가
2. 제약조건 삭제
3. 제약조건 비활성화 / 활성화

--실습

DROP TABLE emp_test;   
    
CREATE TABLE emp_test ( 
    empno NUMBER(4),
    ename VARCHAR(10),
    deptno NUMBER(2)
);

★테이블 수정 키워드(ALTER)
ALTER TABLE 테이블명 ..

1. 신규 컬럼 추가(ADD)
ALTER TABLE 테이블명 ADD (컬럼 내용 기술);
ALTER TABLE emp_test ADD (hp VARCHAR2(11));

DESC emp_test;

2. 컬럼 수정(MODIFY)
** 데이터가 "존재하지 않을 때"는, 비교적 자유롭게 수정 가능(데이터 타입, 사이즈)
ALTER TABLE 테이블명 MODIFY ( 컬럼 내용 기술 )
ALTER TABLE emp_test MODIFY ( hp VARCHAR2(5));
ALTER TABLE emp_test MODIFY ( hp NUMBER(5));

**컬럼 기본값 설정
ALTER TABLE emp_test MODIFY (hp DEFAULT 123); --값 입력 안헀을때 나오는 기본값
INSERT INTO emp_test (empno, ename, deptno) VALUES(9999, 'brown', NULL);

SELECT *
FROM emp_test;

3. 컬럼 명칭 변경(RENAME COLUMN 현재컬럼명 TO 바꿀컬럼명)
ALTER TABLE emp_test RENAME COLUMN hp TO cell;

4. 컬럼 삭제(DROP (테이블명) || DROP COLUMN 테이블명)
ALTER TABLE emp_test DROP (cell);
ALTER TABLE emp_test DROP COLUMN cell;

DESC emp_test;

-------------------------------------------------------------------------------------
☆테이블 생성 후 제약조건 적용
1. 제약조건 추가(ADD) , 삭제(DROP)
+  테이블 레벨의 제약조건을 생성 
==> ALTER TABLE 테이블명 ADD CONSTRAINT 제약조건명 제약조건타입 (대상컬럼) ....


DROP TABLE emp_test;	

--별도의 제약 조건 없이 EMP_TEST테이블 생성
CREATE TABLE emp_test ( 
    empno NUMBER(4),
    ename VARCHAR(10),
    deptno NUMBER(2)
);

--테이블 생성 후 테이블 수정을 통해 emp_test 테이블의 empno컬럼에 PRIMARY KEY 제약조건 추가 
ALTER TABLE emp_test ADD CONSTRAINT pk_emp_test PRIMARY KEY (empno);

--제약조건 삭제하기(DROP) 
ALTER TABLE emp_test DROP CONSTRAINT pk_emp_test; --제거하려는 제약조건명칭 써주면 된다.

p.42 읽기

p.43 제약조건 활성화 / 비활성화
cf) 제약조건 DROP은 제약조건 자체를 삭제하는 행위
제약조건 비활성화 : 제약조건 자체는 남겨두지만, 사용하지는 않는 형태
때가 되면 다시 활성화하여 데이터 무결성에 대한 부분을 강제할 수 있다. 

DROP TABLE emp_test;	
CREATE TABLE emp_test ( 
    empno NUMBER(4),
    ename VARCHAR(10),
    deptno NUMBER(2)
);

--테이블 수정 명령을 통해 emp_test테이블의 emp_no 컬럼으로 PRIMARY KEY제약 생성
ALTER TABLE emp_test RENAME COLUMN empno TO emp_no;
ALTER TABLE emp_test ADD CONSTRAINT pk_emp_test PRIMARY KEY (empno);

DESC emp_test;

*제약조건을 활성화(ENABLE) / 비활성화(DISABLE) 하기 
ALTER TABLE emp_test DISABLE CONSTRAINT pk_emp_test; -- 제약조건 비활성화 : empno 컬럼에 중복되는값 입력 가능
ALTER TABLE emp_test ENABLE CONSTRAINT pk_emp_test; 

SELECT *
FROM user_tables; --딕셔너리

SELECT * 
FROM user_constraints
WHERE constraint_type = 'U'; --조건통해 다양하게 조회 가능
                            --not null 검색은 따로 되지 않음(check제약이기 때문)
--SELECT * 
--FROM user_constraints
--WHERE search_condition LIKE '%NULL';


SELECT *
FROM user_cons_columns
WHERE table_name = 'CYCLE'
AND constraint_name = 'PK_CYCLE';

-테이블 주석 확인하는 딕셔너리
SELECT *
FROM user_tab_comments;
-컬럼 주석 확인하는 딕셔너리
SELECT *
FROM user_col_comments
WHERE table_name = 'EMP_TEST';

- 테이블 / 컬럼 주석 작성하기
COMMENT ON TABLE/COLUMN 테이블명/테이블명.컬럼명 IS '커멘트';

COMMENT ON TABLE emp_test IS 'emp_복제';
COMMENT ON COLUMN emp_test.emp_no IS '사번';
COMMENT ON COLUMN emp_test.ename IS '사원이름';
COMMENT ON COLUMN emp_test.deptno IS '소속부서번호';

--COMMENTS 실습 comment1(p.47)
SELECT c.table_name, t.table_type, t.comments tab_comment, c.column_name, c.comments col_comment
FROM user_col_comments c JOIN user_tab_comments t ON (c.table_name = t.table_name)
WHERE c.table_name IN( 'CUSTOMER', 'CYCLE', 'DAILY', 'PRODUCT') ;

SELECT *
FROM user_tab_comments
WHERE table_name = 'EMP_TEST';

SELECT *
FROM user_col_comments 
WHERE table_name = 'EMP_TEST';

--EMP랑 DEPT테이블 제약조건설정하기

ALTER TABLE emp ADD CONSTRAINT pk_emp PRIMARY KEY (empno); 
ALTER TABLE dept ADD CONSTRAINT pk_dept PRIMARY KEY (deptno);
ALTER TABLE emp ADD CONSTRAINT fk_emp_dept FOREIGN KEY (deptno) REFERENCES dept ; 

SELECT *
FROM emp;

INSERT INTO emp VALUES(9999, 'sally', 'sales', NULL, SYSDATE, 1000, NULL, 50); 



