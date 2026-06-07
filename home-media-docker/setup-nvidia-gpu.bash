#!/usr/bin/env bash

set -euo pipefail

ubuntu-drivers devices

echo "Would you like to install the suggested? [Y/n]"
read -r ANSWER

if [ "$ANSWER" = "" ] || [ "$ANSWER" == 'y' ] || [ "$ANSWER" == "Y" ]; then
	echo "Installing Nvidia drivers"
	ubuntu-drivers install

	distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
		sudo apt update
		sudo apt-get install -y nvidia-docker2

		# Restart Docker.
		sudo systemctl restart docker

		echo "You should reboot now!!!"
else 
	echo "Skpping install...Thanks"
fi



