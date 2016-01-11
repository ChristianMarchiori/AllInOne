#include "hbgtinfo.ch"
#include "inkey.ch"

FUNCTION ConsultaSped()

   LOCAL GetList := {}, cChave := Space(44), cCertificado := Space(80), oSefaz

   IF AppMultiWindow()
      hb_gtReload( hb_gtInfo( HB_GTI_VERSION ) )
      SetMode( 20, 100 )
      CLS
      hb_gtInfo( HB_GTI_ICONRES, "AppIcon" )
      hb_gtInfo( HB_GTI_WINTITLE, "Consulta Sefaz" )
      HarbourInit()
   ENDIF

   DO WHILE .T.
      @ 4, 0 SAY "Chave:" GET cChave PICTURE "@9"
      @ 6, 0 SAY "Nome do certificado:"
      @ 7, 0 GET cCertificado
      READ

      IF Lastkey() == K_ESC
         EXIT
      ENDIF

      oSefaz := SefazClass():New()
      DO CASE
      CASE Substr( cChave, 21, 2 ) == "55" ; MsgExclamation( oSefaz:NfeConsulta( cChave, Trim( cCertificado ) ) )
      CASE Substr( cChave, 21, 2 ) == "57" ; MsgExclamation( oSefaz:CteConsulta( cChave, Trim( cCertificado ) ) )
      CASE Substr( cChave, 21, 2 ) == "58" ; MsgExclamation( oSefaz:MdfeConsulta( cChave, Trim( cCertificado ) ) )
      OTHERWISE
         MsgExclamation( "Documento nao identificado" )
      ENDCASE
   ENDDO
   RETURN NIL