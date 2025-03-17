#!/bin/bash 

#le nom du container
pg_container="keycloak_prod-postgres_keycloak_test-1"

#utilisateur du po"$pg_user"
pg_user="valisoa"

#nom du bdd 
pg_bdd="keycloak"

#lien du fichier pour restaurer , $1 le nom du fichier 
restaure="backups/"$1


if [ -f "$restaure" ]; then 
    #on cree un dossier speciale pour stocker les fichiers du restauration
    docker exec "$pg_container" bash -c ' if [ -e /tmp/restauration ]; then echo " /tmp/restauration existe, on continue ";     else mkdir /tmp/restauration ; fi'

    #on copie
    docker cp "$restaure" "$pg_container":/tmp/restauration

    if [ $? -eq 0 ]; then 
        echo "copie effectué avec success"

        #suppression des tables dans le bdd 
    
        docker exec -it  "$pg_container" psql -U "$pg_user" -d "$pg_bdd" -c "DROP SCHEMA public CASCADE;"

        docker exec -it  "$pg_container" psql -U "$pg_user" -d "$pg_bdd" -c "CREATE SCHEMA public;"

        if [ $? -eq 0 ]; then 
            echo "******** Suppression des tables avec success*******"
            

            docker exec  "$pg_container" bash -c " ls -l /tmp/restauration/$1"


            #la restauration , on 2eme param, le lien du fichier qui contient le backup 
            docker exec -i "$pg_container" psql -U "$pg_user" -d "$pg_bdd" -f /tmp/restauration/$1


            if [ $? -eq 0 ]; then 
                echo "***** Bravo, Restauration de la base de données effectuée avec succès /tmp/restauration/$1"


                echo "*********redemarrage du conteneur ************"

                docker-compose down 

                docker-compose up -d 
            else
                echo "Erreur lors de la restauration de la  Bdd  avec le fichier /tmp/restauration/$1"
            fi

        else 
            echo "Erreur lors de la suppression des tables "
        fi

    else 
        echo " Erreur lors du copie de la restauration "
    fi
else
    echo " Erreur  $restaure n'existe pas"
fi





