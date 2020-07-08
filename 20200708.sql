--0708 CLASS
지난 수업들

sub2 (p.266)
SELECT *
FROM emp
WHERE sal > (SELECT AVG(sal)  --비상호 연관 서브쿼리
                FROM emp);
                
Q. 사원이 속한 부서의 급여 평균보다 높은 급여를 받는 사원 정보 조회
   
 --정답 
  SELECT *
  FROM emp e
  WHERE sal > (SELECT AVG(sal)
                FROM emp s   -- FROM 에서 ALIAS지정해서 구분할 수 있다.!!
                WHERE s.deptno = e.deptno); 
 
 --내가 생각했던 것...
 -- 난 너무 어렵게 생각함.. group by하고, 한정자 지정을 FROM에서 하지 않고 전체 테이블로 만들어서 하려고 했다.
 SELECT *   
 FROM emp 
 WHERE sal >   ( SELECT avg
                FROM(SELECT deptno, AVG(sal) avg
                FROM emp
                GROUP BY deptno) a
                WHERE a.deptno = emp.deptno);
   
 
 
 SELECT *   
 FROM emp 
 WHERE sal >  SELECT AVG(sal)
                FROM emp a
                GROUP BY deptno
                WHERE a.deptno = emp.deptno;
  
  
Q.전체사원의 정보를 조회, 조인 없이 해당 사원이 속한 부서의 이름 
  SELECT empno, ename, deptno, (SELECT dname FROM dept WHERE deptno = emp.deptno)
  FROM emp;


Q. SMITH와 WARD사원이 속한 부서의 모든 사원 정보를 조회하는 쿼리 작성(sub3)
SELECT *
FROM emp 
WHERE deptno IN (SELECT deptno 
                   FROM emp
                   WHERE ename = 'SMITH' OR ename = 'WARD'); --단일 값 비교는 = 로 비교가능하지만, 복수행 비교는 당연 in비교
                   
                   
                   
--P.272
NULL 과 IN, NULL과 NOT IN
NOT IN ==> AND

SELECT *
FROM emp
WHERE mgr IN (7902, null);
==> mgr = 7902 OR mgr = null
==> mgr = 7902 OR [mgr = null] : 데이터가 나오기는 함. OR이기 때문에 mgr=7902만 나옴. mgr=null인 값은 안나옴. NULL은 IS로 비교

SELECT *
FROM emp
WHERE mgr = 7902
OR mgr IS NULL;  -- 이렇게 써줘야 한다.

---NOT IN
SELECT *
FROM emp
WHERE mgr NOT IN (7902, null);   --NOT IN 안에 NULL이 있을땐 값이 안나옴.!
==> mgr != 7902 AND mgr != null

SELECT *
FROM emp
WHERE mgr != 7902
AND mgr IS NOT null;

** IN, NOT IN 이용시 NULL값의 존재 유무에 따라 원하지 않는 결과가 나올 수도 있다.

---------------------------------------------------------------------------
PAIRWISE, non-pairwise

한행의 컬럼 값을 하나씩 비교하는 것: non-pairwise  = 지금까지 한것..
SELECT *
FROM emp
WHERE job IN ('MANAGER', 'CLERK');

한행의 복수 컬럼을 비교 하는 것 : pairwise
여러개의 컬럼을 동시에 만족하는가

 (PAIRWISE)
SELECT *
FROM emp
WHERE (mgr, deptno) IN (SELECT mgr, deptno
                        FROM emp
                        WHERE empno IN (7499, 7782));

(NON-PAIRWISE)
SELECT *
FROM emp
WHERE mgr IN (SELECT mgr
              FROM emp
              WHERE empno IN (7499,7782))
AND deptno IN (SELECT deptno
                FROM emp
                WHERE empno IN (7499, 7782));  
        
***결과가 다를 수도 있다.
PAIRWISE는 (7698,30) (7839,10)인 애들만 조회 (경우의 수 제한)
NON-PAIRWISE는 경우의 수가 많아짐 (인자수1 x 인자수2) 경우의 수가 나옴.
7698    30
7839    10 으로 인식해서
(7698,10) (7839,30) 인 경우가 나올 수 있음.


----------------------------------------------------------------------------

서브쿼리 실행 순서
상호 연관 서브 쿼리: sub쿼리가 main쿼리를 참조하기 때문에 main쿼리 먼저 실행 된다.

--실습sub4
INSERT INTO dept VALUES (99, 'ddit', 'daejeon');
Q. dept테이블에는 신규 등록된 99번 부서에 속한 사람이 없다.
    직원이 속하지 않은 부서를 조회하는 쿼리를 작성해 보세요.

--처음 한 생각
SELECT dept.deptno, dept.dname, dept.loc
FROM dept LEFT OUTER JOIN emp ON(dept.deptno = emp.deptno)
WHERE emp.empno IS NULL;

-- 서브쿼리 이용해 본 생각..
SELECT deptno, dname, loc
FROM dept
WHERE deptno NOT IN (SELECT deptno
                    FROM emp    
                    --WHERE dept.deptno = emp.deptno);  --WHERE절 굳이 안써도 된다. 어차피 EMP에서 가져오는 값이니까!!!
                    
--Sub5

SELECT *
FROM cycle;

SELECT *
FROM product
WHERE pid NOT IN (SELECT *
                  FROM cycle
                  WHERE cid =1);

--Sub6
SELECT *
FROM cycle
WHERE ;

SELECT *
FROM cycle
WHERE pid IN (SELECT pid FROM cycle WHERE cid =1);
AND pid IN (SELECT pid FROM cycle WHERE cid =2);

SELECT *
FROM cycle
WHERE(SELECT pid
FROM cycle
WHERE cid =1) IN (SELECT pid FROM cycle WHERE cid = 2 );

SELECT pid
FROM cycle
WHERE cid =2;


SELECT *
FROM cycle;



SELECT *
FROM cycle
WHERE pid 
(SELECT pid
FROM cycle
WHERE pid IN (SELECT pid
                  FROM cycle
                  WHERE cid =2);
                  
(SELECT *
FROM cycle
WHERE pid IN (SELECT pid
                  FROM cycle
                  WHERE cid =1));

SELECT *
FROM cycle
WHERE (pid, deptno) IN (SELECT mgr, deptno
                        FROM emp
                        WHERE empno IN (7499, 7782));



SELECT *
FROM customer;

SELECT *
FROM product;

SELECT *
FROM (SELECT * FROM cycle WHERE cid = 1) a
WHERE a.pid IN (SELECT pid FROM cycle WHERE cid =2);

SELECT *
FROM cycle
WHERE cid =1;



























