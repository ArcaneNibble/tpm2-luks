#!/bin/sh

# args are: input priv pub

# KEEP IN SYNC!
PCRS="0 2 4 7"
PCR_BITS="95"
TOOLSDIR="/opt/tpmdisk"

tmpdir=$(mktemp -d)

# Read PCRs
for pcr in $PCRS
do
    "$TOOLSDIR/pcrread" -ns -ha $pcr >>"$tmpdir/pcrs.txt"
done

# Make text policy file
"$TOOLSDIR/policymakerpcr" -bm $PCR_BITS -if "$tmpdir/pcrs.txt" -of "$tmpdir/pcr-policy.txt"

# Make binary policy file
"$TOOLSDIR/policymaker" -if "$tmpdir/pcr-policy.txt" -of "$tmpdir/pcr-policy.bin"

# Seal the actual file
"$TOOLSDIR/create" -hp 81000001 -bl -kt p -kt f -pol "$tmpdir/pcr-policy.bin" -if "$1" -opr "$2" -opu "$3"

# Clean up
rm -rf "$tmpdir"
