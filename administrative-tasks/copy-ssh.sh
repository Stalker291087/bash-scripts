#!/bin/bash

# Set the username and the path to the SSH key on the local machine
username=<your_username>
ssh_key_path=<path_to_ssh_key>

# Set the list of remote servers
servers=(
    server1.example.com
    server2.example.com
    server3.example.com
)

# Loop through the servers and copy the SSH key
for server in "${servers[@]}"
do
    echo "Copying SSH key to $server..."
    ssh-copy-id -i $ssh_key_path $username@$server
done
