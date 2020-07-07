--0707 햄버거 이어서 : 실무에 가까운 쿼리.

SELECT sido, sigungu,  
        ROUND((NVL(SUM(DECODE(storecategory, 'KFC', 1)),0) + NVL(SUM(DECODE(storecategory, 'MACDONALD', 1)),0) + NVL(SUM(DECODE(storecategory, 'BURGER KING', 1)),0)) / 
        NVL(SUM(DECODE(storecategory, 'LOTTERIA', 1)),1),2) dev_index
FROM burgerstore
WHERE storecategory IN ('KFC', 'BURGER KING', 'MACDONALD', 'LOTTERIA')  
GROUP BY sido, sigungu
ORDER BY dev_index DESC;

--TAX

SELECT *
FROM tax;

-- 도시발전순위(rownum), 햄버거 발전지수 시도, 햄버거발전지수 시군구, 근로소득 순위, 근로소득 시도, 근로소득 시군구, 1인당 근로소득액
SELECT ROWNUM rank, a.*
FROM(SELECT sido, sigungu,  
        ROUND((NVL(SUM(DECODE(storecategory, 'KFC', 1)),0) + NVL(SUM(DECODE(storecategory, 'MACDONALD', 1)),0) + NVL(SUM(DECODE(storecategory, 'BURGER KING', 1)),0)) / 
        NVL(SUM(DECODE(storecategory, 'LOTTERIA', 1)),1),2) dev_index
FROM burgerstore
WHERE storecategory IN ('KFC', 'BURGER KING', 'MACDONALD', 'LOTTERIA')  
GROUP BY sido, sigungu
ORDER BY dev_index DESC) a;

--tax에서 근로소득 순위

SELECT ROWNUM tax_rank, tx.*
FROM (SELECT sido, sigungu, ROUND(sal/people,2) tax_per_person
FROM tax
ORDER BY sal DESC) tx;

SELECT burger.sido, burger.sigungu, txx.tax_rank, txx.sido tax_sido, txx.sigungu tax_sigungu, tax_per_person -- *, burger.*, tax.* 로도 쓸 수 있다.
FROM (SELECT ROWNUM rank, a.*
        FROM(SELECT sido, sigungu,  
        ROUND((NVL(SUM(DECODE(storecategory, 'KFC', 1)),0) + NVL(SUM(DECODE(storecategory, 'MACDONALD', 1)),0) + NVL(SUM(DECODE(storecategory, 'BURGER KING', 1)),0)) / 
        NVL(SUM(DECODE(storecategory, 'LOTTERIA', 1)),1),2) dev_index
        FROM burgerstore
        WHERE storecategory IN ('KFC', 'BURGER KING', 'MACDONALD', 'LOTTERIA')  
        GROUP BY sido, sigungu
        ORDER BY dev_index DESC) a) burger RIGHT OUTER JOIN 
        (SELECT ROWNUM tax_rank, tx.*
        FROM (SELECT sido, sigungu, ROUND(sal/people,2) tax_per_person
        FROM tax
        ORDER BY tax_per_person DESC) tx) txx ON (burger.rank = txx.tax_rank) --인당 근로소득이 rank 기준
ORDER BY txx.tax_rank; 
        
        
-- CROSS JOIN
-- ex)

원하는 것: emp에 있는 부서번호를 이용해 dept쪽에 있는 dname, loc컬럼을 가져오는 것

SELECT e.empno, e.ename, e.deptno, d.dname, d.loc
FROM emp e, dept d; --연결하는 조건이 기술이 안돼있음. (CROSS JOIN)
emp : 14건
dept : 4건 
결과 : 56건

올바른 것: (JOIN)
SELECT e.empno, e.ename, e.deptno, d.dname, d.loc
FROM emp e, dept d
WHERE e.deptno = d.deptno;

--
CROSS JOIN : 테이블간 조인 조건을 기술하지 않은 형태로, 두 테이블간의 행간 모든 가능한 조합으로 조인이 되는 형태
             주로, 데이터 복제를 위해 사용한다. (크로스 조인 조회 결과를 필요로하는 메뉴는 거의 없음)
             * SQL의 중간 단계에서 필요한 경우는 존재
            
SELECT e.empno, e.ename, e.deptno, d.dname, d.loc
FROM emp e JOIN dept d ON (1=1); --ANSI에서는 항상 참이나오는 조건을 이용해 CROSS JOIN 만들 수 있다

--CROSSJOIN1 실습
SELECT *
FROM product;


SELECT *
FROM customer, product;

SELECT  *
FROM customer CROSS JOIN product; --(ANSI)

SELECT *
FROM product CROSS JOIN customer;

SELECT *
FROM product, customer;  -- 방향성이 있음


**서브쿼리
: SQL 내부에서 사용된 SQL = MAIN쿼리에서 사용된 쿼리
- 사용 위치에 따른 분류
1. SELECT 절 : Scalar(단일의) subquery 로 지칭
2. FROM 절 : Inline view
3. WHERE 절 : 그냥 일반 서브쿼리

- 반환하는 행, 컬럼 수에 따른 분류
1. 단일행, 단일 컬럼
2. 단일행, 복수 컬럼
3. 다중행, 단일 컬럼
4. 다중행, 복수 컬럼

-서브쿼리에서 메인쿼리의 컬럼을 사용유무에 따른 분류
1. 서브쿼리에서 메인쿼리의 컬럼 사용: (두개의 쿼리가 서로 연결된 경우) correlated subquery - 상호연관 서브쿼리
                ==>서브쿼리를 단독으로 실행 불가
2. 서브쿼리에서 메인쿼리의 컬럼 미사용: non-correlated subquery - 독자적, 단독 실행 가능

--Q. SMITH 사원이 속한 부서에 속하는 사원들은 누가 있을까?
SELECT ename, deptno
FROM emp;
두개의 쿼리가 필요
1. SMITH가 속한 부서 번호 구하기
2. 1에서 확인한 부서번호로 해당 부서에 속하는 사원들 조회

SELECT *        --SELECT~FROM : MAIN 쿼리
FROM emp
WHERE
(SELECT deptno
FROM emp
WHERE ename = 'SMITH') = deptno; --서브쿼리 결과가 상수.
--SMITH가 속한 부서 데이터 조회 > SMITH가 속한 부서가 바뀌더라도 쿼리 수정하지 않아도 됨 > 유지 보수 편함

SELECT * 
FROM emp
WHERE ename = 'SMITH';
+
SELECT *
FROM emp
WHERE deptno = 20;


---------스칼라 서브 쿼리-----------
SELECT절에서 사용된 서브 쿼리
* 제약 사항: 반드시 서브쿼리가 하나의 행, 하나의 컬럼을 반환해야한다
--스칼라 서브 쿼리가 다중행 복수 컬럼을 리턴하는 경우(X)
SELECT empno, ename, (SELECT deptno, dname FROM dept) -- 서브쿼리는 하나의 행, 하나의 컬럼이어야 한다. 앞 컬럼의 하나의 행에 붙기떄문
FROM emp;

--스칼라 서브 쿼리가 단일행 복수 컬럼을 리턴 하는 경우(X)
SELECT empno, ename, (SELECT deptno, dname FROM dept WHERE deptno =10)  -- 서브쿼리가 하나의 행/컬럼 으로 만들어 줘야 한다. 
FROM emp;

-- 두개 쓰고 싶으면 일일이 서브쿼리 써줘야 한다....왕귀찮
SELECT empno, ename, (SELECT deptno FROM dept WHERE deptno =10 ), (SELECT dname FROM dept WHERE deptno =10 ) -- 서브쿼리가 하나의 행/컬럼 으로 만들어 줘야 한다. 
FROM emp;

---- 서브쿼리가 하나의 행/컬럼 으로 만들어 줘야 한다
SELECT empno, ename, (SELECT deptno FROM dept WHERE deptno =10) subquery  
FROM emp;

-------------------------4교시..after 시험....
FOR ME.....
SQL <<<<<<<<<<<< JAVA
 :( 새해 헬스장 같은 분위기..
 이루지 못할 꿈을 잡고 있는것도 추하다.......ㅠㅠ
 ------------------------------------------
 
-- 스칼라 서브쿼리 이어서
 서브쿼리에서 메인쿼리의 컬럼을 사용유무에 따른 분류
 
 - 상호연관 서브쿼리
 SELECT empno, ename, deptno, (SELECT dname FROM dept WHERE deptno = emp.deptno) dname --한정자 붙이지 않으면 가장 가까운 컬럼 찾아간다. 
 FROM emp;
 --메인쿼리의 행에 따라 서브쿼리의 값이 바뀜. 메인 쿼리 없이 독단적으로 사용 불가. 
 -- JOIN 과 동일한 결과를 갖는다.
 
 -In-line View
 
 - Subquery  :  WHERE절에서 사용된 것
 WHERE 절에서 서브 쿼리 사용시 주의점: 연산자, 서브쿼리의 반환 행수 체크할 것.
                                    = 비교시 : 서브쿼리에서 여러개의 행(값)을 리턴하면 논리적으로 맞지 않음
                                    
SELECT *
FROM emp
WHERE deptno = (SELECT deptno
                FROM emp
                WHERE ename IN('SMITH','ALLEN')); --이렇게 할경우 deptno = (20, 30) 이기 때문에 논리적으로 맞지 않다.                                    
                                    
SELECT *
FROM emp
WHERE deptno IN (SELECT deptno
                FROM emp
                WHERE ename IN('SMITH','ALLEN'));  --이럴 경우 IN을 사용해야 한다.                                   

SELECT *
FROM emp
WHERE deptno IN (SELECT deptno, empno
                FROM emp
                WHERE ename IN('SMITH','ALLEN')); --아무리 OR로 묶여있어도 비교하고자 하는 데이터는 같아야 한다. (deptno <> empno)

                                    
"SMITH가 속한 부서의 사원들을 조회"
SELECT *
FROM emp
WHERE deptno = (SELECT deptno
                FROM emp
                WHERE ename = 'SMITH');


--평균 급여보다 높은 급여를 받는 직원의 수를 조회하세요

--SUB1
SELECT COUNT(*)
FROM emp
WHERE sal > (SELECT AVG(sal) FROM emp);

--SUB2 (P.266)
SELECT *
FROM emp
WHERE sal > (SELECT AVG(sal) FROM emp);






