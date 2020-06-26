 WHERE 절에서 사용 가능한 연산자 : LIKE
 사용 용도 : 문자의 일부분으로 검색을 하고 싶을때 사용
  ex) ename 컬럼의 값이 s로 시작하는 사원들을 조회
 사용 방법: 컬럼 LIKE '패턴문자열'
 마스킹 문자열: 1. % : 문자가 없거나, 어떤 문자든지 여러개의 문자열 
                 ex) 'S%' : S로 시작하는 모든 문자열을 나타내줌. S, SS, SMITH, S...
              2. _ :  어떤 문자든 딱 하나의 문자를 의미 
                  ex) 'S_' : S로 시작하고, 두번째 문자가 어떤 문자든 하나의 문자가 오는 두자리 문자열 SO, SE, SL, ...
                     'S____' : SAMPLE, SINGLE, ....
  
 emp테이블에서 ename컬럼의 값이 S로 시작하는 사원들만 조회
 SELECT *
 FROM emp
 WHERE ename LIKE 'S%';
 
실습 where4
SELECT mem_id, mem_name
FROM member
WHERE mem_name LIKE '신%';

실습 where5
SELECT mem_id, mem_name
FROM member
WHERE mem_name LIKE '%이%';

-- b001 : 이쁜이 
UPDATE member SET mem_name = '신이환'
WHERE mem_id = 'c001';

--NULL비교
NULL 비교 : 연산자로 비교X -> IS 로 비교. 컬럼 IS NULL

SELECT empno, ename, comm
FROM emp
WHERE comm IS NULL;

--where6 
emp 테이블에서 comm값이 NULL이 아닌 데이터를 조회
SELECT empno, ename, comm
FROM emp
WHERE comm IS NOT NULL;

--
논리연산자 : AND, OR,  NOT (PPT p.91)

p.92
SELECT *
FROM emp
WHERE mgr = 7698
 AND sal > 1000;

SELECT *
FROM emp
WHERE mgr = 7698
   OR sal > 1000;

--P.93
NOT : 조건을 반대로 해석하는 부정형 연산
      NOT IN 
      IS NOT NULL

emp테이블에서 mgr가 7698, 7839가 아닌 사원들을 조회

SELECT *
FROM emp
WHERE mgr NOT IN (7698, 7839); --NULL값은 비교연산으로 비교X
-- mgr 컬럼에 NULL값이 있을 경우 NULL을 갖는 행은 무시된다.

--mgr 사번이 7698, 7839, NULL이 아닌 직원들을 조회
SELECT *
FROM emp
WHERE mgr NOT IN (7698, 7839, NULL); -- 결과 안나옴 NULL값 때문.

SELECT *
FROM emp
WHERE mgr NOT IN (7698, 7839) 
   OR mgr IS NULL;

SELECT *
FROM emp
WHERE mgr != 7698
   OR mgr != 7839;

--where7
SELECT *
FROM emp
WHERE job = 'SALESMAN' 
  AND hiredate >= TO_DATE('81/06/01','RR/MM/DD');
--where8 (p.95)
SELECT *
FROM emp
WHERE deptno != 10
  AND hiredate >= TO_DATE('81/06/01','RR/MM/DD');
--DEPT 테이블에서 deptno 관리한다

--where9
SELECT *
FROM emp
WHERE deptno NOT IN (10); --NOT IN ( X) 꼭 복수 아니어도 됨

--where 10(p.97)
SELECT *
FROM emp
WHERE deptno IN (20, 30)
  AND hiredate >= TO_DATE('81/06/01','RR/MM/DD');
  
--where 11(p.98)
SELECT *
FROM emp
WHERE job = 'SALESMAN'
  OR hiredate >= TO_DATE('81/06/01','RR/MM/DD');
  
--where 12(p.99)
emp 테이블에서 job이 SALESMAN이거나 사원번호가 78로 시작하는
직원의 정보를 조회하시오.
SELECT *
FROM emp
WHERE job = 'SALESMAN'
  OR empno LIKE '78%';  --결과 자동 형변환 숫자 > 문자

--where 13(p.100)
SELECT *
FROM emp
WHERE job = 'SALESMAN'
   OR empno BETWEEN 7800 AND 7899
   OR empno BETWEEN 780 AND 789
   OR empno = 78;

-- where14(p.104)
SELECT *
FROM emp
WHERE job = 'SALESMAN' 
   OR ((empno BETWEEN 7800 AND 7899) AND hiredate >= TO_DATE('81/06/01','RR/MM/DD'));
   
--데이터정렬(P.105)
RDBMS : 집합적인 사상을 따른다
집합 특징: 순서, 중복 값이 없다
데이터 정렬 방법 : ORDER BY (WHERE절 다음에 위치)를 통해 정렬 기준 컬럼을 명시
                컬럼 뒤에 ASC | DESC 을 기술해 오름차순/내림차순 지정 가능
        1. ORDER BY 컬럼
        2. ORDER BY ALIAS
        3. ORDER BY 컬럼인덱스번호

SELECT *
FROM emp
ORDER BY ename;

SELECT *
FROM emp
ORDER BY ename desc;

-- 정렬기준 : ename이지만 ename 동일할 경우 mgr 기준으로 정렬
-- ASC(오름차순) 기본
SELECT *
FROM emp
ORDER BY ename desc, mgr;

--별칭으로 ORDER BY
SELECT empno, ename, sal, sal*12 salary
FROM emp
ORDER BY salary;
-- 컬럼순서로 ORDER BY
SELECT empno, ename, sal, sal*12 salary
FROM emp
ORDER BY 4;

--orderby1 (p.109)
SELECT *
FROM dept
ORDER BY dname;

SELECT *
FROM dept
ORDER BY loc DESC;

--orderby2 (p.110)
SELECT *
FROM emp
WHERE comm > 0 --이렇게 하면 굳이 null 신경 안써도 된다!!! 바보 
ORDER BY comm DESC, empno DESC;

DESC emp;