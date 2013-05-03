set MODULE cc_testbench
start $MODULE
add wave $MODULE/*
add wave $MODULE/cc_test1/*
add wave $MODULE/cc_test2/*
add wave $MODULE/cc_test3/*
run 10000us
