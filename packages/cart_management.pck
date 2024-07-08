create or replace package cart_management is
  

    PROCEDURE add_to_cart (
        p_userID IN NUMBER,
        p_productID IN NUMBER,
        p_quantity IN NUMBER
    );

    PROCEDURE removeFromCart (
        p_userID IN NUMBER,
        p_productID IN NUMBER
    );

    PROCEDURE viewCart (
        p_userID IN NUMBER
    );

    FUNCTION is_Product_In_Cart (
        p_userID IN NUMBER,
        p_productID IN NUMBER
    ) RETURN NUMBER;
    
    FUNCTION is_cart_empty (
        p_userID IN NUMBER
    ) RETURN NUMBER ;
    
    FUNCTION calculate_total_price (
        p_UserID IN NUMBER
    ) RETURN NUMBER;



end cart_management;
/
create or replace package body cart_management is


    
    --Hata kodlarý
    c_user_not_exists constant number := -20019;
    c_user_not_loggin CONSTANT NUMBER := -20020;
    c_product_not_active CONSTANT NUMBER := -20021;
    c_user_not_loggin_for_remove_from_cart constant number := -20022;
    c_product_not_in_cart constant number := -20023;
    c_cart_is_empty constant number := -20024;


    
    --Hata mesajlarý
    c_user_not_exists_msg constant VARCHAR2(400) := 'Yanlýþ ID. Böyle bir kullanýcý bulunamadý.';
    c_user_not_loggin_msg CONSTANT VARCHAR2(400) := 'Kullanýcý çevrimdýþý. Sepete ürün ekleyebilmek için lütfen giriþ yapýn.';
    c_product_not_active_msg CONSTANT VARCHAR2(400) := 'Bu ürün aktif deðil. Sepete eklenemez.';
    c_user_not_loggin_for_remove_from_cart_msg constant varchar2(400) := 'Ürünü sepetten çýkartmak için kullanýcý login olmalý.'; 
    c_product_not_in_cart_msg constant VARCHAR2(400) := 'Sepetten çýkarma iþlemi baþarýsýz! Sepette böyle bir ürün yok.';
    c_cart_is_empty_msg constant VARCHAR2(400) := 'Sepetten çýkarýlacak ürün bulunamadý. Kullanýcýnýn sepeti zaten boþ !';

    

    -- Ürünün sepette olup olmadýðýný kontrol eden yardýmcý fonksiyon
    FUNCTION is_product_in_cart (
        p_userID IN NUMBER,
        p_productID IN NUMBER
    ) RETURN NUMBER IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM cart
        WHERE userID = p_userID AND productID = p_productID;

        RETURN v_count;
    exception when others then
        handle_error(sqlcode, sqlerrm);
    END is_product_in_cart;



    -- Sepetin boþ olup olmadýðýný kontrol eden fonksiyon
    FUNCTION is_cart_empty (
        p_userID IN NUMBER
    ) RETURN NUMBER IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM cart
        WHERE userID = p_userID;

        IF v_count > 0 THEN
            return 0; --Sepette ürün var
        ELSE
            return 1; --Sepet boþ
        END IF;
    exception when others then
        handle_error(sqlcode, sqlerrm);
    END is_cart_empty;
    
    
    --kullanýcýnýn Sepet toplamýný hesaplayan fonksiyon
    FUNCTION calculate_total_price (
        p_UserID IN NUMBER
    ) RETURN NUMBER IS
        v_totalPrice NUMBER := 0;
        CURSOR cart_cursor IS
            SELECT c.quantity, p.price FROM cart c JOIN product p ON c.productID = p.productID
            WHERE c.userID = p_UserID;
        v_quantity cart.quantity%TYPE;
        v_price product.price%TYPE;
    BEGIN
        FOR cart_rec IN cart_cursor LOOP
            v_quantity := cart_rec.quantity;
            v_price := cart_rec.price;
            v_totalPrice := v_totalPrice + (v_quantity * v_price);
        END LOOP;

        RETURN v_totalPrice;
    exception when others then
        handle_error(sqlcode, sqlerrm);
    END calculate_total_price;



    -- Sepete ürün ekleme prosedürü
    PROCEDURE add_to_cart (                
        p_userID IN NUMBER,
        p_productID IN NUMBER,
        p_quantity IN NUMBER
    ) is
    BEGIN
        
        --user var mý
        if user_management.check_user_exists(p_userID) = 0 then
          RAISE_APPLICATION_ERROR(c_user_not_exists, c_user_not_exists_msg);            
        end if;
        
    
        --user login mi kontrolü
        if user_management.check_user_logged_in(p_userID) = 0 then                
          RAISE_APPLICATION_ERROR(c_user_not_loggin, c_user_not_loggin_msg);            
        end if;
        
        -- Ürün veritabanýnda mevcut mu ve aktif mi
        product_management.check_entity_exists_and_active('PRODUCT', p_productID, c_product_not_active, c_product_not_active_msg);
        

        -- Ürün zaten sepette varsa miktarý arttýr
        IF is_product_in_cart(p_userID, p_productID) > 0 THEN
            UPDATE cart
            SET quantity = quantity + p_quantity
            WHERE userID = p_userID AND productID = p_productID;
        ELSE
            -- Ürün sepette yoksa sepete ekle
            INSERT INTO cart (userID, productID, quantity)
            VALUES (p_userID, p_productID, p_quantity);
        END IF;
        
        dbms_output.put_line('Ürün sepete eklendi.');
        commit;
     
    exception 
      when others then
       handle_error(sqlcode, sqlerrm);
       
    END add_to_cart;





    -- Sepetten ürün çýkarma prosedürü
    PROCEDURE removeFromCart (
        p_userID IN NUMBER,                
        p_productID IN NUMBER
    ) is
        v_quantity NUMBER;
    BEGIN
        
        --user var mý
        if user_management.check_user_exists(p_userID) = 0 then
          RAISE_APPLICATION_ERROR(c_user_not_exists, c_user_not_exists_msg);            
        end if;
        
  
        --Kullanýcýnýn sepeti boþ mu. Eðer boþsa boþuna ürün var mý diye kontrol edilmez.
        if is_cart_empty(p_userID) = 1 then
           raise_application_error(c_cart_is_empty, c_cart_is_empty_msg);
        end if;
        
        
        --user login mi kontrolü
        if user_management.check_user_logged_in(p_userID) = 0 then                
          RAISE_APPLICATION_ERROR(c_user_not_loggin_for_remove_from_cart, c_user_not_loggin_for_remove_from_cart_msg);
        end if;     

    
        -- Ürün sepette mevcut mu kontrol et
        IF is_product_in_cart(p_userID, p_productID) = 0 THEN
            RAISE_APPLICATION_ERROR(c_product_not_in_cart, c_product_not_in_cart_msg);
        END IF;


        -- Ürün miktarýný deðiþkene ata
        SELECT quantity INTO v_quantity FROM cart 
        WHERE userID = p_userID AND productID = p_productID;

        -- Ürün sepette varsa ve miktarý birden fazlaysa miktarý azalt
        IF v_quantity > 1 THEN
            UPDATE cart
            SET quantity = quantity - 1
            WHERE userID = p_userID AND productID = p_productID;            
            dbms_output.put_line('Sepetteki ürün miktarý 1 azaldý.');
            commit;
        ELSE
            -- Miktar bire eþitse ürünü sepetten çýkar
            DELETE FROM cart
            WHERE userID = p_userID AND productID = p_productID;
            dbms_output.put_line('Ürün sepetten çýkarýldý.');
            commit;
        END IF;

    exception 
      when others then
       handle_error(sqlcode, sqlerrm);
    END removeFromCart;




    -- Sepeti görüntüleme prosedürü
    PROCEDURE viewCart (               
        p_UserID IN NUMBER
    ) is    
        CURSOR c_cart_cursor IS
            SELECT p.productName, c.quantity, p.price
            FROM cart c
            JOIN product p ON c.productID = p.productID
            WHERE c.userID = p_UserID;
        v_username user_definition.username%type;
        v_productName product.productName%TYPE;
        v_quantity cart.quantity%TYPE;
        v_price product.price%TYPE;
        v_totalPrice NUMBER := 0;
        v_row c_cart_cursor%ROWTYPE;
    BEGIN
        --kullanýcý kontrolü saðlanýyor ve username alýnýyor.(bütün user'larýn sepeti var, veri gelmezse user yoktur)
        select username into v_username from user_definition where userID = p_userID;
        
        
        DBMS_OUTPUT.PUT_LINE(v_username || ' Kullanicisinin Sepetini Görüntülüyorsunuz');
        DBMS_OUTPUT.PUT_LINE('-----------------------------------');


        OPEN c_cart_cursor;
        LOOP
            FETCH c_cart_cursor INTO v_row;
            EXIT WHEN c_cart_cursor%NOTFOUND;

            v_productName := v_row.productName;
            v_quantity := v_row.quantity;
            v_price := v_row.price;

            DBMS_OUTPUT.PUT_LINE(v_productName || ' | ' || v_quantity || ' adet' || ' | Toplam Fiyat: ' || (v_quantity * v_price));
        END LOOP;
        CLOSE c_cart_cursor;

        --sepet toplamýnýn hesaplanmasý.
        v_totalPrice := calculate_total_price(p_UserID);

        DBMS_OUTPUT.PUT_LINE('-----------------------------------');
        DBMS_OUTPUT.PUT_LINE('Sepet Toplami: ' || v_totalPrice);
        
    exception 
        when no_data_found then
           handle_error(sqlcode, 'Sepeti görüntülenecek bir kullanýcý bulunamadý. Lütfen kayýtlý bir kullanýcý girin.');
        when others then
           handle_error(sqlcode, sqlerrm);
    
    END viewCart;
    
    
end Cart_Management;
/
