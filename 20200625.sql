-- 0625 수업

SELECT *
FROM prod;

SELECT prod_id, prod_name
FROM prod;

-- expressio: 컬럼값을 가공, 존재하지 않는 새로운 상수값을 표현.
-- 연산을 하더라도 해당 SQL 조회 결과에만 나올 뿐! 실제 테이블의 데이터에는 영향을 주지 않는다(왜냐하면 SELECT 구문이기 때문)
SELECT sal, sal+500, sal-500, sal/5, sal*5, 500
FROM emp;

SELECT *
FROM dept;

SELECT hiredate, hiredate + 5, hiredate -5 
FROM emp;

--테이블의 컬럼구성 정보확인 : DESC(DESCRIBE) 테이블명
DESC emp;

--users 테이블의 컬럼 타입을 확인하고 reg_dt 컬럼 값에 5일 뒤 날짜를 새로운 컬럼으로 표현 해보기
-- 조회컬럼: userid, reg_dt, reg_dt 의 5일 뒤 날짜

DESC users;

SELECT userid, reg_dt, reg_dt+5
FROM users; 

--null
--emp 테이블에서 sal 컬럼과 comm 컬럼의 합을 새로운 컬럼으로 표현
-- 조회되는 컬럼: empno, ename, sal, comm, 새로운 컬럼(expression)
-- 컬럼 명을 새로 부여하고 싶으면 뒤에 AS(alias) 쓰고 새로명칭 쓰면 된다 | 그냥 컬럼명 뒤에 바로 새로운명칭 써도 됨
-- 컬럼, expression [AS] 별칭명 
-- "새로운 별칭" 하면 소문자, space 표기 가능. 원래 ORACLE 디폴트는 대문자

SELECT empno, ename, sal, comm commition, sal + comm AS "sal plus_comm"
FROM emp;

-- SELECT 2

SELECT prod_id AS "id", prod_name AS "name"
FROM prod;

SELECT lprod_gu AS "gu", lprod_nm AS "nm"
FROM lprod;

SELECT buyer_id 바이어아이디, buyer_name AS 이름
FROM buyer;

--users 테이블의 userid 컬럼과 username 컬럼을 결합 (|| 연산자)
-- | sql에서 문자열 결합 함수: CONCAT(문자열1, 문자열2) == 문자열1||문자열2

SELECT userid, usernm, userid || usernm id_name, CONCAT(userid, usernm) concat_id_name
FROM users;

SELECT userid, usernm, userid || usernm
FROM users;

SELECT userid, usernm, CONCAT(userid, usernm)
FROM users;

-- 임의 문자열결합도 가능 ( sal+500, '아이디 :' || userid)
SELECT '아이디:' || userid || '안녕', 500, 'test'
FROM users;

SELECT '아이디:' || userid 
FROM users;

--내가 갖고있는 table (user_tables)
SELECT 'SELECT * FROM ' || TABLE_NAME || ';' query
FROM user_tables;

SELECT CONCAT('SELECT * FROM ' || TABLE_NAME, ';') AS query
FROM user_tables;

SELECT CONCAT(CONCAT('SELECT * FROM ', TABLE_NAME), ';') AS query
FROM user_tables;

--WHERE : 테이블에서 조회할 행의 조건을 기술

SELECT *
FROM users
WHERE userid = 'brown';

--emp 테이블에서 deptno 컬럼의 값이 30보다 크거나 같은 행을 조회, 컬럼은 모든 컬럼

SELECT *
FROM emp
WHERE deptno >= 30;

-- emp table 총 행수 14개
-- WHERE 조건문이 참인지 거짓인지만 판단하면 된다. 
SELECT *
FROM emp
WHERE 1 = 1; 

-- SQL에서 날짜는 2020년 06월 25일은 '20/06/25' 로 표기 (서버 설정마다 표기법 다름)
-- 미국: mm/dd/yy
-- 그래서 date 리터럴 보다는 문자열을 date 타입으로 변경해주는 함수를 주로 사용
-- TO_DATE('날짜문자열', '첫번째 인자의 형식')
-- 문제) emp 테이블에서 hiredate 값이 1982년 1월 1일 이후인 사원들만 조회

-- date 리터럴 표기법으로 실행한 sql
SELECT * 
FROM emp
WHERE hiredate >= '82/01/01';
-- TO_DATE 함수를 통해 문자열을 DATE 타입으로 변경후 실행
SELECT * 
FROM emp
WHERE hiredate >= TO_DATE('1982/01/01', 'YYYY/MM/DD');

-- ORACLE DB 기본 설정
SELECT *
FROM NLS_SESSION_PARAMETERS;

-- BETWEEN AND : 두 값 사이에 위치한 값을 참으로 인식. 비교값 BETWEEN 시작값 AND 종료값
-- 비교값이 시작값과 종료값을 포함하여 사이에 있으면 참으로 인식
-- 문제) emp 테이블에서 sal 값이 1000 보다 크거나 같고 2000보다 작거나 같은 사원들만 조회

SELECT *
FROM emp
WHERE sal BETWEEN 1000 AND 2000;

SELECT *
FROM emp
WHERE sal >= 1000 
  AND sal <= 2000;

-- 실습 where1
SELECT ename, hiredate
FROM emp
WHERE hiredate BETWEEN TO_DATE('1982/01/01','RRRR/MM/DD') AND TO_DATE('1983/01/01','RRRR/MM/DD');

-- 실습 where2 (부등호 이용하기)
SELECT ename, hiredate
FROM emp
WHERE hiredate >= TO_DATE('1982/01/01','RRRR/MM/DD') 
  AND hiredate <= TO_DATE('1983/01/01','RRRR/MM/DD');

-- IN 연산자 : 비교값이 나열된 값에 포함될 때 참으로 인식
-- 사용 방법: 비교컬럼 IN (비교대상 값, 비교대상2, 비교대상 값3, ....) 
-- 문제) 사원의 소속 부서가 10번 혹은 20번인 사원을 조회하는 SQL을 IN 연산자로 작성
    
SELECT *
FROM emp
WHERE deptno IN (20, 30);
  
--위와 동일한 SQL
SELECT *
FROM emp
WHERE deptno = 10
  OR deptno = 20;
  
  