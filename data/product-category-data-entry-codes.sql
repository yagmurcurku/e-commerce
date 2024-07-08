------------------------------------------------------------------

-- Elektronik
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Elektronik', NULL);

------------------------------------------------------------------

-- Elektronik kategorisine ba�l� alt kategoriler
-- K���k Ev Aletleri
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('K���k Ev Aletleri', (SELECT categoryID FROM product_category WHERE categoryName = 'Elektronik'));  


-- Telefon
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Telefon', (SELECT categoryID FROM product_category WHERE categoryName = 'Elektronik'));

------------------------------------------------------------------

-- K���k Ev Aletleri kategorisine ba�l� alt kategoriler
-- Tost Makinesi
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Tost Makinesi', (SELECT categoryID FROM product_category WHERE categoryName = 'K���k Ev Aletleri'));


-- �ay Makinesi
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('�ay Makinesi', (SELECT categoryID FROM product_category WHERE categoryName = 'K���k Ev Aletleri'));


-- S�p�rge
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('S�p�rge', (SELECT categoryID FROM product_category WHERE categoryName = 'K���k Ev Aletleri'));
-- S�p�rge Alt Kategorileri
-- Torbas�z S�p�rge
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Torbas�z S�p�rge', (SELECT categoryID FROM product_category WHERE categoryName = 'S�p�rge'));

-- Toz Torbal� S�p�rge
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Toz Torbal� S�p�rge', (SELECT categoryID FROM product_category WHERE categoryName = 'S�p�rge'));

-- Dik S�p�rge
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Dik S�p�rge', (SELECT categoryID FROM product_category WHERE categoryName = 'S�p�rge'));

-- Robot S�p�rge
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Robot S�p�rge', (SELECT categoryID FROM product_category WHERE categoryName = 'S�p�rge'));


-- �t�
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('�t�', (SELECT categoryID FROM product_category WHERE categoryName = 'K���k Ev Aletleri'));
-- �t� Alt Kategorileri
-- Buharl� �t�
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Buharl� �t�', (SELECT categoryID FROM product_category WHERE categoryName = '�t�'));

-- Buharl� Dikey �t�
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Buharl� Dikey �t�', (SELECT categoryID FROM product_category WHERE categoryName = '�t�'));

-- Buhar Kazanl� �t�
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Buhar Kazanl� �t�', (SELECT categoryID FROM product_category WHERE categoryName = '�t�'));


-- Kahve Makinesi
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Kahve Makinesi', (SELECT categoryID FROM product_category WHERE categoryName = 'K���k Ev Aletleri'));
-- Kahve Makinesi Alt Kategorileri
-- T�rk Kahve Makinesi
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('T�rk Kahve Makinesi', (SELECT categoryID FROM product_category WHERE categoryName = 'Kahve Makinesi'));

-- Espresso Makinesi
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Espresso Makinesi', (SELECT categoryID FROM product_category WHERE categoryName = 'Kahve Makinesi'));

-- Filtre Kahve Makinesi
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Filtre Kahve Makinesi', (SELECT categoryID FROM product_category WHERE categoryName = 'Kahve Makinesi'));

------------------------------------------------------------------

-- Telefon kategorisine ba�l� alt kategoriler
-- Cep Telefonu
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Cep Telefonu', (SELECT categoryID FROM product_category WHERE categoryName = 'Telefon'));
-- Cep Telefonu alt kategorileri
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Ak�ll� Cep Telefonu', (SELECT categoryID FROM product_category WHERE categoryName = 'Cep Telefonu'));

INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Tu�lu Cep Telefonu', (SELECT categoryID FROM product_category WHERE categoryName = 'Cep Telefonu'));


-- Telefon Aksesuarlar�
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Telefon Aksesuarlar�', (SELECT categoryID FROM product_category WHERE categoryName = 'Telefon'));
-- Telefon Aksesuarlar� alt kategorileri
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Telefon K�l�flar�', (SELECT categoryID FROM product_category WHERE categoryName = 'Telefon Aksesuarlar�'));

INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Kamera Lens Koruyucu', (SELECT categoryID FROM product_category WHERE categoryName = 'Telefon Aksesuarlar�'));

INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Ekran Koruyucu', (SELECT categoryID FROM product_category WHERE categoryName = 'Telefon Aksesuarlar�'));


-- G�� �r�nleri
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('G�� �r�nleri', (SELECT categoryID FROM product_category WHERE categoryName = 'Telefon'));
-- G�� �r�nleri alt kategorileri
INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Powerbank', (SELECT categoryID FROM product_category WHERE categoryName = 'G�� �r�nleri'));

INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('�arj Adapt�r�', (SELECT categoryID FROM product_category WHERE categoryName = 'G�� �r�nleri'));

INSERT INTO product_category (categoryName, parentCategoryID)
VALUES ('Ara� ��i �arj Cihaz�', (SELECT categoryID FROM product_category WHERE categoryName = 'G�� �r�nleri'));


