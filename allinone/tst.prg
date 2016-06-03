PROCEDURE Main

   HarbourInit()
   hb_ThreadStart( { || MainMenu( .F. ) } )
   Inkey(3)
   hb_ThreadWaitForAll()
   RETURN
