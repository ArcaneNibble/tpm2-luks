#!/bin/sh

# args are: priv pub output

# KEEP IN SYNC!
PCRS="0 2 4 7"
PCR_BITS="95"
TOOLSDIR="/opt/tpmdisk"

tmpdir=$(mktemp -d)
export TPM_DATA_DIR="$tmpdir"

# Load the keys
load_key=$("$TOOLSDIR/load" -hp 81000001 -ipr "$1" -ipu "$2")
if [ $? -ne 0 ]
then
    >&2 echo "Load command failed!"
    >&2 echo "$load_key"
    rm -rf "$tmpdir"
    exit 1
fi
key_handle=${load_key#*Handle }

# Start auth session
start_auth=$("$TOOLSDIR/startauthsession" -se p)
if [ $? -ne 0 ]
then
    >&2 echo "Start auth session failed!"
    >&2 echo "$start_auth"
    "$TOOLSDIR/flushcontext" -ha $key_handle
    rm -rf "$tmpdir"
    exit 1
fi
sess_handle=${start_auth#*Handle }

# Run policypcr
"$TOOLSDIR/policypcr" -ha $sess_handle -bm $PCR_BITS

# Unseal
"$TOOLSDIR/unseal" -ha $key_handle -se0 $sess_handle 0 -of "$3"
if [ $? -ne 0 ]
then
    >&2 echo "Unsealing failed!"
    "$TOOLSDIR/flushcontext" -ha $key_handle
    "$TOOLSDIR/flushcontext" -ha $sess_handle
    rm -rf "$tmpdir"
    exit 1
fi

# Flush temporary
"$TOOLSDIR/flushcontext" -ha $key_handle

# Clean up
rm -rf "$tmpdir"
