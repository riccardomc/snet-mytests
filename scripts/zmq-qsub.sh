#!/bin/sh
#
# Run the zmq EXE RUNS times on a batch system. The root node is executed
# locally.
#

DPORT=20737
SPORT=20738
ARGS="-sport $SPORT -dport $DPORT"
RUNS=10

usage() {
  echo "$0 OPTIONS"
  echo
  echo "OPTIONS:"
  echo "-e EXE"
  echo "-s SYNC_PORT"
  echo "-d DATA_PORT" 
  echo "-n NODES"
  echo "-i INPUT"
  echo "-o OUTPUT"
  echo "-r RUNS"
  echo "-h show this help"
}

mandatory() {
  echo "Argument $1 is mandatory." >&2
  exit 1
}

pollqstat() {
  JOBS=$(qstat | grep "rcefala *r" | wc -l)
  while [[ $JOBS -ne $1 ]]; do
    sleep $2
    JOBS=$(qstat | grep "rcefala *r" | wc -l)
  done
}

while getopts ":e:s:d:n:i:o:r:h" opt; do
  case $opt in
    s)
      SPORT=$OPTARG
      ;;
    d)
      DPORT=$OPTARG
      ;;
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
[ -z "$VERB" ] && VERB=">/dev/null"

RADDR=tcp://$(hostname -A | cut -d " " -f 1):$SPORT/

VALG=$(which valgrind)

for ((i = 1; i <= $RUNS; i++)) do
  echo TEST $i
  for ((j = 1; j < $NODES ; j++)) do
    echo "$VALG $EXE $ARGS -raddr $RADDR" | qsub
  done
  echo -n "Waiting for $(( $NODES - 1 )) running jobs... "
  pollqstat $(( $NODES - 1 )) 0.5
  echo -n " Running! "
  #/usr/bin/time -f "%e %S %U" -ao $OUT $EXE $ARGS -root $NODES -i $IN -o /dev/null
  export SNET_DBG_TIMING="$OUT"
  $VALG $EXE $ARGS -root $NODES -i $IN -o /dev/null
  unset SNET_DBG_TIMING
  echo -n "Completed. Waiting for Jobs to terminate... "
  pollqstat 0 0.1
  echo OK
done


