-- 2021.06.17 sy
--[주문하기-최근 배송지]
-- 컬럼으로 쪼개기
-- DELIVERY_ADDRESS ->
--                      delivery_zipcode       우편번호
--                      delivery_roadAddress   도로명주소
--                      delivery_jibunAddress  지번주소
--                      delivery_namujiAddress 나머지(상세)주소
-- 배송지 정보를 나눠서 저장하기 위해 컬럼 추가(우편번호, 도로명, 지번, 상세주소)
ALTER TABLE T_SHOPPING_ORDER ADD(delivery_zipcode VARCHAR2(20));
ALTER TABLE T_SHOPPING_ORDER ADD(delivery_roadAddress VARCHAR2(500));
ALTER TABLE T_SHOPPING_ORDER ADD(delivery_jibunAddress VARCHAR2(500));
ALTER TABLE T_SHOPPING_ORDER ADD(delivery_namujiAddress VARCHAR2(500));
-- 우편번호
UPDATE T_SHOPPING_ORDER A 
SET a.delivery_zipcode = (
                SELECT substr(b.DELIVERY_ADDRESS,6,5) as zipcode
                FROM T_SHOPPING_ORDER B 
                WHERE a.ORDER_SEQ_NUM = b.ORDER_SEQ_NUM
                );
-- 도로명 주소
UPDATE T_SHOPPING_ORDER A 
SET a.delivery_roadAddress = (
                SELECT substr(DELIVERY_ADDRESS,(instr(DELIVERY_ADDRESS,':',1,2)+1),(instr(DELIVERY_ADDRESS,'<br>',1,2)-instr(DELIVERY_ADDRESS,':',1,2)-1)) as ROADADDRESS
                FROM T_SHOPPING_ORDER B 
                WHERE a.ORDER_SEQ_NUM = b.ORDER_SEQ_NUM
                );
-- 지번 주소
UPDATE T_SHOPPING_ORDER A 
SET a.delivery_jibunAddress = (
                SELECT substr(DELIVERY_ADDRESS,(instr(DELIVERY_ADDRESS,':',1,3)+1),(instr(DELIVERY_ADDRESS,'<br>',1,3)-instr(DELIVERY_ADDRESS,':',1,3)-2)) as JIBUNADDRESS
                FROM T_SHOPPING_ORDER B 
                WHERE a.ORDER_SEQ_NUM = b.ORDER_SEQ_NUM
                );
-- 나머지 주소
UPDATE T_SHOPPING_ORDER A 
SET a.delivery_namujiAddress = (
                SELECT substr(DELIVERY_ADDRESS,(instr(DELIVERY_ADDRESS,'<br>',1,3)+4)) as NAMUJIADDRESS
                FROM T_SHOPPING_ORDER B 
                WHERE a.ORDER_SEQ_NUM = b.ORDER_SEQ_NUM
                );
--[기본 게시판]
-- 회원정보 추가
INSERT INTO T_SHOPPING_MEMBER (MEMBER_ID, MEMBER_PW, MEMBER_NAME, MEMBER_GENDER, TEL1, TEL2, TEL3, HP1, HP2, HP3, SMSSTS_YN, EMAIL1, EMAIL2, EMAILSTS_YN, ZIPCODE, ROADADDRESS, JIBUNADDRESS, NAMUJIADDRESS, MEMBER_BIRTH_Y, MEMBER_BIRTH_M, MEMBER_BIRTH_D, MEMBER_BIRTH_GN, JOINDATE, DEL_YN) VALUES ('hong', '1212', '홍길동', '101', '02', '1111', '2222', '010', '1111', '2222', 'Y', 'hong', 'gmail.com', 'Y', '06253', '서울 강남구 강남대로 298 (역삼동)', '서울 강남구 역삼동 838', '럭키빌딩 101호', '2000', '5', '10', '2', TO_DATE('2018-10-16 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'N');
INSERT INTO T_SHOPPING_MEMBER (MEMBER_ID, MEMBER_PW, MEMBER_NAME, MEMBER_GENDER, TEL1, TEL2, TEL3, HP1, HP2, HP3, SMSSTS_YN, EMAIL1, EMAIL2, EMAILSTS_YN, ZIPCODE, ROADADDRESS, JIBUNADDRESS, NAMUJIADDRESS, MEMBER_BIRTH_Y, MEMBER_BIRTH_M, MEMBER_BIRTH_D, MEMBER_BIRTH_GN, JOINDATE, DEL_YN) VALUES ('kim', '1212', '김유신', '101', '02', '1111', '2222', '010', '2222', '3333', 'Y', 'kim', 'jweb.com', 'Y', '13547', '경기 성남시 분당구 고기로 25 (동원동)', '경기 성남시 분당구 동원동 79-1', '럭키빌딩 101호', '2000', '5', '10', '2', TO_DATE('2018-10-23 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'N');
commit;

--기본 게시판 테이블을 생성
DROP TABLE t_Board CASCADE CONSTRAINTS;
create table t_Board(
    articleNO number(10) primary key,
    parentNO number(10) default 0,
    title varchar2(500) not null,
    content varchar2(4000),
    imageFileName varchar2(30),
    writedate date default sysdate not null,
    id varchar2(10),
    CONSTRAINT FK_ID FOREIGN KEY(id)
    REFERENCES T_SHOPPING_MEMBER(MEMBER_ID)
);

-- 테이블에 테스트 글을 추가
insert into t_board(articleNO, parentNO, title, content, imageFileName, writedate, id)
values(1, 0, '테스트글입니다.', '테스트글입니다.', null, sysdate, 'hong' );
insert into t_board(articleNO, parentNO, title, content, imageFileName, writedate, id)
values(2, 0, '안녕하세요.', '상품 후기입니다.', null,sysdate, 'hong' );
insert into t_board(articleNO, parentNO, title, content, imageFileName, writedate, id)
values(3, 2, '답변입니다.', '상품 후기에 대한 답변입니다.', null,sysdate, 'hong' );
insert into t_board(articleNO, parentNO, title, content, imageFileName, writedate, id)
values(5, 3, '답변입니다.', '상품 좋습니다.', null,sysdate, 'lee' );
insert into t_board(articleNO, parentNO, title, content, imageFileName, writedate, id)
 values(4, 0, '김유신입니다.', '김유신 테스트글입니다.', null, sysdate, 'kim' );
insert into t_board(articleNO, parentNO, title, content, imageFileName, writedate, id)
 values(6, 2, '상품 후기입니다.', '이순신 상품 사용 후기를 올립니다.', null, sysdate, 'lee' );
commit;

CREATE TABLE t_imageFile (
   imageFileNO number(10) primary key,
   imageFileName varchar2(200),
   regDate date default sysdate,
   articleNO number(10),
   CONSTRAINT FK_ARTICLENO FOREIGN KEY(articleNO)
   REFERENCES t_board(articleNO) ON DELETE CASCADE
);  
-- // 2021.06.17 sy

 -- 2021.06.22 sy
-- 자유게시판 테이블 생성
DROP TABLE FREE_BOARD CASCADE CONSTRAINTS;
CREATE TABLE FREE_BOARD (
    FREE_BO_NO  number(10)  not null 
    ,PARENT_NO  number(10)  DEFAULT 0
    ,MEM_ID     VARCHAR2(20) not null 
    ,TITLE      VARCHAR2(100) not null 
    ,CONTENT    VARCHAR2(4000) not null 
    ,READ_COUNT number(30) DEFAULT 0
    ,WRITE_DATE date DEFAULT SYSDATE
    ,IS_DEL     number(1) DEFAULT 0
    ,CONSTRAINT PK_FREE_BOARD PRIMARY KEY(FREE_BO_NO)
    ,CONSTRAINT FK_FREE_BOARD FOREIGN KEY(MEM_ID) REFERENCES T_SHOPPING_MEMBER(MEMBER_ID)
    --,CONSTRAINT FK_FREE_BOARD FOREIGN KEY(MEM_ID) REFERENCES MEMBER(MEM_ID)
);
-- 자유게시판 글번호 시퀀스 생성
DROP SEQUENCE SQAFREE_BO_NO;
CREATE SEQUENCE SQAFREE_BO_NO START WITH 1 INCREMENT BY 1;
-- 자유게시판 테이블 코멘트 추가
COMMENT ON TABLE FREE_BOARD IS '(FREE_BOARD)자유게시판';
COMMENT ON COLUMN FREE_BOARD.FREE_BO_NO IS '글번호';
COMMENT ON COLUMN FREE_BOARD.PARENT_NO IS '부모 글 번호(DEFAULT 0)';
COMMENT ON COLUMN FREE_BOARD.MEM_ID IS '아이디';
COMMENT ON COLUMN FREE_BOARD.TITLE IS '글 제목';
COMMENT ON COLUMN FREE_BOARD.CONTENT IS '글 내용';
COMMENT ON COLUMN FREE_BOARD.READ_COUNT IS '조회수(DEFAULT 0)';
COMMENT ON COLUMN FREE_BOARD.WRITE_DATE IS '작성일(DEFAULT SYSDATE)';
COMMENT ON COLUMN FREE_BOARD.IS_DEL IS '삭제여부(DEFAULT 0 / 0:기본, 1:삭제)';

-- 자유게시판 이미지 파일 테이블 생성
DROP TABLE FREE_BOARD_IMG CASCADE CONSTRAINTS;
CREATE TABLE FREE_BOARD_IMG (
    FREE_BO_IMG_NO	number(10) not null 
    ,FREE_BO_NO     number(10) not null 
    ,IMG_FILENAME  	VARCHAR2(200) not null
    ,REG_DATE       DATE    DEFAULT SYSDATE
    ,IS_DEL         number(1) DEFAULT 0
    ,CONSTRAINT PK_FREE_BOARD_IMG PRIMARY KEY(FREE_BO_IMG_NO)
    ,CONSTRAINT FK_FREE_BOARD_IMG FOREIGN KEY(FREE_BO_NO) REFERENCES FREE_BOARD(FREE_BO_NO)
);
-- 자유게시판 이미지 파일 글번호 시퀀스 생성
DROP SEQUENCE SQAFREE_BO_IMG_NO;
CREATE SEQUENCE SQAFREE_BO_IMG_NO  START WITH 1 INCREMENT BY 1; 
-- 자유게시판 이미지 파일 테이블 코멘트 추가
COMMENT ON TABLE FREE_BOARD_IMG IS '(FREE_BOARD_IMG)자유게시판 이미지';
COMMENT ON COLUMN FREE_BOARD_IMG.FREE_BO_IMG_NO IS '자유게시판 이미지 파일 번호';
COMMENT ON COLUMN FREE_BOARD_IMG.FREE_BO_NO IS '글번호';
COMMENT ON COLUMN FREE_BOARD_IMG.IMG_FILENAME IS '이미지 파일 이름';
COMMENT ON COLUMN FREE_BOARD_IMG.REG_DATE IS '등록일(DEFAULT SYSDATE)';
COMMENT ON COLUMN FREE_BOARD_IMG.IS_DEL IS '삭제여부(DEFAULT 0 / 0:기본, 1:삭제)';

 -- //2021.06.22 sy








-- 공지사항 게시판
-- 공지사항 게시판 테이블 생성
DROP TABLE NOTICE_BOARD CASCADE CONSTRAINTS;
CREATE TABLE NOTICE_BOARD (
    NOTICE_BO_NO  number(10)  not null 
    ,PARENT_NO  number(10)  DEFAULT 0
    ,MEM_ID     VARCHAR2(20) not null 
    ,TITLE      VARCHAR2(100) not null 
    ,CONTENT    VARCHAR2(4000) not null 
    ,READ_COUNT number(30) DEFAULT 0
    ,WRITE_DATE date DEFAULT SYSDATE
    ,IS_DEL     number(1) DEFAULT 0
    ,CONSTRAINT PK_NOTICE_BOARD PRIMARY KEY(NOTICE_BO_NO)
    ,CONSTRAINT FK_NOTICE_BOARD FOREIGN KEY(MEM_ID) REFERENCES T_SHOPPING_MEMBER(MEMBER_ID)
);
-- 공지사항 게시판 글번호 시퀀스 생성
DROP SEQUENCE SQANOTICE_BO_NO;
CREATE SEQUENCE SQANOTICE_BO_NO START WITH 1 INCREMENT BY 1;
-- 공지사항 게시판 테이블 코멘트 추가
COMMENT ON TABLE NOTICE_BOARD IS '(NOTICE_BOARD)공지사항 게시판';
COMMENT ON COLUMN NOTICE_BOARD.NOTICE_BO_NO IS '글번호';
COMMENT ON COLUMN NOTICE_BOARD.PARENT_NO IS '부모 글 번호(DEFAULT 0)';
COMMENT ON COLUMN NOTICE_BOARD.MEM_ID IS '아이디';
COMMENT ON COLUMN NOTICE_BOARD.TITLE IS '글 제목';
COMMENT ON COLUMN NOTICE_BOARD.CONTENT IS '글 내용';
COMMENT ON COLUMN NOTICE_BOARD.READ_COUNT IS '조회수(DEFAULT 0)';
COMMENT ON COLUMN NOTICE_BOARD.WRITE_DATE IS '작성일(DEFAULT SYSDATE)';
COMMENT ON COLUMN NOTICE_BOARD.IS_DEL IS '삭제여부(DEFAULT 0 / 0:기본, 1:삭제)';

-- 공지사항 게시판 이미지 파일 테이블 생성
DROP TABLE NOTICE_BOARD_IMG CASCADE CONSTRAINTS;
CREATE TABLE NOTICE_BOARD_IMG (
    NOTICE_BO_IMG_NO	number(10) not null 
    ,NOTICE_BO_NO     number(10) not null 
    ,IMG_FILENAME  	VARCHAR2(200) not null
    ,REG_DATE       DATE    DEFAULT SYSDATE
    ,IS_DEL         number(1) DEFAULT 0
    ,CONSTRAINT PK_NOTICE_BOARD_IMG PRIMARY KEY(NOTICE_BO_IMG_NO)
    ,CONSTRAINT FK_NOTICE_BOARD_IMG FOREIGN KEY(NOTICE_BO_NO) REFERENCES NOTICE_BOARD(NOTICE_BO_NO)
);
-- 공지사항 게시판 이미지 파일 글번호 시퀀스 생성
DROP SEQUENCE SQANOTICE_BO_IMG_NO;
CREATE SEQUENCE SQANOTICE_BO_IMG_NO  START WITH 1 INCREMENT BY 1; 
-- 공지사항 게시판 이미지 파일 테이블 코멘트 추가
COMMENT ON TABLE NOTICE_BOARD_IMG IS '(NOTICE_BOARD_IMG)공지사항 게시판 이미지';
COMMENT ON COLUMN NOTICE_BOARD_IMG.NOTICE_BO_IMG_NO IS '공지사항 게시판 이미지 파일 번호';
COMMENT ON COLUMN NOTICE_BOARD_IMG.NOTICE_BO_NO IS '글번호';
COMMENT ON COLUMN NOTICE_BOARD_IMG.IMG_FILENAME IS '이미지 파일 이름';
COMMENT ON COLUMN NOTICE_BOARD_IMG.REG_DATE IS '등록일(DEFAULT SYSDATE)';
COMMENT ON COLUMN NOTICE_BOARD_IMG.IS_DEL IS '삭제여부(DEFAULT 0 / 0:기본, 1:삭제)';
commit;



-- 문의사항 게시판 테이블 생성
DROP TABLE QNA_BOARD CASCADE CONSTRAINTS;
CREATE TABLE QNA_BOARD (
    QNA_BO_NO  number(10)  not null 
    ,PARENT_NO  number(10)  DEFAULT 0
    ,MEM_ID     VARCHAR2(20) not null 
    ,TITLE      VARCHAR2(100) not null 
    ,CONTENT    VARCHAR2(4000) not null 
    ,READ_COUNT number(30) DEFAULT 0
    ,WRITE_DATE date DEFAULT SYSDATE
    ,IS_DEL     number(1) DEFAULT 0
    ,CONSTRAINT PK_QNA_BOARD PRIMARY KEY(QNA_BO_NO)
    ,CONSTRAINT FK_QNA_BOARD FOREIGN KEY(MEM_ID) REFERENCES T_SHOPPING_MEMBER(MEMBER_ID)
    --,CONSTRAINT FK_QNA_BOARD FOREIGN KEY(MEM_ID) REFERENCES MEMBER(MEM_ID)
);
-- 문의사항 게시판 글번호 시퀀스 생성
DROP SEQUENCE SQAQNA_BO_NO;
CREATE SEQUENCE SQAQNA_BO_NO START WITH 1 INCREMENT BY 1;
-- 문의사항 게시판 테이블 코멘트 추가
COMMENT ON TABLE QNA_BOARD IS '(FREE_BOARD)자유게시판';
COMMENT ON COLUMN QNA_BOARD.QNA_BO_NO IS '글번호';
COMMENT ON COLUMN QNA_BOARD.PARENT_NO IS '부모 글 번호(DEFAULT 0)';
COMMENT ON COLUMN QNA_BOARD.MEM_ID IS '아이디';
COMMENT ON COLUMN QNA_BOARD.TITLE IS '글 제목';
COMMENT ON COLUMN QNA_BOARD.CONTENT IS '글 내용';
COMMENT ON COLUMN QNA_BOARD.READ_COUNT IS '조회수(DEFAULT 0)';
COMMENT ON COLUMN QNA_BOARD.WRITE_DATE IS '작성일(DEFAULT SYSDATE)';
COMMENT ON COLUMN QNA_BOARD.IS_DEL IS '삭제여부(DEFAULT 0 / 0:기본, 1:삭제)';

-- 문의게시판 이미지 파일 테이블 생성
DROP TABLE QNA_BOARD_IMG CASCADE CONSTRAINTS;
CREATE TABLE QNA_BOARD_IMG (
    QNA_BO_IMG_NO	number(10) not null 
    ,QNA_BO_NO     number(10) not null 
    ,IMG_FILENAME  	VARCHAR2(200) not null
    ,REG_DATE       DATE    DEFAULT SYSDATE
    ,IS_DEL         number(1) DEFAULT 0
    ,CONSTRAINT PK_QNA_BOARD_IMG PRIMARY KEY(QNA_BO_IMG_NO)
    ,CONSTRAINT FK_QNA_BOARD_IMG FOREIGN KEY(QNA_BO_NO) REFERENCES QNA_BOARD(QNA_BO_NO)
);
-- 문의게시판 이미지 파일 글번호 시퀀스 생성
DROP SEQUENCE SQAQNA_BO_IMG_NO;
CREATE SEQUENCE SQAQNA_BO_IMG_NO  START WITH 1 INCREMENT BY 1; 
-- 문의게시판 이미지 파일 테이블 코멘트 추가
COMMENT ON TABLE QNA_BOARD_IMG IS '(QNA_BOARD_IMG)문의게시판 이미지';
COMMENT ON COLUMN QNA_BOARD_IMG.QNA_BO_IMG_NO IS '문의게시판 이미지 파일 번호';
COMMENT ON COLUMN QNA_BOARD_IMG.QNA_BO_NO IS '글번호';
COMMENT ON COLUMN QNA_BOARD_IMG.IMG_FILENAME IS '이미지 파일 이름';
COMMENT ON COLUMN QNA_BOARD_IMG.REG_DATE IS '등록일(DEFAULT SYSDATE)';
COMMENT ON COLUMN QNA_BOARD_IMG.IS_DEL IS '삭제여부(DEFAULT 0 / 0:기본, 1:삭제)';
commit;


-- 2021.06.23 sy 멤버 테이블 권한 컬럼 추가
ALTER TABLE T_SHOPPING_MEMBER ADD ADMIN_YN VARCHAR2(20) default 'N';
UPDATE T_SHOPPING_MEMBER
SET admin_yn='Y'
WHERE member_id='admin';
COMMIT;
-- //2021.06.23 sy 멤버 테이블 권한 컬럼 추가

-- 상품후기 게시판 테이블 생성
DROP TABLE REVIEW_BOARD CASCADE CONSTRAINTS;
CREATE TABLE REVIEW_BOARD (
    REVIEW_BO_NO  number(10)  not null 
    ,PARENT_NO  number(10)  DEFAULT 0
    ,MEM_ID     VARCHAR2(20) not null 
    ,TITLE      VARCHAR2(100) not null 
    ,CONTENT    VARCHAR2(4000) not null 
    ,READ_COUNT number(30) DEFAULT 0
    ,WRITE_DATE date DEFAULT SYSDATE
    ,IS_DEL     number(1) DEFAULT 0
    ,CONSTRAINT PK_REVIEW_BOARD PRIMARY KEY(REVIEW_BO_NO)
    ,CONSTRAINT FK_REVIEW_BOARD FOREIGN KEY(MEM_ID) REFERENCES T_SHOPPING_MEMBER(MEMBER_ID)
    --,CONSTRAINT FK_REVIEW_BOARD FOREIGN KEY(MEM_ID) REFERENCES MEMBER(MEM_ID)
);

-- 상품후기 게시판 글번호 시퀀스 생성
DROP SEQUENCE SQAREVIEW_BO_NO;
CREATE SEQUENCE SQAREVIEW_BO_NO START WITH 1 INCREMENT BY 1;
-- 상품후기 게시판 테이블 코멘트 추가
COMMENT ON TABLE REVIEW_BOARD IS '(REVIEW_BOARD)상품후기게시판';
COMMENT ON COLUMN REVIEW_BOARD.REVIEW_BO_NO IS '글번호';
COMMENT ON COLUMN REVIEW_BOARD.PARENT_NO IS '부모 글 번호(DEFAULT 0)';
COMMENT ON COLUMN REVIEW_BOARD.MEM_ID IS '아이디';
COMMENT ON COLUMN REVIEW_BOARD.TITLE IS '글 제목';
COMMENT ON COLUMN REVIEW_BOARD.CONTENT IS '글 내용';
COMMENT ON COLUMN REVIEW_BOARD.READ_COUNT IS '조회수(DEFAULT 0)';
COMMENT ON COLUMN REVIEW_BOARD.WRITE_DATE IS '작성일(DEFAULT SYSDATE)';
COMMENT ON COLUMN REVIEW_BOARD.IS_DEL IS '삭제여부(DEFAULT 0 / 0:기본, 1:삭제)';

-- 상품후기 게시판 이미지 파일 테이블 생성
DROP TABLE REVIEW_BOARD_IMG CASCADE CONSTRAINTS;
CREATE TABLE REVIEW_BOARD_IMG (
    REVIEW_BO_IMG_NO	number(10) not null 
    ,REVIEW_BO_NO     number(10) not null 
    ,IMG_FILENAME  	VARCHAR2(200) not null
    ,REG_DATE       DATE    DEFAULT SYSDATE
    ,IS_DEL         number(1) DEFAULT 0
    ,CONSTRAINT PK_REVIEW_BOARD_IMG PRIMARY KEY(REVIEW_BO_IMG_NO)
    ,CONSTRAINT FK_REVIEW_BOARD_IMG FOREIGN KEY(REVIEW_BO_NO) REFERENCES REVIEW_BOARD(REVIEW_BO_NO)
);

-- 상품후기 게시판 이미지 파일 글번호 시퀀스 생성
DROP SEQUENCE SQAREVIEW_BO_IMG_NO;
CREATE SEQUENCE SQAREVIEW_BO_IMG_NO  START WITH 1 INCREMENT BY 1; 
-- 상품후기 게시판 이미지 파일 테이블 코멘트 추가
COMMENT ON TABLE REVIEW_BOARD_IMG IS '(REVIEW_BOARD_IMG)상품후기게시판 이미지';
COMMENT ON COLUMN REVIEW_BOARD_IMG.REVIEW_BO_IMG_NO IS '상품후기게시판 이미지 파일 번호';
COMMENT ON COLUMN REVIEW_BOARD_IMG.REVIEW_BO_NO IS '글번호';
COMMENT ON COLUMN REVIEW_BOARD_IMG.IMG_FILENAME IS '이미지 파일 이름';
COMMENT ON COLUMN REVIEW_BOARD_IMG.REG_DATE IS '등록일(DEFAULT SYSDATE)';
COMMENT ON COLUMN REVIEW_BOARD_IMG.IS_DEL IS '삭제여부(DEFAULT 0 / 0:기본, 1:삭제)';




-- 2021.06.24 sy 포인트
--멤버.포인트	포인트log.포인트	오더.포인트
ALTER TABLE T_SHOPPING_ORDER ADD order_point number(10) default 0;
ALTER TABLE T_SHOPPING_MEMBER ADD member_point number(10) default 0;

-- 포인트 log 테이블 생성CREATE TABLE POINT_LOG (
DROP TABLE POINT_LOG CASCADE CONSTRAINTS;
CREATE TABLE POINT_LOG (
    POINT_LOG_NO 		number(20) not null 
    ,POINT_MONEY 		number(20)
    ,save_point_date 	date   default sysdate
    ,ORDER_SEQ_NUM 		number(20)
    ,MEMBER_ID     		VARCHAR2(20) not null 
    ,save_YN    		VARCHAR2(5) default 'N'
    ,CONSTRAINT PK_POINT_LOG PRIMARY KEY(POINT_LOG_NO) 
    ,CONSTRAINTS FK_POINT_LOG1 FOREIGN KEY (ORDER_SEQ_NUM) REFERENCES T_SHOPPING_ORDER(ORDER_SEQ_NUM)
    ,CONSTRAINTS FK_POINT_LOG2 FOREIGN KEY (MEMBER_ID) REFERENCES T_SHOPPING_MEMBER(MEMBER_ID)
);
DROP SEQUENCE SQA_POINT_LOG_NO;
CREATE SEQUENCE SQA_POINT_LOG_NO START WITH 1 INCREMENT BY 1;

COMMENT ON TABLE POINT_LOG IS '(POINT_LOG)포인트 적립 로그';
COMMENT ON COLUMN POINT_LOG.POINT_LOG_NO IS '포인트 일련번호';
COMMENT ON COLUMN POINT_LOG.POINT_MONEY IS '포인트 적립금';
COMMENT ON COLUMN POINT_LOG.save_point_date IS '적립일자(default sysdate)';
COMMENT ON COLUMN POINT_LOG.ORDER_SEQ_NUM IS '주문번호';
COMMENT ON COLUMN POINT_LOG.MEMBER_ID IS '아이디';
COMMENT ON COLUMN POINT_LOG.save_YN IS '적립여부(default N)';
-- //2021.06.24 sy 포인트


