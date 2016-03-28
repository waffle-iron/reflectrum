#!/bin/bash

## Usage:
## sudo bash config_pi.sh [debug_flags]
# where [debug_flags] is a binary number that maps to a set of build steps to run.
# "2#1" (binary 1) means run step, "2#0" means skip step.
# ex: "sudo bash config_pi.sh 2#0100001" will run the 1st and 6th build step.

chromium_flag=2#1                #       1   Install Chromium
gen_ssh_flag=2#10                #      10   Generate SSH Key
add_ssh_to_github_flag=2#100     #     100   Add SSH key to github
bluetooth_keyboard_flag=2#1000   #    1000   Set up bluetooth keyboard
clone_source_flag=2#10000        #   10000   Clone reflectrum source
install_npm_flag=2#100000        #  100000   Install npm and jspm
install_packages_flag=2#1000000  # 1000000   Install javascript packages

## default flag - run all steps
#input_flag=${1:-2#1111111}
echo $input_flag
exit 1

if [[ $(( ${input_flag} & ${chromium_flag} )) != 0 ]]; then
  ## Install Chromium
  echo "Install Chromium"
  # https://www.raspberrypi.org/forums/viewtopic.php?t=121195
  wget https://dl.dropboxusercontent.com/u/87113035/chromium-browser-l10n_48.0.2564.82-0ubuntu0.15.04.1.1193_all.deb
  wget https://dl.dropboxusercontent.com/u/87113035/chromium-browser_48.0.2564.82-0ubuntu0.15.04.1.1193_armhf.deb
  wget https://dl.dropboxusercontent.com/u/87113035/chromium-codecs-ffmpeg-extra_48.0.2564.82-0ubuntu0.15.04.1.1193_armhf.deb
  sudo dpkg -i chromium-codecs-ffmpeg-extra_48.0.2564.82-0ubuntu0.15.04.1.1193_armhf.deb
  sudo dpkg -i chromium-browser-l10n_48.0.2564.82-0ubuntu0.15.04.1.1193_all.deb chromium-browser_48.0.2564.82-0ubuntu0.15.04.1.1193_armhf.deb

fi

if [[ $(( ${input_flag} & ${gen_ssh_flag} )) != 0 ]]; then
  ## Generate SSH Key
  echo "Generate SSH Key"
  # https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#platform-linux
  ssh-keygen -q -t rsa -b 4096 -C "chris@gervang.com"
  eval "$(ssh-agent -s)"
  ssh-add ${HOME}/.ssh/id_rsa
fi

if [[ $(( ${input_flag} & ${add_ssh_to_github_flag} )) != 0 ]]; then
  ## Add SSH key to github
  echo "Add SSH key to github"
  # https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/#platform-linux
  sudo apt-get -y install xclip
  xclip -sel clip < ~/.ssh/id_rsa.pub
fi

if [[ $(( ${input_flag} & ${bluetooth_keyboard_flag} )) ]] ; then
  ## Set up bluetooth keyboard
  echo "Set up bluetooth keyboard"
  # Install bluetooth GUI
  sudo apt-get -y install blueman

fi

if [[ $(( ${input_flag} & ${clone_source_flag} )) ]] ; then
  ## Clone Source
  echo "Clone reflectrum source"
  read -p "set_color yellow; echo press enter once ssh is set in github;"
  git clone git@github.com:chrisgervang/Reflectrum.git ${HOME}/code/Reflectrum
fi

if [[ $(( ${input_flag} & ${install_npm_flag} )) ]] ; then
  ## Install npm
  echo "Install npm and jspm"
  sudo apt-get -y install npm
  npm install jspm -g
fi

if [[ $(( ${input_flag} & ${install_packages_flag} )) ]] ; then
  ## Install javascript packages
  echo "Install javascript packages"
  npm install ${HOME}/code/Reflectrum
  jspm install ${HOME}/code/Reflectrum
fi