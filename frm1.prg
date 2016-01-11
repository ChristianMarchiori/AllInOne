* 2014.02.10.1048 - Changed to use default parameters and compile standalone
* 2014.02.11.0821 - Correction for not wvg version

#include "hbclass.ch"
#include "inkey.ch"
#include "hbgtinfo.ch"

FUNCTION Frm1( lIsGraphic, lThread )

   LOCAL oFrm := frm1Class():New()

   lIsGraphic := iif( lIsGraphic == NIL, hb_gtInfo( HB_GTI_VERSION ) == "WVG", lIsGraphic )
   lThread    := iif( lThread == NIL, .F., lThread )
   IF lThread
      hb_gtReload( hb_GTInfo( HB_GTI_VERSION ) )
      HarbourInit()
   ENDIF
   HB_GtInfo( HB_GTI_ICONRES, "AppIcon" )
   HB_GtInfo( HB_GTI_WINTITLE, "Sample Database Class" )
   CreateDbf()
   CLS
   Aadd( oFrm:acMoreOptions, "Browse" )
   oFrm:lIsGraphic := lIsGraphic
   USE mydbf SHARED
   oFrm:Execute()
   CLOSE DATABASES
   RETURN NIL

CREATE CLASS frm1Class INHERIT frmCadClass

   METHOD DataEntry( lEdit )
   METHOD UserFunction()
   END CLASS

METHOD DataEntry( lEdit ) CLASS frm1Class

   LOCAL GetList := {}
   LOCAL cCode  := mydbf->Code
   LOCAL cName  := mydbf->Name
   LOCAL cPhone := mydbf->Phone

   lEdit := iif( lEdit == NIL, .F., lEdit )

   @ Row() + 1, 0 SAY "Code"
   @ Row(), 10    SAY "Name"
   @ Row() + 1, 0 GET cCode
   @ Row(), 10    GET cName
   @ Row() + 2, 0 SAY "Phone"
   @ Row() + 1, 0 GET cPhone
#ifdef GTWVG
   IF ::lIsGraphic
      SetPaintGetList( GetList )
   ENDIF
#endif
   IF .NOT. lEdit
     CLEAR GETS
     RETURN NIL
   ENDIF
   READ
   IF LastKey() != K_ESC
      rLock()
      REPLACE mydbf->Code WITH cCode, mydbf->Name WITH cName, mydbf->Phone WITH cPhone
      SKIP 0
      UNLOCK
   ENDIF
   RETURN NIL

METHOD UserFunction() CLASS frm1Class

   DO CASE
   CASE ::cOption == "B"
#ifdef GTWVG
      ::GuiHide()
#endif
      Browse()
#ifdef GTWVG
      ::GuiShow()
#endif
   ENDCASE
   RETURN NIL

STATIC FUNCTION CreateDbf()

   LOCAL aStru, nCont

   IF .NOT. File( "mydbf.dbf" )
      aStru := { ;
         { "CODE", "C", 5, 0 }, ;
         { "NAME", "C", 30, 0 }, ;
         { "PHONE", "C", 30, 0 } }
      dbCreate( "mydbf", aStru )
      USE mydbf SHARED
      FOR nCont = 1 TO 9
         APPEND BLANK
         REPLACE mydbf->Code WITH Replicate( Str( nCont, 1 ), 5 ), mydbf->Name WITH Replicate( Str( nCont, 1 ), 30 ), mydbf->Phone WITH Replicate( Str( nCont, 1 ), 30 )
      NEXT
      USE
   ENDIF
   RETURN NIL
