-- Seed MariaDB versionné : utilisateur de backup.
-- Changez le mot de passe ci-dessous avant tout usage hors poste de dev.
-- `backupuser` se connecte en TCP depuis le réseau Docker : host `%` requis
-- (`localhost` ne couvrirait que les connexions locales au conteneur).
CREATE USER 'backupuser'@'%' IDENTIFIED BY 'change_me_backup_password';

GRANT RELOAD, LOCK TABLES, PROCESS ON *.* TO 'backupuser'@'%';

FLUSH PRIVILEGES;