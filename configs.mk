################################################################################
# User parameters begin

# Project directory
proj_dir = $(PWD)

# HW design parameters
hw_design_name=bd_wrapper
BOARD ?= ZCU104 # cannot be changed

######### Xilinx tools

XILINX_TOOLS 	 ?= /tools/Xilinx
XILINX_VERSION ?= 2019.2
export XILINX_VIVADO := $(XILINX_TOOLS)/Vivado/$(XILINX_VERSION)
export XILINX_VITIS  := $(XILINX_TOOLS)/Vitis/$(XILINX_VERSION)

HLS 		=$(XILINX_VIVADO)/bin/vivado_hls
XVLOG		=$(XILINX_VIVADO)/bin/xvlog
XELAB		=$(XILINX_VIVADO)/bin/xelab
XSIM 		=$(XILINX_VIVADO)/bin/xsim

XSCT 		=$(XILINX_VITIS)/bin/xsct
BOOTGEN =$(XILINX_VITIS)/bin/bootgen

################################################################################
# Escape colors for printing messages
export BLUE 	=\033[0;34m
export GREEN	=\033[0;32m
export CYAN 	=\033[0;36m
export RST	  =\033[0m

# use ${ } for getting a 'space'
null :=
space := ${null} ${null}
${space} := ${space}# ${ } is a space

# use ${\n} for getting a 'newline'
define \n


endef

################################################################################
# vivado tools loggings

# provide the logfile to be grepped
ignore_comp_infos=grep -svE "\[VRFC 10-2263\]|\[VRFC 10-311\]" $(1) | \
		grep -sEi --color=always "ERROR|WARNING|undeclared"

################################################################################

define print_rule =
	printf "${CYAN}[%-10s] %s ...${RST}\n" $@ $1
endef

define print_help =
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | \
		awk 'BEGIN {FS = ":.*?## "}; \
		{printf "${CYAN}%-15s ${RST}%s\n", $$1, $$2}'
endef
