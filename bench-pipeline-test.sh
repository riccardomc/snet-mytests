#!/bin/sh
#
# Submit jobs to PBS and collect results
#

TESTF=$1
RUNS=$2
SUBM=$3

#the source of the bench-pipeline example
SRCDIR="$PWD/bench-pipeline"

([ -z "$TESTF" ] |  [ -z "$RUNS" ]) && \
echo "$0 <TEST_FILE> <RUNS> [local|pbs|qsub]" && exit 1

[ -z "$3" ] && SUBM=local


RESDIR="$PWD/${TESTF##*/}-$SUBM-$(date  +'%Y%m%d-%H%M')"
mkdir -p $RESDIR
cp $TESTF $RESDIR/configs

make -C $SRCDIR clean

for line in $(cat $TESTF) ; do
  TEST=result-$line
  IFS="-"
  set $line
  unset IFS
  make -C $SRCDIR $TEST
  echo $1 $2 $3 $4 $5 $6 $7 $8 $9

  TORUN="$PWD/scripts/${9}-${SUBM}.sh"
  $TORUN -e $SRCDIR/test-$1-$2-$3-$8-$9/prog -n $(( $2 + 1 )) -i $SRCDIR/input-$4-$5-$6.xml -o $RESDIR/$TEST.dat -r $RUNS 
  
done

