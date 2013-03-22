#!/bin/sh
#
# Execute $1 on a batch system, the root node is executed locally.
#

EXE_PATH=${SNET_DIR}/../snet-dev/snet-rts/examples/tests/distributed/
EXE_NAME=$1
EXE=$EXE_PATH/$EXE_NAME/$EXE_NAME
DPORT=20737
SPORT=20738
RADDR=tcp://$(hostname -A | cut -d " " -f 1):$SPORT/
NODES=`cat $EXE_PATH/$EXE_NAME/nodes`

ARGS="-sport $SPORT -dport $DPORT"

export SNETTESTFLAGS="-distrib zmq"
cd $EXE_PATH/$EXE_NAME
make
cd $OLDPWD

for ((i = 1; i < $NODES ; i++)) do
  echo "$EXE $ARGS -raddr $RADDR" | qsub
done

$EXE $ARGS -root $NODES -i $EXE_PATH/$EXE_NAME/input.xml
