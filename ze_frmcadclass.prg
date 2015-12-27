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
#define OPTION_BROWSE   "B"

CREATE CLASS frmCadClass INHERIT frmClass
   METHOD Edit()
   METHOD Insert()
   METHOD Delete()
   METHOD First()
   METHOD Last()
   METHOD Previous()
   METHOD Next()
   METHOD DataEntry( lEdit )
   METHOD Execute()
   METHOD UserFunction()
   END CLASS

METHOD UserFunction() CLASS frmCadClass
   RETURN NIL

METHOD Edit() CLASS frmCadClass
   ::RowIni()
   ::DataEntry( .T. )
   RETURN NIL

METHOD Insert() CLASS frmCadClass
   APPEND BLANK
   ::RowIni()
   ::DataEntry( .T. )
   RETURN NIL

METHOD Delete() CLASS frmCadClass
   rLock()
   DELETE
   SKIP 0
   UNLOCK
   SKIP
   IF Eof()
      GOTO BOTTOM
   ENDIF
   RETURN NIL

METHOD First() CLASS frmCadClass
   GOTO TOP
   RETURN NIL

METHOD Last() CLASS frmCadClass
   GOTO BOTTOM
   RETURN NIL

METHOD Previous() CLASS frmCadClass
   SKIP -1
   RETURN NIL

METHOD Next() CLASS frmCadClass
   SKIP
   RETURN NIL

METHOD Execute() CLASS frmCadClass
   ::FormBegin()
   DO WHILE .T.
      ::RowIni()
      ::Dataentry( .F. )
      ::OptionSelect()
      DO CASE
      CASE ::cOption == OPTION_EXIT
         EXIT
      CASE ::cOption == OPTION_INSERT
         ::Insert()
      CASE ::cOption == OPTION_DELETE
         ::Delete()
      CASE ::cOption == OPTION_EDIT
         ::Edit()
      CASE ::cOption == OPTION_FIRST
         ::First()
      CASE ::cOption == OPTION_LAST
         ::Last()
      CASE ::cOption == OPTION_PREVIOUS
         ::Previous()
      CASE ::cOption == OPTION_NEXT
         ::Next()
      OTHERWISE
         ::UserFunction()
      ENDCASE
   ENDDO
   ::FormEnd()
   RETURN NIL

METHOD DataEntry( lEdit ) CLASS frmCadClass
   LOCAL GetList := {}, xVar1 := Space(10)

   ::RowIni()
   lEdit := iif( lEdit == NIL, .F., lEdit )
   @ Row() + 1, 0 SAY "Anything:" GET xVar1
   IF lEdit
      CLEAR GETS
      RETURN NIL
   ENDIF
   READ
   IF LastKey() != K_ESC
      // write to database
   ENDIF
   RETURN NIL
