--0720 class
--지난 시간 이어서
--GROUPING
Grouping(Column) : 0 , 1
0 : 해당 컬럼이 소계 계산에 사용되지 않은 경우 (Group by컬럼으로 사용됨)
1 : 해당 컬럼이 소계 계산에 사용된 경우 (Group by컬럼으로 사용 안됨)

--실습 group_ad2
SELECT DECODE(GROUPING(job),1, '총계', 0, job) job, deptno, SUM(sal + NVL(comm,0)) sal
FROM emp
GROUP BY ROLLUP(job, deptno);

SELECT GROUPING(job)
FROM emp
GROUP BY ROLLUP(job, deptno);

--cf) 잘못된 풀이
SELECT NVL(job, '총계')
FROM emp
GROUP BY ROLLUP(job, deptno);

※JOB컬럼이 GROUP BY 컬럼으로 소계계산으로 사용되어 null값이 나온 것인지, 아니면 정말 컬럼의 값이 null인 행들이
group by 된것인지 알기위해선 GROUPING 함수를 사용해야한다.

☆NVL함수를 사용하지 않고 GROUPING 함수를 사용해야하는 이유

SELECT job, mgr, SUM(sal), GROUPING(job), GROUPING(mgr)
FROM emp
GROUP BY ROLLUP(job,mgr);



SELECT job, deptno, GROUPING(deptno), GROUPING(job), SUM(sal)
FROM emp
GROUP BY ROLLUP(job,deptno);

SELECT DECODE(GROUPING(job), 1, '총', 0, job) job, 
            CASE 
            WHEN GROUPING(deptno) = 1 AND GROUPING(job) = 1 THEN '계'
            WHEN GROUPING(deptno) = 1 AND GROUPING(job) = 0 THEN '소계'
            WHEN GROUPING(deptno) = 0 AND GROUPING(job) = 0 THEN TO_CHAR(deptno) --DEPTNO는 숫자이므로 문자열로 바꿔야한다.
            END AS deptno, SUM(sal) sal_sum
FROM emp
GROUP BY ROLLUP(job,deptno);

SELECT DECODE(GROUPING(job), 1, '총', 0, job) job, 
--       DECODE(GROUPING(deptno)=GROUPING(job), 1, '계', 0, '소계') deptno
--        DECODE(GROUPING(deptno), GROUPING(job)=1, '계',GROUPING(job)=0, '소계') deptno
        DECODE(1, GROUPING(deptno) AND GROUPING(job), '계', GROUPING(deptno) OR GROUPING(job), '소계', 0, TO_CHAR(deptno)) deptno
FROM emp
GROUP BY ROLLUP(job,deptno);


SELECT DECODE(GROUPING(deptno), 1 AND GROUPING(job), '계', 1 AND GROUPING(job) = 0, '소계', 0 AND GROUPING(job), TO_CHAR(deptno)) deptno
FROM emp
GROUP BY ROLLUP(job,deptno);

SELECT DECODE(GROUPING(job), 1, '총', 0, job) job, 
            CASE 
            WHEN GROUPING(deptno) = 1 AND GROUPING(job) = 1 THEN '계'
            WHEN GROUPING(deptno) = 1 AND GROUPING(job) = 0 THEN '소계'
            WHEN GROUPING(deptno) = 0 AND GROUPING(job) = 0 THEN TO_CHAR(deptno)
            END AS deptno, SUM(sal) sal_sum
FROM emp
GROUP BY ROLLUP(job,deptno);

[GROUP_AD2-1] 이렇게 생각하자ㅠㅠㅠ
SELECT DECODE(GROUPING(job), 1, '총', 0, job) job, 
       DECODE(GROUPING(job)+GROUPING(deptno), 2, '계', 1, '소계', 0, deptno) deptno
FROM emp
GROUP BY ROLLUP(job,deptno);


--실습 GROUP_AD3
SELECT deptno, job, SUM(sal)+NVL(SUM(comm),0) sal
FROM emp
GROUP BY ROLLUP (deptno,job);

SELECT job, deptno, SUM(sal)+NVL(SUM(comm),0) sal
FROM emp
GROUP BY ROLLUP (deptno,job); --이렇게 컬럼 위치를 바꿔도 rollup 순서 읽을 수 있어야 한다.

--실습 GROUP_AD4

SELECT dname, job, sum(sal+NVL(comm,0)) sal
FROM dept NATURAL JOIN emp
GROUP BY ROLLUP(dname, job)
ORDER BY dname, job DESC;

--인라인뷰로오? 이렇게도 생각해보기.
-- emp가 1억건이라면? 
-- 먼저 group by하고 join 하기 때문에 속도 향상
SELECT dept.dname, a.job, sal_sum
FROM (SELECT deptno, job, SUM(sal+NVL(comm,0)) sal_sum
        FROM emp
        GROUP BY ROLLUP(deptno,job)) a, dept
WHERE a.deptno = dept.deptno(+);


--실습 GROUP_AD5
SELECT DECODE(GROUPING(dname), 1, '총합', 0, dname) dname, job, sum(sal+NVL(comm,0)) sal
FROM dept NATURAL JOIN emp
GROUP BY ROLLUP(dname, job)
ORDER BY dname, job DESC;

SELECT dname, GROUPING(job), GROUPING(dname), job, sum(sal+NVL(comm,0)) sal
FROM dept NATURAL JOIN emp
GROUP BY ROLLUP(dname, job)
ORDER BY dname, job DESC;

--위에 것으로 복습해보기
SELECT DECODE(GROUPING(dname), 1, '총합', 0, dname) dname, 
        DECODE(GROUPING(job)+GROUPING(dname), 2, '계', 1, '소계', 0, job) job
        , sum(sal+NVL(comm,0)) sal
FROM dept NATURAL JOIN emp
GROUP BY ROLLUP(dname, job)
ORDER BY dname, job DESC;

★★확장된 GROUP BY
1. ROLLUP (O) - 컬럼 기술에 방향성이 있다. 
    GROUP BY ROLLUP(job, deptno) != GROUP BY ROLLUP(deptno, job)
    GROUP BY job, deptno            GROUP BY deptno, job
    GROUP BY job                    GROUP BY deptno
    GROUP BY  ''                    GROUP BY ''
    단점: 개발자가 필요없는 서브그룹을 임의로 제거할 수 없다.
    
    
2. GROUPING SETS (O) - 필요한 서브그룹을 임의로 지정하는 형태
    GROUP BY GROUPING SETS(컬럼1, 컬럼2)
=   GROUP BY 컬럼1
    UNION ALL
    GROUP BY 컬럼2
    => 복수의 GROUP BY를 하나로 합쳐서 결과를 돌려준다.
    ROLLUP과 다르게 방향성이 없다. (컬럼 나열 순서가 데이터자체에 영향 안미침) 

    GROUP BY a, b
    UNION ALL
    GROUP BY a
    ==> GROUPING SETS((a,b),a) 로 쓰면 된다.

--실습
SELECT job, deptno, SUM(sal + NVL(comm,0)) sal_sum
FROM emp
GROUP BY GROUPING SETS (job, deptno);
--GROUP BY ROLLUP(job,deptno)

--위 쿼리를 UNION ALL로 풀어 쓰기
SELECT 0 job, 0 deptno, 0 sal
FROM dual
UNION ALL
SELECT job, SUM(sal + NVL(comm,0)) sal_sum
FROM emp
GROUP BY job
UNION ALL
SELECT deptno, SUM(sal + NVL(comm,0)) sal_sum
FROM emp
GROUP BY deptno;

--난 모르겠다^^ ==> null을 넣어주면 된다^^
-- with 쌤
SELECT job, null, SUM(sal + NVL(comm,0)) sal_sum
FROM emp
GROUP BY job
UNION ALL
SELECT null, deptno, SUM(sal + NVL(comm,0)) sal_sum
FROM emp
GROUP BY deptno;

--p.33
SELECT job, deptno, mgr, SUM(sal + NVL(comm,0)) sal_sum
FROM emp
GROUP BY GROUPING SETS((job,deptno),mgr);


SELECT job, deptno, mgr, SUM(sal + NVL(comm,0)) sal_sum
FROM emp
GROUP BY GROUPING SETS(job,deptno,mgr);


--큐브
3. CUBE (△) 
GROUP BY를 확장한 구문
CUBE절에 나열한 모든 가능한 조합으로 서브구릅 생성
SELECT job, deptno, SUM(sal + NVL(comm,0)) sal_sum
FROM emp
GROUP BY CUBE(job,deptno);
= GROUP BY job, deptno
  GROUP BY job
  GROUP BY deptno
  GROUP BY ''
  ==> 총 네가지 경우의 수 (2^n)가지 (포함되거나/포함되지않거나)
  ==> 실제 필요하지 않는 서브 그룹이 포함될 가능성이 높음
  ==> ROLLUP, GROUPING SETS보다 활용성 떨어짐.
  
**GROUP BY job, ROLLUP(deptno), CUBE(mgr) 로 기술할 수도 있지만 
내가 필요로 하는 서브그룹을 grouping sets를 통해 정의하면 간단히 작성 가능. 

--분석해보기
GROUP BY job, ROLLUP(deptno), CUBE(mgr)

ROLLUP(deptno) : GROUP BY deptno, 
                GROUP BY ''

CUBE(mgr) : GROUP BY mgr
            GROUP BY ''

GROUP BY job, deptno, mgr
GROUP BY job, deptno
GROUP BY job, mgr
GROUP BY job

SELECT job, deptno, mgr, SUM(sal+ NVL(comm,0)) sal_sum
FROM emp
GROUP BY job, ROLLUP(deptno), CUBE(mgr);
  
-----------------------------------------------------------------------------

SELECT job, deptno, mgr, SUM(sal+ NVL(comm,0)) sal_sum
FROM emp
GROUP BY job, ROLLUP(job, deptno), cube(mgr);

ROLLUP(job,deptno) ; GROUP BY (job, deptno)
                     GROUP BY (job)
                     GROUP BY ''

CUBE(mgr)          : GROUP BY (mgr)
                     GROUP BY ''
                     
발생가능:
    GROUP BY job, (job), deptno, mgr
    GROUP BY job, (job), deptno
    GROUP BY job, mgr
--  GROUP BY job, (job), mgr
--  GROUP BY job , (job)
    GROUP BY job
    >> 결과가 6개가 나오긴 함.!!!

----------------------------------------------------------------------------------
p.41
★ 서브쿼리를 이용해 UPDATE하기(상호연관쿼리)

1. emp_test 테이블을 삭제
DROP TABLE emp_test;

2. emp테이블을 이용해 emp_test 테이블을 생성 (모든행, 모든 컬럼)

CREATE TABLE emp_test AS
SELECT *
FROM emp;


3.  emp_test테이블에 dname컬럼을 추가 (VARCHAR2(14))

ALTER TABLE emp_test ADD (dname VARCHAR2(14));

SELECT *
FROM emp_test;

DESC emp_test;

--서브쿼리 이용한 UPDATE
UPDATE emp_test et SET dname = (SELECT dname FROM dept WHERE deptno = et.deptno);

SELECT empno, ename, deptno, (SELECT dname FROM dept dt WHERE dt.deptno = et.deptno) dname
FROM emp_test et;

--실습 sub_a1 (p.44)

1. dept_TEST 테이블을 삭제
DROP TABLE dept_test;
2. dept 테이블을 이용해 dept_test 생성(모든행, 모든 컬럼)
CREATE TABLE dept_test AS
SELECT * FROM dept;
3. dept_test테이블에 empcnt 컬럼을 추가(number)
ALTER TABLE dept_test ADD (empcnt NUMBER(2)); -- DATATYPE에 괄호를 쓰지 않는다..^^

DESC dept;

4. subquery를 이용해 dept_test테이블의 empcnt컬럼을 해당 부서원 수로 UPDATE

UPDATE dept_test dt SET empcnt = (SELECT COUNT(*) FROM emp WHERE deptno = dt.deptno);

SELECT dt.*, (SELECT COUNT(*) FROM emp WHERE deptno = dt.deptno) cnt
FROM dept_test dt;


