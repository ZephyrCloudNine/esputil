CFLAGS ?= -W -Wall -Wextra -Wundef -Wshadow -Wdouble-promotion -Os $(EXTRA_CFLAGS)
PROG ?= esputil
BINDIR ?= .
CWD ?= $(realpath $(CURDIR))
DOCKER = docker run $(DA) --rm -e Tmp=. -e WINEDEBUG=-all -v $(CWD):$(CWD) -w $(CWD)
SERIAL_PORT ?= /dev/ttyUSB0
MIPS_CC = binutils/toolchain-mips_24kc_gcc-8.4.0_musl/bin/mips-openwrt-linux-gcc
MIPS_BIN_EXE = esputil-mips24kc

all: $(PROG)

$(PROG): esputil.c
	$(CC) $(CFLAGS) $? -o $(BINDIR)/$@

esputil.exe: esputil.c
	$(DOCKER) mdashnet/vc98 wine cl /nologo /W3 /MD /Os $? ws2_32.lib /Fe$@

wintest: esputil.exe
	ln -fs $(SERIAL_PORT) ~/.wine/dosdevices/com55 && wine $? -p '\\.\COM55' -v info

clean:
	rm -rf esputil $(PROG) *.dSYM *.o *.obj _CL* *.exe

compile-mips24kc:
	$(MIPS_CC) $(CFLAGS) $? -o $(BINDIR)/$(MIPS_BIN_EXE) esputil.c