--
create table user_definition (
    userID number primary key,
    username varchar2(50) not null,
    passwordHash varchar2(100) not null,
    salt varchar2(100) not null,
    constraint uq_username unique (username)
);

--
create table user_status (
    userStatusID number primary key,
    userID number,
    isLoggedIn char(1) default 'N',
    constraint fk_userStatus_userID foreign key (userID) references user_definition(userID),
    constraint chk_isLoggedIn check (isLoggedIn IN ('N', 'Y'))
);

--
create table product_category (
    categoryID number primary key,
    categoryName varchar2(100) not null,
    parentCategoryID number,
    constraint fk_productCategory_parentCategoryID foreign key (parentCategoryID) references product_category(categoryID),
    constraint uq_categoryName unique (categoryName)
);

--
create table color (
    colorID number primary key,
    colorName varchar2(50) not null,
    hexCode varchar2(7) not null,
    constraint uq_colorName unique (colorName),
    constraint uq_hexCode unique (hexCode)
);

--
create table brand (
    brandID number primary key,
    brandName varchar2(50) not null,
    constraint uq_brandName unique (brandName)
);

--
create table product (
    productID number primary key,
    categoryID number not null,
    colorID number not null,
    brandID number not null,
    productName varchar2(100) not null,
    price number(10,2) not null,
    isActive char(1) default 'Y',
    constraint fk_product_categoryID foreign key (categoryID) references product_category(categoryID),
    constraint fk_product_colorID foreign key (colorID) references color(colorID),
    constraint fk_product_brandID foreign key (brandID) references brand(brandID),
    constraint chk_price_positive check (price > 0),
    constraint chk_isActive check (isActive IN ('N', 'Y'))
);
--ALTER TABLE product ADD (isActive CHAR(1) DEFAULT 'Y' CHECK (isActive IN ('Y', 'N')));       --eklendi.


--
create table cart (
    cartID number primary key,
    userID number not null,
    productID number not null,
    quantity number not null,
    constraint fk_cart_userID foreign key (userID) references user_definition(userID),
    constraint fk_cart_productID foreign key (productID) references product(productID)
);

--
create table purchase (
    purchaseID number primary key,
    userID number not null,
    purchaseDate date default sysdate,
    totalPrice number(10,2) not null,
    constraint fk_purchase_userID foreign key (userID) references user_definition(userID)
);

--
create table purchase_detail (
    purchaseDetailID number primary key,
    purchaseID number not null,                 
    productID number not null,
    quantity number not null,
    constraint fk_purchaseDetail_purchaseID foreign key (purchaseID) references purchase(purchaseID),
    constraint fk_purchaseDetail_productID foreign key (productID) references product(productID)
);

--
create table favorite (
    favoriteID number primary key,
    userID number not null,
    productID number not null,
    constraint fk_favorite_userID foreign key (userID) references user_definition(userID),
    constraint fk_favorite_productID foreign key (productID) references product(productID),
    constraint uq_user_favorite unique (userID, productID)             --bir kullan�c� ayn� �r�n� birden fazla defa fav ekleyemez
);

--
create table product_log (
    productLogID number primary key,
    productID number not null,
    categoryID number,
    colorID number,
    brandID number,
    productName varchar2(100),
    price number(10,2),
    action varchar2(100) not null,
    actionDate date not null,
    actionUser varchar2(100) not null,
    constraint fk_productLog_productID foreign key (productID) references product(productID),
    constraint fk_productLog_categoryID foreign key (categoryID) references product_category(categoryID),
    constraint fk_productLog_colorID foreign key (colorID) references color(colorID),
    constraint fk_productLog_brandID foreign key (brandID) references brand(brandID),
    constraint chk_price_valid check (price > 0 or price is null)
);






drop table user_definition;
drop table user_status;
drop table product_category;
drop table color;
drop table brand;
drop table product;
drop table cart;
drop table purchase;
drop table purchase_detail;
drop table favorite;
drop table product_log;




SELECT * FROM user_definition;
SELECT * FROM user_status;
SELECT * FROM product_category;
SELECT * FROM color;
SELECT * FROM brand;
SELECT * FROM product;
SELECT * FROM cart;
SELECT * FROM purchase;
SELECT * FROM purchase_detail;
SELECT * FROM favorite;
SELECT * FROM product_log;


















