* ZErrorsys.prg - Modified Standard Clipper Error handler
*----------------------------------------------------------------

#include "error.ch"

// put messages to STDERR
#command ? <list,...>   =>  ?? HB_EOL() ; ?? <list>
#command ?? <list,...>  =>  OutErr(<list>)

* ErrorSys()
* Note:  automatically executes at startup

PROCEDURE ERRORSYS
   ErrorBlock( { |e| DefError( e ) } )
   RETURN

* DefError()

STATIC FUNCTION DefError( e )
   LOCAL nCont, cMessage, aOptions, nChoice

   // by default, division by zero yields zero
   IF ( e:GenCode == EG_ZERODIV )
      RETURN ( 0 )
   ENDIF

   // For network open error, set NETERR() and subsystem default
   IF ( e:GenCode == EG_OPEN .AND. e:OsCode == 32 .AND. e:CanDefault )
      NetErr( .T. )
      RETURN ( .F. )									// NOTE
   ENDIF

   // for lock error during APPEND BLANK, set NETERR() and subsystem default
   IF ( e:GenCode == EG_APPENDLOCK .AND. e:CanDefault )
      NetErr( .T. )
      RETURN ( .F. )									// NOTE
   ENDIF

   // build error message
   cMessage := ErrorMessage(e)

   // build options array
   // aOptions := { "Break", "Quit" }
   aOptions := { "Quit" }

   IF e:GenCode == EG_WRITE .OR. e:GenCode == EG_READ .OR. e:GenCode == EG_LOCK .OR. e:GenCode == EG_APPENDLOCK
      e:CanRetry := .T.
   ENDIF

   IF ( e:CanRetry )
      AAdd( aOptions, "Retry" )
   ENDIF

   IF ( e:CanDefault )
      AAdd( aOptions, "Default" )
   ENDIF

   // put up alert box
   IF "DATA WIDTH ERROR" $ Upper( cMessage ) .AND. e:CanDefault
      nChoice := aScan( aOptions, "Default" ) // default
   ELSE
      nChoice := 0
   ENDIF
   DO WHILE ( nChoice == 0 )
      IF ( Empty(e:osCode) )
         nChoice := Alert( cMessage, aOptions )
      ELSE
         nChoice := Alert( cMessage + ";(DOS Error " + Ltrim( Str( e:OsCode ) ) + ")", aOptions )
      ENDIF
      IF ( nChoice == NIL )
         EXIT
      ENDIF
   ENDDO

   IF ( !Empty( nChoice ) )
      // do as instructed
      IF ( aOptions[ nChoice ] == "Break" )
         Break(e)
      ELSEIF ( aOptions[ nChoice ] == "Retry" )
         RETURN (.T.)
      ELSEIF ( aOptions[ nChoice ] == "Default" )
         RETURN (.F.)
      ENDIF
   ENDIF

   // display message and traceback
   IF ( !Empty( e:OsCode ) )
      cMessage += " (DOS Error " + Ltrim( Str( e:OsCode ) ) + ") "
   ENDIF

   WriteErrorLog( , 1 ) // with machine ID
   ? cMessage
   WriteErrorLog( cMessage )
   nCont := 2
   DO WHILE ( .NOT. Empty( ProcName( nCont ) ) )
      cMessage = "Called from " + Trim( ProcName( nCont ) ) + "(" + Ltrim( Str( ProcLine( nCont ) ) ) + ")  "
      ? cMessage
      WriteErrorLog( cMessage )
      nCont++
   ENDDO
   WriteErrorLog( Replicate( "-", 80 ) )
   RUN ( "start notepad.exe error.log" )
   // give up
   ErrorLevel(1)
   QUIT
   RETURN (.F.)


* ErrorMessage()

STATIC FUNCTION ErrorMessage(e)
   LOCAL cMessage

   // start error message
   cMessage := if( e:Severity > ES_WARNING, "Error ", "Warning " )

   // add subsystem name IF available
   IF ( ValType( e:SubSystem ) == "C" )
      cMessage += e:SubSystem()
   ELSE
      cMessage += "???"
   ENDIF

   // add subsystem's error code IF available
   IF ( ValType( e:SubCode ) == "N" )
      cMessage += ( "/" + Ltrim(Str( e:SubCode ) ) )
   ELSE
      cMessage += "/???"
   ENDIF

   // add error description IF available
   IF ( ValType( e:Description ) == "C" )
      cMessage += ( "  " + e:Description )
   ENDIF

   // add either filename or operation
   IF ( ! Empty( e:Filename ) )
      cMessage += (": " + e:Filename )
   ELSEIF ( ! Empty( e:Operation ) )
      cMessage += ( ": " + e:Operation )
   ENDIF
   RETURN ( cMessage )


FUNCTION WriteErrorLog( cText, nDetail )
   LOCAL nHandle, cFileName, nCont, nCont2

   cText   := iif( cText == NIL, "", cText )
   nDetail := iif( nDetail == NIL, 0, nDetail )

   IF nDetail > 0
      WriteErrorLog( Replicate( "-", 80 ) )
      WriteErrorLog( "Error on " + Dtoc( Date() ) + " " + Time() )
      WriteErrorLog( "Computer Name: " + GetEnv( "COMPUTERNAME" ) )
      WriteErrorLog( "User Name: "     + GetEnv( "USERNAME" ) )
      WriteErrorLog( "Logon Server: "  + Substr( GetEnv( "LOGONSERVER" ), 2 ) )
      WriteErrorLog( "Client Name: "   + GetEnv( "CLIENTNAME" ) )
      WriteErrorLog( "User Domain: "   + GetEnv( "USERDOMAIN" ) )
      WriteErrorLog( "OS: " + Os() )
      WriteErrorLog( "Harbour: " + Version() )
      WriteErrorLog( "Compiler: " + HB_Compiler() )
      WriteErrorLog()
   ENDIF
   cFileName := "error.log"
   IF .NOT. File( cFileName )
      nHandle := fCREATE( cFileName )
      fClose( nHandle )
   ENDIF

   nHandle := fOpen( cFileName, 1 )
   fSeek( nHandle, 0, 2 )
   fWrite( nHandle, cText + HB_EOL() )
   IF nDetail > 1
      nCont := 2
      nCont2 := 0
      DO WHILE nCont2 < 5
         IF .NOT. Empty( ProcName( nCont ) )
            cText := "Called from " + Trim( ProcName( nCont ) ) + "(" + Ltrim(Str( ProcLine( nCont ) ) ) + ")  "
            WriteErrorLog( cText )
         ELSE
            nCont2++
         ENDIF
         nCont++
      ENDDO
   ENDIF
   fClose( nHandle )
   RETURN NIL
