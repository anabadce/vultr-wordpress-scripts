# Restore Wordpress Backup

- Uncompress

```
tar -zxf 2018-01-23-Tue-11.02-UTC-wp3534515.sql.gz
gunzip 2018-01-23-Tue-11.02-UTC-wp3534515.sql.gz
```

- Create empty DB and user credentials

```
cat var/www/html/wp-config.php | grep DB_

mysql -u root
>
  create database wp3534515 default character set utf8;
  grant all privileges on wp3534515.* to 'wpuser48553'@'localhost' identified by '************';
  exit
```

- Restore database

```
mysql -u wpuser48553 -p
  use wp3534515;
  source 2018-01-23-Tue-11.02-UTC-wp3534515.sql;
```

- Restore site

```
mv /var/www/html /var/www/html_old
mv var/www/html/ /var/www/
```

- Change URL in required

```
select * from wp_options where option_name='siteurl';

UPDATE wp_options SET option_value = replace(option_value, 'https://www.oldurl.com', 'https://www.newurl.com') WHERE option_name = 'home' OR option_name = 'siteurl';
```
