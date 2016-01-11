#ifdef GTWVG
   #include "wvtwin.ch"
#endif
#include "inkey.ch"
#include "hbgtinfo.ch"

THREAD STATIC AppSaveScreen := {}

FUNCTION AppMainThread( xValue )

   STATIC AppMainThread

   IF xValue != NIL
      AppMainThread := xValue
   ENDIF
   RETURN AppMainThread

FUNCTION AppMultiWindow()

   LOCAL lValue

   IF "WIN" $ hb_gtInfo( HB_GTI_VERSION )
      lValue := .F.
   ELSE
      lValue := .T.
   ENDIF
   RETURN lValue

FUNCTION AppUserName( xValue )

   STATIC AppUserName := ""

   IF xValue != NIL
      AppUserName := xValue
   ENDIF
   RETURN AppUserName

FUNCTION AppMessage()

   STATIC AppMessage := { NIL, NIL }

   RETURN AppMessage

FUNCTION HarbourInit()

   SET SCOREBOARD OFF
   SET DELETED    ON
   SET( _SET_EVENTMASK, INKEY_ALL - INKEY_MOVE ) // + HB_INKEY_GTEVENT )
   hb_gtInfo( HB_GTI_SELECTCOPY, .T. )
   hb_gtInfo( HB_GTI_INKEYFILTER, { | nKey |
      LOCAL nBits, lIsKeyCtrl

      nBits := hb_GtInfo( HB_GTI_KBDSHIFTS )
      lIsKeyCtrl := ( nBits == hb_BitOr( nBits, HB_GTI_KBD_CTRL ) )
      SWITCH nKey
      CASE K_MWBACKWARD
         RETURN K_DOWN
      CASE K_MWFORWARD
         RETURN K_UP
      CASE K_RBUTTONDOWN
         RETURN K_ESC
      CASE K_RDBLCLK
         RETURN K_ESC
      CASE K_INS
         IF lIsKeyCtrl
            hb_GtInfo( HB_GTI_CLIPBOARDPASTE )
            RETURN 0
         ENDIF
      CASE K_CTRL_C
         IF lIsKeyCtrl
            IF GetActive() != NIL
               hb_gtInfo( HB_GTI_CLIPBOARDDATA, Transform( GetActive():varGet(), "" ) )
               RETURN 0
            ENDIF
         ENDIF
      ENDSWITCH
      RETURN nKey
       } )
   RETURN NIL

FUNCTION SetColorTitulo()

   RETURN "W/G,N/W,,,W/G"

FUNCTION SetColorNormal()

   RETURN "W/B,N/W,,,W/B"

FUNCTION SetColorMensagem()

   RETURN "W/N,N/W,,,W/N"

FUNCTION SetColorFocus()

   RETURN "N/W,W/N,,,N/W"

FUNCTION SetColorBox()

   RETURN "W/GR,N/W,,,W/Gr"

FUNCTION SetColorAlerta()

   RETURN "W/R,N/W,,,W/R"

FUNCTION Mensagem( cTexto )

   LOCAL cColorOld := SetColor()

   cTexto := iif( cTexto == NIL, "", cTexto )
   Scroll( MaxRow()-1, 0, MaxRow(), MaxCol(), 0 )
   @ MaxRow()-1, 0 SAY cTexto
   SetColor( cColorOld )
   RETURN NIL

FUNCTION WSave()

   Aadd( AppSaveScreen, SaveScreen() )
   RETURN NIL

FUNCTION WRestore()

   IF Len( AppSaveScreen ) > 0
      RestScreen( ,,,,ATail( AppSaveScreen ) )
      aSize( AppSaveScreen, Len( AppSaveScreen ) - 1 )
   ENDIF
   RETURN NIL

FUNCTION WOpen( nUp, nLeft, nRight, nDown, cTitle )

   wSave()
   @ nUp, nLeft TO nRight, nDown
   @ nUp+1, nLeft+1 CLEAR TO nRight-1, nDown-1
   @ nUp, nLeft + 1 SAY Pad( cTitle, nRight - nLeft - 1 )
   RETURN NIL

FUNCTION WClose()

   WRestore()
   RETURN NIL

FUNCTION PicVal( nLen, nDec )

   LOCAL cPicture

   nDec := iif( nDec == NIL, 0, nDec )
   cPicture := "999,999,999,999,999,999"
   cPicture := Transform( val( Replicate( "9", nLen - nDec ) ), cPicture )
   IF nDec > 0
      cPicture := cPicture + "." + Replicate( "9", nDec )
   ENDIF
   RETURN cPicture

FUNCTION SayScroll( cText )

   cText := iif( cText == NIL, "", cText )
   Scroll( 2, 0, MaxRow() - 3, MaxCol(), 1 )
   @ MaxRow() - 3, 0 SAY cText
   RETURN NIL

#ifdef GTWVG
FUNCTION MsgYesNo( cText )

   RETURN wapi_MessageBox( wapi_GetActiveWindow(), cText, "Confirm", MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2 ) == IDYES

FUNCTION MsgExclamation( cText )

   RETURN wapi_MessageBox( wapi_GetActiveWindow(), cText, "Atention", MB_ICONASTERISK )

FUNCTION MsgWarning( cText )

   RETURN wapi_MessageBox( wapi_GetActiveWindow(), cText, "Warning", MB_ICONEXCLAMATION )

FUNCTION MsgStop( cText )

   RETURN wapi_MessageBox( wapi_GetActiveWindow(), cText, "Wait", MB_ICONHAND )
#endif

FUNCTION ReturnValue( xValue, ... )

   RETURN xValue

FUNCTION RecLock()

   RLock()
   RETURN .T.

FUNCTION RecUnlock()

   UNLOCK
   RETURN NIL

FUNCTION RunCmd( cComando )

   RUN ( cComando )
   RETURN NIL

FUNCTION Cls()

   Scroll( 1, 0, MaxRow() - 3, MaxCol(), 0 )
   RETURN NIL

FUNCTION GravaOcorrencia( ... )

   RETURN NIL

FUNCTION RecDelete()

   RecLock()
   DELETE
   RecUnlock()
   RETURN NIL

FUNCTION MyTempFile( cExtensao )

   RETURN "temp." + cExtensao

FUNCTION MacroType( cExpression )

   LOCAL cType := "U", bBlock

   BEGIN SEQUENCE WITH { | e | Break( e ) }
      bBlock := hb_MacroBlock( cExpression )
      cType  := ValType( Eval( bBlock ) )
   END SEQUENCE
   RETURN cType
