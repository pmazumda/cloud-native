#!/bin/bash

###################################################################################
## Name: kubectl-dbops plugin
## Author: Pinak Mazumdar
## Description: This is a plugin which can be used to 
##
###################################################################################
# Check if kubectl is installed
if ! command -v kubectl &> /dev/null
then
    echo "kubectl not found. Please install kubectl."
    exit 1
fi

# optional argument handling
if [[ "$1" == "version" ]]
then
    echo "kubectl dbops plugin version: 1.0.0"
    exit 0
fi


# Function to display usage
usage() {
    echo ""
    echo "Usage: kubectl dbops <namespace> [--backup <database-name> [<backup-file>]] [--list-databases] [--list-backups]"
    echo ""
    echo "Parameters:"
    echo "  <namespace>                   The Kubernetes namespace where the MSSQL pod is running."
    echo ""
    echo "Commands:"
    echo "  --backup <database-name> [<backup-file>]"
    echo "                                  Take a backup of the specified database."
    echo "                                  If no backup file is provided, it will generate a default path."
    echo ""
    echo "  --list-databases              List all available databases in the MSSQL instance."
    echo ""
    echo "  --list-backups                List all backup files in the default backup directory."
    echo ""
    echo "Examples:"
    echo "  kubectl dbops default --backup MyDatabase"
    echo "  kubectl dbops default --backup MyDatabase /var/opt/mssql/backups/custom_backup.bak"
    echo "  kubectl dbops default --list-databases"
    echo "  kubectl dbops default --list-backups"
    exit 1
}

# Ensure the namespace is passed as an argument
if [[ -z "$1" || $1 == "-h" || $1 == "--help"  ]]; then
    usage
fi

NAMESPACE=$1
LABEL_SELECTOR="app=mssql"
BACKUP_MODE=false
LIST_DATABASES=false
LIST_BACKUPS=false
DB_NAME=""
BACKUP_FILE=""
DEFAULT_BACKUP_DIR="/var/backups"

# Check for backup flag and backup file path
if [[ "$2" == "--backup" ]]; then
    BACKUP_MODE=true
    if [ -z "$3" ]; then
        echo "Error: Please specify the database name and backup file path."
        usage
    else
        DB_NAME="$3"
        BACKUP_FILE="$4" # Optional backup file name, can be empty
    fi
elif [[ "$2" == "--list-databases" ]]; then
    LIST_DATABASES=true
elif [[ "$2" == "--list-backups" ]]; then
    LIST_BACKUPS=true
fi

# Prompt for MSSQL password
read -sp "Enter MSSQL password: " MSSQL_PASSWORD
echo

# Function to list all databases
list_databases() {
    echo "Listing all databases..."

    # Query to list databases
    LIST_CMD="SELECT name FROM sys.databases;"

    # Run the list databases command inside the MSSQL pod
    kubectl exec -it $POD_NAME -n $NAMESPACE -- /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$MSSQL_PASSWORD" -Q "$LIST_CMD"
}

# Function to generate a backup file path if none is provided
generate_backup_file() {
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    BACKUP_FILE="$DEFAULT_BACKUP_DIR/${DB_NAME}_backup_$TIMESTAMP.bak"
}


# Function to list all backup files
list_backups() {
    echo "Listing all backup files in $DEFAULT_BACKUP_DIR..."

    # Command to list backup files in the default backup directory
    LIST_BACKUPS_CMD="ls -lh $DEFAULT_BACKUP_DIR"

    # Run the list backups command inside the MSSQL pod
    kubectl exec -it $POD_NAME -n $NAMESPACE -- bash -c "$LIST_BACKUPS_CMD"
}


# Find the MSSQL pod in the provided namespace
POD_NAME=$(kubectl get pod -n $NAMESPACE -l $LABEL_SELECTOR -o jsonpath="{.items[0].metadata.name}")

if [[ -z "$POD_NAME" ]]; then
    echo "No MSSQL pod found in namespace $NAMESPACE with label $LABEL_SELECTOR"
    exit 1
fi

# Function to take database backup
take_backup() {
    if [ -z "$BACKUP_FILE" ]; then
        generate_backup_file
        echo "No backup file path provided. Generated backup file path: $BACKUP_FILE"
    fi
    
    echo "Taking backup of the database '$DB_NAME' to '$BACKUP_FILE'..."

# Verify if BACKUP_FILE is non-empty and valid
    if [ -z "$BACKUP_FILE" ]; then
        echo "Error: Backup file path is invalid or empty."
        exit 1
    fi

# Create the backup directory inside the pod if it doesn't exist
    kubectl exec -it $POD_NAME -n $NAMESPACE -- bash -c "mkdir -p $(dirname "$BACKUP_FILE")"

# Create backup command
    BACKUP_CMD="BACKUP DATABASE [$DB_NAME] TO DISK = N'$BACKUP_FILE' WITH NOFORMAT, NOINIT, NAME = '$DB_NAME-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10;"

    # Run the backup command inside the MSSQL pod
    kubectl exec -it $POD_NAME -n $NAMESPACE -- /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$MSSQL_PASSWORD" -Q "$BACKUP_CMD"
    
    if [ $? -eq 0 ]; then
        echo "Backup completed successfully!"
        echo "Backup file is stored at: $BACKUP_FILE"
    else
        echo "Backup failed."
    fi
}

# Logic for backup, list databases, or connecting to SQL prompt
if [ "$BACKUP_MODE" = true ]; then
    take_backup
elif [ "$LIST_DATABASES" = true ]; then
    list_databases
elif [ "$LIST_BACKUPS" = true ]; then
    list_backups
else
    echo "Connecting to MSSQL pod: $POD_NAME in namespace: $NAMESPACE"

    # Start SQLCMD inside the pod
    kubectl exec -it $POD_NAME -n $NAMESPACE -- /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$MSSQL_PASSWORD"
fi