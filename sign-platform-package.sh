#!/bin/bash

spk_in="$1"
spk_out="$2"
tmpdir=`mktemp -d -t dsmpkg-sign.XXXXXXXX`
tmpcatfile=`mktemp -t dsmpkg-sign.XXXXXXXX`

tar xfz "$spk_in" -C "$tmpdir"
rm -rf "$tmpdir/syno_signature.asc"
cat `find $tmpdir -type f | sort` > "$tmpcatfile"
gpg --armor --detach-sign --output "$tmpdir/syno_signature.asc" "$tmpcatfile"
tar cfz "$spk_out" -C "$tmpdir" `ls -1 "$tmpdir"`

#rm -rf "$tmpdir" "$tmpcatfile"

