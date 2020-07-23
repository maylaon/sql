--0722

myBatis
SELECT : 결과가 1건 VS 복수건
    1건 : sqlSession.selectOne("네임스페이스.sqlid", [인자]) ==> overloading
            리턴타입 = resultType
    복수 : sqlSession.selectList("네임스페이스.sqlid", [인자]) ==> overloading
            리턴 타입 = List<resultType> 
    


p.62
오라클 계층 쿼리 : 하나의 테이블(혹은 인라인뷰)에서 특정 행을 기준으로 다른 행을 찾아가는 문법. 

cf) 조인 : 테이블 - 테이블의 연결

계층 : 행 - 행의 연결

1. 시작행 설정
2. 시작행과 다른행을 연결시킬 조건을 기술

--실습
1. 시작점 : mgr 정보가 없는 KING 
2. 연결 조건: KING을 mgr컬럼으로 하는 사원;

SELECT emp.*, level
FROM emp
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr;

--시각화
--lpad / rpad
SELECT LPAD('기준문자열', 15, '*') --바이트로 따짐. 한글은 한글자 2바이트.
FROM dual; -- 15자리가 안될때 나머지 공간 *로. 기본값은 공백.

 --level값 만큼 들여쓰기해보자.
--LEVEL = 1이면 공백 0칸
--LEVEL = 2이면 공백 4칸 ..
SELECT LPAD(' ', (LEVEL-1)*4) || ename, level
FROM emp
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr;

SELECT LPAD(' ', (LEVEL-1)*4) || ename, level
FROM emp
START WITH ename = 'BLAKE'
CONNECT BY PRIOR empno = mgr;

---------------------------------------------------------------------------------------------
상향식 연결방법 (최하단 노드 -> 상위 노드)
시작점 : SMITH 

SELECT LPAD(' ', (LEVEL -1)*4) || ename, level
FROM emp
START WITH ename = 'SMITH'
CONNECT BY PRIOR mgr = empno AND deptno = 20; --부서번호가 20인 애들만 연결

--------------------------------------------------------------------------------------------
dept_h 테이블 생성

SELECT *
FROM dept_h;

--p.74 실습 
--XX회사 부서부터 시작하는 하향식 계층 쿼리 작성.. 부서 이름과 LEVEL컬럼 이용해 들여쓰기 표현

SELECT LPAD(' ', (LEVEL-1)*4) || deptnm, level
FROM dept_h
START WITH p_deptcd IS NULL
CONNECT BY PRIOR deptcd = p_deptcd;

--상향식으로 해보자
SELECT LPAD(' ', (4-level)*4) || deptnm, level
FROM dept_h
START WITH deptnm = '기획팀'
CONNECT BY PRIOR p_deptcd = deptcd;

SELECT deptcd, LPAD(' ', (level-1)*4) || deptnm deptnm, level
FROM dept_h
START WITH deptnm = '디자인팀'
CONNECT BY PRIOR p_deptcd = deptcd;


EXPLAIN PLAN FOR 
SELECT LPAD(' ', (LEVEL-1)*4) || deptnm, level
FROM dept_h
START WITH p_deptcd IS NULL
CONNECT BY PRIOR deptcd = p_deptcd;

SELECT * 
FROM TABLE(dbms_xplan.display);

EXPLAIN PLAN FOR
SELECT level
FROM dual
CONNECT BY LEVEL <= 5;