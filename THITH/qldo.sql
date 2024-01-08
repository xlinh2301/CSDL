--1. (2 đ) Cho biết danh sách những người bán có đăng ký quảng cáo với thời hạn sử dụng từ tháng 9 đến tháng 10 năm 2006.
--Thông tin mỗi người bán cần xuất ra gồm mã người bán, họ tên, địa chỉ theo đúng thứ tự này, các dòng
--dữ liệu kết quả không được trùng nhau.	
SELECT DISTINCT NB.MaNB, HOTEN, DIACHI FROM NGUOI_BAN NB
JOIN PHIEU_DANG_KY PDK ON PDK.MaNB = NB.MaNB
JOIN CT_PDK CT ON CT.MaPDK = PDK.MaPDK
WHERE MONTH(CT.TuNgay) = 9 AND YEAR(CT.TuNgay) = 2006 AND MONTH(CT.DenNgay) = 10 AND YEAR(CT.DenNgay) = 2006

--2. (3 đ) Cho biết thông tin người bán và số ngày của lần gia hạn lâu nhất của mỗi phiếu đăng kí của họ.
--Kết quả gồm: họ tên người bán, ngày đăng kí, số ngày của lần gia hạn lâu nhất. Các dòng dữ liệu kết quả không được trùng nhau.
--Lưu ý: không xét trường hợp người bán không đăng ký hoặc không gia hạn.
SELECT HOTEN, NGAYDK, DATEDIFF(DAY, MIN(TUNGAY), MAX(DENNGAY)) AS SONGAYGIAHANLAINHAT FROM NGUOI_BAN NB
JOIN PHIEU_DANG_KY PDK ON PDK.MaNB = NB.MaNB
JOIN PHIEU_GIA_HAN PGH ON PGH.MaPDK = PDK.MaPDK
GROUP BY HOTEN, NGAYDK, PDK.MAPDK

--3. (3 đ) Cho biết những người bán có ít nhất 01 lần đăng kí trong đó đăng kí tất cả các dịch vụ hiện có.
--Thông tin người bán cần xuất gồm mã người bán, họ tên, địa chỉ theo đúng thứ tự này, các dòng dữ liệu kết quả không được trùng nhau.
SELECT MANB, HOTEN, DIACHI FROM NGUOI_BAN NB
WHERE EXISTS (
        SELECT DISTINCT PDK.MaNB
        FROM 
            PHIEU_DANG_KY PDK
        JOIN 
            CT_PDK CT ON CT.MaPDK = PDK.MaPDK
        JOIN 
            DICH_VU DV ON DV.MaDV = CT.MaDV
        WHERE 
            PDK.MaNB = NB.MaNB
            AND DV.MaDV IN (SELECT DISTINCT MaDV FROM DICH_VU)
			AND PDK.TongSoDV = (SELECT COUNT(MADV) FROM DICH_VU)
);

--4. (2 đ) Ngày bắt đầu gia hạn của 1 chi tiết phiếu đăng ký phải lớn hơn hoặc bằng ngày kết thúc đăng ký của chi tiết đó.
--Lưu ý: phải đưa ra bảng tầm ảnh hưởng và chọn viết 1 trigger.

--						THEM		SUA						XOA
--CT_PDK				+		+(DENNGAY)					-		
--PHIEU_GIA_HAN			-		+(TUNGAY, NGAYGIAHAN)		+

CREATE TRIGGER TG_PHIEUGH ON PHIEU_GIA_HAN
FOR INSERT, UPDATE
AS
BEGIN
	IF UPDATE(NgayGiaHang)
	BEGIN
		DECLARE @NGAYGIAHAN SMALLDATETIME, @DENNGAY SMALLDATETIME, @MAPDK CHAR(10)
		SELECT @NGAYGIAHAN = I.NgayGiaHang, @MAPDK = I.MaPDK FROM inserted I
		SELECT @DENNGAY = DENNGAY FROM CT_PDK CT WHERE CT.MaPDK = @MAPDK

		IF (@NGAYGIAHAN < @DENNGAY)
		BEGIN
			PRINT 'ERROR!'
			ROLLBACK TRAN
		END

		ELSE 
		BEGIN
			PRINT 'SUCCESS!'
		END
	END
END;