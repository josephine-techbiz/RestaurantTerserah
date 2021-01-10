CREATE DATABASE Restaurant_terserah

CREATE TABLE Customer (
	CustomerID CHAR(5) PRIMARY KEY,
    CustomerName VARCHAR(20),
    CustomerAddress VARCHAR(50),
    CustomerPhoneNumber VARCHAR(20),
    CustomerEmailAddress VARCHAR(50),
    CONSTRAINT cekIDcust CHECK(CustomerID LIKE 'CU[0-9][0-9][0-9]')
)

CREATE TABLE Employee (
	EmployeeID CHAR(5) PRIMARY KEY,
    EmployeeName VARCHAR(20),
    EmployeeDOB DATE,
    EmployeeGender VARCHAR(10),
    EmployeeAddress VARCHAR(50),
    EmployeePhoneNumber VARCHAR(20),
    EmployeeEmailAddress VARCHAR(50),
    CONSTRAINT cekIDemp CHECK(EmployeeID LIKE 'EM[0-9][0-9][0-9]')
)

CREATE TABLE TableList (
TableNumber CHAR(3) PRIMARY KEY,
TableCapacity INT,
TableStatus VARCHAR(20)
)

CREATE TABLE RestaurantTable (
TableID CHAR(5) PRIMARY KEY,
TableNumber CHAR(3) REFERENCES TableList ON UPDATE CASCADE ON DELETE CASCADE
)


CREATE TABLE EmployeeShift (
	ShiftCode CHAR(5) PRIMARY KEY,
    StartTime TIME,
    EndTime TIME,
	CONSTRAINT cekIDshift CHECK(ShiftCode LIKE 'SC[0-9][0-9][0-9]')
)

CREATE TABLE IngredientsStock (
	IngredientsID CHAR(5) REFERENCES IngredientsList ON UPDATE CASCADE ON DELETE CASCADE,
    DetailName CHAR(20),
	IngredientsStock INT,
    IngredientsPrice NUMERIC(10,2),
    ExpiryDate DATE,
    MaxStock INT,
    MinStock INT
)

CREATE TABLE IngredientsList (
	IngredientsID CHAR(5) PRIMARY KEY,
    IngredientsName VARCHAR(20),
    CONSTRAINT cekIDing CHECK(IngredientsID LIKE 'IN[0-9][0-9][0-9]')
)

CREATE TABLE Supplier (
	SupplierID CHAR(5) PRIMARY KEY,
    SupplierCompany VARCHAR(50),
    SupplierPhoneNumber VARCHAR(20),
    CONSTRAINT cekIDsupp CHECK(SupplierID LIKE 'SU[0-9][0-9][0-9]')
)

CREATE TABLE Chef (
    EmployeeID CHAR(5) REFERENCES Employee ON UPDATE CASCADE ON DELETE CASCADE,
    Specialization VARCHAR(20)
)

CREATE TABLE Courier (
    EmployeeID CHAR(5) REFERENCES Employee ON UPDATE CASCADE ON DELETE CASCADE,
    Region VARCHAR(20)
)

CREATE TABLE Courier_Shift (
	EmployeeID CHAR(5) REFERENCES Courier ON UPDATE CASCADE ON DELETE CASCADE,
    ShiftCode CHAR(5) REFERENCES EmployeeShift ON UPDATE CASCADE ON DELETE CASCADE,
    ShiftStartDate DATE,
    ShiftEndDate DATE
)

CREATE TABLE Cashier (
    EmployeeID CHAR(5) REFERENCES Employee ON UPDATE CASCADE ON DELETE CASCADE,
    CashierPassword VARCHAR(20)
)

CREATE TABLE Cashier_Shift (
	EmployeeID CHAR(5) REFERENCES Cashier ON UPDATE CASCADE ON DELETE CASCADE,
    ShiftCode CHAR(5) REFERENCES EmployeeShift ON UPDATE CASCADE ON DELETE CASCADE,
    ShiftStartDate DATE,
    ShiftEndDate DATE
)

CREATE TABLE Manager (
    EmployeeID CHAR(5) REFERENCES Employee ON UPDATE CASCADE ON DELETE CASCADE,
    Division VARCHAR(20)
)


CREATE TABLE  (
	ProductID CHAR(5) PRIMARY KEY,
    EmployeeID CHAR(5) REFERENCES Chef ON UPDATE CASCADE ON DELETE CASCADE,
    ProductName VARCHAR(20),
    ProductPrice NUMERIC(10,2),
    CONSTRAINT cekIDpro CHECK(ProductID LIKE 'PR[0-9][0-9][0-9]')
)

CREATE TABLE Package (
	PackageID CHAR(5) PRIMARY KEY,
    EmployeeID CHAR(5) REFERENCES Chef ON UPDATE CASCADE ON DELETE CASCADE,
    PackageName VARCHAR(20),
    PackagePrice NUMERIC(10,2),
    CONSTRAINT cekIDpack CHECK(PackageID LIKE 'PP[0-9][0-9][0-9]')
)

CREATE TABLE DetailPackage (
	PackageID CHAR(5) REFERENCES Package ON UPDATE CASCADE ON DELETE CASCADE,
	ProductID CHAR(5) REFERENCES Product ON UPDATE CASCADE ON DELETE CASCADE,
    Qty INT
)


CREATE TABLE Booking (
	BookingCode CHAR(5) PRIMARY KEY,
    TableNumber CHAR(2) REFERENCES RestaurantTable ON UPDATE CASCADE ON DELETE CASCADE,
    CustomerID CHAR(5) REFERENCES Customer ON UPDATE CASCADE ON DELETE CASCADE,
    BookingDate DATE,
    BookingTime TIME,
    NumberOfCust INT,
    CONSTRAINT cekIDbook CHECK(BookingCode LIKE 'BO[0-9][0-9][0-9]')
)

CREATE TABLE Recipe (
	ProductID CHAR(5) REFERENCES Product ON UPDATE CASCADE ON DELETE CASCADE,
    IngredientsID CHAR(5) REFERENCES Ingredients ON UPDATE CASCADE ON DELETE CASCADE,
    IngredientsAmount INT
)

CREATE TABLE HeaderPurchase (
	PurchaseID CHAR(5) PRIMARY KEY,
    SupplierID CHAR(5) REFERENCES Supplier ON UPDATE CASCADE ON DELETE CASCADE,
    ManagerID CHAR(5) REFERENCES Manager ON UPDATE CASCADE ON DELETE CASCADE,
    PurchaseDate DATE,
    TotalCost NUMERIC (10,2),
    CONSTRAINT cekIDpurchase CHECK(PurchaseID LIKE 'PC[0-9][0-9][0-9]')
)

CREATE TABLE DetailPurchase (
	PurchaseID CHAR(5) REFERENCES HeaderPurchase ON UPDATE CASCADE ON DELETE CASCADE,
    IngredientsID CHAR(5) REFERENCES Ingredients ON UPDATE CASCADE ON DELETE CASCADE,
    Qty INT
)

CREATE TABLE HeaderTransaction (
	TransactionID CHAR(10) PRIMARY KEY,
    CustomerID CHAR(5) REFERENCES Customer ON UPDATE CASCADE ON DELETE CASCADE,
    EmployeeID CHAR(5) REFERENCES Cashier ON UPDATE CASCADE ON DELETE CASCADE,
    DeliveryID CHAR(5) REFERENCES Delivery ON UPDATE CASCADE ON DELETE CASCADE,
    TotalBill NUMERIC (10,2),
    TransactionDate DATE,
    TransactionTime TIME,
    PaymentMethod VARCHAR(10),
    OrderType VARCHAR(10),
    CONSTRAINT cekIDTrans CHECK(TransactionID LIKE 'TR[0-9][0-9][0-9]')
)


CREATE TABLE DetailTransaction (
	TransactionID CHAR(5) REFERENCES HeaderTransaction ON UPDATE CASCADE ON DELETE CASCADE,
    ProductID CHAR(5) REFERENCES Product ON UPDATE CASCADE ON DELETE CASCADE,
    Qty INT
)

CREATE TABLE DetailTable (
	TransactionID CHAR(5) REFERENCES HeaderTransaction ON UPDATE CASCADE ON DELETE CASCADE,
    TableID CHAR(5) REFERENCES RestaurantTable ON UPDATE CASCADE ON DELETE CASCADE
)

CREATE TABLE Booking_Table (
	BookingCode CHAR(5) REFERENCES Booking ON UPDATE CASCADE ON DELETE CASCADE,
    TableID CHAR(5) REFERENCES RestaurantTable ON UPDATE CASCADE ON DELETE CASCADE
)

CREATE TABLE Delivery (
	DeliveryID CHAR(5) PRIMARY KEY,
    EmployeeID CHAR(5) REFERENCES Courier ON UPDATE CASCADE ON DELETE CASCADE,
    Distance INT,
    DeliveryFeePerKm NUMERIC(10,2),
    TotalDeliveryFee NUMERIC(10,2),
    CONSTRAINT cekIDDeliv CHECK(DeliveryID LIKE 'DV[0-9][0-9][0-9]')
)
