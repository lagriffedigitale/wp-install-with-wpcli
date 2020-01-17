website_path="./web"

echo " "
echo "###"
echo "Bienvenue dans WP Install"
echo "Des informations sur la configuration de WordPress vont vous être demandé..."
echo "###"
echo " "
echo " "
echo " "

echo "## Informations du compte administrateur ##"
echo " "
echo "Login de l'administrateur ?";
read username
echo "E-mail de l'administrateur ?";
read usermail
echo "Mot de passe de l'administrateur ?";
read userpass
echo " "
echo " "
echo " "

echo "## Informations du site ##"
echo " "
echo "Nom de domaine (sans http://) ?";
read local_domain
echo "Titre du site ?";
read website_title
echo "Description du site ?";
read website_desc
echo " "
echo " "
echo " "

echo "## Informations de connexion à la base de données ##"
echo " "
echo "Hôte :";
read db_host
echo "Base de données :";
read db_name
echo "Identifiant :";
read db_user
echo "Mot de passe :";
read db_password
echo "Préfixe des tables (MySQL) :";
read db_prefix
echo " "
echo " "
echo " "

#PLUG-INS TO INSTALL
plugins_list_configuration='./plugins_list.txt'

#CREATE WP FOLDER
mkdir -p 'web'

# DOWNLOAD WP CORE IN FRENCH
echo " "
echo "Téléchargement de WordPress..."
echo " "

wp core download --path=$website_path --locale=fr_FR


#CREATE WP-CONFIG
echo " "
echo "Création du fichier WP Config..."
echo " "

wp config create --dbhost=$db_host --dbname=$db_name --dbuser=$db_user --dbpass=$db_password --dbprefix=$db_prefix --extra-php --path=$website_path <<PHP
define( 'WP_DEBUG', TRUE );
define( 'WP_DEBUG_LOG', TRUE );
define( 'WP_POST_REVISIONS', 3 );
define( 'WP_AUTO_UPDATE_CORE', FALSE );
PHP

# INSTALL WP
echo " "
echo "Installation de WordPress..."
echo " "
wp core install --url="http://$local_domain" --title=test --admin_user=$username --admin_email=$usermail --admin_password=$userpass --path=$website_path

# Update WP Description
# wp option update blogdescription < $website_desc

# INSTALL & ACTIVE PLUG-INS
echo " "
echo "Installation des plugins..."
echo " "

while IFS= read -r module
do
  echo " "
  echo " "
  wp plugin install $module --path=$website_path
  echo "Installation de $module ..."
  wp plugin activate $module --path=$website_path
  echo "Activation de $module ..."
  echo " "
  echo " "
done < "$plugins_list_configuration"

# CLEAN
echo " "
echo "Nettoyage en cours... Suppression des plugins et posts inutiles"
echo " "

#UPDATE OPTIONS
cd web/ && wp option update blogname "$website_title" && wp option update blogdescription "$website_desc" && wp plugin delete hello && wp plugin delete akismet && wp post delete 1 && wp post delete 2

# OPEN WEBSITE
open "http://$local_domain"
