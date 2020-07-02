--0702 SQL CLASS
GROUP 함수의 특징
1. NULL은 그룹함수 연산에서 제외가 된다.

--부서 번호별 사원의 sal, comm컬럼의 총 합 구하기
SELECT deptno, SUM(sal+comm), SUM(sal+NVL(comm,0)), SUM(sal) + SUM(comm) 
FROM emp
GROUP BY deptno;

★컬럼끼리의 연산에서는 NULL 연산 적용되기때문에 NVL처리 해야한다.
--sal 값이라도 보여주고 싶을때
SELECT deptno, SUM(sal) + NVL(SUM(comm),0), -- SUM 이후 NVL 적용: 아래것 보다 효율적. SUM구한 이후 NVL적용하니까.
               SUM(sal) + SUM(NVL(comm,0)) --NVL 적용이후 SUM적용. 
FROM emp
GROUP BY deptno;

--group function 실습 grp1

SELECT MAX(sal) max_sal, MIN(sal) min_sal, ROUND(AVG(sal),2) avg_sal, SUM(sal) sum_sal, COUNT(sal) count_sal,
        COUNT(mgr) count_mgr, COUNT(*)
FROM emp;

-- 실습 grp2
SELECT deptno, MAX(sal) max_sal, MIN(sal) min_sal, ROUND(AVG(sal),2) avg_sal, SUM(sal) sum_sal, COUNT(sal) count_sal,
        COUNT(mgr) count_mgr, COUNT(*)
FROM emp
GROUP BY deptno;

-- grp3

SELECT *
FROM dept;

--1. decode 사용
SELECT DECODE(deptno, 10, 'ACCOUNTING', 20, 'RESEARCH', 30, 'SALES', 40, 'OPERATTIONS') dname, MAX(sal)
FROM emp
GROUP BY deptno;

--2. decode GROUP BY에 사용: 문자열을 GROUP BY에 사용 가능하다.

SELECT DECODE(deptno, 10, 'ACCOUNTING', 20, 'RESEARCH', 30, 'SALES', 40, 'OPERATTIONS') dname, MAX(sal) max_sal, MIN(sal) min_sal, ROUND(AVG(sal),2) avg_sal, SUM(sal) sum_sal, COUNT(sal) count_sal,
        COUNT(mgr) count_mgr, COUNT(*)
FROM emp
GROUP BY DECODE(deptno, 10, 'ACCOUNTING', 20, 'RESEARCH', 30, 'SALES', 40, 'OPERATTIONS');

-- group function grp4(P.196)
SELECT TO_CHAR(TO_DATE(hiredate,'YYYY/MM/DD'),'YYYYMM') hire_YYYYMM, COUNT(*) cnt
FROM emp
GROUP BY TO_CHAR(TO_DATE(hiredate,'YYYY/MM/DD'),'YYYYMM');

-- grp5
SELECT TO_CHAR(TO_DATE(hiredate,'YYYY/MM/DD'),'YYYY') hire_YYYYMM, COUNT(*) cnt
FROM emp
GROUP BY TO_CHAR(TO_DATE(hiredate,'YYYY/MM/DD'),'YYYY');

--grp6
SELECT COUNT(*) cnt
FROM dept;

SELECT *
FROM emp;

SELECT COUNT(a) --테이블명을 count했으니 당연히 값이 안나옴...
FROM   (SELECT deptno 
        FROM emp
        GROUP BY deptno) a; 

SELECT COUNT(deptno) cnt --고로 컬럼명 / * 써야 한다...
FROM   (SELECT deptno 
        FROM emp
        GROUP BY deptno); 


SELECT COUNT(COUNT(deptno)) cnt
        FROM emp
        GROUP BY deptno;
        
SELECT *
FROM emp;

SELECT 
FROM emp
GROUP BY deptno


-- 데이터 결합 : JOIN(P.200)

JOIN : 컬럼을 확장하는 방법 (데이터를 연결)
        다른 테이블의 컬럼을 가져온다.
>> RDBMS 는 중복을 최소화하는 구조이기 때문.
    하나의 테이블에 데이터를 전부 담지 않고, 목적에 맞게 설계한 테이블에 데이터가 분산된다.
    하지만, 데이터 조회시 다른 테이블의 데이터를 연결해 컬럼을 가져올 수 있다.

문법 작성법 두가지)    
1. ANSI-SQL: American National Standard Institute
2. ORACLE-SQL 문법

JOIN: ANSI-SQL
      ORACLE-SQL의 차이가 다소 발생
      
(ANSI SQL) JOIN
NATURAL JOIN : JOIN하고자 하는 테이블간의 컬럼명이 동일할 경우, 해당 컬럼으로 행을 연결
                 컬럼명 뿐 아니라 데이터 타입도 동일 해야 한다.
문법:          
SELECT 컬럼 ...
FROM 테이블1 NATURAL JOIN 테이블2

-- emp, dept 두 테이블의 공통된 이름을 갖는 컬럼이 있을 경우 어디에서 왔는지 한정자를 써야한다
-- 단, JOIN 조건으로 쓰인 컬럼은 한정자 지정 X (ANSI-SQL에서는 에러)
-- ex) emp.empno
SELECT empno, ename, deptno, dname, loc
FROM emp NATURAL JOIN dept;

-- 위의 쿼리를 ORACLE SQL로 수정
오라클에서는 JOIN 조건을 WHERE절에 기술
행을 제한하는 조건, 조인 조건 ==> WHERE절에 기술
오라클에서는 결과행이 중복돼서 나온다.
SELECT emp.*, dname
FROM emp, dept  --콤마를 이용해 연결하려는 테이블 나열
WHERE emp.deptno = dept.deptno;

SELECT emp.*, dname
FROM emp, dept  --콤마를 이용해 연결하려는 테이블 나열
WHERE emp.deptno != dept.deptno;
-- 이럴 경우도 가능하다

ANSI-SQL : JOIN with USING 
JOIN 테이블간 동일한 이름의 컬럼이 "복수개"인데
실제 JOIN하려는 컬럼 하나를 지정해 주고 싶을 때 
A JOIN B USING (기준컬럼)

SELECT *
FROM emp JOIN dept USING (deptno);

--오라클)
SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno;

ANSI-SQL : JOIN with ON
위에서 배운 NATURAL JOIN, JOIN with USING의 경우: join테이블의 join 컬럼의 이름이 같아야 한다
                                        하지만, 설계상 두 테이블 컬럼의 이름이 다를 수 있음. 
                                        컬럼 이름이 다를 경우 개발자가 직접 JOIN조건 기술 가능하도록 하는 문법
A JOIN B ON(조건)

SELECT *
FROM emp JOIN dept ON (emp.deptno = dept.deptno);

--오라클
SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno;

ANSI-SQL : SELF-JOIN 
    동일한 테이블끼리 JOIN할 때 지칭하는 명칭(별도의 키워드가 아님)
    테이블을 별칭을 정해서 구분하도록 한다
    왜 할까? 

-- 사원번호, 사원이름, 사원의 상사 사원번호, 사원의 상사 이름을 알고 싶을때.    
SELECT e.empno, e.ename, e.mgr, m.ename mgr_name
FROM emp e JOIN emp m ON ( e.mgr = m.empno); --KING의 MGR은 없기 때문에 JOIN에 실패하여 결과에 나오지 않음

SELECT *
FROM emp e JOIN emp m ON ( e.mgr = m.empno); --KING의 MGR은 없기 때문에 JOIN에 실패하여 결과에 나오지 않음

--사원 중 사원의 번호가 7369-7698인 사원만 대상으로 해당 사원의 사원번호, 이름, 상사의 사원번호, 상사의 이름
SELECT e.empno, e.ename, e.mgr, m.ename mgr_name
FROM emp e JOIN emp m ON ( e.mgr = m.empno)
WHERE e.empno BETWEEN 7369 AND 7698;

-- ORACLE(절차지향적)
SELECT a.*, emp.ename
FROM (SELECT empno, ename, mgr
        FROM emp
        WHERE empno BETWEEN 7369 AND 7698) a, emp
WHERE a.mgr = emp.empno;

--얘를 ANSI로 표현
SELECT a.*, emp.ename
FROM (SELECT empno, ename, mgr
        FROM emp
        WHERE empno BETWEEN 7369 AND 7698) a JOIN emp ON (a.mgr = emp.empno);

-- NON-EQUI-JOIN: 조인 조건이 =이 아닌 조인
 !=  값이 다를때 연결
 
SELECT empno, ename, sal, grade
FROM emp, salgrade
WHERE sal BETWEEN losal AND hisal;
 
SELECT *
FROM salgrade;
--salgrade 에는 시작값과 끝값만 있고 행들끼리 연결돼 있다(선분 데이터 이력)

--실습 join 0
SELECT empno, ename, emp.deptno, dname
FROM emp, dept
WHERE emp.deptno = dept.deptno;

SELECT empno, ename, deptno, dname
FROM emp NATURAL JOIN dept;

--실습 join0_1
SELECT empno, ename, deptno, dname
FROM emp NATURAL JOIN dept
WHERE deptno = 10 OR deptno = 30;

SELECT empno, ename, emp.deptno, dname
FROM emp, dept
WHERE emp.deptno = dept.deptno
AND (dept.deptno = 10 OR dept.deptno = 30); -- AND연산자가 먼저 수행되기 때문에 OR 괄호 처리 해야한다





