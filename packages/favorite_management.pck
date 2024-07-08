create or replace package favorite_management is


    PROCEDURE add_favorite(
        p_userID IN user_definition.userID%type,
        p_productID IN product.productID%type
    );

    PROCEDURE remove_favorite(
        p_userID IN NUMBER,
        p_productID IN NUMBER
    );
    

end favorite_management;
/
create or replace package body favorite_management is


     
    --Hata kodlarý
    c_user_not_loggin CONSTANT NUMBER := -20016;
    c_product_not_active CONSTANT NUMBER := -20017;
    c_product_in_favorites CONSTANT NUMBER := -20018;
    c_user_not_exists CONSTANT NUMBER := -20028;
    c_product_not_in_favorites CONSTANT NUMBER := -20029;
    

    
    --Hata mesajlarý
    c_user_not_loggin_msg CONSTANT VARCHAR2(400) := 'Kullanýcý çevrimiçi deðil. Lütfen giriþ yapýn.';
    c_product_not_active_msg CONSTANT VARCHAR2(400) := 'Bu ürün aktif deðil.';
    c_product_in_favorites_msg CONSTANT VARCHAR2(400) := 'Bu ürün zaten favorilerinizde.';
    c_user_not_exists_msg CONSTANT VARCHAR2(400) := 'Kullanýcý bulunamadý.';
    c_product_not_in_favorites_msg CONSTANT VARCHAR2(400) := 'Favorilerinizden çýkartýlacak böyle bir ürün bulunamadý.';
    
    

    --ürünün favorilere eklenmesi
    PROCEDURE add_favorite(
          p_userID IN user_definition.userID%type,
          p_productID IN product.productID%type
      ) is
          v_product_exists NUMBER;
      BEGIN
          
          --Ürün var mý ve aktif mi kontrolü
          product_management.check_entity_exists_and_active('PRODUCT', p_productID, c_product_not_active, c_product_not_active_msg);        


          --kullanýcý var mý
          if user_management.check_user_exists(p_userID) = 0 then
            RAISE_APPLICATION_ERROR(c_user_not_exists, c_user_not_exists_msg);            
          end if;
          

          --kullanýcý login mi kontrolü
          if user_management.check_user_logged_in(p_userID) = 0 then             
            RAISE_APPLICATION_ERROR(c_user_not_loggin, c_user_not_loggin_msg);                
          end if;
          
          --Ürün zaten favorilerde mi kontrolü
          SELECT COUNT(*)
          INTO v_product_exists
          FROM favorite
          WHERE userID = p_userID
          AND productID = p_productID;

          IF v_product_exists > 0 THEN
              RAISE_APPLICATION_ERROR(c_product_in_favorites, c_product_in_favorites_msg);
          END IF;


          --ürünün favorilere eklenmesi
          INSERT INTO favorite (userID, productID)
          VALUES (p_userID, p_productID);
          
          dbms_output.put_line('Ürün favorilerinize eklendi.');
          commit;
          
     exception when others then
        handle_error(sqlcode, sqlerrm);
        
     END add_favorite;



      -- Favori kaldýrma prosedürü 
      PROCEDURE remove_favorite(                
          p_userID IN NUMBER,
          p_productID IN NUMBER
      ) is
          v_product_exists NUMBER;
      BEGIN
          
          --kullanýcý var mý
          if user_management.check_user_exists(p_userID) = 0 then
            RAISE_APPLICATION_ERROR(c_user_not_exists, c_user_not_exists_msg);            
          end if;
          
      
          --kullanýcý login mi kontrolü
          if user_management.check_user_logged_in(p_userID) = 0 then             
            RAISE_APPLICATION_ERROR(c_user_not_loggin, c_user_not_loggin_msg);                
          end if;
          
          --Ürün favorilerde mi kontrolü
          SELECT COUNT(*)
          INTO v_product_exists
          FROM favorite
          WHERE userID = p_userID
          AND productID = p_productID;

          IF v_product_exists = 0 THEN
              RAISE_APPLICATION_ERROR(c_product_not_in_favorites, c_product_not_in_favorites_msg);
          END IF;


          -- Favoriyi kaldýrma
          DELETE FROM favorite
          WHERE userID = p_userID
          AND productID = p_productID;
          
          dbms_output.put_line('Ürün favorilerilerinizden kaldýrýldý.');
          commit;
      exception when others then
        handle_error(sqlcode, sqlerrm);
          
      END remove_favorite;


end favorite_management;
/
