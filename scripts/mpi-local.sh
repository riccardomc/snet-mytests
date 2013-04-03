#!/bin/bash
#
# Run the mpi EXE locally.
#

RUNS=3

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

MPIRUN=$(which mpirun)
for ((j = 1; j <= $RUNS; j++)) do
  echo TEST $j
  echo "$MPIRUN -n $NODES $PROG -i $DATA | sort | tail -n1 >> $OUTF"
  $MPIRUN -n $NODES $PROG -i $DATA -o /dev/null | sort | tail -n1 >> $OUTF
  sleep 0.1
done
