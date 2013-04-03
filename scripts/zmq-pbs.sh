#!/bin/bash
#
# Submit the zmq PROG using a PBS multinode job.
#
# This is used on the LISA system.
#

RUNS=3
JOBF=$PWD/jobs/multinode.sh
JOBS=$PWD/jobs/snet-zmq-pbs.sh
QSUB=/usr/bin/qsub

usage() {
  echo "$0 OPTIONS"
  echo
  echo "OPTIONS:"
  echo "-e EXE"
  echo "-n NODES"
  echo "-i INPUT"
  echo "-o OUTPUT"
  echo "-o RUNS"
  echo "-h show this help"
}

mandatory() {
  echo "Argument $1 is mandatory." >&2
  exit 1
}

while getopts ":e:n:i:o:r::h" opt; do
  case $opt in
    e)
      PROG=$OPTARG
      ;;
    n)
      NODES=$OPTARG
      ;;
    i)
      DATA=$OPTARG
      ;;
    o)
      OUTF=$OPTARG
      ;;
    r)
      RUNS=$OPTARG
      ;;

    h)
      usage
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

[ -z "$PROG" ] && mandatory "-e"
[ -z "$NODES" ] && mandatory "-n"
[ -z "$DATA" ] && mandatory "-i"
[ -z "$OUTF" ] && mandatory "-o"
[ -z "$RUNS" ] && mandatory "-r"

export SNET_BENCHTEST_PROG=$PROG
export SNET_BENCHTEST_DATA=$DATA
export SNET_BENCHTEST_OUTF=$OUTF
export SNET_BENCHTEST_RUNS=$RUNS
export SNET_BENCHTEST_JOBS=$JOBS

JOBN=${OUTF##*/}
JOBN=${JOBN%%.dat}

echo "$QSUB -V -N $JOBN -lnodes=$NODES:ppn=1 $JOBF"
$QSUB -V -N $JOBN -lnodes=$NODES:ppn=1 $JOBF

unset SNET_BENCHTEST_PROG
unset SNET_BENCHTEST_DATA
unset SNET_BENCHTEST_OUTF
unset SNET_BENCHTEST_RUNS
unset SNET_BENCHTEST_JOBS
