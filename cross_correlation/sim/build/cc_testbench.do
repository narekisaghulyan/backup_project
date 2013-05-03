proc start {m} {vsim -L unisims_ver -L unimacro_ver -L xilinxcorelib_ver -L secureip work.glbl $m}
set MODULE cc_testbench
start $MODULE
add wave $MODULE/*
add wave $MODULE/cc_test1/*
add wave $MODULE/cc_test2/*
add wave $MODULE/cc_test3/*
run 10000us
