#!/bin/bash

# Check if bash version is at least 4.0 for associative arrays
if [[ "${BASH_VERSION%%.*}" -lt 4 ]]; then
  echo "This script requires Bash 4.0 or higher."
  # Simulating associative array handling for Bash 3
  databases=("irving_frias")
  user_passwords=("irving_frias")
  sql_files=(
    "/irving-frias/irving_frias.sql"
  )
fi

# Uninstall MariaDB
echo "Removing MariaDB..."
brew remove mariadb

# Wait until MariaDB is removed
while brew list | grep -q "mariadb"; do
  echo "Waiting for MariaDB to be removed..."
  sleep 2
done

# Remove the MySQL data directory
echo "Removing MySQL data directory..."
rm -rf /usr/local/var/mysql

# Install MariaDB
echo "Installing MariaDB..."
brew install mariadb

# Wait until MariaDB is installed
while ! brew list | grep -q "mariadb"; do
  echo "Waiting for MariaDB to be installed..."
  sleep 2
done

# Start MariaDB service
echo "Starting MariaDB service..."
brew services start mariadb

# Function to check if MariaDB is running
check_mariadb() {
  mysqladmin ping -h localhost -u root --password=12341234 &>/dev/null
}

# Wait for MariaDB to start with progress indication
echo "Waiting for MariaDB to start..."
while ! check_mariadb; do
  echo -n "."
  sleep 2
done
echo -e "\nMariaDB is up and running!"

# Access MariaDB and change the root password
echo "Changing root password..."
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '12341234'; FLUSH PRIVILEGES;"

# Only use sudo where necessary
echo "Creating MySQL folder with correct permissions..."
if [ ! -d "/usr/local/var/mysql" ]; then
  sudo mkdir -p /usr/local/var/mysql
fi

sudo chown -R $(whoami) /usr/local/var/mysql

echo "Reinitializing MariaDB Data Directory..."
mariadb-install-db --datadir=/usr/local/var/mysql --user=$(whoami)

echo "Restarting MariaDB service..."
brew services restart mariadb

# Wait for MariaDB to restart with progress indication
echo "Waiting for MariaDB to restart..."
while ! check_mariadb; do
  echo -n "."
  sleep 2
done
echo -e "\nMariaDB has restarted successfully!"

# Function to create a database and user
create_db_user() {
  db=$1
  user_password=$2
  echo "Creating database and user for $db..."
  mysql -e "CREATE DATABASE $db DEFAULT CHARACTER SET utf8;"
  mysql -e "GRANT ALL PRIVILEGES ON $db.* TO '$db'@'localhost' IDENTIFIED BY '$user_password';"
}

# Function to restore a SQL file
restore_sql() {
  db=$1
  user_password=$2
  sql_file=$3
  if [ -f "$sql_file" ]; then
    echo "Restoring SQL file for $db from $sql_file..."
    mysql -u$db -p${user_password} $db < "$sql_file"
  else
    echo "SQL file $sql_file does not exist. Skipping restoration for $db."
  fi
}

# Check if databases array is not empty
if [ ${#databases[@]} -eq 0 ]; then
  echo "No databases defined. Skipping database creation and user setup."
else
  # Create databases and users in parallel
  for i in "${!databases[@]}"; do
    create_db_user "${databases[$i]}" "${user_passwords[$i]}" &
  done
  wait
fi

# Check if sql_files array is not empty
if [ ${#sql_files[@]} -eq 0 ]; then
  echo "No SQL files defined. Skipping database restoration."
else
  # Restore SQL files in parallel
  for i in "${!sql_files[@]}"; do
    restore_sql "${databases[$i]}" "${user_passwords[$i]}" "${sql_files[$i]}" &
  done
  wait
fi

# Display finish message
echo "MariaDB reinstallation complete. Root password set, databases created, users granted privileges, and databases restored."
