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
