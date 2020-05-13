# Tremolo Makefile for Windows CE port
# Uses the VLC toolchain
# $URL$
# $Id$

sdk_gcc_root = $(DEVKITARM)
srcdir    = .
VPATH     = $(srcdir)

CC     = $(DEVKITARM)/bin/arm-none-eabi-gcc
CXX    = $(DEVKITARM)/bin/arm-none-eabi-g++
LD     = $(DEVKITARM)/bin/arm-none-eabi-g++
AR     = $(DEVKITARM)/bin/arm-none-eabi-ar cru
RANLIB = $(DEVKITARM)/bin/arm-none-eabi-ranlib
STRIP  = $(DEVKITARM)/bin/arm-none-eabi-strip
RANLIB = $(DEVKITARM)/bin/arm-none-eabi-ranlib
WINDRES= $(DEVKITARM)/bin/arm-none-eabi-windres
MKDIR  = mkdir -p
RM     = rm -f
RM_REC = rm -rf
ECHO   = echo -n
CAT    = cat
AS     = $(DEVKITARM)/bin/arm-none-eabi-as

DEFINES := 

CFLAGS := -g -O3 -mcpu=arm7tdmi -mtune=arm7tdmi -I$(srcdir) -I$(sdk_gcc_root)/include -D_ARM_ASSEM_ -static \
        -ffast-math \
        -falign-functions=4

CXXFLAGS := $(CFLAGS)

LDFLAGS := -Llibs/lib -L$(sdk_gcc_root)/lib
LIBS := --entry WinMainCRTStartup

OBJS := 
MODULE_DIRS += .

OUTPUT_LIB = libTremolo008.a

LIBOBJS := bitwise.o bitwiseARM.o codebook.o dpen.o dsp.o floor0.o \
           floor1.o floor1ARM.o floor_lookup.o framing.o info.o mapping0.o \
           mdct.o mdctARM.o misc.o res012.o vorbisfile.o speed.o
EXEOBJS := testtremor.o

LIBOBJS_C := bitwise.oc codebook.oc dsp.oc floor0.oc floor1.oc \
             floor_lookup.oc framing.oc info.oc mapping0.oc mdct.oc misc.oc \
             res012.oc vorbisfile.oc speed.o
EXEOBJS_C := testtremor.oc

LIBOBJS_L := bitwise.ol bitwiseARM.o codebook.ol dpen.o dsp.ol floor0.ol \
             floor1.ol floor1LARM.o floor_lookup.ol framing.ol info.ol mapping0.ol \
             mdct.ol mdctLARM.o misc.ol res012.ol vorbisfile.ol speed.o
EXEOBJS_L := testtremor.ol

LIBOBJS_LC := bitwise.olc codebook.olc dsp.olc floor0.olc floor1.olc \
              floor_lookup.olc framing.olc info.olc mapping0.olc mdct.olc misc.olc \
              res012.olc vorbisfile.olc speed.o
EXEOBJS_LC := testtremor.olc

# Rules
.SUFFIXES: .oc .ol .olc

.c.oc:
	$(CC) $(CFLAGS) -c $(<) -o $*.oc -DONLY_C

.c.ol:
	$(CC) $(CFLAGS) -c $(<) -o $*.ol -D_LOW_ACCURACY_

.c.olc:
	$(CC) $(CFLAGS) -c $(<) -o $*.olc -D_LOW_ACCURACY_ -DONLY_C

all: $(OUTPUT_LIB)

# bittest.exe testtremor.exe testtremorC.exe testtremorL.exe testtremorLC.exe annotate.exe

install: all
	cp $(OUTPUT_LIB) /cygdrive/c/cvs/scummvm/trunk/backends/platform/wince/libs/lib/
	cp ivorbisfile.h /cygdrive/c/cvs/scummvm/trunk/backends/platform/wince/libs/include/tremolo006/tremor/
	cp config_types.h /cygdrive/c/cvs/scummvm/trunk/backends/platform/wince/libs/include/tremolo006/
	cp ivorbiscodec.h /cygdrive/c/cvs/scummvm/trunk/backends/platform/wince/libs/include/tremolo006/
	cp ogg.h /cygdrive/c/cvs/scummvm/trunk/backends/platform/wince/libs/include/tremolo006/
	cp os_types.h /cygdrive/c/cvs/scummvm/trunk/backends/platform/wince/libs/include/tremolo006/

$(OUTPUT_LIB): $(LIBOBJS)
	$(AR) $@ $^
	$(RANLIB) $@

bitwiseTEST.o: bitwise.c
	$(CC) $(CFLAGS) -c -o bitwiseTEST.o bitwise.c -D_V_BIT_TEST

bittest.exe: bitwiseTEST.o bitwiseARM.o dpen.o
	$(LD) $^ $(LDFLAGS) $(LIBS) -o $@ -Wl,-Map,bittest.exe.map -Wl,--stack,65536

testtremor.exe: testtremor.o profile.o $(LIBOBJS)
	$(LD) $^ $(LDFLAGS) $(LIBS) -o $@ -Wl,-Map,testtremor.exe.map -Wl,--stack,65536 -debug

testtremorC.exe: testtremor.oc profile.o $(LIBOBJS_C)
	$(LD) $^ $(LDFLAGS) $(LIBS) -o $@ -Wl,-Map,testtremorC.exe.map -Wl,--stack,65536

testtremorL.exe: testtremor.ol profile.o $(LIBOBJS_L)
	$(LD) $^ $(LDFLAGS) $(LIBS) -o $@ -Wl,-Map,testtremorL.exe.map -Wl,--stack,65536

testtremorLC.exe: testtremor.olc profile.o $(LIBOBJS_LC)
	$(LD) $^ $(LDFLAGS) $(LIBS) -o $@ -Wl,-Map,testtremorLC.exe.map -Wl,--stack,65536

annotate.exe: annotate.c
	gcc $^ -o $@

clean:
	rm -f *.o *.ol *.oc *.olc
