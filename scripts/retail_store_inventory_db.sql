-- MEMBUAT DATABASE
CREATE DATABASE retail_store_inventory_db;
USE retail_store_inventory_db;


-- MEMBUAT TABEL
CREATE TABLE tbl_inventory (
    Date DATE NOT NULL,
    StoreID VARCHAR(50) NOT NULL,
    ProductID VARCHAR(50) NOT NULL,
    Category VARCHAR(100) NOT NULL,
    Region VARCHAR(50) NOT NULL,
    InventoryLevel INT NOT NULL,
    UnitsSold INT NOT NULL,
    UnitsOrdered INT NOT NULL,
    DemandForecast DECIMAL(10, 2) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Discount DECIMAL(5, 2) NOT NULL,
    WeatherCondition VARCHAR(50) NOT NULL,
    HolidayPromotion INT NOT NULL,
    CompetitorPricing DECIMAL(10, 2) NOT NULL,
    Seasonality VARCHAR(50) NOT NULL
);


-- MENG UPLOAD DATA MENTAH MENGGUNAKAN CARA LOCAL INFILE
SHOW VARIABLES LIKE "local_infile";

SET GLOBAL local_infile=1;

LOAD DATA LOCAL INFILE 'C:/Users/agust/OneDrive/Documents/Retail Store Inventory Analysis/Raw Data/retail_store_inventory.csv' 
INTO TABLE tbl_inventory
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES             
(
    @v_date,               
    StoreID,
    ProductID,
    Category,
    Region,
    InventoryLevel,
    UnitsSold,
    UnitsOrdered,
    DemandForecast,
    Price,
    Discount,
    WeatherCondition,
    HolidayPromotion,
    CompetitorPricing,
    Seasonality
)
SET Date = STR_TO_DATE(@v_date, '%Y-%m-%d'); 


SELECT * FROM tbl_inventory LIMIT 10;


-- MENGECEK DATA TIAP KOLOM APAKAH ADA YANG NULL / KOSONG
SELECT COUNT(*) FROM tbl_inventory 
WHERE Date IS NULL 
   OR StoreID IS NULL 
   OR ProductID IS NULL
   OR Category IS NULL
   OR Region IS NULL
   OR InventoryLevel IS NULL
   OR UnitsSold IS NULL
   OR UnitsOrdered IS NULL
   OR DemandForecast IS NULL
   OR Price IS NULL
   OR Discount IS NULL
   OR WeatherCondition IS NULL
   OR HolidayPromotion IS NULL
   OR CompetitorPricing IS NULL
   OR Seasonality IS NULL;
  
 
-- MENGECEK DUPLIKASI DATA PADA KOLOM KUNCI DATE, STOREID, PRODUCTID
SELECT Date, StoreID, ProductID, COUNT(*) 
FROM tbl_inventory
GROUP BY Date, StoreID, ProductID
HAVING COUNT(*) > 1;


-- MENGECEK NILAI PADA KOLOM UNITSSOLD, INVENTORYLEVEL, PRICE, APAKAH ADA YANG KURANG DARI 0
SELECT * FROM tbl_inventory 
WHERE UnitsSold < 0 
   OR InventoryLevel < 0 
   OR Price < 0;

-- MENGECEK KONSISTENSI PENULISAN PADA KOLOM CATEGORY DAN REGION
SELECT DISTINCT Category FROM tbl_inventory;
SELECT DISTINCT Region FROM tbl_inventory;

-- MENGECEK RENTANG TANGGAL UNTUK FORECASTING KARENA MEMBUTUHKAN URUTAN WAKTU YANG KONSISTEN DAN MEMASTIKAN TIDAK ADA LONJAKAN TAHUN YANG ANEH
SELECT MIN(Date) AS Tanggal_Awal, MAX(Date) AS Tanggal_Akhir FROM tbl_inventory;

-- MENAMBAHKAN KOLOM UNTUK MENAMPUNG HASIL UNTISSOLD*PRICE UNTUK TOTALPRICE (TOTAL REVENUE) 
ALTER TABLE tbl_inventory 
ADD COLUMN TotalPrice DECIMAL(10,2);

-- MEMATIKAN MODE AMAN SEMENTARA UNTUK MENJALANKAN PERKALIAN UNITSSOLD*PRICE DAN DI MASUKKAN KE DALAM KOLOM TOTALPRICE
SET SQL_SAFE_UPDATES = 0;

-- UPDATE DATA UNTUK TOTALPRICE
UPDATE tbl_inventory 
SET TotalPrice = UnitsSold * Price;

-- MENYALAKAN KEMBALI KE MODE AMAN
SET SQL_SAFE_UPDATES = 1;

