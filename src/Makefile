# Makefile for MPCM

ifeq ($(notdir $(CURDIR)),src)
$(error do not execute make in src directory)
endif

SRCDIR_MK = ../srcdir.mk
SRC_DIR = ../src
-include $(SRCDIR_MK)

AS = has060
ASFLAGS = -w2 -c3 -i./include
LD ?= hlk
LDFLAGS =

SRCS = 

TARGET = mpcm.x p8emu.x


.PHONY: all
.PRECIOUS: %.o

all: $(TARGET)

# %.x: %.s
%.o: %.s
	$(AS) $(ASFLAGS) -o$@ $<
%.x: %.o
	$(LD) $(LDFLAGS) -o$@ $<


mpcm.o: adp_0101.s adp_0102.s adp_0103.s adp_0104.s adp_0203.s adp_effect.s adp_high.s adp_low.s \
        p16_0101.s p16_0102.s p16_0103.s p16_0104.s p16_0203.s p16_effect.s p16_high.s p16_low.s \
        p8_0101.s p8_0102.s p8_0103.s p8_0104.s p8_0203.s p8_effect.s p8_high.s p8_low.s \
        mpcmcall.mac mpcm_prg.mac

p8emu.o: p8emu.s


# EOF
