#include "hbclass.ch"
#include "inkey.ch"
#include "hbgtinfo.ch"

#include "hbgtwvg.ch"
#include "wvtwin.ch"
#include "wvgparts.ch"

CREATE CLASS TstRectangle INHERIT WvgWindow
   VAR ClassName      INIT "STATIC"
   VAR Style          INIT WIN_WS_CHILD + WIN_WS_GROUP
   VAR autosize       INIT .F.
   VAR Border         INIT .T.
   VAR cancel         INIT .F.
   VAR default        INIT .F.
   VAR drawMode       INIT WVG_DRAW_NORMAL
   VAR preSelect      INIT .F.
   VAR pointerFocus   INIT .F.
   METHOD new( oParent, oOwner, aPos, aSize, aPresParams, lVisible )
   METHOD create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )
   METHOD configure( oParent, oOwner, aPos, aSize, aPresParams, lVisible )
   METHOD destroy()
   METHOD handleEvent( nMessage, aNM )
   ENDCLASS

METHOD tstRectangle:new( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::wvgWindow:new( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   RETURN Self

METHOD tstRectangle:create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::wvgWindow:create( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::oParent:AddChild( Self )

   ::createControl()
   IF ::visible
      ::show()
   ENDIF
   ::setPosAndSize()

   RETURN Self

METHOD tstRectangle:handleEvent( nMessage, aNM )

   DO CASE
   CASE nMessage == HB_GTE_RESIZED
      IF ::isParentCrt()
         ::rePosition()
      ENDIF
      ::sendMessage( WIN_WM_SIZE, 0, 0 )
      IF HB_ISEVALITEM( ::sl_resize )
         Eval( ::sl_resize, , , Self )
      ENDIF

   ENDCASE
   HB_SYMBOL_UNUSED( aNM )
   RETURN EVENT_UNHANDLED

METHOD tstRectangle:destroy()

   ::wvgWindow:destroy()

   RETURN NIL

METHOD tstRectangle:configure( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   ::Initialize( oParent, oOwner, aPos, aSize, aPresParams, lVisible )

   RETURN Self
