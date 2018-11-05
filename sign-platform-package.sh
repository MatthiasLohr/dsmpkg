#!/bin/bash

# code found https://forum.synology.com/enu/viewtopic.php?t=98760
export SPK_IN="$1"
export SPK_OUT="$2"
export SPK_EXTRACT_DIR="./SPK_UNTAR"
export SPK_CATALL_OUT="./CATALL.dat"
export SPK_SIG_FILE="syno_signature"
export SPK_TOKEN_FILE="$SPK_EXTRACT_DIR/syno_signature.asc"

export GPG_HOME="./GPG_HOME"
export GPG="gpg2"
export GPG_OPTS="--ignore-time-conflict --ignore-valid-from --yes --batch --homedir $GPG_HOME"
export GPG_PUBLIC_KEY="./alice.pub"
export GPG_PUBLIC_USR="alice@example.org"

export TIMESERVER="http://timestamp.synology.com/timestamp.php"


# Create new keys
if [ ! -f "$GPG_PUBLIC_KEY" ]; then
	echo "Creating new keys"
	rm -r "$GPG_HOME"
	mkdir -p "$GPG_HOME" && chmod 700 "$GPG_HOME"
	echo "----- Please create keys for $GPG_PUBLIC_USR -----"
	$GPG --homedir "$GPG_HOME" --gen-key
	$GPG $GPG_OPTS --armor --output "$GPG_PUBLIC_KEY" --export "$GPG_PUBLIC_USR"
fi

# Prepare
$GPG $GPG_OPTS --list-secret-keys
export KEY_FPR=`$GPG $GPG_OPTS --list-secret-keys | egrep "^sec" | cut -d'/' -f2 | cut -d' ' -f1`
echo "Using SECRET_KEY $KEY_FPR"

echo "----- CLEAN -----"
rm -r "$SPK_EXTRACT_DIR" "$SPK_OUT" "$SPK_CATALL_OUT" "$SPK_SIG_FILE" "$SPK_TOKEN_FILE"
mkdir "$SPK_EXTRACT_DIR"


tar xf "$SPK_IN" -C "$SPK_EXTRACT_DIR"
rm "$SPK_SIG_FILE" "$SPK_TOKEN_FILE"

# Pipe all files into a single file
echo "----- CATALL -----"
find SPK_UNTAR -type f | sort | xargs wc -c
cat `find $SPK_EXTRACT_DIR -type f | sort` > "$SPK_CATALL_OUT"
wc -c "$SPK_CATALL_OUT"

echo "----- SIGN -----"
$GPG $GPG_OPTS --local-user $KEY_FPR --armor --detach-sign --output "$SPK_SIG_FILE" "$SPK_CATALL_OUT"

echo "----- CHECK -----"
tar -tf "$SPK_OUT"
cat "$SPK_SIG_FILE"
$GPG $GPG_OPTS --verify "$SPK_SIG_FILE" "$SPK_CATALL_OUT"

echo "----- SYNO -----"
curl --form "file=@$SPK_SIG_FILE" "$TIMESERVER" > "$SPK_TOKEN_FILE"
cat "$SPK_TOKEN_FILE"

echo "----- PACK -----"
tar -cf "$SPK_OUT" -C "$SPK_EXTRACT_DIR" `ls -1 $SPK_EXTRACT_DIR`
