#!/usr/bin/env bash
#
# Script to grab Solr and embed in priv dir.
#
# Usage:
#     ./grab-solr.sh
set -e

if [ $(basename $PWD) != "tools" ]
then
    cd tools
fi

SOLR_DIR=../priv/solr
BUILD_DIR=../build
VSN=solr-4.3.0-yz
SRC_DIR=$BUILD_DIR/$VSN
EXAMPLE_DIR=$SRC_DIR/example

check_for_solr()
{
    # $SOLR_DIR is preloaded with xml files, so check for the generated jar
    test -e $SOLR_DIR/start.jar
}

get_solr()
{
        wget --progress=dot:mega https://s3.amazonaws.com/yzami/pkgs/$VSN.tgz
        tar zxf $VSN.tgz
}

if check_for_solr
then
    echo "Solr already exists, exiting"
    exit 0
fi

echo "Create dir $BUILD_DIR"
if [ ! -e $BUILD_DIR ]; then
    mkdir $BUILD_DIR
fi

cd $BUILD_DIR

if [ ! -e $SRC_DIR ]
then
    get_solr
fi

echo "Creating Solr dir $SOLR_DIR"

# Explicitly copy files needed rather than copying everything and
# removing which requires using cp -rn (since $SOLR_DIR/etc has files
# which shouldn't be overwritten).  For whatever reason, cp -n causes
# non-zero exit code when files that would have been overwritten are
# detected.
cp -vr $EXAMPLE_DIR/contexts $SOLR_DIR
cp -vr $EXAMPLE_DIR/etc/create-solrtest.keystore.sh $SOLR_DIR/etc
cp -vr $EXAMPLE_DIR/etc/logging.properties $SOLR_DIR/etc
cp -vr $EXAMPLE_DIR/etc/webdefault.xml $SOLR_DIR/etc
cp -vr $EXAMPLE_DIR/lib $SOLR_DIR
# TODO: does resources need to be copied?
cp -vr $EXAMPLE_DIR/resources $SOLR_DIR
cp -vr $EXAMPLE_DIR/solr-webapp $SOLR_DIR
cp -vr $EXAMPLE_DIR/start.jar $SOLR_DIR
cp -vr $EXAMPLE_DIR/webapps $SOLR_DIR

echo "Solr dir created successfully"
