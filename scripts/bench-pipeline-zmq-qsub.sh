#!/bin/sh

TESTF=$1
NRUNS=$2
SRCDIR="$SNET_DIR/../snet-mytests/bench-pipeline"
ZMQSUB="$SRCDIR/../scripts/zmq-qsub.sh"

([ -z "$TESTF" ] |  [ -z "$NRUNS" ]) && echo "$0 <TEST_FILE> <RUNS>" && exit 1

RESDIR="${TESTF##*/}-$(date  +'%Y%m%d%H%M')"

make -C $SRCDIR clean

for line in $(cat $TESTF) ; do
  TEST=result-$line
  IFS="-"
  set $line
  unset IFS
  make -C $SRCDIR $TEST
  echo $1 $2 $3 $4 $5 $6 $7 $8 $9
  mkdir -p $RESDIR
  $ZMQSUB -e $SRCDIR/test-$1-$2-$3-$8-$9/prog -n $(( $2 + 1 )) -i $SRCDIR/input-$4-$5-$6.xml -o $RESDIR/$TEST.dat -r $NRUNS 
done


