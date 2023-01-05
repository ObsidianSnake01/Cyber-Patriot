#!/bin/bash

# Prompt the user for a list of users
echo "Enter a list of users, separated by space:"
read -a user_list

# Look at all the users on the system
all_users=`cut -d: -f1 /etc/passwd`

# Ask the user if they want to delete users who are not on the list
echo "Do you want to delete users who are not on the list? (y/n)"
read delete_users

if [ "$delete_users" == "y" ]; then
  # Iterate through all users on the system
  for user in $all_users; do
    # Check if the current user is not in the list provided by the user
    if ! [[ " ${user_list[@]} " =~ " ${user} " ]]; then
      # Delete the user
      userdel "$user"
      echo "Deleted user: $user"
    fi
  done
fi

# Check if user wants to add a new user
read -p "Do you want to add a new user? (y/n) " add_user

if [ "$add_user" == "y" ]; then
  # Prompt for username
  read -p "Enter username: " username

  # Check if group exists
  read -p "Enter group name: " group
  if grep -q "^$group:" /etc/group; then
    # Add user to existing group
    useradd -G $group $username
  else
    # Create new group and add user to it
    groupadd $group
    useradd -G $group $username
  fi
fi



# Update Linux
apt-get update
apt-get upgrade

# Set maximum password age
max_age=90
sed -i "s/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   $max_age/" /etc/login.defs


# Install ufw
apt-get update
apt-get install ufw

# Enable ufw
ufw enable

# Set default policy to deny incoming and allow outgoing
ufw default deny incoming
ufw default allow outgoing

# Allow SSH connections
ufw allow ssh

# Enable logging
ufw logging on

# Reload ufw to apply changes
ufw reload



# Set minimum password length
min_length=8
sed -i "s/^PASS_MIN_LEN.*/PASS_MIN_LEN    $min_length/" /etc/login.defs

# Set password aging for all users
chage --maxdays $max_age --mindays 1 --warndays 7 $(awk -F: '{print $1}' /etc/passwd)

# Set up automatic updates
apt-get install unattended-upgrades
echo 'APT::Periodic::Update-Package-Lists "1";' >> /etc/apt/apt.conf.d/10periodic
echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.d/10periodic


# Find all files in the home directory
find ~ -type f | while read file; do
  # Check if file is a photo, video, or song
  if file "$file" | grep -Eq "image|video|audio"; then
    # Check if file is not the screensaver
    if ! [ "$file" == "~/Screensaver" ]; then
      # Remove file
      rm "$file"
    fi
  fi
done

# List of suspicious file extensions
suspicious_extensions=(".exe" ".bat" ".vbs" ".scr" ".cmd" ".msi" ".pif" ".com" ".js" ".jse" ".wsf" ".wsh" ".pl" ".sh")

# Find all files in the home directory
find ~ -type f | while read file; do
  # Get file basename and extension
  filename=$(basename -- "$file")
  extension="${filename##*.}"
  # Check if file is not named cyber.sh and has a suspicious extension
  if ! [ "$filename" == "cyber.sh" ] && [[ " ${suspicious_extensions[@]} " =~ " $extension " ]]; then
    # Print suspicious file
    echo "$file"
  fi
done

# Prompt user to remove suspicious files
read -p "Do you want to remove the suspicious files? (y/n) " remove_files

if [ "$remove_files" == "y" ]; then
  # Find all files in the home directory
  find ~ -type f | while read file; do
    # Get file


echo "Done!"
