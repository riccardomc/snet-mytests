#!/bin/bash

RTERM=$(which R)

TESTDIR=$1

[ -z "$TESTDIR" ]  && echo "$0 <TEST_DIR>" && exit 1
   
$RTERM --no-restore --no-save --args $TESTDIR < plotavg.R > R.log 2>&1
