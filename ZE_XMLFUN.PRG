*****************************************************************
* ZE_XMLFUN - FUNCOES XML                                       *
* 2012.02.11                                                    *
*****************************************************************

* 12.03.12 - Titulo no fonte
* 16.04.12 - Retirada mudanca de XML
* 03.05.12 - Ia retirar UTF8, mas melhor deixar como diferenca aceita
* 27.06.12 - Ajuste em XmlNode ref tag com elementos
* 27.06.12 - Reescrita XmlNode() permite com/sem
* 22.08.12 - Tipo de XML movido pra ZE_SEFAZ por ser especifico
* 15.10.12 - Correcao em XmlElement
* 17.12.12 - Letras acentuadas
* 07.01.13 - Retira declaracao padrao de xml
* 07.02.13 - Outra diferenca no emissor oficial afff
* 2013.06.13.1130 - Uso de conversao Utf8
* 2013.06.26.1217 - Compatibilidade com novos XMLs
* 2015.12.20.0100 - FOR EACH
*----------------------------------------------------------------

FUNCTION XmlTransform( cXml )
   LOCAL cRemoveTag, cTag, nCont

   cRemoveTag := { ;
      [<?xml version="1.0" encoding="utf-8"?>], ; // Petrobras inventou de usar assim
      [<?xml version="1.0" encoding="UTF-8"?>] }  // Alguns usam assim

   FOR EACH cTag in cRemoveTag
      cXml := StrTran( cXml, cTag, "" )
   NEXT
   IF .NOT. ["] $ cXml // Petrobras usa aspas simples
      cXml := StrTran( cXml, ['], ["] )
   ENDIF
   FOR nCont = 1 TO 2
      cXml := StrTran( cXml, Chr(26), "" )
      cXml := StrTran( cXml, Chr(13), "" )
      cXml := StrTran( cXml, Chr(10), "" )
      IF Substr( cXml, 1, 1 ) == Chr(239)
         cXml := Substr( cXml, 2 )
      ENDIF
      IF Substr( cXml, 1, 1 ) == Chr(187)
         cXml := Substr( cXml, 2 )
      ENDIF
      IF Substr(cXml, 1, 1 ) == Chr(191)
         cXml := Substr( cXml, 2 )
      ENDIF
      cXml := StrTran( cXml, Chr(195) + Chr(173), "i" ) // i acentuado minusculo
      cXml := StrTran( cXml, Chr(195) + Chr(135), "C" ) // c cedilha maiusculo
      cXml := StrTran( cXml, Chr(195) + Chr(141), "I" ) // i acentuado maiusculo
      cXml := StrTran( cXml, Chr(195) + Chr(163), "a" ) // a acentuado minusculo
      cXml := StrTran( cXml, Chr(195) + Chr(167), "c" ) // c acentuado minusculo
      cXml := StrTran( cXml, Chr(195) + Chr(161), "a" ) // a acentuado minusculo
      cXml := StrTran( cXml, Chr(195) + Chr(131), "A" ) // a acentuado maiusculo
      cXml := StrTran( cXml, Chr(194) + Chr(186), "o." ) // numero simbolo
      cXml := StrTran( cXml, " />", "/>" ) // Diferenca entre versoes do emissor
      // so pra corrigir no MySql
      cXml := StrTran( cXml, "+" + Chr(129), "A" )
      cXml := StrTran( cXml, "+" + Chr(137), "E" )
      cXml := StrTran( cXml, "+" + Chr(131), "A" )
      cXml := StrTran( cXml, "+" + Chr(135), "C" )
      cXml := StrTran( cXml, "?" + Chr(167), "c" )
      cXml := StrTran( cXml, "?" + Chr(163), "a" )
      cXml := StrTran( cXml, "?" + Chr(173), "i" )
      cXml := StrTran( cXml, "?" + Chr(131), "A" )
      cXml := StrTran( cXml, "?" + Chr(161), "a" )
      cXml := StrTran( cXml, "?" + Chr(141), "I" )
      cXml := StrTran( cXml, "?" + Chr(135), "C" )
      cXml := StrTran( cXml, Chr(195) + Chr(156), "a" )
      cXml := StrTran( cXml, Chr(195) + Chr(159), "A" )
      cXml := StrTran( cXml, "?" + Chr(129), "A" )
      cXml := StrTran( cXml, "?" + Chr(137), "E" )
      cXml := StrTran( cXml, Chr(195) + "?", "C" )
      cXml := StrTran( cXml, "?" + Chr(149), "O" )
      cXml := StrTran( cXml, "?" + Chr(154), "U" )
      cXml := StrTran( cXml, "+" + Chr(170), "o" )
      cXml := StrTran( cXml, "?" + Chr(128), "A" )
      cXml := StrTran( cXml, Chr(195) + Chr(166), "e" )
      cXml := StrTran( cXml, Chr(135) + Chr(227), "ca" )
      cXml := StrTran( cXml, "n" + Chr(227), "na" )
      cXml := StrTran( cXml, Chr(162), "o" )
      cXml := hb_Utf8ToStr( cXml )
   NEXT
   RETURN cXml

FUNCTION XmlNode( cXml, cNode, lComTag )
   LOCAL mInicio, mFim, cResultado := ""
   lComTag := iif( lComTag == NIL,.F., lComTag )
   IF " " $ cNode
      cNode := Substr( cNode, 1, At( " ", cNode ) - 1 )
   ENDIF
   mInicio := At( "<" + cNode, cXml )
   IF mInicio != 0
      IF .NOT. lComTag
         mInicio := mInicio + Len( cNode ) + 2
         IF mInicio != 1 .AND. Substr( cXml, mInicio - 1, 1 ) != ">" // Quando tem elementos no bloco
            mInicio := AtStart( ">", cXml, mInicio ) + 1
         ENDIF
      ENDIF
   ENDIF
   IF mInicio != 0
      mFim = AtStart( "</" + cNode + ">", cXml, mInicio )
      IF mFim != 0
         mFim -=1
         IF lComTag
            mFim := mFim + Len( cNode ) + 3
         ENDIF
      ENDIF
      IF mFim <> 0
         cResultado := Substr( cXml, mInicio, mFim - mInicio + 1 )
      ENDIF
   ENDIF
   RETURN cResultado

FUNCTION XmlElement( cXml, cElement )
   LOCAL mInicio, mFim, cResultado := ""
   mInicio := At( cElement + "=", cXml )
   IF mInicio != 0
      mInicio += 1
      mInicio := AtStart( "=", cXml, mInicio ) + 2
   ENDIF
   mFim    := AtStart( ["], cXml, mInicio ) - 1
   IF mInicio >0 .AND. mFim > 0 .AND. mFim > mInicio
      cResultado = Substr( cXml, mInicio, mFim - mInicio + 1 )
   ENDIF
   RETURN cResultado

FUNCTION XmlDate( cData )
   LOCAL dDate
   dDate := Ctod( Substr( cData, 9, 2 ) + "/" + Substr( cData, 6, 2 ) + "/" + Substr( cData, 1, 4 ) )
   RETURN dDate

FUNCTION XmlTag( cTag, cConteudo )
   LOCAL cTexto := ""
   cConteudo := Iif( cConteudo == NIL, "", cConteudo )
   cConteudo := AllTrim( cConteudo )
   IF Len( Trim( cConteudo ) ) = 0
      cTexto := [<]+ cTag + [/>]
   ELSE
      cConteudo := AllTrim( cConteudo )
      IF Len( cConteudo ) == 0
         cConteudo := " "
      ENDIF
      cTexto := cTexto + [<] + cTag + [>] + cConteudo + [</] + cTag + [>]
   ENDIF
   RETURN cTexto
*----------------------------------------------------------------


FUNCTION AtStart( cSearch, cString, nStart, nEnd )
   LOCAL nPosicao
   nStart := iif( nStart == NIL, 1, nStart )
   nEnd := iif( nEnd == NIL, Len( cString ), nEnd )
   nPosicao := At( cSearch, Substr( cString, nStart, nEnd ) )
   IF nPosicao != 0
      nPosicao := nPosicao + nStart -1
   ENDIF
   RETURN nPosicao
*----------------------------------------------------------------

FUNCTION StringToChr( cTexto )
   LOCAL cLetra, cTexto2 := ""

   FOR EACH cLetra IN cTexto
      DO CASE
      CASE cLetra $ "0123456789"
      CASE cLetra $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      CASE cLetra $ "abcdefghijklmnopqrstuvwxyz"
      CASE cLetra $ "()<>+-,.:;=$& "
      CASE cLetra $ "/?@!#%*[]\_"
      CASE cLetra $ ['"]
      OTHERWISE
         cLetra := [CHR(] + StrZero( Asc( cLetra ), 3 ) + [)]
      ENDCASE
      cTexto2 += cLetra
   NEXT
   RETURN cTexto2

FUNCTION ChrToString( cTexto )
   LOCAL nCont, cLetra

   FOR nCont = 0 TO 255
      cLetra := [CHR(] + StrZero( nCont, 3 ) + [)]
      cTexto := StrTran( cTexto, cLetra, Chr( nCont ) )
   NEXT
   RETURN cTexto
