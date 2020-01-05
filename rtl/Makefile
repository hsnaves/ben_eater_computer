CXX       := g++
FBDIR     := .
VDIRFB    := $(FBDIR)/obj_dir
VERILATOR := verilator
VFLAGS    := -Wall --MMD --trace -cc
RM        := rm -rf

.PHONY: all
all: verilate

.PHONY: verilate
verilate: $(VDIRFB)/Vcomputer__ALL.a

$(VDIRFB)/Vcomputer__ALL.a: $(VDIRFB)/Vcomputer.cpp

$(VDIRFB)/V%.mk:  $(VDIRFB)/%.h
$(VDIRFB)/V%.h:   $(VDIRFB)/%.cpp
$(VDIRFB)/V%.cpp: $(FBDIR)/%.v
	$(VERILATOR) $(VFLAGS) $*.v

$(VDIRFB)/V%__ALL.a: $(VDIRFB)/V%.mk
	cd $(VDIRFB); $(MAKE) -f V$*.mk

.PHONY: clean
clean:
	$(RM) $(VDIRFB)/
