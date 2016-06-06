/*
Comment where needed on Harbour 3.2
*/

/* general */

//#define WIN_MAKELONG( lw, hw )     hb_bitOr( hb_bitShift( hb_bitAnd( hw, 0xFFFF ), 16 ), hb_bitAnd( lw, 0xFFFF ) )
//#define WIN_WS_EX_CLIENTEDGE       WS_EX_CLIENTEDGE
//#define WIN_WS_EX_TRANSPARENT      WS_EX_TRANSPARENT
//#define WIN_WM_GETFONT             WM_GETFONT
//#define WIN_WM_SETFONT             WM_SETFONT
//#define WIN_WM_SIZE                WM_SIZE
//#define WIN_WM_LBUTTONUP           WM_LBUTTONUP
//#define WIN_WM_SETTEXT             WM_SETTEXT
//#define EVENT_HANDLED              1
//#define EVENT_UNHANDLED            0

/* progressbar */

//#define PBS_MARQUEE                8
//#define PBM_SETMARQUEE             ( WM_USER + 10 )

/* listview */

#define LVM_SETEXTENDEDLISTVIEWSTYLE ( LVM_FIRST + 54 )
#define LVS_EX_FULLROWSELECT         0x00000020 // applies to report mode only
#define LVM_INSERTCOLUMNA            ( LVM_FIRST + 27 )
#define LVM_INSERTCOLUMNW            ( LVM_FIRST + 97 )
#ifdef UNICODE
   #define  LVM_INSERTCOLUMN         LVM_INSERTCOLUMNW
#else
   #define  LVM_INSERTCOLUMN         LVM_INSERTCOLUMNA
#endif
#define LVM_INSERTITEMA              ( LVM_FIRST + 7 )
#define LVM_INSERTITEMW              ( LVM_FIRST + 77 )
#ifdef UNICODE
   #define LVM_INSERTITEM            LVM_INSERTITEMW
#else
   #define LVM_INSERTITEM            LVM_INSERTITEMA
#endif

/* button command link */

#define BS_COMMANDLINK               0x0000000E
#define BCM_FIRST                    0x1600
#define BCM_SETNOTE                  ( BCM_FIRST + 9 )

/* trackbar */

#define TBS_AUTOTICKS                0x0001
#define TBS_ENABLESELRANGE           0x0020
#define TBM_GETPOS                   ( WM_USER )
#define TBM_SETPOS                   ( WM_USER + 5 )
#define TBM_SETRANGE                 ( WM_USER + 6 )
#define TBM_SETSEL                   ( WM_USER + 10 )
#define TBM_SETPAGESIZE              ( WM_USER + 21 )

/* updown */

#define UDS_ALIGNRIGHT               0x0004
#define UDM_SETRANGE                 ( WM_USER + 101 )
#define UDM_SETPOS                   ( WM_USER + 103 )
