------------------------------------------------------------------

-- Elektronik
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Elektronik', NULL);

------------------------------------------------------------------

-- Elektronik kategorisine baðlý alt kategoriler
-- Küçük Ev Aletleri
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Küçük Ev Aletleri', (SELECT categoryID FROM product_category WHERE categoryName = 'Elektronik'));  


-- Telefon
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Telefon', (SELECT categoryID FROM product_category WHERE categoryName = 'Elektronik'));

------------------------------------------------------------------

-- Küçük Ev Aletleri kategorisine baðlý alt kategoriler
-- Tost Makinesi
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Tost Makinesi', (SELECT categoryID FROM product_category WHERE categoryName = 'Küçük Ev Aletleri'));


-- Çay Makinesi
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Çay Makinesi', (SELECT categoryID FROM product_category WHERE categoryName = 'Küçük Ev Aletleri'));


-- Süpürge
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Süpürge', (SELECT categoryID FROM product_category WHERE categoryName = 'Küçük Ev Aletleri'));
-- Süpürge Alt Kategorileri
-- Torbasýz Süpürge
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Torbasýz Süpürge', (SELECT categoryID FROM product_category WHERE categoryName = 'Süpürge'));

-- Toz Torbalý Süpürge
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Toz Torbalý Süpürge', (SELECT categoryID FROM product_category WHERE categoryName = 'Süpürge'));

-- Dik Süpürge
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Dik Süpürge', (SELECT categoryID FROM product_category WHERE categoryName = 'Süpürge'));

-- Robot Süpürge
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Robot Süpürge', (SELECT categoryID FROM product_category WHERE categoryName = 'Süpürge'));


-- Ütü
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Ütü', (SELECT categoryID FROM product_category WHERE categoryName = 'Küçük Ev Aletleri'));
-- Ütü Alt Kategorileri
-- Buharlý Ütü
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Buharlý Ütü', (SELECT categoryID FROM product_category WHERE categoryName = 'Ütü'));

-- Buharlý Dikey Ütü
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Buharlý Dikey Ütü', (SELECT categoryID FROM product_category WHERE categoryName = 'Ütü'));

-- Buhar Kazanlý Ütü
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Buhar Kazanlý Ütü', (SELECT categoryID FROM product_category WHERE categoryName = 'Ütü'));


-- Kahve Makinesi
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Kahve Makinesi', (SELECT categoryID FROM product_category WHERE categoryName = 'Küçük Ev Aletleri'));
-- Kahve Makinesi Alt Kategorileri
-- Türk Kahve Makinesi
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Türk Kahve Makinesi', (SELECT categoryID FROM product_category WHERE categoryName = 'Kahve Makinesi'));

-- Espresso Makinesi
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Espresso Makinesi', (SELECT categoryID FROM product_category WHERE categoryName = 'Kahve Makinesi'));

-- Filtre Kahve Makinesi
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Filtre Kahve Makinesi', (SELECT categoryID FROM product_category WHERE categoryName = 'Kahve Makinesi'));

------------------------------------------------------------------

-- Telefon kategorisine baðlý alt kategoriler
-- Cep Telefonu
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Cep Telefonu', (SELECT categoryID FROM product_category WHERE categoryName = 'Telefon'));
-- Cep Telefonu alt kategorileri
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Akýllý Cep Telefonu', (SELECT categoryID FROM product_category WHERE categoryName = 'Cep Telefonu'));

INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Tuþlu Cep Telefonu', (SELECT categoryID FROM product_category WHERE categoryName = 'Cep Telefonu'));


-- Telefon Aksesuarlarý
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Telefon Aksesuarlarý', (SELECT categoryID FROM product_category WHERE categoryName = 'Telefon'));
-- Telefon Aksesuarlarý alt kategorileri
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Telefon Kýlýflarý', (SELECT categoryID FROM product_category WHERE categoryName = 'Telefon Aksesuarlarý'));

INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Kamera Lens Koruyucu', (SELECT categoryID FROM product_category WHERE categoryName = 'Telefon Aksesuarlarý'));

INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Ekran Koruyucu', (SELECT categoryID FROM product_category WHERE categoryName = 'Telefon Aksesuarlarý'));


-- Güç Ürünleri
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Güç Ürünleri', (SELECT categoryID FROM product_category WHERE categoryName = 'Telefon'));
-- Güç Ürünleri alt kategorileri
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Powerbank', (SELECT categoryID FROM product_category WHERE categoryName = 'Güç Ürünleri'));

INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Þarj Adaptörü', (SELECT categoryID FROM product_category WHERE categoryName = 'Güç Ürünleri'));

INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Araç Ýçi Þarj Cihazý', (SELECT categoryID FROM product_category WHERE categoryName = 'Güç Ürünleri'));


