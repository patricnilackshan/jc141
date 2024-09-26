#!/usr/bin/env bash

# game binary
GAME_BIN="game-root/bin/game"

# game ID from Steam
GAME_ID=1000000

# game files
GAME_PATH=$(dirname "$0")
CONFIG_PATH=$(dirname "$0")

CUR_DIR=$(pwd)

cd "$CONFIG_PATH"
mkdir -p ~/.steam/sdk{32,64}

# libfaketime if needed
export LD_PRELOAD="$PWD/game-root/libfaketime.so.1"

# copy our files
[ ! -f "$HOME/.steam/sdk64/steamclient.so" ] && cp "$PWD/game-root/steamclient.so" "$HOME/.steam/sdk64/steamclient.so"

# write pid
echo $BASHPID > ~/.steam/steam.pid

# start
cd "$GAME_PATH" && SteamAppPath="$GAME_PATH" SteamAppId="$GAME_ID" SteamGameId="$GAME_ID" FAKETIME="@2000-00-00 00:00:00" ./"$GAME_BIN"

# remove pid
rm -Rf ~/.steam/steam.pid
