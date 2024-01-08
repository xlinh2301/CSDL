/* 4. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quốc” sản xuất có giá từ 30.000 đến 40.000. */
SELECT MASP, TENSP FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc' AND GIA BETWEEN 30000 AND 40000;

/*5. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” hoặc “Thai Lan” sản xuất có giá từ 30.000 đến 40.000.*/
SELECT MASP, TENSP FROM SANPHAM
WHERE (NUOCSX = 'Trung Quoc' OR NUOCSX = 'Thai Lan') AND GIA BETWEEN 30000 AND 40000;

/*6. In ra các số hóa đơn, trị giá hóa đơn bán ra trong ngày 1/1/2007 và ngày 2/1/2007.*/
SELECT SOHD, TRIGIA FROM HOADON
WHERE NGHD IN ('2007-01-01', '2007-01-02');

/*7. In ra các số hóa đơn, trị giá hóa đơn trong tháng 1/2007, sắp xếp theo ngày (tăng dần) và trị giá của hóa đơn (giảm dần).*/
SELECT SOHD, TRIGIA FROM HOADON
WHERE YEAR(NGHD) = 2007 AND MONTH(NGHD) = 1
ORDER BY NGHD ASC, TRIGIA DESC; 

/*8. In ra danh sách các khách hàng (MAKH, HOTEN) đã mua hàng trong ngày 1/1/2007.*/
SELECT KH.MAKH, KH.HOTEN FROM KHACHHANG KH
JOIN HOADON HD ON HD.MAKH = KH.MAKH
WHERE HD.NGHD = '2007-01-01';

/*9. In ra số hóa đơn, trị giá các hóa đơn do nhân viên có tên “Nguyen Van B” lập trong ngày 28/10/2006.*/
SELECT HD.SOHD, HD.TRIGIA FROM HOADON HD
JOIN KHACHHANG KH ON KH.MAKH = HD.MAKH
WHERE KH.HOTEN = 'Nguyen Van B' AND KH.NGDK = '2006-10-28';

/*10. In ra danh sách các sản phẩm (MASP,TENSP) được khách hàng có tên “Nguyen Van A” mua trong tháng 10/2006.*/
SELECT SP.MASP, SP.TENSP 
FROM KHACHHANG KH
JOIN HOADON HD ON HD.MAKH = KH.MAKH
JOIN CTHD CT ON CT.SOHD = HD.SOHD
JOIN SANPHAM SP ON SP.MASP = CT.MASP
WHERE KH.HOTEN = 'Nguyen Van A' AND MONTH(HD.NGHD) = 10 AND YEAR(HD.NGHD) = 2006;

/*11. Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”.*/
SELECT CT.SOHD FROM CTHD CT
WHERE CT.MASP = 'BB01' OR CT.MASP = 'BB02';

/*12. Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm
mua với số lượng từ 10 đến 20.*/
SELECT CT.SOHD FROM CTHD CT
WHERE CT.MASP IN ('BB01', 'BB02') AND CT.SL BETWEEN 10 AND 20;

/*13. Tìm các số hóa đơn mua cùng lúc 2 sản phẩm có mã số “BB01” và “BB02”, mỗi sản
phẩm mua với số lượng từ 10 đến 20.*/
SELECT HD.SOHD FROM HOADON HD
JOIN CTHD CT1 ON HD.SOHD = CT1.SOHD AND CT1.MASP = 'BB01' AND CT1.SL BETWEEN 10 AND 20
JOIN CTHD CT2 ON HD.SOHD = CT2.SOHD AND CT2.MASP = 'BB02' AND CT2.SL BETWEEN 10 AND 20;

/*14. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất hoặc các sản
phẩm được bán ra trong ngày 1/1/2007.*/
SELECT SP.MASP, SP.TENSP FROM SANPHAM SP
JOIN CTHD CT ON CT.MASP = SP.MASP
JOIN HOADON HD ON HD.SOHD = CT.SOHD
WHERE NUOCSX = 'Trung Quoc' OR HD.NGHD = '2007-01-01';

/*15. In ra danh sách các sản phẩm (MASP,TENSP) không bán được.*/
SELECT SP.MASP, SP.TENSP FROM SANPHAM SP
WHERE SP.MASP NOT IN ( SELECT CT.MASP FROM CTHD CT);

/*16. In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006.*/
SELECT SP.MASP, SP.TENSP FROM SANPHAM SP
WHERE SP.MASP NOT IN 
( 
	SELECT CT.MASP FROM CTHD CT
	JOIN HOADON HD ON HD.SOHD = CT.SOHD
	WHERE YEAR(HD.NGHD) = 2006
);

/*17. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất không bán được trong năm 2006.*/
SELECT SP.MASP, SP.TENSP FROM SANPHAM SP
WHERE SP.NUOCSX = 'Trung Quoc' AND SP.MASP NOT IN 
( 
	SELECT CT.MASP FROM CTHD CT
	JOIN HOADON HD ON HD.SOHD = CT.SOHD
	WHERE YEAR(HD.NGHD) = 2006
);

/*18. Tìm số hóa đơn đã mua tất cả các sản phẩm do Singapore sản xuất.*/
SELECT CT.SOHD FROM CTHD CT
JOIN SANPHAM SP ON SP.MASP = CT.MASP
WHERE SP.NUOCSX = 'Singapore'
GROUP BY CT.SOHD
HAVING COUNT(DISTINCT SP.MASP) = (SELECT COUNT(*) FROM SANPHAM SP WHERE SP.NUOCSX = 'Singapore');
