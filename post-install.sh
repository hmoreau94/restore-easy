#!/bin/sh

## README
# /!\ Ce script d'installation est conçu pour mon usage. Ne le lancez pas sans vérifier chaque commande ! /!\

## La base : Homebrew et les lignes de commande
if test ! $(which brew)
then
	echo 'Installation de Homebrew'
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Vérifier que tout est bien à jour
brew update

## Utilitaires pour les autres apps : Cask et mas (Mac App Store)
echo 'Installation de mas, pour installer les apps du Mac App Store.'
brew install mas
echo "Saisir le mail du compte iTunes :" 
read COMPTE
echo "Saisir le mot de passe du compte : $COMPTE"
read -s PASSWORD
mas signin $COMPTE "$PASSWORD"

# Installation d'apps avec mas (source : https://github.com/argon/mas/issues/41#issuecomment-245846651)
function install () {
	# Check if the App is already installed
	mas list | grep -i "$1" > /dev/null

	if [ "$?" == 0 ]; then
		echo "==> $1 est déjà installée"
	else
		echo "==> Installation de $1..."
		mas search "$1" | { read app_ident app_name ; mas install $app_ident ; }
	fi
}

echo 'Installation de Cask, pour installer les autres apps.'
brew tap caskroom/cask

## Installations des logiciels
echo 'Installation des outils en ligne de commande.'
brew install wget coreutils 

echo 'Installation des apps : utilitaires.'
brew cask install 1password alfred istat-menus dropbox google-drive flux appcleaner carbon-copy-cloner selfcontrol onyx wireshark
install "BetterSnapTool"
install "Amphetamine"
install "Daum Equation Editor"
install "The Unarchiver"

echo "Ouverture de Dropbox pour commencer la synchronisation"
open -a Dropbox


echo 'Installation des apps : bureautique.'
install "Pages"
install "Keynote"
install "Numbers"
brew cask install microsoft-office

echo 'Installation des apps : développement.'
brew cask install github-desktop brackets sublime-text visual-studio-code mactex anaconda
install "Xcode"

echo 'Installation des apps : communication.'
install "Wunderlist"
brew cask install google-chrome transmission franz skype

echo 'Installation des apps : photo, vidéo, musique.'
brew cask install vlc spotify

## ************************* CONFIGURATION ********************************
echo "Configuration de quelques paramètres par défaut…"

## FINDER

# Finder : affichage de la barre latérale / affichage par défaut en mode liste / affichage chemin accès / extensions toujours affichées
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string “Nlsv”
defaults write com.apple.finder ShowPathbar -bool true
sudo defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Afficher le dossier maison par défaut
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Coup d'œîl : sélection de texte
defaults write com.apple.finder QLEnableTextSelection -bool true

# Pas de création de fichiers .DS_STORE
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Changer l'emplacement des screenshot
mkdir -p /Users/hmoreau/Pictures/Screenshots
defaults write com.apple.screencapture location ~/Pictures/Screenshots

# Créer les dossiers
mkdir -p /Users/hmoreau/Movies/{To\ See,To\ Store}
mkdir -p /Users/hmoreau/Developer


## RÉGLAGES DOCK
# Taille du texte au minimum
defaults write com.apple.dock tilesize -int 15
# Regler le auto-hide du dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0 
defaults write com.apple.dock autohide-time-modifier -float 0 

## MISSION CONTROL
# Pas d'organisation des bureaux en fonction des apps ouvertes
defaults write com.apple.dock mru-spaces -bool false

# Mot de passe demandé immédiatement quand l'économiseur d'écran s'active
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

## CLAVIER ET TRACKPAD
# Accès au clavier complet (tabulation dans les boîtes de dialogue)
sudo defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Arrêt pop-up clavier façon iOS
sudo defaults write -g ApplePressAndHoldEnabled -bool false

# Répétition touches plus rapide
sudo defaults write NSGlobalDomain KeyRepeat -int 1
# Délai avant répétition des touches
sudo defaults write NSGlobalDomain InitialKeyRepeat -int 20

# Alertes sonores quand on modifie le volume
sudo defaults write com.apple.systemsound com.apple.sound.beep.volume -float 1

# Réglages Trackpad : toucher pour cliquer
sudo defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
sudo defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# hide status bar item for location services
launchctl unload -w /System/Library/LaunchAgents/com.apple.locationmenu.plist 

## Disable app auto-resume on relaunch
# Make the file owned by root (otherwise the OS will just replace it)
sudo chown root ~/Library/Preferences/ByHost/com.apple.loginwindow*

# Remove all permissions, so it can't be read or written to
sudo chmod 000 ~/Library/Preferences/ByHost/com.apple.loginwindow*

# Allow to download applications from anywhere in the security options
sudo spctl --master-disable


## APPS
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool YES

# TextEdit : .txt par défaut
defaults write com.apple.TextEdit RichText -int 0

## ************ Fin de l'installation *********
echo "Finder et Dock relancés… redémarrage nécessaire pour terminer."
killall Dock
killall Finder
killall SystemUIServer

echo "Derniers nettoyages…"
brew cleanup
rm -f -r /Library/Caches/Homebrew/*

echo "ET VOILÀ !"
echo "Après synchronisation des données cloud, lancer le script post-cloud.sh"