FUNCTION ModalWindow()

   LOCAL oCrt, nSel

   oCrt := WvgCrt():New( /* parent */, /* owner */, { 4, 8 }, { 12, 49 }, , .T. )

   oCrt:lModal      := .T.
   oCrt:resizable   := .F.
   oCrt:closable    := .F.
   oCrt:title       := "Modal Dialog!"
   oCrt:icon        := "jpa.ico"
   oCrt:Create()
   oCrt:show()
   SetColor( "N/W" )
   CLS
   DO WHILE .T.
      nSel := Alert( "A modal window !;Click on parent window;Move this window", { "OK" } )
      IF nSel == 0 .OR. nSel == 1
         EXIT
      ENDIF
   ENDDO
   oCrt:Destroy()
   RETURN NIL
