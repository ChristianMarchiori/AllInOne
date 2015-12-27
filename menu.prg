#include "hbgtinfo.ch"
#include "inkey.ch"

FUNCTION MenuCria()
   MEMVAR nMenuLevel, oMenuOptions
   PRIVATE nMenuLevel, oMenuOptions

nMenuLevel   := 0
oMenuOptions := {}
MenuOption( "General" )
   MenuDrop()
   MenuOption( "Modal Window", { || ModalWindow() } )
   MenuOption( "Calendar", { || hb_ThreadStart( { || TwoCalendar() } ) } )
   IF AppMultiWindow()
      MenuOption( "Progressbar with time", { || hb_ThreadStart( { || Progressbar() } ) } )
      MenuOption( "Calculator", { || hb_ThreadStart( { || Calculator() } ) } )
   ELSE
      MenuOption( "Progressbar with time", { || Progressbar() } )
      MenuOption( "Calculator", { || Calculator() } )
   ENDIF
   MenuOption( "Generate PDF", { || pdf() } )
   MenuOption( "dBase like", { || hb_ThreadStart( { || rdbase() } ) } )
   MenuUnDrop()
MenuOption( "Database" )
   MenuDrop()
   IF AppMultiWindow()
      MenuOption( "Frm Console Style No Thread", { || frm1( .F., .F. ) } )
      MenuOption( "Frm WVG Style No Thread", { || frm1( .T., .F. ) } )
      MenuOption( "Frm Console Thread", { || hb_ThreadStart( { || frm1( .F., .T. ) } ) } )
      MenuOption( "Frm WVG Style Thread", { || hb_ThreadStart( { || frm1( .T., .T. ) } ) } )
   ELSE
      MenuOption( "Frm Console Style", { || frm1( .F., .F. ) } )
   ENDIF
   MenuUnDrop()
MenuOption( "BrazilOnly" )
   MenuDrop()
   MenuOption( "Consulta Sped", { || hb_ThreadStart( { || ConsultaSped() } ) } )
   MenuUnDrop()
MenuOption( "Menu" )
   MenuDrop()
   MenuOption( "Use WVG Menu", { || hb_ThreadStart( { || MainMenu( .T. ) } ) } )
   MenuOption( "About", { || About() } )
   MenuUnDrop()
RETURN oMenuOptions
*----------------------------------------------------------------


STATIC FUNCTION MenuOption( cCaption, oModule )
   LOCAL nCont, oLastMenu
   MEMVAR nMenuLevel, oMenuOptions

   oLastMenu := oMenuOptions
   FOR nCont = 1 TO nMenuLevel
      oLastMenu := oLastMenu[ Len( oLastMenu ) ]
      IF ValType( oLastMenu[ 2 ] ) # "A"
         oLastMenu[ 2 ] := {}
      ENDIF
      oLastMenu := oLastMenu[ 2 ]
   NEXT
   AAdd( oLastMenu, { cCaption, {}, oModule } )
   RETURN NIL
*----------------------------------------------------------------


STATIC FUNCTION MenuDrop()
   MEMVAR nMenuLevel
   nMenuLevel++
   RETURN NIL
*----------------------------------------------------------------


STATIC FUNCTION MenuUnDrop()
   MEMVAR nMenuLevel
   nMenuLevel--
   RETURN NIL
*----------------------------------------------------------------


FUNCTION MainMenu( lWindows )
   LOCAL mOpc    := 1
   LOCAL mTecla
   LOCAL mCont, mLenTot, mDife, mEspEntre, mEspFora, mColIni, aMouseMenu, mMenuOpt

   mMenuOpt := MenuCria()
   HB_GtReload( hb_GTInfo( HB_GTI_VERSION ) )
   HB_GtInfo( HB_GTI_ICONRES, "AppIcon" )
   HB_GtInfo( HB_GTI_WINTITLE, "Samples" )
   HarbourInit()
   SetMode( 30, 100 )
   CLS
   IF lWindows
#ifdef GTWVG
      MenuWvg( mMenuOpt )
      RETURN NIL
#endif
   ENDIF
   // Center options
   mLenTot := 0
   FOR mCont = 1 TO Len( mMenuOpt )
      mLenTot += Len( mMenuOpt[ mCont, 1 ] )
   NEXT
   mDife     := Max( MaxCol() + 1 - mLenTot, 0 )
   IF mDife < (Len( mMenuOpt ) + 1 )
      IF mDife >= ( Len( mMenuOpt ) - 1 )
         mEspEntre := 1
      ELSE
         mEspEntre := 0
      ENDIF
      mEspFora  := 0
   ELSE
      mEspEntre := int( mDife / ( Len( mMenuOpt ) + 1 ) )
      mEspFora  := int( ( mDife - ( mEspEntre * ( Len( mMenuOpt ) + 1 ) ) ) / 2 ) + mEspEntre
   ENDIF
   mColIni   := { mEspFora }
   FOR mCont = 2 TO Len( mMenuOpt )
      AAdd( mColIni, mColIni[ mCont - 1 ] + Len( mMenuOpt[ mCont - 1, 1 ] ) + mEspEntre )
   NEXT

   *---------- Faz o menu ----------*

   aMouseMenu := {}
   FOR mCont = 1 TO Len( mMenuOpt )
      AAdd( aMouseMenu, { 1, mColIni[ mCont ], mColIni[ mCont ] - 1 + Len( mMenuOpt[ mCont, 1 ] ), 48 + mCont + Iif( mCont > 10, 1, 0 ), 0 } )
   NEXT
   Mensagem( "Selecione e tecle <ENTER>, <ESC> Sai" )
   DO WHILE .T.
      SetColor( SetColorNormal() )
      Scroll( 1, 0, 1, MaxCol(), 0 )
      FOR mCont = 1 TO Len( mMenuOpt )
         @ 1, mColIni[ mCont ] SAY mMenuOpt[ mCont, 1 ] COLOR iif( mCont == mOpc, SetColorFocus(), SetColorNormal() )
      NEXT
      BoxMenu( 3, mColIni[ mOpc ] - 20 + Int( Len( mMenuOpt[ mOpc, 1 ] ) / 2 ), mMenuOpt[ mOpc, 2 ], 1,, .T., .T., aMouseMenu, 1 )
      mTecla := Inkey(0)
      DO CASE
      CASE mTecla == K_ESC // ESC
         EXIT
      CASE mTecla == 4 // seta direita
         mOpc := iif( mOpc == Len( mMenuOpt ), 1, mOpc + 1 )
      CASE mTecla == 19 // seta esquerda
         mOpc := iif( mOpc == 1, Len( mMenuOpt ), mOpc - 1 )
      CASE mTecla > 48 .AND. mTecla < 49 + Len( mMenuOpt ) + iif( Len( mMenuOpt ) > 10, 1, 0 )
         mOpc   := Abs( mTecla ) - 48
         mOpc   := Iif( mOpc > 10, mOpc - 1, mOpc )
      ENDCASE
   ENDDO
   Mensagem()
   RETURN NIL
*----------------------------------------------------------------


STATIC FUNCTION BoxMenu( mLini, mColi, mMenuOpt, mOpc, mTitulo, mSaiSetas, mSaiFunc, aMouseConv, nLevel )
   LOCAL mLinf, mColf, mCont, mTecla, aMouseLen, lExit, xLin, xCol, cTexto // , nCont, oDbfs
   LOCAL nMRow, nMCol, cCorAnt
   MEMVAR m_Prog, cDummy
   PRIVATE cDummy

#ifdef GTWVG
   wvt_DrawImage( 3, 0, MaxRow() - 2, MaxCol(), "jpa.ico" )
   @ 20, 10 SAY " background is a small picture, to reduce sample size "
#ENDIF
   @ 22, 10 SAY " if gt do not accept multiwindow, change AppMultiWindow() in zfunctions.prg"
   cCorAnt := SetColor()
   mSaiSetas := iif( mSaiSetas == NIL, .F., mSaiSetas )
   mSaiFunc  := iif( mSaiFunc == NIL, .F., mSaiFunc )
   mTitulo   := iif( mTitulo == NIL, "", mTitulo )
   mOpc      := iif( mOpc == NIL, 1, mOpc )
   mLinf     := mLini + Len( mMenuOpt ) + iif( Empty( mTitulo ), 1, 2 )
   IF mLinf > MaxRow() - 4
      mLini := mLini + MaxRow() - 4 - mLinf
      mLinf := mLini + Len( mMenuOpt ) + iif( Empty( mTitulo ), 1, 2 )
   ENDIF
   mColi    := iif( mColi < 0, 0, mColi )
   mColf    := mColi + 37
   IF mColf > MaxCol() - 2
      mColi := mColi - 10 // Se nao conseguiu +5, tenta -5
      mColf := mColf - 10
      IF mColf > MaxCol() - 2
         mColi := mColi + MaxCol() - 2 - mColf
         mColf := mColi + 37
      ENDIF
   ENDIF
   wOpen( mLini, mColi, mLinf, mColf, mTitulo )
   aMouseLen := Len( aMouseConv )
   ASize( aMouseConv, Len( aMouseConv ) + Len( mMenuOpt ) )
   FOR mCont = 1 TO Len( mMenuOpt )
      AIns( aMouseConv, 1 )
      xLin := mLini + iif( Empty( mTitulo ), 0, 1 ) + mCont
      xCol := mColi + 1
      aMouseConv[1] := { xLin, xCol, xCol + 33, 64 + mCont, nLevel }
   NEXT
   DO WHILE .T.
      FOR mCont = 1 TO Len( mMenuOpt )
         IF mMenuOpt[ mCont, 1 ] == "-" // separator
            @ mLini + iif( Empty( mTitulo ), 0, 1 ) + mCont, mColi + 1 TO mLini + iif( Empty( mTitulo ), 0, 1 ) + mCont, mColi + 36 COLOR iif( mCont == mOpc, SetColorFocus(), SetColorBox() )
         ELSE
            cTexto := " " + Chr( 64 + mCont ) + ":" + mMenuOpt[ mCont, 1 ]
            cTexto := Pad( cTexto, 34 ) + iif( Len( mMenuOpt[ mCont, 2 ] ) > 0, Chr(16), " " ) + " "
            @ mLini + iif( Empty( mTitulo ), 0, 1 ) + mCont, mColi + 1 SAY cTexto COLOR iif( mCont == mOpc, SetColorFocus(), SetColorBox() )
         ENDIF
      NEXT
      SetColor( SetColorNormal() )
      mTecla := Inkey(1800)
      lExit := .F.
      DO CASE
      CASE mTecla == K_ESC .OR. mTecla == K_RBUTTONDOWN .OR. mTecla == 0
         IF mTecla == 0
            CLS
            QUIT
         ENDIF
         IF nLevel == 1
            KEYBOARD Chr( K_ESC )
         ENDIF
         EXIT

      CASE mTecla == K_LBUTTONDOWN // Click Esquerda
         nMRow := MROW()
         nMCol := MCOL()
         FOR mCont = 1 TO Len( aMouseConv )
            IF nMRow == aMouseConv[ mCont, 1 ] .AND. nMCol >= aMouseConv[ mCont, 2 ] .AND. nMCol <= aMouseConv[ mCont, 3 ]
               IF aMouseConv[ mCont, 5 ] == nLevel // Nivel Atual
                  KEYBOARD Chr( aMouseConv[ mCont, 4 ] )
               ELSEIF aMouseConv[ mCont, 5 ] == 0 // Principal
                  KEYBOARD Chr( aMouseConv[ mCont, 4 ] )
                  lExit := .T.
               ELSE
                  KEYBOARD Replicate( Chr( K_ESC ), nLevel - aMouseConv[ mCont, 5 ] - 1 ) + Chr( aMouseConv[ mCont, 4 ] )
                  lExit := .T.
               ENDIF
               EXIT
            ENDIF
         NEXT
         IF lExit
            EXIT
         ENDIF
      CASE mTecla > 64 .AND. mTecla < 65 + Len( mMenuOpt ) // Letra menu atual
         mOpc := mTecla - 64
         KEYBOARD Chr( K_ENTER )
      CASE mSaiSetas .AND. ( mTecla == 4 .OR. mTecla == 19 ) // setas
         IF nLevel == 1
            KEYBOARD Chr( mTecla )
         ENDIF
         EXIT
      CASE mTecla == K_DOWN
         mOpc := iif( mOpc == Len( mMenuOpt ), 1, mOpc + 1 )
      CASE mTecla == K_UP
         mOpc := iif( mOpc == 1, Len( mMenuOpt ), mOpc - 1 )
      CASE mTecla == K_HOME
         mOpc := 1
      CASE mTecla == K_END
         mOpc := Len( mMenuOpt )
      CASE mTecla == K_ENTER
         IF Len( mMenuOpt[ mOpc, 2 ] ) > 0
            BoxMenu( mLini + iif( Empty( mTitulo ), 0, 1 ) + mOpc, mColi + 5, mMenuOpt[ mOpc, 2 ], 1, mMenuOpt[ mOpc, 1 ], .T., .T., aMouseConv, nLevel + 1 )
         ELSEIF ValType( mMenuOpt[ mOpc, 3 ] ) == "B"
            wSave()
            Mensagem()
            Eval( mMenuOpt[ mOpc, 3 ] )
            WRestore()
         ENDIF

      CASE SetKey( mTecla ) != NIL
         Eval( SetKey( mTecla ), ProcName(), ProcLine(), ReadVar() )

      OTHERWISE // Vamos ver se e' atalho
         mTecla := Asc( Upper( Chr( mTecla ) ) )
         FOR mCont = 1 TO Len( aMouseConv )
            IF mTecla == aMouseConv[ mCont, 4 ]
               IF aMouseConv[ mCont, 5 ] == nLevel // Nivel Atual
                  KEYBOARD Chr( aMouseConv[ mCont, 4 ] )
               ELSEIF aMouseConv[ mCont, 5 ] == 0 // Principal
                  KEYBOARD Chr( aMouseConv[ mCont, 4 ] )
                  lExit := .T.
               ELSE
                  KEYBOARD Replicate( Chr(27), nLevel - aMouseConv[ mCont, 5 ] - 1 ) + Chr( aMouseConv[ mCont, 4 ] )
                  lExit := .T.
               ENDIF
               EXIT
            ENDIF
         NEXT
      ENDCASE
      CLOSE DATABASES
      IF lExit
         EXIT
      ENDIF
   ENDDO
   FOR mCont = 1 TO Len( mMenuOpt )
      ADel( aMouseConv, 1 )
   NEXT
   ASize( aMouseConv, aMouseLen )
   wClose()
   SetColor( cCorAnt )
   RETURN NIL
*----------------------------------------------------------------

#ifdef GTWVG
STATIC FUNCTION MenuWvg( mMenuOpt )
   LOCAL oMenu, nKey
   oMenu  := wvgSetAppWindow():MenuBar()
   BuildMenu( oMenu, mMenuOpt )
   DO WHILE .T.
      nKey := Inkey( 0 )
      DO CASE
      CASE nKey == HB_K_GOTFOCUS
      CASE nKey == HB_K_LOSTFOCUS
      CASE nKey == K_ESC .OR. nKey == HB_K_CLOSE
         EXIT
      ENDCASE
   ENDDO
   // Note: destroy ok, but can't add new one
   wvgSetAppWindow():oMenu := {}
   wapi_SetMenu( wapi_GetActiveWindow(), NIL )
   wapi_DestroyMenu( oMenu:hWnd )
   RETURN NIL

FUNCTION BuildMenu( oMenu, acMenu )
   LOCAL nCont, oSubMenu
   MEMVAR m_Prog

   FOR nCont = 1 TO Len( acMenu )
      IF Len( acMenu[ nCont, 2 ] ) == 0
         m_Prog := acMenu[ nCont, 3 ]
         oMenu:AddItem( acMenu[ nCont, 1 ], acMenu[ nCont, 3 ] )
      ELSE
         oSubMenu := WvgMenu():new( oMenu, , .T. ):Create()
         BuildMenu( oSubMenu, acMenu[ nCont, 2 ] )
         oMenu:AddItem( oSubMenu, acMenu[ nCont, 1 ] )
      ENDIF
   NEXT
   RETURN NIL
#endif
