USE mysql;
SET @host := '${DB_HOST}';
SET @user := '${DB_USER}';
SET @pass := '${DB_PASS}';
set @rolename := '${DB_ROLE}';
SET @connlimit := '${CONN_LIMIT}';
SET @createuser := CONCAT("CREATE OR REPLACE USER ", QUOTE(@user), "@", QUOTE(@host), " IDENTIFIED BY ", QUOTE(@pass), " WITH MAX_USER_CONNECTIONS ", @connlimit);
SET @grantprivs := CONCAT("GRANT ", @rolename, " TO ", QUOTE(@user), "@", QUOTE(@host));
SET @setdefaultrole := CONCAT("SET DEFAULT ROLE ", @rolename, " FOR ", QUOTE(@user), "@", QUOTE(@host));
PREPARE stmt_createuser FROM @createuser;
EXECUTE stmt_createuser;
DROP PREPARE stmt_createuser;
PREPARE stmt_grantprivs FROM @grantprivs;
EXECUTE stmt_grantprivs;
DROP PREPARE stmt_grantprivs;
PREPARE stmt_setdefaultrole FROM @setdefaultrole;
EXECUTE stmt_setdefaultrole;
DROP PREPARE stmt_setdefaultrole;
FLUSH USER_VARIABLES;