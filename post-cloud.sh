#!/bin/sh

## README
# /!\ Ce script d'installation est conçu pour mon usage. Ne le lancez pas sans vérifier chaque commande ! /!\
# Ce script est à utiliser après la synchronisation des données Dropbox (ou Google Drive, ou iCloud, ou ce que vous voulez)

echo "Installation de mackup et restauration des préférences."
brew install mackup

# Récupéeation de la sauvegarde sans demander à chaque fois l'autorisation
mackup restore -n

