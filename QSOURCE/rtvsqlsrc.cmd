 RTVSQLSRC:  CMD        PROMPT('Retrieve SQL Source')
             /* Command processing program is: RTVSQLSRC  */
             PARM       KWD(FILE) TYPE(QUAL) MIN(1) PROMPT('File name')
 QUAL:       QUAL       TYPE(*NAME) MIN(1) EXPR(*YES)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*CURLIB) (*LIBL)) +
                          MIN(0) EXPR(*YES) PROMPT('Library')
             PARM       KWD(SRCFILE) TYPE(SRCFILE) PROMPT('Source file +
                          name')
 SRCFILE:    QUAL       TYPE(*NAME) DFT(QSQLSRC) EXPR(*YES)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*CURLIB) (*LIBL)) +
                          MIN(0) EXPR(*YES) PROMPT('Library')
             PARM       KWD(SRCMBR) TYPE(*NAME) DFT(*FILE) SPCVAL((*FILE)) +
                          EXPR(*YES) PROMPT('Source member')
             PARM       KWD(REPLACE) TYPE(*LGL) DFT(*YES) SPCVAL((*YES +
                          '1') (*NO '0') (*ON '1') (*OFF '0') (*REPLACE +
                          '1') (*NOREPLACE '0')) EXPR(*YES) +
                          PROMPT('Replace source member')
             PARM       KWD(NAMING) TYPE(*CHAR) LEN(3) RSTD(*YES) +
                          DFT(*SYS) SPCVAL((*SYS 'SYS') (*SQL 'SQL')) +
                          EXPR(*YES) PROMPT('Qualified name syntax')
             PARM       KWD(SQLLVL) TYPE(*INT2) RSTD(*YES) DFT(*SYS) +
                          SPCVAL((*SYS 0) (*DB2SQL 1) (*ANSISQL 2)) +
                          PROMPT('SQL Standards syntax')
             PARM       KWD(GENDROP) TYPE(*LGL) RSTD(*YES) DFT(*NO) +
                          SPCVAL((*NO '0') (*YES '1')) EXPR(*YES) +
                          PROMPT('Generate DROP file statement')
             PARM       KWD(COMMENT) TYPE(*LGL) RSTD(*YES) DFT(*YES) +
                          SPCVAL((*YES '1') (*NO '0')) EXPR(*YES) +
                          PROMPT('Generate header comments')
             PARM       KWD(MSGLVL) TYPE(*INT2) DFT(30) RANGE(0 39) +
                          PROMPT('Message generation level')
             PARM       KWD(SEVLVL) TYPE(*INT2) RSTD(*YES) DFT(30) +
                          VALUES(0 10 20 30 40) PROMPT('Error severity +
                          level to fail')
