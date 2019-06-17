      ** Program name: RTVSQLSRC
      ** Download the latest version at:
      **     http://www.rpgiv.com/newsletter
      **
      ** Original source by Robert Cozzi 8/19/2003
      **     No license info mentioned
      **
      ** Changes by Brian Garland 06/17/2019
      **     Additional API fields updated as this was failing on an IBM i 7.3 server
      **
     H BNDDIR('QC2LE') OPTION(*SRCSTMT:*NODEBUGIO)
     H DFTACTGRP(*NO)

     D RtvSQLSrc       PR
     D  FileLib                      20A
     D  SrcFileLib                   20A
     D  Srcmbr                       10A
     D  bReplace                      1N   OPTIONS(*NOPASS)
     D  szNaming                      3A   OPTIONS(*NOPASS)
     D  nStandard                     5I 0 OPTIONS(*NOPASS)
     D  bDrop                         1N   OPTIONS(*NOPASS)
     D  bHeader                       1N   OPTIONS(*NOPASS)
     D  nMsgLvl                       5I 0 OPTIONS(*NOPASS)
     D  nSevLvl                       5I 0 OPTIONS(*NOPASS)
     D RtvSQLSrc       PI
     D  FileLib                      20A
     D  SrcFileLib                   20A
     D  Srcmbr                       10A
     D  bReplace                      1N   OPTIONS(*NOPASS)
     D  szNaming                      3A   OPTIONS(*NOPASS)
     D  nStandard                     5I 0 OPTIONS(*NOPASS)
     D  bDrop                         1N   OPTIONS(*NOPASS)
     D  bHeader                       1N   OPTIONS(*NOPASS)
     D  nMsgLvl                       5I 0 OPTIONS(*NOPASS)
     D  nSevLvl                       5I 0 OPTIONS(*NOPASS)
     D SafeAddMbr      PR
     D  SrcFileLib                   20A   Value
     D  SrcMbr                       10A   Value

     D system          PR                  extproc('system')
     D  szCMDString                    *   OPTIONS(*STRING) VALUE

     D  apiError       DS                  Inz
     D   errDSLen                    10I 0 Inz(%size(apiError))
     D   errRtnLen                   10I 0 Inz
     D   errMsgID                     7A   Inz(*ALLX'00')
     D   errReserved                  1A   Inz(X'00')
     D   errMsgData                  64A   Inz(*ALLX'00')

      /COPY QSYSINC/QRPGLESRC,QSQGNDDL
      /COPY QSYSINC/QRPGLESRC,QUSROBJD

     D pFileLib        S               *
     D InFileLib       DS                  BASED(pFileLib)
     D  InFile                       10A
     D  InLib                        10A
     D pSrcFileLib     S               *
     D InSrcFileLib    DS                  BASED(pSrcFileLib)
     D  SrcFile                      10A
     D  SrcLib                       10A

     D QRtvOBJD        PR                  Extpgm('QUSROBJD')
     D  rtnData                            LIKE(QUSD0200)
     D  rtnLen                       10I 0 Const
     D  odFormat                      8A   Const
     D  ObjLib                       20A   Const
     D  ObjType                      10A   Const
     D  apiErrorDS                         Like(ApiError)

     D  InReplace      S              1N   Inz('1')
     D  InNaming       S              3A   Inz('SYS')
     D  inMsgLvl       S              5I 0 Inz(30)
     D  inSevLvl       S              5I 0 Inz(30)
     D  inStandard     S              5I 0 Inz(0)
     D  inDrop         S              1N   Inz('0')
     D  inHeader       S              1N   Inz('1')

     D FileType        S                   Like(QUSEoA05)
     D SQLTempl        S                   Like(QSQR0100)
     D QRtvSQLSrc      PR                  Extpgm('QSQGNDDL')
     D  sqTempl                            Like(QSQR0100)
     D  sqtLen                       10I 0 Const
     D  sqFormat                      9A   Const
     D  apiError                     16A

     C                   eval      *INLR = *ON

     C                   eval      pFileLib = %addr(FileLib)
     C                   eval      pSrcFileLIb = %addr(SrcFileLib)

     C                   if        srcmbr = '*FILE'
     C                   eval      srcmbr = InFile
     C                   endif
      ** Copy the input parms to their variables, if specified.
     C                   if        %parms >= 4
     C                   eval      InReplace = bReplace
     C                   if        %parms >= 5
     C                   eval      InNaming = szNaming
     C                   if        %parms >= 6
     C                   eval      InStandard= nStandard
     C                   if        %parms >= 7
     C                   eval      InDrop = bDrop
     C                   if        %parms >= 8
     C                   eval      InHeader = bHeader
     C                   if        %parms >= 9
     C                   eval      inMsgLvl = nMsgLvl
     C                   if        %parms >= 10
     C                   eval      InSevLvl = nSevLvl
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif

      ** Retrieve the file attribute (LF or PF)
     C                   callp     qrtvobjd(QUSD0200 : %Len(QUSD0200) :
     C                                 'OBJD0200' : FileLIb :'*FILE':apiError)

     C                   if        %subst(errMSGID:1:5) = 'CPF98'
     C** Failed - Source file not found. :(
     C                   return
     C                   endif

      ** Does the member exist? It has to or this stupid API won't work!
     C                   callp     SafeAddMbr(InSrcFileLib : SrcMbr)
     C

     C                   eval      FileType = QUSEoA05
     C                   CLEAR                   QSQR0100
     C                   eval      qsqOBJN = InFile
     C                   eval      qsqOBJL = inLib
     C                   select
     C                   when      FileType = 'PF'
     C                   eval      qsqObjT = 'TABLE'
     C                   when      FileType = 'LF'
     C                   eval      qsqObjT = 'VIEW'
     C                   endsl

     C                   eval      qsqSFilN = SrcFile
     C                   eval      qsqSFilL = SrcLib
     C                   eval      qsqSFilM = SrcMbr
     C
     C                   eval      qsqSL02 = InSevLvl
     C                   eval      qsqRo   = InReplace
     C                   eval      qsqNo02 = InNaming
     C                   eval      qsqML02 = InMsgLvl
     C                   eval      qsqSFo  = '0'
     C                   eval      qsqDF02 = 'ISO'
     C                   eval      qsqTF02 = 'ISO'
     C                   eval      qsqDS02 = ' '
     C                   eval      qsqTS02 = ' '
     C                   eval      qsqDP02 = '.'
     C                   eval      qsqSo01 = %char(InStandard)
     C                   eval      qsqDo   = InDrop
     C                   eval      qsqCo   = '1'
     C                   eval      qsqLo   = '1'
     C                   eval      qsqHo   = InHeader
     C                   eval      qsqTo   = '1'
     C                   eval      qsqCo00 = '2'
     C                   eval      qsqSno  = '1'
     C                   eval      qsqPro  = '0'
     C                   eval      qsqcco  = '0'
     C                   eval      qsqcro  = '1'
     C                   eval      qsqobo  = '0'
     C                   eval      qsqaro  = '0'
     C                   eval      qsqMpo  = '0'
     C                   eval      qsqQno  = '1'
     C                   eval      qsqAoo  = '1'
     C                   eval      qsqIvo  = '0'

      **  Copy the data structure to our local data structure
      **  Note: When everyone is on V5R1 and later, we can use
      **        a qualified data structure instead.
     C                   eval      sqltempl = Qsqr0100
     C                   CallP     qrtvsqlsrc(sqltempl : %Len(QSQR0100) :
     C                                 'SQLR0100' : apiError)
     C
     C                   return

     P SafeAddMbr      B                   Export
     D SafeAddMbr      PI
     D  SrcFileLib                   20A   Value
     D  SrcMbr                       10A   Value

     D InSrcFileLib    DS
     D  SrcFile                      10A
     D  SrcLib                       10A

     ** The structure returned by the QusRMBRD API.
     D szMbrd0100      DS                  INZ
     D  nBytesRtn                    10I 0
     D  nBytesAval                   10I 0
     D  szFileName                   10A
     D  szLibName                    10A
     D  szMbrName                    10A
     D  szFileAttr                   10A
     D  szSrcType                    10A
     D  dtCrtDate                    13A
     D  dtLstChg                     13A
     D  szMbrText                    50A
     D  bIsSource                     1A
     D CPF_MbrNotFound...
     D                 C                   CONST('CPF9815')
     **----------------------------------------------------------------
     ** Input Parameters to the QUSRMBRD API
     **----------------------------------------------------------------
     **  Tells the APIs how long the buffers are that are being used.
     D nBufLen         S             10I 0
     ** Format to be returned
     D Format          S              8A   Inz('MBRD0100')
     ** Whether or not to ignore overrides (0=Ignore, 1 = Apply)
     D bOvr            S              1A   Inz('0')

     C                   eval      InSrcFileLib = SrcFileLib

     **----------------------------------------------------------------
     C                   Reset                   apiError
     C                   Eval      nBufLen = %size(szMbrD0100)
     **----------------------------------------------------------------
     C                   Call      'QUSRMBRD'
     C                   Parm                    szMbrD0100
     C                   Parm                    nBufLen
     C                   Parm                    Format
     C                   Parm                    SrcFileLIb
     C                   Parm                    SrcMbr
     C                   Parm                    bOvr
     C                   Parm                    apiError

      ** If the member doesn't exist, add it; otherwise, just return.
     C                   if        errRtnLen > 0
     C                   if        errMsgID = CPF_MbrNotFound or
     C                             errMsgID = 'CPF3019' or
     C                             errMsgID = 'CPF32DE' or
     C                             errMsgID = 'CPF3C27' or
     C                             errMsgID = 'CPF3C26'
     C                   callp     system('ADDPFM FILE(' + %TrimR(srcLib) + '/'
     C                               + srcfile + ') MBR(' + srcmbr + ')')
     C                   endif
     C                   endif
     C                   return
     P SafeAddMbr      E