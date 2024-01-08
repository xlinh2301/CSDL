﻿-- CAU 1 --
CREATE DATABASE DE04
USE DE04
SET DATEFORMAT DMY

CREATE TABLE KHACHHANG
(
	MAKH CHAR(4) PRIMARY KEY,
	TENKH VARCHAR(40),
	DIACHI VARCHAR(50),
	LOAIKH CHAR(50)
)

CREATE TABLE LOAICAY
(
	MALC CHAR(4) PRIMARY KEY,
	TENLC CHAR(40),
	XUATXU CHAR(30),
	GIA MONEY
)

CREATE TABLE HOADON
(
	SOHD INT PRIMARY KEY, 
	NGHD SMALLDATETIME,
	MAKH CHAR(4) REFERENCES KHACHHANG(MAKH),
	KHUYENMAI INT
)

CREATE TABLE CTHD
(
	SOHD INT REFERENCES HOADON(SOHD),
	MALC CHAR(4) REFERENCES LOAICAY(MALC),
	SOLUONG INT,
	PRIMARY KEY(SOHD,MALC)
)
-- CAU 2 --
INSERT INTO KHACHHANG(MAKH,TENKH,DIACHI,LOAIKH) VALUES
('KH01', 'LIZ KIM CUONG', 'HA NOI', 'VANG LAI'),
('KH02', 'IVONE DIEU LINH', 'DA NANG', 'THUONG XUYEN'),
('KH03', 'EMMA NHAT KHANH', 'TP.HCM', 'VANG LAI');
INSERT INTO LOAICAY(MALC,TENLC,XUATXU,GIA) VALUES
('LC01', 'XUONG RONG TAI THO', 'MEXICO', 180000),
('LC02', 'SEN THACH NGOC', 'ANH', 300000),
('LC03', 'BA MAU RAU', 'NAM PHI', 270000);
INSERT INTO HOADON(SOHD,NGHD,MAKH,KHUYENMAI) VALUES
('00001', '22/11/2017', 'KH01', 5),
('00002', '04/12/2017', 'KH03', 5),
('00003', '10/12/2017', 'KH02', 10);
INSERT INTO CTHD(SOHD,MALC,SOLUONG) VALUES
('00001', 'LC01', 1),
('00001', 'LC02', 2),
('00003', 'LC03', 5);

-- CAU 3 -- Hiện thực ràng buộc toàn vẹn sau: Tất cả các mặt hàng xuất xứ từ nước Anh đều có giá lớn hơn 250.000đ
ALTER TABLE LOAICAY ADD CHECK (XUATXU <> 'ANH' OR  GIA > 250000)

-- CAU 4 --Hiện thực ràng buộc toàn vẹn sau: Hóa đơn mua với số lượng tổng cộng lớn hơn hoặc bằng 5 đều được giảm giá 10 phần trăm. (2đ).
--BANG TAM ANH HUONG:
--			THEM	XOA		SUA
--HOADON	 -	  	 -		 +(KHUYENMAI)
--CTHD		 +		 -		 +(SOHD,SOLUONG)
--- Giải thích thêm:
------Thêm HOADON dấu - vì lúc thêm mới một hóa đơn chưa có CTHD, bên cạnh đó người dùng muốn thêm KhuyenMai giá trị bao nhiêu cũng được.
------Xóa CTHD dấu - vì ràng buộc chỉ yêu cầu số lượng >= 5 chứ không ràng buộc < 5 thì KhuyenMai phải bằng bao nhiêu.

CREATE TRIGGER trg_upd_hoadon ON HOADON
FOR UPDATE
AS IF UPDATE(KHUYENMAI)
BEGIN
	IF EXISTS (SELECT I.SOHD FROM INSERTED I, CTHD C
				WHERE I.SOHD = C.SOHD AND I.KHUYENMAI < 10
				GROUP BY I.SOHD
				HAVING SUM(SOLUONG) >= 5)				
	BEGIN 
		RAISERROR('LOI', 16, 1)
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		PRINT('THANH CONG')
	END
END

CREATE TRIGGER trg_ins_cthd ON CTHD
FOR INSERT
AS
BEGIN
	-- Tìm những hóa đơn nào có KhuyenMai bé hơn 10 mới update
	--- những hóa đơn có KhuyenMai >= 10 sẵn thì để nguyên
	UPDATE HOADON
	SET KHUYENMAI = 10
	WHERE SOHD = (SELECT I.SOHD FROM INSERTED I, HOADON H, CTHD C
				WHERE I.SOHD = H.SOHD AND H.SOHD = C.SOHD
					AND H.KHUYENMAI < 10
				GROUP BY I.SOHD
				HAVING SUM(C.SOLUONG) >= 5))
				
	PRINT('DA CAP NHAT LAI KHUYEN MAI')
END

CREATE TRIGGER trg_upd_cthd ON CTHD
FOR UPDATE
AS IF (UPDATE(SOHD) OR UPDATE(SOLUONG))
BEGIN
	-- Tìm những hóa đơn nào có KhuyenMai bé hơn 10 mới update
	--- những hóa đơn có KhuyenMai >= 10 sẵn thì để nguyên
	UPDATE HOADON
	SET KHUYENMAI = 10
	WHERE SOHD = (SELECT I.SOHD FROM INSERTED I, HOADON H, CTHD C
				WHERE I.SOHD = H.SOHD AND H.SOHD = C.SOHD
					AND H.KHUYENMAI < 10
				GROUP BY I.SOHD
				HAVING SUM(C.SOLUONG) >= 5))
				
	PRINT('DA CAP NHAT LAI KHUYEN MAI')
END

-- CAU 5 --Tìm tất cả các hóa đơn có ngày lập hóa đơn trong quý 4 năm 2017, sắp xếp kết quả tăng dần theo phần trăm giảm giá (1đ).
SELECT * 
FROM HOADON 
WHERE MONTH(NGHD) > 9 AND YEAR(NGHD) = 2017
ORDER BY KHUYENMAI

-- CAU 6 --Tìm loại cây có số lượng mua ít nhất trong tháng 12 
SELECT TOP 1 WITH TIES MALC, SUM(SOLUONG) AS TONGSOLUONGMUA
FROM CTHD C JOIN HOADON H ON H.SOHD = C.SOHD
WHERE MONTH(NGHD) = 12
GROUP BY MALC
ORDER BY TONGSOLUONGMUA

-- CAU 7 --Tìm loại cây mà cả khách thường xuyên (LOAIKH là ‘Thuong xuyen’) và khách vãng lai (LOAIKH là ‘Vang lai’) đều mua. (1đ).
SELECT MALC 
FROM CTHD C JOIN HOADON H ON H.SOHD = C.SOHD 
	JOIN KHACHHANG K ON K.MAKH = H.MAKH
WHERE LOAIKH = 'THUONG XUYEN'
INTERSECT
SELECT MALC 
FROM CTHD C JOIN HOADON H ON H.SOHD = C.SOHD 
	JOIN KHACHHANG K ON K.MAKH = H.MAKH
WHERE LOAIKH = 'VANG LAI'

-- CAU 8 -- Tìm khách hàng đã từng mua tất cả các loại cây (1đ).
SELECT *
FROM KHACHHANG K
WHERE NOT EXISTS (
	SELECT *
	FROM LOAICAY L
	WHERE NOT EXISTS (
		SELECT *
		FROM HOADON H JOIN CTHD C ON H.SOHD = C.SOHD
		WHERE C.MALC = L.MALC AND H.MAKH = K.MAKH
	)
)


