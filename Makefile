#generate a set of test programs for the bench-pipeline example

#T_BASES = sn sd pt bn bd
T_BASES = sn
T_LENS = 1 6 12
T_WIDTHS = 0 1 5
T_NRECS = 1 50
T_CYCLES = 1 5
T_THREADING = lpel
T_CORES = 1
T_LOADS = 1

TESTS = $(foreach B,$(T_BASES), \
        $(foreach L,$(T_LENS), \
        $(foreach W,$(T_WIDTHS), \
        $(foreach N,$(T_NRECS), \
        $(foreach M,$(T_LOADS), \
        $(foreach C,$(T_CYCLES), \
        $(foreach P,$(T_CORES), \
        $(foreach T,$(T_THREADING), \
        $(B)-$(L)-$(W)-$(N)-$(M)-$(C)-$(P)-$(T)-zmq))))))))

test-file:
	@echo $(TESTS) > test_file
	sed -i 's| |\n|g' test_file

all: test-file
