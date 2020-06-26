-- IN 실습 where3

SELECT userid 아이디, usernm 이름, alias AS 별명
FROM users
WHERE userid IN ('brown', 'cony', 'sally');

-- SQL에서는 키워드는 대소문자를 가리지 않는다.
-- 데이터는 대소문자를 가린다! (당연한 거겠지만)