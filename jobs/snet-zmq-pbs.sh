#!/bin/sh

PROG=$1
DATA=$2
OUTF=$3
NODES=$4
RFILE="$PBS_O_WORKDIR/$PBS_JOBNAME.root"
DPORT=20737
SPORT=20738
ARGS="-sport $SPORT -dport $DPORT"

cd $PBS_O_WORKDIR

case $PBS_NODENUM in
  0)
    rm -f $PBS_JOBNAME.done
    echo $HOSTNAME > $RFILE
    echo "$PROG $ARGS -root $NODES -i $DATA >> $OUTF"
    $PROG $ARGS -root $NODES -i $DATA >> $OUTF
    rm -f $RFILE
    touch $PBS_JOBNAME.done
    ;;
    
  *)
    while [[ ! -e $RFILE ]] ; do
      sleep 1
    done
    sleep 1
    ROOT=$(cat $RFILE)
    echo "$PROG $ARGS -raddr tcp://$ROOT:$SPORT/ > /dev/null"
    $PROG $ARGS -raddr tcp://$ROOT:$SPORT/ > /dev/null
    ;;
esac

