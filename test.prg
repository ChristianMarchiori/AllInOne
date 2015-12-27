PROCEDURE Main
   HarbourInit()
   RunThread( { || MainMenu( .F. ) } )
   DO WHILE RunThread()
      HB_IdleSleep(1)
   ENDDO
   RETURN

FUNCTION RunThread( bCode )
   STATIC AppThreadList := {}, s_Mutex := hb_MutexCreate()
   LOCAL  nCont, lIsRunning := .F.

   hb_MutexLock( s_Mutex )

   IF bCode == NIL
      IF Len( AppThreadList ) != 0
         lIsRunning := .F.
         FOR nCont = Len( AppThreadList ) TO 1 STEP -1
            IF hb_ThreadWait( AppThreadList[ nCont ], 0.1, .T. ) != 1
               lIsRunning := .T.
            ELSE
               aDel( AppThreadList, nCont )
               aSize( AppThreadList, Len( AppThreadList ) - 1 )
            ENDIF
         NEXT
      ENDIF
   ELSE
      Aadd( AppThreadList, hb_ThreadStart( bCode ) )
   ENDIF
   hb_MutexUnlock( s_Mutex )
   RETURN lIsRunning
