#!/bin/bash
#
# AlbumGenerator Update Script
# (c) Copyright 2010 ayaby. All Rights Reserved. 
#

OWNER=apache
GROUP=apache

SELFNAME=`basename $0`

if [ $#	-ne 1 ]; then
	echo "Usage: $SELFNAME <AlbumGenerator Path>" 1>&2
	exit 1
fi

ALBUMGEN_DIR=$1;

if [ ! -f $ALBUMGEN_DIR/AlbumGenerator.rb  ]; then
	echo "AlbumGenerator Path $ALBUMGEN_DIR is invalid." 1>&2
	exit 1
fi

# copy *****.rb files.
echo "copy files"
cp *.rb $ALBUMGEN_DIR

# change ownwer
echo "exec chown"
chown ${OWNER}:${GROUP} $ALBUMGEN_DIR/*.rb

# changemod
echo "exec chmod."
chmod 700 $ALBUMGEN_DIR/*.rb

echo "update is finished."