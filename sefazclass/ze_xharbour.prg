// compatibilidade xHarbour
// inclusa aqui w32ole.prg da hbnfe

#ifdef __XHARBOUR__
FUNCTION win_OleCreateObject( cObject )
   RETURN xhb_CreateObject( cObject )

FUNCTION hb_MemoWrit( cFile, cText )
   RETURN Memowrit( cFile, cText, .T. )

FUNCTION hb_At( cText, nStart, nEnd )
   RETURN At( cText, nStart, nEnd )

FUNCTION hb_Eol()
   RETURN Chr(13) + Chr(10)

FUNCTION wapi_MessageBox( nHwnd, cText, cTitle )
   RETURN Alert( cText )

* w32ole.prg baseada na win32ole.prg v 1.82 2005/04/29 do xharbour

STATIC bOleInitialized:=.F.

#ifndef __PLATFORM__Windows

#include "common.ch"

  Function xhb_CreateObject()
  Return NIL

  FUNCTION xhb_GetActiveObject( cString )
    HB_SYMBOL_UNUSED( cString )
  Return NIL

#else

#include "hbclass.ch"
#include "error.ch"
#include "vt.ch"
#include "oleerr.ch"

//----------------------------------------------------------------------------//
FUNCTION xhb_CreateObject( cString, cLicense )
//----------------------------------------------------------------------------//

RETURN TOleAutoX():New( cString, , cLicense )

//----------------------------------------------------------------------------//
FUNCTION xhb_GetActiveObject( cString )
//----------------------------------------------------------------------------//

RETURN TOleAutoX():GetActiveObject( cString )

//----------------------------------------------------------------------------//
CLASS TOleAutoX

   DATA hObj
   DATA cClassName

   METHOD New( uObj, cClass ) CONSTRUCTOR
   METHOD GetActiveObject( cClass ) CONSTRUCTOR

   METHOD Invoke()
   MESSAGE Set METHOD Invoke()
   MESSAGE Get METHOD Invoke()

   METHOD Collection( xIndex, xValue ) OPERATOR "[]"

   // Needed to refernce, or hb_dynsymFindName() will fail
   METHOD ForceSymbols() INLINE ::cClassName()

   ERROR HANDLER OnError()

   DESTRUCTOR Release()

ENDCLASS

//--------------------------------------------------------------------

METHOD New( uObj, cClass ) CLASS TOleAutoX

   LOCAL oErr

   // Hack incase OLE Server already created and New() is attempted as an OLE Method.

   IF ::hObj != NIL
      RETURN HB_ExecFromArray( Self, "_New", HB_aParams() )
   ENDIF

   IF ValType( uObj ) = 'C'

      ::hObj := CreateOleObject( uObj )

      IF WOleError() != 0

         IF WOle2TxtError() == "DISP_E_EXCEPTION"

            oErr := ErrorNew()

            oErr:Args          := HB_aParams()
            oErr:CanDefault    := .F.
            oErr:CanRetry      := .F.
            oErr:CanSubstitute := .T.
            oErr:Description   := OLEExceptionDescription()
            oErr:GenCode       := EG_OLEEXECPTION

            oErr:Operation     := ProcName()
            oErr:Severity      := ES_ERROR

            oErr:SubCode       := -1
            oErr:SubSystem     := OLEExceptionSource()

            RETURN Eval( ErrorBlock(), oErr )
         ELSE
            oErr := ErrorNew()
            oErr:Args          := HB_aParams()
            oErr:CanDefault    := .F.
            oErr:CanRetry      := .F.
            oErr:CanSubstitute := .T.
            oErr:Description   := WOle2TxtError()
            oErr:GenCode       := EG_OLEEXECPTION
            oErr:Operation     := ProcName()
            oErr:Severity      := ES_ERROR
            oErr:SubCode       := -1
            oErr:SubSystem     := "TOleAutoX"

            RETURN Eval( ErrorBlock(), oErr )
         ENDIF
      ENDIF

      ::cClassName := uObj
   ELSEIF ValType( uObj ) = 'N'
      ::hObj := uObj

      IF ValType( cClass ) == 'C'
         ::cClassName := cClass
      ELSE
         ::cClassName := LTrim( Str( uObj ) )
      ENDIF
   ELSE
      MessageBox( 0, "Invalid parameter type to constructor TOleAutoX():New()!", "OLE Interface", 0 )
      ::hObj := 0
   ENDIF

RETURN Self

//--------------------------------------------------------------------

// Destructor!
PROCEDURE Release() CLASS TOleAutoX

   IF ! Empty( ::hObj )
       OleReleaseObject( ::hObj )
   ENDIF

RETURN

//--------------------------------------------------------------------
METHOD GetActiveObject( cClass ) CLASS TOleAutoX
//--------------------------------------------------------------------

   LOCAL oErr

   IF ValType( cClass ) = 'C'

      ::hObj := GetOleObject( cClass )

      IF WOleError() != 0

         IF WOle2TxtError() == "DISP_E_EXCEPTION"
            oErr := ErrorNew()
            oErr:Args          := { cClass }
            oErr:CanDefault    := .F.
            oErr:CanRetry      := .F.
            oErr:CanSubstitute := .T.
            oErr:Description   := OLEExceptionDescription()
            oErr:GenCode       := EG_OLEEXECPTION
            oErr:Operation     := ProcName()
            oErr:Severity      := ES_ERROR
            oErr:SubCode       := -1
            oErr:SubSystem     := OLEExceptionSource()

            RETURN Eval( ErrorBlock(), oErr )
         ELSE
            oErr := ErrorNew()
            oErr:Args          := { cClass }
            oErr:CanDefault    := .F.
            oErr:CanRetry      := .F.
            oErr:CanSubstitute := .T.
            oErr:Description   := WOle2TxtError()
            oErr:GenCode       := EG_OLEEXECPTION
            oErr:Operation     := ProcName()
            oErr:Severity      := ES_ERROR
            oErr:SubCode       := -1
            oErr:SubSystem     := "TOleAutoX"

            RETURN Eval( ErrorBlock(), oErr )
         ENDIF
      ENDIF

      ::cClassName := cClass
   ELSE
      MessageBox( 0, "Invalid parameter type to constructor TOleAutoX():GetActiveObject()!", "OLE Interface", 0 )
      ::hObj := 0
   ENDIF

RETURN Self

//--------------------------------------------------------------------
METHOD Invoke( ... ) CLASS TOleAutoX
//--------------------------------------------------------------------
   LOCAL cMethod := HB_aParams()[1]

RETURN HB_ExecFromArray( Self, cMethod, aDel( HB_aParams(), 1, .T. ) )

//--------------------------------------------------------------------
METHOD Collection( xIndex, xValue ) CLASS TOleAutoX
//--------------------------------------------------------------------
   LOCAL xRet

   IF PCount() == 1
      RETURN ::Item( xIndex )
   ENDIF

   TRY
      // ASP Collection syntax.
      xRet := ::_Item( xIndex, xValue )
   CATCH
      xRet := ::SetItem( xIndex, xValue )
   END

RETURN xRet

#pragma BEGINDUMP

   #ifndef CINTERFACE
      #define CINTERFACE 1
   #endif

   #define NONAMELESSUNION

   #include "hbapiitm.h"
   #include "hbapierr.h"
   #include "hbvm.h"
   #include "hbdate.h"
   #include "hbfast.h"
#include "hbapi.h"
#include "hbstack.h"

#include <ctype.h>
   #include <windows.h>
   #include <ole2.h>
   #include <oleauto.h>

   #ifdef __MINGW32__
      // Missing in oleauto.h
      WINOLEAUTAPI VarR8FromDec(DECIMAL *pdecIn, DOUBLE *pdblOut);
   #endif

   #if ( defined(__DMC__) || defined(__MINGW32__) || ( defined(__WATCOMC__) && !defined(__FORCE_LONG_LONG__) ) )
      #define HB_LONG_LONG_OFF
   #endif

   static HRESULT  s_nOleError;
   static HB_ITEM  OleAuto;

   static PHB_DYNS s_pSym_OleAuto;
   static PHB_DYNS s_pSym_hObj;
   static PHB_DYNS s_pSym_New;
   static PHB_DYNS s_pSym_cClassName;

   static BOOL *s_OleRefFlags = NULL;

   static VARIANTARG RetVal;

  static EXCEPINFO excep;

  static PHB_ITEM *aPrgParams = NULL;

  static BSTR bstrMessage;
  static DISPID lPropPut = DISPID_PROPERTYPUT;
  static UINT uArgErr;


   HB_FUNC_STATIC( OLE_INITIALIZE )
   {
      s_nOleError = OleInitialize( NULL );

      s_pSym_OleAuto = hb_dynsymFindName( "TOLEAUTOX" );
      s_pSym_New  = hb_dynsymFindName( "NEW" );
      s_pSym_hObj        = hb_dynsymFindName( "HOBJ" );
      s_pSym_cClassName  = hb_dynsymFindName( "CCLASSNAME" );

   }

   HB_FUNC_STATIC( OLE_UNINITIALIZE )
   {
      OleUninitialize();
   }
  //---------------------------------------------------------------------------//

  static double DateToDbl( LPSTR cDate )
  {
     double nDate;

     nDate = hb_dateEncStr( cDate ) - 0x0024d9abL;

     return ( nDate );
  }

  //---------------------------------------------------------------------------//

  static LPSTR DblToDate( double nDate )
  {
     static char cDate[9] = "00000000";

     hb_dateDecStr( cDate, (LONG) nDate + 0x0024d9abL );

     return ( cDate );
  }

  //---------------------------------------------------------------------------//


  static BSTR AnsiToSysString( LPSTR cString )
  {
     BSTR bstrString;
     int nConvertedLen = MultiByteToWideChar( CP_ACP, MB_PRECOMPOSED, cString, -1, NULL, 0 ) -1;

     bstrString = SysAllocStringLen( NULL, nConvertedLen );

     if( bstrString )
     {
        bstrString[0] = '\0';
        MultiByteToWideChar( CP_ACP, 0, cString, -1,  bstrString, nConvertedLen );
     }

     return bstrString;
  }

  //---------------------------------------------------------------------------//

  static LPSTR WideToAnsi( BSTR wString )
  {
     char *cString;
     int nConvertedLen = WideCharToMultiByte( CP_ACP, 0, wString, -1, NULL, 0, NULL, NULL );

     if( nConvertedLen )
     {
        cString = (char *) hb_xgrab( nConvertedLen );
        WideCharToMultiByte( CP_ACP, 0, wString, -1, cString, nConvertedLen, NULL, NULL );
     }
     else
     {
        cString = (char *) hb_xgrab( 1 );
        cString[0] = '\0';
     }

     //wprintf( L"\nWide: '%s'\n", wString );
     //printf( "\nAnsi: '%s'\n", cString );

     return cString;
  }

  //---------------------------------------------------------------------------//

  static void GetParams( DISPPARAMS *pDispParams )
  {
     VARIANTARG * pArgs = NULL;
     PHB_ITEM uParam;
     int n, nArgs, nArg;
     BOOL bByRef;

     nArgs = hb_pcount();

     if( nArgs > 0 )
     {
        pArgs = ( VARIANTARG * ) hb_xgrab( sizeof( VARIANTARG ) * nArgs );
        aPrgParams = ( PHB_ITEM * ) hb_xgrab( sizeof( PHB_ITEM ) * nArgs );

        // 1 Based!!!
        s_OleRefFlags = (BOOL *) hb_xgrab( ( nArgs + 1 ) * sizeof( BOOL ) );

        //printf( "Args: %i\n", nArgs );

        for( n = 0; n < nArgs; n++ )
        {
           // Parameters are processed in reversed order.
           nArg = nArgs - n;

           VariantInit( &( pArgs[ n ] ) );

           uParam = hb_param( nArg, HB_IT_ANY );

           bByRef = HB_IS_BYREF( hb_stackItemFromBase( nArg ) );

           // 1 Based!!!
           s_OleRefFlags[ nArg ] = bByRef;

           //TraceLog( NULL, "N: %i Arg: %i Type: %i %i ByRef: %i\n", n, nArg, hb_stackItemFromBase( nArg  )->type, uParam->type, bByRef );

           aPrgParams[ n ] = uParam;

           switch( uParam->type )
           {
              case HB_IT_NIL:
                pArgs[ n ].n1.n2.vt   = VT_EMPTY;
                break;

              case HB_IT_STRING:
              case HB_IT_MEMO:
                if( bByRef )
                {
                   hb_itemPutCRawStatic( uParam, ( char *) AnsiToSysString( hb_parcx( nArg ) ), uParam->item.asString.length * 2 + 1 );

                   pArgs[ n ].n1.n2.vt   = VT_BYREF | VT_BSTR;
                   pArgs[ n ].n1.n2.n3.pbstrVal = (BSTR *) &( uParam->item.asString.value );
                   //wprintf( L"*** BYREF >%s<\n", *pArgs[ n ].n1.n2.n3.bstrVal );
                }
                else
                {
                   pArgs[ n ].n1.n2.vt   = VT_BSTR;
                   pArgs[ n ].n1.n2.n3.bstrVal = AnsiToSysString( hb_parcx( nArg ) );
                   //wprintf( L"*** >%s<\n", pArgs[ n ].n1.n2.n3.bstrVal );
                }
                break;

              case HB_IT_LOGICAL:
                if( bByRef )
                {
                   pArgs[ n ].n1.n2.vt = VT_BYREF | VT_BOOL;
                   pArgs[ n ].n1.n2.n3.pboolVal = (short *) &( uParam->item.asLogical.value ) ;
                   uParam->type = HB_IT_LONG;
                }
                else
                {
                   pArgs[ n ].n1.n2.vt = VT_BOOL;
                   pArgs[ n ].n1.n2.n3.boolVal = hb_parl( nArg ) ? VARIANT_TRUE : VARIANT_FALSE;
                }
                break;

              case HB_IT_INTEGER:
#if HB_INT_MAX == INT16_MAX
                if( bByRef )
                {
                   pArgs[ n ].n1.n2.vt = VT_BYREF | VT_I2;
                   pArgs[ n ].n1.n2.n3.piVal = &( uParam->item.asInteger.value ) ;
                }
                else
                {
                   pArgs[ n ].n1.n2.vt = VT_I2;
                   pArgs[ n ].n1.n2.n3.iVal = hb_parni( nArg );
                }
                break;
#else
                if( bByRef )
                {
                   pArgs[ n ].n1.n2.vt = VT_BYREF | VT_I4;
                   pArgs[ n ].n1.n2.n3.plVal = (long *) &( uParam->item.asInteger.value ) ;
                }
                else
                {
                   pArgs[ n ].n1.n2.vt = VT_I4;
                   pArgs[ n ].n1.n2.n3.lVal = hb_parnl( nArg );
                }
                break;
#endif
              case HB_IT_LONG:
#if HB_LONG_MAX == INT32_MAX || defined( HB_LONG_LONG_OFF )
                if( bByRef )
                {
                   pArgs[ n ].n1.n2.vt = VT_BYREF | VT_I4;
                   pArgs[ n ].n1.n2.n3.plVal = (long *) &( uParam->item.asLong.value ) ;
                }
                else
                {
                   pArgs[ n ].n1.n2.vt = VT_I4;
                   pArgs[ n ].n1.n2.n3.lVal = hb_parnl( nArg );
                }
#else
                if( bByRef )
                {
                   pArgs[ n ].n1.n2.vt = VT_BYREF | VT_I8;
                   pArgs[ n ].n1.n2.n3.pllVal = &( uParam->item.asLong.value ) ;
                }
                else
                {
                   pArgs[ n ].n1.n2.vt = VT_I8;
                   pArgs[ n ].n1.n2.n3.llVal = hb_parnll( nArg );
                }
#endif
                break;

              case HB_IT_DOUBLE:
                if( bByRef )
                {
                   pArgs[ n ].n1.n2.vt = VT_BYREF | VT_R8;
                   pArgs[ n ].n1.n2.n3.pdblVal = &( uParam->item.asDouble.value ) ;
                   uParam->type = HB_IT_DOUBLE;
                }
                else
                {
                   pArgs[ n ].n1.n2.vt   = VT_R8;
                   pArgs[ n ].n1.n2.n3.dblVal = hb_parnd( nArg );
                }
                break;

              case HB_IT_DATE:
                if( bByRef )
                {
                   pArgs[ n ].n1.n2.vt = VT_BYREF | VT_DATE;
                   uParam->item.asDouble.value = DateToDbl( hb_pards( nArg ) );
                   pArgs[ n ].n1.n2.n3.pdblVal = &( uParam->item.asDouble.value ) ;
                   uParam->type = HB_IT_DOUBLE;
                }
                else
                {
                   pArgs[ n ].n1.n2.vt   = VT_DATE;
                   pArgs[ n ].n1.n2.n3.dblVal = DateToDbl( hb_pards( nArg ) );
                }
                break;

              case HB_IT_ARRAY:
              {
                 pArgs[ n ].n1.n2.vt = VT_EMPTY;

                 if( ! HB_IS_OBJECT( uParam ) )
                 {
                    SAFEARRAYBOUND rgsabound;
                    PHB_ITEM       elem;
                    long           count;
                    long           i;

                    count = hb_arrayLen( uParam );

                    rgsabound.cElements = count;
                    rgsabound.lLbound = 0;
                    pArgs[ n ].n1.n2.vt        = VT_ARRAY | VT_VARIANT;
                    pArgs[ n ].n1.n2.n3.parray = SafeArrayCreate( VT_VARIANT, 1, &rgsabound );

                    for( i = 0; i < count; i++ )
                    {
                       elem = hb_arrayGetItemPtr( uParam, i+1 );

                       if( strcmp( hb_objGetClsName( elem ), "TOLEAUTOX" ) == 0 )
                       {
                          VARIANT mVariant;

                          VariantInit( &mVariant );

                          hb_vmPushSymbol( s_pSym_hObj->pSymbol );
                          hb_vmPush( elem );
                          hb_vmSend( 0 );

                          mVariant.n1.n2.vt = VT_DISPATCH;
                          mVariant.n1.n2.n3.pdispVal = ( IDispatch * ) hb_parnl( -1 );
                          SafeArrayPutElement( pArgs[ n ].n1.n2.n3.parray, &i, &mVariant );
                       }
                    }
                 }
                 else
                 {
                    if( hb_clsIsParent( uParam->item.asArray.value->uiClass , "TOLEAUTOX" ) )
                    {
                       hb_vmPushSymbol( s_pSym_hObj->pSymbol );
                       hb_vmPush( uParam );
                       hb_vmSend( 0 );
                       //TraceLog( NULL, "\n#%i Dispatch: %ld\n", n, hb_parnl( -1 ) );
                       pArgs[ n ].n1.n2.vt = VT_DISPATCH;
                       pArgs[ n ].n1.n2.n3.pdispVal = ( IDispatch * ) hb_parnl( -1 );
                       //printf( "\nDispatch: %p\n", pArgs[ n ].n1.n2.n3.pdispVal );

                    }
                    else
                    {
                       TraceLog( NULL, "Class: '%s' not suported!\n", hb_objGetClsName( uParam ) );
                    }
                 }
              }
              break;
           }
        }
     }

     pDispParams->rgvarg            = pArgs;
     pDispParams->cArgs             = nArgs;
     pDispParams->rgdispidNamedArgs = 0;
     pDispParams->cNamedArgs        = 0;
  }

  //---------------------------------------------------------------------------//

  static void FreeParams( DISPPARAMS *pDispParams )
  {
     int n, nParam;
     char *sString;

     if( pDispParams->cArgs > 0 )
     {
        for( n = 0; n < ( int ) pDispParams->cArgs; n++ )
        {
           nParam = pDispParams->cArgs - n;

           //TraceLog( NULL, "*** N: %i, Param: %i Type: %i\n", n, nParam, pDispParams->rgvarg[ n ].n1.n2.vt );

           // 1 Based!!!
           if( s_OleRefFlags[ nParam ]  )
           {
              switch( pDispParams->rgvarg[ n ].n1.n2.vt )
              {
                 case VT_BYREF | VT_BSTR:
                   //printf( "String\n" );
                   sString = WideToAnsi( *( pDispParams->rgvarg[ n ].n1.n2.n3.pbstrVal ) );

                   SysFreeString( *( pDispParams->rgvarg[ n ].n1.n2.n3.pbstrVal ) );

                   hb_itemPutCPtr( aPrgParams[ n ], sString, strlen( sString ) );
                   break;

                 // Already using the PHB_ITEM allocated value
                 /*
                 case VT_BYREF | VT_BOOL:
                   //printf( "Logical\n" );
                   ( aPrgParams[ n ] )->type = HB_IT_LOGICAL;
                   ( aPrgParams[ n ] )->item.asLogical.value = pDispParams->rgvarg[ n ].n1.n2.n3.boolVal ;
                   break;
                 */

                 case VT_DISPATCH:
                 case VT_BYREF | VT_DISPATCH:
                   //TraceLog( NULL, "Dispatch %p\n", pDispParams->rgvarg[ n ].n1.n2.n3.pdispVal );
                   if( pDispParams->rgvarg[ n ].n1.n2.n3.pdispVal == NULL )
                   {
                      hb_itemClear( aPrgParams[ n ] );
                      break;
                   }

                   OleAuto.type = HB_IT_NIL;

                   if( s_pSym_OleAuto )
                   {
                      hb_vmPushSymbol( s_pSym_OleAuto->pSymbol );
                      hb_vmPushNil();
                      hb_vmDo( 0 );

                      hb_itemForwardValue( &OleAuto, hb_stackReturnItem()) ;
                   }

                   if( s_pSym_New && OleAuto.type )
                   {

                      hb_vmPushSymbol( s_pSym_New->pSymbol );
                      hb_itemPushForward( &OleAuto );
                      hb_vmPushLong( ( LONG ) pDispParams->rgvarg[ n ].n1.n2.n3.pdispVal );
                      hb_vmSend( 1 );

                      hb_itemForwardValue( aPrgParams[ n ], hb_stackReturnItem() );
                   }
                   // Can't CLEAR this Variant
                   continue;

                 /*
                 case VT_BYREF | VT_I2:
                   //printf( "Int %i\n", pDispParams->rgvarg[ n ].n1.n2.n3.iVal );
                   hb_itemPutNI( aPrgParams[ n ], ( int ) pDispParams->rgvarg[ n ].n1.n2.n3.iVal );
                   break;

                 case VT_BYREF | VT_I4:
                   //printf( "Long %ld\n", pDispParams->rgvarg[ n ].n1.n2.n3.lVal );
                   hb_itemPutNL( aPrgParams[ n ], ( LONG ) pDispParams->rgvarg[ n ].n1.n2.n3.lVal );
                   break;

#ifndef HB_LONG_LONG_OFF
                 case VT_BYREF | VT_I8:
                   //printf( "Long %Ld\n", pDispParams->rgvarg[ n ].n1.n2.n3.llVal );
                   hb_itemPutNLL( aPrgParams[ n ], ( LONGLONG ) pDispParams->rgvarg[ n ].n1.n2.n3.llVal );
                   break;
#endif

                 case VT_BYREF | VT_R8:
                   //printf( "Double\n" );
                   hb_itemPutND( aPrgParams[ n ],  pDispParams->rgvarg[ n ].n1.n2.n3.dblVal );
                   break;
                 */

                 case VT_BYREF | VT_DATE:
                   //printf( "Date\n" );
                   hb_itemPutDS( aPrgParams[ n ], DblToDate( *( pDispParams->rgvarg[ n ].n1.n2.n3.pdblVal ) ) );
                   break;

                 /*
                 case VT_BYREF | VT_EMPTY:
                   //printf( "Nil\n" );
                   hb_itemClear( aPrgParams[ n ] );
                   break;
                 */

                 default:
                   TraceLog( NULL, "*** Unexpected Type: %i***\n", pDispParams->rgvarg[ n ].n1.n2.vt );
              }
           }
           else
           {
              switch( pDispParams->rgvarg[ n ].n1.n2.vt )
              {
                 case VT_BSTR:
                   break;

                 case VT_DISPATCH:
                   //TraceLog( NULL, "***NOT REF*** Dispatch %p\n", pDispParams->rgvarg[ n ].n1.n2.n3.pdispVal );
                   // Can'r CLEAR this Variant.
                   continue;

                 //case VT_ARRAY | VT_VARIANT:
                 //  SafeArrayDestroy( pDispParams->rgvarg[ n ].n1.n2.n3.parray );
              }
           }

           VariantClear( &(pDispParams->rgvarg[ n ] ) );
        }

        hb_xfree( ( LPVOID ) pDispParams->rgvarg );

        hb_xfree( (void *) s_OleRefFlags );
        s_OleRefFlags = NULL;

        hb_xfree( ( LPVOID ) aPrgParams );
        aPrgParams = NULL;
     }
  }

  //---------------------------------------------------------------------------//

  static void RetValue( void )
  {
     LPSTR cString;

     /*
     printf( "Type: %i\n", RetVal.n1.n2.vt );
     fflush( stdout );
     getchar();
     */

     switch( RetVal.n1.n2.vt )
     {
        case VT_BSTR:
          //printf( "String\n" );
          cString = WideToAnsi( RetVal.n1.n2.n3.bstrVal );
          //printf( "cString %s\n", cString );
          hb_retcAdopt( cString );
          //printf( "Adopted\n" );
          break;

        case VT_BOOL:
          hb_retl( RetVal.n1.n2.n3.boolVal == VARIANT_TRUE ? 1 :0 );
          break;

        case VT_DISPATCH:
          if( RetVal.n1.n2.n3.pdispVal == NULL )
          {
             hb_ret();
             break;
          }

          OleAuto.type = HB_IT_NIL;

          if( s_pSym_OleAuto )
          {
             hb_vmPushSymbol( s_pSym_OleAuto->pSymbol );
             hb_vmPushNil();
             hb_vmDo( 0 );

             hb_itemForwardValue( &OleAuto, hb_stackReturnItem() ) ; //; &(HB_VM_STACK.Return) );
          }

          if( s_pSym_New && OleAuto.type )
          {
             //TOleAuto():New( nDispatch )
             hb_vmPushSymbol( s_pSym_New->pSymbol );
             hb_itemPushForward( &OleAuto );
             hb_vmPushLong( ( LONG ) RetVal.n1.n2.n3.pdispVal );
             hb_vmSend( 1 );
             //printf( "Dispatch: %ld %ld\n", ( LONG ) RetVal.n1.n2.n3.pdispVal, (LONG) hb_stack.Return.item.asArray.value );
          }
          break;

        case VT_I1:     // Byte
        case VT_UI1:
          hb_retni( ( short ) RetVal.n1.n2.n3.bVal );
          break;

        case VT_I2:     // Short (2 bytes)
        case VT_UI2:
          hb_retni( ( short ) RetVal.n1.n2.n3.iVal );
          break;

        case VT_I4:     // Long (4 bytes)
        case VT_UI4:
        case VT_INT:
        case VT_UINT:
          hb_retnl( ( LONG ) RetVal.n1.n2.n3.lVal );
          break;

#ifndef HB_LONG_LONG_OFF
        case VT_I8:     // LongLong (8 bytes)
        case VT_UI8:
          hb_retnll( ( LONGLONG ) RetVal.n1.n2.n3.llVal );
          break;
#endif

        case VT_R4:     // Single
          hb_retnd( RetVal.n1.n2.n3.fltVal );
          break;

        case VT_R8:     // Double
          hb_retnd( RetVal.n1.n2.n3.dblVal );
          break;

        case VT_CY:     // Currency
        {
          double tmp = 0;
          VarR8FromCy( RetVal.n1.n2.n3.cyVal, &tmp );
          hb_retnd( tmp );
        }
          break;

        case VT_DECIMAL: // Decimal
          {
          double tmp = 0;
          VarR8FromDec( &RetVal.n1.decVal, &tmp );
          hb_retnd( tmp );
          }
          break;

        case VT_DATE:
          hb_retds( DblToDate( RetVal.n1.n2.n3.dblVal ) );
          break;

        case VT_EMPTY:
        case VT_NULL:
          hb_ret();
          break;

        case VT_ARRAY | VT_VARIANT:
        {
           long     i, nFrom, nTo;
           VARIANT  mElem;
           HB_ITEM Result, Add;

           SafeArrayGetLBound( RetVal.n1.n2.n3.parray, 1, &nFrom );
           SafeArrayGetUBound( RetVal.n1.n2.n3.parray, 1, &nTo );

           Result.type = HB_IT_NIL;
           hb_arrayNew( &Result, 0 );

           Add.type = HB_IT_NIL;

           for ( i = nFrom; i <= nTo; i++ )
           {
              VariantInit( &mElem );
              SafeArrayGetElement( RetVal.n1.n2.n3.parray, &i, &mElem );

              if( mElem.n1.n2.vt == VT_DISPATCH && mElem.n1.n2.n3.pdispVal )
              {
                 if( s_pSym_OleAuto )
                 {
                    hb_vmPushSymbol( s_pSym_OleAuto->pSymbol );
                    hb_vmPushNil();
                    hb_vmDo( 0 );

                    hb_itemForwardValue( &Add, hb_stackReturnItem() );
                 }

                 if( s_pSym_New && Add.type )
                 {
                    hb_vmPushSymbol( s_pSym_New->pSymbol );
                    hb_vmPush( &Add );
                    hb_vmPushLong( ( LONG ) mElem.n1.n2.n3.pdispVal );
                    hb_vmSend( 1 );

                    mElem.n1.n2.n3.pdispVal->lpVtbl->AddRef( mElem.n1.n2.n3.pdispVal );
                 }

                 hb_arrayAddForward( &Result, &Add );
              }

              VariantClear( &mElem );
           }

           hb_itemReturn( &Result );
        }
        break;
/*- end ----------------------------->8-------------------------------------*/

        default:
          //printf( "Default %i!\n", RetVal.n1.n2.vt );
          if( s_nOleError == S_OK )
          {
             s_nOleError = E_UNEXPECTED;
          }

          hb_ret();
          break;
     }

     if( RetVal.n1.n2.vt == VT_DISPATCH && RetVal.n1.n2.n3.pdispVal )
     {
        //printf( "Dispatch: %ld\n", ( LONG ) RetVal.n1.n2.n3.pdispVal );
     }
     else
     {
        VariantClear( &RetVal );
     }
  }

  //---------------------------------------------------------------------------//

  HB_FUNC( WOLESHOWEXCEPTION )
  {
     if( (LONG) s_nOleError == DISP_E_EXCEPTION )
     {
        LPSTR source, description;

        source = WideToAnsi( excep.bstrSource );
        description = WideToAnsi( excep.bstrDescription );

        MessageBox( NULL, description, source, MB_ICONHAND );

        hb_xfree( source );
        hb_xfree( description );
     }
  }

  //---------------------------------------------------------------------------//

  HB_FUNC_STATIC( OLEEXCEPTIONSOURCE )
  {
     if( (LONG) s_nOleError == DISP_E_EXCEPTION )
     {
        LPSTR source;

        source = WideToAnsi( excep.bstrSource );
        hb_retcAdopt( source );
     }
  }

  //---------------------------------------------------------------------------//

  HB_FUNC_STATIC( OLEEXCEPTIONDESCRIPTION )
  {
     if( (LONG) s_nOleError == DISP_E_EXCEPTION )
     {
        LPSTR description;

        description = WideToAnsi( excep.bstrDescription );
        hb_retcAdopt( description );
     }
  }

  //---------------------------------------------------------------------------//

  HB_FUNC( WOLEERROR )
  {
     hb_retnl( (LONG) s_nOleError );
  }

  //---------------------------------------------------------------------------//

  static char * WOle2TxtError( void )
  {
     switch( (LONG) s_nOleError )
     {
        case S_OK:
           return "S_OK";

        case CO_E_CLASSSTRING:
           return "CO_E_CLASSSTRING";

        case OLE_E_WRONGCOMPOBJ:
           return "OLE_E_WRONGCOMPOBJ";

        case REGDB_E_CLASSNOTREG:
           return "REGDB_E_CLASSNOTREG";

        case REGDB_E_WRITEREGDB:
           return "REGDB_E_WRITEREGDB";

        case E_OUTOFMEMORY:
           return "E_OUTOFMEMORY";

        case E_NOTIMPL:
           return "E_NOTIMPL";

        case E_INVALIDARG:
           return "E_INVALIDARG";

        case E_UNEXPECTED:
           return "E_UNEXPECTED";

        case DISP_E_UNKNOWNNAME:
           return "DISP_E_UNKNOWNNAME";

        case DISP_E_UNKNOWNLCID:
           return "DISP_E_UNKNOWNLCID";

        case DISP_E_BADPARAMCOUNT:
           return "DISP_E_BADPARAMCOUNT";

        case DISP_E_BADVARTYPE:
           return "DISP_E_BADVARTYPE";

        case DISP_E_EXCEPTION:
           return "DISP_E_EXCEPTION";

        case DISP_E_MEMBERNOTFOUND:
           return "DISP_E_MEMBERNOTFOUND";

        case DISP_E_NONAMEDARGS:
           return "DISP_E_NONAMEDARGS";

        case DISP_E_OVERFLOW:
           return "DISP_E_OVERFLOW";

        case DISP_E_PARAMNOTFOUND:
           return "DISP_E_PARAMNOTFOUND";

        case DISP_E_TYPEMISMATCH:
           return "DISP_E_TYPEMISMATCH";

        case DISP_E_UNKNOWNINTERFACE:
           return "DISP_E_UNKNOWNINTERFACE";

        case DISP_E_PARAMNOTOPTIONAL:
           return "DISP_E_PARAMNOTOPTIONAL";

        case CO_E_SERVER_EXEC_FAILURE:
           return "CO_E_SERVER_EXEC_FAILURE";

        case MK_E_UNAVAILABLE:
           return "MK_E_UNAVAILABLE";

        default:
           TraceLog( NULL, "TOleAutoX Error %p\n", s_nOleError );
           return "Unknown error";
     };
  }

  //---------------------------------------------------------------------------//
  HB_FUNC( WOLE2TXTERROR )
  {
     hb_retc( WOle2TxtError() );
  }

  //---------------------------------------------------------------------------//

  HB_FUNC_STATIC( MESSAGEBOX )
  {
     hb_retni( MessageBox( ( HWND ) hb_parnl( 1 ), hb_parcx( 2 ), hb_parcx( 3 ), hb_parni( 4 ) ) );
  }

  //---------------------------------------------------------------------------//

  HB_FUNC_STATIC( CREATEOLEOBJECT ) // ( cOleName | cCLSID  [, cIID ] )
  {
     BSTR bstrClassID;
     IID ClassID, iid;
     LPIID riid = (LPIID) &IID_IDispatch;
     IDispatch *pDisp;

     bstrClassID = AnsiToSysString( hb_parcx( 1 ) );

     if( hb_parcx( 1 )[ 0 ] == '{' )
     {
        s_nOleError = CLSIDFromString( bstrClassID, (LPCLSID) &ClassID );
     }
     else
     {
        s_nOleError = CLSIDFromProgID( bstrClassID, (LPCLSID) &ClassID );
     }

     SysFreeString( bstrClassID );

     //TraceLog( NULL, "Result: %i\n", s_nOleError );

     if( hb_pcount() == 2 )
     {
        if( hb_parcx( 2 )[ 0 ] == '{' )
        {
           bstrClassID = AnsiToSysString( hb_parcx( 2 ) );
           s_nOleError = CLSIDFromString( bstrClassID, &iid );
           SysFreeString( bstrClassID );
        }
        else
        {
           memcpy( ( LPVOID ) &iid, hb_parcx( 2 ), sizeof( iid ) );
        }

        riid = &iid;
     }

     if( s_nOleError == S_OK )
     {
        //TraceLog( NULL, "Class: %i\n", ClassID );
        pDisp = NULL;
        s_nOleError = CoCreateInstance( (REFCLSID) &ClassID, NULL, CLSCTX_SERVER, (REFIID) riid, (void **) &pDisp );
        //TraceLog( NULL, "Result: %i\n", s_nOleError );
     }

     hb_retnl( ( LONG ) pDisp );
  }

  //---------------------------------------------------------------------------//

  HB_FUNC_STATIC( GETOLEOBJECT ) // ( cOleName | cCLSID  [, cIID ] )
  {
     BSTR bstrClassID;
     IID ClassID, iid;
     LPIID riid = (LPIID) &IID_IDispatch;
     IUnknown *pUnk = NULL;
     IDispatch *pDisp;
     //LPOLESTR pOleStr = NULL;

     s_nOleError = S_OK;

     if( ( s_nOleError == S_OK ) || ( s_nOleError == (HRESULT) S_FALSE) )
     {
        bstrClassID = AnsiToSysString( hb_parcx( 1 ) );

        if( hb_parcx( 1 )[ 0 ] == '{' )
        {
           s_nOleError = CLSIDFromString( bstrClassID, (LPCLSID) &ClassID );
        }
        else
        {
           s_nOleError = CLSIDFromProgID( bstrClassID, (LPCLSID) &ClassID );
        }

        //s_nOleError = ProgIDFromCLSID( &ClassID, &pOleStr );
        //wprintf( L"Result %i ProgID: '%s'\n", s_nOleError, pOleStr );

        SysFreeString( bstrClassID );

        if( hb_pcount() == 2 )
        {
           if( hb_parcx( 2 )[ 0 ] == '{' )
           {
              bstrClassID = AnsiToSysString( hb_parcx( 2 ) );
              s_nOleError = CLSIDFromString( bstrClassID, &iid );
              SysFreeString( bstrClassID );
           }
           else
           {
              memcpy( ( LPVOID ) &iid, hb_parcx( 2 ), sizeof( iid ) );
           }

           riid = &iid;
        }

        if( s_nOleError == S_OK )
        {
           s_nOleError = GetActiveObject( (REFCLSID) &ClassID, NULL, &pUnk );

           if( s_nOleError == S_OK )
           {
              pDisp = NULL;
              s_nOleError = pUnk->lpVtbl->QueryInterface( pUnk, (REFIID) riid, (void **) &pDisp );
           }
        }
     }

     hb_retnl( ( LONG ) pDisp );
  }

  //---------------------------------------------------------------------------//

  HB_FUNC_STATIC( OLERELEASEOBJECT ) // (hOleObject, szMethodName, uParams...)
  {
     IDispatch *pDisp = ( IDispatch * ) hb_parnl( 1 );

     s_nOleError = pDisp->lpVtbl->Release( pDisp );
  }

  //---------------------------------------------------------------------------//

  static void OleSetProperty( IDispatch *pDisp, DISPID DispID, DISPPARAMS *pDispParams )
  {
     // 1 Based!!!
     if( ( s_OleRefFlags && s_OleRefFlags[ 1 ] ) || hb_param( 1, HB_IT_ARRAY ) )
     {
        memset( (LPBYTE) &excep, 0, sizeof( excep ) );

        s_nOleError = pDisp->lpVtbl->Invoke( pDisp,
                                             DispID,
                                             (REFIID) &IID_NULL,
                                             LOCALE_USER_DEFAULT,
                                             DISPATCH_PROPERTYPUTREF,
                                             pDispParams,
                                             NULL,    // No return value
                                             &excep,
                                             &uArgErr );

       if( s_nOleError == S_OK )
       {
          return;
       }
     }

     memset( (LPBYTE) &excep, 0, sizeof( excep ) );

     s_nOleError = pDisp->lpVtbl->Invoke( pDisp,
                                          DispID,
                                          (REFIID) &IID_NULL,
                                          LOCALE_USER_DEFAULT,
                                          DISPATCH_PROPERTYPUT,
                                          pDispParams,
                                          NULL,    // No return value
                                          &excep,
                                          &uArgErr );
  }

  //---------------------------------------------------------------------------//

  static void OleInvoke( IDispatch *pDisp, DISPID DispID, DISPPARAMS *pDispParams )
  {
     memset( (LPBYTE) &excep, 0, sizeof( excep ) );

     s_nOleError = pDisp->lpVtbl->Invoke( pDisp,
                                          DispID,
                                          (REFIID) &IID_NULL,
                                          LOCALE_USER_DEFAULT,
                                          DISPATCH_METHOD,
                                          pDispParams,
                                          &RetVal,
                                          &excep,
                                          &uArgErr );
  }

  //---------------------------------------------------------------------------//

  static void OleGetProperty( IDispatch *pDisp, DISPID DispID, DISPPARAMS *pDispParams )
  {
     memset( (LPBYTE) &excep, 0, sizeof( excep ) );

     s_nOleError = pDisp->lpVtbl->Invoke( pDisp,
                                          DispID,
                                          (REFIID) &IID_NULL,
                                          LOCALE_USER_DEFAULT,
                                          DISPATCH_PROPERTYGET,
                                          pDispParams,
                                          &RetVal,
                                          &excep,
                                          &uArgErr );

  }

  //---------------------------------------------------------------------------//
  HB_FUNC_STATIC( TOLEAUTOX_ONERROR )
  {
     IDispatch *pDisp;
     DISPID DispID;
     DISPPARAMS DispParams;
     BOOL bSetFirst = FALSE;

     //TraceLog( NULL, "Class: '%s' Message: '%s', Params: %i Arg1: %i\n", hb_objGetClsName( hb_stackSelfItem() ), ( *HB_VM_STACK.pBase )->item.asSymbol.value->szName, hb_pcount(), hb_parinfo(1) );

     hb_vmPushSymbol( s_pSym_hObj->pSymbol );
     hb_vmPush( hb_stackSelfItem() );
     hb_vmSend( 0 );

     pDisp = ( IDispatch * ) hb_parnl( -1 );

     if( hb_stackBaseItem()->item.asSymbol.value->szName[0] == '_' && hb_stackBaseItem()->item.asSymbol.value->szName[1] && hb_pcount() >= 1 )
     {
        bstrMessage = AnsiToSysString( hb_stackBaseItem()->item.asSymbol.value->szName + 1 );
        s_nOleError = pDisp->lpVtbl->GetIDsOfNames( pDisp, (REFIID) &IID_NULL, (wchar_t **) &bstrMessage, 1, LOCALE_USER_DEFAULT, &DispID );
        SysFreeString( bstrMessage );
        //TraceLog( NULL, "1. ID of: '%s' -> %i Result: %i\n", ( *HB_VM_STACK.pBase )->item.asSymbol.value->szName + 1, DispID, s_nOleError );

        if( s_nOleError == S_OK )
        {
           bSetFirst = TRUE;
        }
     }
     else
     {
        s_nOleError = E_PENDING;
     }

     if( s_nOleError != S_OK )
     {
        // Try again without removing the assign prefix (_).
        bstrMessage = AnsiToSysString( hb_stackBaseItem()->item.asSymbol.value->szName );
        s_nOleError = pDisp->lpVtbl->GetIDsOfNames( pDisp, (REFIID) &IID_NULL, (wchar_t **) &bstrMessage, 1, 0, &DispID );
        SysFreeString( bstrMessage );
        //TraceLog( NULL, "2. ID of: '%s' -> %i Result: %i\n", ( *HB_VM_STACK.pBase )->item.asSymbol.value->szName, DispID, s_nOleError );
     }

     if( s_nOleError == S_OK )
     {
        GetParams( &DispParams );

        VariantInit( &RetVal );

        if( bSetFirst )
        {
           DispParams.rgdispidNamedArgs = &lPropPut;
           DispParams.cNamedArgs = 1;

           OleSetProperty( pDisp, DispID, &DispParams );
           //TraceLog( NULL, "OleSetProperty %i\n", s_nOleError );

           if( s_nOleError == S_OK )
           {
              hb_itemReturn( hb_stackItemFromBase( 1 ) );
           }
           else
           {
              DispParams.rgdispidNamedArgs = NULL;
              DispParams.cNamedArgs = 0;
           }
        }

        if( bSetFirst == FALSE || s_nOleError != S_OK )
        {
           OleInvoke( pDisp, DispID, &DispParams );
           //TraceLog( NULL, "OleInvoke %i\n", s_nOleError );

           if( s_nOleError == S_OK )
           {
              RetValue();
           }
        }

        // Collections are properties that do require arguments!
        if( s_nOleError != S_OK /* && hb_pcount() == 0 */ )
        {
           OleGetProperty( pDisp, DispID, &DispParams );
           //TraceLog( NULL, "OleGetProperty %i\n", s_nOleError );

           if( s_nOleError == S_OK )
           {
              RetValue();
           }
        }

        if( s_nOleError != S_OK && hb_pcount() >= 1 )
        {
           DispParams.rgdispidNamedArgs = &lPropPut;
           DispParams.cNamedArgs = 1;

           OleSetProperty( pDisp, DispID, &DispParams );
           //TraceLog( NULL, "OleSetProperty %i\n", s_nOleError );

           if( s_nOleError == S_OK )
           {
              hb_itemReturn( hb_stackItemFromBase( 1 ) );
           }
        }

        FreeParams( &DispParams );
     }

     if( s_nOleError == S_OK )
     {
        //TraceLog( NULL, "Invoke Succeeded!\n" );

        if( HB_IS_OBJECT( hb_stackReturnItem() ) )
        {
           HB_ITEM Return;
           HB_ITEM OleClassName;
           char sOleClassName[ 256 ];

           Return.type = HB_IT_NIL;
           hb_itemForwardValue( &Return, hb_stackReturnItem() ) ;


           hb_vmPushSymbol( s_pSym_cClassName->pSymbol );
           hb_vmPush( hb_stackSelfItem() );
           hb_vmSend( 0 );

           strncpy( sOleClassName, hb_parc( - 1 ), hb_parclen( -1 ) );
           sOleClassName[ hb_parclen( -1 ) ] = ':';
           strcpy( sOleClassName + hb_parclen( -1 ) + 1, hb_stackBaseItem()->item.asSymbol.value->szName );

           //TraceLog( NULL, "Class: '%s'\n", sOleClassName );

           OleClassName.type = HB_IT_NIL;
           hb_itemPutC( &OleClassName, sOleClassName );

           hb_vmPushSymbol( s_pSym_cClassName->pSymbol );
           hb_vmPush( &Return );
           hb_itemPushForward( &OleClassName );
           hb_vmSend( 1 );

           hb_itemReturn( &Return );
        }
     }
     else
     {
        PHB_ITEM pReturn;
        char *sDescription;

        //TraceLog( NULL, "Invoke Failed!\n" );

        hb_vmPushSymbol( s_pSym_cClassName->pSymbol );
        hb_vmPush( hb_stackSelfItem() );
        hb_vmSend( 0 );

        if( s_nOleError == DISP_E_EXCEPTION )
        {
           // Intentional to avoid report of memory leak if fatal error.
           char *sTemp = WideToAnsi( excep.bstrDescription );
           sDescription = (char *) malloc( strlen( sTemp ) + 1 );
           strcpy( sDescription, sTemp );
           hb_xfree( sTemp );
        }
        else
        {
           sDescription = WOle2TxtError();
        }

        //TraceLog( NULL, "Desc: '%s'\n", sDescription );

        pReturn = hb_errRT_SubstParams( hb_parcx( -1 ), EG_OLEEXECPTION, (ULONG) s_nOleError, sDescription, hb_stackBaseItem()->item.asSymbol.value->szName );

        if( s_nOleError == DISP_E_EXCEPTION )
        {
           free( (void *) sDescription );
        }

        if( pReturn )
        {
           hb_itemReturn( pReturn );
        }
     }
  }

#pragma ENDDUMP


//----------------------------------------------------------------------------//
INIT PROCEDURE Initialize_Ole
//----------------------------------------------------------------------------//

   IF ! bOleInitialized
      bOleInitialized := .T.
      Ole_Initialize()
   ENDIF

RETURN

//----------------------------------------------------------------------------//
EXIT PROCEDURE __DEACTIVATE__OLE
//----------------------------------------------------------------------------//

   UnInitialize_ole()

Return

//----------------------------------------------------------------------------//
PROCEDURE UnInitialize_Ole
//----------------------------------------------------------------------------//

   IF bOleInitialized
      bOleInitialized := .F.
      Ole_UnInitialize()
   ENDIF

RETURN
#endif
