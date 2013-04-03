#generate a set of test programs for the bench-pipeline example

#T_BASES = sn sd pt bn bd
T_BASES = sn
T_LENS = 1
T_WIDTHS = 1
T_NRECS = 100000
T_CYCLES = 1
T_THREADING = pthread
T_CORES = 1
T_LOADS = 1
T_DISTRIB = mpi zmq

TESTS = $(foreach B,$(T_BASES), \
        $(foreach L,$(T_LENS), \
        $(foreach W,$(T_WIDTHS), \
        $(foreach N,$(T_NRECS), \
        $(foreach M,$(T_LOADS), \
        $(foreach C,$(T_CYCLES), \
        $(foreach P,$(T_CORES), \
        $(foreach T,$(T_THREADING), \
        $(foreach D,$(T_DISTRIB), \
        $(B)-$(L)-$(W)-$(N)-$(M)-$(C)-$(P)-$(T)-$(D))))))))))

test-%:
	@echo $(TESTS) > $@
	sed -i 's| |\n|g' $@

all: test-file
