#!/usr/bin/env bash

# Ensure script is not run as root
[ "$EUID" -eq 0 ] && { echo "This script should not be run as root."; exit 1; }

# Define runtime dependencies and check their availability
declare -A DEPENDENCIES=(
    ['dwarfs']='dwarfs'
    ['bwrap']='bubblewrap'
    ['fuse-overlayfs']='fuse-overlayfs'
)

for dep_bin in "${!DEPENDENCIES[@]}"; do
    if ! command -v "$dep_bin" &> /dev/null; then
        echo "Error: ${DEPENDENCIES[$dep_bin]} is not installed or not executable."
        exit 1
    fi
done

# Set up common variables
GAME_ROOT="$PWD/files/game-root"

# Function to mount game from dwarfs file
dwarfs-mount() {
	dwarfs-unmount &> /dev/null

	HWRAMTOTAL="$(grep MemTotal /proc/meminfo | awk '{print $2}')"
	CACHEONRAM=$((HWRAMTOTAL * 33 / 100))

	CORUID="$(id -u $USER)"
	CORGID="$(id -g $USER)"

	[ -d "$GAME_ROOT" ] && { [ "$(ls -A "$GAME_ROOT")" ] && echo "Game is mounted or extracted." && return 0; }

    mkdir -p "$PWD/files/.game-root-mnt" "$PWD/files/overlay-storage" "$PWD/files/.game-root-work" "$GAME_ROOT" || {
        echo "Error: Failed to create necessary directories."
        return 1
    }

    dwarfs "$PWD/files/game-root.dwarfs" "$PWD/files/.game-root-mnt" \
        -o cachesize="${CACHEONRAM}k" -o clone_fd -o cache_image && \
        fuse-overlayfs -o squash_to_uid="$CORUID" \
                        -o squash_to_gid="$CORGID" \
                        -o lowerdir="$PWD/files/.game-root-mnt",upperdir="$PWD/files/overlay-storage",workdir="$PWD/files/.game-root-work" \
                        "$GAME_ROOT" && \
        echo "Game mounted successfully. Extraction not required."

}

# Function to unmount the dwarfs file
dwarfs-unmount() {
    fuser -k "$PWD/files/.game-root-mnt" 2>/dev/null

    local UMOUNT_DIRS=("$GAME_ROOT" "$PWD/files/.game-root-mnt")
    for dir in "${UMOUNT_DIRS[@]}"; do
        fusermount3 -u -z "$dir" 2>/dev/null || {
            echo "Warning: Could not unmount $dir."
        }
    done

    echo "Game unmounted successfully."

    # Clean up temporary directories
    rm -rf "$PWD/files/.game-root-mnt" "$PWD/files/.game-root-work"
    [ -d "$GAME_ROOT" ] && [ -z "$(ls -A "$GAME_ROOT")" ] && rm -rf "$GAME_ROOT"
}

# Function to extract game files from dwarfs
dwarfs-extract() {
    if [ -d "$GAME_ROOT" ] && [ "$(ls -A "$GAME_ROOT")" ]; then
        echo "Game is already mounted or extracted."
        return 0
    fi

    mkdir -p "$GAME_ROOT" || {
        echo "Error: Failed to create game root directory."
        return 1
    }

    dwarfsextract --stdout-progress -i "$PWD/files/game-root.dwarfs" -o "$GAME_ROOT" || {
        echo "Error: Failed to extract game files."
        return 1
    }
}

# Function to compress game files into dwarfs
dwarfs-compress() {
    if [ -f "$PWD/files/game-root.dwarfs" ]; then
        echo "Warning: Dwarfs archive already exists. Skipping compression."
        return 0
    fi

    mkdwarfs -l7 -B24 -S24 \
        --no-history \
        --order=nilsimsa \
        --set-owner=1000 \
        --set-group=1000 \
        --set-time=now \
        --chmod=Fa+rw,Da+rwx \
        -i "$GAME_ROOT" \
        -o "$PWD/files/game-root.dwarfs" && \
        b3sum "$PWD/files/game-root.dwarfs" > "$PWD/files/blake3" && \
        tree -a -s files/game-root > files/dwarfs-tree
}

# Function to check integrity of the dwarfs archive
dwarfs-check_integrity() { dwarfsck --check-integrity -i "$PWD/files/game-root.dwarfs"; }

# Function for cleanup tasks
jc141-cleanup() { cd "$OLDPWD" && dwarfs-unmount; }

# Function to initiate a WINE prefix for Windows games
wine-initiate_prefix() {
    wineboot -i
    find "$WINEPREFIX/drive_c/users/$USER" -maxdepth 1 -type l -exec test -d {} \; -exec rm {} \; -exec mkdir {} \;
    wineserver -w
}

# Function to set up external Vulkan support
wine-setup_external_vulkan() {
    if tar -xvf "$PWD/files/vulkan.tar.xz" -C "$PWD/files" && bash "$PWD/files/vulkan/setup-vulkan.sh"; then
        echo "Vulkan installed successfully." > "$WINEPREFIX/vulkan.log"
        rm -rf "$PWD/files/vulkan"
    else
        echo "Error: Failed to set up Vulkan."
    fi
}

# Function to write a configuration file
jc141-write_config() {
	cat <<- 'EOF' >> "$1"
		# ---------------------------------------------------------------------------- #
		# General

		# Automatically unmounts game files after the process ends.
		UNMOUNT=1

		# Extract game files instead of mounting the dwarfs archive on launch.
		EXTRACT=0

		# Display terminal output of various commands run by the launch scripts.
		TERMINAL_OUTPUT=1

		# Configure WINE executable path
		SYSWINE="$(command -v wine)"

		# ---------------------------------------------------------------------------- #
		# Bubblewrap

		# Force games into using an isolated sandbox directory.
		ISOLATE=1

		# Block network access to the game. Does not work if Isolation is disabled.
		BLOCK_NET=1

		# Sandbox directory path for isolation. (stores WINE Prefix, Game saves, etc..)
		# Only applies when ISOLATE=1 for native games. The path is used regarldess for the wine prefix.
		JC_DIRECTORY="$HOME/Games/jc141"

		# ---------------------------------------------------------------------------- #
		# Gamescope

		# Use gamescope?
		GAMESCOPE=1

		# Make the game fullscreen
		GAMESCOPE_FULLSCREEN=1

		# Make the game run in a borderless window
		GAMESCOPE_BORDERLESS=0

		# Use AMD FidelityFX Super Resolution
		GAMESCOPE_FSR=0

		# Use NVIDIA Image Scaling
		GAMESCOPE_NIS=0

		# Output resolution
		GAMESCOPE_SCREEN_WIDTH=
		GAMESCOPE_SCREEN_HEIGHT=

		# Game resolution
		GAMESCOPE_GAME_WIDTH=
		GAMESCOPE_GAME_HEIGHT=

		# Enable Integer Scaling
		GAMESCOPE_INTEGER_SCALING=

		# Enable Stretched Scaling
		GAMESCOPE_STRETCH_SCALING=

		# FPS/Refresh Rate limits
		GAMESCOPE_FPS_LIMIT=
		GAMESCOPE_FPS_LIMIT_UNFOCUSED=

		# Use wide color gamut for SDR content
		STEAMDECK_COLOR_RENDERING=0

		# Enable HDR output
		GAMESCOPE_HDR=0

		# Enable SDR->HDR inverse tone mapping (only works for SDR input)
		GAMESCOPE_HDR_ITM=0

		# Set the luminance of SDR content in nits (default: 400)
		GAMESCOPE_HDR_SDR_CONTENT_NITS=

		# Set the luminance of SDR content in nits used as the input for the inverse tone mapping process. (default: 100, max: 1000)
		GAMESCOPE_HDR_ITM_SDR_NITS=

		# Set the target luminance in nits of the inverse tone mapping process. (default: 1000, max: 10000)
		GAMESCOPE_HDR_ITM_TARGET_NITS=

		# Upscaler sharpness (max: 0, min: 20) [yes, this is not a typo]
		GAMESCOPE_SHARPNESS=
		GAMESCOPE_FSR_SHARPNESS=

		# Upscaler type (auto, integer, fit, fill, stretch)
		GAMESCOPE_SCALER=

	EOF
}

# Generate global configuration defaults if not present
jc141-generate_global_defaults() {

	# Write global config header to file
	cat <<- 'EOF' > "$HOME/.jc141rc"
		# ---------------------------------------------------------------------------- #
		# This file is used by jc141 start scripts to specify default settings.
		# These settings are applied globally, unless overridden by the game-specific
		# configuration file located beside the launch scripts

	EOF

	# Write config keys and default values to file
	jc141-write_config "$HOME/.jc141rc"

}

# Generate local overrides if not present
jc141-generate_local_overrides() {

	cat <<- 'EOF' > "$PWD/script_default_settings"
		# ---------------------------------------------------------------------------- #
		# This file is used by jc141 start scripts to specify game-specific settings.
		# These settings are applied only to this game, and override the global
		# configuration specified in "~/.jc141rc"

		# ---------------------------------------------------------------------------- #
		# By default, all settings in this file are commented out (disabled)
		# Users may uncomment/enable the individual settings here to override the
		# value of the config variable set by "~/.jc141rc"

		# Uploaders will also use it to disable specific settings like gamescope
		# because it does not work properly in this instance.

	EOF

	# Write config keys and default values to file
	jc141-write_config "$PWD/script_default_settings"

	# Comment out config keys by default
	sed -i -e 's/^\([^#].*\)/#\1/g' "$PWD/script_default_settings"

}

# Run a command in a bubblewrap sandbox
bwrap-run_in_sandbox() {
	[ -n "${WAYLAND_DISPLAY}" ] && export wayland_socket="${WAYLAND_DISPLAY}" || export wayland_socket="wayland-0"
	[ -z "${XDG_RUNTIME_DIR}" ] && export XDG_RUNTIME_DIR="/run/user/${EUID}"

	# common args
	BWRAP_FLAGS=(
		--bind / /
		--ro-bind-try "$HOME" "$HOME"
		--dev-bind /dev /dev
		--ro-bind-try /sys /sys
		--proc /proc
		--ro-bind-try /mnt /mnt
		--ro-bind-try /run /run
		--ro-bind-try /var /var
		--ro-bind-try /etc /etc
		--ro-bind-try /tmp/.X11-unix /tmp/.X11-unix
		--ro-bind-try /opt /opt
		--bind-try /tmp /tmp
		--ro-bind-try /usr/lib64 /usr/lib64
		--ro-bind-try /usr/lib /usr/lib
	)

	# X11 compatibility?
	for s in /tmp/.X11-unix/*; do
		BWRAP_FLAGS+=(--bind-try "${s}" "${s}")
	done

	# runner specific args
	[ "$ISOLATION_TYPE" = 'wine' ] && BWRAP_FLAGS+=( --bind "$WINEPREFIX" "$WINEPREFIX" )
	[ "$ISOLATION_TYPE" = 'native' ] && BWRAP_FLAGS+=( --bind-try "$JC_DIRECTORY/native-docs" ~/ ) && [ ! -e "$JC_DIRECTORY/native-docs/.Xauthority" ] && ln "$XAUTHORITY" "$JC_DIRECTORY/native-docs" && XAUTHORITY="$HOME/.Xauthority"

	# block network
	[ $BLOCK_NET = 1 ] && BWRAP_FLAGS+=( --unshare-net )

	# current dir as last setting
	BWRAP_FLAGS+=( --bind "$PWD" "$PWD" )

	bwrap "${BWRAP_FLAGS[@]}" "$@"
}

# Function to run a game using Gamescope
gamescope-run_embedded() {
    # Check for Gamescope installation
    local GAMESCOPE_BIN
    GAMESCOPE_BIN="$(command -v gamescope)"
    [ ! -x "$GAMESCOPE_BIN" ] && { echo "Error: gamescope not installed."; exit 1; }

    local -a GAMESCOPE_ARGS

    [ $GAMESCOPE_FULLSCREEN -eq 1 ] && GAMESCOPE_ARGS+=(-f)
    [ $GAMESCOPE_BORDERLESS -eq 1 ] && GAMESCOPE_ARGS+=(-b)
    [ $GAMESCOPE_FSR -eq 1 ] && GAMESCOPE_ARGS+=(-F fsr)
    [ $GAMESCOPE_NIS -eq 1 ] && GAMESCOPE_ARGS+=(-F nis)

    # Add resolution options
    [ -n "$GAMESCOPE_SCREEN_WIDTH" ] && GAMESCOPE_ARGS+=(-W "$GAMESCOPE_SCREEN_WIDTH")
    [ -n "$GAMESCOPE_SCREEN_HEIGHT" ] && GAMESCOPE_ARGS+=(-H "$GAMESCOPE_SCREEN_HEIGHT")
    [ -n "$GAMESCOPE_GAME_WIDTH" ] && GAMESCOPE_ARGS+=(-w "$GAMESCOPE_GAME_WIDTH")
    [ -n "$GAMESCOPE_GAME_HEIGHT" ] && GAMESCOPE_ARGS+=(-h "$GAMESCOPE_GAME_HEIGHT")

    [ $STEAMDECK_COLOR_RENDERING -eq 1 ] && GAMESCOPE_ARGS+=(--sdr-gamut-wideness 1)
    [ $GAMESCOPE_INTEGER_SCALING -ne 0 ] && GAMESCOPE_ARGS+=(-S integer)
    [ $GAMESCOPE_STRETCH_SCALING -ne 0 ] && GAMESCOPE_ARGS+=(-S stretch)

    # Add FPS limits if set
    [ -n "$GAMESCOPE_FPS_LIMIT" ] && GAMESCOPE_ARGS+=(-r "$GAMESCOPE_FPS_LIMIT")
    [ -n "$GAMESCOPE_FPS_LIMIT_UNFOCUSED" ] && GAMESCOPE_ARGS+=(-o "$GAMESCOPE_FPS_LIMIT_UNFOCUSED")

    # Add HDR options
    [ $GAMESCOPE_HDR -eq 1 ] && GAMESCOPE_ARGS+=(--hdr-enabled)
    [ -n "$GAMESCOPE_HDR_SDR_CONTENT_NITS" ] && GAMESCOPE_ARGS+=(--hdr-sdr-content-nits "$GAMESCOPE_HDR_SDR_CONTENT_NITS")
    [ $GAMESCOPE_HDR_ITM -eq 1 ] && GAMESCOPE_ARGS+=(--hdr-itm-enable)
    [ -n "$GAMESCOPE_HDR_ITM_SDR_NITS" ] && GAMESCOPE_ARGS+=(--hdr-itm-sdr-nits "$GAMESCOPE_HDR_ITM_SDR_NITS")
    [ -n "$GAMESCOPE_HDR_ITM_TARGET_NITS" ] && GAMESCOPE_ARGS+=(--hdr-itm-target-nits "$GAMESCOPE_HDR_ITM_TARGET_NITS")
    [ -n "$GAMESCOPE_SHARPNESS" ] && GAMESCOPE_ARGS+=(--sharpness "$GAMESCOPE_SHARPNESS")
    [ -n "$GAMESCOPE_FSR_SHARPNESS" ] && GAMESCOPE_ARGS+=(--fsr-sharpness "$GAMESCOPE_FSR_SHARPNESS")
    [ -n "$GAMESCOPE_SCALER" ] && GAMESCOPE_ARGS+=(--scaler "$GAMESCOPE_SCALER")

    # Execute Gamescope with constructed arguments
    "$GAMESCOPE_BIN" "${GAMESCOPE_ARGS[@]}" -- "$@"
}

# Generate config files if not present
[ ! -f "$HOME/.jc141rc" ] && jc141-generate_global_defaults
[ ! -f "$PWD/script_default_settings" ] && jc141-generate_local_overrides

# Load config files
source "$HOME/.jc141rc"
source "$PWD/script_default_settings"

# Minimal CLI goodness
(return 0 2> /dev/null) || {
	if type "$1" &> /dev/null; then
		"$1" "${@:2}"
	else
		echo "ERROR: Unknown action '$1', exiting..."
		exit
	fi
}