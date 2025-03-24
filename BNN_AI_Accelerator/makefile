# VCS
VCS = vcs -full64 -LDFLAGS -Wl,-no-as-needed
DEFINE_VPD = +define+DUMP_VPD
DEFINE_DSDB = +define+DUMP_FSDB
DEFINE_GATE = +define+GATE_DEBUG

# DVE
DVE = dve -full64

# Simulation Timescale
TIMESCALE = timescale=10ps/1ps


all: com sim open_verdi
	
gen_flist: 
	find -wholename "./rtl/*.v" > filelist.f

com:	
	$(VCS) +v2k -sverilog \
	-f filelist.f \
	-debug_access+all \
	-$(TIMESCALE) \
	-l com.log \
	$(DEFINE_DSDB) \
	+warn=all

sim:
	./simv -l sim.log

clean: clean_com clean_sim clean_verdi
	rm -rf *.log

clean_com:
	rm -rf csrc simv.daidir simv com.log

clean_sim:
	rm -rf *.key *.fsdb *.vcd *.vpd DVEfiles NOVAS_dump.log sim.log

clean_verdi:
	rm -rf ./verdiLog ./novas.*

open_dve :
	$(DVE) -vpd ./sim_output_pluson.vpd &

open_verdi:
	verdi +v2k -sverilog -f filelist.f -ssf ./sim_output_pluson.fsdb -sswr ./signal.rc &

resim: com sim

gate_com:
	$(VCS) +v2k -sverilog \
	-f filelist_gate.f \
	-o gate_simv \
	-debug_access+all \
	-$(TIMESCALE) \
	-l com.log \
	$(DEFINE_GATE) \
	$(DEFINE_DSDB) \
	+warn=all +lint=all +lint=TFIPC-L \
	+notimingchecks +nospecify

gate_sim:
	./gate_simv -l sim.log

gate_verdi:
	verdi +v2k -sverilog -f filelist.f -ssf ./sim_output_pluson.fsdb -sswr ./gate.rc &

gate_resim: gate_com gate_sim

gate: gate_com gate_sim gate_verdi

post_com:
	$(VCS) -sverilog \
	./post/ic.output1.v ./dc/scc018ug_uhd_rvt.v ./dc/SP018WP_V1p1.v ./rtl/top_tb_weight.v \
	-o post_simv \
	-debug_access+all \
	-$(TIMESCALE) \
	-sdf max:top_pad:./post/ic.sdf +neg_tchk -negdelay -R -diag=sdf:verbose +iopath+edge+max \
	$(DEFINE_GATE) \
	$(DEFINE_DSDB)