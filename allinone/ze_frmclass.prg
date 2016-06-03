REQUEST __keyboard

#include "inkey.ch"
#include "hbclass.ch"

#define OPTION_INSERT   "I"
#define OPTION_DELETE   "D"
#define OPTION_EDIT     "E"
#define OPTION_NEXT     "N"
#define OPTION_PREVIOUS "P"
#define OPTION_FIRST    "F"
#define OPTION_LAST     "L"
#define OPTION_EXIT     "X"

CREATE CLASS frmClass

   VAR    cOption        INIT " "
   VAR    cOptions       INIT OPTION_INSERT + OPTION_EDIT + OPTION_DELETE
   VAR    acButtons      INIT {}
   VAR    acMoreOptions  INIT {}
   VAR    lIsGraphic     INIT .F.
   VAR    aGUIButtons    INIT {}
   VAR    oSaveBoxGet    INIT {}
   METHOD FormBegin()
   METHOD FormEnd()
   METHOD OptionCreate()
   METHOD OptionSelect()
   METHOD RowIni()
#ifdef GTWVG
   METHOD GUICreate()
   METHOD GUISelect()
   METHOD GUIShow()
   METHOD GUIHide()
   METHOD GUIEnable()
   METHOD GUIDisable()
   METHOD GUIDestroy()
#endif
   METHOD Init()
   END CLASS

METHOD Init() CLASS frmClass

   SET SCOREBOARD OFF
   SET( _SET_EVENTMASK, INKEY_ALL - INKEY_MOVE )
   SetColor( "0/7,0/15,,,0/15" )
   RETURN NIL

METHOD FormBegin() CLASS frmClass

   ::OptionCreate()
   RETURN NIL

METHOD FormEnd() CLASS frmClass
#ifdef GTWVG
   ::GUIDestroy()
#endif
   RETURN NIL

METHOD OptionCreate() CLASS frmClass

   LOCAL nCont

   ::acButtons := {}
   IF OPTION_EDIT $ ::cOptions
      Aadd( ::acButtons, "Edit" )
   ENDIF
   IF OPTION_INSERT $ ::cOptions
      Aadd( ::acButtons, "Insert" )
   ENDIF
   IF OPTION_DELETE $ ::cOptions
      Aadd( ::acButtons, "Delete" )
   ENDIF
   Aadd( ::acButtons, "First" )
   Aadd( ::acButtons, "Last" )
   Aadd( ::acButtons, "Previous" )
   Aadd( ::acButtons, "Next" )
   FOR nCont = 1 TO Len( ::acMoreOptions )
      Aadd( ::acButtons, ::acMoreOptions[ nCont ] )
   NEXT
   Aadd( ::acButtons, "X(Exit)" )
#ifdef GTWVG
   IF ::lIsGraphic
      ::GuiCreate()
   ENDIF
#endif
   RETURN NIL

METHOD OptionSelect() CLASS frmClass

   LOCAL nCont, nOpc := 0, oButton

#ifdef GTWVG
   IF ::lIsGraphic
      ::GUISelect()
      RETURN NIL
   ENDIF
#endif
   FOR nCont = 1 TO Len( ::acButtons )
      IF ::cOption == Substr( ::acButtons[ nCont ], 1, 1 )
         nOpc :=  nCont
         EXIT
      ENDIF
   NEXT
   nOpc := Max( nOpc, 1 )
   @ MaxRow(), 0 SAY ""
   FOR EACH oButton IN ::acButtons
      @ Row(), iif( Col() == 0, 0, Col() + 2 ) PROMPT oButton
   NEXT
   MENU TO nOpc
   IF nOpc == 0 .OR. LastKey() == K_ESC
      ::cOption := OPTION_EXIT
   ELSE
      ::cOption := Substr( ::acButtons[ nOpc ], 1, 1 )
   ENDIF
   RETURN NIL

METHOD RowIni() CLASS frmClass
#ifdef GTWVG
   IF ::lIsGraphic
      @ 5, 1 SAY ""
   ELSE
      @ 1, 1 SAY ""
   ENDIF
#else
   @ 1, 1 SAY ""
#endif
   RETURN NIL

#ifdef GTWVG
   METHOD GUICreate() CLASS frmClass

      LOCAL nCol, oThisButton, cToolTip, cColorAnt, oButton

      cColorAnt := SetColor( "7/0" )
      @ 0, 0 CLEAR TO 4, MaxCol()
      SetColor( cColorAnt )
      nCol := 1
      FOR EACH oButton IN ::acButtons
         oThisButton := wvgPushButton():New()
         oThisButton:PointerFocus := .f.
         oThisButton:Caption := IconFromCaption( oButton, @cToolTip )
         oThisButton:Create( , , { -1, iif( nCol == 0, -0.1, -nCol ) }, { -3, -5 } )
         oThisButton:ToolTipText := cToolTip
         oThisButton:Activate := &( [{ || __Keyboard( "] + Substr( oButton, 1, 1 ) + [") }] )
         Aadd( ::aGuiButtons, oThisButton )
         nCol += 5
      NEXT
      ::GuiShow()
      RETURN NIL

   METHOD GUISelect() CLASS frmClass

      LOCAL nKey

      ::GuiEnable()
      nKey := Inkey(0)
      ::cOption := Chr( nKey )
      ::GuiDisable()
      IF LastKey() == K_ESC
         ::cOption := OPTION_EXIT
      ENDIF
      RETURN NIL

   METHOD GUIEnable() CLASS frmClass

      LOCAL oButton

      FOR EACH oButton IN ::aGUIButtons
         oButton:Enable()
      NEXT
      RETURN NIL

   METHOD GUIDisable() Class frmClass

      LOCAL oButton

      FOR EACH oButton IN ::aGUIButtons
         oButton:Disable()
      NEXT
      RETURN NIL

   METHOD GUIHide() Class frmClass

      LOCAL oButton

      FOR EACH oButton IN ::aGUIButtons
         oButton:Hide()
      NEXT
      ::oSaveBoxGet := SetPaintBlock()
      SetPaintBlock( {} )
      RETURN NIL

    METHOD GuiShow() Class frmClass

      LOCAL oButton

      FOR EACH oButton IN ::aGUIButtons
         oButton:Show()
      NEXT
      SetPaintBlock( ::oSaveBoxGet )
      RETURN NIL

   METHOD GUIDestroy() Class frmClass

      LOCAL oButton

      FOR EACH oButton IN ::aGUIButtons
         oButton:Destroy()
      NEXT
      SetPaintBlock( {} )
      RETURN NIL

   STATIC FUNCTION IconFromCaption( cCaption, cToolTip )

      LOCAL xSource

      cToolTip := ""
      DO CASE
      CASE cCaption == "Edit";       xSource := "cmdEdit";     cToolTip := "Edit Current Record"
      CASE cCaption == "Insert";     xSource := "cmdInsert";   cToolTip := "Insert a New Record"
      CASE cCaption == "Delete";     xSource := "cmdDelete";   cToolTip := "Delete Current Record"
      CASE cCaption == "First";      xSource := "cmdFirst";    cToolTip := "Goto First Record"
      CASE cCaption == "Last";       xSource := "cmdLast";     cToolTip := "Goto Last  Record"
      CASE cCaption == "Previous";   xSource := "cmdPrevious"; cToolTip := "Goto Previous Record"
      CASE cCaption == "Next";       xSource := "cmdNext";     cToolTip := "Goto Next Record"
      CASE cCaption == "X(Exit)";    xSource := "cmdExit";     cToolTip := "Exit This Module"
      CASE cCaption == "Browse" ;    xSource := "cmdBrowse" ;  cTooltip := "View List of Records"
      OTHERWISE
         @ 22, 10 SAY cCaption
      ENDCASE
      xSource := { , WVG_IMAGE_BITMAPRESOURCE, xSource }
      RETURN xSource

FUNCTION wvt_Paint()

   wvtPaintObjects()
   RETURN NIL

FUNCTION SetPaintBlock( oNewBlock )

   LOCAL oOldBlock
   THREAD STATIC oBlock := {}

   oOldBlock := oBlock
   IF oNewBlock != NIL
      oBlock := oNewBlock
      wvtSetPaint( oBlock )
   ENDIF
   RETURN oOldBlock

FUNCTION SetPaintGetList( GetList )

   LOCAL oPos := {} , oGet

   FOR EACH oGet IN GetList
      Aadd( oPos, { oGet:Row, oGet:Col, oGet:Row, oGet:Col - 1 + Len( Transform( oGet:VarGet(), oGet:Picture ) ) } )
   NEXT
   SetPaintBlock( { { "Gets", {|| AEval( oPos, {| oPosi | DrawBoxGetFlat( oPosi ) } ) }, NIL } } )
   wvgSetAppWindow():Refresh()
   RETURN NIL


STATIC FUNCTION DrawBoxGetFlat( oPos )

   LOCAL nColor := WIN_RGB( 100, 100, 100 )

   wvt_DrawLine( oPos[1], oPos[2], oPos[1], oPos[4], WVT_LINE_HORZ, WVT_LINE_PLAIN, WVT_LINE_TOP, WVT_LINE_SOLID, 1, nColor )
   wvt_DrawLine( oPos[1], oPos[2], oPos[1], oPos[2], WVT_LINE_VERT, WVT_LINE_PLAIN, WVT_LINE_LEFT, WVT_LINE_SOLID, 1, nColor )
   wvt_DrawLine( oPos[1], oPos[2], oPos[1], oPos[4], WVT_LINE_HORZ, WVT_LINE_PLAIN, WVT_LINE_BOTTOM, WVT_LINE_SOLID, 1, nColor )
   wvt_DrawLine( oPos[3], oPos[4], oPos[3], oPos[4], WVT_LINE_VERT, WVT_LINE_PLAIN, WVT_LINE_RIGHT, WVT_LINE_SOLID, 1, nColor )
   RETURN NIL
#endif

