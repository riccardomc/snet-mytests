#!/bin/bash

RTERM=$(which R)
PLOTS=$(dirname $0)/plotavg.R

TESTDIR=$1

[ -z "$TESTDIR" ]  && echo "$0 <TEST_DIR>" && exit 1
   
$RTERM --no-restore --no-save --args $TESTDIR < $PLOTS > R.log 2>&1
