# MariaDB Reinstallation and Configuration Script

This script automates the process of removing MariaDB, reinstalling it, creating and configuring databases, and restoring them from SQL files.

## Overview

1. **Remove MariaDB**: Uninstalls MariaDB using Homebrew.
2. **Reinstall MariaDB**: Installs the latest version of MariaDB.
3. **Configure MariaDB**: Sets up the data directory, changes the root password, and starts the MariaDB service.
4. **Database and User Setup**: Creates databases and users, grants privileges, and restores SQL files.

## Prerequisites

- **Homebrew**: Ensure Homebrew is installed for package management.
- **Bash**: The script requires Bash 3 or higher. For Bash 4 features, upgrade if necessary.
- **MariaDB**: The script will manage MariaDB installation.

## Usage Instructions

### 1. Save the Script

Save the provided script to a file, e.g., `setup_mariadb.sh`.

### 2. Set Execution Permission

Make the script executable by running:

```bash
chmod +x setup_mariadb.sh
