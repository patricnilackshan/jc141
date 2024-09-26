#!/usr/bin/env bash
# Navigate to the directory of the script
cd "$(dirname "$(readlink -f "$0")")" || { echo "Failed to navigate to script directory. Exiting."; exit 1; }

# Display a support message
cat << EOF
Support can be provided on our Matrix channel.

Pain heals, chicks dig scars; Glory lasts forever!
EOF

# Source helper functions
source "$PWD/actions.sh"

# Redirect terminal output if specified
[ $TERMINAL_OUTPUT = 0 ] && exec &> /dev/null

# Manage the extraction and mounting of dwarfs
[ $EXTRACT = 0 ] && dwarfs-mount || { dwarfs-extract && UNMOUNT=0; }

# Set cleanup trap
[ $UNMOUNT = 1 ] && trap jc141-cleanup EXIT INT SIGINT SIGTERM

# Configure Wine environment
export WINEPREFIX="$PWD/files/prefix"
echo "Using Wine prefix located at: $WINEPREFIX"
export WINEDLLOVERRIDES="winemenubuilder.exe=d;mshtml=d;nvapi,nvapi64=n"
export WINE_LARGE_ADDRESS_AWARE=1
export DXVK_ENABLE_NVAPI=1

# Initialize Wine prefix if it doesn't exist
if [ ! -d "$WINEPREFIX" ]; then
    wine-initiate_prefix || { echo "Failed to initiate Wine prefix. Exiting."; exit 1; }
fi

# Setup external Vulkan translation if the log file is not present
if [ ! -f "$WINEPREFIX/vulkan.log" ]; then
    wine-setup_external_vulkan || { echo "Failed to setup external Vulkan. Exiting."; exit 1; }
fi

# Define the root directory for game files
GAMEROOT="$PWD/files/game-root"

# Prepare command line for launching the game
CMD=("$SYSWINE" "game.exe" "$@")

# Declare an array for running commands
declare -a RUN

# Check if gamescope is available and if it should be used
if command -v gamescope &>/dev/null && [ "$GAMESCOPE" == "1" ]; then
    RUN+=( gamescope-run_embedded )
fi

# Set isolation settings if specified
if [ "$ISOLATE" == "1" ]; then
    export ISOLATION_TYPE='wine'
    RUN+=( bash 'actions.sh' bwrap-run_in_sandbox --chdir "$GAMEROOT" )
else
    cd "$GAMEROOT" || { echo "Failed to navigate to game root. Exiting."; exit 1; }
fi

# Execute the prepared command
RUN+=( "${CMD[@]}" )
"${RUN[@]}"