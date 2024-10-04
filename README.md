# `kubectl-mssql` Plugin

This is a custom `kubectl` plugin that allows you to interact with an MSSQL server running inside a Kubernetes cluster. It supports taking database backups, listing databases, listing backup files, and connecting to the SQL prompt.

## Features

- Take backups of a specified MSSQL database inside a Kubernetes pod.
- List all available databases inside the MSSQL instance.
- List all existing backups in the default backup directory.
- Interactively connect to the MSSQL server via the `sqlcmd` tool.

## Prerequisites

- `kubectl` installed on your local machine.
- Kubernetes cluster with an MSSQL server running in a pod.
- Correct namespace and label configuration for the MSSQL pod (`app=mssql`).
- You have the `sa` password for the MSSQL server.

## Installation

Save the script to a file called `kubectl-mssql` and place it in your `PATH` (e.g., `/usr/local/bin/`).

```bash
sudo mv kubectl-mssql /usr/local/bin/kubectl-mssql
sudo chmod +x /usr/local/bin/kubectl-mssql
```

## Usage

```bash
kubectl mssql <namespace> [--backup <database-name> [<backup-file>]] [--list-databases] [--list-backups]
```

### Parameters:

`<namespace>`: The Kubernetes namespace where the MSSQL pod is running. This is required for every command.

`--backup <database-name> [<backup-file>]`:

Initiates a backup of the specified database (<database-name>).
If <backup-file> is not provided, a default file path will be generated inside the pod, e.g., /var/opt/mssql/backups/.
The backup will be stored as a .bak file.

`--list-databases`:

Lists all databases present in the MSSQL instance running inside the pod.

`--list-backups`:

Lists all backup files stored in the default backup directory inside the pod (typically `/var/opt/mssql/backups`).

### Prompt for MSSQL Password:

After running any command, the script will prompt you to enter the MSSQL password for the sa (system administrator) user.

```bash
Enter MSSQL password:
```

### Examples

#### 1. Take a Backup of a Database

To take a backup of the MyDatabase database with an auto-generated backup file path:

```bash
kubectl mssql default --backup MyDatabase
```

##### Output:

```bash
Enter MSSQL password: ********
No backup file path provided. Generated backup file path: /var/opt/mssql/backups/MyDatabase_backup_20241004123456.bak
Taking backup of the database 'MyDatabase' to /var/opt/mssql/backups/MyDatabase_backup_20241004123456.bak...
Backup completed successfully!
Backup file is stored at: /var/opt/mssql/backups/MyDatabase_backup_20241004123456.bak
```

To provide a specific backup file path:

```bash
kubectl mssql default --backup MyDatabase /var/opt/mssql/backups/custom_backup.bak
```

##### Output:

```bash
Enter MSSQL password: ********
Taking backup of the database 'MyDatabase' to /var/opt/mssql/backups/custom_backup.bak...
Backup completed successfully!
Backup file is stored at: /var/opt/mssql/backups/custom_backup.bak
```

#### 2. List All Databases

To list all databases available in the MSSQL instance:

```bash
kubectl mssql default --list-databases
```

##### Output:

```bash
Copy code
Enter MSSQL password: ********
Listing all databases...
name
--------------------------------
master
tempdb
model
msdb
MyDatabase
```

### 3. List All Backup Files

To list all existing backups stored in the default backup directory (`/var/opt/mssql/backups`):

```bash
kubectl mssql default --list-backups
```

##### Output:

```bash
Enter MSSQL password: ********
Listing all backup files in /var/opt/mssql/backups...
-rw-r--r-- 1 root root 12M Oct 04 12:45 MyDatabase_backup_20241004123456.bak
-rw-r--r-- 1 root root 15M Oct 03 14:20 custom_backup.bak
```

### 4. Connect to the MSSQL Prompt

To open an interactive SQL prompt using sqlcmd:

```bash
kubectl mssql default
```

##### Output:

```bash
Enter MSSQL password: ********
Connecting to MSSQL pod: mssql-pod-12345 in namespace: default
1>
```

You can now interact with the MSSQL server as you would in a standard sqlcmd session.


### Error Handling


**"Invalid zero-length device name":** Ensure that the backup file path is valid and not empty.
**"No MSSQL pod found":** Ensure that the MSSQL pod exists in the specified namespace and that it has the correct label (app=mssql).


### License

This script is open-source and licensed under MIT. You can modify and distribute it as per your needs.

---


