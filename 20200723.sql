--0723 CLASS

(REVIEW)
계층쿼리(행-행 연결)
: 테이블(데이터셋)의 행과 행 사이의 연관 관계를 추적하는 쿼리
    ex) emp테이블의 해당 사원의 mgr컬럼을 통해 상급자 추적 가능
    상급자 직원을 다른 테이블로 관리하지 않음 => 상급자 구조가 계층이 변경 돼도 테이블 구조는 변경할 필요X
    
PRIOR : 현재 읽고 있는 행을 지칭. PRIOR 안붙인 애들: 앞으로 읽을 행;


--실습 H_4(P.81);

SELECT LPAD(' ', (level-1)*4) || s_id s_id, value, level
FROM h_sum
START WITH ps_id IS NULL
CONNECT BY PRIOR s_id = ps_id;

SELECT *
FROM h_sum;

--실습 h_5(p.82)
SELECT *
FROM no_emp;

DESC no_emp;

SELECT LPAD(' ', (level-1)*4) || org_cd org_cd, no_emp
FROM no_emp
START WITH parent_org_cd IS NULL
CONNECT BY PRIOR org_cd = parent_org_cd;

--계층쿼리 level 설계 코드가 궁금하다 +_+

p.82
pruning branch (가지치기)
SELECT 쿼리의 실행 순서 : FROM - WHERE - SELECT - ORDER BY
계층 쿼리의 SELECT 쿼리 실행 순서 : FROM - START WITH, CONNECT BY - WHERE 

계층쿼리에서 조회할 행의 조건을 기술할 수 있는 부분이 두 곳! (결과가 상이할 수 있다)
1. CONNECT BY : 연결 조건.
2. WHERE;

SELECT LPAD(' ', (level-1) * 4) || deptnm deptnm
FROM dept_h
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = p_deptcd AND deptnm != '정보기획부';
★정보기획부 포함 하위 부서까지 나오지 않는다. 조건이 connect by절에 왔으니

SELECT LPAD(' ', (level-1) * 4) || deptnm deptnm
FROM dept_h
WHERE deptnm != '정보기획부'
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = p_deptcd;
★실행순서가 FROM - START WITH, CONNECT BY - WHERE 이므로 CONNECT이후에 WHERE조건 적용된다.

-------------------------------------------------------------------------------------------------------
(P.83) 계층쿼리에서 사용할 수 있는 특수 함수
1) CONNECT_BY_ROOT(컬럼) : START WITH 기준 
최상위 행의 컬럼 값을 반환해 준다.
2) SYS_CONNECT_BY_PATH(컬럼, 구분자) : 계층의 순회 경로를 표현 --구분자는 왼쪽에 붙여준다
3) CONNECT_BY_ISLEAF : 해당 행이 LEAF NODE인지(1) 아닌지(0) 리턴 (리프 노드 : 말단 계층);

SELECT LPAD(' ', (level-1) * 4) || deptnm deptnm, CONNECT_BY_ROOT(deptnm) root, 
        LTRIM(SYS_CONNECT_BY_PATH(deptnm, '-'),'-') path, CONNECT_BY_ISLEAF
FROM dept_h
WHERE deptnm != '정보기획부'
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = p_deptcd;


--p.86 실습 h6
SELECT seq, LPAD(' ', (level-1) * 4) || title title
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq;

--실습7
SELECT seq, LPAD(' ', (level-1) * 4) || title title
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq
ORDER BY seq DESC;

SELECT seq, LPAD(' ', (level-1) * 4) || title title, level
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq
ORDER SIBLINGS BY seq DESC; --계층 유지 정렬 (자식간의 정렬도 함)

--생각해보기
게시글은 최신순으로 DESC 정렬되지만, 댓글은 작성시간순으로 정렬된다. 
SELECT seq, LPAD(' ', (level-1) * 4) || title title, gn, CONNECT_BY_ROOT(seq)
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq
ORDER SIBLINGS BY gn DESC,seq;

//그룹번호 생성
ALTER TABLE board_test ADD(gn NUMBER) ;
UPDATE board_test SET gn = 4
WHERE seq IN(4,5,6,7,8,10,11);

UPDATE board_test SET gn = 2
WHERE seq IN (2,3);

UPDATE board_test SET gn = 1
WHERE seq IN(1,9);

SELECT *
FROM board_test;

COMMIT;
//CONNECT_BY_ROOT = gn 동일!
SELECT *
FROM(
SELECT seq, LPAD(' ', (level-1) * 4) || title title, gn, CONNECT_BY_ROOT(seq) rt
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq)
ORDER BY rt DESC,seq;

-------------------------------------------------------------------------------------------------------
p.97
★ 분석함수 (a.k.a. window 함수)

SELECT MIN(sal)
FROM emp
GROUP BY deptno;

SELECT deptno
FROM emp
GROUP BY deptno;

SELECT ename, sal, deptno, 
(SELECT COUNT(*) FROM emp WHERE deptno = e.deptno GROUP BY deptno) sal_rank
FROM emp e
ORDER BY deptno, sal DESC;

순위를 매길 대상 : emp사원 = > 14명
부서별로 인원이 다름
SELECT *
FROM
(SELECT ROWNUM rn, ee.*
FROM
(SELECT ename, sal, deptno
FROM emp e
ORDER BY deptno, sal DESC) ee) eee
JOIN
(SELECT ROWNUM rn, a.*
FROM(
SELECT a.lv
FROM
(SELECT LEVEL lv
FROM dual
CONNECT BY LEVEL <= (SELECT COUNT(*) FROM emp)) a,
(SELECT deptno, COUNT(*) cnt
FROM emp
GROUP BY deptno) b
WHERE a.lv <= b.cnt
ORDER BY b.deptno, a.lv) a) aa
ON 
(eee.rn = aa.rn); 

--위와 동일한 동작을 하는 WINDOW함수
 SELECT ename, sal, deptno, RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) sal_rank
 FROM emp;

--부하가 좀 더 생기지만, 테이블을 한번만 읽기 때문에 효율!

★WINDOW함수★
행간 연산이 가능해짐 => 일반적으로 풀리지 않는 쿼리를 간단하게 만들 수 있다. 
** 모든 dbms가 동일한 윈도우 함수를 제공하지 않음

문법: 윈도우 함수 OVER ([PARTITION BY 컬럼명] [ORDER BY 컬럼] [windowing])
PARTITION BY : 행들을 묶을 그룹 지정 (GROUP BY와 유사)
ORDER BY : 묶여진 행들간 순서를 지정할 때 (ex_ RANK 순위의 경우 순서를 설정하는 기준이 된다.)
WINDOWING : 파티션 안에서 특정 행들에 대해서만 연산을 하고 싶을 때 범위 지정

순위(RANK)관련 함수
1. RANK() : 1등이 2명일 경우, 그 다음 순위는 3
            동일 값일 때는, 동일 순위 부여. 후순위는 중복자만큼 건너 띄우고 부여한다. 
2. DENSE_RANK() : 1등이 2명일 경우 그 다음 순위는 2
3. ROW_NUMBER() : 동일 값이라도 별도의 순위를 부여(중복x - partition 내 row-number 개념

SELECT ename, sal, deptno, RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) sal_rank,
    DENSE_RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) dense_rank,
    ROW_NUMBER() OVER (PARTITION BY deptno ORDER BY sal DESC) row_number
FROM emp;

---P.108 no_ana2 
SELECT empno, ename, deptno, (SELECT count(*) from emp where deptno = e.deptno) cnt
FROM emp e
ORDER BY deptno;

--p.109
★집계 윈도우 함수: SUM, MAX, MIN, AVG, COUNT
--부서번호 별 사원의 수
EXPLAIN PLAN FOR
SELECT empno, ename, deptno, COUNT(*) OVER ( PARTITION BY deptno) cnt
FROM emp;

SELECT * 
FROM TABLE(dbms_xplan.display);

SELECT empno, ename, sal, deptno, ROUND(AVG(sal) OVER (PARTITION BY deptno),2) avg_sal
FROM emp;

--ana3
SELECT empno, ename, sal, deptno, MAX(sal) OVER (PARTITION BY deptno) max_sal
FROM emp;

--ana4 (P.113)
SELECT empno, ename, sal, deptno, MIN(sal) OVER (PARTITION BY deptno) max_sal
FROM emp;




