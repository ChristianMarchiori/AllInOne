FUNCTION pdf()

   LOCAL oPDF, nCont, nType

   HarbourInit()
   FOR nType = 1 TO 3
      oPDF := PDFClass():New()
      oPDF:nType := nType
      oPDF:cHeader := "RELATORIO TESTE" + Str( nType, 1 )
      oPDF:cFileName := "teste" + Str( nType, 1 ) + "." + iif( nType < 3, "pdf", "lst" )
      oPDF:Begin()
      FOR nCont = 1 TO 1000
         oPDF:MaxRowTest()
         oPDF:DrawText( oPDF:nRow++, 0, nCont )
      NEXT
      oPDF:End()
   NEXT
   RETURN NIL
