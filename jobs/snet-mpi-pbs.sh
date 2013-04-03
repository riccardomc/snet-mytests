#PBS -lwalltime=0:05:00

PROG=$SNET_BENCHTEST_PROG
DATA=$SNET_BENCHTEST_DATA
OUTF=$SNET_BENCHTEST_OUTF
RUNS=$SNET_BENCHTEST_RUNS

NODES=$(wc -l $PBS_NODEFILE | grep -o '^[0-9]* ')

MPIRUN=$(which mpirun)

for ((i = 1; i <= $RUNS; i++)) do
  echo TEST $i
  echo "$MPIRUN -n $NODES $PROG -i $DATA -o /dev/null | sort | tail -n1 >> $OUTF"
  $MPIRUN -n $NODES $PROG -i $DATA -o /dev/null | sort | tail -n1 >> $OUTF
  sleep 1
done


