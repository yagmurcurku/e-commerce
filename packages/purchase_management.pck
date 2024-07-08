create or replace package purchase_management is

 
    PROCEDURE process_purchase (
        p_UserID IN NUMBER
    );


end purchase_management;
/
create or replace package body purchase_management is

    
    --Hata kodlarý
    c_user_not_login constant number := -20025;
    c_cart_is_empty constant number := -20026;
    c_purchase_error constant number := -20027;

    
    --Hata mesajlarý
    c_user_not_login_msg constant VARCHAR2(400) := 'Satýn alma iþlemi baþarýsýz. Kullanýcý giriþ yapmamýþ.';
    c_cart_is_empty_msg constant VARCHAR2(400) := 'Satýn alýnacak ürün bulunamadý. Kullanýcýnýn sepeti boþ !';
    c_purchase_error_msg constant varchar2(400) := 'Bir sorun oluþtu ! Satýn alma iþlemi gerçekleþtirilemedi.';

   


    PROCEDURE process_purchase (
        p_UserID IN NUMBER
    ) IS
        v_TotalPrice NUMBER := 0;
        v_PurchaseID purchase.purchaseID%TYPE;
        CURSOR cart_cursor IS
            SELECT productID, quantity FROM cart WHERE userID = p_UserID;
        v_productID cart.productID%TYPE;
        v_quantity cart.quantity%TYPE;
    BEGIN
      
        --Kullanýcýnýn sepeti boþ mu
        if cart_management.is_cart_empty(p_userID) = 1 then
           raise_application_error(c_cart_is_empty, c_cart_is_empty_msg);
        end if;
        
        
        --kullanýcý login kontrolü
        if user_management.check_user_logged_in(p_userID) = 0 then
          raise_application_error(c_user_not_login, c_user_not_login_msg);
        end if;
        

       --Kullanýcýnýn sepetindeki ürünlerin toplam fiyatýný hesapla   
        v_totalPrice := cart_management.calculate_total_price(p_UserID);


        --Satýn alma iþlemi için Transaction baþlatýlýr.
        BEGIN
            --Satýn alma iþleminin kaydedilmesi.
            INSERT INTO purchase (userID, totalPrice, purchaseDate) 
            VALUES (p_UserID, v_TotalPrice, SYSDATE) 
            RETURNING purchaseID INTO v_PurchaseID;
            
            dbms_output.put_line('Satýn alma iþlemi baþarýlý.');

            -- Satýn alýnan ürünlerin detay tablosuna kaydedilmesi.
            OPEN cart_cursor;
            LOOP
                FETCH cart_cursor INTO v_productID, v_quantity;
                EXIT WHEN cart_cursor%NOTFOUND;
                INSERT INTO purchase_detail (purchaseID, productID, quantity) 
                VALUES (v_PurchaseID, v_productID, v_quantity);
            END LOOP;
            CLOSE cart_cursor;

            -- Sepetin boþaltýlmasý.
            DELETE FROM cart WHERE userID = p_UserID;

            -- Transaction bitirlir.
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                --Transaction sýrasýnda bir hata ile karþýlaþýlýrsa tüm iþlemler rollback yapýlýr.
                ROLLBACK;
                RAISE_APPLICATION_ERROR(c_purchase_error, c_purchase_error_msg);
        END;
    EXCEPTION
        when others then
           handle_error(sqlcode, sqlerrm);
    END process_purchase;
    


end purchase_management;
/
