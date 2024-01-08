/*câu 1: Tạo các quan hệ và khai báo các khóa chính, khóa ngoại của quan hệ */
USE QLBH;

CREATE TABLE KHACHHANG
(
	MAKH char(4) NOT NULL,
	HOTEN varchar(40),
	DCHI varchar(50),
	SODT varchar(20),
	NGSINH smalldatetime,
	DOANHSO money,
	NGDK smalldatetime,
	CONSTRAINT PK_KH PRIMARY KEY(MAKH)
);

CREATE TABLE NHANVIEN
(
	MANV char(4) NOT NULL,
	HOTEN varchar(40),
	SODT varchar(20),
	NGVL smalldatetime,
	CONSTRAINT PK_MANV PRIMARY KEY(MANV)
);

CREATE TABLE SANPHAM
(
	MASP char(4) NOT NULL,
	TENSP varchar(40),
	DVT varchar(20),
	NUOCSX varchar(40),
	GIA money,
	CONSTRAINT PK_SP PRIMARY KEY(MASP)
);

CREATE TABLE HOADON
(
	SOHD int NOT NULL,
	NGHD smalldatetime,
	MAKH char(4),
	MANV char(4),
	TRIGIA money
	CONSTRAINT PK_HD PRIMARY KEY(SOHD)
	CONSTRAINT FK_HD_MAKH FOREIGN KEY (MAKH) REFERENCES KHACHHANG(MAKH),
	CONSTRAINT FK_HD_MANV FOREIGN KEY (MANV) REFERENCES NHANVIEN(MANV)
);

CREATE TABLE CTHD
(
	SOHD int NOT NULL,
	MASP char(4) NOT NULL,
	SL int,
	CONSTRAINT PK_CTHD PRIMARY KEY(SOHD, MASP)
);
/*câu 2: Thêm vào thuộc tính GHICHU có kiểu dữ liệu varchar(20) cho quan hệ SANPHAM*/
ALTER TABLE SANPHAM
ADD GHICHU varchar(20);

/*câu 3: Thêm vào thuộc tính LOAIKH có kiểu dữ liệu là tinyint cho quan hệ KHACHHANG*/
ALTER TABLE KHACHHANG
ADD LOAIKH tinyint;

/*câu 4: Sửa kiểu dữ liệu của thuộc tính GHICHU trong quan hệ SANPHAM thành varchar(100).*/
ALTER TABLE SANPHAM
ALTER COLUMN GHICHU varchar(100);

/*câu 5: Xóa thuộc tính GHICHU trong quan hệ SANPHAM*/
ALTER TABLE SANPHAM
DROP COLUMN GHICHU;

/*câu 6: Làm thế nào để thuộc tính LOAIKH trong quan hệ KHACHHANG có thể lưu các giá trị là: “Vang lai”, “Thuong xuyen”, “Vip”, …*/
ALTER TABLE KHACHHANG
ALTER COLUMN LOAIKH varchar(20);

/*câu 7: Đơn vị tính của sản phẩm chỉ có thể là (“cay”,”hop”,”cai”,”quyen”,”chuc”) */
ALTER TABLE SANPHAM
ADD CONSTRAINT SP_DVT CHECK(DVT = 'cay' OR DVT = 'hop' OR DVT = 'cai' OR DVT = 'quyen' OR DVT = 'chuc');

/*câu 8: Giá bán của sản phẩm từ 500 đồng trở lên*/
ALTER TABLE SANPHAM
ADD CONSTRAINT SP_GIA CHECK(GIA >= 500);

/*câu 9: Mỗi lần mua hàng, khách hàng phải mua ít nhất 1 sản phẩm*/
ALTER TABLE CTHD
ADD CONSTRAINT CTHD_SL CHECK(SL >= 1);

/*câu 10: Ngày khách hàng đăng ký là khách hàng thành viên phải lớn hơn ngày sinh của người đó.*/
ALTER TABLE KHACHHANG
ADD CONSTRAINT KHACHHANG_NGDK_NGSINH CHECK(NGDK > NGSINH);

/*II.1: Nhập dữ liệu cho các quan hệ trên*/
/*II.2. Tạo quan hệ SANPHAM1 chứa toàn bộ dữ liệu của quan hệ SANPHAM. Tạo quan hệ KHACHHANG1 chứa toàn bộ dữ liệu của quan hệ KHACHHANG.*/
CREATE VIEW SANPHAM AS
SELECT FROM 

/*II.3. Cập nhật giá tăng 5% đối với những sản phẩm do “Thai Lan” sản xuất (cho quan hệ SANPHAM1) */


/*II.4. Cập nhật giá giảm 5% đối với những sản phẩm do “Trung Quoc” sản xuất có giá từ 10.000 trở xuống (cho quan hệ SANPHAM1). */


/*II.5. Cập nhật giá trị LOAIKH là “Vip” đối với những khách hàng đăng ký thành viên trước
ngày 1/1/2007 có doanh số từ 10.000.000 trở lên hoặc khách hàng đăng ký thành viên từ 1/1/2007 trở về 
sau có doanh số từ 2.000.000 trở lên (cho quan hệ KHACHHANG1).*/


/*III.1. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất.*/


/*III.2. In ra danh sách các sản phẩm (MASP, TENSP) có đơn vị tính là “cay”, ”quyen”.*/


/*III.3. In ra danh sách các sản phẩm (MASP,TENSP) có mã sản phẩm bắt đầu là “B” và kết thúc là “01”.*/