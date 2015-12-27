* messageclass

#include "inkey.ch"
#include "hbclass.ch"
#include "hbgtinfo.ch"
#include "hbthread.ch"

FUNCTION AppMessage()
   STATIC AppMessage := { NIL, NIL }
   RETURN AppMessage

PROCEDURE PUSRMSG
   IF AppMessage()[ 2 ]:lExit
      AppMessage()[ 2 ]:Execute()
   ENDIF
   IF AppMessage()[ 1 ]:lExit
      AppMessage()[ 2 ]:Execute()
   ENDIF
   RETURN
*----------------------------------------------------------

CREATE CLASS MessageClass
   VAR cUser         INIT ""                            // User of window
   VAR lExit         INIT .T.                           // End task
   VAR acMessage     INIT {}                            // Text to show
   METHOD MessageFromUser( cUser, cDateFrom, cText )    // Distribute message to user
   METHOD SendMessage()                                 // Send a new message
   METHOD Execute( cUser )                              //
   METHOD UserExecute()                                 // Execute for user window
   METHOD MainExecute()                                 // Execute for main window
   METHOD CheckMasterThread()                           // Check if master thread is running
   METHOD Close()                                       // Close window
   METHOD SelectExecute()
   ENDCLASS

METHOD Close() CLASS MessageClass
   LOCAL nCont
   ::lExit := .T.
   IF ::cUser == "SysMain"
      FOR nCont = 2 TO Len( AppMessage() )
         AppMessage()[ nCont ]:Close()
      NEXT
   ENDIF
   RETURN NIL

METHOD Execute( cUser ) CLASS MessageClass
   IF cUser != NIL
      ::cUser := cUser
   ENDIF
   ::lExit := .F.
   IF ::cUser == "SysMain"
      hb_ThreadStart( { || ::MainExecute() } )
   ELSEIF ::cUser == "SysSelect"
      hb_ThreadStart( { || ::SelectExecute() } )
   ELSE
      hb_ThreadStart( { || ::UserExecute() } )
   ENDIF
   RETURN NIL

METHOD UserExecute() CLASS MessageClass
   LOCAL nKey, nCont

   hb_gtReLoad( hb_gtInfo( HB_GTI_VERSION ) )
   AppInitSets()
   SetMode( 40, 40 )
   SetColor( SetColorNormal() )
   CLS
   @ 0, 0 SAY Padc( ::cUser, MaxCol() + 1 ) COLOR SetColorTitulo()
   HB_GtInfo( HB_GTI_WINTITLE, ::cUser + "(PARA " + AppUserName() + ")" )
//   HB_GtInfo( HB_GTI_RESIZEMODE, HB_GTI_RESIZEMODE_ROWS )
   Mensagem( "Tecle <ENTER> para enviar mensagem" )
   DO WHILE .NOT. ::lExit
      FOR nCont = 1 TO Len( ::acMessage )
         IF .NOT. Empty( ::acMessage[ nCont, 1 ] )
            SayScroll( ::acMessage[ nCont, 1 ] )
            SayScroll( Space(3) + ::acMessage[ nCont, 2 ] )
            ::acMessage[ nCont, 1 ] := ""
            ::acMessage[ nCont, 2 ] := ""
            wvgSetAppWindow():Show()
         ENDIF
      NEXT
      nKey := Inkey(1)
      IF nKey == K_ESC
         EXIT
      ENDIF
      IF nKey == K_ENTER
         ::SendMessage()
      ENDIF
      ::CheckMasterThread()
   ENDDO
   ::lExit := .T.
   RETURN NIL

METHOD CheckMasterThread() CLASS MessageClass
   IF AppThreadMaster() != NIL
      IF hb_ThreadWait( AppThreadMaster(), 0.1, .T. ) == 1
         ::lExit := .T.
      ENDIF
   ENDIF
   RETURN NIL

METHOD MainExecute() CLASS MessageClass
   LOCAL cnMySql := MySqlClass():New()
   MEMVAR m_Prog
   PUBLIC m_Prog := "PUSRMSG"
   hb_gtReLoad( hb_gtInfo( HB_GTI_VERSION ) )
   AppInitSets()
   SetMode( 4, 4 )
   SetColor( SetColorNormal() )
   BEGIN SEQUENCE WITH { | e | Break( e ) }
      cnMySql:Open( .F. )
   END SEQUENCE
//   CLS
   HB_GtInfo( HB_GTI_WINTITLE, "Verificando mensagens" )
//   HB_GtInfo( HB_GTI_RESIZEMODE, HB_GTI_RESIZEMODE_ROWS )
   wvgSetAppWindow():Hide()
   DO WHILE .NOT. ::lExit
      BEGIN SEQUENCE WITH { | e | Break( e ) }
//         cnMySql:Open( .F. )
         cnMySql:cSql := "SELECT * FROM JPUSRMSG WHERE MSEMPRESA=[EMPRESA] AND MSTO=[USUARIO] AND MSOKTO='N'"
         cnMySql:Replace( "[EMPRESA]", StringSql( Trim( AppEmpresaApelido() ) ) )
         cnMySql:Replace( "[USUARIO]", StringSql( Trim( AppUserName() ) ) )
         cnMySql:Execute( , .F. )
         DO WHILE .NOT. cnMySql:Rs:Eof()
            IF cnMySql:rs:Fields( "MSTO" ):Value == Trim( AppUserName() )
//               SayScroll( "Chegou mensagem " + cnMySql:rs:Fields( "MSFROM" ):Value )
               ::MessageFromUser( cnMySql:rs:Fields( "MSFROM" ):Value, cnMySql:rs:Fields( "MSDATEFROM" ):Value + " " + cnMySql:rs:Fields( "MSFROM" ):Value, cnMySql:rs:Fields( "MSTEXT" ):Value )
               cnMySql:cSql := "UPDATE JPUSRMSG SET MSOKTO='S', MSDATETO = '" + Transform( Dtos( Date() ), "@R 9999-99-99" ) + " " + Time() + "' WHERE MSNUMLAN=" + Ltrim( Str( cnMySql:rs:Fields( "MSNUMLAN" ):Value ) )
               cnMySql:ExecuteCmd()
            ENDIF
            cnMySql:Rs:MoveNext()
         ENDDO
         cnMySql:Rs:Close()
      END SEQUENCE
      IF Inkey(5) == K_ESC
         ::lExit := .T.
      ENDIF
      ::CheckMasterThread()
   ENDDO
   BEGIN SEQUENCE WITH { | e | Break( e ) }
      cnMySql:Close()
   END SEQUENCE
   RETURN NIL

METHOD SelectExecute() CLASS MessageClass
   LOCAL aLstUser := {}, nOpcUser := 0

   hb_gtReLoad( hb_gtInfo( HB_GTI_VERSION ) )
   AppInitSets()
   SetMode( 15, 40 )
   HB_GtInfo( HB_GTI_WINTITLE, "Lista de Usuários" )
   SetColor( SetColorNormal() )
   CLS
//   HB_GtInfo( HB_GTI_RESIZEMODE, HB_GTI_RESIZEMODE_ROWS )
   IF .NOT. AbreArquivos( { "jpsenha" } )
      RETURN NIL
   ENDIF
   GOTO TOP
   DO WHILE .NOT. Eof()
      AAdd( aLstUser, jpsenha->UserName )
      SKIP
   ENDDO
   CLOSE DATABASES
   DO WHILE .NOT. ::lExit
      Mensagem( "Selecione usuario a enviar mensagem" )
      wAchoice( 2, 2, aLstUser, @nOpcUser, "USUÁRIO" )
      Mensagem()
      IF LastKey() == K_ESC .OR. nOpcUser == 0
         EXIT
      ENDIF
      ::MessageFromUser( Trim( aLstUser[ nOpcUser ] ), "", "" )
   ENDDO
   ::lExit := .T.
   ::Close()
   RETURN NIL

METHOD MessageFromUser( cUser, cDateFrom, cText ) CLASS MessageClass
  LOCAL nNumWindow := 0, nCont

  FOR nCont = 1 TO Len( AppMessage() )
     IF AppMessage()[ nCont ]:cUser = cUser
        nNumWindow := nCont
        EXIT
     ENDIF
  NEXT
  IF nNumWindow == 0
     Aadd( AppMessage(), MessageClass():New() )
     nNumWindow := Len( AppMessage() )
     AppMessage()[ nNumWindow ]:Execute( cUser )
  ELSEIF AppMessage()[ nNumWindow ]:lExit
     AppMessage()[ nNumWindow ]:= MessageClass():New()
     AppMessage()[ nNumWindow ]:Execute( cUser )
  ENDIF
  IF .NOT. Empty( cText )
     Aadd( AppMessage()[ nNumWindow ]:acMessage, { cDateFrom, cText, .T. }  )
  ENDIF
  RETURN NIL

METHOD SendMessage() CLASS MessageClass
   LOCAL cText := Space(100), GetList := {}, cDateFrom, cnMySql := MySqlClass():New()
   MEMVAR m_Prog
   PUBLIC m_Prog

   wSave( MaxRow()-1, 0, MaxRow(), MaxCol() )
   Mensagem( "Digite mensagem a ser enviada, <ESC> abandona" )
   @ MaxRow(), 0 SAY "Mensagem:" GET cText PICTURE "@S" + Ltrim( Str( MaxCol() - 10 ) )
   READ
   wRestore()
   IF LastKey() == K_ESC .OR. Empty( cText ) .OR. ::lExit
      RETURN NIL
   ENDIF
   BEGIN SEQUENCE WITH { | e | Break( e ) }
      cnMySql:Open( .F. )
      cDateFrom := Transform( Dtos( Date() ), "@R 9999-99-99" ) + " " + Time()
      cnMySql:cSql := "INSERT INTO JPUSRMSG ( MSEMPRESA, MSFROM, MSTO, MSDATEFROM, MSTEXT, MSINFINC ) VALUES ( [EMPRESA], [REMETENTE], [DESTINATARIO], [EMISSAO], [TEXTO], [INFINC] )"
      cnMySql:Replace( "[EMPRESA]", StringSql( Trim( AppEmpresaApelido() ) ) )
      cnMySql:Replace( "[REMETENTE]", StringSql( AppUserName() ) )
      cnMySql:Replace( "[DESTINATARIO]", StringSql( ::cUser ) )
      cnMySql:Replace( "[EMISSAO]", StringSql( cDateFrom ) )
      cnMySql:Replace( "[TEXTO]", StringSql( cText ) )
      cnMySql:Replace( "[INFINC]", StringSql( LogInfo() ) )
      cnMySql:ExecuteCmd( , .F. )
      cnMySql:Close()
      Aadd( ::acMessage, { cDateFrom, cText } )
   ENDSEQUENCE
   RETURN NIL
*----------------------------------------------------------
