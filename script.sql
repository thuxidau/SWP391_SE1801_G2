-- Drop database if exits
DROP DATABASE IF EXISTS DBProjectSWP391_V1;

-- Create database
CREATE DATABASE DBProjectSWP391_V1;

-- Use database
USE DBProjectSWP391_V1;

-- Setup
SET @sql = NULL;
SELECT GROUP_CONCAT('ALTER TABLE ', table_name, ' DROP FOREIGN KEY ', constraint_name, ';') INTO @sql
FROM information_schema.table_constraints
WHERE constraint_type = 'FOREIGN KEY'
AND table_schema = DATABASE();

SET @sql = NULL;
SELECT GROUP_CONCAT('DROP TABLE IF EXISTS ', table_name, ';') INTO @sql
FROM information_schema.tables
WHERE table_schema = DATABASE();

-- Create table UserRole
CREATE TABLE UserRole (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    RoleName NVARCHAR(255),
    Description NVARCHAR(255),
    CreatedAt DATE,
    UpdatedAt DATE,
    DeletedAt DATE,
    IsDelete BOOLEAN DEFAULT 0
);
-- Trigger UserRole;
DELIMITER //
CREATE TRIGGER before_UserRoles_insert
BEFORE INSERT ON UserRole
FOR EACH ROW
BEGIN
    IF NEW.UpdatedAt IS NOT NULL AND NEW.UpdatedAt < NEW.CreatedAt THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UpdatedAt cannot be before CreatedAt';
    END IF;
    IF NEW.DeletedAt IS NOT NULL AND (NEW.DeletedAt < NEW.CreatedAt OR NEW.DeletedAt < NEW.UpdatedAt) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DeletedAt cannot be before CreatedAt or UpdatedAt';
    END IF;
END;
//
CREATE TRIGGER before_UserRoles_update
BEFORE UPDATE ON UserRole
FOR EACH ROW
BEGIN
    IF NEW.UpdatedAt IS NOT NULL AND NEW.UpdatedAt < NEW.CreatedAt THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UpdatedAt cannot be before CreatedAt';
    END IF;
    IF NEW.DeletedAt IS NOT NULL AND (NEW.DeletedAt < NEW.CreatedAt OR NEW.DeletedAt < NEW.UpdatedAt) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DeletedAt cannot be before CreatedAt or UpdatedAt';
    END IF;
END;
//
DELIMITER ;


-- Create tabale user
CREATE TABLE User (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName NVARCHAR(55),
    LastName NVARCHAR(55),
    Email VARCHAR(55),
    Phone VARCHAR(10),
    UserBalance DOUBLE DEFAULT 0,
    RoleID INT DEFAULT 2,
    IsMember Boolean default False,
    GetNotifications Boolean default False,
    CreatedAt DATE,
    UpdatedAt DATE,
    DeletedAt DATE,
    IsDelete BOOLEAN DEFAULT 0,
    DeletedBy INT,
    FOREIGN KEY (RoleID) REFERENCES UserRole(ID)
);

-- Trigger User;
DELIMITER //
CREATE TRIGGER before_Users_insert
BEFORE INSERT ON User
FOR EACH ROW
BEGIN
	IF NEW.UserBalance < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UserBalance cannot be negative';
    END IF;
    IF NEW.UpdatedAt IS NOT NULL AND NEW.UpdatedAt < NEW.CreatedAt THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UpdatedAt cannot be before CreatedAt';
    END IF;
    IF NEW.DeletedAt IS NOT NULL AND (NEW.DeletedAt < NEW.CreatedAt OR NEW.DeletedAt < NEW.UpdatedAt) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DeletedAt cannot be before CreatedAt or UpdatedAt';
    END IF;
END;
//
CREATE TRIGGER before_Users_update
BEFORE UPDATE ON User
FOR EACH ROW
BEGIN
	IF NEW.UserBalance < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UserBalance cannot be negative';
    END IF;
    IF NEW.UpdatedAt IS NOT NULL AND NEW.UpdatedAt < NEW.CreatedAt THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UpdatedAt cannot be before CreatedAt';
    END IF;
    IF NEW.DeletedAt IS NOT NULL AND (NEW.DeletedAt < NEW.CreatedAt OR NEW.DeletedAt < NEW.UpdatedAt) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DeletedAt cannot be before CreatedAt or UpdatedAt';
    END IF;
END;
//
DELIMITER ;

-- Create table authentication
CREATE TABLE Authentication (
	ID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT,
    UserKey VARCHAR(40), -- Username / GoogleID
    PassWord VARCHAR(255),
    VerifyEmail VARCHAR(40),
    CreatedAt DATE,
    UpdatedAt DATE,
    DeletedAt DATE,
    IsDelete BOOLEAN DEFAULT 0,
    DeletedByID INT,
    FOREIGN KEY (UserID) REFERENCES User(ID) 
);

-- Trigger authentication
DELIMITER //
CREATE TRIGGER before_Authentication_insert
BEFORE INSERT ON Authentication
FOR EACH ROW
BEGIN
    IF NEW.UpdatedAt IS NOT NULL AND NEW.UpdatedAt < NEW.CreatedAt THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UpdatedAt cannot be before CreatedAt';
    END IF;
    IF NEW.DeletedAt IS NOT NULL AND (NEW.DeletedAt < NEW.CreatedAt OR NEW.DeletedAt < NEW.UpdatedAt) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DeletedAt cannot be before CreatedAt or UpdatedAt';
    END IF;
END;
//
CREATE TRIGGER before_Authentication_update
BEFORE UPDATE ON Authentication
FOR EACH ROW
BEGIN
    IF NEW.UpdatedAt IS NOT NULL AND NEW.UpdatedAt < NEW.CreatedAt THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UpdatedAt cannot be before CreatedAt';
    END IF;
    IF NEW.DeletedAt IS NOT NULL AND (NEW.DeletedAt < NEW.CreatedAt OR NEW.DeletedAt < NEW.UpdatedAt) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DeletedAt cannot be before CreatedAt or UpdatedAt';
    END IF;
END;
//
DELIMITER ;

-- Create table brands
CREATE TABLE Brands (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    BrandName NVARCHAR(50),
    Image VARCHAR(40),
    CreatedAt DATE,
    UpdatedAt DATE,
    DeletedAt DATE,
    IsDelete BOOLEAN,
    DeletedBy INT
);

-- Create table ProductCategories
CREATE TABLE ProductCategories (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    BrandID INT,
    Name NVARCHAR(40),
    Price DOUBLE CHECK (Price >= 0),
    Image VARCHAR(40),
    Quantity INT CHECK (Quantity >= 0),
    Description NVARCHAR(255),
    Discount DOUBLE,
    DiscountFrom DATE,
    DiscountTo DATE,
    CreatedAt DATE,
    UpdatedAt DATE,
    DeletedAt DATE,
    IsDelete BOOLEAN,
    DeletedBy INT,
    FOREIGN KEY (BrandID) REFERENCES Brands(ID),
    CONSTRAINT chk_discount_range CHECK (Discount >= 0 AND Discount <= 30),
    CONSTRAINT chk_discount_date CHECK (DiscountFrom < DiscountTo),
    CONSTRAINT chk_deleted_by CHECK (DeletedBy IS NULL OR IsDelete = TRUE)
);


-- Create table ProductCard
CREATE TABLE ProductCard (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ProductCategoriesID INT,
    Seri VARCHAR(20),
    Code VARCHAR(20),
    CreatedAt DATE,
    ExpiredDate DATE,
    UpdatedAt DATE,
    DeletedAt DATE,
    IsDelete BOOLEAN,
    DeletedBy INT,
    FOREIGN KEY (ProductCategoriesID) REFERENCES ProductCategories(ID)
);

-- Create table Cart
CREATE TABLE Cart (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    CreatedAt DATE,
    UpdatedAt DATE,
    DeletedAt DATE,
    IsDelete BOOLEAN,
    DeletedBy INT,
    FOREIGN KEY (UserID) REFERENCES User(ID)
);

-- Create table CartItem
CREATE TABLE CartItem (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    CartID INT NOT NULL,
    ProductCategoriesID INT NOT NULL,
    Quantity INT NOT NULL,
    CreatedAt DATE,
    UpdatedAt DATE,
    DeletedAt DATE,
    IsDelete BOOLEAN,
    DeletedBy INT,
    FOREIGN KEY (CartID) REFERENCES Cart(ID),
    FOREIGN KEY (ProductCategoriesID) REFERENCES ProductCategories(ID),
    CONSTRAINT chk_quantity CHECK (Quantity > 0)
);

-- Create table Orders
CREATE TABLE Orders (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT,
    TotalQuantity INT,
    TotalAmount DOUBLE,
    Status VARCHAR(15) CHECK (Status IN ('Paid', 'Unpaid')),
    CreatedAt DATE,
    UpdatedAt DATE,
    DeletedAt DATE,
    IsDelete BOOLEAN,
    DeletedBy INT,
    FOREIGN KEY (UserID) REFERENCES User(ID),
    CONSTRAINT chk_total_quantity CHECK (TotalQuantity > 0),
    CONSTRAINT chk_total_amount CHECK (TotalAmount >= 0)
);

-- Create table Orders
CREATE TABLE OrderDetails (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    ProductCategoriesID INT,
    ProductCategoriesName NVARCHAR(55),
    BrandName NVARCHAR(55),
    ProductCardID INT,
    ProductPrice DOUBLE,
    Discount DOUBLE,
    Amount Double,
    FOREIGN KEY (OrderID) REFERENCES Orders(ID),
    FOREIGN KEY (ProductCategoriesID) REFERENCES ProductCategories(ID),
    FOREIGN KEY (ProductCardID) REFERENCES ProductCard(ID),
    CONSTRAINT chk_product_price CHECK (ProductPrice >= 0),
    CONSTRAINT chk_discount CHECK (Discount >= 0)
);

-- Create table ReportProductCard
CREATE TABLE ReportProductCard ( 
	ID INT auto_increment primary key,
    UserID INT,
    OrderDetailID INT,
    ProductCardID INT,
    ProductCategoriesName NVARCHAR(55),-- THÊM ĐỂ LOG
    BrandName NVARCHAR(55),-- THÊM ĐỂ LOG
    Status NVARCHAR(55) CHECK (Status IN ('Replied & Compensated', 'Replied & No compensation','No repli & No compensation yet')),
    CreatedAt DATE,
    UpdatedAt DATE,
    DeletedAt DATE,
    IsDelete BOOLEAN,
    DeletedBy INT,
    AcceptBy INT,
	FOREIGN KEY (UserID) REFERENCES User(ID),
    FOREIGN KEY (ProductCardID) REFERENCES ProductCard(ID),
    FOREIGN KEY (OrderDetailID) REFERENCES OrderDetails(ID)
);

-- Create table Comment
CREATE TABLE Comment (
	ID INT auto_increment primary key,
    UserID INT,
    ProductCategoriesID INT,
	ProductCategoriesName NVARCHAR(55),-- THÊM ĐỂ LOG
    BrandName NVARCHAR(55), -- THÊM ĐỂ LOG
    Title NVARCHAR(55),
    Message NVARCHAR(300),
    CreatedAt DATE,
    UpdatedAt DATE,
    DeletedAt DATE,
    IsDelete BOOLEAN,
    DeletedBy INT,
	FOREIGN KEY (UserID) REFERENCES User(ID),
    FOREIGN KEY (ProductCategoriesID) REFERENCES ProductCategories(ID)
);


-- Create table Transaction
CREATE TABLE Transaction (
	ID INT auto_increment primary key,
    UserID INT,
    OrderID INT,
    Amount decimal,
    Type NVARCHAR(55) CHECK (Type IN ('Deposit', 'Payment')),
    PaymentCode VARCHAR(55),
    BankCode VARCHAR(55),
	Status NVARCHAR(55) CHECK (Status IN ('Pending','Failed', 'Success')),
    CreatedAt DATE,
    UpdatedAt DATE,
    DeletedAt DATE,
    IsDelete BOOLEAN,
    DeletedBy INT,
    FOREIGN KEY (UserID) REFERENCES User(ID),
	FOREIGN KEY (OrderID) REFERENCES Orders(ID)
);
-- ========================================================== Bổ sung


-- Create table CategoriesNews
CREATE TABLE CategoriesNews (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Title NVARCHAR(55) NOT NULL,          -- Tên của danh mục
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Thời gian tạo
    UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Thời gian cập nhật
    DeletedAt DATETIME,                   -- Thời gian xóa
    IsDelete BOOLEAN DEFAULT FALSE,       -- Trạng thái xóa
    DeletedBy INT                         -- Người xóa
);

-- Create table News
CREATE TABLE News (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Title NVARCHAR(55) NOT NULL,          -- Tiêu đề bài viết
    Description NVARCHAR(500),            -- Mô tả ngắn về bài viết
    ContentFirst NVARCHAR(500),               -- Nội dung bài viết
    ContentBody NVARCHAR(2000), 
    ContentEnd NVARCHAR(500), 
    CategoriesID INT NOT NULL,            -- ID danh mục bài viết
    Hotnews Boolean default False,        -- Hotnews
    Image VARCHAR(50),
    DescriptionImage VARCHAR(55),
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Thời gian tạo
    UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Thời gian cập nhật
    DeletedAt DATETIME,                   -- Thời gian xóa
    IsDelete BOOLEAN DEFAULT FALSE,       -- Trạng thái xóa
    DeletedBy INT,                        -- Người xóa
    FOREIGN KEY (CategoriesID) REFERENCES CategoriesNews(ID) -- Khóa ngoại tham chiếu đến bảng CategoriesNews
);

CREATE TABLE RegiterNotification (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name NVARCHAR(100), 
    Email NVARCHAR(100),            
    Message NVARCHAR(200),       
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    DeletedAt DATETIME,                   
    IsDelete BOOLEAN DEFAULT FALSE,       
    DeletedBy INT                        
);


CREATE TABLE CommentNews (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name NVARCHAR(100), 
    Email NVARCHAR(100),            
    Message NVARCHAR(200), 
    NewsID INT,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    DeletedAt DATETIME,                   
    IsDelete BOOLEAN DEFAULT FALSE,       
    DeletedBy INT,
	FOREIGN KEY (NewsID) REFERENCES News(ID) 
);

CREATE TABLE Voucher (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Title NVARCHAR(100) NOT NULL,
    PurchaseOffer NVARCHAR(200),
    ApplyDescription NVARCHAR(500),
    Image VARCHAR(50),
    ApplyBrandID INT,
    ApplyProductID INT,
    FromDate DATE NOT NULL,
    ToDate DATE NOT NULL,
    PriceFrom DOUBLE NOT NULL,
    Discount DOUBLE NOT NULL,
    DiscountMax Double NOT NULL,
    Quantity int,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    DeletedAt DATETIME,                   
    IsDelete BOOLEAN DEFAULT FALSE,       
    DeletedBy INT
);


CREATE TABLE GetVoucher (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    VoucherID INT NOT NULL,
    UserID INT NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    DeletedAt DATETIME,                   
    IsDelete BOOLEAN DEFAULT FALSE,       
    DeletedBy INT,
    FOREIGN KEY (VoucherID) REFERENCES Voucher(ID),
    FOREIGN KEY (UserID) REFERENCES User(ID)
);


-- =============================================
CREATE TABLE FavoriteProduct (
	ID INT auto_increment primary key,
    UserID INT,
    ProductCategoriesID INT,
    CreatedAt DATE,
    UpdatedAt DATE,
    DeletedAt DATE,
    IsDelete BOOLEAN,
    DeletedBy INT,
	FOREIGN KEY (UserID) REFERENCES User(ID),
    FOREIGN KEY (ProductCategoriesID) REFERENCES ProductCategories(ID)
);

CREATE TABLE RegisterMember (
	ID INT auto_increment primary key,
    UserID INT,
    Email1 varchar(50) NOT NULL,
    Email2 varchar(50) NOT NULL,
    Message nvarchar(100),
    CreatedAt DATE,
    UpdatedAt DATE,
    DeletedAt DATE,
    IsDelete BOOLEAN,
    DeletedBy INT,
	FOREIGN KEY (UserID) REFERENCES User(ID)
);

-- =====Sơn đỗ
CREATE TABLE NameAgreementPolicy (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name NVARCHAR(55),
    Status NVARCHAR(55) CHECK (Status IN ('Active','Inactive')),
    CreatedAt DATE,
    UpdatedAt DATE,
    DeletedAt DATE,
    IsDelete BOOLEAN DEFAULT 0
);

CREATE TABLE AgreementPolicy (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    IDNameAgreementPolicy int,
    Message NVARCHAR(3000),
    CreatedAt DATE,
    UpdatedAt DATE,
    DeletedAt DATE,
    IsDelete BOOLEAN DEFAULT 0,
    FOREIGN KEY (IDNameAgreementPolicy) REFERENCES NameAgreementPolicy(ID)
);



-- Insert database hieu:
CREATE TABLE withdrawal_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT(11) NOT NULL,
    account_number VARCHAR(50) NOT NULL,
    bank_name VARCHAR(100) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(ID)
);

ALTER TABLE withdrawal_requests
ADD COLUMN transaction_details TEXT;

-- ==========================================================
-- TRIGGER;

-- Trigger to update Quantity on insert into ProductCard
DELIMITER //

-- Trigger for AFTER INSERT on ProductCard
CREATE TRIGGER ProductCard_AfterInsert
AFTER INSERT ON ProductCard
FOR EACH ROW
BEGIN
    DECLARE brandIsDeleted BOOLEAN;
    
    SELECT b.IsDelete INTO brandIsDeleted
    FROM ProductCategories pc
    JOIN brands b ON pc.BrandID = b.ID
    WHERE pc.ID = NEW.ProductCategoriesID;
    
    IF NEW.IsDelete = FALSE AND brandIsDeleted = FALSE THEN
        UPDATE ProductCategories
        SET Quantity = Quantity + 1
        WHERE ID = NEW.ProductCategoriesID;
    END IF;
END //

-- Trigger for AFTER DELETE on ProductCard
CREATE TRIGGER ProductCard_AfterDelete
AFTER DELETE ON ProductCard
FOR EACH ROW
BEGIN
    DECLARE brandIsDeleted BOOLEAN;
    
    SELECT b.IsDelete INTO brandIsDeleted
    FROM ProductCategories pc
    JOIN brands b ON pc.BrandID = b.ID
    WHERE pc.ID = OLD.ProductCategoriesID;
    
    IF OLD.IsDelete = FALSE AND brandIsDeleted = FALSE THEN
        UPDATE ProductCategories
        SET Quantity = Quantity - 1
        WHERE ID = OLD.ProductCategoriesID;
    END IF;
END //

-- Trigger for AFTER UPDATE on ProductCard
-- CREATE TRIGGER ProductCard_AfterUpdate
-- AFTER UPDATE ON ProductCard
-- FOR EACH ROW
-- BEGIN
--     DECLARE brandIsDeleted BOOLEAN;
--     
--     SELECT b.IsDelete INTO brandIsDeleted
--     FROM ProductCategories pc
--     JOIN brands b ON pc.BrandID = b.ID
--     WHERE pc.ID = NEW.ProductCategoriesID;
--     
--     IF OLD.IsDelete != NEW.IsDelete AND brandIsDeleted = FALSE THEN
--         IF OLD.IsDelete = TRUE AND NEW.IsDelete = FALSE THEN
--             UPDATE ProductCategories
--             SET Quantity = Quantity + 1
--             WHERE ID = NEW.ProductCategoriesID;
--         ELSEIF OLD.IsDelete = FALSE AND NEW.IsDelete = TRUE THEN
--             UPDATE ProductCategories
--             SET Quantity = Quantity - 1
--             WHERE ID = NEW.ProductCategoriesID;
--         END IF;
--     END IF;
-- END //
CREATE TRIGGER ProductCard_AfterUpdate
AFTER UPDATE ON ProductCard
FOR EACH ROW
BEGIN
    DECLARE brandIsDeleted BOOLEAN;
    
    SELECT b.IsDelete INTO brandIsDeleted
    FROM ProductCategories pc
    JOIN brands b ON pc.BrandID = b.ID
    WHERE pc.ID = NEW.ProductCategoriesID;
    
    IF OLD.IsDelete != NEW.IsDelete AND brandIsDeleted = FALSE THEN
        IF OLD.IsDelete = TRUE AND NEW.IsDelete = FALSE THEN
            UPDATE ProductCategories
            SET Quantity = Quantity + 1
            WHERE ID = NEW.ProductCategoriesID;
        ELSEIF OLD.IsDelete = FALSE AND NEW.IsDelete = TRUE THEN
            UPDATE ProductCategories
            SET Quantity = Quantity - 1
            WHERE ID = NEW.ProductCategoriesID;
        END IF;
    END IF;

    -- Reset discount if the expiration date is over
    IF NEW.ExpiredDate < CURDATE() THEN
    -- Set IsDelete to TRUE and DeletedAt to current date in ProductCard
        UPDATE ProductCard
        SET IsDelete = TRUE, DeletedAt = NOW()
        WHERE ID = NEW.ID;
        UPDATE ProductCategories
        SET Discount = 0, DiscountFrom = NULL, DiscountTo = NULL
        WHERE ID = NEW.ProductCategoriesID;
    END IF;
END //

DELIMITER ;

-- Trigger for updating brands
DELIMITER $$

CREATE TRIGGER Brand_AfterUpdate
AFTER UPDATE ON brands
FOR EACH ROW
BEGIN
    IF NEW.IsDelete = TRUE AND OLD.IsDelete = FALSE THEN
        -- Update the ProductCard entries associated with the ProductCategories of the brand
        UPDATE ProductCard p
        JOIN ProductCategories c ON p.ProductCategoriesID = c.ID
        SET p.DeletedAt = NOW(), p.IsDelete = TRUE, p.DeletedBy = NEW.DeletedBy
        WHERE c.BrandID = NEW.ID;

        -- Update the ProductCategories associated with the brand
        UPDATE ProductCategories
        SET DeletedAt = NOW(), IsDelete = TRUE, DeletedBy = NEW.DeletedBy
        WHERE BrandID = NEW.ID;
    END IF;
END $$

DELIMITER ;

-- Insert data ex to database

-- use database
USE DBProjectSWP391_V1;

-- Insert data to UserRole
INSERT INTO UserRole (RoleName, Description, CreatedAt, UpdatedAt)
VALUES ('Admin', 'Administrator role', NOW(), NULL);
INSERT INTO UserRole (RoleName, Description, CreatedAt, UpdatedAt)
VALUES ('User', 'User role', NOW(), NULL);


-- Insert data to User
INSERT INTO User (FirstName, LastName, Email, Phone, UserBalance, RoleID, CreatedAt, UpdatedAt)
VALUES
('Dung', 'Pham', 'DungPAHE173131@fpt.edu.vn', '0981153101', 500000000, 1, '2023-07-25', NULL),
('Son', 'Do', 'SonDHHE170206@fpt.edu.vn', '0867085558', 500000000, 2, '2024-07-10', NULL),
('Hieu', 'Nguyen', 'HieuNQHE171297@fpt.edu.vn', '0967553328', 500000000, 2, '2024-07-12', NULL),
('Thu', 'Doan', 'ThuDLHE180404@fpt.edu.vn', '0914582004', 500000000, 2, '2024-07-20', NULL),
('Dat', 'Hoang', 'DatHTHE173228@fpt.edu.vn', '0984545555', 500000000, 2,'2024-07-07', NULL),
('Dung', 'Le', 'DungLTHE163788@fpt.edu.vn', '0914582004', 500000000, 2, '2024-07-10', NULL),

('Viet', 'Hoang', 'VietHDQHE170021@fpt.edu.vn', '0914582004', 500000, 2, '2024-02-27', NULL),
('Nam', 'Nguyen', 'NamNHHE170026@fpt.edu.vn', '0914582004', 500000, 2,'2024-02-27', NULL),
('Son', 'Do', 'SonDTHE171352@fpt.edu.vn', '0914582004', 500000, 2,'2024-02-27', NULL),
('Nam', 'Pham', 'NamNHHE1713828@fpt.edu.vn', '0914582004', 500000, 2, '2024-02-27', NULL),
('Hai', 'Bui', 'HaiBMHE171522@fpt.edu.vn', '0914582004', 500000, 2, '2024-02-27', NULL),

('Thanh', 'Chu', 'ThanhCVHE171649@fpt.edu.vn', '0914582004', 500000, 2,'2024-03-27', NULL),
('Dong', 'Truong', 'DongDTHE171684@fpt.edu.vn', '0914582004', 500000, 2, '2024-03-27', NULL),
('Cuong', 'Le', 'CuongLVHE171920@fpt.edu.vn', '0914582004', 500000, 2, '2024-03-27', NULL),
('Quang', 'Le', 'QuangLVHE171994@fpt.edu.vn', '0914582004', 500000, 2, '2024-03-27', NULL),
('Huy', 'Ngo', 'HuyNLHE172025@fpt.edu.vn', '0914582004', 500000, 2, '2024-03-27', NULL),

('Thang', 'Vuong', 'ThangVSHE172065@fpt.edu.vn', '0914582004', 500000, 2, '2024-04-27', NULL),
('Trung', 'Dinh', 'TrungDQHE172761@fpt.edu.vn', '0914582004', 500000, 2, '2024-04-27', NULL),
('Hoang', 'Que', 'HoangQXHE173031@fpt.edu.vn', '0914582004', 500000, 2, '2024-04-27', NULL),
('Duc', 'Hoang', 'DucHMHE173344@fpt.edu.vn', '0914582004', 500000, 2, '2024-04-27', NULL),
('Khanh', 'Hoang', 'KhanhHNHE173434@fpt.edu.vn', '0914582004', 500000, 2, '2024-04-27', NULL),

('Huy', 'Ngo', 'HuyNMHE176493@fpt.edu.vn', '0914582004', 500000, 2, '2024-04-27', NULL),
('An', 'Nguyen', 'AnNDHE176533@fpt.edu.vn', '0914582004', 500000, 2, '2024-04-27', NULL),
('Khanh', 'Luu', 'KhanhLGHE180423@fpt.edu.vn', '0914582004', 500000, 2, '2024-04-27', NULL),
('Nhat', 'Ta', 'NhatTMHE181227@fpt.edu.vn', '0914582004', 500000, 2, '2024-05-27', NULL),
('Anh', 'Nguyen', 'AnhNTHE182498@fpt.edu.vn', '0914582004', 500000, 2, '2024-05-27', NULL),

('Hung', 'Vo', 'HungVDHE186864@fpt.edu.vn', '0914582004', 500000, 2, '2024-05-27', NULL),
('Ngoc', 'Nghiem', 'NgocNTHHE186888@fpt.edu.vn', '0914582004', 500000, 2,'2024-06-27', NULL),
('Quan', 'Nguyen', 'QuanNTHE187203@fpt.edu.vn', '0914582004', 500000, 2, '2024-06-27', NULL),
('Hung', 'Le', 'HungLPHS171183@fpt.edu.vn', '0914582004', 500000, 2, '2024-06-27', NULL);













-- Insert data to Authentication
INSERT INTO Authentication (UserID, UserKey, PassWord, CreatedAt, UpdatedAt)
VALUES 
(1, 'dungpham123', '123456', NOW(), NULL),
(2, 'sondo123', '123456', NOW(), NULL),
(3, 'hieunguyen123', '123456', NOW(), NULL),
(4, 'thudoan123', '123456', NOW(), NULL),
(5, 'dathoang123', '123456', NOW(), NULL),

(6, 'dungle123', '123456', NOW(), NULL),
(7, 'viethoang123', '123456', NOW(), NULL),
(8, 'namnguyen123', '123456', NOW(), NULL),
(9, 'sondo1234', '123456', NOW(), NULL),
(10, 'nampham123', '123456', NOW(), NULL),
(11, 'haibui123', '123456', NOW(), NULL),

(12, 'thanhchu123', '123456', NOW(), NULL),
(13, 'dongtruong123', '123456', NOW(), NULL),
(14, 'cuongle123', '123456', NOW(), NULL),
(15, 'quangle123', '123456', NOW(), NULL),
(16, 'huyngo123', '123456', NOW(), NULL),

(17, 'thangvuong123', '123456', NOW(), NULL),
(18, 'trungdinh123', '123456', NOW(), NULL),
(19, 'hoangque123', '123456', NOW(), NULL),
(20, 'duchoang123', '123456', NOW(), NULL),
(21, 'khanhhoang123', '123456', NOW(), NULL),

(22, 'huyngo1234', '123456', NOW(), NULL),
(23, 'annguyen123', '123456', NOW(), NULL),
(24, 'khanhluu123', '123456', NOW(), NULL),
(25, 'nhatta123', '123456', NOW(), NULL),
(26, 'anhnguyen123', '123456', NOW(), NULL),

(27, 'hungvo123', '123456', NOW(), NULL),
(28, 'ngocnghiem123', '123456', NOW(), NULL),
(29, 'quannguyen123', '123456', NOW(), NULL),
(30, 'hungle123', '123456', NOW(), NULL);

-- Insert data to Brands
INSERT INTO Brands (BrandName, Image, CreatedAt, UpdatedAt, DeletedAt, IsDelete, DeletedBy)
VALUES 
('Viettel', 'viettel_logo.jpg', NOW(), NULL, NULL, FALSE, NULL),
('Mobiphone', 'mobiphone_logo.jpg',NOW(), NULL, NULL, FALSE, NULL),
('Vinaphone', 'vinaphone_logo.jpg',NOW(), NULL, NULL, FALSE, NULL),
('Vietnamobi', 'vietnamobi_logo.jpg',NOW(), NULL, NULL, FALSE, NULL),
('Garena', 'garena_logo.jpg', NOW(),NULL, NULL, FALSE, NULL),
('Itel','itel_logo.jpg', NOW(), NULL, NULL, FALSE, NULL),
('Zing', 'zing_logo.jpg',NOW(), NULL, NULL, FALSE, NULL);

-- Insert data to ProductCategories
INSERT INTO ProductCategories (BrandID, Name, Price, Image, Quantity, Description, Discount, DiscountFrom, DiscountTo, CreatedAt, UpdatedAt, DeletedAt, IsDelete, DeletedBy)
VALUES 
    -- Viettel
(1, 'Thẻ 10.000 VNĐ - Viettel', 10000, 'viettel_logo.jpg', 0, 'Thẻ nạp 10.000 VNĐ của Viettel', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(1, 'Thẻ 20.000 VNĐ - Viettel', 20000, 'viettel_logo.jpg', 0, 'Thẻ nạp 20.000 VNĐ của Viettel', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(1, 'Thẻ 50.000 VNĐ - Viettel', 50000, 'viettel_logo.jpg', 0, 'Thẻ nạp 50.000 VNĐ của Viettel', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(1, 'Thẻ 100.000 VNĐ - Viettel', 100000, 'viettel_logo.jpg', 0, 'Thẻ nạp 100.000 VNĐ của Viettel', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(1, 'Thẻ 200.000 VNĐ - Viettel', 200000, 'viettel_logo.jpg', 0, 'Thẻ nạp 200.000 VNĐ của Viettel', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(1, 'Thẻ 500.000 VNĐ - Viettel', 500000, 'viettel_logo.jpg', 0, 'Thẻ nạp 500.000 VNĐ của Viettel', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
    -- Mobiphone
(2, 'Thẻ 10.000 VNĐ - Mobiphone', 10000, 'mobiphone_logo.jpg', 0, 'Thẻ nạp 10.000 VNĐ của Mobiphone', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(2, 'Thẻ 20.000 VNĐ - Mobiphone', 20000, 'mobiphone_logo.jpg', 0, 'Thẻ nạp 20.000 VNĐ của Mobiphone', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(2, 'Thẻ 50.000 VNĐ - Mobiphone', 50000, 'mobiphone_logo.jpg', 0, 'Thẻ nạp 50.000 VNĐ của Mobiphone', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(2, 'Thẻ 100.000 VNĐ - Mobiphone', 100000, 'mobiphone_logo.jpg', 0, 'Thẻ nạp 100.000 VNĐ của Mobiphone', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(2, 'Thẻ 200.000 VNĐ - Mobiphone', 200000, 'mobiphone_logo.jpg', 0, 'Thẻ nạp 200.000 VNĐ của Mobiphone', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(2, 'Thẻ 500.000 VNĐ - Mobiphone', 500000, 'mobiphone_logo.jpg', 0, 'Thẻ nạp 500.000 VNĐ của Mobiphone', NULL,NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
    -- Vinaphone
(3, 'Thẻ 10.000 VNĐ - Vinaphone', 10000, 'vinaphone_logo.jpg', 0, 'Thẻ nạp 10.000 VNĐ của Vinaphone', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(3, 'Thẻ 20.000 VNĐ - Vinaphone', 20000, 'vinaphone_logo.jpg', 0, 'Thẻ nạp 20.000 VNĐ của Vinaphone', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(3, 'Thẻ 50.000 VNĐ - Vinaphone', 50000, 'vinaphone_logo.jpg', 0, 'Thẻ nạp 50.000 VNĐ của Vinaphone', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(3, 'Thẻ 100.000 VNĐ - Vinaphone', 100000, 'vinaphone_logo.jpg', 0, 'Thẻ nạp 100.000 VNĐ của Vinaphone', NULL,NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(3, 'Thẻ 200.000 VNĐ - Vinaphone', 200000, 'vinaphone_logo.jpg', 0, 'Thẻ nạp 200.000 VNĐ của Vinaphone', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(3, 'Thẻ 500.000 VNĐ - Vinaphone', 500000, 'vinaphone_logo.jpg', 0, 'Thẻ nạp 500.000 VNĐ của Vinaphone', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
    -- Vietnamobi
(4, 'Thẻ 10.000 VNĐ - Vietnamobi', 10000, 'vietnamobi_logo.jpg', 0, 'Thẻ nạp 10.000 VNĐ của Vietnamobi', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(4, 'Thẻ 20.000 VNĐ - Vietnamobi', 20000, 'vietnamobi_logo.jpg', 0, 'Thẻ nạp 20.000 VNĐ của Vietnamobi', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(4, 'Thẻ 50.000 VNĐ - Vietnamobi', 50000, 'vietnamobi_logo.jpg', 0, 'Thẻ nạp 50.000 VNĐ của Vietnamobi', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(4, 'Thẻ 100.000 VNĐ - Vietnamobi', 100000, 'vietnamobi_logo.jpg', 0, 'Thẻ nạp 100.000 VNĐ của Vietnamobi', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(4, 'Thẻ 200.000 VNĐ - Vietnamobi', 200000, 'vietnamobi_logo.jpg', 0, 'Thẻ nạp 200.000 VNĐ của Vietnamobi', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(4, 'Thẻ 500.000 VNĐ - Vietnamobi', 500000, 'vietnamobi_logo.jpg', 0, 'Thẻ nạp 500.000 VNĐ của Vietnamobi', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
    -- Garena
(5, 'Thẻ 10.000 VNĐ - Garena', 10000, 'garena_logo.jpg', 0, 'Thẻ nạp 10.000 VNĐ của Garena', NULL, NULL,NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(5, 'Thẻ 20.000 VNĐ - Garena', 20000, 'garena_logo.jpg', 0, 'Thẻ nạp 20.000 VNĐ của Garena', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(5, 'Thẻ 50.000 VNĐ - Garena', 50000, 'garena_logo.jpg', 0, 'Thẻ nạp 50.000 VNĐ của Garena', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(5, 'Thẻ 100.000 VNĐ - Garena', 100000, 'garena_logo.jpg', 0, 'Thẻ nạp 100.000 VNĐ của Garena', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(5, 'Thẻ 200.000 VNĐ - Garena', 200000, 'garena_logo.jpg', 0, 'Thẻ nạp 200.000 VNĐ của Garena', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(5, 'Thẻ 500.000 VNĐ - Garena', 500000, 'garena_logo.jpg', 0, 'Thẻ nạp 500.000 VNĐ của Garena', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
    -- Itel
(6, 'Thẻ 10.000 VNĐ - Itel', 10000, 'itel_logo.jpg', 0, 'Thẻ nạp 10.000 VNĐ của Itel', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(6, 'Thẻ 20.000 VNĐ - Itel', 20000, 'itel_logo.jpg', 0, 'Thẻ nạp 20.000 VNĐ của Itel', NULL, NULL,NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(6, 'Thẻ 50.000 VNĐ - Itel', 50000, 'itel_logo.jpg', 0, 'Thẻ nạp 50.000 VNĐ của Itel', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(6, 'Thẻ 100.000 VNĐ - Itel', 100000, 'itel_logo.jpg', 0, 'Thẻ nạp 100.000 VNĐ của Itel', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(6, 'Thẻ 200.000 VNĐ - Itel', 200000, 'itel_logo.jpg', 0, 'Thẻ nạp 200.000 VNĐ của Itel', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(6, 'Thẻ 500.000 VNĐ - Itel', 500000, 'itel_logo.jpg', 0, 'Thẻ nạp 500.000 VNĐ của Itel', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
    -- Zing
(7, 'Thẻ 10.000 VNĐ - Zing', 10000, 'zing_logo.jpg', 0, 'Thẻ nạp 10.000 VNĐ của Zing', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(7, 'Thẻ 20.000 VNĐ - Zing', 20000, 'zing_logo.jpg', 0, 'Thẻ nạp 20.000 VNĐ của Zing', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(7, 'Thẻ 50.000 VNĐ - Zing', 50000, 'zing_logo.jpg', 0, 'Thẻ nạp 50.000 VNĐ của Zing', NULL,NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(7, 'Thẻ 100.000 VNĐ - Zing', 100000, 'zing_logo.jpg', 0, 'Thẻ nạp 100.000 VNĐ của Zing', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(7, 'Thẻ 200.000 VNĐ - Zing', 200000, 'zing_logo.jpg', 0, 'Thẻ nạp 200.000 VNĐ của Zing', NULL, NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL),
(7, 'Thẻ 500.000 VNĐ - Zing', 500000, 'zing_logo.jpg', 0, 'Thẻ nạp 500.000 VNĐ của Zing', NULL,NULL, NULL, CURDATE(), CURDATE(), NULL, FALSE, NULL);



-- Insert data to ProductCard
INSERT INTO ProductCard (ProductCategoriesID, Seri, Code, CreatedAt, ExpiredDate, UpdatedAt, DeletedAt, IsDelete, DeletedBy)
VALUES 
    -- Viettel 10K
    (1, 'SERIVT1000000001', 'CODEVT1000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000002', 'CODEVT1000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000003', 'CODEVT1000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000004', 'CODEVT1000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000005', 'CODEVT1000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000006', 'CODEVT1000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000007', 'CODEVT1000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000008', 'CODEVT1000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000009', 'CODEVT1000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000010', 'CODEVT1000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000011', 'CODEVT1000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000012', 'CODEVT1000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000013', 'CODEVT1000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000014', 'CODEVT1000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000015', 'CODEVT1000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000016', 'CODEVT1000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000017', 'CODEVT1000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000018', 'CODEVT1000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000019', 'CODEVT1000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000020', 'CODEVT1000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000021', 'CODEVT1000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000022', 'CODEVT1000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000023', 'CODEVT1000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000024', 'CODEVT1000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000025', 'CODEVT1000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000026', 'CODEVT1000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000027', 'CODEVT1000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000028', 'CODEVT1000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000029', 'CODEVT1000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (1, 'SERIVT1000000030', 'CODEVT1000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    
    
    -- Viettel 20K
	(2, 'SERIVT2000000001', 'CODEVT2000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000002', 'CODEVT2000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000003', 'CODEVT2000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000004', 'CODEVT2000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000005', 'CODEVT2000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000006', 'CODEVT2000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000007', 'CODEVT2000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000008', 'CODEVT2000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000009', 'CODEVT2000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000010', 'CODEVT2000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000011', 'CODEVT2000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000012', 'CODEVT2000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000013', 'CODEVT2000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000014', 'CODEVT2000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000015', 'CODEVT2000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000016', 'CODEVT2000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000017', 'CODEVT2000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000018', 'CODEVT2000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000019', 'CODEVT2000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000020', 'CODEVT2000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000021', 'CODEVT2000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000022', 'CODEVT2000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000023', 'CODEVT2000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000024', 'CODEVT2000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000025', 'CODEVT2000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000026', 'CODEVT2000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000027', 'CODEVT2000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000028', 'CODEVT2000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000029', 'CODEVT2000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (2, 'SERIVT2000000030', 'CODEVT2000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    
    
    
    -- Viettel 50K
    (3, 'SERIVT5000000001', 'CODEVT5000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000002', 'CODEVT5000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000003', 'CODEVT5000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000004', 'CODEVT5000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000005', 'CODEVT5000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000006', 'CODEVT5000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000007', 'CODEVT5000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000008', 'CODEVT5000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000009', 'CODEVT5000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000010', 'CODEVT5000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000011', 'CODEVT5000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000012', 'CODEVT5000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000013', 'CODEVT5000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000014', 'CODEVT5000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000015', 'CODEVT5000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000016', 'CODEVT5000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000017', 'CODEVT5000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000018', 'CODEVT5000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000019', 'CODEVT5000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000020', 'CODEVT5000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000021', 'CODEVT5000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000022', 'CODEVT5000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000023', 'CODEVT5000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000024', 'CODEVT5000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000025', 'CODEVT5000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000026', 'CODEVT5000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000027', 'CODEVT5000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000028', 'CODEVT5000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000029', 'CODEVT5000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (3, 'SERIVT5000000030', 'CODEVT5000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    
    -- Viettel 100K
	(4, 'SERIVT0100000001', 'CODEVT0100000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000002', 'CODEVT0100000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000003', 'CODEVT0100000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000004', 'CODEVT0100000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000005', 'CODEVT0100000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000006', 'CODEVT0100000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000007', 'CODEVT0100000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000008', 'CODEVT0100000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000009', 'CODEVT0100000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000010', 'CODEVT0100000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000011', 'CODEVT0100000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000012', 'CODEVT0100000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000013', 'CODEVT0100000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000014', 'CODEVT0100000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000015', 'CODEVT0100000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000016', 'CODEVT0100000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000017', 'CODEVT0100000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000018', 'CODEVT0100000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000019', 'CODEVT0100000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000020', 'CODEVT0100000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000021', 'CODEVT0100000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000022', 'CODEVT0100000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000023', 'CODEVT0100000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000024', 'CODEVT0100000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000025', 'CODEVT0100000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000026', 'CODEVT0100000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000027', 'CODEVT0100000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000028', 'CODEVT0100000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000029', 'CODEVT0100000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (4, 'SERIVT0100000030', 'CODEVT0100000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    
    
    
    -- Viettel 200K
    (5, 'SERIVT0200000001', 'CODEVT0200000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000002', 'CODEVT0200000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000003', 'CODEVT0200000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000004', 'CODEVT0200000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000005', 'CODEVT0200000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000006', 'CODEVT0200000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000007', 'CODEVT0200000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000008', 'CODEVT0200000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000009', 'CODEVT0200000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000010', 'CODEVT0200000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000011', 'CODEVT0200000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000012', 'CODEVT0200000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000013', 'CODEVT0200000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000014', 'CODEVT0200000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000015', 'CODEVT0200000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000016', 'CODEVT0200000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000017', 'CODEVT0200000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000018', 'CODEVT0200000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000019', 'CODEVT0200000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000020', 'CODEVT0200000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000021', 'CODEVT0200000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000022', 'CODEVT0200000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000023', 'CODEVT0200000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000024', 'CODEVT0200000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000025', 'CODEVT0200000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000026', 'CODEVT0200000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000027', 'CODEVT0200000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000028', 'CODEVT0200000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000029', 'CODEVT0200000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (5, 'SERIVT0200000030', 'CODEVT0200000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    
    
    -- Viettel 500K
    (6, 'SERIVT0500000001', 'CODEVT0500000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000002', 'CODEVT05200000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000003', 'CODEVT0500000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000004', 'CODEVT0500000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000005', 'CODEVT0500000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000006', 'CODEVT0500000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000007', 'CODEVT0500000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000008', 'CODEVT0500000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000009', 'CODEVT0500000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000010', 'CODEVT0500000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000011', 'CODEVT0500000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000012', 'CODEVT0500000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000013', 'CODEVT0500000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000014', 'CODEVT0500000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000015', 'CODEVT0500000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000016', 'CODEVT0500000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000017', 'CODEVT0500000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000018', 'CODEVT0500000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000019', 'CODEVT0500000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000020', 'CODEVT0500000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000021', 'CODEVT0500000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000022', 'CODEVT0500000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000023', 'CODEVT0500000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000024', 'CODEVT0500000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000025', 'CODEVT0500000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000026', 'CODEVT0500000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000027', 'CODEVT0500000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000028', 'CODEVT0500000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000029', 'CODEVT0500000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (6, 'SERIVT0500000030', 'CODEVT0500000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    
    
    
    
    -- Mobiphone 10K
    (7, 'SERIMB1000000001', 'CODEMB1000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000002', 'CODEMB1000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000003', 'CODEMB1000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000004', 'CODEMB1000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000005', 'CODEMB1000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000006', 'CODEMB1000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000007', 'CODEMB1000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000008', 'CODEMB1000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000009', 'CODEMB1000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000010', 'CODEMB1000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000011', 'CODEMB1000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000012', 'CODEMB1000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000013', 'CODEMB1000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000014', 'CODEMB1000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000015', 'CODEMB1000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000016', 'CODEMB1000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000017', 'CODEMB1000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000018', 'CODEMB1000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000019', 'CODEMB1000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000020', 'CODEMB1000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000021', 'CODEMB1000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000022', 'CODEMB1000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000023', 'CODEMB1000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000024', 'CODEMB1000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000025', 'CODEMB1000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000026', 'CODEMB1000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000027', 'CODEMB1000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000028', 'CODEMB1000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000029', 'CODEMB1000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(7, 'SERIMB1000000030', 'CODEMB1000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),

    -- Mobiphone 20K
	(8, 'SERIMB2000000001', 'CODEMB2000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000002', 'CODEMB2000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000003', 'CODEMB2000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000004', 'CODEMB2000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000005', 'CODEMB2000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000006', 'CODEMB2000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000007', 'CODEMB2000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000008', 'CODEMB2000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000009', 'CODEMB2000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000010', 'CODEMB2000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000011', 'CODEMB2000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000012', 'CODEMB2000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000013', 'CODEMB2000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000014', 'CODEMB2000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000015', 'CODEMB2000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000016', 'CODEMB2000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000017', 'CODEMB2000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000018', 'CODEMB2000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000019', 'CODEMB2000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000020', 'CODEMB2000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000021', 'CODEMB2000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000022', 'CODEMB2000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000023', 'CODEMB2000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000024', 'CODEMB2000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000025', 'CODEMB2000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000026', 'CODEMB2000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000027', 'CODEMB2000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000028', 'CODEMB2000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000029', 'CODEMB2000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(8, 'SERIMB2000000030', 'CODEMB2000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),

    -- Mobiphone 50K
    (9, 'SERIMOBI5000000001', 'CODEMOBI5000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000002', 'CODEMOBI5000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000003', 'CODEMOBI5000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000004', 'CODEMOBI5000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000005', 'CODEMOBI5000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000006', 'CODEMOBI5000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000007', 'CODEMOBI5000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000008', 'CODEMOBI5000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000009', 'CODEMOBI5000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000010', 'CODEMOBI5000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000011', 'CODEMOBI5000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000012', 'CODEMOBI5000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000013', 'CODEMOBI5000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000014', 'CODEMOBI5000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000015', 'CODEMOBI5000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000016', 'CODEMOBI5000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000017', 'CODEMOBI5000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000018', 'CODEMOBI5000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000019', 'CODEMOBI5000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000020', 'CODEMOBI5000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000021', 'CODEMOBI5000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000022', 'CODEMOBI5000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000023', 'CODEMOBI5000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000024', 'CODEMOBI5000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000025', 'CODEMOBI5000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000026', 'CODEMOBI5000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000027', 'CODEMOBI5000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000028', 'CODEMOBI5000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000029', 'CODEMOBI5000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(9, 'SERIMOBI5000000030', 'CODEMOBI5000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),

    -- Mobiphone 100K
	(10, 'SERIMB0100000001', 'CODEMB0100000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000002', 'CODEMB0100000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000003', 'CODEMB0100000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000004', 'CODEMB0100000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000005', 'CODEMB0100000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000006', 'CODEMB0100000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000007', 'CODEMB0100000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000008', 'CODEMB0100000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000009', 'CODEMB0100000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000010', 'CODEMB0100000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000011', 'CODEMB0100000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000012', 'CODEMB0100000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000013', 'CODEMB0100000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000014', 'CODEMB0100000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000015', 'CODEMB0100000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000016', 'CODEMB0100000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000017', 'CODEMB0100000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000018', 'CODEMB0100000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000019', 'CODEMB0100000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000020', 'CODEMB0100000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000021', 'CODEMB0100000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000022', 'CODEMB0100000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000023', 'CODEMB0100000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000024', 'CODEMB0100000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000025', 'CODEMB0100000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000026', 'CODEMB0100000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000027', 'CODEMB0100000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000028', 'CODEMB0100000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000029', 'CODEMB0100000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(10, 'SERIMB0100000030', 'CODEMB0100000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),

    -- Mobiphone 200K
	(11, 'SERIMB0200000001', 'CODEMB0200000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000002', 'CODEMB0200000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000003', 'CODEMB0200000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000004', 'CODEMB0200000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000005', 'CODEMB0200000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000006', 'CODEMB0200000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000007', 'CODEMB0200000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000008', 'CODEMB0200000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000009', 'CODEMB0200000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000010', 'CODEMB0200000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000011', 'CODEMB0200000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000012', 'CODEMB0200000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000013', 'CODEMB0200000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000014', 'CODEMB0200000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000015', 'CODEMB0200000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000016', 'CODEMB0200000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000017', 'CODEMB0200000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000018', 'CODEMB0200000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000019', 'CODEMB0200000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000020', 'CODEMB0200000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000021', 'CODEMB0200000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000022', 'CODEMB0200000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000023', 'CODEMB0200000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000024', 'CODEMB0200000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000025', 'CODEMB0200000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000026', 'CODEMB0200000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000027', 'CODEMB0200000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000028', 'CODEMB0200000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000029', 'CODEMB0200000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(11, 'SERIMB0200000030', 'CODEMB0200000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),

    -- Mobiphone 500K
    (12, 'SERIMB0500000001', 'CODEMB0500000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000002', 'CODEMB05200000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000003', 'CODEMB0500000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000004', 'CODEMB0500000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000005', 'CODEMB0500000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000006', 'CODEMB0500000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000007', 'CODEMB0500000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000008', 'CODEMB0500000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000009', 'CODEMB0500000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000010', 'CODEMB0500000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000011', 'CODEMB0500000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000012', 'CODEMB0500000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000013', 'CODEMB0500000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000014', 'CODEMB0500000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000015', 'CODEMB0500000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000016', 'CODEMB0500000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000017', 'CODEMB0500000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000018', 'CODEMB0500000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000019', 'CODEMB0500000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000020', 'CODEMB0500000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000021', 'CODEMB0500000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000022', 'CODEMB0500000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000023', 'CODEMB0500000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000024', 'CODEMB0500000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000025', 'CODEMB0500000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000026', 'CODEMB0500000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000027', 'CODEMB0500000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000028', 'CODEMB0500000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000029', 'CODEMB0500000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(12, 'SERIMB0500000030', 'CODEMB0500000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),


    -- Vinaphone 10K
    (13, 'SERIVP1000000001', 'CODEVP1000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000002', 'CODEVP1000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000003', 'CODEVP1000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000004', 'CODEVP1000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000005', 'CODEVP1000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000006', 'CODEVP1000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000007', 'CODEVP1000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000008', 'CODEVP1000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000009', 'CODEVP1000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000010', 'CODEVP1000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000011', 'CODEVP1000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000012', 'CODEVP1000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000013', 'CODEVP1000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000014', 'CODEVP1000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000015', 'CODEVP1000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000016', 'CODEVP1000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000017', 'CODEVP1000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000018', 'CODEVP1000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000019', 'CODEVP1000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000020', 'CODEVP1000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000021', 'CODEVP1000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000022', 'CODEVP1000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000023', 'CODEVP1000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000024', 'CODEVP1000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000025', 'CODEVP1000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000026', 'CODEVP1000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000027', 'CODEVP1000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000028', 'CODEVP1000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000029', 'CODEVP1000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(13, 'SERIVP1000000030', 'CODEVP1000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),

    -- Vinaphone 20K
    (14, 'SERIVP2000000001', 'CODEVP2000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000002', 'CODEVP2000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000003', 'CODEVP2000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000004', 'CODEVP2000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000005', 'CODEVP2000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000006', 'CODEVP2000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000007', 'CODEVP2000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000008', 'CODEVP2000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000009', 'CODEVP2000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000010', 'CODEVP2000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000011', 'CODEVP2000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000012', 'CODEVP2000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000013', 'CODEVP2000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000014', 'CODEVP2000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000015', 'CODEVP2000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000016', 'CODEVP2000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000017', 'CODEVP2000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000018', 'CODEVP2000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000019', 'CODEVP2000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000020', 'CODEVP2000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000021', 'CODEVP2000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000022', 'CODEVP2000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000023', 'CODEVP2000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000024', 'CODEVP2000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000025', 'CODEVP2000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000026', 'CODEVP2000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000027', 'CODEVP2000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000028', 'CODEVP2000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000029', 'CODEVP2000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(14, 'SERIVP2000000030', 'CODEVP2000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),

    -- Vinaphone 50K
    (15, 'SERIVP5000000001', 'CODEVP5000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000002', 'CODEVP5000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000003', 'CODEVP5000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000004', 'CODEVP5000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000005', 'CODEVP5000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000006', 'CODEVP5000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000007', 'CODEVP5000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000008', 'CODEVP5000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000009', 'CODEVP5000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000010', 'CODEVP5000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000011', 'CODEVP5000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000012', 'CODEVP5000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000013', 'CODEVP5000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000014', 'CODEVP5000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000015', 'CODEVP5000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000016', 'CODEVP5000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000017', 'CODEVP5000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000018', 'CODEVP5000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000019', 'CODEVP5000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000020', 'CODEVP5000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000021', 'CODEVP5000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000022', 'CODEVP5000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000023', 'CODEVP5000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000024', 'CODEVP5000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000025', 'CODEVP5000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000026', 'CODEVP5000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000027', 'CODEVP5000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000028', 'CODEVP5000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000029', 'CODEVP5000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(15, 'SERIVP5000000030', 'CODEVP5000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),

    -- Vinaphone 100K
    (16, 'SERIVP0100000001', 'CODEVP0100000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000002', 'CODEVP0100000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000003', 'CODEVP0100000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000004', 'CODEVP0100000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000005', 'CODEVP0100000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000006', 'CODEVP0100000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000007', 'CODEVP0100000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000008', 'CODEVP0100000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000009', 'CODEVP0100000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000010', 'CODEVP0100000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000011', 'CODEVP0100000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000012', 'CODEVP0100000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000013', 'CODEVP0100000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000014', 'CODEVP0100000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000015', 'CODEVP0100000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000016', 'CODEVP0100000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000017', 'CODEVP0100000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000018', 'CODEVP0100000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000019', 'CODEVP0100000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000020', 'CODEVP0100000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000021', 'CODEVP0100000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000022', 'CODEVP0100000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000023', 'CODEVP0100000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000024', 'CODEVP0100000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000025', 'CODEVP0100000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000026', 'CODEVP0100000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000027', 'CODEVP0100000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000028', 'CODEVP0100000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000029', 'CODEVP0100000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(16, 'SERIVP0100000030', 'CODEVP0100000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),

    -- Vinaphone 200K
   (17, 'SERIVP0200000001', 'CODEVP0200000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000002', 'CODEVP0200000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000003', 'CODEVP0200000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000004', 'CODEVP0200000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000005', 'CODEVP0200000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000006', 'CODEVP0200000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000007', 'CODEVP0200000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000008', 'CODEVP0200000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000009', 'CODEVP0200000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000010', 'CODEVP0200000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000011', 'CODEVP0200000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000012', 'CODEVP0200000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000013', 'CODEVP0200000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000014', 'CODEVP0200000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000015', 'CODEVP0200000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000016', 'CODEVP0200000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000017', 'CODEVP0200000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000018', 'CODEVP0200000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000019', 'CODEVP0200000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000020', 'CODEVP0200000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000021', 'CODEVP0200000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000022', 'CODEVP0200000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000023', 'CODEVP0200000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000024', 'CODEVP0200000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000025', 'CODEVP0200000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000026', 'CODEVP0200000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000027', 'CODEVP0200000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000028', 'CODEVP0200000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000029', 'CODEVP0200000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(17, 'SERIVP0200000030', 'CODEVP0200000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),

    -- Vinaphone 500K
    (18, 'SERIVP0500000001', 'CODEVP0500000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000002', 'CODEVP05200000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000003', 'CODEVP0500000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000004', 'CODEVP0500000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000005', 'CODEVP0500000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000006', 'CODEVP0500000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000007', 'CODEVP0500000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000008', 'CODEVP0500000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000009', 'CODEVP0500000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000010', 'CODEVP0500000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000011', 'CODEVP0500000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000012', 'CODEVP0500000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000013', 'CODEVP0500000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000014', 'CODEVP0500000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000015', 'CODEVP0500000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000016', 'CODEVP0500000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000017', 'CODEVP0500000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000018', 'CODEVP0500000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000019', 'CODEVP0500000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000020', 'CODEVP0500000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000021', 'CODEVP0500000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000022', 'CODEVP0500000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000023', 'CODEVP0500000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000024', 'CODEVP0500000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000025', 'CODEVP0500000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000026', 'CODEVP0500000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000027', 'CODEVP0500000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000028', 'CODEVP0500000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000029', 'CODEVP0500000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
	(18, 'SERIVP0500000030', 'CODEVP0500000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),

    
    
    -- Vietnamobi 10K
	(19, 'SERIVM1000000001', 'CODEVM1000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000002', 'CODEVM1000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000003', 'CODEVM1000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000004', 'CODEVM1000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000005', 'CODEVM1000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000006', 'CODEVM1000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000007', 'CODEVM1000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000008', 'CODEVM1000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000009', 'CODEVM1000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000010', 'CODEVM1000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000011', 'CODEVM1000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000012', 'CODEVM1000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000013', 'CODEVM1000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000014', 'CODEVM1000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000015', 'CODEVM1000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000016', 'CODEVM1000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000017', 'CODEVM1000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000018', 'CODEVM1000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000019', 'CODEVM1000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000020', 'CODEVM1000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000021', 'CODEVM1000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000022', 'CODEVM1000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000023', 'CODEVM1000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000024', 'CODEVM1000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000025', 'CODEVM1000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000026', 'CODEVM1000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000027', 'CODEVM1000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000028', 'CODEVM1000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000029', 'CODEVM1000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (19, 'SERIVM1000000030', 'CODEVM1000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    
    -- Vietnamobi 20K
    (20, 'SERIVM2000000001', 'CODEVM2000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000002', 'CODEVM2000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000003', 'CODEVM2000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000004', 'CODEVM2000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000005', 'CODEVM2000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000006', 'CODEVM2000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000007', 'CODEVM2000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000008', 'CODEVM2000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000009', 'CODEVM2000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000010', 'CODEVM2000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000011', 'CODEVM2000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000012', 'CODEVM2000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000013', 'CODEVM2000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000014', 'CODEVM2000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000015', 'CODEVM2000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000016', 'CODEVM2000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000017', 'CODEVM2000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000018', 'CODEVM2000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000019', 'CODEVM2000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000020', 'CODEVM2000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000021', 'CODEVM2000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000022', 'CODEVM2000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000023', 'CODEVM2000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000024', 'CODEVM2000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000025', 'CODEVM2000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000026', 'CODEVM2000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000027', 'CODEVM2000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000028', 'CODEVM2000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000029', 'CODEVM2000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (20, 'SERIVM2000000030', 'CODEVM2000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Vietnamobi 50K
	(21, 'SERIVM5000000001', 'CODEVM5000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000002', 'CODEVM5000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000003', 'CODEVM5000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000004', 'CODEVM5000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000005', 'CODEVM5000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000006', 'CODEVM5000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000007', 'CODEVM5000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000008', 'CODEVM5000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000009', 'CODEVM5000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000010', 'CODEVM5000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000011', 'CODEVM5000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000012', 'CODEVM5000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000013', 'CODEVM5000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000014', 'CODEVM5000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000015', 'CODEVM5000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000016', 'CODEVM5000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000017', 'CODEVM5000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000018', 'CODEVM5000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000019', 'CODEVM5000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000020', 'CODEVM5000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000021', 'CODEVM5000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000022', 'CODEVM5000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000023', 'CODEVM5000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000024', 'CODEVM5000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000025', 'CODEVM5000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000026', 'CODEVM5000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000027', 'CODEVM5000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000028', 'CODEVM5000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000029', 'CODEVM5000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (21, 'SERIVM5000000030', 'CODEVM5000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    
	-- Vietnamobi 100K
    (22, 'SERIVM0100000001', 'CODEVM0100000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000002', 'CODEVM0100000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000003', 'CODEVM0100000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000004', 'CODEVM0100000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000005', 'CODEVM0100000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000006', 'CODEVM0100000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000007', 'CODEVM0100000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000008', 'CODEVM0100000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000009', 'CODEVM0100000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000010', 'CODEVM0100000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000011', 'CODEVM0100000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000012', 'CODEVM0100000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000013', 'CODEVM0100000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000014', 'CODEVM0100000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000015', 'CODEVM0100000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000016', 'CODEVM0100000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000017', 'CODEVM0100000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000018', 'CODEVM0100000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000019', 'CODEVM0100000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000020', 'CODEVM0100000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000021', 'CODEVM0100000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000022', 'CODEVM0100000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000023', 'CODEVM0100000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000024', 'CODEVM0100000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000025', 'CODEVM0100000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000026', 'CODEVM0100000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000027', 'CODEVM0100000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000028', 'CODEVM0100000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000029', 'CODEVM0100000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (22, 'SERIVM0100000030', 'CODEVM0100000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Vietnamobi 200K
	(23, 'SERIVM0200000001', 'CODEVM0200000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000002', 'CODEVM0200000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000003', 'CODEVM0200000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000004', 'CODEVM0200000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000005', 'CODEVM0200000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000006', 'CODEVM0200000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000007', 'CODEVM0200000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000008', 'CODEVM0200000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000009', 'CODEVM0200000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000010', 'CODEVM0200000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000011', 'CODEVM0200000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000012', 'CODEVM0200000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000013', 'CODEVM0200000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000014', 'CODEVM0200000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000015', 'CODEVM0200000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000016', 'CODEVM0200000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000017', 'CODEVM0200000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000018', 'CODEVM0200000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000019', 'CODEVM0200000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000020', 'CODEVM0200000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000021', 'CODEVM0200000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000022', 'CODEVM0200000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000023', 'CODEVM0200000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000024', 'CODEVM0200000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000025', 'CODEVM0200000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000026', 'CODEVM0200000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000027', 'CODEVM0200000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000028', 'CODEVM0200000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000029', 'CODEVM0200000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (23, 'SERIVM0200000030', 'CODEVM0200000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Vietnamobi 500K
	(24, 'SERIVM0500000001', 'CODEVM0500000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000002', 'CODEVM0500000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000003', 'CODEVM0500000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000004', 'CODEVM0500000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000005', 'CODEVM0500000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000006', 'CODEVM0500000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000007', 'CODEVM0500000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000008', 'CODEVM0500000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000009', 'CODEVM0500000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000010', 'CODEVM0500000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000011', 'CODEVM0500000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000012', 'CODEVM0500000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000013', 'CODEVM0500000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000014', 'CODEVM0500000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000015', 'CODEVM0500000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000016', 'CODEVM0500000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000017', 'CODEVM0500000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000018', 'CODEVM0500000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000019', 'CODEVM0500000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000020', 'CODEVM0500000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000021', 'CODEVM0500000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000022', 'CODEVM0500000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000023', 'CODEVM0500000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000024', 'CODEVM0500000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000025', 'CODEVM0500000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000026', 'CODEVM0500000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000027', 'CODEVM0500000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000028', 'CODEVM0500000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000029', 'CODEVM0500000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (24, 'SERIVM0500000030', 'CODEVM0500000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    
    -- Garena 10K
	(25, 'SERIGR1000000001', 'CODEGR1000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000002', 'CODEGR1000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000003', 'CODEGR1000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000004', 'CODEGR1000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000005', 'CODEGR1000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000006', 'CODEGR1000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000007', 'CODEGR1000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000008', 'CODEGR1000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000009', 'CODEGR1000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000010', 'CODEGR1000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000011', 'CODEGR1000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000012', 'CODEGR1000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000013', 'CODEGR1000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000014', 'CODEGR1000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000015', 'CODEGR1000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000016', 'CODEGR1000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000017', 'CODEGR1000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000018', 'CODEGR1000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000019', 'CODEGR1000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000020', 'CODEGR1000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000021', 'CODEGR1000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000022', 'CODEGR1000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000023', 'CODEGR1000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000024', 'CODEGR1000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000025', 'CODEGR1000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000026', 'CODEGR1000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000027', 'CODEGR1000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000028', 'CODEGR1000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000029', 'CODEGR1000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (25, 'SERIGR1000000030', 'CODEGR1000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Garena 20K
    (26, 'SERIGR2000000001', 'CODEGR2000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000002', 'CODEGR2000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000003', 'CODEGR2000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000004', 'CODEGR2000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000005', 'CODEGR2000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000006', 'CODEGR2000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000007', 'CODEGR2000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000008', 'CODEGR2000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000009', 'CODEGR2000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000010', 'CODEGR2000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000011', 'CODEGR2000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000012', 'CODEGR2000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000013', 'CODEGR2000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000014', 'CODEGR2000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000015', 'CODEGR2000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000016', 'CODEGR2000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000017', 'CODEGR2000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000018', 'CODEGR2000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000019', 'CODEGR2000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000020', 'CODEGR2000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000021', 'CODEGR2000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000022', 'CODEGR2000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000023', 'CODEGR2000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000024', 'CODEGR2000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000025', 'CODEGR2000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000026', 'CODEGR2000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000027', 'CODEGR2000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000028', 'CODEGR2000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000029', 'CODEGR2000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (26, 'SERIGR2000000030', 'CODEGR2000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Garena 50K
	(27, 'SERIGR5000000001', 'CODEGR5000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000002', 'CODEGR5000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000003', 'CODEGR5000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000004', 'CODEGR5000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000005', 'CODEGR5000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000006', 'CODEGR5000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000007', 'CODEGR5000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000008', 'CODEGR5000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000009', 'CODEGR5000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000010', 'CODEGR5000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000011', 'CODEGR5000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000012', 'CODEGR5000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000013', 'CODEGR5000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000014', 'CODEGR5000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000015', 'CODEGR5000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000016', 'CODEGR5000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000017', 'CODEGR5000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000018', 'CODEGR5000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000019', 'CODEGR5000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000020', 'CODEGR5000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000021', 'CODEGR5000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000022', 'CODEGR5000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000023', 'CODEGR5000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000024', 'CODEGR5000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000025', 'CODEGR5000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000026', 'CODEGR5000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000027', 'CODEGR5000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000028', 'CODEGR5000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000029', 'CODEGR5000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (27, 'SERIGR5000000030', 'CODEGR5000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Garena 100K
	(28, 'SERIGR0100000001', 'CODEGR0100000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000002', 'CODEGR0100000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000003', 'CODEGR0100000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000004', 'CODEGR0100000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000005', 'CODEGR0100000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000006', 'CODEGR0100000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000007', 'CODEGR0100000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000008', 'CODEGR0100000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000009', 'CODEGR0100000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000010', 'CODEGR0100000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000011', 'CODEGR0100000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000012', 'CODEGR0100000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000013', 'CODEGR0100000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000014', 'CODEGR0100000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000015', 'CODEGR0100000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000016', 'CODEGR0100000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000017', 'CODEGR0100000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000018', 'CODEGR0100000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000019', 'CODEGR0100000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000020', 'CODEGR0100000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000021', 'CODEGR0100000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000022', 'CODEGR0100000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000023', 'CODEGR0100000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000024', 'CODEGR0100000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000025', 'CODEGR0100000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000026', 'CODEGR0100000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000027', 'CODEGR0100000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000028', 'CODEGR0100000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000029', 'CODEGR0100000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (28, 'SERIGR0100000030', 'CODEGR0100000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Garena 200K
    (29, 'SERIGR0200000001', 'CODEGR0200000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000002', 'CODEGR0200000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000003', 'CODEGR0200000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000004', 'CODEGR0200000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000005', 'CODEGR0200000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000006', 'CODEGR0200000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000007', 'CODEGR0200000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000008', 'CODEGR0200000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000009', 'CODEGR0200000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000010', 'CODEGR0200000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000011', 'CODEGR0200000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000012', 'CODEGR0200000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000013', 'CODEGR0200000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000014', 'CODEGR0200000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000015', 'CODEGR0200000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000016', 'CODEGR0200000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000017', 'CODEGR0200000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000018', 'CODEGR0200000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000019', 'CODEGR0200000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000020', 'CODEGR0200000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000021', 'CODEGR0200000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000022', 'CODEGR0200000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000023', 'CODEGR0200000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000024', 'CODEGR0200000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000025', 'CODEGR0200000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000026', 'CODEGR0200000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000027', 'CODEGR0200000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000028', 'CODEGR0200000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000029', 'CODEGR0200000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (29, 'SERIGR0200000030', 'CODEGR0200000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Garena 500K
     (30, 'SERIGR0500000001', 'CODEGR0500000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000002', 'CODEGR0500000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000003', 'CODEGR0500000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000004', 'CODEGR0500000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000005', 'CODEGR0500000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000006', 'CODEGR0500000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000007', 'CODEGR0500000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000008', 'CODEGR0500000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000009', 'CODEGR0500000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000010', 'CODEGR0500000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000011', 'CODEGR0500000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000012', 'CODEGR0500000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000013', 'CODEGR0500000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000014', 'CODEGR0500000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000015', 'CODEGR0500000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000016', 'CODEGR0500000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000017', 'CODEGR0500000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000018', 'CODEGR0500000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000019', 'CODEGR0500000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000020', 'CODEGR0500000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000021', 'CODEGR0500000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000022', 'CODEGR0500000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000023', 'CODEGR0500000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000024', 'CODEGR0500000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000025', 'CODEGR0500000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000026', 'CODEGR0500000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000027', 'CODEGR0500000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000028', 'CODEGR0500000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000029', 'CODEGR0500000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (30, 'SERIGR0500000030', 'CODEGR0500000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    
    -- Itel 10K
    (31, 'SERIIT1000000001', 'CODEIT1000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000002', 'CODEIT1000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000003', 'CODEIT1000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000004', 'CODEIT1000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000005', 'CODEIT1000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000006', 'CODEIT1000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000007', 'CODEIT1000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000008', 'CODEIT1000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000009', 'CODEIT1000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000010', 'CODEIT1000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000011', 'CODEIT1000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000012', 'CODEIT1000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000013', 'CODEIT1000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000014', 'CODEIT1000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000015', 'CODEIT1000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000016', 'CODEIT1000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000017', 'CODEIT1000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000018', 'CODEIT1000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000019', 'CODEIT1000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000020', 'CODEIT1000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000021', 'CODEIT1000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000022', 'CODEIT1000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000023', 'CODEIT1000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000024', 'CODEIT1000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000025', 'CODEIT1000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000026', 'CODEIT1000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000027', 'CODEIT1000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000028', 'CODEIT1000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000029', 'CODEIT1000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000030', 'CODEIT1000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (31, 'SERIIT1000000031', 'CODEIT1000000031', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Itel 20K
     (32, 'SERIIT2000000001', 'CODEIT2000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000002', 'CODEIT2000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000003', 'CODEIT2000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000004', 'CODEIT2000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000005', 'CODEIT2000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000006', 'CODEIT2000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000007', 'CODEIT2000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000008', 'CODEIT2000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000009', 'CODEIT2000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000010', 'CODEIT2000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000011', 'CODEIT2000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000012', 'CODEIT2000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000013', 'CODEIT2000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000014', 'CODEIT2000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000015', 'CODEIT2000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000016', 'CODEIT2000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000017', 'CODEIT2000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000018', 'CODEIT2000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000019', 'CODEIT2000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000020', 'CODEIT2000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000021', 'CODEIT2000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000022', 'CODEIT2000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000023', 'CODEIT2000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000024', 'CODEIT2000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000025', 'CODEIT2000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000026', 'CODEIT2000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000027', 'CODEIT2000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000028', 'CODEIT2000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000029', 'CODEIT2000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000030', 'CODEIT2000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000031', 'CODEIT2000000031', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (32, 'SERIIT2000000032', 'CODEIT2000000032', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Itel 50K
     (33, 'SERIIT5000000001', 'CODEIT5000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000002', 'CODEIT5000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000003', 'CODEIT5000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000004', 'CODEIT5000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000005', 'CODEIT5000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000006', 'CODEIT5000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000007', 'CODEIT5000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000008', 'CODEIT5000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000009', 'CODEIT5000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000010', 'CODEIT5000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000011', 'CODEIT5000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000012', 'CODEIT5000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000013', 'CODEIT5000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000014', 'CODEIT5000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000015', 'CODEIT5000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000016', 'CODEIT5000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000017', 'CODEIT5000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000018', 'CODEIT5000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000019', 'CODEIT5000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000020', 'CODEIT5000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000021', 'CODEIT5000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000022', 'CODEIT5000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000023', 'CODEIT5000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000024', 'CODEIT5000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000025', 'CODEIT5000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000026', 'CODEIT5000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000027', 'CODEIT5000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000028', 'CODEIT5000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000029', 'CODEIT5000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (33, 'SERIIT5000000030', 'CODEIT5000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Itel 100K
	(34, 'SERIIT0100000001', 'CODEIT0100000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000002', 'CODEIT0100000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000003', 'CODEIT0100000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000004', 'CODEIT0100000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000005', 'CODEIT0100000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000006', 'CODEIT0100000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000007', 'CODEIT0100000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000008', 'CODEIT0100000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000009', 'CODEIT0100000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000010', 'CODEIT0100000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000011', 'CODEIT0100000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000012', 'CODEIT0100000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000013', 'CODEIT0100000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000014', 'CODEIT0100000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000015', 'CODEIT0100000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000016', 'CODEIT0100000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000017', 'CODEIT0100000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000018', 'CODEIT0100000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000019', 'CODEIT0100000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000020', 'CODEIT0100000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000021', 'CODEIT0100000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000022', 'CODEIT0100000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000023', 'CODEIT0100000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000024', 'CODEIT0100000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000025', 'CODEIT0100000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000026', 'CODEIT0100000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000027', 'CODEIT0100000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000028', 'CODEIT0100000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000029', 'CODEIT0100000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (34, 'SERIIT0100000030', 'CODEIT0100000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Itel 200K
    (35, 'SERIIT0200000001', 'CODEIT0200000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000002', 'CODEIT0200000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000003', 'CODEIT0200000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000004', 'CODEIT0200000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000005', 'CODEIT0200000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000006', 'CODEIT0200000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000007', 'CODEIT0200000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000008', 'CODEIT0200000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000009', 'CODEIT0200000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000010', 'CODEIT0200000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000011', 'CODEIT0200000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000012', 'CODEIT0200000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000013', 'CODEIT0200000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000014', 'CODEIT0200000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000015', 'CODEIT0200000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000016', 'CODEIT0200000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000017', 'CODEIT0200000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000018', 'CODEIT0200000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000019', 'CODEIT0200000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000020', 'CODEIT0200000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000021', 'CODEIT0200000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000022', 'CODEIT0200000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000023', 'CODEIT0200000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000024', 'CODEIT0200000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000025', 'CODEIT0200000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000026', 'CODEIT0200000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000027', 'CODEIT0200000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000028', 'CODEIT0200000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000029', 'CODEIT0200000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (35, 'SERIIT0200000030', 'CODEIT0200000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Itel 500K
    (36, 'SERIIT0500000001', 'CODEIT0500000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000002', 'CODEIT0500000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000003', 'CODEIT0500000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000004', 'CODEIT0500000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000005', 'CODEIT0500000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000006', 'CODEIT0500000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000007', 'CODEIT0500000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000008', 'CODEIT0500000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000009', 'CODEIT0500000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000010', 'CODEIT0500000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000011', 'CODEIT0500000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000012', 'CODEIT0500000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000013', 'CODEIT0500000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000014', 'CODEIT0500000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000015', 'CODEIT0500000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000016', 'CODEIT0500000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000017', 'CODEIT0500000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000018', 'CODEIT0500000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000019', 'CODEIT0500000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000020', 'CODEIT0500000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000021', 'CODEIT0500000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000022', 'CODEIT0500000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000023', 'CODEIT0500000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000024', 'CODEIT0500000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000025', 'CODEIT0500000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000026', 'CODEIT0500000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000027', 'CODEIT0500000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000028', 'CODEIT0500000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000029', 'CODEIT0500000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (36, 'SERIIT0500000030', 'CODEIT0500000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),

	    -- Zing 10K
    (37, 'SERIZI1000000001', 'CODEZI1000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000002', 'CODEZI1000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000003', 'CODEZI1000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000004', 'CODEZI1000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000005', 'CODEZI1000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000006', 'CODEZI1000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000007', 'CODEZI1000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000008', 'CODEZI1000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000009', 'CODEZI1000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000010', 'CODEZI1000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000011', 'CODEZI1000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000012', 'CODEZI1000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000013', 'CODEZI1000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000014', 'CODEZI1000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000015', 'CODEZI1000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000016', 'CODEZI1000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000017', 'CODEZI1000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000018', 'CODEZI1000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000019', 'CODEZI1000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000020', 'CODEZI1000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000021', 'CODEZI1000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000022', 'CODEZI1000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000023', 'CODEZI1000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000024', 'CODEZI1000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000025', 'CODEZI1000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000026', 'CODEZI1000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000027', 'CODEZI1000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000028', 'CODEZI1000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000029', 'CODEZI1000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (37, 'SERIZI1000000030', 'CODEZI1000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Zing 20K
    (38, 'SERIZI2000000001', 'CODEZI2000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000002', 'CODEZI2000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000003', 'CODEZI2000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000004', 'CODEZI2000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000005', 'CODEZI2000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000006', 'CODEZI2000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000007', 'CODEZI2000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000008', 'CODEZI2000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000009', 'CODEZI2000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000010', 'CODEZI2000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000011', 'CODEZI2000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000012', 'CODEZI2000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000013', 'CODEZI2000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000014', 'CODEZI2000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000015', 'CODEZI2000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000016', 'CODEZI2000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000017', 'CODEZI2000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000018', 'CODEZI2000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000019', 'CODEZI2000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000020', 'CODEZI2000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000021', 'CODEZI2000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000022', 'CODEZI2000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000023', 'CODEZI2000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000024', 'CODEZI2000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000025', 'CODEZI2000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000026', 'CODEZI2000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000027', 'CODEZI2000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000028', 'CODEZI2000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000029', 'CODEZI2000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (38, 'SERIZI2000000030', 'CODEZI2000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Zing 50K
    (39, 'SERIZI5000000001', 'CODEZI5000000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000002', 'CODEZI5000000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000003', 'CODEZI5000000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000004', 'CODEZI5000000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000005', 'CODEZI5000000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000006', 'CODEZI5000000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000007', 'CODEZI5000000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000008', 'CODEZI5000000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000009', 'CODEZI5000000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000010', 'CODEZI5000000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000011', 'CODEZI5000000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000012', 'CODEZI5000000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000013', 'CODEZI5000000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000014', 'CODEZI5000000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000015', 'CODEZI5000000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000016', 'CODEZI5000000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000017', 'CODEZI5000000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000018', 'CODEZI5000000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000019', 'CODEZI5000000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000020', 'CODEZI5000000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000021', 'CODEZI5000000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000022', 'CODEZI5000000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000023', 'CODEZI5000000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000024', 'CODEZI5000000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000025', 'CODEZI5000000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000026', 'CODEZI5000000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000027', 'CODEZI5000000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000028', 'CODEZI5000000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000029', 'CODEZI5000000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (39, 'SERIZI5000000030', 'CODEZI5000000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Zing 100K
    (40, 'SERIZI0100000001', 'CODEZI0100000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000002', 'CODEZI0100000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000003', 'CODEZI0100000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000004', 'CODEZI0100000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000005', 'CODEZI0100000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000006', 'CODEZI0100000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000007', 'CODEZI0100000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000008', 'CODEZI0100000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000009', 'CODEZI0100000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000010', 'CODEZI0100000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000011', 'CODEZI0100000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000012', 'CODEZI0100000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000013', 'CODEZI0100000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000014', 'CODEZI0100000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000015', 'CODEZI0100000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000016', 'CODEZI0100000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000017', 'CODEZI0100000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000018', 'CODEZI0100000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000019', 'CODEZI0100000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000020', 'CODEZI0100000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000021', 'CODEZI0100000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000022', 'CODEZI0100000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000023', 'CODEZI0100000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000024', 'CODEZI0100000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000025', 'CODEZI0100000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000026', 'CODEZI0100000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000027', 'CODEZI0100000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000028', 'CODEZI0100000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000029', 'CODEZI0100000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (40, 'SERIZI0100000030', 'CODEZI0100000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Zing 200K
   (41, 'SERIZI0200000001', 'CODEZI0200000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000002', 'CODEZI0200000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000003', 'CODEZI0200000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000004', 'CODEZI0200000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000005', 'CODEZI0200000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000006', 'CODEZI0200000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000007', 'CODEZI0200000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000008', 'CODEZI0200000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000009', 'CODEZI0200000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000010', 'CODEZI0200000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000011', 'CODEZI0200000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000012', 'CODEZI0200000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000013', 'CODEZI0200000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000014', 'CODEZI0200000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000015', 'CODEZI0200000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000016', 'CODEZI0200000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000017', 'CODEZI0200000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000018', 'CODEZI0200000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000019', 'CODEZI0200000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000020', 'CODEZI0200000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000021', 'CODEZI0200000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000022', 'CODEZI0200000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000023', 'CODEZI0200000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000024', 'CODEZI0200000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000025', 'CODEZI0200000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000026', 'CODEZI0200000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000027', 'CODEZI0200000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000028', 'CODEZI0200000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000029', 'CODEZI0200000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (41, 'SERIZI0200000030', 'CODEZI0200000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    -- Zing 500K
    (42, 'SERIZI0500000001', 'CODEZI0500000001', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000002', 'CODEZI0500000002', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000003', 'CODEZI0500000003', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000004', 'CODEZI0500000004', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000005', 'CODEZI0500000005', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000006', 'CODEZI0500000006', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000007', 'CODEZI0500000007', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000008', 'CODEZI0500000008', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000009', 'CODEZI0500000009', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000010', 'CODEZI0500000010', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000011', 'CODEZI0500000011', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000012', 'CODEZI0500000012', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000013', 'CODEZI0500000013', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000014', 'CODEZI0500000014', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000015', 'CODEZI0500000015', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000016', 'CODEZI0500000016', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000017', 'CODEZI0500000017', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000018', 'CODEZI0500000018', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000019', 'CODEZI0500000019', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000020', 'CODEZI0500000020', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000021', 'CODEZI0500000021', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000022', 'CODEZI0500000022', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000023', 'CODEZI0500000023', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000024', 'CODEZI0500000024', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000025', 'CODEZI0500000025', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000026', 'CODEZI0500000026', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000027', 'CODEZI0500000027', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000028', 'CODEZI0500000028', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000029', 'CODEZI0500000029', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL),
    (42, 'SERIZI0500000030', 'CODEZI0500000030', CURDATE(), '2025-12-31', CURDATE(), NULL, FALSE, NULL);
    
    
-- Dữ liệu mẫu cho 29 người dùng bình luận về 42 loại thẻ
INSERT INTO Comment (UserID, ProductCategoriesID, ProductCategoriesName, BrandName, Title, Message, CreatedAt, UpdatedAt, DeletedAt, IsDelete, DeletedBy)
VALUES 
-- Thẻ Viettel
(1, 1, 'Thẻ 10.000 VNĐ - Viettel', 'Viettel', 'Dung Pham comment!', 'Dịch vụ nhanh chóng và đáng tin cậy', '2024-07-01', '2024-07-01', NULL, FALSE, NULL),
(1, 2, 'Thẻ 20.000 VNĐ - Viettel', 'Viettel', 'Dung Pham comment!', 'Giao hàng nhanh', '2024-07-02', '2024-07-02', NULL, FALSE, NULL),
(1, 3, 'Thẻ 50.000 VNĐ - Viettel', 'Viettel', 'Dung Pham comment!', 'Sản phẩm chất lượng cao', '2024-07-03', '2024-07-03', NULL, FALSE, NULL),
(1, 4, 'Thẻ 100.000 VNĐ - Viettel', 'Viettel', 'Dung Pham comment!', 'Giá cả hợp lý', '2024-07-04', '2024-07-04', NULL, FALSE, NULL),
(1, 5, 'Thẻ 200.000 VNĐ - Viettel', 'Viettel', 'Dung Pham comment!', 'Rất hài lòng với dịch vụ', '2024-07-05', '2024-07-05', NULL, FALSE, NULL),
(1, 6, 'Thẻ 500.000 VNĐ - Viettel', 'Viettel', 'Dung Pham comment!', 'Sản phẩm rất tốt', '2024-07-06', '2024-07-06', NULL, FALSE, NULL),

-- Thẻ Mobiphone
(1, 7, 'Thẻ 10.000 VNĐ - Mobiphone', 'Mobiphone', 'Dung Pham comment!', 'Dịch vụ nhanh chóng và đáng tin cậy', '2024-07-01', '2024-07-01', NULL, FALSE, NULL),
(1, 8, 'Thẻ 20.000 VNĐ - Mobiphone', 'Mobiphone', 'Dung Pham comment!', 'Giao hàng nhanh', '2024-07-02', '2024-07-02', NULL, FALSE, NULL),
(1, 9, 'Thẻ 50.000 VNĐ - Mobiphone', 'Mobiphone', 'Dung Pham comment!', 'Sản phẩm chất lượng cao', '2024-07-03', '2024-07-03', NULL, FALSE, NULL),
(1, 10, 'Thẻ 100.000 VNĐ - Mobiphone', 'Mobiphone', 'Dung Pham comment!', 'Giá cả hợp lý', '2024-07-04', '2024-07-04', NULL, FALSE, NULL),
(1, 11, 'Thẻ 200.000 VNĐ - Mobiphone', 'Mobiphone', 'Dung Pham comment!', 'Rất hài lòng với dịch vụ', '2024-07-05', '2024-07-05', NULL, FALSE, NULL),
(1, 12, 'Thẻ 500.000 VNĐ - Mobiphone', 'Mobiphone', 'Dung Pham comment!', 'Sản phẩm rất tốt', '2024-07-06', '2024-07-06', NULL, FALSE, NULL),

-- Thẻ Vinaphone
(1, 13, 'Thẻ 10.000 VNĐ - Vinaphone', 'Vinaphone',  'Dung Pham comment!', 'Dịch vụ nhanh chóng và đáng tin cậy', '2024-07-01', '2024-07-01', NULL, FALSE, NULL),
(1, 14, 'Thẻ 20.000 VNĐ - Vinaphone', 'Vinaphone',  'Dung Pham comment!', 'Giao hàng nhanh', '2024-07-02', '2024-07-02', NULL, FALSE, NULL),
(1, 15, 'Thẻ 50.000 VNĐ - Vinaphone', 'Vinaphone',  'Dung Pham comment!', 'Sản phẩm chất lượng cao', '2024-07-03', '2024-07-03', NULL, FALSE, NULL),
(1, 16, 'Thẻ 100.000 VNĐ - Vinaphone', 'Vinaphone',  'Dung Pham comment!', 'Giá cả hợp lý', '2024-07-04', '2024-07-04', NULL, FALSE, NULL),
(1, 17, 'Thẻ 200.000 VNĐ - Vinaphone', 'Vinaphone',  'Dung Pham comment!', 'Rất hài lòng với dịch vụ', '2024-07-05', '2024-07-05', NULL, FALSE, NULL),
(1, 18, 'Thẻ 500.000 VNĐ - Vinaphone', 'Vinaphone',  'Dung Pham comment!', 'Sản phẩm rất tốt', '2024-07-06', '2024-07-06', NULL, FALSE, NULL),

-- Thẻ Vietnamobi
(1, 19, 'Thẻ 10.000 VNĐ - Vietnamobi', 'Vietnamobi',  'Dung Pham comment!', 'Dịch vụ nhanh chóng và đáng tin cậy', '2024-07-01', '2024-07-01', NULL, FALSE, NULL),
(1, 20, 'Thẻ 20.000 VNĐ - Vietnamobi', 'Vietnamobi',  'Dung Pham comment!', 'Giao hàng nhanh', '2024-07-02', '2024-07-02', NULL, FALSE, NULL),
(1, 21, 'Thẻ 50.000 VNĐ - Vietnamobi', 'Vietnamobi',  'Dung Pham comment!', 'Sản phẩm chất lượng cao', '2024-07-03', '2024-07-03', NULL, FALSE, NULL),
(1, 22, 'Thẻ 100.000 VNĐ - Vietnamobi', 'Vietnamobi',  'Dung Pham comment!', 'Giá cả hợp lý', '2024-07-04', '2024-07-04', NULL, FALSE, NULL),
(1, 23, 'Thẻ 200.000 VNĐ - Vietnamobi', 'Vietnamobi',  'Dung Pham comment!', 'Rất hài lòng với dịch vụ', '2024-07-05', '2024-07-05', NULL, FALSE, NULL),
(1, 24, 'Thẻ 500.000 VNĐ - Vietnamobi', 'Vietnamobi',  'Dung Pham comment!', 'Sản phẩm rất tốt', '2024-07-06', '2024-07-06', NULL, FALSE, NULL),

-- Garenna
(1, 25, 'Thẻ 10.000 VNĐ - Itel', 'Itel',  'Dung Pham comment!', 'Dịch vụ nhanh chóng và đáng tin cậy', '2024-07-01', '2024-07-01', NULL, FALSE, NULL),
(1, 26, 'Thẻ 20.000 VNĐ - Itel', 'Itel',  'Dung Pham comment!', 'Giao hàng nhanh', '2024-07-02', '2024-07-02', NULL, FALSE, NULL),
(1, 27, 'Thẻ 50.000 VNĐ - Itel', 'Itel',  'Dung Pham comment!', 'Sản phẩm chất lượng cao', '2024-07-03', '2024-07-03', NULL, FALSE, NULL),
(1, 28, 'Thẻ 100.000 VNĐ - Itel', 'Itel',  'Dung Pham comment!', 'Giá cả hợp lý', '2024-07-04', '2024-07-04', NULL, FALSE, NULL),
(1, 29, 'Thẻ 200.000 VNĐ - Itel', 'Itel',  'Dung Pham comment!', 'Rất hài lòng với dịch vụ', '2024-07-05', '2024-07-05', NULL, FALSE, NULL),
(1, 30, 'Thẻ 500.000 VNĐ - Itel', 'Itel', 'Dung Pham comment!', 'Sản phẩm rất tốt', '2024-07-06', '2024-07-06', NULL, FALSE, NULL),

-- Thẻ Itel
(1, 31, 'Thẻ 10.000 VNĐ - Itel', 'Itel',  'Dung Pham comment!', 'Dịch vụ nhanh chóng và đáng tin cậy', '2024-07-01', '2024-07-01', NULL, FALSE, NULL),
(1, 32, 'Thẻ 20.000 VNĐ - Itel', 'Itel', 'Dung Pham comment!', 'Giao hàng nhanh', '2024-07-02', '2024-07-02', NULL, FALSE, NULL),
(1, 33, 'Thẻ 50.000 VNĐ - Itel', 'Itel',  'Dung Pham comment!', 'Sản phẩm chất lượng cao', '2024-07-03', '2024-07-03', NULL, FALSE, NULL),
(1, 34, 'Thẻ 100.000 VNĐ - Itel', 'Itel',  'Dung Pham comment!', 'Giá cả hợp lý', '2024-07-04', '2024-07-04', NULL, FALSE, NULL),
(1, 35, 'Thẻ 200.000 VNĐ - Itel', 'Itel',  'Dung Pham comment!', 'Rất hài lòng với dịch vụ', '2024-07-05', '2024-07-05', NULL, FALSE, NULL),
(1, 36, 'Thẻ 500.000 VNĐ - Itel', 'Itel',  'Dung Pham comment!', 'Sản phẩm rất tốt', '2024-07-06', '2024-07-06', NULL, FALSE, NULL),

-- Thẻ Zing
(1, 37, 'Thẻ 10.000 VNĐ - Itel', 'Itel', 'Dung Pham comment!', 'Dịch vụ nhanh chóng và đáng tin cậy', '2024-07-01', '2024-07-01', NULL, FALSE, NULL),
(1, 38, 'Thẻ 20.000 VNĐ - Itel', 'Itel',  'Dung Pham comment!', 'Giao hàng nhanh', '2024-07-02', '2024-07-02', NULL, FALSE, NULL),
(1, 39, 'Thẻ 50.000 VNĐ - Itel', 'Itel',  'Dung Pham comment!', 'Sản phẩm chất lượng cao', '2024-07-03', '2024-07-03', NULL, FALSE, NULL),
(1, 40, 'Thẻ 100.000 VNĐ - Itel', 'Itel',  'Dung Pham comment!', 'Giá cả hợp lý', '2024-07-04', '2024-07-04', NULL, FALSE, NULL),
(1, 41, 'Thẻ 200.000 VNĐ - Itel', 'Itel',  'Dung Pham comment!', 'Rất hài lòng với dịch vụ', '2024-07-05', '2024-07-05', NULL, FALSE, NULL),
(1, 42, 'Thẻ 500.000 VNĐ - Itel', 'Itel',  'Dung Pham comment!', 'Sản phẩm rất tốt', '2024-07-06', '2024-07-06', NULL, FALSE, NULL),


-- ID 6,7,8,9
-- Thẻ Viettel
(6, 1, 'Thẻ 10.000 VNĐ - Viettel', 'Viettel', 'Dung Le comment!', 'Dịch vụ nhanh chóng và đáng tin cậy', '2024-07-01', '2024-07-01', NULL, FALSE, NULL),
(7, 2, 'Thẻ 20.000 VNĐ - Viettel', 'Viettel', 'Viet Hoang comment!', 'Giao hàng nhanh', '2024-07-02', '2024-07-02', NULL, FALSE, NULL),
(8, 3, 'Thẻ 50.000 VNĐ - Viettel', 'Viettel', 'Nam Nguyen comment!', 'Sản phẩm chất lượng cao', '2024-07-03', '2024-07-03', NULL, FALSE, NULL),
(9, 4, 'Thẻ 100.000 VNĐ - Viettel', 'Viettel', 'Son Do comment!', 'Giá cả hợp lý', '2024-07-04', '2024-07-04', NULL, FALSE, NULL),
(10, 5, 'Thẻ 200.000 VNĐ - Viettel', 'Viettel', 'Nam Pham comment!', 'Rất hài lòng với dịch vụ', '2024-07-05', '2024-07-05', NULL, FALSE, NULL),
(11, 6, 'Thẻ 500.000 VNĐ - Viettel', 'Viettel', 'Hai Bui comment!', 'Sản phẩm rất tốt', '2024-07-06', '2024-07-06', NULL, FALSE, NULL),

-- Thẻ Mobiphone
(12, 7, 'Thẻ 10.000 VNĐ - Mobiphone', 'Mobiphone', 'Thanh Chu comment!', 'Dịch vụ nhanh chóng và đáng tin cậy', '2024-07-01', '2024-07-01', NULL, FALSE, NULL),
(13, 8, 'Thẻ 20.000 VNĐ - Mobiphone', 'Mobiphone', 'Dong Truong comment!', 'Giao hàng nhanh', '2024-07-02', '2024-07-02', NULL, FALSE, NULL),
(14, 9, 'Thẻ 50.000 VNĐ - Mobiphone', 'Mobiphone', 'Cuong Le comment!', 'Sản phẩm chất lượng cao', '2024-07-03', '2024-07-03', NULL, FALSE, NULL),
(15, 10, 'Thẻ 100.000 VNĐ - Mobiphone', 'Mobiphone', 'Quang Le comment!', 'Giá cả hợp lý', '2024-07-04', '2024-07-04', NULL, FALSE, NULL),
(16, 11, 'Thẻ 200.000 VNĐ - Mobiphone', 'Mobiphone', 'Huy Ngo comment!', 'Rất hài lòng với dịch vụ', '2024-07-05', '2024-07-05', NULL, FALSE, NULL),
(17, 12, 'Thẻ 500.000 VNĐ - Mobiphone', 'Mobiphone', 'Thang Vuong comment!', 'Sản phẩm rất tốt', '2024-07-06', '2024-07-06', NULL, FALSE, NULL),

-- Thẻ Vinaphone
(6, 13, 'Thẻ 10.000 VNĐ - Vinaphone', 'Vinaphone',  'Dung Le comment!', 'Dịch vụ nhanh chóng và đáng tin cậy', '2024-07-01', '2024-07-01', NULL, FALSE, NULL),
(7, 14, 'Thẻ 20.000 VNĐ - Vinaphone', 'Vinaphone',  'Viet Hoang comment!', 'Giao hàng nhanh', '2024-07-02', '2024-07-02', NULL, FALSE, NULL),
(8, 15, 'Thẻ 50.000 VNĐ - Vinaphone', 'Vinaphone',  'Nam Nguyen comment!', 'Sản phẩm chất lượng cao', '2024-07-03', '2024-07-03', NULL, FALSE, NULL),
(9, 16, 'Thẻ 100.000 VNĐ - Vinaphone', 'Vinaphone',  'Son Do comment!', 'Giá cả hợp lý', '2024-07-04', '2024-07-04', NULL, FALSE, NULL),
(10, 17, 'Thẻ 200.000 VNĐ - Vinaphone', 'Vinaphone',  'Nam Pha comment!', 'Rất hài lòng với dịch vụ', '2024-07-05', '2024-07-05', NULL, FALSE, NULL),
(11, 18, 'Thẻ 500.000 VNĐ - Vinaphone', 'Vinaphone',  'Hai Bui comment!', 'Sản phẩm rất tốt', '2024-07-06', '2024-07-06', NULL, FALSE, NULL),

-- Thẻ Vietnamobi
(11, 19, 'Thẻ 10.000 VNĐ - Vietnamobi', 'Vietnamobi',  'Hai Bui comment!', 'Dịch vụ nhanh chóng và đáng tin cậy', '2024-07-01', '2024-07-01', NULL, FALSE, NULL),
(12, 20, 'Thẻ 20.000 VNĐ - Vietnamobi', 'Vietnamobi',  'Thanh Chu comment!', 'Giao hàng nhanh', '2024-07-02', '2024-07-02', NULL, FALSE, NULL),
(13, 21, 'Thẻ 50.000 VNĐ - Vietnamobi', 'Vietnamobi',  'Dong Truong comment!', 'Sản phẩm chất lượng cao', '2024-07-03', '2024-07-03', NULL, FALSE, NULL),
(14, 22, 'Thẻ 100.000 VNĐ - Vietnamobi', 'Vietnamobi',  'Cuong Le comment!', 'Giá cả hợp lý', '2024-07-04', '2024-07-04', NULL, FALSE, NULL),
(15, 23, 'Thẻ 200.000 VNĐ - Vietnamobi', 'Vietnamobi',  'Quang Le comment!', 'Rất hài lòng với dịch vụ', '2024-07-05', '2024-07-05', NULL, FALSE, NULL),
(16, 24, 'Thẻ 500.000 VNĐ - Vietnamobi', 'Vietnamobi',  'Huy Ngo comment!', 'Sản phẩm rất tốt', '2024-07-06', '2024-07-06', NULL, FALSE, NULL),

-- Garenna
(18, 25, 'Thẻ 10.000 VNĐ - Itel', 'Itel',  'Trung Dinh comment!', 'Dịch vụ nhanh chóng và đáng tin cậy', '2024-07-01', '2024-07-01', NULL, FALSE, NULL),
(19, 26, 'Thẻ 20.000 VNĐ - Itel', 'Itel',  'Hoang Que comment!', 'Giao hàng nhanh', '2024-07-02', '2024-07-02', NULL, FALSE, NULL),
(20, 27, 'Thẻ 50.000 VNĐ - Itel', 'Itel',  'Duc Hoang comment!', 'Sản phẩm chất lượng cao', '2024-07-03', '2024-07-03', NULL, FALSE, NULL),
(21, 28, 'Thẻ 100.000 VNĐ - Itel', 'Itel',  'Khanh Hoang comment!', 'Giá cả hợp lý', '2024-07-04', '2024-07-04', NULL, FALSE, NULL),
(22, 29, 'Thẻ 200.000 VNĐ - Itel', 'Itel',  'Huy Ngo comment!', 'Rất hài lòng với dịch vụ', '2024-07-05', '2024-07-05', NULL, FALSE, NULL),
(12, 30, 'Thẻ 500.000 VNĐ - Itel', 'Itel', 'Thanh Chu comment!', 'Sản phẩm rất tốt', '2024-07-06', '2024-07-06', NULL, FALSE, NULL),

-- Thẻ Itel
(12, 31, 'Thẻ 10.000 VNĐ - Itel', 'Itel',  'Thanh Chu comment!', 'Dịch vụ nhanh chóng và đáng tin cậy', '2024-07-01', '2024-07-01', NULL, FALSE, NULL),
(13, 32, 'Thẻ 20.000 VNĐ - Itel', 'Itel', 'Dong Truong comment!', 'Giao hàng nhanh', '2024-07-02', '2024-07-02', NULL, FALSE, NULL),
(14, 33, 'Thẻ 50.000 VNĐ - Itel', 'Itel',  'Cuong Le comment!', 'Sản phẩm chất lượng cao', '2024-07-03', '2024-07-03', NULL, FALSE, NULL),
(16, 34, 'Thẻ 100.000 VNĐ - Itel', 'Itel',  'Huy Ngo comment!', 'Giá cả hợp lý', '2024-07-04', '2024-07-04', NULL, FALSE, NULL),
(14, 35, 'Thẻ 200.000 VNĐ - Itel', 'Itel',  'Cuong Le comment!', 'Rất hài lòng với dịch vụ', '2024-07-05', '2024-07-05', NULL, FALSE, NULL),
(17, 36, 'Thẻ 500.000 VNĐ - Itel', 'Itel',  'Thang Vuong comment!', 'Sản phẩm rất tốt', '2024-07-06', '2024-07-06', NULL, FALSE, NULL),

-- Thẻ Zing
(12, 37, 'Thẻ 10.000 VNĐ - Itel', 'Itel', 'Thanh Chu comment!', 'Dịch vụ nhanh chóng và đáng tin cậy', '2024-07-01', '2024-07-01', NULL, FALSE, NULL),
(13, 38, 'Thẻ 20.000 VNĐ - Itel', 'Itel',  'Dong Truong comment!', 'Giao hàng nhanh', '2024-07-02', '2024-07-02', NULL, FALSE, NULL),
(14, 39, 'Thẻ 50.000 VNĐ - Itel', 'Itel',  'Cuong Le comment!', 'Sản phẩm chất lượng cao', '2024-07-03', '2024-07-03', NULL, FALSE, NULL),
(15, 40, 'Thẻ 100.000 VNĐ - Itel', 'Itel',  'Quang Le comment!', 'Giá cả hợp lý', '2024-07-04', '2024-07-04', NULL, FALSE, NULL),
(16, 41, 'Thẻ 200.000 VNĐ - Itel', 'Itel',  'Huy Ngom comment!', 'Rất hài lòng với dịch vụ', '2024-07-05', '2024-07-05', NULL, FALSE, NULL),
(17, 42, 'Thẻ 500.000 VNĐ - Itel', 'Itel',  'Thang Vuong comment!', 'Sản phẩm rất tốt', '2024-07-06', '2024-07-06', NULL, FALSE, NULL);



-- Insert data to categoriesNews;
INSERT INTO CategoriesNews (Title, CreatedAt) VALUES
('Khuyến mãi và giảm giá', NOW()),          -- Các chương trình khuyến mãi và giảm giá đặc biệt
('Cập nhật sản phẩm', NOW()),                -- Giới thiệu các sản phẩm và thay đổi mới
('Tin tức công nghệ', NOW()),                -- Cập nhật về các công nghệ mới trong lĩnh vực viễn thông
('Tin tức công ty', NOW()),                  -- Thông báo về các hoạt động và sự kiện của công ty
('Thông báo hệ thống', NOW()),              -- Thông báo về bảo trì và sự cố hệ thống
('Tin tức tài chính', NOW()),                -- Cập nhật về phương thức thanh toán và bảo mật
('Chương trình tri ân', NOW());              -- Thông báo về các chương trình tri ân khách hàng

-- Insert data to News;
-- Khuyến mãi và giảm giá
INSERT INTO News (Title, Description, ContentFirst, ContentBody, ContentEnd, CategoriesID, Hotnews, Image, DescriptionImage, CreatedAt) VALUES
('Khuyến mãi cực sốc mùa hè 2024!', 'Giảm giá cực lớn lên đến 50% cho tất cả các thẻ điện thoại.', 
'Chúng tôi rất vui mừng thông báo về chương trình khuyến mãi mùa hè 2024. Trong suốt thời gian khuyến mãi, tất cả các thẻ điện thoại sẽ được giảm giá lên đến 50%!', 
'Đây là cơ hội tuyệt vời để bạn tiết kiệm chi phí và trải nghiệm dịch vụ di động chất lượng cao với mức giá ưu đãi. Chúng tôi cam kết cung cấp các sản phẩm chất lượng nhất và dịch vụ chăm sóc khách hàng tốt nhất. Hãy nhanh tay đặt hàng trước khi chương trình khuyến mãi kết thúc vào cuối tháng 8!', 
'Chúng tôi rất mong bạn sẽ tận hưởng các ưu đãi đặc biệt này. Đừng bỏ lỡ cơ hội tuyệt vời này!', 
1, TRUE, 'summer_promo_2024.jpg', 'Khuyến mãi mùa hè 2024', NOW()),

('Khuyến mãi cuối năm đặc biệt', 'Nhận ưu đãi giảm giá lên đến 60% vào dịp cuối năm.', 
'Chúng tôi đang tổ chức một chương trình khuyến mãi đặc biệt vào cuối năm với mức giảm giá lên đến 60% cho tất cả các thẻ điện thoại.', 
'Chương trình khuyến mãi này sẽ giúp bạn tiết kiệm chi phí mua sắm và có cơ hội nhận thêm nhiều quà tặng hấp dẫn. Đừng bỏ lỡ cơ hội này vì chương trình chỉ kéo dài đến ngày 31 tháng 12.', 
'Hãy nhanh chóng đặt hàng để nhận được các ưu đãi đặc biệt và quà tặng miễn phí!', 
1, TRUE, 'endyear_promo.jpg', 'Khuyến mãi cuối năm', NOW()),

('Giảm giá sốc vào Black Friday', 'Ưu đãi lớn vào ngày Black Friday với mức giảm lên đến 70%.', 
'Chúng tôi vui mừng thông báo chương trình khuyến mãi Black Friday với mức giảm giá cực lớn lên đến 70% cho tất cả các thẻ điện thoại.', 
'Đây là cơ hội tốt nhất trong năm để bạn tiết kiệm chi phí và mua sắm thẻ điện thoại với giá cực kỳ ưu đãi. Chương trình khuyến mãi chỉ áp dụng trong ngày Black Friday.', 
'Đừng bỏ lỡ cơ hội này! Hãy đặt hàng ngay để nhận được ưu đãi và các phần quà hấp dẫn.', 
1, TRUE, 'black_friday_promo.jpg', 'Khuyến mãi Black Friday', NOW()),

('Ưu đãi ngày lễ Tết Nguyên Đán', 'Giảm giá và quà tặng nhân dịp Tết Nguyên Đán.', 
'Nhân dịp Tết Nguyên Đán, chúng tôi tổ chức chương trình khuyến mãi đặc biệt với các ưu đãi giảm giá và quà tặng hấp dẫn.', 
'Bạn sẽ nhận được các thẻ điện thoại với mức giảm giá đặc biệt và nhiều phần quà thú vị. Đây là cơ hội để bạn chuẩn bị cho năm mới với chi phí tiết kiệm hơn.', 
'Hãy tham gia chương trình khuyến mãi Tết Nguyên Đán và nhận những phần quà ý nghĩa!', 
1, TRUE, 'tet_promo.jpg', 'Khuyến mãi Tết Nguyên Đán', NOW());

-- Cập nhật sản phẩm
INSERT INTO News (Title, Description, ContentFirst, ContentBody, ContentEnd, CategoriesID, Hotnews, Image, DescriptionImage, CreatedAt) VALUES
('Ra mắt thẻ điện thoại mới - Tháng 8', 'Giới thiệu các thẻ điện thoại mới với nhiều ưu đãi.', 
'Chúng tôi vui mừng thông báo về sự ra mắt của các thẻ điện thoại mới trong tháng 8.', 
'Những thẻ điện thoại này không chỉ mang đến các tính năng cải tiến mà còn đi kèm với các ưu đãi đặc biệt. Hãy cập nhật và trải nghiệm các sản phẩm mới để tận hưởng dịch vụ di động tốt nhất.', 
'Đừng bỏ lỡ cơ hội trải nghiệm các sản phẩm mới và nhận ưu đãi hấp dẫn!', 
2, TRUE, 'new_product_august.jpg', 'Sản phẩm tháng 8', NOW()),

('Cập nhật thẻ điện thoại tháng 9', 'Danh sách các thẻ điện thoại mới cập nhật cho tháng 9.', 
'Chúng tôi đã cập nhật danh sách các thẻ điện thoại cho tháng 9 với nhiều ưu đãi và sản phẩm mới.', 
'Hãy kiểm tra ngay danh sách sản phẩm và ưu đãi để không bỏ lỡ cơ hội tiết kiệm chi phí và nhận các phần quà hấp dẫn. Chúng tôi cam kết cung cấp các sản phẩm chất lượng và dịch vụ tốt nhất.', 
'Đặt hàng ngay để nhận được ưu đãi và sản phẩm mới nhất!', 
2, TRUE, 'september_updates.jpg', 'Cập nhật tháng 9', NOW()),

('Thẻ điện thoại mới - Tính năng và ưu đãi', 'Khám phá các tính năng mới của thẻ điện thoại và ưu đãi đi kèm.', 
'Chúng tôi giới thiệu các thẻ điện thoại mới với các tính năng nâng cao và ưu đãi đặc biệt.', 
'Những thẻ điện thoại này mang lại nhiều lợi ích và cải tiến về hiệu suất sử dụng. Hãy khám phá các tính năng mới và tận dụng các ưu đãi đi kèm để có trải nghiệm dịch vụ di động tốt nhất.', 
'Đừng bỏ lỡ cơ hội trải nghiệm các sản phẩm mới và nhận ưu đãi hấp dẫn!', 
2, TRUE, 'new_features.jpg', 'Tính năng thẻ điện thoại', NOW()),

('Đổi mới trong các gói thẻ điện thoại', 'Cập nhật về các gói thẻ điện thoại và ưu đãi mới.', 
'Chúng tôi đã cập nhật các gói thẻ điện thoại với nhiều lựa chọn mới và ưu đãi đặc biệt.', 
'Các gói thẻ điện thoại mới này được thiết kế để đáp ứng nhu cầu sử dụng của bạn và mang lại nhiều lợi ích hơn. Hãy kiểm tra các gói thẻ mới và tận hưởng các ưu đãi hấp dẫn.', 
'Đặt hàng ngay để trải nghiệm các gói thẻ điện thoại mới và nhận ưu đãi đặc biệt!', 
2, TRUE, 'new_packages.jpg', 'Gói thẻ điện thoại mới', NOW());

-- Tin tức công nghệ
INSERT INTO News (Title, Description, ContentFirst, ContentBody, ContentEnd, CategoriesID, Hotnews, Image, DescriptionImage, CreatedAt) VALUES
('Xu hướng công nghệ viễn thông 2024', 'Khám phá các xu hướng công nghệ mới trong lĩnh vực viễn thông.', 
'Năm 2024 đánh dấu sự phát triển mạnh mẽ trong công nghệ viễn thông với nhiều xu hướng nổi bật.', 
'Chúng tôi điểm qua các xu hướng công nghệ mới như 5G, IoT, và các giải pháp kết nối thông minh, giúp cải thiện hiệu suất dịch vụ và mở ra nhiều cơ hội mới cho người tiêu dùng.', 
'Hãy theo dõi các cập nhật công nghệ mới để không bỏ lỡ những đổi mới quan trọng trong ngành viễn thông.', 
3, TRUE, 'tech_trends_2024.jpg', 'Xu hướng công nghệ 2024', NOW()),

('Công nghệ 5G và ảnh hưởng của nó đến viễn thông', 'Tìm hiểu về công nghệ 5G và ảnh hưởng của nó đối với ngành viễn thông.', 
'Công nghệ 5G đang thay đổi cách chúng ta kết nối và tương tác, mang lại dịch vụ di động nhanh hơn và ổn định hơn.', 
'Với tốc độ truyền tải dữ liệu cao và độ trễ thấp, 5G sẽ mở ra nhiều cơ hội mới trong các lĩnh vực như IoT, thực tế ảo và tăng cường, giúp cải thiện trải nghiệm người dùng.', 
'Khám phá những ảnh hưởng của 5G và cách công nghệ này đang thay đổi ngành viễn thông.', 
3, TRUE, '5g_technology.jpg', 'Công nghệ 5G', NOW()),

('Những đổi mới trong công nghệ mạng 2024', 'Cập nhật về các đổi mới trong công nghệ mạng trong năm 2024.', 
'Công nghệ mạng đang có những bước tiến lớn trong năm 2024 với nhiều đổi mới và cải tiến.', 
'Chúng tôi sẽ cung cấp cái nhìn tổng quan về các đổi mới trong công nghệ mạng, bao gồm các giải pháp kết nối thông minh và cải tiến về bảo mật mạng.', 
'Đừng bỏ lỡ các cập nhật quan trọng về công nghệ mạng và cách chúng có thể mang lại lợi ích cho bạn.', 
3, TRUE, 'network_innovations_2024.jpg', 'Đổi mới công nghệ mạng', NOW()),

('Công nghệ mạng thế hệ tiếp theo', 'Giới thiệu về các công nghệ mạng thế hệ tiếp theo và tiềm năng của chúng.', 
'Công nghệ mạng thế hệ tiếp theo đang hứa hẹn mang đến nhiều cải tiến và cơ hội mới trong ngành công nghiệp viễn thông.', 
'Chúng tôi sẽ khám phá các công nghệ mạng mới như mạng định hướng dịch vụ, mạng có thể lập trình và các giải pháp kết nối thế hệ mới, giúp nâng cao trải nghiệm người dùng và đáp ứng nhu cầu ngày càng cao.', 
'Theo dõi các cập nhật công nghệ để biết thêm chi tiết về các công nghệ mạng thế hệ tiếp theo.', 
3, TRUE, 'next_gen_network.jpg', 'Công nghệ mạng thế hệ tiếp theo', NOW());

-- Tin tức công ty
INSERT INTO News (Title, Description, ContentFirst, ContentBody, ContentEnd, CategoriesID, Hotnews, Image, DescriptionImage, CreatedAt) VALUES
('Mở rộng chi nhánh mới tại Hà Nội', 'Thông báo về việc mở rộng chi nhánh mới của công ty tại Hà Nội.', 
'Chúng tôi vui mừng thông báo về việc mở rộng chi nhánh mới tại Hà Nội.', 
'Chi nhánh mới này sẽ giúp chúng tôi phục vụ khách hàng tốt hơn và mở rộng phạm vi dịch vụ của mình tại khu vực miền Bắc. Chi nhánh sẽ chính thức hoạt động từ ngày 1 tháng 9.', 
'Chúng tôi rất mong được phục vụ bạn tại chi nhánh mới và cung cấp các dịch vụ di động chất lượng cao.', 
4, TRUE, 'new_branch_hanoi.jpg', 'Chi nhánh mới Hà Nội', NOW()),

('Chương trình đào tạo nhân viên mới', 'Thông báo về chương trình đào tạo và phát triển kỹ năng cho nhân viên mới.', 
'Chúng tôi đang tổ chức chương trình đào tạo để nâng cao kỹ năng và kiến thức cho các nhân viên mới.', 
'Chương trình này sẽ giúp nhân viên làm quen với quy trình làm việc và cải thiện kỹ năng cần thiết để phục vụ khách hàng tốt hơn. Chúng tôi cam kết đầu tư vào việc phát triển đội ngũ nhân viên của mình để đảm bảo chất lượng dịch vụ.', 
'Chúng tôi rất tự hào về đội ngũ nhân viên của mình và tin rằng chương trình đào tạo này sẽ góp phần nâng cao chất lượng dịch vụ.', 
4, TRUE, 'training_program.jpg', 'Chương trình đào tạo nhân viên', NOW()),

('Nhân viên xuất sắc tháng này', 'Danh sách nhân viên xuất sắc nhất của tháng và thành tích đạt được.', 
'Chúng tôi xin chúc mừng các nhân viên xuất sắc nhất của tháng này vì những thành tích đáng ghi nhận.', 
'Những nhân viên này đã thể hiện sự cống hiến và nỗ lực vượt trội trong công việc. Chúng tôi rất tự hào về những thành tích mà họ đã đạt được và mong muốn ghi nhận đóng góp của họ đối với sự thành công của công ty.', 
'Hãy cùng chúng tôi chúc mừng các nhân viên xuất sắc và tiếp tục hỗ trợ họ trong công việc.', 
4, TRUE, 'employee_of_the_month.jpg', 'Nhân viên xuất sắc tháng này', NOW()),

('Sự kiện kỷ niệm 10 năm thành lập công ty', 'Thông báo về sự kiện kỷ niệm 10 năm thành lập công ty.', 
'Chúng tôi vui mừng thông báo về sự kiện kỷ niệm 10 năm thành lập công ty của chúng tôi, sẽ được tổ chức vào ngày 15 tháng 9 tới.', 
'Trong sự kiện này, chúng tôi sẽ tổ chức nhiều hoạt động thú vị, bao gồm các buổi giao lưu, hội thảo và các chương trình khuyến mãi đặc biệt. Đây là cơ hội tuyệt vời để bạn gặp gỡ đội ngũ của chúng tôi, tìm hiểu thêm về các sản phẩm và dịch vụ mới, và cùng chúng tôi kỷ niệm một chặng đường 10 năm thành công.', 
'Hãy tham gia sự kiện và cùng chúng tôi tạo nên những kỷ niệm đáng nhớ trong ngày kỷ niệm đặc biệt này!', 
4, TRUE, 'company_anniversary.jpg', 'Kỷ niệm 10 năm thành lập công ty', NOW());

-- Thông báo hệ thống
INSERT INTO News (Title, Description, ContentFirst, ContentBody, ContentEnd, CategoriesID, Hotnews, Image, DescriptionImage, CreatedAt) VALUES
('Bảo trì hệ thống vào cuối tuần này', 'Thông báo về việc bảo trì hệ thống trong tuần này.', 
'Chúng tôi xin thông báo rằng hệ thống sẽ được bảo trì vào cuối tuần này từ thứ Sáu đến Chủ Nhật.', 
'Trong thời gian bảo trì, một số dịch vụ có thể bị gián đoạn hoặc không khả dụng. Chúng tôi đang nỗ lực để hoàn tất quá trình bảo trì càng sớm càng tốt và giảm thiểu sự ảnh hưởng đến bạn. Chúng tôi xin lỗi về bất kỳ sự bất tiện nào có thể xảy ra và cảm ơn bạn đã thông cảm.', 
'Hãy theo dõi các thông báo cập nhật từ chúng tôi để biết thêm chi tiết về lịch trình bảo trì và trạng thái của hệ thống.', 
5, TRUE, 'system_maintenance.jpg', 'Bảo trì hệ thống', NOW()),

('Sự cố hệ thống - Đã được khắc phục', 'Cập nhật về sự cố hệ thống và tình trạng khắc phục.', 
'Chúng tôi xin thông báo rằng sự cố hệ thống gần đây đã được khắc phục hoàn toàn và các dịch vụ đã hoạt động trở lại bình thường.', 
'Chúng tôi đã làm việc chăm chỉ để xác định nguyên nhân và sửa chữa vấn đề để đảm bảo rằng hệ thống của chúng tôi hoạt động ổn định và đáng tin cậy. Chúng tôi xin lỗi vì sự bất tiện gây ra và cảm ơn bạn đã kiên nhẫn trong thời gian khắc phục sự cố.', 
'Nếu bạn gặp bất kỳ vấn đề nào hoặc cần hỗ trợ thêm, xin vui lòng liên hệ với đội ngũ hỗ trợ khách hàng của chúng tôi.', 
5, TRUE, 'system_issue_fixed.jpg', 'Sự cố hệ thống', NOW()),

('Cảnh báo bảo mật hệ thống', 'Cảnh báo về các mối đe dọa bảo mật gần đây và cách phòng ngừa.', 
'Chúng tôi muốn cảnh báo về các mối đe dọa bảo mật gần đây và cung cấp các biện pháp phòng ngừa để bảo vệ thông tin của bạn.', 
'Để đảm bảo an toàn, chúng tôi khuyến nghị bạn nên thay đổi mật khẩu và kiểm tra các hoạt động đáng ngờ trên tài khoản của mình. Chúng tôi cũng đang thực hiện các biện pháp tăng cường bảo mật để bảo vệ hệ thống khỏi các mối đe dọa.', 
'Hãy tuân thủ các biện pháp phòng ngừa và liên hệ với chúng tôi nếu bạn gặp vấn đề bảo mật.', 
5, TRUE, 'security_alert.jpg', 'Cảnh báo bảo mật', NOW()),

('Cập nhật tình trạng bảo trì hệ thống', 'Thông báo về tiến độ và tình trạng bảo trì hệ thống.', 
'Chúng tôi xin cập nhật tình trạng bảo trì hệ thống hiện tại và các bước tiến hành.', 
'Chúng tôi đang tích cực thực hiện các công việc bảo trì và sửa chữa để hệ thống hoạt động trở lại bình thường. Chúng tôi sẽ tiếp tục thông báo về tiến độ và thời gian hoàn tất bảo trì.', 
'Cảm ơn bạn đã kiên nhẫn và thông cảm trong thời gian bảo trì. Chúng tôi cam kết mang lại dịch vụ tốt nhất cho bạn.', 
5, TRUE, 'maintenance_update.jpg', 'Cập nhật bảo trì hệ thống', NOW());

-- Tin tức tài chính
INSERT INTO News (Title, Description, ContentFirst, ContentBody, ContentEnd, CategoriesID, Hotnews, Image, DescriptionImage, CreatedAt) VALUES
('Cập nhật phương thức thanh toán mới', 'Giới thiệu các phương thức thanh toán mới trên nền tảng của chúng tôi.', 
'Chúng tôi rất vui được thông báo về việc bổ sung các phương thức thanh toán mới trên nền tảng của chúng tôi.', 
'Từ giờ, bạn có thể thanh toán bằng nhiều phương thức khác nhau, bao gồm thẻ tín dụng, ví điện tử và chuyển khoản ngân hàng. Chúng tôi hy vọng rằng sự đa dạng này sẽ mang lại sự tiện lợi hơn cho bạn trong quá trình thanh toán và giúp bạn dễ dàng hơn trong việc quản lý các giao dịch của mình.', 
'Chúng tôi cam kết đảm bảo tính bảo mật và an toàn của tất cả các giao dịch và luôn nỗ lực để mang đến trải nghiệm thanh toán tốt nhất cho bạn.', 
6, TRUE, 'payment_methods_update.jpg', 'Cập nhật phương thức thanh toán', NOW()),

('Cập nhật chính sách bảo mật thanh toán', 'Thông báo về các cập nhật mới trong chính sách bảo mật thanh toán.', 
'Chúng tôi đã thực hiện một số cập nhật quan trọng trong chính sách bảo mật thanh toán của mình để đảm bảo an toàn và bảo mật tối ưu cho tất cả các giao dịch.', 
'Những thay đổi này bao gồm việc áp dụng các biện pháp bảo mật mới và cải tiến quy trình xác thực để bảo vệ thông tin cá nhân và tài chính của bạn. Chúng tôi cam kết sẽ tiếp tục theo dõi và nâng cấp hệ thống bảo mật của mình để đáp ứng nhu cầu ngày càng cao và bảo vệ tốt nhất cho bạn.', 
'Hãy theo dõi các cập nhật và thông báo của chúng tôi để biết thêm chi tiết về các chính sách bảo mật mới.', 
6, TRUE, 'payment_security_update.jpg', 'Cập nhật chính sách bảo mật', NOW()),

('Phương pháp thanh toán bảo mật nhất', 'Hướng dẫn về các phương pháp thanh toán an toàn nhất.', 
'Chúng tôi cung cấp hướng dẫn về các phương pháp thanh toán an toàn nhất để bảo vệ thông tin tài chính của bạn.', 
'Để đảm bảo an toàn, bạn nên sử dụng các phương pháp thanh toán bảo mật như thẻ tín dụng với mã bảo mật, ví điện tử có mã OTP và chuyển khoản qua ngân hàng với các biện pháp bảo mật cao. Chúng tôi khuyến nghị bạn luôn kiểm tra các giao dịch và báo cáo ngay lập tức nếu phát hiện bất kỳ hoạt động nghi ngờ nào.', 
'Chúng tôi cam kết cung cấp các biện pháp bảo mật tối ưu để bảo vệ thông tin của bạn và mang đến sự an tâm trong mỗi giao dịch.', 
6, TRUE, 'secure_payment_methods.jpg', 'Phương pháp thanh toán bảo mật', NOW()),

('Cập nhật tình trạng giao dịch', 'Thông báo về tình trạng và tiến độ giao dịch tài chính.', 
'Chúng tôi cung cấp các thông tin cập nhật về tình trạng và tiến độ giao dịch tài chính của bạn.', 
'Chúng tôi đang nỗ lực để xử lý và hoàn tất các giao dịch một cách nhanh chóng và chính xác nhất. Bạn có thể theo dõi tình trạng giao dịch của mình qua trang quản lý tài khoản và nhận thông báo ngay khi giao dịch hoàn tất.', 
'Chúng tôi cam kết cung cấp dịch vụ giao dịch nhanh chóng và hiệu quả để đáp ứng nhu cầu của bạn.', 
6, TRUE, 'transaction_update.jpg', 'Cập nhật giao dịch', NOW());

-- Chương trình tri ân
INSERT INTO News (Title, Description, ContentFirst, ContentBody, ContentEnd, CategoriesID, Hotnews, Image, DescriptionImage, CreatedAt) VALUES
('Chương trình tri ân khách hàng', 'Thông báo về chương trình tri ân khách hàng với nhiều ưu đãi.', 
'Chúng tôi tổ chức chương trình tri ân khách hàng để cảm ơn sự ủng hộ và tin tưởng của bạn trong thời gian qua.', 
'Chương trình này bao gồm nhiều ưu đãi đặc biệt như giảm giá cho tất cả các thẻ điện thoại, quà tặng miễn phí và các phần thưởng hấp dẫn khác. Đây là cách chúng tôi muốn gửi lời cảm ơn đến tất cả các khách hàng đã đồng hành cùng chúng tôi.', 
'Chúng tôi hy vọng bạn sẽ tận hưởng các ưu đãi và phần thưởng trong chương trình tri ân này.', 
7, TRUE, 'customer_appreciation.jpg', 'Chương trình tri ân khách hàng', NOW()),

('Tặng quà tri ân cho khách hàng thân thiết', 'Nhận quà tặng đặc biệt trong chương trình tri ân khách hàng thân thiết.', 
'Chúng tôi muốn gửi lời cảm ơn đặc biệt đến các khách hàng thân thiết với quà tặng tri ân.', 
'Trong chương trình này, khách hàng thân thiết sẽ nhận được quà tặng độc quyền và ưu đãi đặc biệt. Chúng tôi rất trân trọng sự ủng hộ và lòng trung thành của bạn.', 
'Hãy liên hệ với chúng tôi để nhận quà tặng và tìm hiểu thêm về các ưu đãi đặc biệt trong chương trình tri ân này.', 
7, TRUE, 'loyalty_rewards.jpg', 'Quà tặng tri ân', NOW()),

('Ưu đãi đặc biệt cho khách hàng VIP', 'Nhận ưu đãi đặc biệt dành cho khách hàng VIP trong chương trình tri ân.', 
'Chúng tôi dành riêng các ưu đãi đặc biệt cho khách hàng VIP như một cách để tri ân sự hỗ trợ và lòng trung thành của bạn.', 
'Khách hàng VIP sẽ được hưởng các quyền lợi đặc biệt như giảm giá cao hơn, quà tặng độc quyền và các dịch vụ ưu tiên. Đây là cách chúng tôi muốn thể hiện sự biết ơn của mình đối với sự hỗ trợ của bạn.', 
'Chúng tôi mong bạn sẽ tận hưởng các ưu đãi và dịch vụ đặc biệt này.', 
7, TRUE, 'vip_rewards.jpg', 'Ưu đãi khách hàng VIP', NOW()),

('Chương trình khuyến mãi tri ân cuối năm', 'Nhận ưu đãi và quà tặng trong chương trình khuyến mãi tri ân cuối năm.', 
'Nhân dịp cuối năm, chúng tôi tổ chức chương trình khuyến mãi tri ân với nhiều ưu đãi hấp dẫn và quà tặng đặc biệt.', 
'Chương trình này là cơ hội tuyệt vời để bạn nhận được các ưu đãi lớn và các phần quà ý nghĩa. Hãy tham gia để không bỏ lỡ các cơ hội hấp dẫn trong dịp cuối năm.', 
'Chúng tôi rất vui được gửi lời cảm ơn đến bạn và hy vọng bạn sẽ tận hưởng chương trình khuyến mãi tri ân này.', 
7, TRUE, 'endyear_appreciation.jpg', 'Khuyến mãi tri ân cuối năm', NOW());


-- Insert data to voucher:
INSERT INTO Voucher (Title, PurchaseOffer, ApplyDescription, Image, ApplyBrandID, ApplyProductID, FromDate, ToDate, PriceFrom, Discount, DiscountMax,Quantity, CreatedAt, DeletedAt, IsDelete, DeletedBy)
VALUES
('Giảm giá sốc', 'Giảm giá 10% cho đơn hàng tối thiểu 200k', 'Áp dụng cho tất cả các sản phẩm trên hệ thống','zing_logo.jpg', null, null,'2024-07-01', '2025-07-31', 200000, 10, 50000, 10,NOW(), NULL, FALSE, NULL),
('Giảm giá sốc', 'Giảm giá 5% cho đơn hàng tối thiểu 100k', 'Áp dụng cho tất cả các sản phẩm trên hệ thống','zing_logo.jpg', null, null, '2024-08-01', '2025-08-31', 100000, 5, 25000, 10,NOW(),  NULL, FALSE, NULL),
('Giảm giá sốc', 'Giảm giá 20% cho đơn hàng tối thiểu 500k', 'Áp dụng cho tất cả các sản phẩm trên hệ thống','zing_logo.jpg', null, null, '2024-11-25', '2025-11-30', 500000, 20, 100000, 10,NOW(),  NULL, FALSE, NULL),
('Giảm giá sốc', 'Giảm giá 15% cho đơn hàng tối thiểu 300k', 'Áp dụng cho sản phẩm thẻ điện thoại của Viettel','viettel_logo.jpg', 1, 5, '2024-12-20', '2025-12-25', 300000, 15, 75000, 10,NOW(), NULL, FALSE, NULL),
('Giảm giá sốc', 'Giảm giá 12% cho đơn hàng tối thiểu 400k', 'Áp dụng cho sản phẩm thẻ điện thoại của Viettel','viettel_logo.jpg', 1, null, '2024-01-01', '2025-01-10', 400000, 12, 60000, 10,NOW(),  NULL, FALSE, NULL),
('Giảm giá sốc', 'Giảm giá 8% cho đơn hàng tối thiểu 150k', 'Áp dụng cho sản phẩm thẻ điện thoại của Viettel','viettel_logo.jpg', 1, null, '2024-02-10', '2025-02-14', 150000, 8, 20000, 10,NOW(), NULL, FALSE, NULL),
('Giảm giá sốc', 'Giảm giá 7% cho đơn hàng tối thiểu 250k', 'Áp dụng cho sản phẩm thẻ điện thoại của Viettel','viettel_logo.jpg', 1, null,  '2024-04-01', '2025-04-10', 250000, 7, 35000, 10,NOW(),  NULL, FALSE, NULL),
('Giảm giá sốc', 'Giảm giá 10% cho đơn hàng tối thiểu 300k', 'Áp dụng cho sản phẩm thẻ điện thoại của Viettel','viettel_logo.jpg', 1, null, '2024-06-01', '2025-06-15', 300000, 10, 50000, 10,NOW(),  NULL, FALSE, NULL),
('Giảm giá sốc', 'Giảm giá 15% cho đơn hàng tối thiểu 500k', 'Áp dụng cho sản phẩm thẻ điện thoại của Viettel','viettel_logo.jpg', 1, null, '2024-09-02', '2025-09-05', 500000, 15, 75000, 10,NOW(),  NULL, FALSE, NULL),
('Giảm giá sốc', 'Giảm giá 20% cho đơn hàng tối thiểu 400k', 'Áp dụng cho sản phẩm thẻ điện thoại của Viettel','viettel_logo.jpg', 1, null,  '2024-10-28', '2025-10-31', 400000, 20, 80000, 10,NOW(),  NULL, FALSE, NULL);


-- Insert policy
INSERT INTO NameAgreementPolicy (Name, Status, CreatedAt, UpdatedAt, DeletedAt, IsDelete)
VALUES 
('Chính sách bảo mật', 'Active', '2023-01-01', '2023-01-01', NULL, 0),
('Điều khoản dịch vụ', 'Active', '2023-01-01', '2023-01-01', NULL, 0),
('Chính sách hoàn tiền', 'Active', '2023-01-01', '2023-01-01', NULL, 0),
('Thỏa thuận người dùng', 'Active', '2023-01-01', '2023-01-01', NULL, 0),
('Chính sách lưu giữ dữ liệu', 'Active', '2023-01-01', '2023-01-01', NULL, 0);

Insert AgreementPolicy (IDNameAgreementPolicy, Message, CreatedAt, UpdatedAt, DeletedAt, IsDelete)
Value
(1, 'Chính sách này nêu rõ cách chúng tôi thu thập, sử dụng và bảo vệ dữ liệu của bạn. Bằng cách đồng ý, bạn đồng ý với các hoạt động của chúng tôi liên quan đến việc xử lý dữ liệu và các biện pháp bảo mật để bảo vệ quyền riêng tư của bạn.', '2023-01-01', '2023-01-01', NULL, 0),
(2, 'Các điều khoản này chi phối việc bạn sử dụng các dịch vụ của chúng tôi, nêu rõ các quyền và trách nhiệm của bạn. Bằng cách chấp nhận, bạn đồng ý tuân thủ mọi luật và quy định hiện hành khi sử dụng trang web của chúng tôi.', '2023-01-01', '2023-01-01', NULL, 0),
(3, 'Nếu bạn không hài lòng với giao dịch mua của mình, chính sách này giải thích các bước bạn cần thực hiện để yêu cầu hoàn lại tiền, bao gồm tiêu chí đủ điều kiện, mốc thời gian và cách xử lý hoàn lại tiền.', '2023-01-01', '2023-01-01', NULL, 0),
(4, 'Thỏa thuận này bao gồm các điều khoản mà bạn có thể truy cập và sử dụng các dịch vụ của chúng tôi, bao gồm tạo tài khoản, phương thức thanh toán và hành vi của người dùng. Việc chấp nhận là bắt buộc để truy cập trang web.', '2023-01-01', '2023-01-01', NULL, 0),
(5, 'Chúng tôi lưu giữ thông tin cá nhân của bạn và trong trường hợp nào thông tin sẽ bị xóa. Chính sách này đảm bảo rằng dữ liệu chỉ được lưu giữ trong thời gian cần thiết cho các mục đích mà dữ liệu được thu thập, tuân thủ các yêu cầu pháp lý.', '2023-01-01', '2023-01-01', NULL, 0);

INSERT INTO favoriteproduct(ID, UserID, ProductCategoriesID, CreatedAt)
VALUES
(1, 1, 2, now()),
(2, 1, 3, now()),
(3, 1, 1, now()),
(4, 1, 4, now()),
(5, 1, 2, now()),
(6, 1, 3, now()),
(7, 1, 1, now());
INSERT INTO registermember(UserID, Email1, Email2, Message, CreatedAt, UpdatedAt, DeletedAt, IsDelete, DeletedBy)
VALUES
(1, 'NamNHHE1713828@fpt.edu.vn', 'wrong@gmail.com', 'Tôi đồng ý và cam kết thông tin đúng', now(), now(), NULL, 0, NULL),
(7, 'wronge1@example.com', 'wronge2@gmail.com', 'Tôi đã mời 2 người bạn sử dụng web', now(), now(), NULL, 0, NULL),
(2, 'wronge33@example.com', 'DongDTHE171684@fpt.edu.vn', 'Bạn của tôi đang đăng ký', now(), now(), NULL, 0, NULL),
(3, 'CuongLVHE171920@fpt.edu.vn', 'QuangLVHE171994@fpt.edu.vn', 'Tôi rất thích thú chương trình này', now(), now(), NULL, 0, NULL),
(4, 'KhanhHNHE173434@fpt.edu.vn', 'AnNDHE176533@fpt.edu.vn', 'Chương trình này oke', now(), now(), NULL, 0, NULL),
(5, 'KhanhLGHE180423@fpt.edu.vn', 'QuanNTHE187203@fpt.edu.vn', 'Membership confirmed.', now(), now(), NULL, 0, NULL),
(6, 'Opps@example.com', 'dangky@example.com', 'Enjoy my benefits!', now(), now(), NULL, 0, NULL);