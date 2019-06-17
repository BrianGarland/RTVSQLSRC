NAME=Retrieve SQL Source
BIN_LIB=RTVSQLSRC
DBGVIEW=*SOURCE
TGTRLS=V7R3M0

#----------

all: rtvsqlsrc.rpgle rtvsqlsrc.cmd
	@echo "Built all"

#----------

%.rpgle:
	system "CRTBNDRPG PGM($(BIN_LIB)/$*) SRCSTMF('QSOURCE/$*.rpgle') TEXT('$(NAME)') REPLACE(*YES) DBGVIEW($(DBGVIEW)) TGTRLS($(TGTRLS))"

%.cmd:
	-system -qi "CRTSRCPF FILE($(BIN_LIB)/QSOURCE) MBR($*) RCDLEN(112)"
	system "CPYFRMSTMF FROMSTMF('QSOURCE/$*.cmd') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QSOURCE.file/$*.mbr') MBROPT(*REPLACE)"
	system "CRTCMD CMD($(BIN_LIB)/$*) PGM($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QSOURCE) SRCMBR($*) TEXT('$(NAME)')"
	-system -qi "DLTF FILE($(BIN_LIB)/QSOURCE)"
	
clean:
	system "CLRLIB $(BIN_LIB)"