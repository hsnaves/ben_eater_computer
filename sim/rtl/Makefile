CXX       := g++
FBDIR     := .
VDIRFB    := $(FBDIR)/obj_dir
RTLDIR    := ../../rtl
VERILATOR := verilator
VFLAGS    := -Wall --MMD --trace -y $(RTLDIR) -cc
RM        := rm -rf

.PHONY: verilate
verilate: top
top: $(VDIRFB)/Vtop__ALL.a

$(VDIRFB)/Vtop__ALL.a:   $(VDIRFB)/Vtop.cpp

$(VDIRFB)/V%.mk:  $(VDIRFB)/%.h
$(VDIRFB)/V%.h:   $(VDIRFB)/%.cpp
$(VDIRFB)/V%.cpp: $(FBDIR)/%.v
	$(VERILATOR) $(VFLAGS) $*.v

$(VDIRFB)/V%__ALL.a: $(VDIRFB)/V%.cpp
	cd $(VDIRFB); $(MAKE) -f V$*.mk

.PHONY: clean
clean:
	$(RM) $(VDIRFB)/
