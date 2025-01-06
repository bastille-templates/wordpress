# wordpress-
CMS WordPress

## Now apply template to container
```sh
bastille create wordpress 14.1-RELEASE YourIP-Bastille
bastille bootstrap https://github.com/bastille-templates/femp-mariadb; bastille template wordpress bastille-templates/femp-mariadb
bastille bootstrap https://github.com/bastille-templates/wordpress; bastille template wordpress bastille-templates/wordpress
```