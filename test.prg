PROCEDURE Main
   HarbourInit()
   hb_ThreadStart( { || MainMenu( .F. ) } )
   Inkey(3)
   WaitForThreads()
   RETURN
