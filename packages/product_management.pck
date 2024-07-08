create or replace package product_management is

  procedure check_entity_exists_and_active(p_entityType in varchar2,
                                           p_entityID   in number,
                                           p_errorCode  in number,
                                           p_errorMsg   in varchar2);

  procedure add_product(p_categoryID  in number,
                        p_colorID     in number,
                        p_brandID     in number,
                        p_productName in varchar2,
                        p_price       in number);

  procedure delete_product(p_productID in number);

  procedure reactivate_product(p_productID in number);

  procedure filter_products(p_categoryID   in number default null,
                            p_colorID      in number default null,
                            p_brandID      in number default null,
                            p_min_price    in number default null,
                            p_max_price    in number default null,
                            p_order_by     in number default null,
                            p_product_name in varchar2 default null,
                            p_result       out sys_refcursor);

end product_management;
/
create or replace package body product_management is

  v_isActive varchar2(1);

  --Hata kodlarý
  c_product_already_exists  constant number := -20007;
  c_category_not_active     constant number := -20008;
  c_color_not_active        constant number := -20009;
  c_brand_not_active        constant number := -20010;
  c_price_not_positive      constant number := -20011;
  c_product_already_deleted constant number := -20012;
  c_product_already_active  constant number := -20013;

  --Hata mesajlarý
  c_product_already_exists_msg  constant varchar2(400) := 'Bu ürün zaten mevcut.';
  c_category_not_active_msg     constant varchar2(400) := 'Aktif olmayan kategori!';
  c_color_not_active_msg        constant varchar2(400) := 'Aktif olmayan renk!';
  c_brand_not_active_msg        constant varchar2(400) := 'Aktif olmayan marka!';
  c_price_not_positive_msg      constant varchar2(400) := 'Fiyat pozitif olmalý!';
  c_product_already_deleted_msg constant varchar2(400) := 'Bu ürün zaten silinmis.';
  c_product_already_active_msg  constant varchar2(400) := 'Bu ürün zaten aktif durumda.';



  --ÜRÜN MEVCUT MU VE AKTÝF MÝ KONTROLÜ
  procedure check_entity_exists_and_active(p_entityType in varchar2,
                                           p_entityID   in number,
                                           p_errorCode  in number,
                                           p_errorMsg   in varchar2) is
    v_isActive varchar2(1);
  begin
    --mevcutluk kontrol
    if p_entityType = 'CATEGORY' then
      select isActive
        into v_isActive
        from product_category
       where categoryID = p_entityID;
    elsif p_entityType = 'COLOR' then
      select isActive
        into v_isActive
        from color
       where colorID = p_entityID;
    elsif p_entityType = 'BRAND' then
      select isActive
        into v_isActive
        from brand
       where brandID = p_entityID;
    elsif p_entityType = 'PRODUCT' then
      select isActive
        into v_isActive
        from product
       where productID = p_entityID;
    else
      RAISE_APPLICATION_ERROR(-20014,
                              'Gecersiz varlýk türü! CATEGORY, COLOR, BRAND ve PRODUCT icin kontrol yapabilirsiniz.');
    end if;
  
    --aktiflik kontrol
    if v_isActive = 'N' then
      RAISE_APPLICATION_ERROR(p_errorCode, p_errorMsg);
    end if;
  exception
    when NO_DATA_FOUND then
      RAISE_APPLICATION_ERROR(-20015,
                              'Gecersiz ID girdiniz. Kategori, Renk, Marka veya Ürün bulunamadi.');
    when others then
      handle_error(sqlcode, sqlerrm);
  end check_entity_exists_and_active;



  --ÜRÜN EKLEME
  procedure add_product(p_categoryID  in number,
                        p_colorID     in number,
                        p_brandID     in number,
                        p_productName in varchar2,
                        p_price       in number) is
    v_exists number;
  begin
    --Birebir ayný olan ürün kontrolü(ayný ürün farklý fiyatlarda kaydedilebilir, bunun önüne geçiyoruz)
    select count(*)
      into v_exists
      from product
     where categoryID = p_categoryID
       and colorID = p_colorID
       and brandID = p_brandID
       and productName = p_productName;
  
    if v_exists > 0 then
      RAISE_APPLICATION_ERROR(c_product_already_exists,
                              c_product_already_exists_msg);
    end if;
  
    -- Kategori aktiflik kontrolü
    check_entity_exists_and_active('CATEGORY',
                                   p_categoryID,
                                   c_category_not_active,
                                   c_category_not_active_msg);
    -- Renk aktiflik kontrolü
    check_entity_exists_and_active('COLOR',
                                   p_colorID,
                                   c_color_not_active,
                                   c_color_not_active_msg);
    -- Marka aktiflik kontrolü
    check_entity_exists_and_active('BRAND',
                                   p_brandID,
                                   c_brand_not_active,
                                   c_brand_not_active_msg);

    --Fiyat pozitif mi kontrolü.
    if p_price <= 0 then
      RAISE_APPLICATION_ERROR(c_price_not_positive,
                              c_price_not_positive_msg);
    end if;
  
    --Ürünün eklenmesi.
    insert into product
      (categoryID, colorID, brandID, productName, price)
    values
      (p_categoryID, p_colorID, p_brandID, p_productName, p_price);
  
    dbms_output.put_line('Urün basariyla eklendi.');
    commit;
  exception
    when others then
      handle_error(sqlcode, sqlerrm);
  end add_product;



  --ÜRÜN SÝLME
  procedure delete_product(p_productID in number) is
  begin

    --Ürün aktiflik kontrolü
    check_entity_exists_and_active('PRODUCT',
                                   p_productID,
                                   c_product_already_deleted,
                                   c_product_already_deleted_msg);

    --Ürün soft delete yapýlmasý.
    update product set isActive = 'N' where productID = p_productID;
  
    dbms_output.put_line('Urün basariyla silindi.');
    commit;
  exception
    when others then
      handle_error(sqlcode, sqlerrm);
  end delete_product;



  --ÜRÜNÜ YENÝDEN AKTÝF ETME
  procedure reactivate_product(p_productID in number) is
  begin
  
    --Ürün aktifliði kontrolü.
    select isActive
      into v_isActive
      from product
     WHERE productID = p_productID;
  
    if v_isActive = 'Y' then
      RAISE_APPLICATION_ERROR(c_product_already_active,
                              c_product_already_active_msg);
    end if;
  
    -- Ürün yeniden aktif et
    update product set isActive = 'Y' where productID = p_productID;
  
    dbms_output.put_line('Ürün baþarý ile yeniden aktifleþtirildi.');
    commit;
  
  exception
    when no_data_found then
      handle_error(sqlcode,
                   'Geçersiz ID girdiniz. Aktifleþtirilecek ürün bulunamadý.');
    when others then
      handle_error(sqlcode, sqlerrm);
  end reactivate_product;



  --ÜRÜNLERÝ BELÝRLÝ KOÞULLARA GÖRE FÝLTRELEME VE SIRALAMA
  procedure filter_products(p_categoryID   in number default null,
                            p_colorID      in number default null,
                            p_brandID      in number default null,
                            p_min_price    in number default null,
                            p_max_price    in number default null,
                            p_order_by     in varchar2 default null,
                            p_product_name in varchar2 default null,
                            p_result       out sys_refcursor) is
  begin
    open p_result for
      select p.productID,
             p.categoryID,
             p.colorID,
             p.brandID,
             p.productName,
             p.price,
             (select count(*)
                from favorite f
               where f.productID = p.productID) as favoriteCount,
             (select NVL(SUM(pd.quantity), 0)
                from purchase_detail pd
               where pd.productID = p.productID) as purchaseCount
        from product p
       where (p_categoryID is null or p.categoryID = p_categoryID)
         and (p_colorID is null or p.colorID = p_colorID)
         and (p_brandID is null or p.brandID = p_brandID)
         and (p_min_price is null or p.price >= p_min_price)
         and (p_max_price is null or p.price <= p_max_price)
         and (p_product_name is null or
             LOWER(p.productName) like LOWER('%' || p_product_name || '%'))
       order by case
                  when p_order_by = 'Artan Fiyat' then
                   p.price
                end ASC,
                case
                  when p_order_by = 'Azalan Fiyat' then
                   p.price
                end DESC,
                case
                  when p_order_by = 'A dan Z ye' then
                   p.productName
                end ASC,
                case
                  when p_order_by = 'Z den A ya' then
                   p.productName
                end DESC,
                case
                  when p_order_by = 'En Favoriler' then
                   favoriteCount
                end DESC,
                case
                  when p_order_by = 'En Çok Satanlar' then
                   purchaseCount
                end DESC,
                p.productID;
  exception
    when others then
      handle_error(sqlcode, sqlerrm);
  end filter_products;

end product_management;
/
