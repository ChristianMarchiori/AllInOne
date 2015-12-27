#include "hbgtinfo.ch"

FUNCTION About()
   LOCAL cText := ""
   HarbourInit()
   cText += Version() + HB_EOL()
   cText += HB_Compiler() + HB_EOL()
   cText += hb_gtInfo( HB_GTI_VERSION ) + HB_EOL()
   cText += "Available Memory:" + Ltrim( Transform( Memory(0) / 1000, "999,999" ) ) + "MB" + HB_EOL()
   cText += "(Max 4GB for Harbour 32 bits)" + HB_EOL()
   MsgExclamation( cText )
   RETURN NIL
