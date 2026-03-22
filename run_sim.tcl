# run_sim.tcl – ModelSim ASE 2020.1
# Cach dung: Transcript > do run_sim.tcl

vlib work
vmap work work

vlog clk_divider.v
vlog stepper_driver.v
vlog step_counter.v
vlog fsm_pan.v
vlog pan_top.v
vlog tb_pan.v

vsim -t 1ns work.tb_pan

add wave -divider "=== TOP ==="
add wave /tb_pan/clk
add wave /tb_pan/reset
add wave /tb_pan/btn
add wave -radix unsigned /tb_pan/angle
add wave /tb_pan/motor

add wave -divider "=== step_clk ==="
add wave /tb_pan/uut/div/cnt
add wave /tb_pan/uut/div/step_clk

add wave -divider "=== FSM ==="
add wave /tb_pan/uut/fsm/state
add wave /tb_pan/uut/fsm/wait_cnt
add wave /tb_pan/uut/fsm/en

add wave -divider "=== COUNTER ==="
add wave -radix unsigned /tb_pan/uut/counter/target
add wave -radix unsigned /tb_pan/uut/counter/count
add wave /tb_pan/uut/counter/done

add wave -divider "=== DRIVER ==="
add wave /tb_pan/uut/driver/seq
add wave /tb_pan/uut/driver/phases

# 8 TC x ~250 us + overhead ~ 2500 us
run 2500us
wave zoom full
