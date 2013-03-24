#!/bin/bash
#
# Submit the zmq EXE using a PBS multinode job.
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
      EXE=$OPTARG
      ;;
    n)
      NODES=$OPTARG
      ;;
    i)
      IN=$OPTARG
      ;;
    o)
      OUT=$OPTARG
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

[ -z "$EXE" ] && mandatory "-e"
[ -z "$NODES" ] && mandatory "-n"
[ -z "$IN" ] && mandatory "-i"
[ -z "$OUT" ] && mandatory "-o"
[ -z "$RUNS" ] && mandatory "-r"

export SNET_BENCHTEST_PROG=$EXE
export SNET_BENCHTEST_DATA=$IN
export SNET_BENCHTEST_OUTF=$OUT
export SNET_BENCHTEST_RUNS=$RUNS
export SNET_BENCHTEST_JOBS=$JOBS

JOBN=${JOBS##*/}
JOBN=${JOBN%%.dat}

$QSUB -V -N $JOBN -lnodes=$NODES:ppn=1 $JOBF

unset SNET_BENCHTEST_PROG
unset SNET_BENCHTEST_DATA
unset SNET_BENCHTEST_OUTF
unset SNET_BENCHTEST_RUNS
unset SNET_BENCHTEST_JOBS
