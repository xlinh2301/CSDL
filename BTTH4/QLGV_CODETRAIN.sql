-- 5.* Danh sách học viên (mã học viên, họ tên) của lớp “K” thi môn CTRR không đạt (ở tất cả các lần thi).
SELECT A.MAHV, HOTEN
FROM (
	SELECT HV.MAHV, CONCAT(HO,' ', TEN) HOTEN, LANTHI
	FROM HOCVIEN HV
	JOIN KETQUATHI KQ ON KQ.MAHV = HV.MAHV
	WHERE KQ.MAMH = 'CTRR' AND KQ.KQUA = 'Khong Dat' AND LEFT(HV.MAHV,1) = 'K'
) A
JOIN (
	SELECT MAHV, MAX(LANTHI) LANTHIMAX FROM KETQUATHI KQ
	WHERE LEFT(MAHV,1) = 'K' AND KQ.MAMH = 'CTRR'
	GROUP BY MAHV
) B
ON A.MAHV = B.MAHV
WHERE LANTHI = LANTHIMAX

/*WITH RankedResults AS (
	SELECT DISTINCT HV.MAHV, CONCAT(HO, ' ', TEN) HOTEN, KQ.LANTHI, ROW_NUMBER() OVER (PARTITION BY KQ.MAHV ORDER BY KQ.LANTHI DESC) RowNum
	FROM HOCVIEN HV 
	JOIN KETQUATHI KQ ON KQ.MAHV = HV.MAHV
	WHERE 
		LEFT(KQ.MAHV, 1) = 'K'
		AND KQ.MAMH = 'CTRR'
		AND KQ.KQUA = 'Khong Dat'
)
SELECT MAHV, HOTEN
FROM RankedResults
WHERE RowNum = 3;*/


-- 6.Tìm tên những môn học mà giáo viên có tên “Tran KTam Thanh” dạy trong học kỳ 1 năm 2006.


-- 7.Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy trong học kỳ 1 năm 2006.


-- 8.Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So Du Lieu”.


-- 9.In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So Du Lieu”.


-- 10.Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, tên môn học) nào.


-- 11.Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 năm 2006.


-- 12.Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng chưa thi lại môn này.


-- 13.Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào.


-- 14.Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào thuộc khoa giáo viên đó phụ trách.


-- 15.Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat” hoặc thi lần thứ 2 môn CTRR được 5 điểm.


-- 16.Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm học.

-- 17.Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng).


-- 18.Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần thi).


-- 19.Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất.


-- 20.Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.


-- 21.Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa.


-- 22.Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt).


-- 23.Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho lớp đó ít nhất một môn học.


-- 24.Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.


-- 25.* Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả các lần thi).


-- 26.Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.


-- 27.Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.


-- 28.Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao nhiêu lớp.


-- 29.Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất.


-- 30.Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) nhất.


-- 31.Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1).


-- 32.* Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng).


-- 33.* Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt (chỉ xét lần thi thứ 1).


-- 34.* Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt  (chỉ xét lần thi sau cùng).


-- 35.** Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần thi sau cùng).
