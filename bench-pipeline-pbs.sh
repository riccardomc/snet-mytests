#!/bin/sh
#
# Submit jobs to PBS and collect results
#

TESTF=$1
RUNS=$2

JOBF=$PWD/jobs/multinode.sh
JOBS=$PWD/jobs/snet-zmq-pbs.sh

#the source of the bench-pipeline example
SRCDIR="$PWD/bench-pipeline"

([ -z "$TESTF" ] |  [ -z "$RUNS" ]) && echo "$0 <TEST_FILE> <RUNS>" && exit 1

RESDIR="${TESTF##*/}-$(date  +'%Y%m%d%H%M')"
QSUB=/usr/bin/qsub

make -C $SRCDIR clean

for line in $(cat $TESTF) ; do
  TEST=result-$line
  IFS="-"
  set $line
  unset IFS
  make -C $SRCDIR $TEST
  echo $1 $2 $3 $4 $5 $6 $7 $8 $9
  mkdir -p $RESDIR
 
  export SNET_BENCHTEST_PROG=$SRCDIR/test-$1-$2-$3-$8-$9/prog
  export SNET_BENCHTEST_DATA=$SRCDIR/input-$4-$5-$6.xml
  export SNET_BENCHTEST_OUTF=$RESDIR/$TEST.dat
  export SNET_BENCHTEST_RUNS=$RUNS
  export SNET_BENCHTEST_JOBS=$JOBS

  $QSUB -V -N $TEST -lnodes=$(( $2 + 1 )):ppn=1 $JOBF
done

unset SNET_BENCHTEST_PROG
unset SNET_BENCHTEST_DATA
unset SNET_BENCHTEST_OUTF
unset SNET_BENCHTEST_RUNS
unset SNET_BENCHTEST_JOBS
