#!/bin/bash
# - Install GLPI if not already installed
# - Run apache in foreground

### GENERAL CONF ###############################################################

APACHE_DIR="/var/www/html"
GLPI_DIR="/var/www/html/glpi"
GLPI_SOURCE_URL=${GLPI_SOURCE_URL:-"https://forge.glpi-project.org/attachments/download/2020/glpi-0.85.4.tar.gz"}
VHOST=/etc/apache2/sites-enabled/000-default.conf

### INSTALL GLPI IF NOT INSTALLED ALREADY ######################################

if [ "$(ls -A $GLPI_DIR)" ]; then
  echo "GLPI is already installed at ${GLPI_DIR}"
else
  echo '-----------> Install GLPI'
  echo "Using ${GLPI_SOURCE_URL}"
  wget -O /tmp/glpi.tar.gz $GLPI_SOURCE_URL --no-check-certificate
  tar -C $APACHE_DIR -xzf /tmp/glpi.tar.gz
  chown -R www-data $GLPI_DIR
fi

### REMOVE THE DEFAULT INDEX.HTML TO LET HTACCESS REDIRECTION ##################

# rm ${APACHE_DIR}/index.html

# Use /var/www/html/glpi as DocumentRoot
#sed -i 's/\/var\/www\/html/\/var\/www\/html\/glpi/g' $VHOST
#sed 's_DocumentRoot /var/www/html /var/www/html/glpi_' $VHOST  
# Remove ServerSignature (secutiry)
#awk '/<\/VirtualHost>/{print "ServerSignature Off" RS $0;next}1' $VHOST > tmp && mv tmp $VHOST

touch /etc/apache2/sites-available/glpi.conf
echo "<VirtualHost *:80>" >> /etc/apache2/sites-available/glpi.conf
echo "  DocumentRoot /var/www/html/glpi " >> /etc/apache2/sites-available/glpi.conf
echo "  ErrorLog ${APACHE_DIR}/error.log " >> /etc/apache2/sites-available/glpi.conf
echo "  CustomLog ${APACHE_DIR}/access.log combined " >> /etc/apache2/sites-available/glpi.conf
echo "</VirtualHost>" >> /etc/apache2/sites-available/glpi.conf
sudo a2dissite 000-default
sudo a2ensite glpi
sudo service apache2 reload

# HTACCESS="/var/www/html/.htaccess"
# /bin/cat <<EOM >$HTACCESS
# RewriteEngine On
# RewriteRule ^$ /glpi [L]
# EOM
# chown www-data /var/www/html/.htaccess
chown www-data .

### RUN APACHE IN FOREGROUND ###################################################

# stop apache service
# service apache2 stop
service apache2 restart

# start apache in foreground
# source /etc/apache2/envvars
# /usr/sbin/apache2 -D FOREGROUND
tail -f /var/log/apache2/error.log -f /var/log/apache2/access.log
