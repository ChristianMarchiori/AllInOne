
#include "hbclass.ch"
#include "inkey.ch"
#include "hbgtinfo.ch"

#include "hbgtwvg.ch"
#include "wvtwin.ch"
#include "wvgparts.ch"
#include "ze_wvgtst.ch"

//---------------------------------------------------------------

//CREATE CLASS TstAnimation INHERIT TstAny
   //ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstBitmap INHERIT TstAny

   VAR ClassName  INIT "STATIC"
   VAR ObjType    INIT objTypeStatic
   VAR Style      INIT WIN_WS_CHILD + WIN_WS_GROUP + SS_BITMAP + SS_CENTERIMAGE + BS_NOTIFY
   VAR nIconBimap INIT WIN_IMAGE_BITMAP

   ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstButton INHERIT TstAny

   VAR className INIT "BUTTON"
   VAR objType   INIT objTypePushButton
   VAR style     INIT WIN_WS_CHILD + BS_PUSHBUTTON + BS_NOTIFY + BS_FLAT

   ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstCheckBox INHERIT TstAny

   VAR ClassName INIT "BUTTON"
   VAR objType   INIT objTypeCheckBox
   VAR Style     INIT WIN_WS_CHILD + WIN_WS_TABSTOP + BS_AUTOCHECKBOX
                      // BS_LEFTTEXT
   METHOD SetCheck( lCheck ) INLINE ::SendMessage( BM_SETCHECK, iif( lCheck, BST_CHECKED, BST_UNCHECKED ), 0 )

   ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstCombobox INHERIT TstAny

   VAR ClassName             INIT   "COMBOBOX"
   VAR ObjType               INIT   objTypeComboBox
   VAR Style                 INIT   WIN_WS_CHILD + WIN_WS_BORDER + WIN_WS_TABSTOP + WIN_WS_GROUP + CBS_DROPDOWNLIST
   METHOD AddItem( cText )   INLINE ::SendMessage( CB_ADDSTRING, 0, cText )
   METHOD SetValue( nIndex ) INLINE ::SendMessage( CB_SETCURSEL, nIndex - 1, 0 )

   ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstCommandLink INHERIT TstAny

   VAR ClassName           INIT   "BUTTON"
   VAR objType             INIT   objTypePushButton
   VAR Style               INIT   WIN_WS_CHILD + WIN_WS_BORDER + WIN_WS_TABSTOP + WIN_WS_GROUP + BS_COMMANDLINK
   METHOD SetNote( cText ) INLINE ::SendMessage( BCM_SETNOTE, 0, cText )

   ENDCLASS

//---------------------------------------------------------------

//CREATE CLASS TstDateTimePicker INHERIT TstAny
   //ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstEdit INHERIT TstAny

   VAR ClassName  INIT "EDIT"
   VAR objType    INIT objTypeSLE
   VAR Style      INIT WIN_WS_CHILD + WIN_WS_TABSTOP + WIN_WS_BORDER

   ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstEditMultiline INHERIT TstAny

   VAR ClassName INIT "EDIT"
   VAR ObjType   INIT objTypeMLE
   VAR Style     INIT WIN_WS_CHILD + WIN_WS_TABSTOP + ES_AUTOVSCROLL + ES_MULTILINE + ;
      ES_WANTRETURN + WIN_WS_BORDER + WIN_WS_VSCROLL

   ENDCLASS

//---------------------------------------------------------------

//CREATE CLASS TstFlatScrollbar INHERIT TstAny
   //ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstFrame INHERIT TstAny

   VAR ClassName  INIT "STATIC"
   VAR objType    INIT objTypeStatic
   VAR Style     INIT WIN_WS_CHILD + WIN_WS_GROUP + BS_GROUPBOX

   ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstGroupbox INHERIT TstAny

   VAR className INIT "BUTTON"
   VAR objType   INIT objTypePushButton
   VAR style     INIT WIN_WS_CHILD + WIN_WS_VISIBLE + WIN_WS_TABSTOP + BS_GROUPBOX + WIN_WS_EX_TRANSPARENT

   ENDCLASS

//---------------------------------------------------------------

//CREATE CLASS TstHeader INHERIT TstAny
   //VAR ClassName INIT "SysHeader32"
   //VAR Style     INIT WS_CHILD + WS_BORDER + HDS_BUTTONS + HDS_HORZ
   //ENDCLASS

//---------------------------------------------------------------

//CREATE CLASS TstHotkey INHERIT TstAny
   //ENDCLASS

//---------------------------------------------------------------

//CREATE CLASS TstHyperlink INHERIT TstAny
   //VAR ClassName  INIT "WC_LINK"
   //VAR objType    INIT objTypePushButton // *
   //ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstIcon INHERIT TstAny

   VAR ClassName   INIT "STATIC"
   VAR objType     INIT objTypeStatic
   VAR Style       INIT WIN_WS_CHILD + WIN_WS_GROUP + SS_ICON + SS_CENTERIMAGE + BS_NOTIFY
   VAR nIconBitmap INIT WIN_IMAGE_ICON

   ENDCLASS

//---------------------------------------------------------------

//CREATE CLASS TstImage INHERIT TstAny
   //VAR className INIT "STATIC"
   //VAR objType   INIT objTypeStatic
   //VAR style     INIT WIN_WS_CHILD
   //ENDCLASS

//---------------------------------------------------------------

//CREATE CLASS TstImageList INHERIT TstAny
   //ENDCLASS

//---------------------------------------------------------------

//CREATE CLASS TstIpAdress
   //ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstLineHorizontal INHERIT TstAny

   VAR ClassName  INIT "STATIC"
   VAR objType    INIT objTypeStatic
   VAR Style      INIT WIN_WS_CHILD + WIN_WS_VISIBLE + SS_ETCHEDHORZ + SS_SUNKEN

   ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstLineVertical INHERIT TstAny

   VAR ClassName  INIT "STATIC"
   VAR objType    INIT objTypeStatic
   VAR Style      INIT WIN_WS_CHILD + WIN_WS_VISIBLE + SS_ETCHEDVERT + SS_SUNKEN

   ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstListbox INHERIT TstAny

   VAR ClassName           INIT   "LISTBOX"
   VAR objType             INIT   objTypeListBox
   VAR Style               INIT   WIN_WS_CHILD + WIN_WS_VISIBLE + WIN_WS_TABSTOP + WIN_WS_GROUP
   METHOD AddItem( cText ) INLINE ::SendMessage( LB_ADDSTRING, 0, cText )
   METHOD Clear()          INLINE ::SendMessage( LB_RESETCONTENT, 0, 0 )
   METHOD ListCount()      INLINE ::SendMessage( LB_GETCOUNT, 0, 0 )
   METHOD ListItem()       INLINE ::SendMessage( LB_GETCURSEL, 0, 0 ) + 1

   ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstListView INHERIT TstAny

   VAR ClassName          INIT "SysListView32"
   VAR objType            INIT objTypeListBox // quebra-galho
   VAR Style              INIT WS_CHILD + WS_VISIBLE

   ENDCLASS
   //oControl:SendMessage( LVM_SETEXTENDEDLISTVIEWSTYLE, 0, LVS_EX_FULLROWSELECT )
   //oControl:SendMessage( LVM_INSERTCOLUMN, 0, "Sub item1" )
   //oControl:SendMessage( LVM_INSERTCOLUMN, 1, "Sub item2" )
   //oControl:SendMessage( LVM_INSERTCOLUMN, 2, "Sub item3" )
   //oControl:SendMessage( LVM_INSERTCOLUMN, 3, "Sub item4" )
   //oControl:SendMessage( LVM_INSERTCOLUMN, 4, "Sub item5" )
   //FOR nCont = 1 TO 10
   //   oControl:SendMessage( LVM_INSERTITEM, 0, 0 )
   //   FOR nCont2 = 1 TO 5
   //      oControl:SendMessage( LVM_INSERTCOLUMN, 0, { LVIF_TEXT, 256, 0, 0, "text" } )
   //   NEXT
   //NEXT

//---------------------------------------------------------------

//CREATE CLASS TstMaskEdit INHERIT TstAny
   //ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstMonthCalendar INHERIT TstAny

   VAR ClassName INIT "SysMonthCal32"
   VAR objType   INIT objTypeStatic
   VAR Style     INIT WIN_WS_CHILD // + MCS_NOTODAY + MCS_NOTODAYCIRCLE + MCS_WEEKNUMBERS
   METHOD create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ENDCLASS

METHOD create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   aSize := { 170, 245 }
   ::TstAny:Create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   RETURN Self

//---------------------------------------------------------------

//CREATE CLASS TstPager INHERIT TstAny
   //ENDCLASS

//---------------------------------------------------------------

//CREATE CLASS TstPathEdit INHERIT TstAny
   //ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstProgressbar INHERIT TstAny

   VAR ClassName INIT "msctls_progress32"
   VAR ObjType   INIT objTypeStatic
   VAR Style     INIT WIN_WS_CHILD + WIN_WS_GROUP + WIN_WS_EX_CLIENTEDGE
   METHOD SetValues( nValue, nRangeMin, nRangeMax )

   ENDCLASS

METHOD TstProgressbar:SetValues( nValue, nRangeMin, nRangeMax )

   IF HB_ISNUMERIC( nRangeMin ) .AND. HB_ISNUMERIC( nRangeMax )
      ::SendMessage( PBM_SETRANGE, 0, WIN_MAKELONG( nRangeMin, nRangeMax ) )
   ENDIF
   IF HB_ISNUMERIC( nValue )
      ::SendMessage( PBM_SETPOS, 15, 0 )
   ENDIF

   RETURN NIL

//---------------------------------------------------------------

//CREATE CLASS TstRichEdit INHERIT TstAny
   //ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstRadioButton INHERIT TstAny

   VAR ClassName INIT "BUTTON"
   VAR ObjType   INIT objTypePushButton
   VAR Style     INIT WIN_WS_CHILD + WIN_WS_TABSTOP + BS_AUTORADIOBUTTON
                      // BS_LEFTTEXT
   METHOD SetCheck( lCheck ) INLINE ::SendMessage( BM_SETCHECK, iif( lCheck, BST_CHECKED, BST_UNCHECKED ), 0 )

   ENDCLASS

//---------------------------------------------------------------

//CREATE CLASS TstRebar INHERIT TstAny
   //VAR ClassName INIT "reBarWindow32"
   //END CLASS

//---------------------------------------------------------------

CREATE CLASS TstRectangle INHERIT TstAny

   VAR ClassName INIT "STATIC"
   VAR Style     INIT WIN_WS_CHILD + WIN_WS_GROUP

   ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstScrollbar INHERIT TstAny

   VAR ClassName INIT "SCROLLBAR"
   VAR Style     INIT WIN_WS_CHILD
                      // SBS_VERT SBS_HORZ

   ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstscrollText INHERIT TstAny

   VAR ClassName INIT "EDIT"
   VAR Style     INIT WIN_WS_CHILD + WIN_WS_TABSTOP + ES_AUTOHSCROLL + WIN_WS_GROUP

   ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstStatusbar INHERIT TstAny

   VAR ClassName INIT "msctls_statusbar32"
   VAR Style  INIT WIN_WS_CHILD + WIN_WS_BORDER

   ENDCLASS

//---------------------------------------------------------------

//CREATE CLASS TstTab INHERIT TstAny
   //ENDCLASS

//---------------------------------------------------------------

//CREATE CLASS TstTabCtl32 INHERIT TstAny
   //VAR ClassName INIT "SysTabControl32"
   //VAR Style     INIT WIN_WS_CHILD + TCS_FOCUSNEVER
   //VAR objType   INIT objTypeTabPage
   //ENDCLASS

//---------------------------------------------------------------

//CREATE CLASS TstTaskDialog INHERIT TstAny
   //ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstText INHERIT TstAny

   VAR ClassName INIT "STATIC"
   VAR objType   INIT objTypeStatic
   VAR Style     INIT WIN_WS_CHILD + WIN_WS_GROUP + WIN_WS_EX_TRANSPARENT + SS_LEFT + SS_SIMPLE // + SS_LABEL
   METHOD new( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ENDCLASS

METHOD new( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::Clr_FG := hb_ColorIndex( SetColor(), 0 )
   ::clr_BG := hb_ColorIndex( SetColor(), 0 )
   ::tstAny:new( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   RETURN Self

//---------------------------------------------------------------

//CREATE CLASS TstToolbar INHERIT TstAny
   //VAR ClassName INIT "ToolbarWindow32"
   //ENDCLASS

//---------------------------------------------------------------

//CREATE CLASS TstTooltip INHERIT TstAny
   //ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstTrackbar INHERIT TstAny

   VAR ClassName INIT "msctls_trackbar32"
   VAR Style     INIT WS_CHILD + WS_VISIBLE + TBS_AUTOTICKS + TBS_ENABLESELRANGE
   VAR nPosAtu   INIT 0
   VAR bChanged  INIT NIL
   METHOD SetValues( nValue, nRangeMin, nRangeMax )
   METHOD handleEvent( nMessage, aNM )

   ENDCLASS

METHOD TstTrackbar:SetValues( nValue, nRangeMin, nRangeMax )

   IF HB_ISNUMERIC( nRangeMin ) .AND. HB_ISNUMERIC( nRangeMax )
      ::SendMessage( TBM_SETRANGE, .T., WIN_MAKELONG( nRangeMin, nRangeMax ) )
      ::SendMessage( TBM_SETSEL, .F., WIN_MAKELONG( nRangeMin, nRangeMax ) )
   ENDIF
   IF HB_ISNUMERIC( nValue )
      ::SendMessage( TBM_SETPOS, .T., nValue )
   ENDIF

   RETURN NIL

METHOD TstTrackbar:handleEvent( nMessage, aNM )

   WriteLogWndProc( nMessage, "TstAny " + ::ClassName, ::nControlID )
   IF nMessage == WM_CLOSE // receive this code when change step (while moving)
      ::nPosAtu := ::SendMessage( TBM_GETPOS, 0, 0 )
      IF ::bChanged != NIL
         Eval( ::bChanged, ::nPosAtu )
      ENDIF
   ENDIF

   RETURN ::TstAny:HandleEvent( nMessage, aNM )

//---------------------------------------------------------------

//CREATE CLASS TstTreeview INHERIT TstAny
   //ENDCLASS

//---------------------------------------------------------------

CREATE CLASS TstUpDown INHERIT TstAny

   VAR ClassName INIT "msctls_updown32"
   VAR Style     INIT WS_CHILD + WS_VISIBLE + UDS_ALIGNRIGHT
   METHOD SetValues( nValue, nRangeMin, nRangeMax )

   ENDCLASS

METHOD TstUpDown:SetValues( nValue, nRangeMin, nRangeMax )

   IF HB_ISNUMERIC( nRangeMin ) .AND. HB_ISNUMERIC( nRangeMax )
      ::SendMessage( UDM_SETRANGE, 0, WIN_MAKELONG( nRangeMin, nRangeMax ) )
   ENDIF
   IF HB_ISNUMERIC( nValue )
      ::SendMessage( UDM_SETPOS, 0, nValue )
   ENDIF

   RETURN NIL

//---------------------------------------------------------------

CREATE CLASS TstAny INHERIT WvgWindow

   VAR    autosize                              INIT .F.
   VAR    Border                                INIT .T.
   VAR    cancel                                INIT .F.
   VAR    cText
   VAR    default                               INIT .F.
   VAR    drawMode                              INIT WVG_DRAW_NORMAL
   VAR    preSelect                             INIT .F.
   VAR    pointerFocus                          INIT .F.
   VAR    Style                                 INIT 0
   VAR    cImage
   VAR    nIconBitmap                           INIT 0
   VAR    lSetCallback                          INIT .F.
   VAR    cFontName
   VAR    nFontSize

   METHOD new( oParent, oOwner, aPos, aSize, aPresParams, lVisible )
   METHOD create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )
   METHOD configure( oParent, oOwner, aPos, aSize, aPresParams, lVisible )
   METHOD destroy()
   METHOD handleEvent( nMessage, aNM )

   METHOD activate( xParam )                    SETGET
   METHOD setText()
   METHOD SetImage()
   METHOD draw( xParam )                        SETGET

   ENDCLASS

METHOD TstAny:new( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::wvgWindow:new( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   RETURN Self

METHOD TstAny:create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   LOCAL hOldFont

   //DO CASE
   //CASE ::nIconBitmap == 1 ; ::style += BS_ICON
   //CASE ::nIconBitmap == 2 ; ::style += BS_BITMAP
   //ENDCASE

   ::wvgWindow:create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::oParent:AddChild( Self )

   ::createControl()
   IF ::lSetCallback
      ::SetWindowProcCallback()  /* Let parent take control of it */
   ENDIF

   IF ::cFontName != NIL
      hOldFont := ::SendMessage( WIN_WM_GETFONT )
      ::SendMessage( WIN_WM_SETFONT, wvt_CreateFont( ::cFontName, ::nFontSize ), 0 )
      wvg_DeleteObject( hOldFont )
   ENDIF
   ::SetImage()
   ::SetText()
   IF .NOT. Empty( ::clr_BG )
      ::SetColorBG( ::Clr_BG )
   ENDIF
   IF .NOT. Empty( ::Clr_FG )
      ::SetColorFG( ::Clr_FG )
   ENDIF
   //IF ::IsCrtParent()
      //hOldFont := ::oParent:SendMessage( WIN_WM_GETFONT )
      //::SendMessage( WIN_WM_SETFONT, hOldFont, 0 )
   //ENDIF
   IF ::visible
      ::show()
   ENDIF
   ::setPosAndSize()

   RETURN Self

METHOD TstAny:handleEvent( nMessage, aNM )

   WriteLogWndProc( nMessage, "TstAny " + ::ClassName, ::nControlID )
   DO CASE
   CASE nMessage == HB_GTE_RESIZED
      IF ::isParentCrt()
         ::rePosition()
      ENDIF
      IF ::ClassName == "SysMonthCal32"
         ::InvalidateRect()
      ELSE
         ::sendMessage( WIN_WM_SIZE, 0, 0 )
         IF HB_ISEVALITEM( ::sl_resize )
            Eval( ::sl_resize, , , Self )
         ENDIF
      ENDIF
      //IF ::WControlName $ "CMDBUTTON"
      //   ::Repaint()
      //ENDIF

   CASE nMessage == HB_GTE_COMMAND
      IF aNM[ 1 ] == BN_CLICKED
         IF HB_ISEVALITEM( ::sl_lbClick )
            IF ::isParentCrt()
               ::oParent:setFocus()
            ENDIF
            Eval( ::sl_lbClick, , , Self )
            IF ::pointerFocus
               ::setFocus()
            ENDIF
         ENDIF
         RETURN EVENT_HANDLED
      ENDIF

   CASE nMessage == HB_GTE_NOTIFY

   CASE nMessage == HB_GTE_CTLCOLOR
      // error on harbour 3.2
      IF HB_ISNUMERIC( ::clr_FG )
         wapi_SetTextColor( aNM[ 1 ], ::clr_FG )
      ENDIF
      IF ! Empty( ::hBrushBG )
         wapi_SetBkMode( aNM[ 1 ], WIN_TRANSPARENT )
         RETURN ::hBrushBG
      ENDIF

   CASE ::lSetCallback .AND. nMessage == HB_GTE_ANY
      IF aNM[ 1 ] == WIN_WM_LBUTTONUP
         IF HB_ISEVALITEM( ::sl_lbClick )
            IF ::isParentCrt()
               ::oParent:setFocus()
            ENDIF
            Eval( ::sl_lbClick, , , Self )
         ENDIF
      ENDIF
   ENDCASE

   RETURN EVENT_UNHANDLED

METHOD PROCEDURE TstAny:destroy()

   LOCAL hOldFont

   IF ::cFontName != NIL
      hOldFont := ::SendMessage( WIN_WM_GETFONT )
      ::wvgWindow:destroy()
      ::wvgWindow:destroy()
      wvg_DeleteObject( hOldFont )
   ENDIF

   RETURN

METHOD TstAny:configure( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::Initialize( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   RETURN Self


METHOD TstAny:SetText()

   IF HB_ISCHAR( ::cText )
      ::sendMessage( WIN_WM_SETTEXT, 0, ::cText )
   ENDIF

   RETURN NIL

METHOD TstAny:SetImage()

   IF ::cImage != NIL .AND. ( ::nIconBitmap == WIN_IMAGE_ICON .OR. ::nIconBitmap == WIN_IMAGE_BITMAP )
      // BM_SETIMAGE on button, STM_SETIMAGE em outros
      ::sendMessage( STM_SETIMAGE, ::nIconBitmap,   wvg_LoadImage( ::cImage, 1, ::nIconBitmap ) )
   ENDIF

   RETURN NIL

METHOD TstAny:draw( xParam )

   IF HB_ISEVALITEM( xParam ) .OR. xParam == NIL
      ::sl_paint := xParam
   ENDIF

   RETURN Self

METHOD TstAny:activate( xParam )

   IF HB_ISEVALITEM( xParam ) .OR. xParam == NIL
      ::sl_lbClick := xParam
   ENDIF

   RETURN Self
