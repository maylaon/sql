-- ROWNUM
-- ROWNUM : SELECT 순서대로 행 번호를 부여해 주는 가상 컬럼
-- 특징: WHERE절에서도 사용하는 것이 가능
--      ** 사용할 수 있는 형태가 정해져 있음.
--      WHERE ROWNUM = 1;   : ROWNUM이 1일때 (1만 가능!)
--      WHERE ROWNUM <= N;   : ROWNUM이 N보다 작거나 같은 경우
--      WHERE ROWNUM BETWEEN 1 AND N;  : ROWNUM이 1과 N사이에 있을 경우
--      => ROWNUM은 1부터 순차적으로 읽는 환경에서만 사용 가능
--      *** 안되는 경우
--      WHERE ROWNUM = 2; (1 외의 것은 안됨)
--      WHERE ROWNUM >= N; (크거나 같은 경우는 안됨)
--      *** ROWNUM 사용 용도: 페이징 처리(네이버 카페에서 게시글 리스트를 한화면에 제한적인 개수로 조회할 때 - 100개, 300개, ...
--      페이징 처리: 전체 게시글 수는 굉장히 많아서 한 화면에 못 보여줌. - 1. 웹브라우저 버벅댐. 2. 사용자의 사용성 굉장히 불편
--      > 한 페이지당 건수를 정해놓고 해당 건수만큼만 조회해서 화면에 보여준다


--  WHERE절에서 사용할 수 있는 형태
SELECT ROWNUM, empno, ename
FROM emp
WHERE ROWNUM = 1;

SELECT ROWNUM, empno, ename
FROM emp
WHERE ROWNUM <= 10;

-- WHERE 절에서 사용할 수 없는 형태
SELECT ROWNUM, empno, ename
FROM emp
WHERE ROWNUM >= 10; --1부터 시작해야 한다!

-- ROWNUM과 ORDER BY
-- SELECT SQL의 실행 순서 : FROM - WHERE - SELECT - ORDER BY

SELECT ROWNUM, empno, ename
FROM emp
ORDER BY ename; -- order by 가 가장 나중에 실행되기 때문에 rownum 정렬X
--페이징 처리하기 위해서는 oracle에서 까다로운 절차를 거쳐야 한다!
-- rownum을 orderby 정렬 이후에 반영 하고 싶은 경우 : "IN-LINE VIEW"를 사용해야 한다.
-- VIEW : SQL <- DBMS에 저장되어있는 SQL. SQL의 결과를 테이블이라고 생각함.
-- IN-LINE : "직접 기술 했다." 어딘가 저장을 한 것이 아니라 그 자리에 직접 기술한 것.

SELECT empno, ename
FROM emp;

--(IN-LINE VIEW) VIEW 기준 작성: SQL의 결과를 테이블이라고 생각함.
SELECT ROWNUM, empno, ename -- * 대신 직접 컬럼명 작성: ROWNUM, * 작성시 오류가 나기때문.
FROM (SELECT empno, ename
      FROM emp
      ORDER BY ename); --SELECT 결과를 하나의 테이블이라고 생각
-- SELECT절에서 *는 단독으로 사용하지 않고 콤마를 통해 다른 임의 컬럼/expression을 표기한 경우 *앞에 어떤 테이블(뷰)에서 온 것인지 한정자(테이블 이름, view이름)을 붙여줘야한다
SELECT emp.* --emp에 있는 모든 컬럼이라는 의미
FROM emp;

-- table, view 별칭: table이나 view에도 SELECT절의 컬럼처럼 별칭 부여 가능. 단 AS키워드는 사용하지 않는다. 
SELECT ROWNUM, empno, ename 
SELECT ROWNUM, a.* -- 위 줄과 같다.
FROM (SELECT empno, ename
      FROM emp
      ORDER BY ename) a; --테이블 명 a로 지칭. AS쓰지 않고 바로 ALIAS 표기한다
      
* 요구사항: 1페이지당 10건의 사원 리스트가 보여야 된다
페이지 번호, 페이지당 사이즈
1page : 1~10
2page : 11~20
.
.
npage : (n-1)*10+1 ~ 10*n --10이 아닐 경우 10대신 pagesize 넣으면 된다.
npage : n * 10 - 9 ~ 10*n -- 10에 의존하기 때문에 위 식이 일반적.

--페이징 처리 쿼리 (1 page: 1~10(ROWNUM))
SELECT ROWNUM, a.* 
FROM (SELECT empno, ename
      FROM emp
      ORDER BY ename) a
WHERE ROWNUM BETWEEN 1 AND 10;

--페이징 처리 쿼리 (2 page: 11~20(ROWNUM))
SELECT ROWNUM, a.* 
FROM (SELECT empno, ename
      FROM emp
      ORDER BY ename) a
WHERE ROWNUM BETWEEN 11 AND 20; --ROWNUM은 1부터 순차적으로 나와야하는데 1-10 스킵하고 중간 값만 원했기때문에 실행안됨.
--ROWNUM의 값을 별칭을 통해 새로운 컬럼으로 만들고 해당 SELECT SQL을 in-line view로 만들어 외부에서 ROWNUM에 부여한 별칭을 통해 페이징 처리.

--(수정) 페이징 처리 쿼리 (2 page: 11~20(ROWNUM))
--rownum은 rn이라는 별칭을 쓴다 
SELECT * 
FROM (SELECT ROWNUM rn, a.* 
        FROM (SELECT empno, ename
        FROM emp
        ORDER BY ename) a)      
WHERE rn BETWEEN 11 AND 20;

--SQL 바인딩 변수(= java변수)
-- 설정해야할 변수: 페이지 번호(page), 페이지 사이즈(pageSize)
-- SQL 바인딩 변수 표기 >> :변수명 ==> :page, :pageSize
*바인딩 변수 적용시 (페이징 변수 공식: (:page-1)*:pageSize+1 ~ :page * :pageSize 
SELECT * 
FROM (SELECT ROWNUM rn, a.* 
        FROM (SELECT empno, ename
        FROM emp
        ORDER BY ename) a)      
WHERE rn BETWEEN (:page - 1) * :pageSize + 1 AND :page * :pageSize;

--p.132
*FUNCTION : 입력을 받아들여 특정 로직 수행 후 결과 값을 반환하는 객체
오라클에서의 함수 구분: 입력되는 행의 수에 따라
1. Single row function: 하나의 행 입력 > 결과는 하나의 행
2. Multi row function : 여러 행이 입력 > 결과는 하나의 행

*dual 테이블: oracle의 sys 계정에 존재하는 하나의 행, 하나의 컬럼(dummy)을 갖는 테이블
             누구나 사용할 수 있도록 권한이 개방됨.
*dual 테이블 용도: 
1. 함수 실행 / 테스트
2. 시퀀스 실행 
3. merge 구문에서 활용
4. 데이터 복제**

-- LENGTH 함수 테스트
SELECT LENGTH('TEST'), emp.*--TEST 라는 문자열의 단어수
FROM emp; --행 당 한번씩 실행 되므로 14행 나온다

--문자열 관련 함수
SELECT CONCAT('Hello',CONCAT(', ','World')) concat,
        SUBSTR('Hello, World', 1, 5) substr, --1~5자리 까지 출력
        LENGTH('Hello, World') length,
        INSTR('Hello, World', 'o') instr,
        INSTR('Hello, World', 'o', 6) instr2, --6번째 이후에 등장하는 o의 인덱스.
        INSTR('Hello, World', 'o', INSTR('Hello, World', 'o')+1) instr3, --두번쨰 o의 위치(일반적)
        LPAD('Hello, World', 15, ' ') lpad, --15글자가 안되면 왼쪽에 공백 붙여라
        RPAD('Hello, World', 15, ' ') rpad,
        REPLACE('Hello, World', 'o', 'p') replace, --o를 p로 바꿔라
        TRIM(' Hello, World ') trim, 
        TRIM('H' from 'Hello, World') trim2, --대소문자 구분 주의
        LOWER('HELLO, WORLD') lower,
        UPPER('hello, world') upper,
        INITCAP('hello, world') initcap    
FROM dual;

--함수는 WHERE절에서도 사용 가능
사원 이름이 SMITH인 사람

SELECT *
FROM emp
WHERE ename = UPPER('smith'); --고정된 문자열. 상수

SELECT *
FROM emp
WHERE LOWER(ename) = 'smith'; 
위 두개의 쿼리 중 하지 말아야할 형태: 아래! 왜냐하면 14번을 실행해야 하므로 비효율적(좌변-테이블,컬럼 을 가공하는 형태)

*오라클 숫자관련 함수
ROUND(숫자, 반올림 기준 자리)
TRUNC(숫자, 내림 기준 자리)
MOD(피제수, 제수) : 나머지 값을 구하는 함수 (JAVA : %)

SELECT ROUND(105.54, 1) round,
        ROUND(105.55, 1) round2,
        ROUND(105.55, 0) round3,
        ROUND(105.55) round3, --생략시 위round3와 같음
        ROUND(105.55, -1) round4,
        TRUNC(105.54, 1) trunc,
        TRUNC(105.55, 1) trunc2,
        TRUNC(105.55, 0) trunc3,
        TRUNC(105.55, -1) trunc4 --음수이면 해당 자리에서 내림/반올림
FROM dual;

--sal을 1000으로 나눴을때의 나머지( 몫: quotient, 나머지: reminder)
SELECT ename, sal, TRUNC(sal/1000) quotient, MOD(sal,1000) reminder
FROM emp;

--날짜 관련 함수(P.139)
SYSDATE: ORACLE에서 제공해주는 특수함수.
    1)인자가 없다 2)오라클 설치된 서버의 현재 년,월,일,시,분,초 정보 반환 함수

SELECT SYSDATE
FROM dual;

SELECT *
FROM nls_session_parameters;

--날짜 +- 정수 : 정수를 일자 취급
SELECT SYSDATE + 1
FROM dual;

ex) 현재 날짜에서 3시간 뒤 일자를 구하려면? ORACLE에서 1시간 = 1/24
SELECT SYSDATE + (1/24)*3
FROM dual;

ex) 현재 시간에서 30분 뒤
SELECT SYSDATE + (1/24/60)*30
FROM dual;

--날짜를 표현하는 방법
1) 데이트 리터럴 : NLS_SESSION_PARAMETERS 설정에 따르기 떄문에 DBMS 환경 마다 다르게 인식가능
2) TO_DATE('20/06/29','RR/MM/DD') 이용

--DATE실습 FN1
1. 
SELECT TO_DATE('19/12/31','RR/MM/DD') lastday, TO_DATE('19/12/31','RR/MM/DD') - 5 lastday_before5, 
        SYSDATE now, SYSDATE - 3 now_before3
FROM dual;

-- 문자열 ==> 데이트
    TO_DATE('날짜문자열','날짜문자열패턴');
-- 데이트 ==> 문자열 (보여주고 싶은 형식을 지정할 때)
    TO_CHAR(데이트 값,'표현하고싶은문자열패턴');
    ex) SYSDATE 현재날짜를 YYYY-MM-DD 로
    SELECT SYSDATE, TO_CHAR(SYSDATE, 'YYYY-MM-DD'), TO_CHAR(SYSDATE, 'D'),TO_CHAR(SYSDATE,'IW')
    FROM dual;
    
--P.144

SELECT ename, hiredate, TO_CHAR(hiredate, 'YYYY/MM/DD HH24:MI:SS') h1,
        TO_CHAR(hiredate + 1, 'YYYY/MM/DD HH24:MI:SS') h2,
        TO_CHAR(hiredate + 1/24, 'YYYY/MM/DD HH24:MI:SS') h3
FROM emp;

--P.145 DATE 실습 fn2

SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD') DT_DASH, 
        TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24-MI-SS') DT_DASH_WITH_TIME,
        TO_CHAR(SYSDATE, 'DD-MM-YYYY') DT_DD_MM_YYYY
FROM dual;






