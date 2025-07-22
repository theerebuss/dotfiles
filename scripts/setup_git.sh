#!/bin/bash

password=""
echo "Please provide your Git commit info"
read -p "Full name: " fullName
read -p "Email: " email
read -p "Key password: " -s password
echo ""

echo "Setting up VSCode as the git editor"
git config --global core.editor "code -r --wait"

echo "Setting up global Git identity"

git config --global user.name $fullName
git config --global user.email $email

echo "Setting up SSH key"

key_name="github_ed25519"
ssh-keygen -t ed25519 -C $email -f ~/.ssh/$key_name -N $password
chmod 600 ~/.ssh/$key_name
chmod 644 ~/.ssh/$key_name.pub

# Copy .pub and open GitHub
ssh_key=$(cat ~/.ssh/$key_name.pub)
# # WSL
# echo $ssh_key | clip.exe 2>/dev/null
# # Mac
# echo $ssh_key | pbcoby 2>/dev/null
# TODO: Automate this step

github_new_ssh_url="https://github.com/settings/ssh/new"
echo "Please paste the public key to your GitHub account's SSH keys"
echo $ssh_key

# WSL
explorer.exe $github_new_ssh_url 2>/dev/null
# Mac
open $github_new_ssh_url 2>/dev/null

read -p "Press any key to resume..."

echo "Setting up SSH signing key"

signing_key_name="github_signing_ed25519"
ssh-keygen -t ed25519 -C $email -f ~/.ssh/$signing_key_name -N $password
chmod 600 ~/.ssh/$signing_key_name
chmod 644 ~/.ssh/$signing_key_name.pub

# Copy .pub and open GitHub
signing_key=$(cat ~/.ssh/$key_name.pub)
# # WSL
# echo $signing_key | clip.exe 2>/dev/null
# # Mac
# echo $signing_key | pbcoby 2>/dev/null
# TODO: Automate this step

echo "Please paste it to your GitHub account's SSH keys with the 'Signing' key type."
echo $signing_key
# WSL
explorer.exe https://github.com/settings/ssh/new 2>/dev/null
# Mac
open https://github.com/settings/ssh/new 2>/dev/null

read -p "Press any key to resume..."

awk '{ print $3 " " $1 " " $2 }' ~/.ssh/$signing_key_name.pub >>~/.ssh/allowed_signers

git config --global gpg.format ssh
git config --global user.signingkey "$(cat ~/.ssh/$signing_key_name.pub)"
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers

# Create SSH config file
touch ~/.ssh/config
echo "Host *" >>~/.ssh/config
echo "    IdentityFile ~/.ssh/$key_name" >>~/.ssh/config

# Add SSH key to agent
eval $(ssh-agent)
ssh-add ~/.ssh/$key_name
ssh-add ~/.ssh/$signing_key_name
