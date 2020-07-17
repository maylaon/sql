--07/17 SQL CLASS
--NEW PT : <SQL응용>

1. Multiple Insert <= 많이 쓰는 편은 아님
: 한번의 INSERT쿼리를 통해 여러 "테이블"에 데이터 입력
cf) RDBMS: 데이터의 중복을 최소화 인데? => 그래서 많이 안씀
ex) 
실 사용 예시 : 1) 실제 사용할 테이블과 별개로 보조 테이블에도 동일한 데이터 쌓기
             2) 데이터의 수평 분할 (*)
             ex) 주문 테이블 입력 
             2020년 데이터 - TB_ORDER_2020
             2021년 데이터 - TB_ORDER_2021 (테이블이름이 계속 바뀜 - 유지보수가 힘듦)
             ==> 오라클 PARTITION 을 통해 더 효과적으로 관리 가능 (정식 버전에서) 
             : 하나의 테이블안의 데이터 값에 따라 저장하는 물리공간이 나뉘어 있음
             ==> 개발자 입장에서는 데이터를 입력시, 데이터 값에 따라 물리적인 공간을 오라클이 알아서 나눠 저장

Multiple Insert의 종류
 1) Unconditional Insert : 조건에 관계없이 하나의 데이터를 여러 테이블에 입력
 2) Conditional all Insert : 조건을 만족하는 모든 테이블에 입력
 3) Conditional first Insert : 조건을 만족하는 첫번째 테이블에 입력
 
 ex)
 emp테이블의 empno컬럼, ename컬럼만 갖고 emp_test, emp_test2 생성
 단 데이터를 복사하지 않음
 
 CREATE TABLE emp_test2 AS
 SELECT empno, ename
 FROM emp 
 WHERE 1 != 1;
 
 SELECT *
 FROM emp_test;
 
 -- 1. Unconditional Insert 실습
 아래 두개의 행을 emp_test, emp_test2에 동시 입력 (하나의 insert sql 이용)
  SELECT 9999 empno, 'brown' ename FROM dual --나 이거 헷갈려 하는거 같음
 UNION ALL
 SELECT 9998 empno, 'sally' ename FROM dual;
 
INSERT ALL INTO emp_test (empno, ename) VALUES (empno, ename)
           INTO emp_test2 (empno) VALUES (empno) --아래의 empno를 test2의 empno에 넣겠다!
SELECT 9999 empno, 'brown' ename FROM dual
UNION ALL
SELECT 9998 empno, 'sally' ename FROM dual; --짱 편하네..



-- 2. Conditional Insert 실습
ROLLBACK;
조건 분기 문법 : CASE WHEN THEN END 
조건 분기 함수 : DECODE 

INSERT ALL 
   WHEN empno >= 9999 THEN --조건에 따라 저장해야하는 테이블 구분할 수 있다.
           INTO emp_test (empno, ename) VALUES (empno, ename)
   WHEN empno >= 9998 THEN --조건에 따라 저장해야하는 테이블 구분할 수 있다.
           INTO emp_test2 (empno, ename) VALUES (empno, ename)
   ELSE --위에 둘다 아닐 시
           INTO emp_test2 (empno) VALUES (empno) 
SELECT 9999 empno, 'brown' ename FROM dual
UNION ALL
SELECT 9998 empno, 'sally' ename FROM dual; 

SELECT *
FROM emp_test2;
 
--3. Conditional First 실습

INSERT FIRST 
   WHEN empno >= 9999 THEN --조건에 따라 저장해야하는 테이블 구분할 수 있다.
           INTO emp_test (empno, ename) VALUES (empno, ename)
   WHEN empno >= 9998 THEN --조건에 따라 저장해야하는 테이블 구분할 수 있다.
           INTO emp_test2 (empno, ename) VALUES (empno, ename)
   ELSE --위에 둘다 아닐 시
           INTO emp_test2 (empno) VALUES (empno) 
SELECT 9999 empno, 'brown' ename FROM dual
UNION ALL
SELECT 9998 empno, 'sally' ename FROM dual;
 
----(PT.09)--------------------------------------------------------------------------
☆ Merge, 머지?
: 사용자로부터 받은 값을 갖고 테이블 저장 OR 수정.
입력받은 값이 테이블에 존재하면 수정하고 싶고, 존재하지 않으면 신규 입력 하고 싶을 때

ex)
empno 9999, ename 'brown'
emp 테이블에 동일한 empno가 있으면 ename을 업데이트
emp 테이블에 동일한 empno가 없으면 9999, 'brown' 신규 입력

머지구문을 사용하지 않는다면
1. 해당 데이터가 존재하는지 확인하는 SELECT 구문을 실행
SELECT *
FROM emp
WHERE empno = 9999;

2. 1번 쿼리 조회 결과 값이 있으면 UPDATE 
                    값이 없으면 INSERT
==> 두개의 쿼리가 필요.

UPDATE emp SET ename = 'brown'
WHERE empno = 9999;

INSERT INTO emp (empno, ename) VALUES (9999, 'brown');


테이블의 데이터를 이용해 다른 테이블의 데이터를 UPDATE OR INSERT시 MERGE사용 가능
일반 UPDATE 구문에서는 비효율이 존재
ALLEN의 JOB과 DEPTNO를 SMITH사원과 동일한 업데이트를 하시오
-머지 구문 미사용시
UPDATE emp SET job = (SELECT job FROM emp WHERE ename = 'SMITH'),
            deptno = (SELECT deptno FROM emp WHERE ename = 'SMITH')
WHERE ename = 'ALLEN'; --잊지말자 WHERE구문. WHERE구문을 먼저 쓰는 습관을 갖도록 하자       


★Merge 문법★
MERGE INTO 테이블명(덮어쓰거나, 신규로 입력할 테이블) alias 
USING (소스테이블명 | VIEW | INLINE VIEW) alias 
ON ( 두 테이블간 데이터 존재 여부를 확인할 조건)
WHEN MATCHED THEN --값이 있을 때
    UPDATE SET 컬럼1 = 덮어쓸 값1, 컬럼2 = 덮어쓸 값2, ..
WHEN NOT MATCHED THEN
    INSERT (컬럼1, 컬럼2, ...)
    VALUES (값1, 값2, ...); --INTO는 위에서 MERGE INTO로 테이블 지정해주었기 때문에 쓰지 않는다.
    
ROLLBACK;

1. 7369사원의 데이터를 EMP_TEST로 복사(empno, ename)

INSERT INTO emp_test 
SELECT empno, ename
FROM emp
WHERE empno = 7369;

SELECT *
FROM emp;
(DELETE emp WHERE 지울 애들 조건)

2. EMP테이블을 이용해 emp_test에 동일한 empno값이 있으면 emp_test.ename업뎃
    없으면 emp테이블의 데이터를 신규 입력
    
MERGE INTO emp_test et
USING emp e
ON (et.empno = e.empno)
WHEN MATCHED THEN
    UPDATE SET et.ename = e.ename || '_m'
WHEN NOT MATCHED THEN
    INSERT (empno, ename) VALUES (e.empno, e.ename);
    
==> emp_test 테이블에는
7369사원의 이름이 SMITH_m으로 업데이트
나머지 사원들은 insert 됨

SELECT *
FROM emp_test;


★Merge에서 많이 사용하는 형태
사용자로부터 받은 데이터를 emp_test 테이블에 동일한 데이터 존재 유무에 따른 merge
시나리오: 사용자 입력 empno = 9999, ename = brown


MERGE INTO emp_test et
USING (SELECT :empno empno, :ename ename FROM dual) u --테이블명에 user를 쓰면 안된다!
ON (et.empno = u.empno)
WHEN MATCHED THEN 
    UPDATE SET et.ename = u.ename
WHEN NOT MATCHED THEN
    INSERT VALUES (u.empno, u.ename);

--쌤

MERGE INTO emp_test et
USING dual
ON (et.empno = :empno)
WHEN MATCHED THEN 
    UPDATE SET ename = :ename
WHEN NOT MATCHED THEN
    INSERT VALUES(:empno, :ename)

--실습: dept_test3 테이블을 dept 테이블과 동일하게 생성
    단, 10, 20번 부서 데이터만 복제
    
CREATE TABLE dept_test3 AS
SELECT *
FROM dept
WHERE deptno IN (10,20);

DEPT테이블을 이용해 DEPT_TEST3테이블에 데이터를 MERGE
조건 : 부서번호가 같은 데이터 
    동일한 부서가 있을 때: 기존 LOC컬럼의 값 + _m 으로 업뎃
                없을 때 : 신규 데이터 입력
ROLLBACK;
                
MERGE INTO dept_test3 dt  --TABLE에는 별칭에 AS를 주면 안된다
USING dept d
ON (dt.deptno = d.deptno)
WHEN MATCHED THEN
    UPDATE SET loc = loc || '_m'
WHEN NOT MATCHED THEN
    INSERT VALUES(d.deptno, d.dname, d.loc); -- d.* 하믄 왜 안되나? : 문법상 그렇게 설계가 됨..SHIT
    
SELECT *
FROM dept_test3;


--실습2
사용자 입력받은 값을 이용한 MERGE
사용자 입력: deptno = 9999, dname = 'ddit', loc = 'daejeon'
dept_test3 테이블에 사용자가 입력한 deptno값과
동일한 데이터가 있을 경우 : 사용자가 입력한 dname, loc 값으로 두개 컬럼 업데이트
            없을 경우 : 사용자가 입력한 값으로 인서트
            

MERGE INTO dept_test3  dt
USING dual
ON (dt.deptno = :deptno)
WHEN MATCHED THEN
    UPDATE SET dname = :dname, loc = :loc
WHEN NOT MATCHED THEN
    INSERT VALUES(:deptno, :dname, :loc); 
            
SELECT *
FROM dept_test3;

DESC dept_test3;


----GROUP 함수의 응용(PT.16)-----------------------------------------------------------
어려워짐..허헣

GROUP FUNCTION 응용, 확장
SELECT deptno, SUM(sal)
FROM emp
GROUP BY deptno;

--SELECT deptno, SUM(sal) s
--FROM emp
--GROUP BY deptno
--UNION ALL
--SELECT '' deptno, SUM(a.s)
--FROM(SELECT deptno, SUM(sal) s
--FROM emp
--GROUP BY deptno) a; --내가 쓴 것..GROUP BY 개념 덜 익혀짐

SELECT deptno, SUM(sal)
FROM emp
GROUP BY deptno
UNION ALL
SELECT NULL, SUM(sal)
FROM emp
ORDER BY deptno;

--GROUP BY에서
GROUP BY 지정 안하고 SUM/AVG 함수 쓰면 그 전체에 대한 SUM/AVG값을 얻을 수 있다. 

emp테이블을 한번만 읽고 처리하기

SELECT deptno, SUM(sal)
FROM 


SELECT NULL deptno, SUM(a.s)
FROM(SELECT deptno, SUM(sal) s
FROM emp
GROUP BY deptno) a;

SELECT *
FROM (SELECT deptno, SUM(sal) s FROM emp GROUP BY deptno) a JOIN 

MERGE INTO (SELECT deptno, SUM(sal) s FROM emp GROUP BY deptno) a
USING 
ON ( a.deptno != a.deptno)
WHEN MATCHED THEN
     INSERT INTO VALUES(NULL, SUM(a.s));
WHEN NOT MATCHED THEN
   


INSERT INTO (SELECT deptno, SUM(sal) s FROM emp GROUP BY deptno) a 
VALUES(NULL, SUM(a.s));

 
 SELECT deptno, SUM(sal)
 FROM emp
 GROUP BY deptno;
 
 SELECT ROWNUM rn
 FROM dept 
 WHERE ROWNUM <= 2;



SELECT DECODE(rn, 1, deptno, 2, null) dn, sum_sal, rn
FROM(SELECT deptno, SUM(sal) s
FROM emp
GROUP BY deptno) a, 
 (SELECT ROWNUM rn
 FROM dept 
 WHERE ROWNUM <= 2) b
 GROUP BY dn;


SELECT DECODE(rn, 1, deptno, 2, NULL) deptno, SUM(s)
FROM(SELECT deptno, SUM(sal) s
FROM emp
GROUP BY deptno) a, 
 (SELECT ROWNUM rn
 FROM dept 
 WHERE ROWNUM <= 2) --절대 생각 못했음..
 GROUP BY DECODE(rn, 1, deptno, 2, NULL)
 ORDER BY deptno;

보통 실제로 데이터가 있는 테이블을 쓰진 않고
 (SELECT ROWNUM rn
 FROM dept 
 WHERE ROWNUM <= 2)
 
 SELECT ROWNUM rn FROM dual CONNECT BY LEVEL <= 2 이런식으로 쓴다.
 
 ---------------------------------------------------------------------
 GROUP BY ROLLUP (GROUP BY의 확장 구문)
 1.정해진 규칙으로 서브 그룹을 생성하고, 생성된 서브그룹을 하나의 집합으로 반환.
 2. GROUP BY ROLLUP(컬럼1, 컬럼2, ...)
 3. ROLLUP 절에 기술된 컬럼을 오른쪽 부터 하나씩 제거해가며 서브그룹을 생성
 => ROLLUP의 경우 방향성이 있기 때문에 컬럼 기술 순서가 다르면 다른 결과가 나온다.
  
 : 여러개의 SQL 사용시 가능
  오른쪽 컬럼을 하나씩 제거하며 GROUP BY를 한다
 
SELECT deptno, SUM(sal)
FROM emp
GROUP BY ROLLUP(deptno);
 
 SELECT *
 FROM emp;
 
예시
1. GROUP BY deptno => 부서번호별 총계
2. GROUP BY '' ==> 전체 총계

ex)
GROUP BY ROLLUP(job, deptno)
1. GROUP BY job, deptno ==> 담당 업무, 부서 번호별
2. GROUP BY job ==> 담당 업무별 
3. GROUP BY '' ==> 전체 통계

* ROLLUP절에 N개의 컬럼 기술했을 때 Subgroup의 개수는 : N+1 개( + 전체통계)

SELECT job, deptno, SUM(sal + NVL(comm,0)) sal
FROM emp
GROUP BY ROLLUP(job, deptno); --순차적으로 아래(행)에 추가된다


SELECT job, deptno, GROUPING(job), GROUPING(deptno), SUM(sal + NVL(comm,0)) sal
FROM emp
GROUP BY ROLLUP(job, deptno);

--GROUPING

--실습 group_ad2
SELECT DECODE(GROUPING(job),1, '총계', 0, job) job, deptno, SUM(sal + NVL(comm,0)) sal
FROM emp
GROUP BY ROLLUP(job, deptno);


