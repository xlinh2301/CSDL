--11. Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó đăng ký thành viên (NGDK).
--              THEM    XOA    SUA 
--HOADON	      +		 -		+(NGHD)
--KHACHHANG		  - 	 -		+(NGDK)
CREATE TRIGGER TRG_HD_KH_CAU11 ON HOADON FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @NGHD SMALLDATETIME, @NGDK SMALLDATETIME, @MAKH CHAR(4)
	SELECT @NGHD = NGHD, @MAKH = MAKH FROM INSERTED
	SELECT	@NGDK = NGDK FROM KHACHHANG WHERE MAKH = @MAKH

	PRINT @NGHD 
	PRINT @NGDK

	IF (@NGHD >= @NGDK)
		PRINT N'Thành công.'
	ELSE
	BEGIN
		PRINT N'Lỗi: Ngày mua hàng của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó đăng ký thành viên.'
		ROLLBACK TRANSACTION
	END
END
--TEST:
/*

UPDATE HOADON
SET NGHD = '2006-08-01'
WHERE MAKH = 'KH03'

*/

--12. Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm.
--              THEM    XOA    SUA 
--HOADON	      +		 -		+(NGHD)
--NHANVIEN		  + 	 -		+(NGVL)
----------------HOADON--------------
CREATE TRIGGER TRG_HD_NV_CAU12 ON HOADON FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @NGHD SMALLDATETIME, @NGVL SMALLDATETIME, @MANV CHAR(4)
	SELECT @NGHD = NGHD, @MANV = MANV FROM INSERTED
	SELECT	@NGVL = NGVL FROM NHANVIEN WHERE MANV = @MANV

	IF (@NGHD >= @NGVL)
		PRINT N'Thành công.'
	ELSE
	BEGIN
		PRINT N'Lỗi: Ngày bán hàng của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm.'
		ROLLBACK TRANSACTION
	END
END
GO

--TEST:
/*UPDATE HOADON
SET NGHD = '2006-04-14'
WHERE MANV = 'NV01'*/

--13. Mỗi một hóa đơn phải có ít nhất một chi tiết hóa đơn.
--              THEM    XOA    SUA 
--HOADON	      +		 -		-
--CTHD			  - 	 +		-
alter TRIGGER TRG_HD_CTHD_CAU13 ON HOADON FOR INSERT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @SOHD INT, @COUNT_SOHD INT
	SELECT @SOHD = SOHD FROM INSERTED
	SELECT @COUNT_SOHD = COUNT(SOHD) FROM CTHD WHERE SOHD = @SOHD

	IF (@COUNT_SOHD >= 1)
		PRINT N'Thêm mới một hóa đơn thành công.'
	ELSE
	BEGIN
		PRINT N'Lỗi: Mỗi một hóa đơn phải có ít nhất một chi tiết hóa đơn.'
		ROLLBACK TRANSACTION
	END
END
GO

CREATE TRIGGER TRG_HD_CTHD_DEL_CAU13 ON CTHD FOR DELETE
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @SOHD INT, @COUNT_SOHD INT
	SELECT @SOHD = SOHD FROM deleted
	SELECT @COUNT_SOHD = COUNT(SOHD) FROM CTHD WHERE SOHD = @SOHD

	IF (@COUNT_SOHD >= 1)
		PRINT N'Xóa một hóa đơn thành công.'
	ELSE
	BEGIN
		PRINT N'Lỗi: Mỗi một hóa đơn phải có ít nhất một chi tiết hóa đơn.'
		ROLLBACK TRANSACTION
	END
END
GO

--TEST:
/*UPDATE HOADON
SET TRIGIA = 36000
WHERE SOHD = '1016'

DELETE CTHD
WHERE SOHD = '1007'

INSERT INTO CTHD VALUES ('1007', 'ST03', 10)
*/

--14. Trị giá của một hóa đơn là tổng thành tiền (số lượng*đơn giá) của các chi tiết thuộc hóa đơn đó.
--              THEM    XOA    SUA 
--HOADON	      +		 -		+(TriGia)
--CTHD			  + 	 +		+(SL, DONGIA)
ALTER TRIGGER TRG_CTHD_CAU14 ON CTHD FOR INSERT
AS
BEGIN
	DECLARE @SOHD INT, @TONGGIATRI INT

	SELECT @TONGGIATRI = SUM(SL * GIA), @SOHD = SOHD 
	FROM INSERTED INNER JOIN SANPHAM
	ON INSERTED.MASP = SANPHAM.MASP
	GROUP BY SOHD

	UPDATE HOADON
	SET TRIGIA += @TONGGIATRI
	WHERE SOHD = @SOHD
END
GO 

CREATE TRIGGER TR_DEL_CTHD_CAU14 ON CTHD FOR DELETE
AS
BEGIN
	DECLARE @SOHD INT, @GIATRI INT

	SELECT @SOHD = SOHD, @GIATRI = SL * GIA 
	FROM DELETED INNER JOIN SANPHAM 
	ON SANPHAM.MASP = DELETED.MASP

	UPDATE HOADON
	SET TRIGIA -= @GIATRI
	WHERE SOHD = @SOHD
END
GO

ALTER TRIGGER TR_UPD_CTHD_C14 ON CTHD
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SOHD INT, @TRIGIACU MONEY, @TRIGIAMOI MONEY;

    SELECT @SOHD = SOHD FROM inserted;

    SELECT @TRIGIAMOI = SUM(SL*GIA)
    FROM inserted
    JOIN SANPHAM SP ON SP.MASP = inserted.MASP;

    SELECT @TRIGIACU = SUM(SL*GIA)
    FROM deleted
    JOIN SANPHAM SP ON SP.MASP = deleted.MASP;

    UPDATE HOADON
    SET TRIGIA = @TRIGIAMOI
    WHERE SOHD = @SOHD;
END;
GO

-- TEST --
/*

UPDATE CTHD
SET SL = 7
WHERE SOHD = 1023

UPDATE HOADON
SET TRIGIA = 45000
WHERE SOHD = 1024

INSERT INTO HOADON VALUES('1024','2006-07-23','KH01','NV01',45000)

INSERT INTO CTHD VALUES(1024,'BB01',5)	

DELETE CTHD
WHERE SOHD = 1024 AND MASP = 'BB01'
*/

--15. Doanh số của một khách hàng là tổng trị giá các hóa đơn mà khách hàng thành viên đó đã mua
--              THEM    XOA    SUA 
--KHACHHANG	      +		 -		+(TRIGIA)
--CTHD			  + 	 +		+(SL, SOHD)
CREATE TRIGGER TRIGGER_CAU15
ON HOADON
FOR INSERT, UPDATE, DELETE
AS
BEGIN 
	DECLARE @MAKH char(4);
	SELECT @MAKH = MAKH FROM INSERTED;
	UPDATE KHACHHANG
	SET DOANHSO = (SELECT SUM(TRIGIA) FROM HOADON
		WHERE MAKH = @MAKH)
	WHERE MAKH = @MAKH;
END

