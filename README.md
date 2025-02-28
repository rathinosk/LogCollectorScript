# LogCollectorScript

This repository contains a batch script (`collect.bat`) to collect and zip log files from multiple servers. Below are the sample configuration files (`servers.txt` and `filepaths.txt`) needed for the script to run.

## Configuration Files

### servers.txt

This file contains a list of server names or IP addresses from which logs will be collected. Each server should be listed on a new line. Lines starting with `#` are considered comments and will be ignored. Blank lines will also be skipped.

```plaintext name=servers.txt
# servers.txt - List of Servers
# 
# This file contains a list of servers to collect logs from.
# Each server should be specified on a new line.
# Lines starting with '#' are considered comments and will be ignored.
# Blank lines will also be skipped.
# 
# Example:
# 
# server1.example.com
# server2.example.com
# server3.example.com
# 
# Note: Ensure there are no leading or trailing spaces on each line.

# Add your server entries below

server1.example.com
# server2.example.com
server3.example.com
```

### filepaths.txt

This file contains the source file paths and their corresponding destination paths relative to the destination root. Each entry should be in the format `SourcePath DestinationPath`, separated by a space. Lines starting with `#` are considered comments and will be ignored. Blank lines will also be skipped.

```plaintext name=filepaths.txt
# filepaths.txt - List of File Paths
# 
# This file contains source and destination file paths for log collection.
# Each line should specify a source path and a destination path, separated by a space.
# Lines starting with '#' are considered comments and will be ignored.
# Blank lines will also be skipped.
# 
# Example:
# 
# source\path\to\logs relative\destination\path
# source\path\to\more\logs another\relative\destination\path
# 
# Note: Ensure there are no leading or trailing spaces on each line.
# All destination paths will be relative to the destination path specified in the collect.bat.

# Add your file path entries below

C:\Logs\app1\logs app1
C:\Logs\app2\log.txt app2\log.txt
C:\Logs\app3\logs app3
```

- `SourcePath`: The path of the log file on the server.
- `DestinationPath`: The relative path where the log file will be stored in the destination root.

## Usage

1. Update the `servers.txt` file with the list of servers.
2. Update the `filepaths.txt` file with the paths of the log files to be collected.
3. Run the `collect.bat` script.

The script does the following:  
- Configures paths and log age.  
- Loads the list of servers from `servers.txt`.  
- Loads the file paths from `filepaths.txt`.  
- Displays the list of servers and file paths.  
- Copies log files from the servers to a local destination using robocopy.  
- Optionally, zips the collected logs using 7-Zip, with the current date and time in the format `YYYY-MM-DD_HH-MM` included in the ZIP file names.  

Ensure that the paths and configurations in the `collect.bat` script are correctly set before running the script.