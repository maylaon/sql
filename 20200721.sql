--0721 CLASS
<복습>
    확장된 GROUP BY
    => 서브그룹을 자동으로 생성.
    만약 이런 구문이 없다면 개발자가 직접 SELECT쿼리를 여러개 작성해서 UNION ALL 해야함(동일한 테이블 여러번 조회) => 성능저하
    
    1. ROLLUP
        1) ROLLUP절에 기술한 컬럼을 오른쪽에서부터 지워나가며 서브그룹을 생성
        2) 생성되는 서브 그룹 : ROLLUP절에 기술한 컬럼 개수 + 1(전체) 
        3) ROLLUP(job,deptno) 일때, GROUP BY job, deptno -> GROUP BY job -> GROUP BY ''으로
            오른쪽에서부터 지워나가며 서브그룹 생성한다
    
    2. GROUPING SETS
        1) 생성자가 원하는 서브그룹을 직접 지정하는 형태
        2) 컬럼 기술의 순서는 결과 집합에 영향을 미치지 않는다(집합 개념)
        
    3. CUBE
        1) 큐브절에 기술한 컬럼의 가능한 모든 조합으로 서브그룹을 생성한다.
        2) 잘 안쓴다. 서브 그룹이 너무 많이 생성되기 때문 (2^n(컬럼개수))

상호연관 서브쿼리 이용해 DELETE 구문 작성(P.46)

--실습 SUB_A2
0) DEPT_TEST 테이블에 EMPCNT 컬럼 삭제

ALTER TABLE dept_test DROP (empcnt);

SELECT *
FROM dept_test;

1) 2개의 신규 데이터 입력
INSERT INTO dept_test VALUES(99, 'ddit1', 'daejeon');
INSERT INTO dept_test VALUES(99, 'ddit2', 'daejeon');

2) 부서(dept_test)중에 직원이 속하지 않은 부서를 삭제
    서브쿼리를 사용해서
    1. 비상호연관 2. 상호연관

1. like this..?
DELETE dept_test dt
WHERE dt.deptno NOT IN (SELECT deptno FROM emp);
    
2. 
DELETE dept_test dt
WHERE dt.deptno NOT IN (SELECT deptno FROM emp WHERE deptno = dt.deptno);

2-1. 쌤
DELETE dept_test
WHERE NOT EXISTS (SELECT 'X' FROM emp WHERE emp.deptno = dept_test.deptno);

-----실습 sub_a3
1) emp테이블을 이용해 emp_test 테이블 생성
2) emp_test 테이블에서 본인이 속한 부서의 (sal)평균 급여보다 급여가 작은 직원의 급여 + 200

SELECT *
FROM emp_test;


UPDATE emp_test et 
SET sal = sal + 200
WHERE et.sal < (SELECT AVG(sal) FROM emp WHERE deptno = et.deptno); 


---값 조인해서 비교해보기(self)
CREATE TABLE emp_avg AS
SELECT deptno, ROUND(AVG(sal),2) avg_sal
FROM emp
GROUP BY deptno;

SELECT *
FROM emp_avg;

SELECT evg.*, et.ename, et.sal add_sal, emp.sal emp_sal
FROM emp_avg evg JOIN emp_test et ON (evg.deptno = et.deptno) JOIN emp ON (et.ename = emp.ename);


DROP TABLE emp_avg;


----CF--------------------------------------------------------------------------------------------------------------
-중복 제거 (이런 것도 있다)
SELECT DISTINCT deptno
FROM emp;

----P.48------------------------------------------------------------------------------------------------------------
☆WITH 쿼리블록명(테이블명) AS (서브쿼리1), AS (서브쿼리2), .... 
=> 이걸 쓰면 따로 TABLE 안만들고 쓸 수 있다! 
=> WITH절을 사용하면 메모리에 올릴 수 있다.(속도향상)

:쿼리 블럭을 생성하고, 같이 실행되는 SQL에서 해당 쿼리블럭을 반복적으로 사용할 때 성능 향상 효과를 기대할 수 있다.
WITH 절에 기술된 쿼리 블럭은 메모리에 한번만 올리기 때문에, 쿼리에서 반복적으로 사용하더라도 실제 데이터를 가져오는 작업은
한번만 발생한다. 
하지만, 하나의 쿼리에서 동일한 서브쿼리가 반복적으로 사용된다는 것은 쿼리를 잘못 작성할 가능성이 높다는 뜻이므로 
with절로 해결하기보다는 쿼리를 다른 방식으로 작성할 수 없는지 먼저 고려해볼 것을 추천**

ex) 회사의 DB를 다른 외부인에게 오픈할 수 없기 때문에, 외부인에게 도움을 구하고자 할 때, 테이블을 대신할 목적으로 많이 사용


----P.52------------------------------------------------------------------------------------------------------------
  ★계층쿼리★

☆☆달력 만들기☆☆
--DUAL테이블을 이용해 원하는 개수만큼 행을 만들기
SELECT *
FROM dual
CONNECT BY LEVEL <= 30;

'202007'
1) 원하는 달의 일수가 구하기
SELECT dual.*, level --rownum같은 개념
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY((TO_DATE('202007','YYYYMM'))),'DD');

2) 7월 날짜 구하기 (LEVEL활용)
SELECT TO_DATE('202007','YYYYMM') + (level-1) as 날짜, --왜 마이너스 1이지
        TO_CHAR((TO_DATE('202007','YYYYMM') + (level-1)), 'D') as day_1,
        --일요일이면 날짜 출력(첫번째컬럼), 아니면 NULL
        CASE WHEN day_1 = 1 THEN day_1 = day_1
             WHEN day_1 != 1 THEN day_1 = NULL
             END AS day_2
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY((TO_DATE('202007','YYYYMM'))),'DD');



SELECT TO_DATE('202007','YYYYMM') + (level-1) as 날짜,
        TO_CHAR((TO_DATE('202007','YYYYMM') + (level-1)), 'D') as day_1,
        DECODE(TO_CHAR((TO_DATE('202007','YYYYMM') + (level-1)), 'D'),1,TO_DATE('202007','YYYYMM')+ (level-1)) AS sun,
        DECODE(TO_CHAR((TO_DATE('202007','YYYYMM') + (level-1)), 'D'),2,TO_DATE('202007','YYYYMM')+ (level-1)) AS mon,
        DECODE(TO_CHAR((TO_DATE('202007','YYYYMM') + (level-1)), 'D'),3,TO_DATE('202007','YYYYMM')+ (level-1)) AS tue,
        DECODE(TO_CHAR((TO_DATE('202007','YYYYMM') + (level-1)), 'D'),4,TO_DATE('202007','YYYYMM')+ (level-1)) AS wed,
        DECODE(TO_CHAR((TO_DATE('202007','YYYYMM') + (level-1)), 'D'),5,TO_DATE('202007','YYYYMM')+ (level-1)) AS thu,
        DECODE(TO_CHAR((TO_DATE('202007','YYYYMM') + (level-1)), 'D'),6,TO_DATE('202007','YYYYMM')+ (level-1)) AS fri,
        DECODE(TO_CHAR((TO_DATE('202007','YYYYMM') + (level-1)), 'D'),7,TO_DATE('202007','YYYYMM')+ (level-1)) AS sat
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY((TO_DATE('202007','YYYYMM'))),'DD');

--가독성을 위해 인라인뷰를 쓴다
SELECT  iw, MAX(DECODE(d, 1, dt)) sun, MAX(DECODE(d, 2, dt)) mon, MAX(DECODE(d, 3, dt)) tue, MAX(DECODE(d, 4, dt)) wed, 
        MAX(DECODE(d, 5, dt)) thu, 
        MAX(DECODE(d, 6, dt)) fri, MAX(DECODE(d, 7, dt)) sat
FROM 
(SELECT TO_DATE('201912','YYYYMM') + (level-1) as dt,
        TO_CHAR((TO_DATE('201912','YYYYMM') + (level-1)), 'D') as d,
        TO_CHAR((TO_DATE('201912','YYYYMM') + (level-1)), 'IW') as iw --주차 구하기
        FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY((TO_DATE('201912','YYYYMM'))),'DD'))
GROUP BY iw
ORDER BY iw;
>>결과가 iw는 월요일 기준이므로 day와 맞지 않기 떄문에 일요일일 경우엔 iw+1 을 해주어야 한다

SELECT  DECODE(d, 1, iw+1, iw) iw, MAX(DECODE(d, 1, dt)) sun, MAX(DECODE(d, 2, dt)) mon, MAX(DECODE(d, 3, dt)) tue, MAX(DECODE(d, 4, dt)) wed, 
        MAX(DECODE(d, 5, dt)) thu, 
        MAX(DECODE(d, 6, dt)) fri, MAX(DECODE(d, 7, dt)) sat
FROM 
(SELECT TO_DATE(:yyyymm,'YYYYMM') + (level-1) as dt,
        TO_CHAR((TO_DATE(:yyyymm,'YYYYMM') + (level-1)), 'D') as d,
        TO_CHAR((TO_DATE(:yyyymm,'YYYYMM') + (level-1)), 'IW') as iw --주차 구하기
        FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY((TO_DATE(:yyyymm,'YYYYMM'))),'DD'))
GROUP BY DECODE(d, 1, iw+1, iw)
ORDER BY iw;

--마지막 일자의 주차 
SELECT TO_CHAR(LAST_DAY((TO_DATE('202007','YYYYMM'))),'DD')) d
FROM dual;


--실습 calendar 0

SELECT  DECODE(d, 1, iw+1, iw) iw, MAX(DECODE(d, 1, dt)) sun, MAX(DECODE(d, 2, dt)) mon, MAX(DECODE(d, 3, dt)) tue, MAX(DECODE(d, 4, dt)) wed, 
        MAX(DECODE(d, 5, dt)) thu, 
        MAX(DECODE(d, 6, dt)) fri, MAX(DECODE(d, 7, dt)) sat
FROM 
(SELECT TO_DATE(:yyyymm,'YYYYMM') + (level-1) as dt,
        TO_CHAR((TO_DATE(:yyyymm,'YYYYMM') + (level-1)), 'D') as d,
        TO_CHAR((TO_DATE(:yyyymm,'YYYYMM') + (level-1)), 'IW') as iw --주차 구하기
        FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY((TO_DATE(:yyyymm,'YYYYMM'))),'DD'))
GROUP BY DECODE(d, 1, iw+1, iw)
ORDER BY iw;







----실습 calendar 1

SELECT *
FROM sales;

DESC sales;

==> 여기서 MAX, MIN, SUM 써도 되는데 MIN을 쓰는게 성능상 유리하다. 
SELECT MIN(DECODE(TO_CHAR(dt,'MM'),01, SUM(sales))) jan,  MIN(DECODE(TO_CHAR(dt,'MM'),02, SUM(sales))) feb,
       MIN(DECODE(TO_CHAR(dt,'MM'),03, SUM(sales))) mar, MIN(DECODE(TO_CHAR(dt,'MM'),04, SUM(sales))) apr,
        MIN(DECODE(TO_CHAR(dt,'MM'),05, SUM(sales))) may, MIN(DECODE(TO_CHAR(dt,'MM'),06, SUM(sales))) jun  
FROM sales
GROUP BY TO_NUMBER(TO_CHAR(dt,'MM'));

--SUM.....전체 행을 합칠때. GROUP BY 쓸 필요 X

--WITH 샘
SELECT DECODE(m, 01, sales), DECODE(m, 02, sales),DECODE(m, 03, sales),DECODE(m, 04, sales),DECODE(m, 05, sales),DECODE(m, 06, sales)
FROM(
SELECT TO_CHAR(dt, 'MM') m, SUM(sales) sales
FROM sales
GROUP BY TO_CHAR(dt, 'MM')) m;

SELECT NVL(SUM(DECODE(TO_CHAR(dt, 'MM'), '01', sales)),0) jan,
       NVL(SUM(DECODE(TO_CHAR(dt, 'MM'), '02', sales)),0) feb,
       NVL(SUM(DECODE(TO_CHAR(dt, 'MM'), '03', sales)),0) mar,
       NVL(SUM(DECODE(TO_CHAR(dt, 'MM'), '04', sales)),0) apr,
       NVL(SUM(DECODE(TO_CHAR(dt, 'MM'), '05', sales)),0) may
FROM sales;







