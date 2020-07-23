--0716 SQL CLASS
☆실행계획 (실행계획 PT자료)
index, join 수에 따라 실행계획이 기하급수적으로 늘어난다.

개발자가 SQL을 DBMS에 요청해도 
1) 오라클 서버가 항상 최적의 실행계획을 선택할 수는 없음.
 => 왜냐하면 응답성이 중요하기 때문 (a.k.a. OLTP: Online Transaction Processing)

cf) OLAP (Online Analytical Processing): 전체 처리 시간이 중요
     OLAP는 정해진 시간에 데이터를 가공하거나 처리하는 시스템
     => 응답이 빠를 필요 없음 ex) 은행 이자 처리 
     => 실행 계획 세우는데도 30분 이상 소요되기도 함.
     
2) 항상 실행계획을 세우지 않음
    만약 동일한 SQL이 이미 실행된적이 있으면, 해당 SQL의 실행계획을 새롭게 세우지 않고
    Shared Pool(메모리)에 저장됐던 실행계획을 재사용.
    동일한 SQL = "문자가 완벽하게 동일한 SQL" (대소문자, 공백 포함)
                => SQL의 실행결과가 같다해서 동일한 SQL이 아님
    ex) (1) SELECT * FROM emp;   (2) select * FROM emp; 에서 (1)과 (2)는 서로 다른 SQL로 취급
    

SELECT /* plan_test */ * 
FROM emp
WHERE empno = 7369; ==> empno를 일일히 바꿔줄때마다 sql이 그만큼 실행되기 때문에 바인드 변수를 이용한다!

SELECT /* plan_test */ * 
FROM emp
WHERE empno = :empno; 



☆★SQL실행절차
구문분석 - 바인드 - 실행 - 인출(SELECT절만 해당- 조회 이므로)

1. JOIN과 관련된 실행 계획
★JOIN★
 물리적 조인 : 오라클 내부에서 실제 조인을 처리하는 방식
 
1) Nested Loop Join
: (자바의 for 루프와 유사!)
먼저 읽을 테이블(선행테이블: outer table) 쭉 조회 = > 후행 테이블(inner table) 조회
빠른 응답성
outer, inner에 인덱스 없으면 outer table 행수 * inner table 행수 만큼 읽는다


2. Sort Merge Join
조인 컬럼에 인덱스가 없을 때  
: 조인되는 테이블 각각 정렬 후 연결
-> 응답이 느림
=> sort merge join은 테이블 조인 조건이 =이 아니어도 가능!
=> 오라클에게 실행계획 힌트 줄 수 있음. 주석으로 

3. Hash Join
조인 컬럼에 인덱스가 없고, 연결 조건이 "(=)" 인 경우만! (왜냐하면 결과값이 난수이기떄문에 정확히 
동일한 문자열만 비교 가능)
"Hash" = 함수
입력값 = > hash function => cpu이용해 결과값(난수) 변환
join의 기준이되는 컬럼에 hash function 적용
=> 인덱스랑 어떤 차이가 있으까; 인덱스는 로우 아이디(행 전체)
: 한쪽 테이블이 비교적 작고(이 테이블에 대한 hash function 만들어서) 다른 테이블이 클때 유리

4. index
행이 3천건 이상인 경우는 사용 비추..

(자습 때 SINGLE BLOCK I/O MULTIBLOCK I/O, 실행계획 정리하기)

------------------------------------------------------------------------------------

DCL (GRANT / REVOKE)
: Data Control Language - 시스템 권한 또는 객체 권한을 부여(GRANT) / 회수(REVOKE)

GRANT 권한명 | 롤명 TO 사용자;
REVOKE 권한명 | 롤명 FROM 사용자;

Data Dictionary
오라클 서버가 사용자 정보를 관리하기 위해 저장한 데이터를 볼수 있는 view

CATEGORY(접두어) : 
user_ : 해당 사용자가 소유한 객체 조회
all_ : 해당 사용자가 소유한 객체 + 권한 부여받은 객체 조회
db_ : db에 설치된 모든 객체(dba 권한이 있는 사용자만 가능 - ex) system 계정)
v$_ : 성능, 모니터와 관련된 특수 view

SELECT *
FROM dictionary;

SELECT *
FROM all_tables; --사용자가 사용할 수 있는 모든 테이블 





            


 

 