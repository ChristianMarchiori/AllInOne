*----------------------------------------------------------------
* RDBASE - MIMICS DBASE COMMANDS
* José Quintas - 1999
*----------------------------------------------------------------

* 2015.04.01.1300 - Browse não mais bloqueia arquivo
* 2015.06.18.2011 - Mensagem ref. comandos pra alterar estrutura
* 2015.07.08.1910 - Correção ref default de escopo só quando análise de escopo
* 2015.07.13.0950 - RECALL usando mesmos parâmetros de DELETE
* 2015.09.05.1315 - Correção chamada cmdEdit() em cmdAppend()
* 2015.10.04.1720 - Browse em rede, ou bloqueia arquivo, ou altera Harbour
* 2015.10.30.1600 - Keyboard compare using inkey.ch
* 2015.10.30.1610 - Prevent from too many lines, in standalone use
*----------------------------------------------------------------

#include "inkey.ch"
#include "hbclass.ch"
#include "hbgtinfo.ch"

MEMVAR DB_EXCLUSIVE, DB_ODOMETER
MEMVAR DB_SCOPE_ALL, DB_SCOPE_NEXT, DB_SCOPE_FOR, DB_SCOPE_WHILE, DB_SCOPE_RECORD
MEMVAR cEmptyValue
MEMVAR m_Name, m_Opc, m_Row, m_Item, m_IniVet, acStructure
MEMVAR m_Expr, m_Campo, lChanged, m_Posi
MEMVAR m_NomVar, m_Conte, cFileName, Ret_Val, Mode
MEMVAR Line, Col, m_Col, Opc, IniVet, Modo

PROCEDURE RDBASE

   LOCAL   nCont, GetList := {}, nKey, acCmdList := {}, nCmdPos := 0, cTextToAnalize, mComando
   PRIVATE DB_EXCLUSIVE, DB_ODOMETER
   PRIVATE DB_SCOPE_ALL, DB_SCOPE_NEXT, DB_SCOPE_FOR, DB_SCOPE_WHILE, DB_SCOPE_RECORD

   IF AppMultiWindow()
      hb_gtReLoad( hb_GTInfo( HB_GTI_VERSION ) )
      SetMode( 30, 60 )
      CLS
      HB_GtInfo( HB_GTI_ICONRES, "AppIcon" )
      HB_GtInfo( HB_GTI_WINTITLE, "Calculator" )
      HarbourInit()
   ENDIF
   DB_EXCLUSIVE := .F.
   DB_ODOMETER  := 100

   CLOSE DATABASES // pode ter algum aberto
   MsgWarning( "Atention! If you don't know Foxpro command, don't use it!" + HB_EOL() + ;
      "Depending on changes, use REINDEX option." + HB_EOL() + ;
      "type QUIT when work finished" )
   FOR nCont = 1 TO MaxRow()
      SayScroll()
   NEXT
   Mensagem( "Type command and <ENTER>, or QUIT to exit" )
   cTextToAnalize := ""
   DO WHILE .T.
      cTextToAnalize := Pad( cTextToAnalize, 200 )
      @ MaxRow() - 3, 0 GET cTextToAnalize PICTURE "@S" + Ltrim( Str( MaxCol() - 1 ) )
      READ
      nKey := LastKey()
      DO CASE
      CASE LastKey() == K_ESC
         LOOP
      CASE nKey = K_UP
         IF Len( acCmdList ) >= 1 .AND. nCmdPos >= 1
            cTextToAnalize  := acCmdList[ nCmdPos ]
            nCmdPos := iif( nCmdPos <= 1, 1, nCmdPos - 1 )
         ENDIF
         LOOP
      CASE nKey = K_DOWN
         IF nCmdPos < Len( acCmdList )
            nCmdPos += 1
            cTextToAnalize := acCmdList[ nCmdPos ]
         ENDIF
         LOOP
      CASE Empty( cTextToAnalize )
         LOOP
      ENDCASE
      SayScroll()
      cTextToAnalize := Trim( cTextToAnalize )
      Aadd( acCmdList, AllTrim( cTextToAnalize ) )
      nCmdPos := Len( acCmdList )
      // cTextToAnalize  := AllTrim( &( cTextToAnalize ) )
      GravaOcorrencia( ,, "(*)" + cTextToAnalize )
      mComando := Lower( Trim( Left( ExtractParameter( @cTextToAnalize, " " ), 4 ) ) )
      DO CASE
      CASE mComando == "!"      ;  cmdRun( cTextToAnalize )
      CASE mComando == "?"      ;  cmdPrint( cTextToAnalize )
      CASE mComando == "appe"   ;  cmdAppend( cTextToAnalize )
      CASE mComando == "brow"   ;  cmdBrowse()
      CASE mComando == "clea"   ;  Scroll( 2, 0, MaxRow() - 3, MaxCol(), 0 )
      CASE mComando == "clos"   ;  CLOSE DATABASES
      CASE mComando == "cont"   ;  cmdContinue()
      CASE mComando == "copy"   ;  cmdCopy( cTextToAnalize )
      CASE mComando == "crea"   ;  cmdCreate( cTextToAnalize )
      CASE mComando == "dele"   ;  cmdDelete( cTextToAnalize )
      CASE mComando == "dir"    ;  cmdDir( cTextToAnalize )
      CASE mComando == "disp"   ;  cmdList( cTextToAnalize, mComando )
      CASE mComando == "edit"   ;  cmdEdit( cTextToAnalize )
      CASE mComando == "ejec"   ;  EJECT
      CASE mComando == "go"     ;  cmdGoTo( cTextToAnalize )
      CASE mComando == "goto"   ;  cmdGoto( cTextToAnalize )
      CASE Type( mComando ) == "N" .AND. Empty( cTextToAnalize ) ; cmdGoTo( cTextToAnalize )
      CASE mComando == "inde"   ;  cmdIndex( cTextToAnalize )
      CASE mComando == "list"   ;  cmdList( cTextToAnalize, mComando )
      CASE mComando == "loca"   ;  cmdLocate( cTextToAnalize )
      CASE mComando == "modi"   ;  cmdModify( cTextToAnalize )
      CASE mComando == "pack"   ;  cmdPack()
      CASE mComando == "quit"   ;  EXIT
      CASE mComando == "reca"   ;  cmdRecall( cTextToAnalize )
      CASE mComando == "rein"   ;  cmdReindex()
      CASE mComando == "repl"   ;  cmdReplace( cTextToAnalize )
      CASE mComando == "run"    ;  cmdRun( cTextToAnalize )
      CASE mComando == "seek"   ;  cmdSeek( cTextToAnalize )
      CASE mComando == "sele"   ;  cmdSelect( cTextToAnalize )
      CASE mComando == "set"    ;  cmdSet( cTextToAnalize )
      CASE mComando == "skip"   ;  cmdSkip( cTextToAnalize )
      CASE mComando == "stor"   ;  cmdStore( cTextToAnalize )
      CASE mComando == "sum"    ;  cmdSum( cTextToAnalize )
      CASE mComando == "tota"   ;  cmdTotal( cTextToAnalize )
      CASE mComando == "unlo"   ;  cmdUnLock( cTextToAnalize )
      CASE mComando == "use"    ;  cmdUse( cTextToAnalize )
      CASE mComando == "zap"    ;  cmdZap()
      CASE Left( cTextToAnalize, 1 ) == "="
         cTextToAnalize := Substr( cTextToAnalize, 2 ) + " to " + mComando
         cmdStore( cTextToAnalize )
      OTHERWISE
         SayScroll( "Invalid command" )
      ENDCASE
      SayScroll()
      cTextToAnalize := ""
   ENDDO
   CLOSE DATABASES
   SET UNIQUE    OFF
   SET EXCLUSIVE OFF
   SET DELETED   ON
   SET CONFIRM   ON
   MsgWarning( "Remember your changes, can be needed REINDEX option" )
   RETURN


FUNCTION ExtractParameter( cTextCmd, mTipo, mLista )

   LOCAL mCont, mParametro, m_Procu, m_Inicio, m_Final, mContFor, mContWhil, m_Posi, mContReco, mContNext, mContAll, mContIni, mTemp, mContFim

   cTextCmd        := AllTrim( cTextCmd )

   DO CASE
   CASE mTipo == " "  .OR. mTipo == ","
      mParametro := Substr( cTextCmd, 1, At( mTipo, cTextCmd + mTipo ) - 1 )
      cTextCmd   := Substr( cTextCmd, At( mTipo, cTextCmd + mTipo ) + 1 )
      mParametro := AllTrim( mParametro )
      cTextCmd   := AllTrim( cTextCmd )
      RETURN mParametro

   CASE mTipo == "alias"
      cTextCmd := " " + cTextCmd + " "
      mContini := At( " alias ", cTextCmd )
      IF mContini == 0
         RETURN ""
      ENDIF
      mContfim := mContini + 7
      DO WHILE Substr( cTextCmd, mContfim, 1 ) == " " .AND. mContfim < len( cTextCmd )
         mContFim := mContfim + 1
      ENDDO
      mParametro := AllTrim( ExtractParameter( Substr( cTextCmd, mContfim ), " " ) )
      cTextCmd   := Substr( cTextCmd, 1, mContini ) + Substr( cTextCmd, mContfim + Len( mParametro ) + 1 )
      cTextCmd   := AllTrim( cTextCmd )
      RETURN mParametro

   CASE mTipo == "set"
      mParametro := ""
      IF Lower( cTextCmd ) == "on"
         mParametro := .T.
      ELSEIF Lower( cTextCmd ) == "off"
         mParametro := .F.
      ELSEIF Type( cTextCmd ) == "L"
         mParametro := &cTextCmd
      ENDIF
      RETURN mParametro

   CASE mTipo == "par,"
      mParametro := 0
      mLista := {}
      DO WHILE Len( cTextCmd ) > 0
         mTemp := ""
         DO WHILE Len( cTextCmd ) > 0
            mContini := At( ",", cTextCmd + "," )
            mTemp    := mTemp + Substr( cTextCmd, 1, mContini - 1 )
            cTextCmd   := Substr( cTextCmd, mContini + 1 )
            IF Type( mTemp ) $ "NCDLM"
               EXIT
            ENDIF
            mTemp := mTemp + ","
         ENDDO
         mParametro = mParametro + 1
         Aadd( mLista, mTemp )
      ENDDO
      RETURN mParametro

   CASE mTipo == "escopo"
      DB_SCOPE_FOR    := ".T."
      DB_SCOPE_WHILE  := ".T."
      DB_SCOPE_NEXT   := 0
      DB_SCOPE_RECORD := 0
      DB_SCOPE_ALL    := .F.
      FOR mCont = 1 TO 5
         DO CASE
         CASE mCont = 1
            mTipo := "all"
         CASE mCont = 2
            mTipo := "next"
         CASE mCont = 3
            mTipo := "record"
         CASE mCont = 4
            mTipo := "for"
         CASE mCont = 5
            mTipo := "while"
         ENDCASE
         cTextCmd := " " + cTextCmd + " "
         m_Posi := Array(6)
         mContfor  := At( " for ", Lower( cTextCmd ) )
         mContwhil := At( " while ", Lower( cTextCmd ) )
         IF mContwhil == 0
            mContwhil := At( " whil ", Lower( cTextCmd ) )
         ENDIF
         mContall  := At( " all ",  Lower( cTextCmd ) )
         mContnext := At( " next ", Lower( cTextCmd ) )
         mContReco := At( " record ", Lower( cTextCmd ) )
         IF mContReco == 0
            mContReco := At( " recor ", Lower( cTextCmd ) )
            IF mContReco == 0
               mContReco := At( " reco ", Lower( cTextCmd ) )
            ENDIF
         ENDIF
         m_Posi[ 1 ] := mContall
         m_Posi[ 2 ] := mContnext
         m_Posi[ 3 ] := mContReco
         m_Posi[ 4 ] := Len( cTextCmd )
         m_Posi[ 5 ] := mContfor
         m_Posi[ 6 ] := mContwhil
         aSort( m_Posi )
         // retira parametro all
         DO CASE
         CASE mTipo == "all" .AND. mContall != 0
            DB_SCOPE_ALL := .T.
            //m_Inicio := aScan( m_Posi, mContall )
            //m_Final  := m_Posi[ m_Inicio + 1 ]
            cTextCmd   := Stuff( cTextCmd, mContall, 4, "" )
            // retira e valida parametro next

         CASE mTipo == "next" .AND. mContnext != 0
            m_Inicio := aScan( m_Posi, mContnext )
            m_Final  := m_Posi[ m_Inicio + 1 ]
            DB_SCOPE_NEXT := Substr( cTextCmd, mContnext + 1, m_Final - mContnext )
            cTextCmd   := Stuff( cTextCmd, mContnext, m_Final - mContnext, "" )
            DB_SCOPE_NEXT := Substr( DB_SCOPE_NEXT, At( " ", DB_SCOPE_NEXT ) )
            DB_SCOPE_ALL := .F.
            IF MacroType( DB_SCOPE_NEXT ) != "N"
               SayScroll( "Invalid NEXT" )
               RETURN .F.
            ENDIF
            IF &( DB_SCOPE_NEXT ) < 0
               SayScroll( "Invalid NEXT" )
               RETURN .F.
            ENDIF
            DB_SCOPE_NEXT = &( DB_SCOPE_NEXT )

         // retira e valida parametro record
         CASE mTipo=="record" .AND. mContReco != 0
            m_Inicio := aScan( m_Posi, mContReco )
            m_Final  := m_Posi[ m_Inicio + 1 ]
            DB_SCOPE_RECORD := Substr( cTextCmd, mContReco + 1, m_Final - mContReco )
            cTextCmd   := Stuff( cTextCmd, mContReco, m_Final - mContReco, "" )
            DB_SCOPE_RECORD := Substr( DB_SCOPE_RECORD, At( " ", DB_SCOPE_RECORD ) )
            IF MacroType( DB_SCOPE_RECORD ) != "N"
               SayScroll( "Invalid RECORD" )
               RETURN .F.
            ENDIF
            DB_SCOPE_RECORD := &( DB_SCOPE_RECORD )
            IF DB_SCOPE_RECORD  < 1 .OR. DB_SCOPE_RECORD > LastRec()
               SayScroll( "Record not exist" )
               RETURN .F.
            ENDIF

         // retira e valida parametro for
         CASE mTipo=="for" .AND. mContfor != 0
            m_Inicio := aScan( m_Posi, mContfor )
            m_Final  := m_Posi[ m_Inicio + 1 ]
            DB_SCOPE_FOR := Substr( cTextCmd, mContfor + 1, m_Final - mContfor )
            cTextCmd   := Stuff( cTextCmd, mContfor, m_Final - mContfor, "" )
            DB_SCOPE_FOR := Substr( DB_SCOPE_FOR, At( " ", DB_SCOPE_FOR ) )
            DB_SCOPE_ALL := .T.
            IF MacroType( DB_SCOPE_FOR ) != "L"
               SayScroll( "Invalid FOR" )
               RETURN .F.
            ENDIF
         // retira e valida parametro while
         CASE mTipo=="while" .AND. mContwhil != 0
            m_Inicio := aScan( m_Posi, mContwhil )
            m_Final  := m_Posi[ m_Inicio + 1 ]
            DB_SCOPE_WHILE := Substr( cTextCmd, mContwhil + 1, m_Final - mContwhil )
            cTextCmd   := Stuff( cTextCmd, mContwhil, m_Final - mContwhil, "" )
            DB_SCOPE_WHILE := Substr( DB_SCOPE_WHILE, At( " ", DB_SCOPE_WHILE ) )
            DB_SCOPE_ALL := .F.
            IF MacroType( DB_SCOPE_WHILE ) != "L"
               SayScroll( "Invalid WHILE" )
               RETURN .F.
            ENDIF
         ENDCASE
         cTextCmd := Alltrim( cTextCmd )
      NEXT
      mParametro := .T.

   CASE mTipo == "to"
      cTextCmd     := " " + cTextCmd + " "
      mParametro := ""
      IF " to " $ Lower( cTextCmd )
         mParametro := AllTrim( Lower( substr( cTextCmd, At( " to ", Lower( cTextCmd ) ) + 4 ) ) )
         IF mParametro == "prin"
            mParametro := "print"
         ENDIF
         cTextCmd = AllTrim( substr( cTextCmd, 1, at( " to ", Lower( cTextCmd ) ) - 1 ) )
      ENDIF

   CASE mTipo == "structure" .OR. mTipo == "status" .OR. mTipo == "Exclusive" .OR. mTipo == "index" .OR. mTipo == "sdf" .OR. mTipo == "extended"
      cTextCmd     := " " + cTextCmd + " "
      mParametro := .F.
      FOR mCont = 4 TO 9
         m_procu := " " + substr( mTipo, 1, mCont ) + " "
         IF m_procu $ Lower( cTextCmd )
            mParametro = .T.
            cTextCmd = Stuff( cTextCmd, at( m_procu, Lower( cTextCmd ) ), Len( m_procu ) - 1, "" )
         ENDIF
      NEXT
      cTextCmd := Alltrim( cTextCmd )

   OTHERWISE
      CLS
      SayScroll( "Syntax error" )
      QUIT
   ENDCASE
   cTextCmd := AllTrim( cTextCmd )
   RETURN mParametro


STATIC FUNCTION cmdDelete( cTextToAnalize )

   LOCAL m_ContDel, m_ContReg, nKey

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF .NOT. ExtractParameter( @cTextToAnalize, "escopo" )
      RETURN NIL
   ENDIF
   IF Len( cTextToAnalize ) != 0
      SayScroll( "Invalid " + cTextToAnalize )
      RETURN NIL
   ENDIF
   IF DB_SCOPE_RECORD == 0 .AND. DB_SCOPE_NEXT == 0 .AND. DB_SCOPE_FOR == ".T." .AND. DB_SCOPE_WHILE == ".T." .AND. .NOT. DB_SCOPE_ALL
      DB_SCOPE_RECORD := RecNo()
   ENDIF
   // executa comando
   DO CASE
   CASE DB_SCOPE_ALL
      GOTO TOP
   CASE DB_SCOPE_RECORD != 0
      GOTO DB_SCOPE_RECORD
   ENDCASE
   m_Contreg := 0
   m_Contdel := 0
   nKey    := 0
   SayScroll()
   DO WHILE nKey != K_ESC .AND. .NOT. Eof()
      nKey = Inkey()
      IF .NOT. &( DB_SCOPE_WHILE )
         EXIT
      ENDIF
      m_Contreg := m_Contreg + 1
      IF &( DB_SCOPE_FOR )
         RecDelete()
         m_Contdel := m_Contdel + 1
         IF Mod( m_Contdel, DB_ODOMETER ) == 0
            @ MaxRow() - 3, 0 SAY Str( m_Contdel ) + " record(s) deleted"
         ENDIF
      ENDIF
      IF DB_SCOPE_RECORD != 0
         EXIT
      ENDIF
      SKIP
      IF m_Contreg == DB_SCOPE_NEXT
         EXIT
      ENDIF
   ENDDO
   @ MaxRow() - 3, 0 SAY Str( m_Contdel ) + " record(s) deleted"
   IF LastKey() = K_ESC
      SayScroll( "Interrupted" )
   ENDIF
   RETURN NIL


STATIC FUNCTION cmdEdit( cTextToAnalize )

   LOCAL nCont, GetList := {}, m_Tela, m_Inclui, odbStruct, m_Ini, m_Fim, m_Grava, m_QtTela, mPageRec, m_Conteudo

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF Len( cTextToAnalize ) != 0
      IF Type( cTextToAnalize ) != "N"
         SayScroll( "Need to be a number" )
         RETURN NIL
      ENDIF
      IF &( cTextToAnalize ) < 1 .OR. &( cTextToAnalize ) > LastRec()
         SayScroll( "Invalid record number" )
         RETURN NIL
      ENDIF
      GOTO &( cTextToAnalize )
   ENDIF

   // edita registro

   m_Inclui := Eof()
   mPageRec := MaxRow()-6
   odbStruct := dbStruct()
   m_QtTela := Int( ( Len( odbStruct ) + mPageRec - 1 ) / mPageRec)
   FOR nCont = 1 TO Len( odbStruct )
      Aadd( odbStruct[ nCont ], "" ) // picture
      Aadd( odbStruct[ nCont ], FieldGet( nCont ) ) // value
   NEXT

   DO WHILE .T.
      IF .NOT. m_inclui
         IF .NOT. rLock()
            SayScroll( "Can't lock record" )
            RETURN NIL
         ENDIF
      ENDIF
      FOR nCont = 1 TO Len( odbStruct )
         odbStruct[ nCont, 6 ] := FieldGet( nCont )
          m_Conteudo := odbStruct[ nCont, 6 ]
          IF ValType( m_Conteudo ) == "C"
             odbStruct[ nCont, 5 ] := iif( Len( m_Conteudo ) > ( MaxCol() - 25 ), "@S" + Ltrim( Str( MaxCol() - 25 ) ), "@X" )
          ENDIF
      NEXT
      m_grava = .F.
      m_tela  = 1
      DO WHILE .T.
         Cls()
         m_ini := m_tela * mPageRec - mPageRec + 1
         m_fim := iif( m_tela = m_qttela, Len( odbStruct ), m_ini + mPageRec - 1 )
         @ 2,1 SAY iif( m_inclui .OR. Eof(), "INSERT", "EDIT  " ) + " - Registro.: " + STR( RecNo() ) + "   " + iif( Deleted(),"(DELETED)","")
         FOR nCont = m_ini TO m_fim
             @ nCont + 3 - m_ini, 1 SAY Pad( odbstruct[ nCont, 1 ],18,".") + ": " GET odbStruct[ nCont, 6 ] PICTURE ( odbStruct[ nCont, 5 ] )
         NEXT
         READ
         m_grava = iif( updated(), .T., m_grava )
         DO CASE
         CASE LastKey() == K_ESC
            EXIT
         CASE LastKey() == 18 // .OR. ( LastKey() == 5 .AND. Pad( ReadVar(), 10 ) == Pad( GetList[ 1, 2 ], 10 ) )
            m_tela := m_tela - 1
         CASE LastKey() = 23
            m_grava := .T.
            EXIT
         OTHERWISE
            m_tela := m_tela + 1
         ENDCASE
         IF m_tela < 1 .OR. m_tela > m_qttela
            EXIT
         ENDIF
      ENDDO
      IF LastKey() != K_ESC .AND. m_grava
         IF m_inclui .OR. Eof()
            APPEND BLANK
            DO WHILE NetErr()
               Inkey(.2)
               APPEND BLANK
            ENDDO
         ENDIF
         FOR nCont = 1 TO Len( odbStruct )
            FieldPut( nCont, odbStruct[ nCont, 6 ] )
         NEXT
      ENDIF
      DO CASE
      CASE LastKey() = K_ESC .OR. LastKey() = 23
         EXIT
      CASE LastKey() == 18
         IF .NOT. Bof()
            SKIP -1
         ENDIF
         IF Bof()
            EXIT
         ENDIF
         IF m_inclui
            m_inclui = .F.
         ENDIF
      OTHERWISE
         IF .NOT. Eof()
            SKIP
         ENDIF
         IF Eof() .AND. .NOT. m_inclui
            m_inclui = .T.
         ENDIF
      ENDCASE
   ENDDO
   RETURN NIL


STATIC FUNCTION cmdList( cTextToAnalize, mComando )

   LOCAL m_Status, m_Struct, nCont

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   m_Status := ExtractParameter( @cTextToAnalize, "status" )
   m_Struct := ExtractParameter( @cTextToAnalize, "structure" )
   nCont    := 0 + iif( m_status, 1, 0 ) + iif( m_struct, 1, 0 ) + iif( Len( cTextToAnalize ) == 0, 0, 1 )
   IF nCont > 1
      SayScroll( "Invalid parameters" )
      RETURN NIL
   ENDIF
   DO CASE
   CASE m_status
      cmdListStatus( mComando )
   CASE m_struct
      cmdListStructure()
   OTHERWISE
      cmdListData( cTextToAnalize, mComando )
   ENDCASE
   IF LastKey() == K_ESC
      SayScroll( "Interrupted" )
   ENDIF
   RETURN NIL


STATIC FUNCTION cmdListStatus( /* mComando */ )

   LOCAL nCont, nCont2, nSelect := Select()

   FOR nCont = 1 TO 255
      IF Len( Trim( Alias( nCont ) ) ) != 0
         SELECT ( nCont )
         SayScroll()
         SayScroll( "Alias " + Str( nCont, 2 ) + " -> " + Alias() + iif( nCont == nSelect, "  ==> Actual Alias", "" ) )
         FOR nCont2 = 1 TO 100
            IF Len( Trim( OrdKey(nCont2 ) ) ) == 0
               EXIT
            ENDIF
            SayScroll( "   Tag " + OrdName( nCont2 ) + " -> " + OrdKey( nCont2 ) )
         NEXT
         IF Len( Trim( dbFilter() ) ) != 0
            SayScroll( "          Filter: " + dbFilter() )
         ENDIF
         IF Len( Trim( dbRelation() ) ) != 0
            SayScroll("          Relation: " + dbRelation() + " Alias: " + Alias( dbRSelect() ) )
         ENDIF
      ENDIF
   NEXT
   SELECT ( nSelect )
   SayScroll( "Current Path -> " + hb_cwd() )
   SayScroll()
   RETURN NIL


STATIC FUNCTION cmdListStructure()

   LOCAL nCont, nRow, aStructure

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   aStructure := dbStruct()
   SayScroll( "Filename........: " + Alias() )
   SayScroll( "Qt.Records......: " + LTrim( Str( LastRec() ) ) )
   SayScroll()
   SayScroll( "  #  ---Name---  Type  Lenght   Decimals" )
   SayScroll()
   nRow := 5
   FOR nCont = 1 TO Len( aStructure )
      SayScroll( Str( nCont, 3 ) + "  " + pad( aStructure[ nCont, 1 ], 14 ) + aStructure[ nCont, 2 ] + "      " + Str( aStructure[ nCont, 3 ] ) + "      " + Str( aStructure[ nCont, 4 ] ) )
      nRow += 1
      IF nRow > ( MaxRow() - 8 )
         SayScroll( "Hit any to continue" )
         Inkey(0)
         IF LastKey() == K_ESC
            EXIT
         ENDIF
         nRow := 0
      ENDIF
   NEXT
   IF LastKey() != K_ESC
      SayScroll()
      SayScroll( "Total Record Size.: " + Str( RecSize() ) + " bytes")
      SayScroll()
   ENDIF
   RETURN NIL


STATIC FUNCTION cmdListData( cTextToAnalize, mComando )

   LOCAL nCont, nKey, m_ContReg, m_Lista, m_Item, cTxt

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   cTextToAnalize = " " + cTextToAnalize + " "

   IF .NOT. ExtractParameter( @cTextToAnalize, "escopo" )
      RETURN NIL
   ENDIF

   IF DB_SCOPE_RECORD == 0 .AND. DB_SCOPE_NEXT == 0 .AND. DB_SCOPE_WHILE == ".T."
      IF .NOT. DB_SCOPE_ALL
         IF mComando == "list"
            DB_SCOPE_ALL := .T.
         ELSE
            DB_SCOPE_RECORD := RecNo()
         ENDIF
      ENDIF
   ENDIF

   // prepara lista dos dados

   cTextToAnalize = alltrim( cTextToAnalize )
   m_Lista := {}
   IF len( cTextToAnalize ) = 0
      FOR nCont = 1 TO FCount()
         Aadd( m_Lista, FieldName( nCont ) )
      NEXT
   ELSE
      ExtractParameter( cTextToAnalize, "par,", @m_lista )
   ENDIF

   // lista do indicado

   DO CASE
   CASE DB_SCOPE_ALL
      GOTO TOP
   CASE DB_SCOPE_RECORD != 0
      GOTO DB_SCOPE_RECORD
   ENDCASE

   m_Contreg = 0
   nKey   = 0
   DO WHILE nKey != K_ESC .AND. .NOT. Eof()
      nKey = Inkey()
      IF .NOT. &( DB_SCOPE_WHILE )
         EXIT
      ENDIF
      m_Contreg = m_Contreg + 1
      cTxt := ""
      IF &( DB_SCOPE_FOR )
         cTxt := cTxt + Str( RecNo(), 6 ) + " " + iif( Deleted(), "del", "   " ) + " "
         FOR nCont = 1 TO Len( m_Lista )
            m_item = m_lista[ nCont ]
            IF MacroType( m_Item ) $ "CLDN"
               cTxt += Transform( &m_Item, "" )
            ENDIF
            IF nCont != Len( m_Lista )
               cTxt += " "
            ENDIF
         NEXT
         cTxt := Trim( cTxt )
         DO WHILE Len( cTxt ) != 0
            SayScroll( Left( cTxt, MaxCol() + 1 ) )
            cTxt := Substr( cTxt, MaxCol() + 2 )
         ENDDO
      ENDIF
      IF DB_SCOPE_RECORD != 0
         EXIT
      ENDIF
      SKIP
      IF m_Contreg = DB_SCOPE_NEXT
         EXIT
      ENDIF
   ENDDO
   RETURN NIL


STATIC FUNCTION cmdModify( cTextToAnalize )

   LOCAL m_Tipo

   m_Tipo = Lower( ExtractParameter( @cTextToAnalize, " " ) )
   DO CASE
   CASE Empty( m_Tipo )
      SayScroll( "Need more parameters" )
   CASE Len( m_Tipo ) < 4
      SayScroll( "Invalid parameter" )
   CASE Lower( m_Tipo ) == substr( "structure", 1, len( m_Tipo ) )
      cmdModifyStructure( cTextToAnalize )
   CASE Lower( m_Tipo ) == substr( "command", 1, len( m_Tipo ) )
      cmdModifyCommand( cTextToAnalize )
   OTHERWISE
      SayScroll( "Invalid parameter" )
   ENDCASE
   RETURN NIL


STATIC FUNCTION cmdModifyCommand( cFileName )

   IF len( trim( cFileName) ) = 0
      SayScroll( "Need filename" )
      RETURN NIL
   ENDIF
   IF .NOT. "." $ cFileName
      cFileName = cFileName + ".pro"
   ENDIF
   wSave()
   cmdEditAFile( cFileName )
   wRestore()
   SayScroll()
   RETURN NIL


STATIC FUNCTION cmdEditAFile( cFileName )

   LOCAL cTexto
   PRIVATE lChanged := .F., Ret_Val := 0

   IF Type( "cFileName" ) != "C"
      cFileName = "none"
   ENDIF
   cTexto := MemoRead( cFileName )
   CLS
   @ 1, 0 TO MaxRow() - 1, MaxCol()
   @ MaxRow(), 0 SAY Pad( Lower( cFileName ), 54 )
   cTexto = MemoEdit( cTexto, 2, 1, MaxRow() - 2, MaxCol() - 1, .T., "mfunc", 132, 3 )
   IF .NOT. cFileName == "none" .AND. .NOT. Empty( cTexto ) .AND. ret_val == 23
      lChanged = .F.
      RunCmd( "copy " + cFileName + " *.bak" )
      HB_MemoWrit( cFileName, cTexto )
   ENDIF
   RETURN NIL


****
*       mfunc()
*
*       memoedit user function
****
FUNCTION mfunc

   LOCAL KeyPress, Ret_Val, Rel_Row, Rel_Col, Line_Num, Col_Num
   PARAMETERS Mode, Line, Col

   ret_val = 0
   DO CASE
   CASE mode = 3
   CASE mode = 0
      * idle
      @ MaxRow(), MaxCol() - 20 SAY "line: " + Pad( Ltrim( Str( Line ) ), 4 )
      @ MaxRow(), MaxCol() - 8  SAY "col: "  + Pad( Ltrim( Str( Col ) ), 3 )
   OTHERWISE
      * keystroke exception
      keypress := LastKey()
      * save values to possibly resume edit
      line_num := line
      col_num  := col
      rel_row  := row() - 2
      rel_col  := col() - 1
      IF mode == 2
         lChanged = .T.
      ENDIF
      DO CASE
      CASE keypress = K_CTRL_W
         * ctr-w..write file
         ret_val = 23
      CASE keypress = K_ESC
         * esc..Exit
         IF .NOT. lChanged
            * no change
            ret_val = K_ESC
         ELSE
            * changes have been made to memo
            IF MsgYesNo( "Abort?" )
               ret_val = K_ESC
            ELSE
               ret_val = 32
            ENDIF
         ENDIF
      ENDCASE
   ENDCASE
   RETURN ret_val


STATIC FUNCTION cmdCreate( cTextToAnalize )

   LOCAL m_From

   IF Empty( cTextToAnalize )
      SayScroll( "Invalid parameters" )
      RETURN NIL
   ENDIF
   IF " from " $ Lower( " " + cTextToAnalize + " " )
      m_Posi  = at( " from ", Lower( " " + cTextToAnalize + " " ) )
      m_from  = substr( cTextToAnalize, m_Posi + 5 )
      cTextToAnalize = substr( cTextToAnalize, 1, m_Posi - 1 )
      IF cTextToAnalize == ""
         SayScroll( "Need filename" )
         RETURN NIL
      ENDIF
      IF .NOT. "." $ m_from
         m_from = m_from + ".dbf"
      ENDIF
      IF .NOT. File( m_from )
         SayScroll( "Source filename not found" )
         RETURN NIL
      ENDIF
      IF .NOT. "." $ cTextToAnalize
         cTextToAnalize = cTextToAnalize + ".dbf"
      ENDIF
      IF File( cTextToAnalize )
         IF .NOT. MsgYesNo( "File exists, overwrite?" )
            RETURN NIL
         ENDIF
      ENDIF
      CREATE ( cTextToAnalize ) FROM ( m_from )
      RETURN NIL
   ENDIF

   IF .NOT. "." $ cTextToAnalize
      cTextToAnalize = cTextToAnalize + ".dbf"
   ENDIF

   IF File( cTextToAnalize + ".dbf" )
      IF .NOT. MsgYesNo( "File exist, overwrite?" )
         RETURN NIL
      ENDIF
   ENDIF

   cmdModifyStructure( cTextToAnalize )
   RETURN NIL


STATIC FUNCTION cmdSum( cTextToAnalize )

   LOCAL nCont, m_ContSum, m_ContReg, nKey, m_Item, m_Lista, m_Soma, m_Vari, m_To

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   // valida parametros

   m_to     = ExtractParameter( @cTextToAnalize, "to" )

   IF .NOT. ExtractParameter( @cTextToAnalize, "escopo" )
      RETURN NIL
   ENDIF

   IF DB_SCOPE_RECORD == 0 .AND. DB_SCOPE_NEXT == 0 .AND. DB_SCOPE_WHILE == ".T." .AND. .NOT. DB_SCOPE_ALL // DB_SCOPE_FOR == ".T." .AND.
      DB_SCOPE_ALL := .T.
   ENDIF

   m_Lista := {}

   ExtractParameter( @cTextToAnalize, "par,", @m_lista )
   ExtractParameter( @m_to,    "par,", @m_vari  )
   m_Soma := Array( Len( m_Lista ) )
   Afill( m_Soma, 0 )

   IF Len( m_Lista ) == 0 .OR. ( Len( m_Vari ) != 0 .AND. Len( m_Vari ) != Len( m_lista ) ) .OR. len( cTextToAnalize ) != 0 // if anything more
      SayScroll( "Invalid parameters" )
      RETURN NIL
   ENDIF

   FOR nCont = 1 TO Len( m_Lista )
      m_item = m_lista[ nCont ]
      IF Type( m_item ) != "N"
         SayScroll( "Field not numeric" )
         RETURN NIL
      ENDIF
   NEXT

   // executa comando

   DO CASE
   CASE DB_SCOPE_ALL
      GOTO TOP
   CASE DB_SCOPE_RECORD != 0
      GOTO DB_SCOPE_RECORD
   ENDCASE

   m_Contreg = 0
   m_Contsum = 0
   nKey   = 0
   SayScroll()
   DO WHILE nKey != K_ESC .AND. .NOT. Eof()
      nKey = Inkey()
      IF .NOT. &( DB_SCOPE_WHILE )
         EXIT
      ENDIF
      m_Contreg = m_Contreg + 1
      IF &( DB_SCOPE_FOR )
         FOR nCont = 1 TO Len( m_Lista )
            m_item = m_lista[ nCont ]
            m_soma[ nCont ] = m_soma[ nCont ] + &( m_item )
         NEXT
         m_Contsum += 1
         IF Mod( m_Contsum, DB_ODOMETER ) = 0
            @ MaxRow()-3, 0 SAY Str( m_Contsum ) + " record(s) in sum"
         ENDIF
      ENDIF
      IF DB_SCOPE_RECORD != 0
         EXIT
      ENDIF
      SKIP
      IF m_Contreg = DB_SCOPE_NEXT
         EXIT
      ENDIF
   ENDDO
   @ MaxRow() - 3, 0 SAY Str( m_Contsum ) + " record(s) in sum"
   cTextToAnalize := ""
   FOR nCont = 1 TO Len( m_Lista )
      cTextToAnalize += Str( m_soma[ nCont ] ) + " "
   NEXT
   SayScroll( cTextToAnalize )
   IF LastKey() == K_ESC
      SayScroll( "Interrupted" )
   ENDIF
   RETURN NIL


STATIC FUNCTION cmdSetRelation( cComando )

   LOCAL cRelationTo, cRelationInto
   LOCAL lAdditive := .F., cTrecho, nSelect, nCont
   LOCAL cOrdKeyFromType, cOrdKeyToType
   LOCAL acRelationTo := {}, acRelationInto := {}

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   cTrecho := ExtractParameter( cComando, " " )
   IF Lower( cTrecho ) == substr( "additive", 1, Max( Len( cTrecho ), 4 ) )
      lAdditive = .T.
      ExtractParameter( @cComando, " " ) // elimina proximo parametro
   ENDIF
   IF .NOT. lAdditive
      SET RELATION TO
   ENDIF
   IF Empty( cComando )
      RETURN NIL
   ENDIF
   IF .NOT. " into " $ Lower( cComando )
      SayScroll( "Invalid parameters" )
      RETURN NIL
   ENDIF
   // retira parametros to, into
   DO WHILE Len( cComando ) != 0 .AND. Len( acRelationTo ) < 8
      Aadd( acRelationTo, substr( cComando, 1, at( " into ", Lower( cComando) ) - 1 ) )
      Aadd( acRelationInto, substr( cComando, at( " into ", Lower( cComando ) ) + 6 ) )
   ENDDO

   // valida relacoes, valida alias e executa

   IF .NOT. lAdditive
      SET RELATION TO
   ENDIF

   FOR nCont = 1 TO Len( acRelationTo )

      cRelationInto := acRelationInto[ nCont ]
      cRelationTo   := acRelationTo[ nCont ]

      IF Type( cRelationInto ) = "N"
         IF Alias( cRelationInto ) = 0
            SayScroll( "Alias not in use " + cRelationInto )
            RETURN NIL
         ENDIF
      ELSEIF Select( cRelationInto ) = 0
         SayScroll( "Alias not in use " + cRelationInto )
         RETURN NIL
      ENDIF
      nSelect := Select()
      SELECT ( Select( cRelationInto ) )
      IF Empty( OrdKey() )
         IF cRelationTo != "recno()"
            SELECT ( nSelect )
            SayScroll( "File not indexed to make relation" )
            RETURN NIL
         ENDIF
      ELSE
         cOrdKeyFromType := Type( OrdKey( IndexOrd() ) )
         SELECT ( nSelect )
         cOrdKeyToType := Type( cRelationTo )
         IF cOrdKeyFromType != cOrdKeyToType
            SELECT ( nSelect )
            SayScroll( "Key type: " + cOrdKeyToType + ", in command: " + cOrdKeyFromType )
            RETURN NIL
         ENDIF
      ENDIF
      SELECT ( nSelect )
      SET RELATION ADDITIVE TO &cRelationTo INTO &cRelationInto
   NEXT
   RETURN NIL


STATIC FUNCTION cmdStore( cTextToAnalize )

   IF .NOT. " to " $ Lower( cTextToAnalize )
      SayScroll( "Need TO" )
      RETURN NIL
   ENDIF
   m_nomvar = ExtractParameter( @cTextToAnalize, "to" )
   m_Conte  = cTextToAnalize
   IF .NOT. Type( m_Conte ) $ "NCLD"
      SayScroll( "Invalid content" )
      RETURN NIL
   ENDIF

   //declare m_lista[ 100 ]
   //m_qtparam = ExtractParameter( @cTextToAnalize, "par,", @m_lista )
   //
   //for nCont = 1 to m_qtparam
   //   m_nomevar  = m_lista[ nCont ]
      &m_nomvar = &m_Conte
   //next
   RETURN NIL


STATIC FUNCTION cmdAppend( cTextToAnalize )

   LOCAL mQtRec, m_Sdf
   PRIVATE cFileName

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF Empty( cTextToAnalize )
      GOTO BOTTOM
      SKIP
      cmdEdit( "" )
      RETURN NIL
   ENDIF
   // verifica se e' APPEND BLANK
   IF Lower( cTextToAnalize ) == "blan" .OR. Lower( cTextToAnalize ) == "blank"
      APPEND BLANK
      DO WHILE NetErr()
         Inkey(.2)
         APPEND BLANK
      ENDDO
      RETURN NIL
   ENDIF
   // valida APPEND FROM
   IF Lower( ExtractParameter( @cTextToAnalize, " " ) ) != "from"
      SayScroll( "Invalid parameter" )
      RETURN NIL
   ENDIF
   // valida para append sdf
   m_sdf      = ExtractParameter( @cTextToAnalize, "sdf" )
   cFileName := ExtractParameter( @cTextToAnalize, " " )
   IF .NOT. "." $ cFileName
      cFileName = cFileName + iif( m_sdf, ".txt", ".dbf" )
   ENDIF
   IF .NOT. File( cFileName )
      SayScroll( "File not found" )
      RETURN NIL
   ENDIF
   IF select( cFileName ) != 0
      SayScroll( "File in use" )
      RETURN NIL
   ENDIF
   IF .NOT. ExtractParameter( @cTextToAnalize, "escopo" )
      RETURN NIL
   ENDIF
   IF len( cTextToAnalize ) != 0 .OR. DB_SCOPE_RECORD != 0 .OR. DB_SCOPE_NEXT != 0 .OR. DB_SCOPE_WHILE != ".T."
      SayScroll( "Invalid parameters in APPEND" )
      RETURN NIL
   ENDIF
   // executa comando
   mQtRec := LastRec()
   IF m_sdf
      APPEND FROM ( cFileName ) FOR &( DB_SCOPE_FOR ) WHILE ( Inkey() != K_ESC ) SDF
   ELSE
      APPEND FROM ( cFileName ) FOR &( DB_SCOPE_FOR ) WHILE ( Inkey() != K_ESC )
   ENDIF
   SayScroll( Ltrim( Str( LastRec() - mQtRec ) ) + " Record(s) appended" )
   RETURN NIL


STATIC FUNCTION cmdCopy( cTextToAnalize )

   LOCAL m_Struct, m_Extend, m_SDF, m_To

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   // valida parametros

   m_struct = ExtractParameter( @cTextToAnalize, "structure" )
   m_extend = ExtractParameter( @cTextToAnalize, "extended" )
   m_sdf    = ExtractParameter( @cTextToAnalize, "sdf" )
   m_To     = ExtractParameter( @cTextToAnalize, "to" )
   IF .NOT. ExtractParameter( @cTextToAnalize, "escopo" )
      RETURN NIL
   ENDIF
   IF len( cTextToAnalize ) != 0
      SayScroll("Invalid parameter " + cTextToAnalize)
      RETURN NIL
   ENDIF
   IF len( m_to ) = 0
      SayScroll( "Need destination filename" )
      RETURN NIL
   ENDIF
   IF DB_SCOPE_NEXT == 0 .AND. DB_SCOPE_RECORD == 0
      DB_SCOPE_NEXT := LastRec()
   ENDIF

   IF .NOT. "." $ m_to
      m_to = m_to + ".dbf"
   ENDIF

   IF File( m_to )
      IF .NOT. MsgYesNo( "Filename already exists, overwrite?")
         SayScroll( "Cancelled" )
         RETURN NIL
      ENDIF
   ENDIF

   DO CASE
   CASE m_struct
      IF m_extend
         COPY TO ( m_to ) STRUCTURE EXTENDED
      ELSE
         COPY TO ( m_to ) STRUCTURE
      ENDIF

   CASE DB_SCOPE_RECORD != 0
      IF m_Sdf
         COPY TO ( m_To ) SDF RECORD ( DB_SCOPE_RECORD )
      ELSE
         COPY TO ( m_To ) RECORD ( DB_SCOPE_RECORD )
      ENDIF

   CASE DB_SCOPE_WHILE != ".T." .OR. "while .T." $ Lower( cTextToAnalize )
      IF m_Sdf
         COPY TO ( m_To ) FOR &( DB_SCOPE_FOR ) WHILE &( DB_SCOPE_WHILE ) NEXT DB_SCOPE_NEXT SDF
      ELSE
         COPY TO ( m_To ) FOR &( DB_SCOPE_FOR ) WHILE &( DB_SCOPE_WHILE ) NEXT DB_SCOPE_NEXT
      ENDIF

   CASE .NOT. DB_SCOPE_NEXT != 0
      IF m_Sdf
         COPY TO ( m_To ) FOR &( DB_SCOPE_FOR ) NEXT DB_SCOPE_NEXT SDF
      ELSE
         COPY TO ( m_To ) FOR &( DB_SCOPE_FOR ) NEXT DB_SCOPE_NEXT
      ENDIF

   OTHERWISE
      GOTO TOP
      IF m_sdf
         COPY TO ( m_to ) FOR &( DB_SCOPE_FOR ) sdf
      ELSE
         COPY TO ( m_to ) FOR &( DB_SCOPE_FOR )
      ENDIF

   ENDCASE
   RETURN NIL


STATIC FUNCTION cmdReplace( cTextToAnalize )

   LOCAL nCont, m_ContRep, m_ContReg, m_Name, m_With, nKey
   PRIVATE m_Campo, m_Expr

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF .NOT. ExtractParameter( @cTextToAnalize, "escopo" )
      RETURN NIL
   ENDIF

   IF DB_SCOPE_RECORD == 0 .AND. DB_SCOPE_NEXT == 0 .AND. DB_SCOPE_FOR == ".T." .AND. DB_SCOPE_WHILE = ".T." .AND. .NOT. DB_SCOPE_ALL
      DB_SCOPE_RECORD = RecNo()
   ENDIF

   // retira nomes dos campos e conteudos

   IF Len( cTextToAnalize ) = 0
      SayScroll( "Invalid parameters" )
      RETURN NIL
   ENDIF

   m_Name := Array(100)
   m_With := Array(100)
   afill( m_name, "" )
   nCont = 1
   DO WHILE Len( cTextToAnalize) > 0
      m_expr  = alltrim( substr( cTextToAnalize, rat( " with ", Lower( cTextToAnalize ) ) + 5 ) )
      cTextToAnalize = alltrim( substr( cTextToAnalize, 1, rat( " with ", Lower( cTextToAnalize ) ) ) )
      cTextToAnalize = "," + cTextToAnalize
      m_campo = alltrim( substr( cTextToAnalize, rat( ",", Lower( cTextToAnalize ) ) + 1 ) )
      cTextToAnalize = alltrim( substr( cTextToAnalize, 2, rat( ",", Lower( cTextToAnalize ) ) - 2 ) )
      DO CASE
      CASE Type( m_expr ) $ "U,UI,UE"
         SayScroll( "Invalid content" )
         RETURN NIL

      CASE Type( m_campo ) $ "U,UI,UE"
         SayScroll( "Invalid fieldname" )
         RETURN NIL

      CASE Type( m_campo ) != Type( m_expr )
         SayScroll( "Types mismatched -> " + m_campo + " with " + m_expr)
         RETURN NIL
      ENDCASE
      m_name[ nCont ] = m_campo
      m_with[ nCont ] = m_expr
      nCont += 1
   ENDDO

   // executa comando

   DO CASE
   CASE DB_SCOPE_ALL
      GOTO TOP
   CASE DB_SCOPE_RECORD != 0
      GOTO DB_SCOPE_RECORD
   ENDCASE

   m_Contreg = 0
   m_Contrep = 0
   nKey = 0
   SayScroll()
   DO WHILE nKey != K_ESC .AND. .NOT. Eof()
      nKey = Inkey()
      IF .NOT. &( DB_SCOPE_WHILE )
         EXIT
      ENDIF
      m_Contreg = m_Contreg + 1
      IF &( DB_SCOPE_FOR )
         DO WHILE .T.
            IF rLock()
               EXIT
            ENDIF
            @ Row(), 0 SAY space(79)
            @ Row(), 0 SAY "Waiting lock record " + str( recno() )
         ENDDO

         FOR nCont = 1 TO 100
            IF len( m_name[ nCont ] ) = 0
               EXIT
            ENDIF
            m_campo = m_name[ nCont ]
            m_expr  = m_with[ nCont ]
            REPLACE &( m_campo ) WITH &( m_expr )
         NEXT

         m_Contrep = m_Contrep + 1
         IF Mod( m_Contrep, DB_ODOMETER ) = 0
            @ Row(), 0 SAY str( m_Contrep ) + " record(s) updated"
         ENDIF
      ENDIF
      IF DB_SCOPE_RECORD != 0
         EXIT
      ENDIF
      SKIP
      IF m_Contreg = DB_SCOPE_NEXT
         EXIT
      ENDIF
   ENDDO
   @ Row(), 0 SAY str( m_Contrep ) + " record(s) updated"
   IF LastKey() = K_ESC
      SayScroll( "Cancelled" )
   ENDIF
   RETURN NIL


STATIC FUNCTION cmdLocate( cTextToAnalize )

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF .NOT. ExtractParameter( @cTextToAnalize, "escopo" )
      RETURN NIL
   ENDIF

   IF len( cTextToAnalize ) != 0 .OR. DB_SCOPE_RECORD != 0
      SayScroll( "Invalid parameter " + cTextToAnalize )
      RETURN NIL
   ENDIF

   IF DB_SCOPE_ALL
      GOTO TOP
   ENDIF

   LOCATE FOR &( DB_SCOPE_FOR ) WHILE &( DB_SCOPE_WHILE ) .AND. Inkey() != K_ESC

   IF LastKey() = K_ESC
      SayScroll( "Cancelled" )
   ELSE
     IF Eof() .OR. .NOT. &( DB_SCOPE_WHILE )
        SayScroll( "Not found" )
      ENDIF
   ENDIF
   RETURN NIL


STATIC FUNCTION cmdModifyStructure( cTextToAnalize )

   LOCAL nCont, GetList := {}, m_Mudou, m_Len, m_Type, m_Dec, m_Tipos, mTempFile, m_JaExiste, m_Regs
   PRIVATE acStructure, m_Opc, m_Name, m_Row, cEmptyValue, m_IniVet, m_Col

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   // salva configuracao atual

   m_row    = Row()
   m_col    = Col()
   wSave()
   Cls()

   // prepara tela da estrutura

   @ 4, 20 SAY " -------------------------------------------- "
   @ 5, 20 SAY "|                                            |"
   @ 6, 20 SAY "|--------------------------------------------|"
   @ 7, 20 SAY "| Name       | Type      | Len   | Dec |"
   @ 8, 20 SAY "|--------------------------------------------|"
   cEmptyValue = "            |           |       |           "
   FOR nCont = 9 TO 19
      @ nCont, 20 SAY Chr(179) + cEmptyValue + Chr(179)
   NEXT
   @ 20,20 SAY "|--------------------------------------------|"
   @ 21,20 SAY "| < >  ESC ENTER (I)nsert (D)elete (S)ave    |"
   @ 22,20 SAY " -------------------------------------------- "

   m_tipos      = "CharacterNumeric  Data     Boolean  Memo     "

   IF len( cTextToAnalize ) = 0
      cTextToAnalize     = Alias()
      m_jaexiste = .T.
   ELSE
      m_jaexiste = .F.
   ENDIF

   // mostra campos na tela

   DECLARE acStructure[ 200 ]
   afill( acStructure, "" )
   acStructure[ 1 ] = cEmptyValue
   @ 5, 20 + int( ( 38 - len( cTextToAnalize ) ) / 2 ) Say cTextToAnalize

   IF m_jaexiste
      m_regs = fcount()
      m_Name := Array(m_Regs)
      m_Type := Array(m_Regs)
      m_Len  := Array(m_Regs)
      m_Dec  := Array(m_Regs)
      afields( m_name, m_type, m_len, m_dec )
      FOR nCont=1 TO m_regs
         acStructure[ nCont ] = " " + pad( m_name[ nCont ], 10 ) + " ³ " + ;
                 substr( "CharacterNumeric  Boolean  Date     Memo     ", ;
                 at( m_type[ nCont ], "CNLDM" ) * 9 - 8, 9 ) + " ³  " +  ;
                 str( m_len[ nCont ], 3 ) + "  ³ " + ;
                 str( m_dec[ nCont ], 3 ) + " "
      NEXT
      acStructure[ m_regs + 1 ] = cEmptyValue
   ENDIF

   // permite selecao e alteração

   m_mudou = .F.
   STORE 1 to m_opc, m_inivet
   DO WHILE .T.
      achoice( 9, 21, 19, 58, acStructure, .T., "func_modi", m_opc, m_inivet )
      DO CASE
      CASE LastKey() == K_ESC .OR. Lower( chr( LastKey() ) ) == "q"
         IF MsgYesNo( "Abort?" )
            EXIT
         ENDIF

      CASE Lower( chr( LastKey() ) ) == "d"
         m_row = Row()
         IF acStructure[ m_opc ] # cEmptyValue
            adel( acStructure, m_opc )
            scroll( m_row, 21, 19, 58, 1 )
            @ 19,21 Say cEmptyValue
            m_mudou = .T.
         ENDIF

      CASE Lower( chr( LastKey() ) ) = "s"
         IF acStructure[ 1 ] == cEmptyValue .OR. .NOT. m_mudou
            EXIT
         ENDIF
         IF .NOT. MsgYesNo( "Confirm?" )
            LOOP
         ENDIF
         mTempFile := MyTempFile( "DBF" )
         CREATE ( mTempFile )
         FOR nCont = 1 TO 200
            IF acStructure[ nCont ] == cEmptyValue
               nCont = 200
            ELSE
               m_name = substr( acStructure[ nCont ], 2, 10 )
               m_type = substr( acStructure[ nCont ], 15, 1 )
               m_len  = val( substr( acStructure[ nCont ], 28, 3 ) )
               m_dec  = val( substr( acStructure[ nCont ], 35, 3 ) )
               APPEND BLANK
               REPLACE field_name WITH m_name, ;
                       field_type with m_type, ;
                       field_len  WITH m_len,  ;
                       field_dec  with m_dec
            ENDIF
         NEXT
         IF LastRec() > 0
            IF m_jaexiste
               USE
               IF File( cTextToAnalize + ".bak" )
                  fErase( cTextToAnalize + ".bak" )
               ENDIF
               fRename( cTextToAnalize + ".dbf", cTextToAnalize + ".bak" )
            ENDIF
            CREATE ( cTextToAnalize ) FROM ( mTempFile )
            USE ( cTextToAnalize )
            IF m_jaexiste
               APPEND FROM ( cTextToAnalize + ".bak" )
            ENDIF
            USE ( cTextToAnalize )
         ENDIF
         fErase( mTempFile )
         EXIT

      CASE Lower( chr( LastKey() ) ) == "i" .OR. LastKey()==13
         m_row = ROW()
         IF Lower( chr( LastKey() ) ) == "i" .OR. ;
            acStructure[ m_opc ] = cEmptyValue
            IF m_row < 19
               scroll( m_row, 21, 19, 58, -1 )
               @ m_row, 21 Say cEmptyValue
            ENDIF
            ains( acStructure, m_opc )
            acStructure[ m_opc ] = cEmptyValue
         ENDIF
         m_name = substr( acStructure[ m_opc ], 2, 10 )
         m_type = substr( acStructure[ m_opc ], 15, 1 )
         m_len  = val( substr( acStructure[ m_opc ], 28, 3 ) )
         m_dec  = val( substr( acStructure[ m_opc ], 35, 3 ) )
         m_row  = row()
         @ m_row, 22 GET m_name PICTURE "@!"  VALID name_ok()
         @ m_row, 35 GET m_type PICTURE "!A"  VALID TypeOk( m_Type, @m_Len, @m_Dec )
         @ m_row, 48 GET m_len  PICTURE "999" VALID LenOk( m_Len, m_Type )
         @ m_row, 56 GET m_dec  PICTURE "99"  VALID DecimaisOk( m_Dec, m_Type )
         READ
         IF LastKey()#K_ESC
            acStructure[ m_opc ] = " " + m_name + " ³ " + substr( m_tipos, at( m_type, m_tipos ), 9 ) + " ³  " + str( m_len, 3 ) + "  ³ " + str( m_dec, 3 ) + " "
            m_mudou = .T.
         ELSE
            adel( acStructure, m_opc )
         ENDIF
      ENDCASE
   ENDDO
   wRestore()
   RETURN NIL


// funcao de movimentacao
FUNCTION func_modi

   PARAMETERS modo, opc, inivet

   m_opc    = opc
   m_inivet = inivet
   DO CASE
   CASE modo#3
      RETURN 2
   CASE LastKey() == 1
      KEYBOARD Chr( K_CTRL_PGUP )
      RETURN 2
   CASE LastKey() == 6
      KEYBOARD Chr( K_CTRL_PGDN )
      RETURN 2
   CASE str( LastKey(), 3 ) $ " 27, 13"
      RETURN 0
   CASE Lower( chr( LastKey() ) ) $ "qsid"
      RETURN 0
   ENDCASE
   RETURN 2


// funcao para validar nome
FUNCTION name_ok

   LOCAL  nCont

   DO CASE
   CASE LastKey() =K_ESC
      RETURN .T.
   CASE empty( m_name )
      RETURN .F.
   ENDCASE
   FOR nCont = 1 TO 200
      DO CASE
      CASE acStructure[ nCont ] = cEmptyValue
         nCont = 200
      CASE substr( acStructure[ nCont ], 2, 10 ) == m_name .AND. nCont != m_opc
         RETURN .F.
      ENDCASE
   NEXT
   RETURN .T.


// funcao para validar tipo
FUNCTION TypeOk( cType, nLen, nDecimais )

   LOCAL lOk := .T.

   DO CASE
   CASE cType == "C"
      @ m_Row, 35 SAY "Character"
   CASE cType == "N"
      @ m_Row, 35 Say "Numeric"
   CASE cType == "L"
      @ m_Row, 35 SAY "Boolean"
      nLen      := 1
      nDecimais := 0
   CASE cType == "D"
      @ m_Row, 35 SAY "Date"
      nLen      := 8
      nDecimais := 0
   CASE cType == "M"
      @ m_Row, 35 Say "Memo"
      nLen      := 10
      nDecimais := 0
   OTHERWISE
      lOk := .F.
   ENDCASE
   RETURN lOk


// funcao para validar tamanho
FUNCTION LenOk( nLen, cType )

   LOCAL lOk := ( nLen > 0 )
   DO CASE
   CASE cType == "L"
      lOk := ( nLen == 1 )
   CASE cType == "D"
      lOk := ( nLen == 8 )
   CASE cType == "M"
      lOk := ( nLen==10)
   ENDCASE
   RETURN lOk


// funcao para validar decimais
FUNCTION DecimaisOk( nDecimais, cType )

   DO CASE
   CASE cType $ "LDM"
      RETURN ( nDecimais == 0 )
   CASE nDecimais < 0
      RETURN .F.
   ENDCASE
   RETURN .T.


STATIC FUNCTION cmdPrint( cTextToAnalize )

   LOCAL nCont, m_Lista := {}, cTxt
   PRIVATE m_picture, m_item, m_picture

   IF Empty( cTextToAnalize )
      SayScroll()
      RETURN NIL
   ENDIF

   ExtractParameter( cTextToAnalize, "par,", @m_lista )

   cTxt := ""
   FOR nCont = 1 TO Len( m_Lista )
      m_item = m_lista[ nCont ]
      IF .NOT. Type(m_item) $ "NCLDM"
         IF Right( m_item, 1 ) == ","
            m_item = Substr( m_item, 1, Len( m_item ) - 1 )
         ENDIF
         SayScroll( "Variable not found" )
         RETURN NIL
      ENDIF
      DO CASE
      CASE Type( m_item ) $ "CLDN"
         cTxt += Transform( &( m_Item ), "" ) + " "
      CASE Type( m_item ) = "M"
         cTxt += "memo" + " "
      ENDCASE
   NEXT
   SayScroll( cTxt )
   RETURN NIL


STATIC FUNCTION cmdUse( cTextToAnalize )

   LOCAL cDbfName, cCdxName, cAlias, lExclusive, nCont
   THREAD STATIC nTempAlias := 1

   IF Empty( cTextToAnalize )
      USE
      RETURN NIL
   ENDIF

   cDbfName = ExtractParameter( @cTextToAnalize, " " )

   IF Len( cDbfName) = 0
      SayScroll( "Invalid filename" + cDbfName )
      RETURN NIL
   ENDIF

   IF Select( cDbfName ) != 0
      SayScroll( "File already open!" + cDbfName )
      RETURN NIL
   ENDIF

   IF .NOT. "." $ cDbfName
      cDbfName += ".dbf"
   ENDIF

   IF .NOT. File( cDbfName )
      SayScroll( "File not found " + cDbfName )
      RETURN NIL
   ENDIF

   // Valida uso exclusivo

   lExclusive = ExtractParameter( @cTextToAnalize, "Exclusive" )
   cAlias := ExtractParameter( @cTextToAnalize, "alias" )

   IF .NOT. Empty( cAlias )
      IF Len( cAlias ) < 2 .OR. Len( cAlias ) > 10 .OR. Val( cAlias ) != 0
         SayScroll( "Invalid ALIAS " + cAlias )
         RETURN NIL
      ENDIF
      FOR nCont = 1 TO Len( cAlias )
         IF .NOT. Lower( Substr( cAlias, nCont, 1 ) ) $ "abcdefghijklmnopqrstuvwxyz_0123456789"
            SayScroll( "Invalid ALIAS " + cAlias )
            RETURN NIL
         ENDIF
      NEXT
   ENDIF

   IF Len( cAlias ) == 0
      IF Len( Substr( cDbfName, 1, At( ".", cDbfName + "." ) - 1 ) ) > 8
         cAlias := "TMP" + StrZero( nTempAlias, 7 )
      ELSE
         cAlias := Substr( cDbfName, 1, At( ".", cDbfName + "." ) - 1 )
      ENDIF
   ENDIF

   // Abre e confirma abertura de dbfs

   IF lExclusive
      USE ( cDbfName ) ALIAS ( cAlias ) EXCLUSIVE
      IF NetErr()
         SayScroll( "Can't open exclusive" )
         RETURN NIL
      ENDIF
   ELSE
      USE ( cDbfName ) ALIAS ( cAlias ) // SHARED
      IF NetErr()
         SayScroll( "File in use" )
         RETURN NIL
      ENDIF
   ENDIF

   nTempAlias += 1

   // Valida abertura de indice

   IF .Not. ExtractParameter( @cTextToAnalize, "index" )
      RETURN NIL
   ENDIF
   DO WHILE .T.
      cCdxName := ExtractParameter( @cTextToAnalize, "," )
      IF Len( cCdxName ) = 0
         EXIT
      ENDIF
      IF .NOT. "." $ cCdxName
         cCdxName += ".cdx"
         IF .NOT. File( cCdxName )
            SayScroll( cCdxName + " not found" )
         ELSE
            dbSetIndex( cCdxName )
         ENDIF
      ENDIF
   ENDDO
   RETURN NIL


STATIC FUNCTION cmdRecall( cTextToAnalize )

   LOCAL nContReg := 0, nContDel := 0, nKey := 0

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF .NOT. ExtractParameter( @cTextToAnalize, "escopo" )
      RETURN NIL
   ENDIF

   IF Len( cTextToAnalize ) != 0
      SayScroll( "Invalid parameter " + cTextToAnalize )
      RETURN NIL
   ENDIF

   IF DB_SCOPE_RECORD == 0 .AND. DB_SCOPE_NEXT == 0 .AND. DB_SCOPE_FOR == ".T." .AND. DB_SCOPE_WHILE == ".T." .AND. .NOT. DB_SCOPE_ALL
      DB_SCOPE_RECORD := RecNo()
   ENDIF

   DO CASE
   CASE DB_SCOPE_ALL
      GOTO TOP
   CASE DB_SCOPE_RECORD != 0
      GOTO ( DB_SCOPE_RECORD )
   ENDCASE

   SayScroll()
   DO WHILE nKey != K_ESC .AND. .NOT. Eof()
      nKey = Inkey()
      IF .NOT. &( DB_SCOPE_WHILE )
         EXIT
      ENDIF
      nContreg += 1
      IF &( DB_SCOPE_FOR )
         RecLock()
         RECALL
         nContDel += 1
         IF Mod( nContDel, DB_ODOMETER ) = 0
            @ MaxRow()-3, 0 SAY Str( nContDel ) + " record(s) recalled"
         ENDIF
      ENDIF
      IF DB_SCOPE_RECORD != 0
         EXIT
      ENDIF
      SKIP
      IF nContReg == DB_SCOPE_NEXT
         EXIT
      ENDIF
   ENDDO
   @ MaxRow() - 3, 0 SAY Str( nContDel ) + " record(s) recalled"
   IF LastKey() = K_ESC
      SayScroll( "Interrupted" )
   ENDIF
   RETURN NIL


STATIC FUNCTION cmdSet( cTextToAnalize )

   LOCAL cSet, lOn, cIndice

   cSet := Lower( Trim( ExtractParameter( @cTextToAnalize, " " ) ) )
   DO CASE
   CASE Len( cSet ) < 4
      SayScroll( "Min 4 letters for command" )
      RETURN NIL
   CASE cSet $ "alternate"
      IF Upper( cTextToAnalize ) == "ON"
         SET ALTERNATE ON
      ELSEIF Upper( cTextToAnalize ) == "OFF"
         SET ALTERNATE OFF
      ELSE
         IF Lower( ExtractParameter( @cTextToAnalize, " " ) ) != "to"
            SayScroll( "Syntax error" )
            RETURN NIL
         ENDIF
         SET ALTERNATE TO ( cTextToAnalize )
      ENDIF

   CASE cSet $ "century,deleted,unique,confirm,exclusive"
      IF Upper( cTextToAnalize ) != "ON" .AND. Upper( cTextToAnalize ) != "OFF"
         SayScroll( "Need to be ON or OFF" )
         RETURN NIL
      ENDIF
      lOn := iif( Upper( cTextToAnalize ) == "ON", .T., .F. )
      DO CASE
      CASE cSet $ "alternate"
         IF lOn
            SET ALTERNATE ON
         ELSE
            SET ALTERNATE OFF
         ENDIF
      CASE cSet $ "century"
         IF lOn
            SET CENTURY ON
         ELSE
            SET CENTURY OFF
         ENDIF
      CASE cSet $ "confirm"
         IF lOn
            SET CONFIRM ON
         ELSE
            SET CONFIRM OFF
         ENDIF
      CASE cSet $ "deleted"
         IF lOn
            SET DELETED ON
         ELSE
            SET DELETED OFF
         ENDIF
      CASE cSet $ "unique"
         IF lOn
            SET UNIQUE ON
         ELSE
            SET UNIQUE OFF
         ENDIF
      CASE cSet $ "exclusive"
         IF lOn
            SET EXCLUSIVE ON
         ELSE
            SET EXCLUSIVE OFF
         ENDIF
         DB_EXCLUSIVE := lOn
      ENDCASE
   CASE cSet $ "filter,history,index,order,relation"
      IF cSet $ "filter,index,order,relation" .AND. .NOT. Used()
         SayScroll( "No file in use" )
         RETURN NIL
      ENDIF
      IF Lower( ExtractParameter( @cTextToAnalize, " " ) ) != "to"
         SayScroll( "Syntax error" )
         RETURN NIL
      ENDIF
      IF cSet == "relation"
         cmdSetRelation( cTextToAnalize )
      ELSEIF cSet == "order"
         IF Empty( cTextToAnalize )
            SET ORDER TO 1
            RETURN NIL
         ENDIF
         IF Type( cTextToAnalize ) != "N"
            SayScroll( "Order need to be number" )
            RETURN NIL
         ENDIF
         SET ORDER TO &( cTextToAnalize )
      ELSEIF cSet == "filter"
         IF Empty( cTextToAnalize )
            SET FILTER TO
            RETURN NIL
         ENDIF
         IF Type( cTextToAnalize ) != "L"
            SayScroll( "Filter need to be true or false" )
            RETURN NIL
         ENDIF
         SET FILTER TO &( cTextToAnalize )
      ELSEIF cSet == "index"
         SET INDEX TO
         IF Len( cTextToAnalize ) == 0
            RETURN NIL
         ENDIF
         DO WHILE .T.
            cIndice := ExtractParameter( @cTextToAnalize, "," )
            IF Len( cIndice ) = 0
               EXIT
            ENDIF
            IF .NOT. "." $ cIndice
               IF .NOT. File( cIndice + ".cdx" )
                  SayScroll( cIndice + " not found" )
               ELSE
                  dbSetIndex( cIndice )
               ENDIF
            ENDIF
         ENDDO
      ENDIF
   CASE cSet $ "printer"
      SET PRINTER TO
   OTHERWISE
      SayScroll( "Invalid configuration" )
   ENDCASE
   RETURN NIL


STATIC FUNCTION cmdDir( cTextToAnalize )

   LOCAL acTmpFile, nTotalSize, nCont, nLin

   IF Empty( cTextToAnalize )
      acTmpFile := Directory( "*.dbf" )
      nTotalSize := 0
      nLin := 0
      FOR nCont = 1 TO Len( acTmpFile )
         USE ( acTmpFile[ nCont, 1 ] ) ALIAS temp
         SayScroll( Pad( acTmpFile[ nCont, 1 ], 15 ) + Transform( LastRec(), "99,999,999" ) + " " + ;
            Transform( acTmpFile[ nCont, 2 ], "999,999,999,999" ) + " " + Dtoc( acTmpFile[ nCont, 3 ] ) + " " + acTmpFile[ nCont, 4 ] )
         nTotalSize += acTmpFile[ nCont, 2 ]
         nLin += 1
         USE
         IF nLin > MaxRow()-7
            SayScroll( "Hit any to continue" )
            IF Inkey(0) == K_ESC
               EXIT
            ENDIF
            nLin := 0
         ENDIF
      NEXT
      SayScroll( "Total " + Str( Len( acTmpFile ) ) + " file(s) " + Transform( nTotalSize, PicVal( 9 ) ) + " byte(s)" )
   ELSE
      acTmpFile := Directory( cTextToAnalize )
      nTotalSize := 0
      FOR nCont = 1 TO Len( acTmpFile )
         SayScroll( Pad( acTmpFile[ nCont, 1 ], 15 ) + Transform( acTmpFile[ nCont, 2 ], PicVal( 9 ) ) + " " + Dtoc( acTmpFile[ nCont, 3 ] ) + " " + acTmpFile[ nCont, 4 ] )
         nTotalSize += acTmpFile[ nCont, 2 ]
      NEXT
      SayScroll( "Total " + Str( Len( acTmpFile ) ) + " file(s) " + Transform( nTotalSize, PicVal( 9 ) ) + " byte(s)" )
   ENDIF
   RETURN NIL


STATIC FUNCTION cmdIndex( cTextToAnalize )

   LOCAL cKey, cFileName

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF Lower( ExtractParameter( @cTextToAnalize, " " ) ) != "on"
      SayScroll( "Syntax error" )
      RETURN NIL
   ENDIF
   cKey := AllTrim( Substr( cTextToAnalize, 1, At( " to ", Lower( cTextToAnalize ) ) - 1 ) )
   IF .NOT. Type( cKey ) $ "NCD"
      SayScroll( "Invalid key" )
      RETURN NIL
   ENDIF
   cFileName := AllTrim( Substr( cTextToAnalize, At( " to ", Lower( cTextToAnalize ) ) + 4 ) )
   IF Len( cFileName ) == 0
      SayScroll( "Invalid filename" )
      RETURN NIL
   ENDIF
   INDEX ON &( cKey ) TAG jpa TO ( cFileName )
   SayScroll( Str( LastRec() ) + " record(s) indexed" )
   RETURN NIL


STATIC FUNCTION cmdTotal( cTextToAnalize )

   LOCAL cKey, cFileName

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF Lower( ExtractParameter( @cTextToAnalize, " " ) )  != "on"
      SayScroll( "Syntax error" )
      RETURN NIL
   ENDIF
   cKey := AllTrim( Substr( cTextToAnalize, 1, At( " to ", Lower( cTextToAnalize ) ) - 1 ) )
   IF .NOT. Type( cKey ) $ "NCD"
      SayScroll( "Invalid key" )
      RETURN NIL
   ENDIF
   cFileName := AllTrim( Substr( cTextToAnalize, At( " to ", Lower( cTextToAnalize ) ) + 4 ) )
   IF Len( cFileName ) == 0
      SayScroll( "Invalid filename" )
      RETURN NIL
   ENDIF
   TOTAL ON &( cKey ) TO ( cFileName )
   SayScroll( Str( LastRec()) + " record(s) Total" )
   RETURN NIL


STATIC FUNCTION cmdRun( cTextToAnalize )

   wSave()
   RunCmd( cTextToAnalize )
   ?
   @ MaxRow(), 0 SAY "Hit <ESC> to continue"
   DO WHILE Inkey(0) != K_ESC
   ENDDO
   wRestore()
   RETURN NIL


STATIC FUNCTION cmdBrowse()

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   MsgExclamation( "Do not change in browse mode" )
   wSave()
   Mensagem( "Select and <ENTER>, <ESC> abort, to change record exit and use EDIT" )
   Browse( 2, 0, MaxRow() - 3, MaxCol() )
   wRestore()
   RecUnlock()
   RETURN NIL


STATIC FUNCTION cmdContinue()

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   CONTINUE
   IF LastKey() == K_ESC
      SayScroll( "Interrupted" )
   ELSEIF Eof()
      SayScroll( "End of file" )
   ENDIF
   RETURN NIL


STATIC FUNCTION cmdPack()

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF .NOT. DB_EXCLUSIVE
      SayScroll( "Only available in exclusive mode" )
      RETURN NIL
   ENDIF
   PACK
   SayScroll( Str( LastRec() ) + " record(s) copyed" )
   RETURN NIL


STATIC FUNCTION cmdReindex()

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF .NOT. DB_EXCLUSIVE
      SayScroll( "Only available in exclusive mode" )
      RETURN NIL
   ENDIF
   REINDEX
   SayScroll( Str( LastRec() ) + " record(s) reindexed" )
   RETURN NIL


STATIC FUNCTION cmdSeek( cTextToAnalize )

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF Len( Trim( OrdKey() ) ) == 0
      SayScroll( "File not indexed" )
   ELSEIF Type( cTextToAnalize ) != Type( OrdKey() )
      SayScroll( "Order of file mismatch typed key" )
   ELSE
      SEEK &cTextToAnalize
      IF Eof()
         SayScroll( "Not found" )
      ENDIF
   ENDIF
   RETURN NIL


STATIC FUNCTION cmdSelect( cAlias )

   IF Select( cAlias ) == 0
      SayScroll( "Alias not exist" )
   ELSE
      SELECT ( Select( cAlias ) )
   ENDIF
   RETURN NIL


STATIC FUNCTION cmdSkip( cTextToAnalize )

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF Empty( cTextToAnalize )
      SKIP
   ELSEIF MacroType( cTextToAnalize ) != "N"
      SayScroll( "Type mismatch" )
   ELSEIF &( cTextToAnalize ) < 0 .AND. Bof()
      SayScroll( "Already in begining of file" )
   ELSEIF &( cTextToAnalize ) > 0 .AND. Eof()
      SayScroll( "Already in end of file" )
   ELSE
      SKIP &( cTextToAnalize )
   ENDIF
   RETURN NIL


STATIC FUNCTION cmdUnlock( cTextToAnalize )

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF Empty( cTextToAnalize )
      UNLOCK
   ELSEIF Lower( cTextToAnalize ) == "all"
      UNLOCK ALL
   ELSE
      ? "Invalid parameter"
   ENDIF
   RETURN NIL


STATIC FUNCTION cmdZap()

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF .NOT. DB_EXCLUSIVE
      SayScroll( "Only available in exclusive mode" )
      RETURN NIL
   ENDIF
   ZAP
   SayScroll( "Now file is empty" )
   RETURN NIL


STATIC FUNCTION cmdGoTo( cTextToAnalize )

   IF .NOT. Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF Lower( cTextToAnalize ) == "top"
      GOTO TOP
   ELSEIF Len( cTextToAnalize ) > 4 .AND. cTextToAnalize $ "bottom"
      GOTO BOTTOM
   ELSEIF Type( cTextToAnalize ) != "N"
      SayScroll( "Invalid parameter" )
   ELSEIF &( cTextToAnalize ) > LastRec() .OR. &( cTextToAnalize ) < 1
      SayScroll( "Invalid record number" )
   ELSE
      GOTO &( cTextToAnalize )
   ENDIF
   RETURN NIL
