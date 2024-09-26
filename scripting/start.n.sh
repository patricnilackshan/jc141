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

# Create a sandbox for isolated execution
[ ! -d "$JC_DIRECTORY/native-docs" ] && mkdir -p "$JC_DIRECTORY/native-docs"
echo "Path of the isolated home is $JC_DIRECTORY/native-docs"

# Redirect terminal output if specified
[ $TERMINAL_OUTPUT = 0 ] && exec &> /dev/null

# Manage the extraction and mounting of dwarfs
[ $EXTRACT = 0 ] && dwarfs-mount || { dwarfs-extract && UNMOUNT=0; }

# Set cleanup trap
[ $UNMOUNT = 1 ] && trap jc141-cleanup EXIT INT SIGINT SIGTERM

# Define the root directory for game files
GAMEROOT="$PWD/files/game-root"

# Prepare command line for launching the game
CMD=(./"game.bin" "$@")

# Declare an array for running commands
declare -a RUN

# Check if gamescope is available and if it should be used
if command -v gamescope &>/dev/null && [ "$GAMESCOPE" == "1" ]; then
    RUN+=( gamescope-run_embedded )
fi

# Set isolation settings if specified
if [ "$ISOLATE" == "1" ]; then
    export ISOLATION_TYPE='native'
    RUN+=( bash 'actions.sh' bwrap-run_in_sandbox --chdir "$GAMEROOT" )
else
    cd "$GAMEROOT" || { echo "Failed to navigate to game root. Exiting."; exit 1; }
fi

# Execute the prepared command
RUN+=( "${CMD[@]}" )
"${RUN[@]}"