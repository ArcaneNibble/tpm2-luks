#!/bin/sh

TOOLSDIR="/opt/tpmdisk"
DISK="/dev/disk/by-uuid/40eaf4e5-88ac-4e24-9365-49c2bd476bff"
TPM_SLOT="0"

tmpdir=$(mktemp -d)
umask 0077

# Make a new key
dd if=/dev/urandom of="$tmpdir/newkey.bin" bs=1 count=32

# Kill the existing key
echo "Removing old key..."
cryptsetup luksKillSlot "$DISK" "${TPM_SLOT}" -d /keys/rootkey.bin

# Seal the new key to the TPM
echo "Sealing key to TPM..."
"$TOOLSDIR/seal-to-pcrs.sh" "$tmpdir/newkey.bin" "$TOOLSDIR/sealedkey_priv.bin" "$TOOLSDIR/sealedkey_pub.bin"

# Add the key to LUKS
echo "Adding key..."
cryptsetup luksAddKey "$DISK" "$tmpdir/newkey.bin" -d /keys/rootkey.bin

# Clean up
rm -rf "$tmpdir"
