delimiter //
CREATE DEFINER=`root`@`localhost` PROCEDURE `produktif`(	
	IN oYear int(4) , IN oDate date
    )
BEGIN
	DECLARE done INT DEFAULT FALSE;
	DECLARE temp TEXT;
    DECLARE do_fetch INT DEFAULT FALSE;
    DECLARE temp_c INT DEFAULT 0;
 	
    # Menu Buy 1 Get 1
    DECLARE untungBesar CURSOR FOR 
	SELECT DISTINCT
	CONCAT( 
		(select CASE 
			WHEN DAYNAME(oDate) = MIN(DAYNAME(HeaderTransaction.TransactionDate)) 
            THEN (select DISTINCT product.ProductName)
            ELSE 'N/A' 
            END AS Ket) ,  SPACE(30-char_length(product.ProductName) ), 'Rp ',
            product.ProductPrice - SUM(IngredientsStock.IngredientsPrice * recipe.IngredientsAmount)
            
            
            /**DAYNAME(oDate) , 
            SPACE(30-char_length(MIN(DAYNAME(HeaderTransaction.TransactionDate)) )),
			MIN(DAYNAME(HeaderTransaction.TransactionDate)) **/
            ) 
	FROM Restaurant_terserah.recipe, 
		 Restaurant_terserah.IngredientsStock, 
		 Restaurant_terserah.product,
         Restaurant_terserah.HeaderTransaction
	WHERE IngredientsStock.IngredientsID=recipe.IngredientsID &&
		  recipe.ProductID=product.ProductID &&
		  product.ProductID between 'PR002' and 'PR027' 
          && HeaderTransaction.TransactionDate=oDate
          && year(HeaderTransaction.TransactionDate)= oYear #hapus
	GROUP BY product.ProductID
	ORDER BY product.ProductPrice - SUM(IngredientsStock.IngredientsPrice * recipe.IngredientsAmount) 
	DESC LIMIT 1;
        
      # Cek Hari
    DECLARE cekHari CURSOR FOR 
	SELECT 
	CONCAT( DAYNAME(oDate) , SPACE(20-char_length(DAYNAME(oDate))) ,  
			MIN(DAYNAME(HeaderTransaction.TransactionDate)),
            SPACE(20-char_length(MIN(DAYNAME(HeaderTransaction.TransactionDate)))), 
            MAX(DAYNAME(HeaderTransaction.TransactionDate))) 
	FROM 
         Restaurant_terserah.HeaderTransaction
	WHERE #TransactionDate=oDate && 
          year(TransactionDate)= oYear;
        
 #No Shift 
    DECLARE noShift CURSOR FOR
	SELECT CASE 
			WHEN DAYNAME(oDate) = MAX(DAYNAME(HeaderTransaction.TransactionDate)) 
		THEN CONCAT(min(EmployeeShift.StartTime),' - ', max(EmployeeShift.EndTime), '  (Tanpa Shift)')
		ELSE 'Normal Shift (Sesuai Jadwal)' END AS nos
			
	FROM Restaurant_terserah.HeaderTransaction,
		Restaurant_terserah.EmployeeShift
		 
    WHERE #TransactionDate=oDate && 
    Year(TransactionDate)=oYear;
    
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
 #Temporary Table 
 CREATE TEMPORARY TABLE print(print_i TEXT);
 INSERT INTO print SELECT CONCAT(SPACE(5),'PENINGKATAN PRODUKTIVITAS KERJA RESTORAN ENAK BANGET', SPACE(10));

  #Cek Hari
  INSERT INTO print SELECT CONCAT(SPACE(10),'--- Cek Hari Untuk Promo dan No Shift ---', SPACE(10));
  INSERT INTO print 
	SELECT CONCAT('HARI INI', SPACE(20-CHAR_LENGTH('HARI INI')), 
    'HARI PROMO', SPACE(20-CHAR_LENGTH('HARI PROMO')), 'HARI TANPA SHIFT');
  OPEN cekHari;
  FETCH cekHari INTO temp; 
  INSERT INTO print SELECT temp;
	CLOSE cekHari; 
	INSERT INTO print SELECT ''  ;

 #B1G1
 INSERT INTO print SELECT CONCAT(SPACE(10),'--- Promo Buy 1 Get 1---', SPACE(10));
  OPEN untungBesar;
  FETCH untungBesar INTO temp;
  INSERT INTO print SELECT
		CONCAT('MENU HARI INI'
        , SPACE(30-CHAR_LENGTH('MENU HARI INI')), 'KEUNTUNGAN' # SPACE(30-CHAR_LENGTH('HARI PROMO')), 'HARI PROMO'
        );
  INSERT INTO print SELECT temp;
/**  IF !do_fetch && temp_c<2 THEN
        getUntung: LOOP
			FETCH untungBesar INTO temp;
			IF do_fetch && temp_c=2 THEN
					LEAVE getUntung;
				ELSE
					SET temp_c=temp_c+1;
                    INSERT INTO print SELECT temp;
			END IF;
		END LOOP;
	END IF;
  SET do_fetch = FALSE;
  SET temp_c = 0;  **/
  CLOSE untungBesar;
  INSERT INTO print SELECT ''  ;
  

 #No Shift
  INSERT INTO print SELECT CONCAT(SPACE(5),'--- Jadwal Ganti Shift Pegawai ---', SPACE(10));
  INSERT INTO print 
	SELECT CONCAT( 'KETERANGAN HARI INI', SPACE(10)) ;
 OPEN noShift;
  FETCH noShift INTO temp; 
  INSERT INTO print SELECT temp;
	CLOSE noShift; 
INSERT INTO print SELECT ''  ;
 
 SELECT print_i AS `produktif` FROM print; 
 DROP TEMPORARY TABLE print;

END
delimiter ;