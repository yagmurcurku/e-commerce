--
create sequence user_definition_seq start with 1 increment by 1;          --
CREATE SEQUENCE user_status_seq START WITH 1 INCREMENT BY 1;              --
CREATE SEQUENCE product_seq START WITH 1 INCREMENT BY 1;                  --
CREATE SEQUENCE product_category_seq START WITH 1 INCREMENT BY 1;         --
CREATE SEQUENCE product_log_seq START WITH 1 INCREMENT BY 1;              --
CREATE SEQUENCE cart_seq START WITH 1 INCREMENT BY 1;                     --
CREATE SEQUENCE purchase_seq START WITH 1 INCREMENT BY 1;                 --
CREATE SEQUENCE purchase_detail_seq START WITH 1 INCREMENT BY 1;          --          
CREATE SEQUENCE favorite_seq START WITH 1 INCREMENT BY 1;                 --
CREATE SEQUENCE color_seq START WITH 1 INCREMENT BY 1;                    --
CREATE SEQUENCE brand_seq START WITH 1 INCREMENT BY 1;                    --


--drop sequence color_seq;

-- tablolara atýlan insert için id tetikleyici......................
-- user_definiton Trigger
CREATE OR REPLACE TRIGGER trg_user_definition_id_insert
BEFORE INSERT ON user_definition
FOR EACH ROW
BEGIN
    :new.userID := user_definition_seq.NEXTVAL;
END;


-- product Trigger
CREATE OR REPLACE TRIGGER trg_product_id_insert
BEFORE INSERT ON product
FOR EACH ROW
BEGIN
    :new.productID := product_seq.NEXTVAL;
END;


-- product_category Trigger
CREATE OR REPLACE TRIGGER trg_product_category_id_insert
BEFORE INSERT ON product_category
FOR EACH ROW
BEGIN
    :new.categoryID := product_category_seq.NEXTVAL;
END;


-- cart Trigger
CREATE OR REPLACE TRIGGER trg_cart_id_insert
BEFORE INSERT ON cart
FOR EACH ROW
BEGIN
    :new.cartID := cart_seq.NEXTVAL;
END;



-- purchase Trigger
CREATE OR REPLACE TRIGGER trg_purchase_id_insert
BEFORE INSERT ON purchase
FOR EACH ROW
BEGIN
    :new.purchaseID := purchase_seq.NEXTVAL;
END;


-- purchase_detail Trigger
CREATE OR REPLACE TRIGGER trg_purchase_detail_id_insert
BEFORE INSERT ON purchase_detail
FOR EACH ROW
BEGIN
    :new.purchaseDetailID := purchase_detail_seq.NEXTVAL;
END;


-- product_log Trigger
CREATE OR REPLACE TRIGGER trg_product_log_id_insert
BEFORE INSERT ON product_log 
FOR EACH ROW
BEGIN
    :new.productLogID := product_log_seq.NEXTVAL;
END;


-- favorite Trigger
CREATE OR REPLACE TRIGGER trg_favorite_id_insert
BEFORE INSERT ON favorite
FOR EACH ROW
BEGIN
    :new.favoriteID := favorite_seq.NEXTVAL;
END;


-- color Trigger
CREATE OR REPLACE TRIGGER trg_color_id_insert
BEFORE INSERT ON color
FOR EACH ROW
BEGIN
    :new.colorID := color_seq.NEXTVAL;
END;


-- brand Trigger
CREATE OR REPLACE TRIGGER trg_brand_id_insert
BEFORE INSERT ON brand
FOR EACH ROW
BEGIN
    :new.brandID := brand_seq.NEXTVAL;
END;


----------------------------
--DÝÐER TRIGGER'LAR


--user_definition tablosuna yeni bir user eklendiðinde user_status tablosunda bu user için kayýt oluþturan trigger
CREATE OR REPLACE TRIGGER trg_insert_user_status_on_user_definition_insert
AFTER INSERT ON user_definition
FOR EACH ROW
BEGIN
    -- user_status tablosuna yeni bir kayýt ekleyin ve userID deðerini belirtin
    INSERT INTO user_status (userStatusID, userID) VALUES (user_status_seq.NEXTVAL, :NEW.userID);
END;



--aþaðýdaki trigger'da kullanmak için vt düzeyinde procedure
CREATE OR REPLACE PROCEDURE log_product_change(
    p_productID IN NUMBER,
    p_column_name IN VARCHAR2,
    p_old_value IN VARCHAR2,
    p_new_value IN VARCHAR2,
    p_action IN VARCHAR2,
    p_user IN VARCHAR2
) AS
BEGIN
    INSERT INTO product_log (
        productID, categoryID, colorID, brandID, productName, 
        price, action, actionDate, actionUser
    ) VALUES (
        p_productID,
        CASE WHEN p_column_name = 'categoryID' THEN TO_NUMBER(p_old_value) END,
        CASE WHEN p_column_name = 'colorID' THEN TO_NUMBER(p_old_value) END,
        CASE WHEN p_column_name = 'brandID' THEN TO_NUMBER(p_old_value) END,
        CASE WHEN p_column_name = 'productName' THEN p_old_value END,
        CASE WHEN p_column_name = 'price' THEN TO_NUMBER(p_old_value) END,
        p_action,
        SYSDATE,
        p_user
    );

    INSERT INTO product_log (
        productID, categoryID, colorID, brandID, productName, 
        price, action, actionDate, actionUser
    ) VALUES (
        p_productID,
        CASE WHEN p_column_name = 'categoryID' THEN TO_NUMBER(p_new_value) END,
        CASE WHEN p_column_name = 'colorID' THEN TO_NUMBER(p_new_value) END,
        CASE WHEN p_column_name = 'brandID' THEN TO_NUMBER(p_new_value) END,
        CASE WHEN p_column_name = 'productName' THEN p_new_value END,
        CASE WHEN p_column_name = 'price' THEN TO_NUMBER(p_new_value) END,
        'UPDATE',
        SYSDATE,
        p_user
    );
END;
/


--product tablosuna yeni bir ürün eklendiðinde ve ürün güncellendiðinde bunun kaydýný product_log tablosuna
--atacak olan trigger.
CREATE OR REPLACE TRIGGER trg_product_insert_update_log
AFTER INSERT OR UPDATE ON product
FOR EACH ROW
DECLARE
    insert_action_name CONSTANT VARCHAR2(20) := 'INSERT';
    old_update_action_name CONSTANT VARCHAR2(20) := 'UPDATE_OLD';
BEGIN
    -- INSERT iþlemi için log ekleme
    IF INSERTING THEN
        INSERT INTO product_log (
            productID, categoryID, colorID, brandID, productName, 
            price, action, actionDate, actionUser
        ) VALUES (
            :NEW.productID,
            :NEW.categoryID,
            :NEW.colorID,
            :NEW.brandID,
            :NEW.productName,
            :NEW.price,

            insert_action_name,
            SYSDATE,
            USER
        );
    ELSIF UPDATING THEN
        -- Deðiþen kolonlar için log ekleme
        IF :OLD.categoryID != :NEW.categoryID THEN
            log_product_change(:NEW.productID, 'categoryID', TO_CHAR(:OLD.categoryID), TO_CHAR(:NEW.categoryID), old_update_action_name, USER);
        END IF;
        IF :OLD.colorID != :NEW.colorID THEN
            log_product_change(:NEW.productID, 'colorID', TO_CHAR(:OLD.colorID), TO_CHAR(:NEW.colorID), old_update_action_name, USER);
        END IF;
        IF :OLD.brandID != :NEW.brandID THEN
            log_product_change(:NEW.productID, 'brandID', TO_CHAR(:OLD.brandID), TO_CHAR(:NEW.brandID), old_update_action_name, USER);
        END IF;
        IF :OLD.productName != :NEW.productName THEN
            log_product_change(:NEW.productID, 'productName', :OLD.productName, :NEW.productName, old_update_action_name, USER);
        END IF;
        IF :OLD.price != :NEW.price THEN
            log_product_change(:NEW.productID, 'price', TO_CHAR(:OLD.price), TO_CHAR(:NEW.price), old_update_action_name, USER);
        END IF;
    END IF;
END;
/




--bir product soft delete yapýldýðýnda veya yeniden aktif duruma getirildiðinde bunun log'unu tutan trigger
CREATE OR REPLACE TRIGGER trg_product_soft_delete_and_reactivate_log
AFTER UPDATE OF isActive ON product
FOR EACH ROW
DECLARE
    action_name VARCHAR2(20);
BEGIN
    -- isActive kolonu 'N' olarak güncellenirse soft delete iþlemini logla
    IF :NEW.isActive = 'N' AND :OLD.isActive = 'Y' THEN --zaten önceden de N olabilir bunun kontrolünü ele almýþ oluyoruz
        action_name := 'SOFT_DELETE';
    ELSIF :NEW.isActive = 'Y' AND :OLD.isActive = 'N' THEN      --ayný þekilde zaten önceden de Y olabilir. önceden Y olmalý!
        action_name := 'REACTIVATE';
    ELSE
        RETURN; -- isActive kolonu 'Y' den 'Y' ye veya 'N' den 'N' ye güncellenirse herhangi bir iþlem yapma
    END IF;
    
    INSERT INTO product_log (
        productID, categoryID, colorID, brandID, productName, 
        price, action, actionDate, actionUser
    ) VALUES (
        :OLD.productID,
        :OLD.categoryID,
        :OLD.colorID,
        :OLD.brandID,
        :OLD.productName,
        :OLD.price,
        action_name,
        SYSDATE,
        USER
    );
END;
/

