create or replace package user_management is

  procedure check_user_exists(p_username    in user_definition.username%type,
                              p_user_exists out varchar2);

  procedure check_length(p_value      in varchar2,
                         p_min_length in number,
                         p_max_length in number,
                         p_field_name in varchar2);

  procedure user_register(p_username in user_definition.username%type,
                          p_password in varchar2);

  procedure reset_password(p_username    in user_definition.username%type,
                           p_password    in varchar2,
                           p_newPassword in varchar2);

  procedure user_login(p_username in user_definition.username%type,
                       p_password in varchar2);

  procedure user_logoff(p_username in user_definition.username%type);

  function generate_salt return user_definition.salt%type;

  function hash_password(p_password in varchar2,
                         p_salt     in user_definition.salt%type)
    return varchar2;

  function check_user_logged_in(p_userID in user_status.userID%type)
    return number;

  function check_user_exists(p_userID in user_definition.userID%type)
    return number;

end user_management;
/
create or replace package body user_management is

  v_user_exists varchar2(5);

  --Hata kodlarý
  c_username_already_used   constant number := -20003;
  c_user_not_found          constant number := -20004;
  c_wrong_password          constant number := -20005;
  c_user_already_logged_out constant number := -20006;

  --Hata mesajlarý
  c_username_already_used_msg   constant varchar2(400) := 'Bu kullanici adi baska biri tarafindan kullaniliyor.';
  c_user_not_found_msg          constant varchar2(400) := 'Bu isimde bir kullanici bulunamadi.';
  c_wrong_password_msg          constant varchar2(400) := 'Hatali sifre.';
  c_user_already_logged_out_msg constant varchar2(400) := 'Kullanici zaten cevrimdisi.';


  --SALT OLUÞTURMA
  function generate_salt return user_definition.salt%type is
    v_salt user_definition.salt%type;
  begin
    v_salt := dbms_random.string('x', 32);
    return v_salt;
  exception
    when others then
      handle_error(sqlcode, sqlerrm);
  end generate_salt;


  --PAROLA HASH'LEME
  function hash_password(p_password in varchar2,
                         p_salt     in user_definition.salt%type)
    return varchar2 is
    v_hash raw(256);
  begin
    v_hash := dbms_crypto.hash(utl_raw.cast_to_raw(p_password || p_salt),
                               dbms_crypto.hash_sh256);
    return rawtohex(v_hash);
  exception
    when others then
      handle_error(sqlcode, sqlerrm);
  end hash_password;

  
  --USER LOGIN KONTROLÜ
  function check_user_logged_in(p_userID in user_status.userID%type)
    return number is
    v_logged_in number := 0;
  begin
    select count(*)
      into v_logged_in
      from user_status
     where userID = p_userID
       and isLoggedIn = 'Y';
    return v_logged_in;
  exception
    when others then
      handle_error(sqlcode, sqlerrm);
  end check_user_logged_in;


  --USER VARLIÐI KONTROLÜ(userID ile).
  function check_user_exists(p_userID in user_definition.userID%type)
    return number is
    v_user_count number;
  begin
    select count(*)
      into v_user_count
      from user_definition
     where userID = p_userID;
  
    return v_user_count;
  exception
    when others then
      handle_error(sqlcode, sqlerrm);
  end check_user_exists;


  --USER VARLIÐI KONTROLÜ(username ile).
  procedure check_user_exists(p_username    in user_definition.username%type,
                              p_user_exists out varchar2) is
    v_user_count number;
  begin
    select count(*)
      into v_user_count
      from user_definition
     where username = p_username;
  
    if v_user_count > 0 then
      p_user_exists := 'TRUE';
    else
      p_user_exists := 'FALSE';
    end if;
  exception
    when others then
      handle_error(sqlcode, sqlerrm);
  end check_user_exists;


  --USRENAME VEYA PASSWORD ÝÇÝN KARAKTER UZUNLUÐU KONTROLÜ.
  procedure check_length(p_value      in varchar2,
                         p_min_length in number,
                         p_max_length in number,
                         p_field_name in varchar2) is
    v_error_message varchar2(400);
  begin
    if length(p_value) < p_min_length then
      v_error_message := p_field_name || ' en az ' || p_min_length ||
                         ' karakterden olusmalidir.';
      raise_application_error(-20001, v_error_message);
    elsif length(p_value) > p_max_length then
      v_error_message := p_field_name || ' cok uzun! En fazla ' ||
                         p_min_length || ' karakterden olusmalidir.';
      raise_application_error(-20002, v_error_message);
    end if;
  exception
    when others then
      handle_error(sqlcode, sqlerrm);
  end check_length;


  --KULLANICI KAYIT
  procedure user_register(p_username in user_definition.username%type,
                          p_password in varchar2) is
    v_salt user_definition.salt%type;
    v_hash user_definition.passwordHash%type;
  begin
    --username kontrolü.
    check_user_exists(p_username, v_user_exists);
  
    if v_user_exists = 'TRUE' then
      raise_application_error(c_username_already_used,
                              c_username_already_used_msg);
    end if;
  
    --username uzunluðu kontrolü
    check_length(p_username, 5, 30, 'Kullanýcý adý');
    check_length(p_password, 7, 20, 'Þifre');
  
    --Salt oluþturulmasý ve parolanýn hash'lenmesi.
    v_salt := generate_salt();
  
    v_hash := hash_password(p_password, v_salt);
  
    --Kullanýcýnýn eklenmesi.
    insert into user_definition
      (username, passwordHash, salt)
    values
      (p_username, v_hash, v_salt);
  
    dbms_output.put_line('Kullanici kaydi basarili.');
    commit;
  exception
    when others then
      handle_error(sqlcode, sqlerrm);
  end user_register;


  --PAROLA SIFIRLAMA
  procedure reset_password(p_username    in user_definition.username%type,
                           p_password    in varchar2,
                           p_newPassword in varchar2) is
    v_userID      user_definition.userID%type;
    v_salt        user_definition.salt%type;
    v_hash        user_definition.passwordHash%type;
    v_enteredHash user_definition.passwordHash%type;
  begin
    --kullanýcý kontrolü
    check_user_exists(p_username, v_user_exists);
  
    if v_user_exists = 'FALSE' then
      raise_application_error(c_user_not_found, c_user_not_found_msg);
    else
      select userID, salt, passwordHash
        into v_userID, v_salt, v_hash
        from user_definition
       where username = p_username;
    end if;
  
    --Parola doðruluk kontrolü.
    v_enteredHash := hash_password(p_password, v_salt);
  
    IF v_enteredHash = v_hash THEN
      --yeni password uzunluðu kontrolü
      check_length(p_newPassword, 7, 20, 'Þifre');
    
      --Yeni salt oluþturulmasý ve yeni parolanýn hash'lenmesi.
      v_salt := generate_salt();
      v_hash := hash_password(p_newPassword, v_salt);
    
      --Parolanýn güncellenmesi.
      update user_definition
         set passwordHash = v_hash, salt = v_salt
       where userID = v_userID;
    
      dbms_output.put_line('Sifre basariyla güncellendi.');
      commit;
    else
      raise_application_error(c_wrong_password, c_wrong_password_msg);
    end if;
  exception
    when others then
      handle_error(sqlcode, sqlerrm);
  end reset_password;


  --KULLANICI GÝRÝÞ
  procedure user_login(p_username in user_definition.username%type,
                       p_password in varchar2) is
    v_userID      user_definition.userID%TYPE;
    v_salt        user_definition.salt%TYPE;
    v_hash        user_definition.passwordHash%TYPE;
    v_enteredHash user_definition.passwordHash%TYPE;
  begin
    --kullanýcý kontrolü
    check_user_exists(p_username, v_user_exists);

    if v_user_exists = 'TRUE' then
      select userID, salt, passwordHash
        into v_userID, v_salt, v_hash
        from user_definition
       where username = p_username;
    else
      raise_application_error(c_user_not_found, c_user_not_found_msg);
    end if;
  
    --Girilen parolanýn hash'lenmesi.
    v_enteredHash := hash_password(p_password, v_salt);
  
    --Hash'lerin karþýlaþtýrýlmasý.
    if v_enteredHash = v_hash then
      update user_status set isLoggedIn = 'Y' where userID = v_userID;
      dbms_output.put_line('Kullanici girisi basarili.');
      commit;
    else
      raise_application_error(c_wrong_password, c_wrong_password_msg);
    end if;
  exception
    when others then
      handle_error(sqlcode, sqlerrm);
  end user_login;
  

  --KULLANICI ÇIKIÞ
  procedure user_logoff(p_username in user_definition.username%type) is
    v_userID     user_definition.userID%TYPE;
    v_isLoggedIn user_status.isLoggedIn%TYPE;
  begin
    --kullanýcý kontrolü.
    check_user_exists(p_username, v_user_exists);
  
    if v_user_exists = 'TRUE' then
      --kullanýcý oturum durumu kontrolü.
      select ud.userID, us.isLoggedIn
        into v_userID, v_isLoggedIn
        from user_definition ud
        join user_status us
          on us.userID = ud.userID
       where ud.username = p_username;
    
      if v_isLoggedIn = 'N' then
        raise_application_error(c_user_already_logged_out,
                                c_user_already_logged_out_msg);
      else
        update user_status set isLoggedIn = 'N' where userID = v_userID;
      
        dbms_output.put_line('Oturum sonlandirildi.');
        commit;
      end if;
    else
      raise_application_error(c_user_not_found,
                              'Cikis yapmak icin ' || c_user_not_found_msg);
    end if;
  exception
    when others then
      handle_error(sqlcode, sqlerrm);
  end user_logoff;

end user_management;
/
