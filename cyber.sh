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

echo "Done!"


# Update Linux
apt-get update
apt-get upgrade

# Set maximum password age
max_age=90
sed -i "s/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   $max_age/" /etc/login.defs

# Set minimum password length
min_length=8
sed -i "s/^PASS_MIN_LEN.*/PASS_MIN_LEN    $min_length/" /etc/login.defs

# Set password aging for all users
chage --maxdays $max_age --mindays 1 --warndays 7 $(awk -F: '{print $1}' /etc/passwd)

# Set up automatic updates
apt-get install unattended-upgrades
echo 'APT::Periodic::Update-Package-Lists "1";' >> /etc/apt/apt.conf.d/10periodic
echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.d/10periodic
