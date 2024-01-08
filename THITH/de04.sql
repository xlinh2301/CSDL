-- CAU 3 -- Hiện thực ràng buộc toàn vẹn sau: Tất cả các mặt hàng xuất xứ từ nước Anh đều có giá lớn hơn 250.000đ
ALTER TABLE LOAICAY
ADD CONSTRAINT CK_CAU3 CHECK ((GIA <= 250000 AND XUATXU <> 'ANH') OR GIA > 250000);

-- CAU 4 --Hiện thực ràng buộc toàn vẹn sau: Hóa đơn mua với số lượng tổng cộng lớn hơn hoặc bằng 5 đều được giảm giá 10 phần trăm. (2đ).
--BANG TAM ANH HUONG:
--			THEM     XOA		    SUA
--HOADON	 -	  	  -  	     +(KHUYENMAI)	 
--CTHD		 + 	 	  -		     +(SOLUONG, SOHD)
CREATE TRIGGER TG_CAU4 ON HOADON
FOR UPDATE
AS
BEGIN
	IF EXISTS (SELECT I.SOHD FROM inserted I
		JOIN CTHD CT ON CT.SOHD = I.SOHD
		WHERE I.KHUYENMAI < 10
		GROUP BY I.SOHD
		HAVING SUM(CT.SOLUONG) >= 5)
	BEGIN 
		RAISERROR('ERROR', 16, 1)
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		PRINT N'Thành công!'
	END
END 

-- CAU 5 --Tìm tất cả các hóa đơn có ngày lập hóa đơn trong quý 4 năm 2017, sắp xếp kết quả tăng dần theo phần trăm giảm giá (1đ).
SELECT * FROM HOADON 
WHERE MONTH(NGHD) > 9 AND YEAR(NGHD) = 2007
ORDER BY KHUYENMAI ASC

-- CAU 6 --Tìm loại cây có số lượng mua ít nhất trong tháng 12 
SELECT TOP 1 MALC, SOLUONG FROM CTHD CT
JOIN HOADON HD ON HD.SOHD = CT.SOHD
WHERE MONTH(HD.NGHD) = 12
ORDER BY SOLUONG ASC

-- CAU 7 --Tìm loại cây mà cả khách thường xuyên (LOAIKH là ‘Thuong xuyen’) và khách vãng lai (LOAIKH là ‘Vang lai’) đều mua. (1đ).
SELECT DISTINCT MALC FROM CTHD CT
JOIN HOADON HD ON HD.SOHD = CT.SOHD
JOIN KHACHHANG KH ON KH.MAKH = HD.MAKH
WHERE KH.LOAIKH = 'Thuong xuyen' AND KH.LOAIKH = 'Vang lai'

-- CAU 8 -- Tìm khách hàng đã từng mua tất cả các loại cây (1đ).

