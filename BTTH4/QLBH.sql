/*19. Tìm số hóa đơn trong năm 2006 đã mua ít nhất tất cả các sản phẩm do Singapore sản xuất.*/
SELECT HD.SOHD
FROM HOADON HD
JOIN CTHD CT ON CT.SOHD = HD.SOHD
JOIN SANPHAM SP ON SP.MASP = CT.MASP
WHERE YEAR(HD.NGHD) = 2006 AND SP.NUOCSX = 'Singapore'
GROUP BY HD.SOHD
HAVING COUNT(DISTINCT SP.MASP) = (SELECT COUNT(*) FROM SANPHAM SP WHERE NUOCSX = 'Singapore');

/*20. Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua?*/
SELECT COUNT(*) AS SOHDKHONG_DKTHANHVIEN FROM HOADON HD
WHERE HD.MAKH IS NULL;

/*21. Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006.*/


/*22. Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu ?*/


/*23. Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?*/


/*24. Tính doanh thu bán hàng trong năm 2006.*/


/*25. Tìm số hóa đơn có trị giá cao nhất trong năm 2006.*/
/*26. Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006.*/
/*27. In ra danh sách 3 khách hàng đầu tiên (MAKH, HOTEN) sắp xếp theo doanh số giảm dần.*/
/*28. In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất.*/
/*29. In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1
trong 3 mức giá cao nhất (của tất cả các sản phẩm).*/
/*30. In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1
trong 3 mức giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất).*/
/*31. * In ra danh sách khách hàng nằm trong 3 hạng cao nhất (xếp hạng theo doanh số).*/
/*32. Tính tổng số sản phẩm do “Trung Quoc” sản xuất.*/
/*33. Tính tổng số sản phẩm của từng nước sản xuất.*/
/*34. Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm.*/
/*35. Tính doanh thu bán hàng mỗi ngày.*/
/*36. Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.*/
/*37. Tính doanh thu bán hàng của từng tháng trong năm 2006.*/
/*38. Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau.*/
/*39. Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau).*/
/*40. Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất.*/
/*41. Tháng mấy trong năm 2006, doanh số bán hàng cao nhất ?*/
/*42. Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.43. *Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất.*/
/*44. Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau.*/
/*45. *Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều
nhất.*/