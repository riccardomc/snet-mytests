#PBS -lwalltime=00:05:00

PROG=$SNET_BENCHTEST_PROG
DATA=$SNET_BENCHTEST_DATA
OUTF=$SNET_BENCHTEST_OUTF
RUNS=$SNET_BENCHTEST_RUNS
JOBS=$SNET_BENCHTEST_JOBS

NODES=$(wc -l $PBS_NODEFILE | grep -o '^[0-9]* ')

mail $USER -s "STARTED $PBS_JOBID"  << EOF
Hello $USER,

JOB > $PBS_JOBID < started $(date)

RUNS: $RUNS
PROG: $PROG
DATA: $DATA
OUTF: $OUTF
SUBJ: $JOBS

With love,

Lisa
EOF

for ((i = 1; i <= $RUNS; i++)) do
  echo TEST $i
  pbsdsh $JOBS $PROG $DATA $OUTF $NODES 
  while [[ ! -e $PBS_O_WORKDIR/$PBS_JOBNAME.done ]] ; do
    sleep 1
  done
done

echo "Job $PBS_JOBID ended at `date`" | mail $USER -s "ENDED $PBS_JOBID"

rm -f $PBS_O_WORKDIR/mon*.log
rm -f $PBS_O_WORKDIR/$PBS_JOBNAME.*
