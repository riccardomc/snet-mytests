#!/bin/bash
#
# Run the zmq EXE locally.
#

RUNS=10

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

base_port=15000
root_port=14000
for ((j = 1; j <= $RUNS; j++)) do
  echo TEST $j

  for ((i = 1; i < $NODES; i++)) do
    echo "$EXE -sport $base_port -dport $(($base_port + 1)) -raddr tcp://localhost:${root_port}/ &"
    $EXE -sport $base_port -dport $(($base_port + 1)) -raddr tcp://localhost:${root_port}/ > /dev/null &
    base_port=$(($base_port + 2))
  done

  echo "$EXE -sport $root_port -dport $(($root_port + 1)) -root $NODES -i $IN -o $OUT"
  $EXE -sport $root_port -dport $(($root_port + 1)) -root $NODES -i $IN >> $OUT
  sleep 0.1

done
