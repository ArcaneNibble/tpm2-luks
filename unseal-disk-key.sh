#!/bin/sh

TOOLSDIR="/opt/tpmdisk"

disk_key=$("$TOOLSDIR/unseal-from-pcrs.sh" "$TOOLSDIR/sealedkey_priv.bin" "$TOOLSDIR/sealedkey_pub.bin" /dev/stdout)
if [ $? -ne 0 ]
then
    exec /lib/cryptsetup/askpass "Enter disk recovery key: "
else
    echo -n "$disk_key"
fi
