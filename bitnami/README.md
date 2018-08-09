
# Task list base install

1. Create server with Wordpress in AWS Lightsail
2. Configure new server to have static IP in AWS Ligtsail
3. Change DNS in Route53 so `www.mydomain.com` points to that new server
4. Configure Wordpress to work with `www.mydomain.com` as main domain *(script 1)*
5. Request - validate - apply SSL certificate to make the site work with https *(script 2)*
6. Ensure http redirects to https  *(script 3)*
7. Disable welcome banner from Bitnami in the Wordpress home page  *(script 4)*
8. Tune file permissions to make site safer *(script 5)*
9. Tune PHP and Webserver *(script 6)*
10. Add scheduled tasks to: *(script 7)*

- Server keeps itself updated, code + themes + plugins. (weekly)
- Renew SSL cert automatically (weekly)
- Create local backups of Wordpress files + database (daily)

# Task list configure Wordpress

1. Configure general settings (title, tagline, timezone, format, home page, permalinks)
2. Remove example page, post, comment in Wordpress
3. Configure email delivery (WP Mail SMTP plugin)
4. Choose desired theme/plugins and add content...

# Task list third party

1. Register Google account for Google Analytics and Webmaster Tools