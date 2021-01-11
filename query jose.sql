/************************************************************************************ 
	JOSEPHINE 00000022653 
    Prosedur untuk meningkatkan produktivitas retoran :
    1. Membuat menu makanan Buy 1 Get 1 dari membeli makanan dengan untung terbesar 
	   akan mendapat menu yang paling banyak terbeli dalam setahun 
       promo pada hari yang paling sepi per tahun
    2. Menjadikan pegawai tanpa shift (masuk full) di hari yang rame dalam setahun
    3. Semua itu berlaku untuk tahun berikutnya
    
*************************************************************************************/

delimiter //
CREATE DEFINER=`root`@`localhost` PROCEDURE `produktif`(	
	IN oYear int(4) , IN oDate date
    )
BEGIN
	DECLARE done INT DEFAULT FALSE;
	DECLARE temp TEXT;
    DECLARE do_fetch INT DEFAULT FALSE;
    DECLARE temp_c INT DEFAULT 0;
	DECLARE specialty CONDITION FOR SQLSTATE '45000';
 	
    # Menu Untung TerBesar
    DECLARE untungBesar CURSOR FOR 
	SELECT DISTINCT CASE 
			WHEN DAYNAME(oDate) = MIN(DAYNAME(HeaderTransaction.TransactionDate)) 
            THEN CONCAT(SPACE(7), product.ProductName,  SPACE(27-char_length(product.ProductName) ), 'Rp ',
            product.ProductPrice - SUM(IngredientsStock.IngredientsPrice * recipe.IngredientsAmount))
            ELSE 'N/A'
            END AS Ket 
             
	FROM Restaurant_terserah.recipe, 
		 Restaurant_terserah.IngredientsStock, 
		 Restaurant_terserah.product,
         Restaurant_terserah.HeaderTransaction
	WHERE 
		  IngredientsStock.IngredientsID=recipe.IngredientsID &&
		  recipe.ProductID=product.ProductID && 
		  product.ProductID between 'PR002' and 'PR027' 
          && HeaderTransaction.TransactionDate=oDate 
         
	GROUP BY product.ProductID
	ORDER BY product.ProductPrice - SUM(IngredientsStock.IngredientsPrice * recipe.IngredientsAmount) 
	DESC LIMIT 1;
        
	#Menu Terbanyak 
	DECLARE terbanyak CURSOR FOR 
	SELECT DISTINCT CASE 
			WHEN DAYNAME(oDate) = MIN(DAYNAME(HeaderTransaction.TransactionDate)) 
            THEN CONCAT(SPACE(10), product.ProductName,  SPACE(24-char_length(product.ProductName) ), 
            'Rp ', SUM(IngredientsStock.IngredientsPrice * recipe.IngredientsAmount) )
            ELSE 'N/A'
            END AS Ket 
             
	FROM Restaurant_terserah.recipe, 
		 Restaurant_terserah.IngredientsStock, 
		 Restaurant_terserah.product,
         Restaurant_terserah.HeaderTransaction
	WHERE 
		  IngredientsStock.IngredientsID=recipe.IngredientsID &&
		  recipe.ProductID=product.ProductID && 
		  product.ProductID between 'PR002' and 'PR027' 
          && HeaderTransaction.TransactionDate=oDate
         
	GROUP BY product.ProductID
	ORDER BY count(HeaderTransaction.TransactionDate)
	DESC LIMIT 1;
		
		
	# Cek Hari Paling Sepi Dalam Setahun
    DECLARE cekHariSepi CURSOR FOR 
	SELECT 
	CONCAT( SPACE(14), DAYNAME(oDate) , SPACE(20-char_length(DAYNAME(oDate))) ,  
			MIN(DAYNAME(HeaderTransaction.TransactionDate))) 
	FROM  Restaurant_terserah.HeaderTransaction
	WHERE year(HeaderTransaction.TransactionDate)= oYear
    GROUP BY DAYNAME(HeaderTransaction.TransactionDate) 
    ORDER BY  COUNT(DAYNAME(HeaderTransaction.TransactionDate));
    
    # Cek Hari Paling Rame Setahun
    DECLARE cekHariRame CURSOR FOR 
	SELECT 
	CONCAT( SPACE(12), CAST(DATE_FORMAT(oDate,'%d-%m-%Y') AS CHAR(10)) , 
			SPACE(18-char_length(DAYNAME(oDate))) ,  
			MAX(DAYNAME(HeaderTransaction.TransactionDate))) 
	FROM  Restaurant_terserah.HeaderTransaction
	WHERE year(HeaderTransaction.TransactionDate)= oYear
    GROUP BY DAYNAME(HeaderTransaction.TransactionDate) 
    ORDER BY  COUNT(DAYNAME(HeaderTransaction.TransactionDate)) desc;
    
	#No Shift 
    DECLARE noShift CURSOR FOR
	SELECT CASE 
			WHEN DAYNAME(oDate) = MAX(DAYNAME(HeaderTransaction.TransactionDate)) 
			THEN CONCAT(SPACE(13), min(EmployeeShift.StartTime),' - ', 
				 max(EmployeeShift.EndTime), ' (Tanpa Shift)')
			ELSE CONCAT(SPACE(13),'Normal Shift (Sesuai Jadwal)') END AS nos
		
	FROM Restaurant_terserah.HeaderTransaction,
		 Restaurant_terserah.EmployeeShift
		 
    WHERE Year(HeaderTransaction.TransactionDate)=oYear
	GROUP BY  DAYNAME(HeaderTransaction.TransactionDate) 
    ORDER BY  COUNT(DAYNAME(HeaderTransaction.TransactionDate)) desc;
    
  
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
 #Temporary Table 
 CREATE TEMPORARY TABLE print(print_i TEXT);
 INSERT INTO print SELECT CONCAT(SPACE(13),'PENINGKATAN PRODUKTIVITAS KERJA');
 INSERT INTO print SELECT CONCAT(SPACE(18),'RESTORAN ENAK BANGET');
 INSERT INTO print SELECT CONCAT(SPACE(13), 'Oleh : Josephine', SPACE(3),'000000022653');
 INSERT INTO print SELECT ''  ;

	#Cek Hari 
    # 1. Hari yang diinput & Hari Promo
	INSERT INTO print SELECT CONCAT(SPACE(8),'--- Cek Hari Untuk Promo dan No Shift ---');
	INSERT INTO print     
	SELECT CONCAT(SPACE(13),'HARI INI', SPACE(20-CHAR_LENGTH('HARI INI')), 'HARI PROMO');
		OPEN cekHariSepi;
		FETCH cekHariSepi INTO temp; 
		INSERT INTO print SELECT temp;
		CLOSE cekHariSepi; 
    
	#2. Tanggal Input & Hari Tanpa Shift
	INSERT INTO print 
	SELECT CONCAT(SPACE(13),'TANGGAL', SPACE(18-CHAR_LENGTH('HARI INI')),'HARI TANPA SHIFT');
		OPEN cekHariRame;
		FETCH cekHariRame INTO temp; 
		INSERT INTO print SELECT temp;
		CLOSE cekHariRame; 
	INSERT INTO print SELECT ''  ;

	#Buy							  							      
	INSERT INTO print #								Tahun Depan
    SELECT CONCAT(SPACE(12),'--- Promo Buy 1 Get 1 ', oYear+1, ' ---', SPACE(10));
		OPEN untungBesar;
		FETCH untungBesar INTO temp;
		INSERT INTO print SELECT CONCAT(SPACE(12),'BELI MENU', 
				SPACE(22-CHAR_LENGTH('BELI MENU')), 'KEUNTUNGAN');
		INSERT INTO print SELECT temp;
		CLOSE untungBesar;
  
	#Get
		OPEN terbanyak;
		FETCH terbanyak INTO temp;
		INSERT INTO print SELECT CONCAT(SPACE(12),'DAPAT MENU', 
				SPACE(22-CHAR_LENGTH('DAPAT MENU')), 'HARGA MODAL' );
		INSERT INTO print SELECT temp;
		CLOSE terbanyak;
	INSERT INTO print SELECT ''  ;
  
	#No Shift																	Tahun Depan
	INSERT INTO print SELECT CONCAT(SPACE(7),'--- Jadwal Ganti Shift Pegawai ', oYear+1 ,' ---', SPACE(10));
	INSERT INTO print 
	SELECT CONCAT(SPACE(18), 'KETERANGAN HARI INI', SPACE(10)) ;
		OPEN noShift;
		FETCH noShift INTO temp; 
	INSERT INTO print SELECT temp;
	CLOSE noShift; 
	INSERT INTO print SELECT ''  ;
    
    INSERT INTO print SELECT ''  ;
    INSERT INTO print SELECT CONCAT(SPACE(7),'--- Sekian Laporan Saya, Terima Kasih  ---', SPACE(10));
    INSERT INTO print SELECT ''  ;
 
 SELECT print_i AS `produktif` FROM print; 
 DROP TEMPORARY TABLE print;
 
END
delimiter ;

/******************************************************/
call restaurant_terserah.produktif(2016, '2015-10-30');
call restaurant_terserah.produktif(2015, '2016-07-01');
