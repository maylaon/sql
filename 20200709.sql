--0708 과제
--sub 6


SELECT *
FROM (SELECT * FROM cycle WHERE cid = 1) a
WHERE a.pid IN (SELECT pid FROM cycle WHERE cid =2);



--0709 SQL CLASS

-- SUB6 (P.283)

쌤)
SELECT *
FROM cycle
WHERE cid = 1
AND pid IN (SELECT pid FROM cycle WHERE cid =2);

-- sub7
Q. CUSTOEMR, CYCLE, PRODUCT 테이블 이용해, CID=1 인 고객이 애음하는 제품 중 CID=2인 고객도 애음하는 제품의
애음정보를 조회하고 고객명과 제품명까지 포함하는 쿼리를 작성해 보세요.


SELECT cid, cnm, pid, pnm, day, cnt
FROM (SELECT * FROM cycle WHERE cid = 1 AND pid IN (SELECT pid FROM cycle WHERE cid = 2)) NATURAL JOIN product NATURAL JOIN customer;


SELECT *
FROM product;

SELECT *
FROM customer;

SELECT * 
FROM (SELECT * FROM cycle WHERE cid = 1 AND pid IN (SELECT pid FROM cycle WHERE cid = 2)), product, customer;

SELECT cid, cnm, pid, pnm, day, cnt
FROM cycle NATURAL JOIN product NATURAL JOIN customer
WHERE cid = 1;  -- cid=1 인 애만 나옴



--p.285
EXISTS 연산자 :  서브쿼리에서 반환하는 행이 존재하는지 체크하는 연산자. 
                반환하는 행이 하나라도 존재하면 TRUE, 존재하지 않으면 FALSE
                EXISTS (서브쿼리)
       특 징 : 1. WHERE 절에서 사용
               2. MAIN 테이블의 컬럼이 항으로 사용 X
               3. 주로 상호 연관 서브쿼리[확인자]와 사용된다.
               4. 서브쿼리의 컬럼 값은 중요하지 않다. (SELECT 'X')로 표기
                 ==> 서브쿼리의 행이 존재하는지만 체크
                  
               
cf) IN 연산자 :
    컬럼 IN (서브쿼리, 값을 나열하거나)

EXISTS (서브쿼리)
1. 아래 쿼리에서 서브쿼리는 단독으로 실행 가능
 ==> 서브쿼리의 실행 결과가 메인쿼리의 행 값과 관계없이 항상 실행 되고
    반환되는 행의 수는 1개의 행이다. 
    
SELECT *
FROM emp
WHERE EXISTS (SELECT 'X'
                FROM dual);  ==> 의미가 사실 없음. 결과가 all or nothing 이기 때문..

일반적으로 EXISTS 연산자는 상호 연관 서브쿼리에서 사용 된다.

1. 사원 정보를 조회하는데
2. 서브쿼리 조건을 만족하는 사원만 조회
 
SELECT *
FROM emp e
WHERE EXISTS (SELECT 'X'   -- 일반적으로 EXISTS 연산자에서는 SELECT절 'X'로 쓴다. 의미X
                FROM emp m
                WHERE m.empno = e.mgr);
==> mgr정보가 존재하는 사원 조회
==> 상호연관 커리 EXISTS 연산 사용은 "서브쿼리가 [확인자]로 사용 되었다" 고 표현 한다.
==> 비상호 연관의 경우, 서브쿼리가 먼저 실행될 수도 있다 ("서브쿼리가 [제공자]로 사용되었다.")

--SUB8
매니저가 존재하는 직원 조회(EXISTS 사용X)

SELECT * 
FROM emp
WHERE mgr IS NOT NULL;

SELECT *
FROM emp e JOIN emp m ON (e.mgr = m.empno);

--SUB9
SELECT *
FROM product
WHERE EXISTS (SELECT 'X' 
                FROM cycle 
                WHERE cid=1 AND cycle.pid = product.pid);

--EXISTS 안쓴 기존 배운 대로 하면..
SELECT pid, pnm
FROM cycle NATURAL JOIN product
WHERE cid = 1
GROUP BY pid, pnm;

--SUB9번을 IN 연산자를 사용해서 풀기
SELECT *
FROM product
WHERE pid IN (SELECT pid
               FROM cycle
               WHERE cid = 1);
               
--sub10
SELECT *
FROM product
WHERE NOT EXISTS(SELECT 'X' FROM cycle WHERE cid=1 AND cycle.pid = product.pid);


--p.289
집합연산
sql에서 데이터를 확장하는 방법(행 확장) 
cf) join (컬럼 확장)

집합의 개념과 동일.. 순서, 중복X

집합 연산을 하기 위해서는 연산에 참여하는 두개의 SQL(집합)이 동일한 컬럼 개수와 타입을 가져야 한다. (행 확장 하는거니까)

SQL에서 제공하는 집합 연산자
1. UNION : 두 집합에 속하는 요소는 한번만 표현 됨
2. UNION ALL : 중복을 제거하지 않음 -> UNION보다 빠른 처리 속도. 걍 물리적으로 위 아래행 붙이는 것
    ==>개발자가 두 집합의 중복이 없다는 것을 알고 있으면 UNION ALL쓰는 것이 효율적.
3. INTERSECT
4. MINUS(차집합) : 당근 교환법칙 성립 X => 순서 생각 잘 해야한다.

교환 법칙 : 항의 위치를 수정해도 결과가 동일한 연산

--UNION 연산자 예시
SELECT empno, ename
FROM emp
WHERE empno IN (7566, 7698)

UNION

SELECT empno, ename
FROM emp
WHERE empno IN (7566, 7698);

--INTERSECT/MINUS 연산자 예시
SELECT empno, ename
FROM emp
WHERE empno IN (7369, 7566, 7499)
MINUS
SELECT empno, ename
FROM emp
WHERE empno IN (7566,7698);

--★★★특징:
1. 컬럼명이 동일하지 않아도 됨. 
  => 단 조회 결과는 첫번째 집합의 컬럼을 따른다!
2. 정렬이 필요한 경우, 마지막 집합 뒤에다 기술해준다!!
3. UNION ALL 제외한 나머지 연산은 중복 제거 작업이 들어간다.

SELECT empno, ename
FROM emp
WHERE empno IN (7369, 7566, 7499)
MINUS
SELECT empno e, ename enm
FROM emp
WHERE empno IN (7566,7698)
ORDER BY ename;

---------------------------------------------------------------------SELECT 끝
P.300
☆DML(INSERT)☆ : 테이블에 데이터를 입력하는 SQL문장
1. 어떤 테이블에 데이터를 입력할지 테이블을 정한다
2. 해당 테이블의 어떤 컬럼에 어떤 값을 입력할지 정한다.

INSERT INTO table [(column, [, column2, column3,...])]
VALUES (value1, [, value2, value3,...]);

dept테이블에 99번 부서번호를 갖는 ddit를 부서명으로 daejeon 지역에 위치하는 부서를 등록
INSERT INTO dept (deptno, dname, loc)
VALUES (99, 'ddit', 'daejeon');

컬럼 명을 나열할 때, 테이블 정의에 따른 컬럼 순서를 반드시 따를 필요는 없다.
다만, VALUES 절에 기술한 해당 컬럼에 입력할 값의 위치만 지켜주면 된다.
만약 테이블의 모든 컬럼에 대해 값을 입력하고자 할 때는 컬럼을 나열하지 않아도 되지만, VALUES 절에 입력할 기술 순서가 컬럼 순서와 동일해야함.

DESC dept;

INSERT INTO dept
VALUES (98, 'ddit2', '대전');

SELECT *
FROM dept;

모든 컬럼에 값을 입력하지 않을 수도 있다.
단, 해당 컬럼이 NOT NULL 제약 조건이 걸려 있는 경우는 컬럼에 반드시 값이 들어가야 한다.

DESC emp;

INSERT INTO emp (ename, job)
VALUES ('brown', 'RANGER'); --실행이 되지 않는다!!!

오류 구문:
ORA-01400: cannot insert NULL into ("JINNY"."EMP"."EMPNO") = "empno에는 널값을 넣을 수 없다"
emp의 empno는 not null 제약 조건이 있음.

--data타입에 대한 insert
emp 테이블에 sally 사원을 오늘 날짜로 신규 데이터 입력, job = RANGER, empno = 9998
INSERT INTO emp (empno, ename, hiredate, job)
VALUES (9998, 'sally', SYSDATE, 'RANGER');

INSERT INTO emp (empno, ename, hiredate, job)
VALUES (9997, 'moon', TO_DATE('2020/07/07','YYYY/MM/DD'), 'RANGER');

SELECT *
FROM emp;

--위에서 실행한 INSERT 구문들이 모두 취소 됨.
ROLLBACK;

SELECT *
FROM emp;

------------------------------------------------------------------------
SELECT 쿼리 결과를 테이블에 입력
SELECT 쿼리의 결과는 여러건의 행이 될 수도 있다.
★여러건의 데이터를 하나의 INSERT구문을 통해 입력!

문법
INSERT INTO 테이블명 [(컬럼1,...)]
SELECT 컬럼1, 컬럼2, ..
FROM ....;

INSERT INTO emp (empno, ename, hiredate, job)
SELECT 9998, 'sally', SYSDATE, 'RANGER' --컬럼값을 NULL하고 싶을 경우 강제로 NULL이라고 표현할 수 있다.
FROM dual
UNION ALL
SELECT 9997, 'moon', TO_DATE('2020/07/07','YYYY/MM/DD'), 'RANGER'
FROM dual;

--다량으로 insert처리해야할 경우엔 이렇게 한번에 처리하는 것이 시간 효율적이다.

☆UPDATE☆
: 테이블에 존재하는 데이터를 수정하는 것
1. 어떤 테이블을 업데이트 할 것인지?
2. 어떤 컬럼을 어떤 값으로 업데이트 할 건지
3. 어떠 행에 대해서 업데이트 할 것인지(SELECT의 WHERE절과 동일)

☆문법
UPDATE 테이블명 SET 컬럼명1 = 변경할 값1 [, 컬럼명2 = 변경할 값2, ...]
[WHERE 조건(변경할 행을 제한)]

SELECT *
FROM dept;

--deptno가 90, dname이 ddit, loc 가 대전인 데이터를 dept 테이블에 입력하는 쿼리 작성

INSERT INTO dept (deptno, dname, loc)
VALUES (90, 'ddit', '대전');

SELECT *
FROM dept;

부서번호가 90번인 부서의 부서명을 '대전it' , 위치정보를 'daejeon'으로 업데이트

UPDATE dept SET dname = '대전it', loc = 'daejeon'
WHERE deptno = 90;

★★★★★★★★★★★★★★★★★★★UPDATE 사용시 주의점★★★★★★★★★★★★★★★★★★★★★★★★★★
 1. WHERE절이 있는지 없는지 체크체크체크! 안그럼 전체가 다 바뀐다.. 커밋 전에 잘 확인 할것.
 2. UPDATE하기전에 기술한 WHERE절을 SELECT 절에 적용하여 업데이트 대상 데이터를 눈으로 확인하고 실행할것.
★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★



 

