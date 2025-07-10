#!/bin/bash

./mainFuzzer.sh FUZZER_0 &
./slaveFuzzer.sh FUZZER_1 &
./slaveFuzzer.sh FUZZER_2 &
./slaveFuzzer.sh FUZZER_3 &
./slaveFuzzer.sh FUZZER_4 &
./slaveFuzzer.sh FUZZER_5 &
./slaveFuzzer.sh FUZZER_6 &
./slaveFuzzer.sh FUZZER_7 &
./slaveFuzzer.sh FUZZER_8 &
./slaveFuzzer.sh FUZZER_9 &
./slaveFuzzer.sh FUZZER_10 &
./slaveFuzzer.sh FUZZER_11 &
./alwaysCleanup.sh &

# Wait for any process to exit
wait -n
# Exit with status of process that exited first
exit $?
