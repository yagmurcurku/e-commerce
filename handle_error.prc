CREATE OR REPLACE PROCEDURE handle_error(p_error_code in number default null, p_error_message in varchar2) is
BEGIN
    DBMS_OUTPUT.PUT_LINE('Hata: ' || p_error_code || ' -> ' || p_error_message);
    dbms_output.new_line;
    DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_CALL_STACK);
    DBMS_OUTPUT.PUT_LINE('° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° °');
    DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    DBMS_OUTPUT.PUT_LINE('° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° ° °');
    dbms_output.new_line;
    dbms_output.new_line;
END handle_error;
/
