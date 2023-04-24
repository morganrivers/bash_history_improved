# bash_history_improved
This is my configuration so that bash history actually works! Infinite number of line storage, test to see everything is set up correctly, does not occasionally delete back to 500 lines. Fuzzy search integration (option to search all history ever, not just what you have in your terminal at the moment).

My system that this works on:
Linux 5.10.0-14-amd64 #1 SMP Debian 5.10.113-1 (2022-04-29) x86_64 GNU/Linux


Underlying this is a simple script to automatically backup your Bash history to a file before shutdown and restore it when you start up again. Again, the script is intended for use on Debian-based Linux distributions.

## Requirements

- Bash shell
- Systemd

You can check if a Linux system is using `systemd` by running the following command in the terminal:

```
systemctl
```

If `systemd` is installed and running, you should see a list of units and their current status. If the command is not found, it may indicate that `systemd` is not installed or not being used on the system.


## Installation

1. Download the `bash_history_backup.sh` file and place it in `/usr/local/bin/`:

```
sudo curl https://raw.githubusercontent.com/morganrivers/repo/main/bash_history_backup.sh -o /usr/local/bin/bash_history_backup.sh
sudo chmod +x /usr/local/bin/bash_history_backup.sh
```

2. Create a Systemd service file named `bash_history_backup.service` in `/etc/systemd/system/` with the content from
bash_history_backup.service

3. Enable and start the `bash_history_backup` service:

```
sudo systemctl enable bash_history_backup.service
sudo systemctl start bash_history_backup.service
```
4. Add to end of your bashrc:

```
export HISTFILESIZE=
export HISTSIZE=
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND}"
bash_history_backup.sh restore
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

## Testing

After setting this up, you can test it works with this script (all tests should pass): 

```
./test_history_functionality.sh
```

## Optional Additional Configuration with fuzzy search package
If you have fuzzy search installed, you can add this to your bashrc:

```
function allhistfun(){
    result=`echo $(tac ~/.bash_history| grep -v '^#[0-9]\+' | fzf --no-sort --exact )`
    echo $result
    eval $result
    history -s $result
}

bind '"\C-u": "allhistfun\n"'
```

That way, control+u will search all the bash history, not just the history in the terminal which you have open at the time (this is what you typically get with "history" command or with control+r by default in fzf).

## Limitations

The script only backs up your Bash history file, so any customizations to your history settings or commands typed in the current session will not be saved.

Additionally, if the system shuts down unexpectedly (e.g. power loss), the script will not be able to backup your Bash history and the restored history file may not include commands typed in the last session.

## Conclusion

With this simple script and Systemd service file, you can ensure that your Bash history is automatically backed up and restored on startup, helping you keep track of all the commands you've typed on your Linux system.
