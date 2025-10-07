CREATE USER 'backupuser'@'localhost' IDENTIFIED BY 'password';

GRANT RELOAD, LOCK TABLES, PROCESS ON *.* TO 'backupuser'@'localhost';

FLUSH PRIVILEGES;