-- I. Ngôn ngữ định nghĩa dữ liệu (Data Definition Language):
-- 9.	Lớp trưởng của một lớp phải là học viên của lớp đó.
--           THEM    XOA       SUA 
--LOP	      + 	  -		 +(TRGLOP)
--HOCVIEN	  -	      +      -

CREATE TRIGGER TG_LOP_CAU9 ON LOP
FOR INSERT, UPDATE
AS
BEGIN
	IF NOT EXISTS(
		SELECT * FROM INSERTED I 
		JOIN HOCVIEN HV ON HV.MALOP = I.MALOP
		WHERE I.TRGLOP = HV.MAHV
	)
	BEGIN
		PRINT N'ERROR'
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		PRINT N'Thành công!'
	END
END;

CREATE TRIGGER TG_HOCVIEN_CAU9 ON HOCVIEN
FOR DELETE
AS
BEGIN
	IF EXISTS(
		SELECT 1 FROM DELETED D 
		JOIN LOP L ON L.MALOP = D.MALOP
		WHERE D.MAHV = L.TRGLOP
	)
	BEGIN
		PRINT N'ERROR!'
        ROLLBACK; 
	END
END
GO

-- 10.	Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.
--           THEM    XOA       SUA 
--KHOA	      + 	  -		 +(TRGKHOA)
--GIAOVIEN	  -	      +      +(HOCVI)

CREATE TRIGGER TG_KHOA_C10 ON KHOA
FOR INSERT, UPDATE
AS
BEGIN
	IF NOT EXISTS(
	SELECT 1 FROM inserted I
	JOIN GIAOVIEN GV ON GV.MAKHOA = I.MAKHOA
	WHERE I.TRGKHOA = GV.MAKHOA AND GV.HOCVI IN ('TS', 'PTS')
	)
	BEGIN
		RAISERROR('Trưởng khoa phải là giáo viên thuộc khoa và có học vị "TS" hoặc "PTS"', 16, 1);
	END
END

CREATE TRIGGER TG_DEL_C10 ON GIAOVIEN
FOR DELETE
AS
BEGIN
	IF EXISTS (
		SELECT 1 FROM deleted D
		JOIN KHOA K ON K.MAKHOA = D.MAKHOA
		WHERE D.MAKHOA = K.TRGKHOA AND D.HOCVI IN ('TS', 'PTS')
	)
	BEGIN
		RAISERROR('Trưởng khoa phải là giáo viên thuộc khoa và có học vị "TS" hoặc "PTS"', 16, 1);
	END 
END

ALTER TRIGGER TG_UPDATE_C10 
ON GIAOVIEN
AFTER UPDATE
AS
BEGIN
    DECLARE @MAKHOA1 VARCHAR(4), @MAKHOA2 VARCHAR(4), @HOCVI VARCHAR(10)

    SELECT @MAKHOA1 = I.MAKHOA, @MAKHOA2 = K.MAKHOA, @HOCVI = I.HOCVI
    FROM INSERTED I
    JOIN KHOA K ON I.MAKHOA = K.TRGKHOA

    IF (@MAKHOA1 <> @MAKHOA2)
    BEGIN
        RAISERROR('ERROR! TRG KHOA PHAI LA GIAO VIEN THUOC KHOA', 16, 1);
    END
    ELSE
    BEGIN
        IF (@HOCVI <> 'TS' OR @HOCVI <> 'PTS')
        BEGIN
            RAISERROR('ERROR! TRGKHOA PHAI CO HOCVI LA "TS" HOAC "PTS"', 16, 1);
        END
        ELSE
        BEGIN
            PRINT 'SUCCESSFUL';
        END
    END
END

--TEST
UPDATE GIAOVIEN
SET HOCVI = 'PTS'
WHERE MAGV = 'GV02'

GO
--11. Học viên ít nhất là 18 tuổi.
ALTER TABLE HOCVIEN
ADD CHECK (DATEDIFF(YEAR, NGSINH, GETDATE()) >= 18)

--12. Giảng dạy một môn học ngày bắt đầu (TUNGAY) phải nhỏ hơn ngày kết thúc (DENNGAY).
ALTER TABLE GIANGDAY
ADD CHECK (TUNGAY < DENNGAY)

--13. Giáo viên khi vào làm ít nhất là 22 tuổi.
ALTER TABLE GIAOVIEN
ADD CHECK (DATEDIFF(YEAR, NGSINH, GETDATE()) >= 22)

--14. Tất cả các môn học đều có số tín chỉ lý thuyết và tín chỉ thực hành chênh lệch nhau không quá 3.
ALTER TABLE MONHOC
ADD CHECK (ABS(TCLT - TCTH) <= 3)

-- 15.	Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.
CREATE TRIGGER TG_C15
ON KETQUATHI
FOR INSERT, UPDATE
AS
	DECLARE @NGTHI SMALLDATETIME,
			@DENNGAY SMALLDATETIME

	SELECT @NGTHI=NGTHI,@DENNGAY=DENNGAY
	FROM INSERTED A,HOCVIEN B, GIANGDAY C
	WHERE A.MAHV=B.MAHV AND B.MALOP=C.MALOP AND A.MAMH=C.MAMH

	IF(@NGTHI>@DENNGAY)
		PRINT 'SUCCESSFUL!KETQUATHI HOP LE.'
	ELSE
		BEGIN
			ROLLBACK TRAN
			PRINT 'ERROR!LOP CUA HV CHUA HOC XONG MON NAY'
		END
--------
ALTER TRIGGER UPDATE_GIANGDAY_C15
ON GIANGDAY
FOR UPDATE
AS
BEGIN
	DECLARE @NGTHI SMALLDATETIME,
	@DENNGAY SMALLDATETIME

	SELECT @DENNGAY=DENNGAY FROM INSERTED
	SELECT @NGTHI = NGTHI FROM INSERTED A 
	JOIN KETQUATHI C ON C.MAMH = A.MAMH

	IF(@DENNGAY < @NGTHI)
	BEGIN
		PRINT 'SUCCESSFUL!THOA YEU CAU DENNGAY<NGTHI'
	END
	ELSE
		BEGIN
			ROLLBACK TRAN
			PRINT 'ERROR!ANH HUONG DEN KETQUATHI, NGAY_KET_THUC PHAI TRUOC HON NGAYTHI.'
		ENDEND

UPDATE GIANGDAY
SET DENNGAY = '2006-07-15'
WHERE MAGV = 'GV05'

GO

-- 16.	Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn.
CREATE TRIGGER TG_C16 ON GIANGDAY
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @SL_MONHOC INT

	SELECT @SL_MONHOC = COUNT(GD.MAMH)
	FROM GIANGDAY GD JOIN inserted I ON I.MALOP = GD.MALOP
	WHERE I.HOCKY = GD.HOCKY AND I.NAM = GD.NAM

	IF(@SL_MONHOC > 3)
	BEGIN
		PRINT 'ERROR!'
		ROLLBACK TRAN
	END
	ELSE 
		PRINT 'THANHCONG!'
END

GO

-- 17.	Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó.
CREATE TRIGGER TG_INSERT_C17 ON LOP
FOR INSERT
AS
BEGIN
   UPDATE LOP
   SET SISO = 0 
   WHERE MALOP = (SELECT MALOP FROM INSERTED)
END

CREATE TRIGGER TG_UPDATE_C17 ON LOP
FOR UPDATE
AS
BEGIN
   UPDATE LOP
   SET SISO = (SELECT SISO FROM DELECTED)
   WHERE MALOP = (SELECT MALOP FROM INSERTED)
END

GO

/* 18.	Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng một bộ 
không được giống nhau (“A”,”A”) và cũng không tồn tại hai bộ (“A”,”B”) và (“B”,”A”). */
CREATE TRIGGER TG_C18 ON DIEUKIEN
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @MAMH VARCHAR(10), @MAMH_TRUOC VARCHAR(10)

	SELECT @MAMH = MAMH, @MAMH_TRUOC = MAMH_TRUOC
	FROM DIEUKIEN

	IF(@MAMH = @MAMH_TRUOC
		OR @MAMH IN (SELECT MAMH_TRUOC FROM DIEUKIEN WHERE MAMH_TRUOC = @MAMH)
		OR @MAMH_TRUOC IN (SELECT MAMH FROM DIEUKIEN WHERE MAMH = @MAMH_TRUOC)
	)
	BEGIN
		PRINT 'ERROR!'
	END
END
GO

-- 19.	Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau.
CREATE TRIGGER TG_C19 ON GIAOVIEN
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @MUCLUONG MONEY, @MAGV CHAR(4)

	SELECT DISTINCT @MUCLUONG=A.MUCLUONG,@MAGV=B.MAGV
	FROM GIAOVIEN A, INSERTED B
	WHERE A.HOCHAM=B.HOCHAM AND A.HOCVI=B.HOCVI AND A.HESO=B.HESO AND A.MAGV<>B.MAGV
	
	UPDATE GIAOVIEN
	SET MUCLUONG=@MUCLUONG
	WHERE MAGV=@MAGV
END

GO

-- 20.	Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5.
CREATE TRIGGER TG_C20 ON KETQUATHI
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @LANTHI INT,
	@DIEM NUMERIC(4,2)
	SELECT @LANTHI=LANTHI FROM INSERTED

	IF(@LANTHI>1)
	BEGIN
		SELECT @DIEM=B.DIEM
		FROM INSERTED A,KETQUATHI B
		WHERE A.MAHV=B.MAHV AND A.MAMH=B.MAMH AND B.LANTHI=@LANTHI-1

		IF(@DIEM>=5)
		BEGIN
			ROLLBACK TRAN
			PRINT 'HV NAY DA THI DAT'
		END
	END
END
GO

-- 21.	Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học).
-- Tạo hàm kiểm tra
CREATE TRIGGER TG_C21 ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
    -- Kiểm tra ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        INNER JOIN KETQUATHI k ON i.MAHV = k.MAHV AND i.MAMH = k.MAMH AND i.LANTHI > 1
        WHERE i.NGTHI <= k.NGTHI
    )
    BEGIN
        RAISERROR('Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước.', 16, 1)
        ROLLBACK;
    END
END

GO

-- 22.	Học viên chỉ được thi những môn mà lớp của học viên đó đã học xong.
CREATE TRIGGER TG_C22
ON KETQUATHI
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @MAHV INT, @MAMH VARCHAR(10), @MALOP VARCHAR(10)

    SELECT @MAHV = MAHV, @MAMH = MAMH FROM inserted

    IF NOT EXISTS (
        SELECT 1
        FROM MONHOC MH
        JOIN GIANGDAY GD ON MH.MAMH = GD.MAMH
        WHERE GD.MALOP = (SELECT MALOP FROM HOCVIEN WHERE MAHV = @MAHV)
          AND MH.MAMH = @MAMH
    )
    BEGIN
        PRINT N'Học viên không thể thi môn chưa học xong!'
        ROLLBACK TRAN
    END
END

GO

/* 23.	Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học 
(sau khi học xong những môn học phải học trước mới được học những môn liền sau). */
CREATE TRIGGER TG_C23
ON GIANGDAY
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @MAGV VARCHAR(10), @MAMH VARCHAR(10), @TUNGAY DATE, @DENNGAY DATE

    SELECT @MAGV = MAGV, @MAMH = MAMH, @TUNGAY = TUNGAY, @DENNGAY = DENNGAY
    FROM inserted

    IF NOT EXISTS (
        SELECT 1
        FROM GIANGDAY GD1
        JOIN GIANGDAY GD2 ON GD1.MALOP = GD2.MALOP
        WHERE GD1.MAGV = @MAGV
          AND GD1.MAMH <> @MAMH
          AND GD1.TUNGAY < GD2.TUNGAY AND GD1.DENNGAY > GD2.TUNGAY
    )
    BEGIN
        PRINT 'Lỗi: Môn học phân công không thỏa mãn thứ tự giữa các môn!'
        ROLLBACK TRAN
    END
END

GO

-- 24.	Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách.
CREATE TRIGGER TG_C24
ON GIANGDAY
FOR INSERT
AS
BEGIN
    DECLARE @MAGV INT, @MAKHOA INT

    SELECT @MAGV = i.MAGV, @MAKHOA = k.MAKHOA
    FROM inserted i
    JOIN GIAOVIEN g ON i.MAGV = g.MAGV
    JOIN MONHOC m ON i.MAMH = m.MAMH
    JOIN KHOA k ON m.MAKHOA = k.MAKHOA

    IF @MAKHOA <> @MAKHOA
    BEGIN
        PRINT 'ERROR: Giáo viên không phụ trách khoa này.'
        ROLLBACK TRAN
    END
END

GO