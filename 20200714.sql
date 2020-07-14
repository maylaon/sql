--0714 SQL CLASS P.48

오라클 객체
1. TABLE : 데이터를 저장할 수 있는 공간
    - 제약조건(NOT NULL, PRIMARY KEY, UNIQUE, CHECK, FOREIGN KEY)
    
2. VIEW : SQL  ==> 실제 데이터가 존재하는 것이 아님
 - 컬럼 제한, 자주 사용하는 결과물의 재활용, 쿼리 길이 단축
 - 논리적인 데이터 집합의 정의
 - cf) VIEW TABLE 은 잘못된 표현
 
VIEW 생성 문법
CREATE [OR REPLACE] 기존에 동일한 VIEW가 있었으면 업데이트 해라
CREATE              TABLE
CREATE              INDEX
CREATE [OR REPLACE] VIEW 뷰이름 [컬럼1, 컬럼2, ...] AS
SELECT 쿼리; ==> SELECT 쿼리를 VIEW로 만들어주는 문법

----실습
Q. emp테이블에서 급여정보인 sal, comm컬럼을 제외하고 나머지 6개 컬럼만 조회할 수 있는 SELECT쿼리를 v_emp이름의 
view 로 생성

SELECT * 
FROM emp;

CREATE OR REPLACE VIEW v_emp AS --코드 재사용 가능 -> SQL 코드가 짧아 진다. 
SELECT empno, ename, job, mgr, hiredate, deptno
FROM emp;
>> 오라클에서 뷰를 만드려면 권한을 부여하여야 한다.

SELECT *
FROM v_emp;


inline view를 이용하여 조회 가능
SELECT * 
FROM (SELECT empno, ename, job, mgr, hiredate, deptno
FROM emp);

--계정을 여러개 만들고, 그 계정마다 권한을 다르게 준다.
HR 계정에게 emp 테이블이 아니라 v_emp에 대한 접근 권한을 부여
hr 계정에서는 emp테이블의 sal, comm컬럼 볼 수 없다
==> 급여 정보에 대한 부분을 비 관련자로부터 차단할 수 있다 (java 접근제어자 같은)

GRANT SELECT ON v_emp TO hr;

[hr 계정에 접속하여 테스트 함]
SELECT *
FROM v_emp; --에러 발생. 

SELECT *
FROM JINNY.v_emp; 
v_emp view는 JINNY계정이 hr계정에게 SELECT 권한을 주었기 때문에 정상적으로 조회 가능

View = SQL
v_emp 정의
SELECT empno, ename, job, mgr, hiredate, deptno
FROM emp;

1. emp테이블에 신규 사원을 입력 (기존 14건, 추가하면 15건)
2. 
SELECT *
FROM v_emp; 결과가 몇건 일까? 15건. 

왜냐하면 v_emp는 
SELECT empno, ename, job, mgr, hiredate, deptno
FROM emp; 이기 때문

=> view라고 하는 것은 실체가 없는 데이터 집합을 정의하는 SQL
cf) 구체화된 뷰 는 실체가 있기도 함..(Material-view)

==>view는 sql이기 떄문에, 조인된 결과나 그룹 함수를 적용해 행의 건수가 달라지는 sql도 
view로 생성하는 것이 가능.

ex) emp, dept 테이블의 경우 업무상 자주 같이 쓰일 수 밖에 없는 테이블

부서명, 사원번호, 사원이름, 담당업무, 입사일자
다섯개의 컬럼을 갖는 view를 v_emp_dept 로 생성해보기

CREATE OR REPLACE VIEW v_emp_dept AS
SELECT dname, empno, ename, job, hiredate
FROM emp NATURAL JOIN dept;

SELECT *
FROM v_emp_dept;

SELECT *
FROM dept;

----------------------------------------------------------------------------------
☆ SEQUENCE 객체 ☆
cf) java UUID
SEQUENCE: 중복되지 않는 정수 값을 반환해 주는 오라클 객체
    시작값(default 1, 혹은 개발자가 설정 가능) 부터 1씩 순차적으로 증가한 값을 반환한다.
    
문법
CREATE SEQUENCE 시퀀스명;
[옵션...]

--실습
CREATE SEQUENCE seq_emp;

시퀀스 객체를 통해 중복되지 않는 값을 조회
시퀀스 객체에서 제공하는 함수
1. nextval (next value)
    -시퀀스 객체의 다음 값을 요청하는 함수 
    -함수를 호출 하면 시퀀스 객체의 값이 하나 증가하여 다음번 호출시 증가된 값을 반환하게 된다(++i 같은 애)
2. currval (current value)
    - nextval 함수를 사용하고 나서 사용할 수 있는 함수
    - nextval 함수 사용 후 얻은 값을 다시 확인할 때 사용. sysout(nextval)이랑 동일한 개념
    - sequence 객체가 다음에 리턴할 값에 대해 영향 X
    
--nextval 실습
dual 테이블과 주로 사용됨
SELECT seq_emp.currval
FROM dual;
>> currval은 nextval 이후에 사용해야 한다

SELECT seq_emp.currval
FROM dual;

SEQUENCE는 캐쉬만 수정..

--------------------------------------------------------------------------------------------
이진트리

☆INDEX☆

emp에서 empno = 7698인 데이터를 조회 ==> SELECT * FROM emp WHERE empno = 7698;

EXPLAIN PLAN FOR
SELECT * FROM emp WHERE empno = 7698;

SELECT *
FROM TABLE(dbms_xplan.display);

Plan hash value: 2949544139
 
--------------------------------------------------------------------------------------
| Id  | Operation                   | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |        |     1 |    87 |     1   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP    |     1 |    87 |     1   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN         | PK_EMP |     1 |       |     0   (0)| 00:00:01 |
--------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("EMPNO"=7698)


읽는 순서 : 2-1-0
2에서 index 읽고 1에서 index통해 검색 

>> emp테이블의 primary key제약조건을 생성 하고 나서 변경 된 점
* 오라클 입장에서 데이터를 조회할 때 사용할 수 있는 전략이 하나 더 생긴 것.
1. table full scan
2. pk_emp 인덱스 이용해 사용자가 원하는 행을 빠르게 찾아가서 필요한 컬럼들은 인덱스에 저장된 rowid이용해
  테이블의 행으로 바로 접근 가능
  

--ROWID
ROWID 특수 컬럼 ; SELECT절에 사용할 수 있는 특수 컬럼 (행의 주소 - JAVA 참조형같은)


SELECT ROWID, emp.*
FROM emp
WHERE empno = 7698;
>> ROWID : AAAE5gAAFAAAACLAAF 

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE ROWID = 'AAAE5gAAFAAAACLAAF';

SELECT *
FROM TABLE(dbms_xplan.display);
>> 결과 : 필터가 없다.
주소 값을 알고 그 주소로 접근하면 처리 속도가 빠르다.

**emp테이블의 pk_emp PRIMARY KEY 제약조건을통해 EMPNO컬럼 기준으로 인덱스가 생성(정렬)이 되어 있다.

--실습

EXPLAIN PLAN FOR
SELECT empno 
FROM emp 
WHERE empno = 7698;

SELECT *
FROM TABLE(dbms_xplan.display);

----------------------------------------------------------------------------
| Id  | Operation         | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |        |     1 |    13 |     0   (0)| 00:00:01 |
|*  1 |  INDEX UNIQUE SCAN| PK_EMP |     1 |    13 |     0   (0)| 00:00:01 |
----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - access("EMPNO"=7698)
   
사용자가 원하는 컬럼이 empno이기 때문에 테이블 접근 없이 unique scan으로 검색 종료(p.79)

--실습
empno컬럼의 인덱스를 unique 인덱스가 아닌 일반 인덱스(중복이 가능한)로 생성한 경우
1. fk_emp_dept 제약조건 삭제

ALTER TABLE emp DROP CONSTRAINT fk_emp_dept;

2. pk_emp 제약 조건 삭제
ALTER TABLE emp DROP CONSTRAINT pk_emp;


1. NON-UNIQUE 인덱스 생성(중복 가능)
UNIQUE 명명규칙 : IDX_U_테이블명_01;
NON-UNIQUE : IDX_NU_테이블명_01; 
 CREATE [UNIQUE] INDEX 인덱스명 ON 테이블 (인덱스 기준이 될 컬럼);

CREATE INDEX idx_nu_emp_01 ON emp (empno);

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno = 7698;

SELECT * 
FROM TABLE(dbms_xplan.display);

---------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    87 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    87 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_NU_EMP_01 |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("EMPNO"=7698)
 
Note
-----
   - dynamic sampling used for this statement (level=2)


==> non-unique 일때는 plus one scan이라고도 표현
unique일때는, 중복 값이 없으므로 한 값만 읽고 검색하면 되는데
non-unique일때는 밑에 중복 값이 있을 수 있으므로, 중복값이 없을때 까지 읽는다. 
(정렬된 상태이기 때문에 바로 아래값 읽어서 중복값이 없으면 종료 ==> unique에 비해 한 건 더 읽으므로 
plus one scan이라고도 함)






