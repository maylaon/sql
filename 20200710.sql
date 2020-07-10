--0710 SQL CLASS


SELECT *
FROM emp;

DELETE emp
WHERE empno > 9000;

☆ UPDATE
: 상수값으로 업데이트 ==> 서브쿼리 사용 가능

INSERT INTO emp (empno, ename, job) VALUES (9999, 'brown', 'RANGER');
 위에서 입력한 9999번 사원 번호를 갖는 사원의 deptno와 job 컬럼의 값을 SMITH사원의 DEPTNO와 JOB값으로 업데이트하기

UPDATE emp 
SET deptno = (SELECT deptno FROM emp WHERE ename = 'SMITH'), job = (SELECT job FROM emp WHERE ename = 'SMITH') 
WHERE empno = 9999; --바람직한 SQL문은 아님. MERGE이용해 효율적인 쿼리 작성 가능하다

SELECT * 
FROM emp;

==> UPDATE 쿼리1 실행할때 안쪽 SELECT 쿼리가 2개가 포함됨. ==> 비효율적
    고정된 값으로 업데이트 하는 것이 아니라 다른 테이블에 있는 값을 통해 업데이트 할때 비효율적
    ==> MERGE 구문을 통해 보다 효율적으로 UPDATE 가능
    
    

☆ DELETE
: 테이블의 행을 삭제할때 사용하는 SQL
cf) 특정 컬럼만 삭제하는 것 : UPDATE 
DELTE구문은 행 자체를 삭제한다!

1. 어떤 테이블에서 삭제할지
2. 테이블의 어떤 행을 삭제할지?

문법
DELETE [FROM] 테이블명
[WHERE 삭제할 행을 선택하는 조건];

UPDATE쿼리 실습시 9999번 사원을 등록함. 해당 사원을 삭제하는 쿼리를 작성하자

DELETE emp
WHERE empno = 9999;

SELECT *
FROM emp;

DELETE쿼리도 SELECT쿼리 작성시 사용한 WHERE절과 동일
서브쿼리 사용가능

ex) 사원 중 mgr가 7698인 사원들만 삭제

DELETE emp
WHERE empno IN (SELECT empno FROM emp WHERE mgr = 7698);

ROLLBACK;

-------------------------------------------------------------------------------------
DBMS의 특징
데이터의 복구를 위해 DML 구문을 실행할 때마다 로그를 생성한다.

실무에서 쓰는 DB 세가지 종류
테스트 DB, 디자이너/개발자 통합 테스트 DB, 운영 DB

DDL : TRUNCATE 
보통 테스트 DB에서 사용된다.
로그를 남기지 않고 보다 더 빠르게 삭제 하는 방법
대량의 데이터를 지울때는 로그 기록도 부하가 되기 때문에, 개발환경에서는 테이블의 모든 데이터를 지우는 경우에 한해 사용.
★복구 불가★

문법:
TRUNCATE TABLE 테이블명; WHERE절이 없다.

emp테이블을 이용해 새로운 테이블을 생성 (CREATE 이용)

CREATE TABLE emp_copy AS
SELECT *
FROM emp;

SELECT *
FROM emp_copy;

TRUNCATE TABLE emp_copy;
DELETE emp_copy; 와 동일함. 로그는 남음

-------------------------------------------------------------------------------------
p.312
Transaction : 논리적인 일의 단위

DML 문장이 시작되면 시작됨.
COMMIT 과 ROLLBACK 으로 컨트롤 됨 (트랜잭션 종료)
DML - COMMIT 한덩이
ROLLBACK : COMMIT 전 DML 실행 취소

cf) DCL / DDL : 자동으로 COMMIT 됨. ROLLBACK 불가

p.315 [동시성과 관련됨]

oracle server
oracle sql developer : client program
웹) 웹브라우저 = 사용자 ex) 크롬에서 네이버 접속, 익스에서 네이버 접속 따로 가능

한사람의 트랜잭션이 다른사용자에 영향을 미칠까?
동시에 작업할때, 커밋한 데이터만 상대방에게 나타난다.

읽기 일관성(lv0~lv3)
LV1. READ COMMITED 대부분 DBMS 커밋되지 않은 데이터는 다른 사용자 못봄
LV2. Repeatable Read - 
선행 트랜잭션에서 읽은 데이터를 후행 트랜잭션에서 수정하지 못하게 막아서 선행 트랜잭션 안에서는 항상 동일한 데이터 조회 되도록 보장하는 레벨
오라클에서는 공식적으로 지원하지 않으나, FOR UPDATE; 키워드를 통해 동일한 효과를 낼 수 있음. "락을 걸었다"
동시성 잃음 
EX)
SELECT *
FROM dept
WHERE deptno = 99
FOR UPDATE;  << 다른 사용자가 UPDATE할때 내가 ROLLBACK이나 COMMIT 할때까지 기다린다..(동시성 잃음)

단,  다른 사용자(후행 트랜잭션)가 INSERT 할 수 있다. 
"Phantom Read" 
즉, 수정은 막을 수 있지만 신규는 막을 수 없다
lv2에서는 테이블에 존재하는 데이터에 대해 후행 트랜잭션에서 작업하지 못하도록 막을 수 있지만 후행 트랜잭션에서 신규로 입력하는 데이터는 못막음
즉, 선행 트랜잭션에서 처음 읽은 데이터와 후행트랜잭션에서 신규 입력한 후 커밋한 이후에 조회한 데이터가 불일치 할 수 있다. 


LV3. Serializable Read
후행 트랜잭션에서 신규 데이터를 입력 해도 선행 트랜잭션에서 조회 X
이럴거면 DB왜쓰나!!!!ㅋㅋㅋㅋ  FILE쓰지....
그럼 같은 행을 서로 수정하면 후에 결과로 어떤 데이터 값이 조회되는가? 시점으로 따지나?(update충돌시?)
==> 사용자가 다른 행을 입력하면 상관 없는데 같은 행을 수정할때는 어떻게 되나?????????
==> commit 시점 기준으로 값이 나올 것!
==> 노노. lv2 이어서 같은 행 update 못함!!!! LOCK 계속 적용됨

오라클은 locking메카니즘(수정 lock)이 다른 dbms와 차이가 있다.
isolation level을 올려도 타 dbms만큼 동시성이 저하되지 않는다 왜냐하면 버전 여러개로 관리.
버전들은 메모리에 저장하는데, 시간이 지나면 이 메모리를 내린다. 
그래서 다른 dbms에 없는 에러가 발생한다. ==> SNAPSHOT TOO OLD



-------------------------------------------------------------------------------------
DML (Data Manipulation Language) 
: SELECT, INSERT, UPDATE, DELETE

☆☆DDL (Data Definition Language)☆☆ 
: 데이터가 들어갈 공간(TABLE) 생성, 삭제, 컬럼 추가, 각종 객체 생성, 수정, 삭제;

오라클 대표 객체
Table, Index, View, Sequence, Synonym, etc.

Table, 컬럼명 규칙 : 알파벳 대소문자, 숫자, _, $, # 가능. 오라클 키워드는 피해야함

**DDL은 자동 커밋. 롤백 불가

ex) 테이블 생성 DDL 실행 ==> 롤백 불가
    ==> 테이블 삭제 DDL 별도로 실행해야 함.
    
☆테이블 삭제
문법
DROP 객체종류 객체이름;
DROP table emp_copy;

SELECT *
FROM emp_copy;

테이블과 관련된 내용은 다 삭제 된다^^ 주의해서 사용할 것.

INSERT INTO emp (empno, ename) VALUES (9999, 'brown');

SELECT COUNT(*)
FROM emp;

DROP TABLE batch;

ROLLBACK; 

SELECT COUNT(*)
FROM emp; --결과는 15. 왜냐하면 DDL은 자동 커밋돼기 때문.!!!!!!! 고로 DML, DDL 순서 잘 생각해서 쓰기


☆테이블 생성
문법
CREATE TABLE 테이블명 (
    컬럼명1 컬럼1타입, 컬럼명2 컬럼2타입 DEFAULT 기본값  --값을 안넣었을때 표시 될 값 설정
    );
    
P.6
ranger라는 이름의 테이블 생성
CREATE TABLE ranger ( ranger_no NUMBER, ranger_nm VARCHAR2(50), reg_dt DATE DEFAULT SYSDATE);

SELECT *
FROM ranger;

INSERT INTO ranger (ranger_no, ranger_nm) VALUES (100, 'brown');

☆DDL DATA TYPE
DATE
SELECT *
FROM emp;
--조회만 0000/00/00 으로 보이는것인가?

EXTRACT

    
☆DDL 테이블 제약조건

데이터 무결성: 잘못된 데이터가 들어가는 것을 방지하는 성격
ex) 1. 사원테이블에 중복된 사원번호가 등록되는 것을 방지.
    2. 반드시 입력이 되어야 되는 컬럼의 값을 확인 (NOT NULL 이용)
    ==> 파일 시스템이 가질 수 없는 특징
    
오라클에서 제공하는 데이터 무결성을 지키기위해 제공하는 제약조건 5가지(사실상 4가지)
1. NOT NULL 제약
    해당 컬럼에 값이 반드시 입력 돼야 한다.
    해당 컬럼에 NULL 값이 들어오는 것을 제약, 방지 
    (ex. emp테이블의 empno)

2. UNIQUE 제약
    전체 행 중 해당 컬럼의 값이 중복이 되면 안된다. (=고유값)
    (ex. emp테이블에서 empno 컬럼이 중복 되면 안됨)
    단, null에 대한 중복은 허용 함
    
3.  PRIMARY KEY (= UNIQUE + NOT NULL)
    값이 반드시 존재하면서 고유값
    
4. FOREIGN KEY 
    연관된 테이블에 해당 데이터가 존재해야만 입력이 가능
    emp 테이블과 dept테이블은 deptno 컬럼으로 연결이 되어 있음
    (EMP테이블은DEPT테이블을 참조)
    emp테이블에 데이터를 입력할때 dept 테이블에 존재하지 않는 deptno 값을 입력하는 걸 방지
    deptno에 FOREIGN KEY 설정!  
    
5. CHECK 제약 조건
    컬럼에 들어오는 값을 정해진 로직에 따라 제어
    ex) 
    어떤 테이블에 성별이라는 컬럼 존재하면 (남성 = M, 여성 = F 로 지정시)
    M, F 두가지 값만 저장 될 수 있도록 제어
    ==> C입력시? 시스템 요구 사항을 정의할때 정의하지 않은 값이기 때문에 추후 문제 될 수 있음.
    
    (NOT NULL 도 사실 CHECK제약 조건에 속함)
    
제약조건 생성 방법
1. 테이블 생성시, 컬럼 옆에 기술하는 경우
    * 상대적으로 세세하게 제어 불가

2. 테이블 생성시, 모든 컬럼을 기술하고 나서 제약조건만 별도로 기술
    1.방법보다 세세하게 제어 가능
    
3. 테이블 생성 이후 객체 수정명령 통해 제약조건 추가
    
    
--예시
1번 방법으로 PRIMARY KEY 생성
dept 테이블과 동일한 컬럼명, 타입으로 dept_test라는 테이블 생성
    1. dept 테이블 컬럼의 구성 정보 확인
DESC dept;

CREATE TABLE dept_test (
    deptno NUMBER(2) PRIMARY KEY, 
    dname VARCHAR2(14), 
    loc VARCHAR2(13)
);

DESC dept_test;    
    
    2. PRIMARY KEY 제약조건 확인
1) NULL값 입력 테스트

INSERT INTO dept_test VALUES (null, 'ddit', 'daejeon');
>>결과: 오류 cannot insert NULL into ("JINNY"."DEPT_TEST"."DEPTNO")

2) 중복값 입력 테스트
INSERT INTO dept_test VALUES(99, 'ddit', 'daejeon');

SELECT * 
FROM dept_test;


INSERT INTO dept_test VALUES(99, 'ddit2', '대전');
>>결과 : 오류 unique constraint (JINNY.SYS_C007084) violated
SYS_C007084 ==> PRIMARY KEY 제약조건의 이름 설정 안해주면 오라클에서 자동으로 지정해줌.

--현 시점에서 dept 테이블에 deptno 컬럼에 PRIMARY KEY 제약 안걸려있음

DESC dept;

이미 존재하는 10번 부서 추가 등록

INSERT INTO dept VALUES(10, 'ddit', 'daejeon');

SELECT *
FROM dept;

DELETE dept WHERE dname = 'ddit';
------------------------------------------------------------------------
DROP TABLE dept_test;

테이블 생성시 제약조건 명을 설정한 경우
컬럼명 컬럼타입 CONSTRAINT 제약조건이름 제약조건타입(여기선PRIMARY KEY)

>>회사마다 제약조건이름 규칙이 있다.
>> 수업시간 명명규칙: PRIMARY KEY => PK_테이블명

CREATE TABLE dept_test (
    deptno NUMBER(2) CONSTRAINT pk_dept_test PRIMARY KEY, 
    dname VARCHAR2(14), 
    loc VARCHAR2(13)
);

INSERT INTO dept_test VALUES(99, 'ddit', 'daejeon');
INSERT INTO dept_test VALUES(99, 'ddit2', 'daejeon2');
>>결과 ; 오류 ORA-00001: unique constraint (JINNY.PK_DEPT_TEST) violated


