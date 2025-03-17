#!/bin/bash

# Nom du fichier de sauvegarde avec la date actuelle
backup_file="backup_keycloakdb_$(date +%d-%m-%Y_%H-%M-%S).sql"

#nom du container postrgess 
pg_container="keycloak_prod-postgres_keycloak_test-1"

#utilisateur du po"$pg_user"
pg_user="valisoa"

#nom du bdd 
pg_bdd="keycloak"


# Execution du cmd pg_dump dans le conteneur via bash -c pour configurer l'environnement 


#on entre dans le container et on verifie si le /tmp/backup existe, si non on va le cree
docker exec "$pg_container" bash -c ' if [ -e /tmp/backup ]; then echo " tmp/backup existe, on continue ";  else mkdir /tmp/backup; fi'

# on existe le pg_dump pour faire le backup avec le user valisoa et le db:kecyloak 
docker exec "$pg_container" bash -c "pg_dump -U "$pg_user" "$pg_bdd" > /tmp/backup/backupKc.sql"

# Vérification  si la commande pg_dump a réussi
if [ $? -eq 0 ]; then
	echo " Sauvegarde reussie dans le fichier /tmp/backup/backupKc.sql du container $pg_container "
    
	# Copier le file backupK.sql du container vers l'exterieur , backups (dossier)
	docker cp "$pg_container":/tmp/backup/backupKc.sql ./backups/$backup_file
    
	# Verification  si la copie a réussi
	if [ $? -eq 0 ]; then
    	echo "Sauvegarde  avec succès dans le fichier  /backups/$backup_file "
	else
    	echo "Erreur lors de la copie du fichier de sauvegarde"
	fi
else
	echo "Erreur lors de la sauvegarde"
fi
