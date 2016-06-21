# GLPI Container
Docker GLPI container automated build

Use docker-compose to run the container :

glpi:
  container_name: www_glpi
  image: joffreydupire/glpi:0.85.4
  ports:
    - "8090:80"
  links:
    - mysql:db
  env_file:
    - ./www_glpi.env
  volumes:
    - /www:/var/www/html/glpi

mysql:
  container_name: mysql_glpi
  image: mysql:5.7
  env_file:
    - ./mysql_glpi.env
  volumes:
    - /db:/var/lib/mysql
