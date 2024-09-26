### The Post Setup Page

Here we will list information about the possible commands and configurations you can do.

<br>

#### The global and local configuration

At **_~/.jc141rc_** (Your Home directory. Enable seeing hidden files. If it does not exist it will be generated when you first start a game) you have the global configuration.

Any of the settings here will generally be used by the start scripts, unless they get overriden by the local configuration.

The **_script_default_settings_** located next to each start script of a release includes the same options as the above mentioned. But they are most likely all disabled with a # before them. Removing it will enable the value used regardless of the global configuration.


Let's go through some of the more relevant options you have in these config files.


```
Can choose to opt out of the mounting mechanic and have all games extract at first run.

EXTRACT=0 (1 = enable)

---

Can choose what the start scripts find when they look for wine. 
This could be a path to a custom wine binary or the name of a different package like Proton.

SYSWINE="$(command -v wine)"

---

Force games into using an isolated sandbox.

ISOLATE=1 (0 = disable)

---

Block network access to the game. Does not work if Isolation is disabled.

BLOCK_NET=1 (0 = disable)

---

Path of the wine prefix. If you leave isolation enabled then it's also the "$HOME" recognized by all native games.

If the start script is called start.e-w.sh then the wine prefix is located in files/prefix instead.

JC_DIRECTORY="$HOME/Games/jc141"

---

Enable or disable gamescope. If you didn't install it then the value is irrelevant.

GAMESCOPE=1 (0 = disable)

---

If you don't write your own screen resolution, using gamescope will result in games picking up a 720 resolution.

GAMESCOPE_SCREEN_WIDTH=1920 # example
GAMESCOPE_SCREEN_HEIGHT=1080 # example
```

<br>

#### The actions.sh file

This file includes a lot of commands which can be used by the user.


```
bash actions.sh COMMAND

Available Commands

dwarfs-extract

extract game files to files/game-root
 
if files/game-root already exists and it is not empty then nothing will run.

---

dwarfs-unmount 

unmount the dwarfs image from files/game-root

---

dwarfs-mount

mount the dwarfs image to files/game-root
any files added while mounted will be saved to the files/overlay-storage and will override the base game files.

this is mostly useful for mods or updates. if updates are big then it might be more efficient to compress files again.

---

dwarfs-compress
 
compress the contents of files/game-root to files/game-root.dwarfs with the settings included in actions.sh

command won't run if files/game-root.dwarfs exists already.

---

dwarfs-check_integrity

check for any errors of the image detected by dwarfs. can also use the torrent client rechecking.
```