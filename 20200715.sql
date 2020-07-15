--0715 SQL CLASS

오라클 객체(Object)
☆ table : 데이터 저장 공간 
- ddl 생성, 수정, 삭제
☆ view : SQL쿼리. 논리적인 데이터 정의, 실체가 없다
        view를 구성하는 테이블의 데이터가 변경되면 veiw의 결과도 달라진다.
        
☆ sequence : 중복되지 않는 정수값을 반환해주는 객체
              유일한 값이 필요할 떄 사용할 수 있는 객체
              nextval, currval  
            
☆ index : 테이블의 일부 컬럼을 기준으로 미리 정렬해 놓은 데이터
            ==> 테이블 없이 단독적으로 생성 불가, 특정 테이블에 종속

cf) DBMS구조
DB 구조에서 중요한 전제 조건
1. DB에서 Input/Output 기준은 행단위가 아닌 block 단위
    한건의 데이터를 조회하더라도, 해당 행이 존재하는 block 전체를 읽는다
    
2. extent: 공간할당 기준 (추후에 배움)

데이터 접근 방식
1. table full access
    => multi block io 방식 : 읽어야할 블럭을 여러개 한번에 읽어들이는 방식
                            (일반적으로 8~16 block)
    => 사용자가 원하는 데이터의 결과가 table의 모든 데이터를 다 읽어야 처리가 가능한 경우엔 속도 빠름
    ==> index access 보다 table full access 방식이 유리할 수 있다
   ex)
    전제조건: mgr, sal, comm 컬럼으로 인덱스가 없을 때
    mgr, sal, comm 정보를 table에서만 획득 가능할 때
   SELECT COUNT(mgr), SUM(sal), SUM(comm), AVG(sal)
   FROM emp;
    
2. index access, index access 후 table access
    => single block io : 읽어야할 행이 있는 데이터 block만 읽어서 처리하는 방식
    소수의 몇건의 테이터를 사용자가 조회할 경우, 그리고 조건에 맞는 인덱스가 존재할 경우 빠른 처리.
    * 하지만 single block io가 빈번하게 일어나면, multi block io보다 오히려 느리다.
    

---------------------------------------------------------------------------------------------
현상태 :IDX_UN_emp_01 (empno)

emp테이블의 job컬럼을 기준으로 2번째 NON-UNIQUE 인덱스 생성
CREATE INDEX ind_nu_emp_02 ON emp (job);

현상태 :IDX_NU_emp_01 (empno), IDX_NU_emp_02 (job) 
EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job = 'MANAGER' AND ename LIKE 'C%'; --job컬럼만 인덱스가 있음

SELECT * 
FROM TABLE(dbms_xplan.display);

| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    87 |     2   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    87 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IND_NU_EMP_02 |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("ENAME" LIKE 'C%')
   2 - access("JOB"='MANAGER')

순서: 2-1-0
|*  2 |   INDEX RANGE SCAN          | IND_NU_EMP_02
job 컬럼이 index 기준이므로, 정렬이 돼있는 상태여서 빠르게 접근 가능하다.

----인덱스 추가 생성
emp 테이블의 job, ename컬럼으로 복합 non-unique index 생성 (idx_nu_emp_03)

EXPLAIN PLAN FOR
CREATE INDEX idx_nu_emp_03 ON emp (job, ename);
--JOB으로 정렬, JOB 이름 동일시 NAME으로 정렬 후 인덱스 생성
-- 둘중 한 컬럼에 데이터가 있으면 인덱스 저장된다. (둘중 하나 NULL값, 둘중 하나 데이터 있을경우)
| Id  | Operation              | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------
|   0 | CREATE INDEX STATEMENT |               |   409 |  5317 |     4   (0)| 00:00:01 |
|   1 |  INDEX BUILD NON UNIQUE| IDX_NU_EMP_03 |       |       |            |          |
|   2 |   SORT CREATE INDEX    |               |   409 |  5317 |            |          |
|   3 |    INDEX FAST FULL SCAN| IDX_NU_EMP_03 |       |       |            |          |
----------------------------------------------------------------------------------------

현재 인덱스 상태 : 3개
EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job = 'MANAGER' AND ename LIKE 'C%'; --더 빨라졌을듯

SELECT * 
FROM TABLE(dbms_xplan.display);

| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    87 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    87 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_NU_EMP_03 |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("JOB"='MANAGER' AND "ENAME" LIKE 'C%')
       filter("ENAME" LIKE 'C%')

아까와 다른 부분: ename값으로도 access했다
현재 상태 : idx_nu_emp_01 (empno), idx_nu_emp_02(job), idx_nu_emp_03(job, ename)
여기선 02와 03이 중복 

-----쿼리 조금 수정
위에 쿼리와 변경된 부분은 like패턴이 변경

LIKE 'C%' ==> LIKE '%C'

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job = 'MANAGER' AND ename LIKE '%C'; --index가 잘 실행되는지 확인해보자. 얘는 인덱스가 있어도 다 읽어야함.

SELECT * 
FROM TABLE(dbms_xplan.display);
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    87 |     2   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    87 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IND_NU_EMP_02 |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("ENAME" IS NOT NULL AND "ENAME" LIKE '%C')
   2 - access("JOB"='MANAGER') --ENAME값 인덱스 못씀. --> INDEX 02만 사용한 꼴
   
   
----인덱스 추가
인덱스 추가
emp 테이블에 ename, job 컬럼을 기준으로 non-unique 인덱스 생성(idx_nu_emp_04)
CREATE INDEX idx_nu_emp_04 ON emp(ename, job);

현 인덱스 상황 : 
idx_nu_emp_01 (empno)
idx_nu_emp_02 (job)
idx_nu_emp_03 (job, ename)
idx_nu_emp_04 (ename, job) : 복합 컬럼의 인덱스의 컬럼 순서가 미치는 영향

SELECT ename, job, rowid
FROM emp
ORDER BY ename, job; --idx_04는 이런결과로 나타난다

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job = 'MANAGER' AND ename LIKE 'C%';

SELECT * 
FROM TABLE(dbms_xplan.display);

DROP INDEX idx_nu_emp_03;
--idx03지우고 실행했더니 idx04로 실행됐다.

| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    87 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    87 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_NU_EMP_04 |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("ENAME" LIKE 'C%' AND "JOB"='MANAGER')
       filter("JOB"='MANAGER' AND "ENAME" LIKE 'C%')

-- 오라클에서는 like보다 equal 비교를 더 선호하는 듯 하다.
-- 어떤 조건이 like인지 ==> 어떤 인덱스를 쓸것인지
-- inx 03 지우기전) 여기서는 job이 equal 비교이므로 index03 (job, ename) 가 쓰임

(p.94)--------------------------JOIN에서의 인덱스--------------------------------------------

조인에서의 인덱스 활용
emp : pk_emp, fk_emp_dept 생성

ALTER TABLE emp ADD CONSTRAINT pk_emp PRIMARY KEY (empno);
ALTER TABLE emp ADD CONSTRAINT fk_emp_dept FOREIGN KEY (deptno) REFERENCES dept (deptno);

EXPLAIN PLAN FOR
SELECT *
FROM emp NATURAL JOIN dept
WHERE empno = 7788;

접근 방식: emp  1. table full access, 2. 인덱스*4 ==> 방법 5가지 존재
         dept  1. table full access, 2. 인덱스(PK(deptno)) ==> 방법 2가지 존재
        ==> 가능한 경우의 수 5 * 2 = 10가지 
            방향성 emp먼저 처리할지 dept 먼저 처리할지? 2가지
            총 : 20가지
            
SELECT * 
FROM TABLE(dbms_xplan.display);

| Id  | Operation                     | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |               |     1 |   117 |     2   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                 |               |       |       |            |          |
|   2 |   NESTED LOOPS                |               |     1 |   117 |     2   (0)| 00:00:01 |
|   3 |    TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    87 |     1   (0)| 00:00:01 |
|*  4 |     INDEX RANGE SCAN          | IDX_NU_EMP_01 |     1 |       |     0   (0)| 00:00:01 |
|*  5 |    INDEX UNIQUE SCAN          | PK_DEPT       |     1 |       |     0   (0)| 00:00:01 |
|   6 |   TABLE ACCESS BY INDEX ROWID | DEPT          |   409 | 12270 |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - access("EMP"."EMPNO"=7788)
   5 - access("EMP"."DEPTNO"="DEPT"."DEPTNO")
   
실행순서: 4-3-5-2-6-1-0

NESTED LOOPS = 반복
--where empno = 7788 없애고 부서 번호로 14건의 데이터를 조인하게 되면 어떻게 될까?
EXPLAIN PLAN FOR
SELECT *
FROM emp NATURAL JOIN dept;

SELECT * 
FROM TABLE(dbms_xplan.display);

| Id  | Operation                    | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |         |    14 |  1638 |     6  (17)| 00:00:01 |
|   1 |  MERGE JOIN                  |         |    14 |  1638 |     6  (17)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID| DEPT    |     4 |   120 |     2   (0)| 00:00:01 |
|   3 |    INDEX FULL SCAN           | PK_DEPT |     4 |       |     1   (0)| 00:00:01 |
|*  4 |   SORT JOIN                  |         |    14 |  1218 |     4  (25)| 00:00:01 |
|   5 |    TABLE ACCESS FULL         | EMP     |    14 |  1218 |     3   (0)| 00:00:01 |
----------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - access("EMP"."DEPTNO"="DEPT"."DEPTNO")
       filter("EMP"."DEPTNO"="DEPT"."DEPTNO")

실행 순서: 3-2-5-4-1-0

--------------------------------------------------------------------------------------------

시스템에서 실행되는 모든 쿼리를 분석해 적절한 개수의 최적의 인덱스 설계 어려움

INDEX 구분
: 값의 중복 여부에 따라 구분

--index 실습 idx1(p.110)

CREATE TABLE dept_test2 AS
SELECT *
FROM dept
WHERE 1 = 1;

CREATE UNIQUE INDEX ind_u_dept_test2_01 ON dept_test2 (deptno);
CREATE INDEX ind_nu_dept_test2_02 ON dept_test2 (dname);
CREATE INDEX ind_nu_dept_test2_03 ON dept_test2 (deptno, dname);
--index 실습 idx2
DROP INDEX ind_u_dept_test2_01;
DROP INDEX ind_nu_dept_test2_02;
DROP INDEX ind_nu_dept_test2_03;

--idx3

CREATE  TABLE emp_idx3 AS
SELECT *
FROM emp
WHERE 1 = 1;

empno(uk) , ename, deptno , sal, mgr,  hiredate

CREATE UNIQUE INDEX ind_u_emp_idx3_01 ON emp_idx3 (empno);
CREATE INDEX ind_nu_emp_idx3_02 ON emp_idx3 (ename);
CREATE INDEX ind_nu_emp_idx3_03 ON emp_idx3 (deptno, empno);
CREATE INDEX ind_nu_emp_idx3_05 ON emp_idx3 (deptno, sal);
CREATE INDEX ind_nu_emp_idx3_06 ON emp_idx3 (deptno, job);

SELECT *
FROM emp_idx3;


EXPLAIN PLAN FOR
SELECT deptno, TO_CHAR(hiredate,'yyyymm'), COUNT(*) cnt
FROM emp_idx3
GROUP BY deptno, TO_CHAR(hiredate, 'yyyymm');

SELECT * 
FROM TABLE(dbms_xplan.display);

EXPLAIN PLAN FOR
SELECT b.*
FROM emp_idx3 a, emp_idx3 b
WHERE a.mgr = b.empno
AND a.deptno = :deptno;

SELECT * 
FROM TABLE(dbms_xplan.display);

EXPLAIN PLAN FOR
SELECT deptno, TO_CHAR(hiredate, 'yyyymm'), COUNT(*) cnt
FROM emp
GROUP BY deptno, TO_CHAR(hiredate, 'yyyymm'); --TO_CHAR때매

SELECT *
FROM emp
ORDER BY deptno, hiredate;

EXPLAIN PLAN FOR
SELECT deptno, job
FROM emp_idx3
GROUP BY deptno, job; --TO_CHAR때매 no...


-----idx3 : 정답 없음
쌤 분석
pattern 분석:
1. empno (=)
2. ename (=)
3. deptno (=) , empno(LIKE)
4. deptno(=), sal(between)
5. deptno(=), empno(=)
6. 인덱스(deptno, hiredate)가 있을 경우 table 접근이 필요 없음

==>
index(empno)
index(ename)
index(deptno, empno, sal, hiredate)

ex)
emp테이블에 데이터가 5천만건
10, 20, 30 데이터는 각각 50건씩 존재 => 인덱스 이용
40번 데이터가 4850만건일 때 => table full access 이용

-----idx4 : 숙제^^ 

---------------------------------------------------------------------------------------------
p.114
- Synonym : 별칭 생성
오라클 객체에 별칭을 생성
ex) JINNY.v_emp => v_emp
CREATE [PUBLIC] SYNONYM 붙여줄 명칭 FOR 원본객체;
PUBLIC : 모든 사용자가 사용할 수 있는 SYNONYM. 권한이 있어야 생성 가능
PRIVATE : 해당 사용자만 사용할 수 있는 SYNONYM

