#include "inkey.ch"
#include "set.ch"
#include "hbgtinfo.ch"

FUNCTION Progressbar()
   LOCAL nCont//, oCrt

   IF AppMultiWindow()
      hb_gtReload( hb_GTInfo( HB_GTI_VERSION ) )
      SetMode( 5, 80 )
      CLS
      HB_GtInfo( HB_GTI_ICONRES, "AppIcon" )
      HB_GtInfo( HB_GTI_WINTITLE, "progressbar" )
      HarbourInit()
   ENDIF
   GrafTempo( "Processando" )
   FOR nCont = 1 TO 10000000
      GrafTempo( nCont, 10000000 )
      IF Inkey() == K_ESC
         EXIT
      ENDIF
   NEXT
   RETURN NIL

#Define GRAFMODE 1
#Define GRAFTIME 2

FUNCTION GrafProc( nRow, nCol )
   LOCAL mSetDevice
   THREAD STATIC GrafInfo := { 1, "X" }
   nRow := iif( nRow == NIL, MaxRow() - 1, nRow )
   nCol := iif( nCol == NIL, MaxCol() - 2, nCol )
   IF GrafInfo[ GRAFTIME ] != Time()
      mSetDevice := Set( _SET_DEVICE, "SCREEN" )
      @ nRow, nCol SAY "(" + Substr( "|/-\", GrafInfo[ GRAFMODE ], 1 ) + ")" COLOR SetColorMensagem()
      GrafInfo[ GRAFMODE ] = iif( GrafInfo[ GRAFMODE ] == 4, 1, GrafInfo[ GRAFMODE ] + 1 )
      Set( _SET_DEVICE, mSetDevice )
      GrafInfo[ GRAFTIME ] := Time()
   ENDIF
   RETURN .T.

FUNCTION GrafTempo( xContNow, xContTotal )
   THREAD STATIC nStaticSecondsOld := 0, nStaticSecondsIni := 0, cStaticTxtBar := "", cStaticTxtText := ""
   LOCAL nSecondsNow, nSecondsRemaining, nSecondsElapsed, nCont, nPos, cTxt, cCorAnt
   LOCAL nPercent, cTexto, mSetDevice

   IF Empty( cStaticTxtBar )
      cStaticTxtBar := Replicate( ".", MaxCol() )
      FOR nCont = 1 to 10
         nPos         := Int( Len( cStaticTxtBar ) / 10 * nCont )
         cTxt         := lTrim( Str( nCont, 3 ) ) + "0%" + Chr(30)
         cStaticTxtBar := Stuff( cStaticTxtBar, ( nPos - Len( cTxt ) ) + 1, Len( cTxt ), cTxt )
      NEXT
      cStaticTxtBar := Chr(30) + cStaticTxtBar
   ENDIF
   mSetDevice := Set( _SET_DEVICE, "SCREEN" )
   DO CASE
   CASE ValType( xContNow ) == "C" .OR. xContNow == NIL
      cTexto := xContNow
   CASE xContTotal == NIL
      nPercent := xContNow
   CASE xContNow >= xContTotal
      nPercent := 100
   OTHERWISE
      nPercent := xContNow / xContTotal * 100
   ENDCASE
   xContNow := iif( ValType( xContNow ) != "N", 0, xContNow )
   xContTotal := iif( ValType( xContTotal ) != "N", 0, xContTotal )

   cCorAnt := SetColor()
   SetColor( SetColorMensagem() )
   nSecondsNow := Int( Seconds() )
   IF nPercent == NIL
      nStaticSecondsOld := nSecondsNow
      nStaticSecondsIni := nSecondsNow
      Mensagem()
      @ MaxRow(), 0 SAY cStaticTxtBar
      cStaticTxtText := iif( cTexto == NIL, "", cTexto )

   ELSEIF nPercent == 100 .OR. ( nSecondsNow != nStaticSecondsOld .AND. nPercent != 0 )
      nStaticSecondsOld := nSecondsNow
      nSecondsElapsed := nSecondsNow - nStaticSecondsIni
      DO WHILE nSecondsElapsed < 0; nSecondsElapsed += ( 24 * 3600 ) // Acima de 24 horas
      ENDDO
      nSecondsRemaining := nSecondsElapsed / nPercent * ( 100 - nPercent )
      @ MaxRow()-1, 0 SAY cStaticTxtText + " " + Ltrim( Transform( xContNow, PicVal(14,0) ) ) + "/" + Ltrim( Transform( xContTotal, PicVal(14,0)) )
      @ Row(), MaxCol()-40 SAY "Gasto:"
      @ Row(), Col() SAY Int( nSecondsElapsed / 3600 ) PICTURE "999"
      @ Row(), Col() SAY "h"
      @ Row(), Col() SAY Mod( Int( nSecondsElapsed / 60 ), 60 ) PICTURE "99"
      @ Row(), Col() SAY "m"
      @ Row(), Col() SAY Mod( nSecondsElapsed, 60 ) PICTURE "99"
      @ Row(), Col() SAY "s"
      @ Row(), Col()+3 SAY "Falta:"
      @ Row(), Col() SAY Int( nSecondsRemaining / 3600 ) PICTURE "999"
      @ Row(), Col() SAY "h"
      @ Row(), Col() SAY Mod( Int( nSecondsRemaining / 60 ), 60 ) PICTURE "99"
      @ Row(), Col() SAY "m"
      @ Row(), Col() SAY Mod( nSecondsRemaining, 60 ) PICTURE "99"
      @ Row(), Col() SAY "s"
      GrafProc()
      @ MaxRow(), 0 SAY Left( cStaticTxtBar, Len( cStaticTxtBar ) * nPercent / 100 ) COLOR SetColorFocus()
   ENDIF
   SetColor( cCorAnt )
   SET( _SET_DEVICE, mSetDevice )
   RETURN .T.

