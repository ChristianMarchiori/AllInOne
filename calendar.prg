#include "inkey.ch"
#include "hbgtinfo.ch"

#ifdef GTWVG
FUNCTION TwoCalendar()
   LOCAL oButtons := {}, nRow, nCol, dDate, oElement

   hb_gtReload( hb_GTInfo( HB_GTI_VERSION ) )
   HB_GtInfo( HB_GTI_ICONRES, "AppIcon" )
   HB_GtInfo( HB_GTI_WINTITLE, "Sample Calendar" )
   HarbourInit()
   SetMode( 20, 80 )
   CLS
   nRow  := 1
   nCol  := 1
   dDate := Date()
   Calendar( nRow, nCol, dDate, oButtons )
   Calendar( nRow, nCol + 36, dDate - Day( dDate ) + 35, oButtons )
   DO WHILE Inkey(0) != K_ESC
   ENDDO
   FOR EACH oElement IN oButtons
      oElement:Destroy()
   NEXT
   RETURN NIL

FUNCTION Calendar( nRow, nCol, dDate, oButtons )
   LOCAL oThisButton, nRowCont, nColCont, nDay, nLastDay, nCont

   nRow := iif( nRow == NIL, 3, nRow )
   nCol := iif( nCol == NIL, 3, nCol )

   nDay     := 2 - Dow( dDate - Day( dDate ) + 1 ) // Dow of Day 1
   nLastDay := Day( LastDateMonth( dDate ) )
   FOR nColCont = 1 TO 7
      oThisButton := MyButton( nRow + 3, nCol + 1 + ( ( nColCont - 1 ) * 5 ), 1.5, 4, { "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT" }[ nColCont ] )
      Aadd( oButtons, oThisButton )
   NEXT
   FOR nRowCont = 1 TO 7
      FOR nColCont = 1 TO 7
         IF nDay > nLastDay
            EXIT
         ELSEIF nDay > 0
            oThisButton := MyButton( nRow + 6 + ( ( nRowCont - 1 ) * 2 ), nCol + 1 + ( ( nColCont - 1 ) * 5 ), 1.5, 4, Ltrim( Str( nDay ) ) )
            Aadd( oButtons, oThisButton )
         ENDIF
         nDay += 1
      NEXT
      IF nDay > nLastDay
         EXIT
      ENDIF
   NEXT
   oThisButton := MyButton( nRow + 1, nCol + 1, 1.5, 34, Upper( CMonth( dDate ) ) + "/" + StrZero( Year( dDate ), 4 ) )
   Aadd( oButtons, oThisButton )
   SetColor( "W/B" )
   @ nRow + 2, nCol CLEAR TO nRow + 4, nCol + 35
   SetColor( "W/G" )
   @ nRow + 5, nCol + 1 CLEAR TO nRow + 2 + ( nRowCont * 2 + 4 ), nCol + 4
   SetColor( "W/B" )
   @ nRow + 5, nCol + 5 CLEAR TO nRow + 2 + ( nRowCont * 2 + 4 ), nCol + 34
   SetColor( "W/N" )
   @ nRow, nCol TO nRow + 2 + ( nRowCont * 2 + 4 ), nCol + 35
   FOR nCont = 1 TO Len( oButtons )
      IF Empty( oButtons[ nCont ]:Caption )
         oButtons[ nCont ]:Hide()
      ENDIF
   NEXT
   wvgSetAppWindow():InvalidateRect()
   RETURN NIL

FUNCTION LastDateMonth( dDate )
   LOCAL dNewDate

   dNewDate := dDate - Day( dDate ) + 35
   dNewDate := dNewDate - Day( dNewDate )
   RETURN dNewDate

FUNCTION MyButton( nRowIni, nColIni, nWidth, nHeight, cCaption )
   LOCAL oThisButton
   oThisButton := wvgPushButton():New()
   oThisButton:PointerFocus := .F.
   oThisButton:Caption := cCaption
   oThisButton:Create( , , { -nRowIni, -nColIni }, { -nWidth, -nHeight } )
   RETURN oThisButton
#endif