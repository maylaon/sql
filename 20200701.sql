-- 0701 CLASS (p. 171 -197)
DECODE : 조건에 따라 반환값이 달라지는 함수
        ==> 비교, JAVA(=IF), SQL CASE와 비슷.
        단, 비교 연산이 (=) 만 가능
        CASE의 WHEN절에 기술할 수 있는 코드는 참/거짓 판단할 수 있는 코드면 가능
        ex) sal > 1000 
        이것과 다르게 DECODE 함수에서는 sal = 1000, sal = 2000 equal 비교만 가능
        
DECODE는 가변인자(인자의 갯수가 정해지지 않음. 상황에 따라 늘어날수도 있음)를 갖는 함수
문법 : DECODE(기준값[컬럼|expression], 비교값1, 반환값1, 비교값2, 반환값2, ..., 옵션[default])
        기준값 = 비교값 이면 반환값 출력.
        
      ==> java 
      if ( 기준값 == 비교값1)
      System.out.print(반환값1)
      else if ( 기준값 == 비교값2)
      System.out.print(반환값2)
      ....
      else
      System.out.print(default)
      
--CASE 와 DECODE 비교

SELECT empno, ename, 
    CASE
        WHEN deptno = 10 THEN 'ACCOUNTING'
        WHEN deptno = 20 THEN 'RESEARCH'
        WHEN deptno = 30 THEN 'SALES'
        WHEN deptno = 40 THEN 'OPERATIONS'
        ELSE 'DDIT'
    END AS dname
FROM emp;      
      
--
SELECT empno, ename, deptno,
    DECODE(deptno, 10, 'ACCOUNTING', 20, 'RESEARCH', 30, 'SALES', 40, 'OPERTAIONS', 'DDIT') AS dname
FROM emp;

--
SELECT ename, job, sal, DECODE(job, 'SALESMAN', sal*1.05,  'MANAGER', sal*1.10, 'PRESIDENT', sal*1.20, sal*1) bonus
FROM emp;

--
위의 문제 처럼 job에 따라 sal를 인상을 한다. 단, 추가 조건으로 manager이면서 소속부서(deptno)가 30(sales)이면 
sal*1.5
1) CASE

SELECT *
FROM emp;

SELECT ename, sal, deptno, job,
   CASE        
        WHEN job = 'SALESMAN' THEN sal * 1.05
        WHEN job = 'MANAGER' AND deptno = 30 THEN sal*1.5
        WHEN job = 'MANAGER' THEN sal*1.1
        WHEN job = 'PRESIDENT' THEN sal * 1.20
        ELSE  sal
   END AS inc_sal
FROM emp;
--왜 순서를 바꾸면 안될까...?
-- if 처리되는 순서를 생각하자! a-b 순이면, a가 아니면 b는 건너뛰므로
--즉, 아래의 식에선 
SELECT ename, sal, deptno, job,
   CASE        
        WHEN job = 'SALESMAN' THEN sal * 1.05
        WHEN job = 'MANAGER' THEN sal*1.1
        WHEN job = 'MANAGER' AND deptno = 30 THEN sal*1.5 -- 이것이 실행 X
        WHEN job = 'PRESIDENT' THEN sal * 1.20
        ELSE  sal
   END AS inc_sal
FROM emp;

SELECT ename, sal, deptno, job,
   CASE        
        WHEN job = 'SALESMAN' THEN sal * 1.05
        WHEN job = 'MANAGER' THEN CASE WHEN deptno = 30 THEN sal*1.5 ELSE sal*1.1 END      
        WHEN job = 'PRESIDENT' THEN sal * 1.20
        ELSE  sal
   END AS inc_sal
FROM emp;

SELECT ename, sal, job, 
    DECODE(job, 'SALESMAN', sal*1.05, 'MANAGER', DECODE(deptno, 30, sal*1.5, sal*1.1),'PRESIDENT', sal*1.2,sal) inc_sal
    FROM emp;

--CONDITION 실습 cond2


SELECT empno, ename, hiredate, 
    CASE
        WHEN MOD(TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')),2) = MOD(TO_NUMBER(TO_CHAR(hiredate,'YYYY')),2)
            THEN '건강검진 대상자'
            ELSE '건강검진 비대상자'
            END contact_to_doctor
FROM emp;


-- cond3

SELECT userid, usernm, reg_dt, 
    DECODE(MOD(TO_CHAR(reg_dt,'YYYY'),2), NULL, '값을 입력하세요', MOD(TO_CHAR(SYSDATE,'YYYY'),2), '건강검진 대상자', '건강검진 비대상자') contactodoctor
FROM users;

-- GROUP함수
GROUP FUNCTION
: 여러 행을 입력으로 받아 하나의 행으로 결과를 리턴하는 함수
1. SUM : 그룹 합계
2. COUNT : 행의 수
3. AVG : 그룹 평균
4. MAX : 그룹에서 가장 큰 값
5. MIN : 그룹에서 가장 작은 값

사용법: WHERE 절 다음에 온다 
SELECT 행들을 묶을 기준1, [행들을 묶을 기준2], 그룹함수
FROM 테이블명
[WHERE]
GROUP BY 행들을 묶을 기준1, [행들을 묶을 기준2, ...]

-- 부서 번호별 SAL 컬럼의 합 ==> 부서번호가 같은 행들을 하나의 행으로 만든다 
SELECT deptno, SUM(sal)
FROM emp
GROUP BY deptno;

--부서 번호별 가장 큰 급여를 받는 사람의 급여액수
SELECT deptno, SUM(sal), MAX(sal)
FROM emp
GROUP BY deptno;


--부서 번호별 가장 작은 급여를 받는 사람의 급여액수, 급여 평균
SELECT deptno, SUM(sal), MAX(sal), MIN(sal), ROUND(AVG(sal),2), COUNT(sal), COUNT(comm), COUNT(*)
FROM emp
GROUP BY deptno
ORDER BY deptno;

--COUNT 함수: COUNT(*) 해도 된다.
COUNT(컬럼) 했을 경우: 값이 존재하는 행의 수(컬럼 값이 null이 아닌 행의 수) 전체 행의 수 - null값 있는 행의 수
COUNT(*) : 그 그룹의 전체 행 수( null값 까지 다 포함한 행의 수. ) : 일반적으로 얘를 많이 씀.

--
그룹함수의 특징: 
1) NULL값을 무시 => null있는 행들 sum 해도 null이 아니라 null 무시하고 나머지 값 더함
    ex) 30번 부서의 사원 6명 중 2명은 comm값이 NULL.
2) GROUP BY 여러행을 하나의 행으로 묶게 되면 SELECT절에 기술할 수 있는 컬럼 제한됨
    ==> SELECT절에 기술되는 일반 컬럼들(그룹함수 적용하지 않은)은 반드시 GROUP BY절에 기술 되어야 한다. 
    ==> 단, GROUPING에 영향을 주지 않는 상수값의 컬럼은 SELECT절에 단독으로 기술 가능
    
SELECT deptno, 10, SYSDATE, SUM(sal)
FROM emp
WHERE deptno = 10
GROUP BY deptno;

3) 일반 함수를 WHERE절에서 사용하는 것이 가능. ex) WHERE UPPER('smith') = 'SMITH';
    그룹함수의 경우 WHERE절에서 사용하는게 불가능
    하지만 HAVING 절에 기술하여 동일한 결과를 나타낼 수 있다.
    HAVING 절은 GROUP BY 뒤에 기술
    
 SELECT deptno, SUM(sal)
 FROM emp
 GROUP BY deptno
 HAVING SUM(sal) > 9000;

위의 쿼리를 HAVING절 없이 SQL작성하기
SELECT *
FROM (SELECT deptno, a.*)
    FROM(SELECT SUM(sal)
        FROM emp
        GROUP BY deptno) a)
WHERE  a >= 9000;

-- inline view를 이용하면 SUM함수 컬럼에 별칭을 부여할 수 있으므로 이를 이용해 WHERE로 표현할 수 있다.
-- 다시 이해 필요!
-- where절은 from 다음 에 위치하기 떄문에 위에서 테이블/컬럼 지정해서 조건 줄 수 있다
SELECT *
FROM (SELECT deptno, SUM(sal) sum_sal
        FROM emp
        GROUP BY deptno)
WHERE sum_sal > 9000;

문법 총 정리
SELECT
FROM
WHERE
GROUP BY
HAVING
ORDER BY

GROUP BY절에 행을 그룹핑할 기준을 작성
ex) 부서번호별로 그룹을 만들경우 : GROUP BY deptno
Q. 전체행을 기준으로 그룹핑을 하려면 GROUP BY 절에 어떤 컬럼을 기술해야 할까?
- emp테이블에 등록된 14명 사원 전체의 급여 합계를 구하려면? ==> 결과는 1개의 행 : group by를 기술하지 않으면 됨

SELECT SUM(sal)
FROM emp;

Q. GROUP BY절에 기술한 컬럼을 SELECT절에 기술하지 않은 경우
A. SELECT절은 결과로 나타낼 행을 지정하는 것이기 때문에 GROUP BY에 의해 그룹핑이 좌우되므로 결과는 나온다.

그룹함수의 제한 사항 : 
부서번호별 가장 높은 급여를 받는 사람의 급여액은 나타낼 수 있지만 그게 누군지는 모름
(추후에 서브쿼리, 분석함수를 통해 누구를 알 수 있다.)
SELECT deptno, MAX(sal)
FROM emp
GROUP BY deptno;