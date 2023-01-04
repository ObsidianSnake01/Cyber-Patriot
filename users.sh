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
