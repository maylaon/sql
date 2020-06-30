-- 0630 CLASS
-- 날짜 관련 오라클 내장 함수
-- 내장 함수: "탑재가 되어있다." = 오라클에서 제공해준다 < 왜냐하면 많이 사용해서 개발자가 별도로 개발하지 않도록.

(활용도:*) MONTHS_BETWEEN(date1, date2) : 두 날짜 사이의 개월수를 반환 (잘 안쓰이는 이유: 다른 일수로 하면 소수점이 나옴)
(활용도: *****) ADD_MONTHS(date1, number) : date1 날짜에 number 만큼의 개월수를 더하고 뺀 날짜 반환
(활용도: ***) NEXT_DAY(date1, 주간요일(1~7)) : date1 이후에 등장하는 첫번째 주간요일의 날짜 반환
                                            NEXT_DAY(20200630, 6) = 20200703

(활용도: ***) LAST_DAY(date1) : date1 날짜가 속한 월의 마지막 날짜 반환
                                20200605 ==> 20200630
                                모든 달의 첫번째 날짜는 1일로 정해져 있지만 달의 마지막 날짜는 다름.
                                그래서 LAST_DAY는 있지만 FIRST_DAY는 없다

SELECT ename, TO_CHAR(hiredate,'YYYY-MM-DD') hiredate, MONTHS_BETWEEN(SYSDATE, hiredate)
FROM emp;

--ADD MONTHS
SELECT ADD_MONTHS(SYSDATE, 5) aft5, ADD_MONTHS(SYSDATE, -5) bef5
FROM dual;

--NEXT_DAY: 해당 날짜 이후에 등장하는 첫번쨰 주간요일의 날짜
SELECT NEXT_DAY(SYSDATE, 7)
FROM dual;

--LAST_DAY: 해당 일자가 속한 월의 마지막 일자를 반환
SELECT LAST_DAY(TO_DATE('21/02/05', 'RR/MM/DD'))
FROM dual;

--FIRST_DAY 직접 SQL로 구현
-- 1. SYSDATE를 문자로 변경
-- 2. 1번의 결과에다가 문자열 결합을 통해 '01'문자를 뒤에 붙여준다 >> YYYYMMDD
-- 3. 2의 결과를 DATE타입으로 바꾸기

SELECT TO_DATE(CONCAT(TO_CHAR(SYSDATE, 'YYYYMM'), '01'), 'YYYY-MM-DD') first_day
FROM dual;

--date fn3 실습
SELECT '202002' param, LAST_DAY(TO_DATE('202002','YYYYMM')) - TO_DATE('202002','YYYYMM') + 1 dt
FROM dual;

with 샘
SELECT '202002' param, TO_CHAR(LAST_DAY(TO_DATE('202002','YYYYMM')),'DD') dt
FROM dual;

SELECT :param param, TO_CHAR(LAST_DAY(TO_DATE(:param,'YYYYMM')),'DD') dt
FROM dual;

--형변환(P.157참고)
실행계획 : DBMS가 요청받은 SQL을 처리하기 위해 세운 절차
            sql자체에는 로직X. (어떻게 처리해라 가 없다. <JAVA랑 다른점)
            
실행계획 보는 방법:
1. 실행계획 생성
EXPLAIN PLAN FOR
실행 계획을 보고자 하는 SQL;

2. 실행 계획을 보는 단계
SELECT *
FROM TABLE(dbms_xplan.dispaly);

empno 컬럼은 NUMBER 타입이지만 형변환이 어떻게 일어나는지 확인하기 위해 의도적으로 문자열 상수비교를 진행

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno = '7369';

SELECT *
FROM TABLE(dbms_xplan.display);


--★실행 계획을 읽는 방법:
1. 위에서 아래로
2. 단, 자식 노드가 있으면 자식 노드부터 읽는다.
    자식 노드: 들여쓰기가 된 노드
    
Plan hash value: 3956160932
 
--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    87 |     3   (0)| 00:00:01 | --
|*  1 |  TABLE ACCESS FULL| EMP  |     1 |    87 |     3   (0)| 00:00:01 | -- TABLE ACCESS FULL이 들여쓰기(자식노드)
-------------------------------------------------------------------------- : "EMP테이블을 다 읽어 들인다"
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("EMPNO"=7369)          -- EMPNO가 7369인 애들만 거른다.
 
Note
-----
   - dynamic sampling used for this statement (level=2)


--2
EXPLAIN PLAN FOR
SELECT * 
FROM emp
WHERE TO_CHAR(empno) = '7369';

SELECT*
FROM TABLE(dbms_xplan.display);

결과 >>   1 - filter(TO_CHAR("EMPNO")='7369') 실제 empno를 문자열로 변환함.

--3
EXPLAIN PLAN FOR
SELECT * 
FROM emp
WHERE empno = 7300 +'69';

SELECT*
FROM TABLE(dbms_xplan.display);

결과 >>    1 - filter("EMPNO"=7369) : 숫자로 취급됨

-- 문자 <-> 숫자 형변환
SQL에서 6,000,000 은 문자열로 인식(컴마 붙인 경우)
6,000,000 <=> 6000000
국제화: i18n (internationalization)
    ex) 날짜 국가 별로 형식이 다르다
        한국: yyyy-mm-dd
        미국: mm-dd-yyyy
        숫자 표기
        한국: 9,000,000.00
        독일: 9.000.000,00

--sal(NUMBER) 컬럼의 값을 문자열 포맷팅 적용        
SELECT ename, sal, TO_NUMBER(TO_CHAR(sal, 'L9,999.00'),'L9,999.00')
FROM emp;

--NULL과 관련된 함수
    : NULL값을 다른값으로 치환, 혹은 강제로 NULL을 만듦
1. NVL(expression1,  expression2)
2. NVL2(expression1, expr2, expr3)
3. NULLIF(expr1, expr2)
4. COALESCE(expr1, expr2, ....)

1. NVL(expr1, expr2)
    if(expr1 == null){
    System.out.print(expr2);}  <- java로 표현하자면.
    else{
    System.out.print(expr1);}
    
SELECT empno, sal, comm, NVL(comm,0), sal + NVL(comm,0)
FROM emp;

2. NVL2(expr1, expr2, expr3)
    if(expr1 != null){
    System.out.print(expr2);}
    else{
    System.out.print(expr3);}
        
SELECT empno, sal, comm, NVL2(comm,comm+sal, 0+sal)
FROM emp;

3. NULLIF(expr1, expr2) : NULL값을 생성하는 목적
    if(expr1 == expr2){
    System.out.print(null);}
    else{
    System.out.print(expr1);}
    
SELECT ename, sal, comm, NULLIF(sal,3000)
FROM emp;

4. COALESCE(expr1, expr2,....) : 인자 중 가장 처음으로 null값이 아닌 값을 갖는 인자를 반환
ex) COALESCE(NULL, NULL, 30, NULL, 50, 60) ==> 30
    if(expr1 != null){
    System.out.print(expr1);}
    else{
    COALESCE(expr2, ....);} <- 재귀함수(자기 자신을 다시 호출하는 함수)
    
SELECT COALESCE(NULL,NULL,30,NULL,50)
FROM dual;

-- NULL처리 실습
emp테이블에 14명의 사원 존재. 한명을 추가(INSERT)

INSERT INTO emp (empno, ename, hiredate) VALUES (9999,'brown',NULL);

SELECT * 
FROM emp;

조회컬럼: ename, mgr, ??(mgr컬럼값이 null이면 111로 치환한 값, null이 아니면 mgr), hiredate, 
???(hiredate가 null이면 sysdate로 표기, 아니면 hiredate)

SELECT ename, mgr, NVL2(mgr, mgr, 111) nvl_mgr, hiredate, NVL(hiredate,SYSDATE) nvl_hiredate
FROM emp;

DESC emp;

--null실습 fn4
SELECT empno, ename, mgr, NVL(mgr, 9999) mgr_n, NVL2(mgr, mgr, 9999) mgr_n_1, COALESCE(mgr, 9999) mgr_n_2
FROM emp;

SELECT empno, ename, mgr, COALESCE(null, null, null, mgr, 9999) mgr_n_2 -- 이런식으로 해도 된다.
FROM emp;

--null실습 fn5
DESC users;

SELECT * 
FROM users;

SELECT * 
FROM (SELECT ROWNUM rn, a.*
    FROM (SELECT userid, usernm, reg_dt, NVL(reg_dt, SYSDATE) n_reg_dt
        FROM users) a)
WHERE rn BETWEEN 2 AND 5; --where구문이 생각안나서 rownum을 이용했다........

SELECT userid, usernm, reg_dt, NVL(reg_dt, SYSDATE) n_reg_dt
        FROM users;

SELECT userid, usernm, NVL(reg_dt, SYSDATE) n_reg_dt
FROM users
WHERE userid != 'brown'; --헐 까먹지 말자.....where절.......행을 제한하는 구문!!!!

SELECT ROUND((6/28)* 100,2) || '%'
FROM dual;

--Condition 
SQL 조건문: CASE
CASE
    WHEN 조건문(참,거짓 판별하는 논리식) THEN 반환할값
    WHEN 조건문(참,거짓 판별하는 논리식) THEN 반환할값2
    WHEN 조건문(참,거짓 판별하는 논리식) THEN 반환할값3
    ELSE  모든 WHEN절을 만족시키지 못할 경우 반환할 기본 값
END ==> 하나의 컬럼처럼 취급

-- emp테이블에 저장된 job 컬럼의 값을 기준으로 급여(sal)를 인상시키려 한다.
-- 기존 sal컬럼과 함께 인상된 sal컬럼의 값을 비교
job이 salesman이면 sal*1.05
job이 manager이면 sal *1.10
job이 president 이면 sal * 1.20
나머지 직군은 sal 유지

SELECT ename, job, sal, 
    CASE 
        WHEN job = 'SALESMAN' THEN sal * 1.05
        WHEN job = 'MANAGER' THEN sal * 1.10
        WHEN job = 'PRESIDENT' THEN sal * 1.20
        ELSE    sal
    END AS inc_sal
FROM emp;


--condition 실습 cond1

SELECT empno, ename, 
    CASE
        WHEN deptno = 10 THEN 'ACCOUNTING'
        WHEN deptno = 20 THEN 'RESEARCH'
        WHEN deptno = 30 THEN 'SALES'
        WHEN deptno = 40 THEN 'OPERATIONS'
        ELSE 'DDIT'
    END AS dname
FROM emp;




