#!/bin/bash

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES=(bashrc ctags gitconfig prompt  vim  vimrc)

printf "\nInstalling packages...\n\n"

sudo add-apt-repository ppa:gnome-terminator
sudo apt-get update
sudo apt-get install terminator

sudo pip install flake8

sudo apt-get -y -q install \
    terminator \
    python-dev \
    exuberant-ctags \
    git \
    ipython3 \
    keepass2 \
    python-pip \
    python-pip-whl \
    vim-gnome-py2

printf "\nChecking dotfiles...\n\n"

for FILE in "${DOTFILES[@]}"

do 
	TARGET="$WORKING_DIR/$FILE" 
	LINK_NAME="$HOME/.$FILE" 

	if [ -e "$LINK_NAME" ]; then

		if [ ! -L "$LINK_NAME" ]; then

			echo "$LINK_NAME exists and is not a symbolic link, we might lose data if we touch this, you decide what to do"
			continue

		fi

		if [ -L "$LINK_NAME" ]; then

			if [ "$(readlink $LINK_NAME)" = "$TARGET" ]; then

				echo "$LINK_NAME is already linked"
				continue

			else

				echo "$TARGET $LINK_NAME is not already linked, linked to $(readlink $LINK_NAME) instead"
				unlink $LINK_NAME
				ln -s $TARGET $LINK_NAME
				echo "Installed $LINK_NAME"
				continue

			fi

		fi

	else

		if [ -L "$LINK_NAME" ]; then

			echo "$LINK_NAME is a broken link! We need to unlink and relink"
			unlink $LINK_NAME
			ln -s $TARGET $LINK_NAME
			echo "Installed $LINK_NAME"

		else 

			echo "$LINK_NAME really doesn't exist, we can just link it"
			ln -s $TARGET $LINK_NAME
			echo "Installed $LINK_NAME"

		fi 

	fi

done
