# LogCollectorScript

This repository contains a batch script (`collect.bat`) to collect and zip log files from multiple servers. Below are the sample configuration files (`servers.txt` and `filepaths.txt`) needed for the script to run.

## Configuration Files

### servers.txt

This file contains a list of server names or IP addresses from which logs will be collected. Each server should be listed on a new line.

```plaintext name=servers.txt
server1
server2
server3
```

### filepaths.txt

This file contains the source file paths and their corresponding destination paths relative to the destination root. Each entry should be in the format `SourcePath DestinationPath`, separated by a space.

```plaintext name=filepaths.txt
C:\Logs\app1\log.txt app1\log.txt
C:\Logs\app2\log.txt app2\log.txt
C:\Logs\app3\log.txt app3\log.txt
```

- `SourcePath`: The path of the log file on the server.
- `DestinationPath`: The relative path where the log file will be stored in the destination root.

## Usage

1. Update the `servers.txt` file with the list of servers.
2. Update the `filepaths.txt` file with the paths of the log files to be collected.
3. Run the `collect.bat` script.

The script will:
- Load the list of servers from `servers.txt`.
- Load the file paths from `filepaths.txt`.
- Copy the specified log files from each server to the local destination.
- Optionally, zip the collected logs using 7-Zip.

Ensure that the paths and configurations in the `collect.bat` script are correctly set before running the script.