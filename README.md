# bash_history_improved
This is my configuration so that bash history actually works! Infinite number of line storage, test to see everything is set up correctly, does not occasionally delete back to 500 lines. Fuzzy search integration (option to search all history ever, not just what you have in your terminal at the moment).

Systems that this works on:

```
Linux 5.10.0-14-amd64 #1 SMP Debian 5.10.113-1 (2022-04-29) x86_64 GNU/Linux
Linux casta 5.10.133 #1 SMP PREEMPT Sat Nov 19 21:06:46 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux
```
You can check your system by running the command

```
uname -a
```

Underlying this is a simple script to automatically backup your Bash history to a file before shutdown and restore it when you start up again. Again, the script is intended for use on Debian-based Linux distributions. Might work fine on ubuntu or arch / similiar, but has not been tested.

## Requirements

- Bash shell
- Systemd

You can check if a Linux system is using `systemd` by running the following command in the terminal:

```
systemctl
```

If `systemd` is installed and running, you should see a list of units and their current status. If the command is not found, it may indicate that `systemd` is not installed or not being used on the system.


## Installation

1. Download the `bash_history_backup.sh` and `backup_history_every_5_minutes.sh` file and place them in `/usr/local/bin/`:

```
sudo curl https://raw.githubusercontent.com/morganrivers/bash_history_improved/main/bash_history_backup.sh -o /usr/local/bin/bash_history_backup.sh
sudo curl https://raw.githubusercontent.com/morganrivers/bash_history_improved/main/backup_history_every_5_minutes.sh -o /usr/local/bin/backup_history_every_5_minutes.sh
sudo curl https://raw.githubusercontent.com/morganrivers/bash_history_improved/main/test_history_functionality.sh -o /usr/local/bin/test_history_functionality.sh
sudo chmod +x /usr/local/bin/bash_history_backup.sh
sudo chmod +x /usr/local/bin/backup_history_every_5_minutes.sh
sudo chmod +x /usr/local/bin/test_history_functionality.sh
```

2. I suggest backing up history at both startup and shutdown. To do this, create a Systemd service file named `bash_history_backup.service` in `/etc/systemd/system/` with the content from
bash_history_backup.service. You can use a command line text editor such as `nano` or `vim` to create the service file. Here, I'll use `nano`.

```bash
sudo nano /etc/systemd/system/bash_history_backup.service
```

3. Paste the following content into the opened file:

Note that you need to replace `YourUserName` with your actual username!

```ini
[Unit]
Description=Bash History Backup

[Service]
ExecStart=/usr/local/bin/bash_history_backup.sh
ExecStop=/usr/local/bin/bash_history_backup.sh
User=YourUserName

[Install]
WantedBy=multi-user.target
```

This service configuration will start the bash_history_backup.sh script at system boot and execute it again at system shutdown.

4. Press `CTRL+O` to write out the file. Confirm the filename by pressing `Enter`. Press `CTRL+X` to exit the text editor.



5. Enable and start the `bash_history_backup` service:

```
sudo systemctl enable bash_history_backup.service
sudo systemctl start bash_history_backup.service
```

6. Add to end of your bashrc:

```
export HISTFILESIZE=
export HISTSIZE=
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND}"
bash_history_backup.sh restore
```

7. finally, in ~, create an empty .bash_history_backup file:

```
touch ~/.bash_history_backup
```

8. You can now run the following script to let crontab backs up the history every 5 minutes. Helps prevent issues with unexpected shutdown.
```
backup_history_every_5_minutes.sh
```
This should print out `cron job added`.
I suggest also running `crontab -e` to ensure the crontab has the following line in it:
```
*/5 * * * * /usr/local/bin/bash_history_backup.sh backup
```
and then save the file.


## Testing

After setting this up, you can test it works with this script (all tests should pass): 

```
test_history_functionality.sh
```

## Usage

The `bash_history_backup.sh` script has two modes: `backup` and `restore`.

To backup your Bash history, run:

```
sudo bash_history_backup.sh backup
```

To restore your Bash history, run:

```
sudo bash_history_backup.sh restore
```

... but actually both do the same thing :) sorry if that's confusing ...
They're always looking for the longest of the backup or the bash history and rewrite the shorter one with the longer one. 


## Testing in a docker container

You can also check it works in a docker container named debian-bash-history (note: won't do the systemd things):

```
sudo curl https://raw.githubusercontent.com/morganrivers/bash_history_improved/main/bash_history_backup.sh > debian-bash-history
sudo docker build -t debian-bash-history:latest -f debian-bash-history .
sudo docker run -it debian-bash-history
```
then in the container
```
test_history_functionality.sh
```

## Optional Additional Configuration with fuzzy search package


If you have fuzzy search installed, you can add this to your bashrc:

```
function search_all_history(){
    history -a
    result=$(tac ~/.bash_history | perl -ne '$seen{$_}++ and next or print' | fzf --no-sort --exact)
    # tac: reverse order of cat! (displays the file)
    # perl -ne '$seen{$_}++ and next or print': remove duplicates
    #   -ne: This tells perl to read the input line by line and apply the script provided to each line.
    #   $seen{$_}++: This increments the value in the seen hash for the key $_ (which represents the current line). If the line has been seen before, this value will be greater than 1.
    #   and next or print: This is a conditional statement. If the line has been seen before ($seen{$_}++ is true), it moves to the next line (next). If the line hasn't been seen before, it prints the line (print).
    # grep -v '^#[0-9]\+' : include only the lines that don't start with #[number]
    # fzf --no-sort --exact: nice interactive fuzzy search interface of results
    echo $result
    eval $result
    history -s $result
}

bind '"\C-u": "search_all_history\n"'
```

That way, control+u will search all the bash history, not just the history in the terminal which you have open at the time (this is what you typically get with "history" command or with control+r by default in fzf).

## Limitations
If the system shuts down unexpectedly (e.g. power loss), the script will not be able to backup your Bash history since before the backup was run with crontab, and so the restored history file may not include commands typed in the last minute or two (up to 5 minutes).

Also as you can see, it's a bit hacky. It probably only works on debian, ubuntu, and maybe arch. But it has been tested in Debian and Ubunu. Let me know if it works in these other operating systems!

## Conclusion

With this simple script and Systemd service file, you can ensure that your Bash history is automatically backed up and restored on startup, helping you keep track of all the commands you've typed on your Linux system.

(not sure what the convention is for attribution these days, but most boilerplate code (obviously) written by gpt4)
