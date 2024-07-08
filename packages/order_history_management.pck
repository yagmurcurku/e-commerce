create or replace package order_history_management is

  procedure viewOrderHistory(p_UserID in number);

  procedure viewOrderDetails(p_PurchaseID in number);

  procedure exportPurchasesToCSV(p_FileName in varchar2);

  procedure exportUserPurchasesToCSV(p_userID in number);

end order_history_management;
/
create or replace package body order_history_management is

  --Hata kodlarý
  c_user_not_exists constant number := -20028;

  --Hata mesajlarý
  c_user_not_exists_msg constant VARCHAR2(400) := 'Sisteme kayitli bir kullanici bulunamadi.';


  --KULLANICININ TÜM SÝPARÝÞ GEÇMÝÞÝNÝN LÝSTELENMESÝ.
  procedure viewOrderHistory(p_UserID in number) is
    cursor c_purchase_cursor is
      select purchaseID, purchaseDate, totalPrice
        from purchase
       where userID = p_UserID
       order by purchaseDate DESC;
    v_purchaseID   purchase.purchaseID%TYPE;
    v_purchaseDate purchase.purchaseDate%TYPE;
    v_totalPrice   purchase.totalPrice%TYPE;
    v_username     user_definition.username%type;
  begin
  
    --kullanýcý kontrolü saðlanýyor ve username alýnýyor.
    if user_management.check_user_exists(p_userID) = 0 then
      RAISE_APPLICATION_ERROR(c_user_not_exists, c_user_not_exists_msg);
    else
      select username
        into v_username
        from user_definition
       where userID = p_userID;
    end if;
  
    dbms_output.new_line;
    dbms_output.put_line('° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° °');
    dbms_output.put_line(v_username || ' kullanicisinin siparis gecmisi:');
    dbms_output.new_line;
    dbms_output.put_line('° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° °');
    --kullanýcý daha önce sipariþ oluþturmamýþsa sipariþ geçmiþi boþ gelir. Sepet mantýðý.
  
    open c_purchase_cursor;
    loop
      fetch c_purchase_cursor
        into v_purchaseID, v_purchaseDate, v_totalPrice;
      exit when c_purchase_cursor%NOTFOUND;
    
      dbms_output.put_line('Siparis ID: ' || v_purchaseID);
      dbms_output.put_line('Siparis Tarihi: ' || v_purchaseDate);
      dbms_output.put_line('Toplam: ' || v_totalPrice || 'TL');
      dbms_output.put_line('-----------------------------------');
    end loop;
    close c_purchase_cursor;
  exception
    when others then
      handle_error(sqlcode, sqlerrm);
    
  end viewOrderHistory;



  --KULLANICININ BELÝRLÝ BÝR SÝPARÝÞÝNÝN DETAYLARININ LÝSTELENMESÝ
  procedure viewOrderDetails(p_PurchaseID in number) is
    v_purchaseDate date;
    v_totalPrice   number;
    cursor c_order_details_cursor is
      select pd.productID, p.productName, pd.quantity, p.price
        from purchase_detail pd
        join product p
          on pd.productID = p.productID
       where pd.purchaseID = p_PurchaseID;
    v_productID   purchase_detail.productID%TYPE;
    v_productName product.productName%TYPE;
    v_quantity    purchase_detail.quantity%TYPE;
    v_price       product.price%TYPE;
  begin
  
    dbms_output.new_line;
    dbms_output.put_line('° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° °');
    select purchaseDate, totalPrice
      into v_purchaseDate, v_totalPrice
      from purchase p
     where purchaseID = p_PurchaseID;
    dbms_output.put_line('Siparis Tarihi: ' || v_purchaseDate);
    dbms_output.put_line('Toplam: ' || v_totalPrice || 'TL');
    dbms_output.new_line;
    dbms_output.put_line('° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° °');
  
    open c_order_details_cursor;
    loop
      fetch c_order_details_cursor
        into v_productID, v_productName, v_quantity, v_price;
      exit when c_order_details_cursor%NOTFOUND;
    
      dbms_output.put_line(v_productName || ' X ' || v_quantity || ' adet');
      dbms_output.put_line('Birim fiyat: ' || v_price);
      dbms_output.put_line('Toplam: ' || (v_quantity * v_price || 'TL'));
      dbms_output.put_line('-----------------------------------');
    end loop;
    close c_order_details_cursor;
  exception
    when others then
      handle_error(sqlcode, sqlerrm);   
  end viewOrderDetails;



  --SÝSTEMDE KAYITLI OLAN TÜM SATIÞLARIN LÝSTESÝNÝN CSV OLARAK ALINMASI(bütün kullanýcýlar için)
  procedure exportPurchasesToCSV(p_filename in varchar2) is
    l_output UTL_FILE.FILE_TYPE;
    l_line   varchar2(32767);
    cursor c_purchase_cursor IS
      select purchaseID, userID, purchaseDate, totalPrice from purchase;
    v_purchaseID   purchase.purchaseID%TYPE;
    v_userID       purchase.userID%TYPE;
    v_purchaseDate purchase.purchaseDate%TYPE;
    v_totalPrice   purchase.totalPrice%TYPE;
  begin
    --Dosyanýn açýlmasý/Dosyanýn belirtilen dizinde belirtilen isimde oluþturulmasý ve yazma yetkisi verilmesi.
    l_output := UTL_FILE.FOPEN('CSV_FILES_DIR2', p_filename, 'w');
  

    dbms_output.put_line('Dosya acildi: ' || p_filename);
  
    --CSV baþlýk satýrýnýn yazýlmasý
    l_line := 'PurchaseID, UserID, PurchaseDate, TotalPrice';
    UTL_FILE.PUT_LINE(l_output, l_line);
  
    --Dosya içeriðinin(satýrlarýn) yazýlmasý
    open c_purchase_cursor;
    loop
      fetch c_purchase_cursor
        into v_purchaseID, v_userID, v_purchaseDate, v_totalPrice;
      exit when c_purchase_cursor%NOTFOUND;
      l_line := v_purchaseID || ',' || v_userID || ',' ||
                TO_CHAR(v_purchaseDate, 'YYYY-MM-DD HH24:MI:SS') || ',' ||
                v_totalPrice;
      UTL_FILE.PUT_LINE(l_output, l_line);
    end loop;
    close c_purchase_cursor;
  
    --Dosyanýn kapatýlmasý.
    UTL_FILE.FCLOSE(l_output);
  
    dbms_output.put_line('Dosya basariyla olusturuldu: ' || p_filename);
  exception
    when others then
      --Hata alýnmasý durumunda dosyanýn kapatýlmasýný saðlýyoruz.
      if UTL_FILE.IS_OPEN(l_output) then
        UTL_FILE.FCLOSE(l_output);
      end if;
      handle_error(sqlcode, sqlerrm);
  end exportPurchasesToCSV;



  --USER BAZINDAKÝ SATIÞLARIN LÝSTESÝNÝN CSV OLARAK ALINMASI
  procedure exportUserPurchasesToCSV(p_userID in number) is
    l_output UTL_FILE.FILE_TYPE;
    l_line   varchar2(32767);
    cursor c_purchase_cursor is
      select purchaseID, userID, purchaseDate, totalPrice
        from purchase
       where userID = p_userID;
    v_userfilename varchar2(100);
    v_purchaseID   purchase.purchaseID%TYPE;
    v_userID       purchase.userID%TYPE;
    v_purchaseDate purchase.purchaseDate%TYPE;
    v_totalPrice   purchase.totalPrice%TYPE;
  begin
    --Dosya adýný userID ile özelleþtiriyoruz.
    v_userfilename := 'user_' || p_userID || '_purchases.csv';
  
    --Dosyanýn açýlmasý/Dosyanýn belirtilen dizinde belirtilen isimde oluþturulmasý ve yazma yetkisi verilmesi.
    l_output := UTL_FILE.FOPEN('CSV_FILES_DIR2', v_userfilename, 'w');
  
  
    dbms_output.put_line('Dosya acildi: ' || v_userfilename);
  
    --CSV baþlýk satýrýnýn yazýlmasý
    l_line := 'PurchaseID, UserID, PurchaseDate, TotalPrice';
    UTL_FILE.PUT_LINE(l_output, l_line);
  
    --Dosya içeriðinin(satýrlarýn) yazýlmasý
    open c_purchase_cursor;
    loop
      fetch c_purchase_cursor
        into v_purchaseID, v_userID, v_purchaseDate, v_totalPrice;
      exit when c_purchase_cursor%NOTFOUND;
      l_line := v_purchaseID || ',' || v_userID || ',' ||
                TO_CHAR(v_purchaseDate, 'YYYY-MM-DD HH24:MI:SS') || ',' ||
                v_totalPrice;
      UTL_FILE.PUT_LINE(l_output, l_line);
    end loop;
    close c_purchase_cursor;
  
    --Dosyanýn kapatýlmasý
    UTL_FILE.FCLOSE(l_output);
  
    dbms_output.put_line('Dosya basariyla olusturuldu: ' || v_userfilename);
  exception
    when others then
      -- Hata durumunda dosyayý kapat
      if UTL_FILE.IS_OPEN(l_output) then
        UTL_FILE.FCLOSE(l_output);
      end if;
    
      handle_error(sqlcode, sqlerrm);
  end exportUserPurchasesToCSV;

end order_history_management;
/
