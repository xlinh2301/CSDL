-- CAU 1
CREATE DATABASE QLBC;	

CREATE TABLE VUNGMIEN
(
	MAVM CHAR(6) NOT NULL,
	TENVM VARCHAR(30),
	CHIEUDAIBB FLOAT,
	PRIMARY KEY(MAVM)
);


CREATE TABLE TAU
(
	SOIMO CHAR(6) NOT NULL,
	TENTAU VARCHAR(30),
	CONGDUNG VARCHAR(30),
	PRIMARY KEY(SOIMO)
);

CREATE TABLE BENCANG
(
	MABC CHAR(6) NOT NULL,
	TENBC VARCHAR(30),
	SLTOIDA INT,
	LOAIBC VARCHAR(30),
	CHIPHI MONEY,
	MAVM CHAR(6),
	PRIMARY KEY(MABC),
	CONSTRAINT FK_MAVM FOREIGN KEY(MAVM) REFERENCES VUNGMIEN(MAVM)
);

CREATE TABLE CAPCANG
(
	MABC CHAR(6) NOT NULL,
	SOIMO CHAR(6) NOT NULL,
	NGAYCC DATETIME,
	NGAYRC DATETIME,
	SOTIEN MONEY,
	PRIMARY KEY(MABC, SOIMO),
	CONSTRAINT FK_MABC FOREIGN KEY(MABC) REFERENCES BENCANG(MABC),
	CONSTRAINT FK_SOIMO FOREIGN KEY(SOIMO) REFERENCES TAU(SOIMO)
);

-- CAU 2
INSERT INTO VUNGMIEN (MAVM, TENVM, CHIEUDAIBB)
	VALUES	('VM001', 'Mien Bac', 633.88),
			('VM002', 'Mien Trung', 2089.35),
			('VM003', 'Mien Nam', 934.46);
INSERT INTO TAU (SOIMO, TENTAU, CONGDUNG)
	VALUES	('IMO101', 'CMA CGM Montmartre', 'Cho hang'),
			('IMO102', 'Taxiarchis', 'Cho dau'),
			('IMO103', 'Arafura Lily', 'Du lich');
INSERT INTO BENCANG(MABC, TENBC, SLTOIDA, LOAIBC, CHIPHI, MAVM)
	VALUES	('BC201', 'Cang Sai Gon', 100, 'Loai A', 1840000, 'VM003'),
			('BC202', 'Cang Hai Phong', 50, 'Loai B', 2314990, 'VM001'),
			('BC203', 'Cang Da Nang', 529, 'Loai A', 1820390, 'VM002');
INSERT INTO CAPCANG
	VALUES	('BC201', 'IMO101', '2023-12-01', '2023-12-02', 22080000),
			('BC201', 'IMO102', '2023-12-01', '2023-12-01 1:00', 1840000),
			('BC202', 'IMO103', '2023-12-01', '2023-12-02 23:00', 55559760);

-- CAU 3
UPDATE BENCANG
SET SLTOIDA = 500
WHERE TENBC = 'Cang Da Nang';

-- CAU 4
ALTER TABLE CAPCANG
ADD CHECK(NGAYRC >= NGAYCC);

-- CAU 5
CREATE TRIGGER TG_CAU5 ON CAPCANG
FOR UPDATE, INSERT
AS
BEGIN
	DECLARE @CHIPHI MONEY, @SOTIEN MONEY, @MABC CHAR(6), @NGAYRC DATETIME
	SELECT @CHIPHI = CHIPHI, @MABC = MABC FROM BENCANG
	SELECT @SOTIEN = SOTIEN, @NGAYRC = NGAYRC FROM inserted I WHERE I.MABC = @MABC

	UPDATE CAPCANG
	SET NGAYRC = GETDATE()

	UPDATE CAPCANG
	SET @SOTIEN = @SOTIEN + @CHIPHI
END;

-- CAU 6
SELECT BC.TENBC, T.TENTAU, CC.NGAYCC, VM.TENVM, BC.LOAIBC, VM.CHIEUDAIBB FROM BENCANG BC
JOIN VUNGMIEN VM ON VM.MAVM = BC.MAVM
JOIN CAPCANG CC ON CC.MABC = BC.MABC
JOIN TAU T ON T.SOIMO = CC.SOIMO
WHERE VM.CHIEUDAIBB > 300 AND VM.TENVM = 'Mien Nam' AND LOAIBC = 'B';

-- CAU 7
SELECT BC.MABC + '- ' + TENBC AS 'MABC-TENBC', SOIMO, CHIPHI, NGAYCC, SUM(CHIPHI) TONGCHIPHI  FROM BENCANG BC
JOIN CAPCANG CC ON CC.MABC = BC.MABC
WHERE YEAR(CC.NGAYCC) = 2024 AND MONTH(CC.NGAYCC) = 1
GROUP BY BC.MABC, TENBC, SOIMO, CHIPHI, NGAYCC

-- CAU 8
SELECT TOP 3 TENTAU, BC.MABC ,SUM(CHIPHI) TONGCHIPHI FROM BENCANG BC
JOIN CAPCANG CC ON CC.MABC = BC.MABC
JOIN TAU T ON T.SOIMO = CC.SOIMO
GROUP BY BC.MABC, TENTAU
ORDER BY SUM(CHIPHI) ASC

-- CAU 9
SELECT TENTAU, CC.MABC FROM CAPCANG CC
JOIN TAU T ON T.SOIMO = CC.SOIMO
JOIN BENCANG BC ON BC.MABC = CC.MABC
GROUP BY CC.MABC, TENTAU
ORDER BY COUNT(T.SOIMO) 

-- CAU 10
SELECT TENVM, CONGDUNG FROM VUNGMIEN VM
JOIN BENCANG BC ON BC.MAVM = VM.MAVM
JOIN CAPCANG CC ON CC.MABC = BC.MABC
JOIN TAU T ON T.SOIMO = CC.SOIMO
WHERE CONGDUNG = 'Du lich' AND CONGDUNG = 'Quan su';

-- Cau 11
SELECT TENTAU FROM TAU T
WHERE NOT EXISTS(
	SELECT * FROM CAPCANG CC
	WHERE NOT EXISTS (
		SELECT * FROM BENCANG BC
		WHERE BC.MABC = CC.MABC AND T.SOIMO = CC.SOIMO
	)
)