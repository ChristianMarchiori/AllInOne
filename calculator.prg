
#include "hbgtinfo.ch"
#include "inkey.ch"
#include "hbclass.ch"

FUNCTION Calculator()
   LOCAL oCalculator := CalculatorClass():New()

   IF AppMultiWindow()
      hb_gtReLoad( hb_GTInfo( HB_GTI_VERSION ) )
      SetMode( 15, 40 )
      CLS
      HB_GtInfo( HB_GTI_ICONRES, "AppIcon" )
      HB_GtInfo( HB_GTI_WINTITLE, "Calculator" )
      HarbourInit()
   ENDIF
//   SET KEY K_SH_F10 TO
   oCalculator:Execute()
//   SET KEY K_SH_F10 TO Calcula
   RETURN NIL

CREATE CLASS CalculatorClass
   DATA   nWidth              INIT 31
   DATA   nHeight             INIT 11
   DATA   nTop                INIT 1
   DATA   nLeft               INIT 1
   DATA   nValueTotal         INIT 0
   DATA   nValueMemory        INIT 0
   DATA   cValueDisplay       INIT ""
   DATA   cPendingOperation   INIT " "
   DATA   lBeginNumber        INIT .T.
   DATA   cSaveScreen
   DATA   acTape              INIT { " " }
   DATA   aGUIButtons         INIT {}
   DATA   acKeyboard          INIT { ;
      { "7",   "8", "9", "/", "C",  "MC" }, ;
      { "4",   "5", "6", "*", "CC", "MR" }, ;
      { "1",   "2", "3", "-", "%",  "M+" }, ;
      { "0",   ".", "=", "+", "T",  "M-" } }
   METHOD Execute()
   METHOD Number( cNumber )
   METHOD Comma()
   METHOD Back()
   METHOD Clear()
   METHOD InvertSignal()
   METHOD Operation( cOperation )
   METHOD Percent()
   METHOD Memory()
   METHOD LoadSaveValue( lSave )
   METHOD Show()
   METHOD WriteTape( cFlag )
   METHOD ShowTape()
   METHOD Move( nKey )
   METHOD GuiShow()
   METHOD GuiDestroy()
   ENDCLASS

METHOD Execute() CLASS CalculatorClass
   LOCAL cOldColor := SetColor(), nKey, cStrKey

   ::nTop  := Int( ( MaxRow() - 12 ) / 2 )
   ::nLeft := Int( ( MaxCol() - 32 ) / 2 )

   ::LoadSaveValue()
   SAVE SCREEN TO ::cSaveScreen
   ::GuiShow()
   DO WHILE .T.
      ::Show()
      nKey    := Inkey(0)
      cStrKey := iif( nKey == K_ENTER, "=", Upper( Chr( nKey ) ) )
      DO CASE
      CASE nKey == K_ESC
         KEYBOARD Chr( 205 )
         Inkey(0)
         EXIT
      CASE cStrKey == "D"
         ::LoadSaveValue( .T. )
      CASE nKey == K_BS .OR. cStrKey == "B"
         ::Back()
      CASE nKey == K_LEFT .OR. nKey == K_RIGHT .OR. nKey == K_UP .OR. nKey == K_DOWN .OR. nKey == K_CTRL_RIGHT .OR. nKey == K_CTRL_LEFT .OR. nKey == K_CTRL_UP .OR. nKey == K_CTRL_DOWN
         ::Move( nKey )
      CASE cStrKey $ "0123456789"
         ::Number( cStrKey )
      CASE cStrKey $ ".,"
         ::Comma()
      CASE cStrKey $ "+-*/="
         ::Operation( cStrKey )
      CASE cStrKey == "%"
         ::Percent()
      CASE cStrKey == "C"
         ::Clear()
      CASE cStrKey == "I"
         ::InvertSignal()
      CASE cStrKey == "M"
         ::Memory()
      CASE cStrKey == "T"
         ::ShowTape()
      ENDCASE
   ENDDO
   ::GuiDestroy()
   RESTORE SCREEN FROM ::cSaveScreen
   SetColor( cOldColor )
   RETURN NIL

METHOD Percent() CLASS CalculatorClass
   ::WriteTape( "%" )
   IF ::cPendingOperation $ "+-"
      ::cValueDisplay := ValToString( ::nValueTotal * Val( ::cValueDisplay ) / 100 )
   ELSEIF ::cPendingOperation == "/"
      ::cValueDisplay := ValToString( ::nValueTotal / Val( ::cValueDisplay ) * 100 )
   ELSE
      ::cValueDisplay := ValToString( Val( ::cValueDisplay ) / 100 )
   ENDIF
   RETURN NIL

METHOD Operation( cOperation ) CLASS CalculatorClass
   DO CASE
   CASE ::cPendingOperation == "+"
      ::nValueTotal := ::nValueTotal + Val( ::cValueDisplay )
   CASE ::cPendingOperation == "-"
      ::nValueTotal := ::nValueTotal - Val( ::cValueDisplay )
   CASE ::cPendingOperation == "*"
      ::nValueTotal := ::nValueTotal * Val( ::cValueDisplay )
   CASE ::cPendingOperation == "/"
      ::nValueTotal := ::nValueTotal / Val( ::cValueDisplay )
   OTHERWISE
      ::nValueTotal := Val( ::cValueDisplay )
   ENDCASE
   ::WriteTape( iif( ::cPendingOperation $ "+-*/", ::cPendingOperation, " " ) )
   ::cValueDisplay     := ValToString( ::nValueTotal )
   ::cPendingOperation := cOperation
   ::lBeginNumber      := .T.
   IF cOperation == "="
      ::WriteTape( cOperation )
      ::WriteTape()
   ENDIF
   RETURN NIL

METHOD InvertSignal() CLASS CalculatorClass
   ::cValueDisplay := ValToString( -Val( ::cValueDisplay ) )
   RETURN NIL

METHOD Comma() CLASS CalculatorClass
   IF ::lBeginNumber
      ::cValueDisplay := ""
   ENDIF
   ::lBeginNumber := .F.
   IF .NOT. "." $ ::cValueDisplay
      IF Len( ::cValueDisplay ) == 0
         ::cValueDisplay += "0"
      ENDIF
      ::cValueDisplay += "."
   ENDIF
   RETURN NIL

METHOD Number( cNumber ) CLASS CalculatorClass
   IF ::lBeginNumber
      ::cValueDisplay := ""
   ENDIF
   ::lBeginNumber := .F.
   IF cNumber == "0" .AND. Len( ::cValueDisplay ) == 0
      RETURN NIL
   ENDIF
   ::cValueDisplay += cNumber
   RETURN NIL

METHOD Back() CLASS CalculatorClass
   IF Len( ::cValueDisplay ) > 0
      ::cValueDisplay := Left( ::cValueDisplay, Len( ::cValueDisplay ) - 1 )
   ENDIF
   RETURN NIL

METHOD Clear() CLASS CalculatorClass
   ::cValueDisplay = ""
   IF ::cPendingOperation == "C"
      ::nValueTotal := 0
   ENDIF
   ::cPendingOperation := "C"
   RETURN NIL

METHOD Memory() CLASS CalculatorClass
   LOCAL cStrKey := " ", nKey := 0

   DO WHILE .NOT. cStrKey $ "CR+-" .AND. nKey != K_BS
      nKey := Inkey(0)
      cStrKey := Upper( Chr( nKey ) )
   ENDDO
   DO CASE
   CASE cStrKey == "C"
      ::nValueMemory := 0
   CASE cStrKey == "R"
      ::cValueDisplay := ValToString( ::nValueMemory )
   CASE cStrKey == "+"
      ::nValueMemory := ::nValueMemory + Val( ::cValueDisplay )
   CASE cStrKey == "-"
      ::nValueMemory := ::nValueMemory - Val( ::cValueDisplay )
   ENDCASE
   RETURN NIL

METHOD Show() CLASS CalculatorClass
   LOCAL nCont, nCont2

   DispBegin()
   SetColor( SetColorFocus() )
   @ ::nTop, ::nLeft CLEAR TO ::nTop + ::nHeight - 1, ::nLeft + ::nWidth - 1
   @ ::nTop, ::nLeft TO ::nTop + ::nHeight - 1 , ::nLeft + ::nWidth - 1
   @ ::nTop + 1, ::nLeft + 1  SAY iif( ::nValueMemory == 0, " ", "M" ) COLOR SetColorFocus()
   IF Val( ::cValueDisplay ) > 999999999999999999999999
      @ Row(), Col() SAY Padc( "OVERFLOW", ::nWidth - 4 ) COLOR SetColorAlerta()
   ELSE
      @ Row(), Col() SAY Padl( ValToString( Val( ::cValueDisplay ) ), ::nWidth - 5 ) COLOR SetColorFocus()
   ENDIF
   @ Row(), Col() SAY " " COLOR SetColorFocus()
   @ Row(), Col() SAY ::cPendingOperation COLOR SetColorFocus()
   @ ::nTop + 2, ::nLeft + 1 TO ::nTop + 2, ::nLeft + ::nWidth - 2
   FOR nCont = 1 TO Len( ::acKeyboard )
      FOR nCont2 = 1 TO Len( ::acKeyboard[ nCont ] )
         @ ::nTop + 1 + nCont * 2, ::nLeft + 1 + ( nCont2 - 1 ) * 5 SAY ::acKeyboard[ nCont, nCont2 ]
      NEXT
   NEXT
   DispEnd()
   RETURN NIL

METHOD WriteTape( cFlag ) CLASS CalculatorClass
   IF cFlag == NIL
      Aadd( ::acTape, Pad( "", ::nWidth - 2 ) )
   ELSE
      Aadd( ::acTape, Padl( ValToString( Val( ::cValueDisplay ) ), ::nWidth - 4 ) + " " + cFlag )
   ENDIF
   RETURN NIL

METHOD Move( nKey ) CLASS CalculatorClass
   ::GUIDestroy()
   RESTORE SCREEN FROM ::cSaveScreen
   DO CASE
   CASE nKey == K_LEFT
      ::nLeft := Max( 0, ::nLeft - 1 )
   CASE nKey == K_RIGHT
      ::nLeft := Min( MaxCol() - ::nWidth + 1, ::nLeft + 1 )
   CASE nKey == K_UP
      ::nTop := Max( 0, ::nTop - 1 )
   CASE nKey == K_DOWN
      ::nTop := Min( MaxRow() - ::nHeight + 1, ::nTop + 1 )
   CASE nKey == K_CTRL_UP
      ::nTop := 0
   CASE nKey == K_CTRL_DOWN
      ::nTop := MaxRow() - ::nHeight + 1
   CASE nKey == K_CTRL_LEFT
      ::nLeft := 0
   CASE nKey == K_CTRL_RIGHT
      ::nLeft := MaxCol() - ::nWidth + 1
   ENDCASE
   ::GuiShow()
   RETURN NIL

METHOD ShowTape() CLASS CalculatorClass
   LOCAL cScreen

   ::GuiDestroy()
   SAVE SCREEN TO cScreen
   @ ::nTop + 1, ::nLeft + 1 CLEAR TO ::nTop + ::nHeight - 2, ::nLeft + ::nWidth - 2
   aChoice( ::nTop + 1, ::nLeft + 1, ::nTop + ::nHeight - 2, ::nLeft + ::nWidth - 2, ::acTape, .t., , Len( ::acTape ) )
   RESTORE SCREEN FROM cScreen
   ::GUIShow()
   RETURN NIL

METHOD LoadSaveValue( lSave ) CLASS CalculatorClass
   LOCAL oGet

   lSave := iif( lSave == NIL, .f., lSave )
   oGet := GetActive()
   IF oGet != NIL
      IF oGet:Type == "N"
         IF lSave
            oGet:varPut( Val( ::cValueDisplay ) )
         ELSE
            ::cValueDisplay = ValToString( oGet:varGet() )
         ENDIF
      ENDIF
   ENDIF
   RETURN NIL

STATIC FUNCTION ValToString( nValue )
   LOCAL cValue := Ltrim( Str( nValue, 50, 16 ) )

   IF "." $ cValue
      DO WHILE Right( cValue, 1 ) $ "0"
         cValue := Left( cValue, Len( cValue ) - 1 )
      ENDDO
      IF Right( cValue, 1 ) == "."
         cValue := Left( cValue, Len( cValue ) - 1 )
      ENDIF
   ENDIF
   RETURN cValue

METHOD GUIShow() CLASS CalculatorClass
#ifdef GTWVG
   LOCAL nCont, nCont2, oThisButton
   FOR nCont = 1 TO Len( ::acKeyboard )
      FOR nCont2 = 1 TO Len( ::acKeyboard[ nCont ] )
         oThisButton := wvgPushButton():New()
         oThisButton:Caption := ::acKeyboard[ nCont, nCont2 ]
         oThisButton:PointerFocus := .F.
         oThisButton:Create( , , { -( ::nTop + 1 + nCont * 2 ), -( ::nLeft + 1 + ( nCont2 - 1 ) * 5 ) }, { -1.5, -4 } )
         oThisButton:Activate := &( [{ || __Keyboard( "] + ::acKeyboard[ nCont, nCont2 ] + [" ) }] )
         Aadd( ::aGUIButtons, oThisButton )
      NEXT
   NEXT
#endif
   RETURN NIL

METHOD GUIDestroy() CLASS CalculatorClass
   LOCAL oButton
   FOR EACH oButton IN ::aGUIButtons
#ifdef GTWVG
      oButton:Destroy()
#endif
   NEXT
   ::aGUIButtons := {}
   RETURN NIL
