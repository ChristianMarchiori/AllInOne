Some samples from Jose M C Quintas

test.prg            - All-in-one main program and thread control
about.prg           - A About message
calculator.prg      - calculator using wvgpushbuttom
calendar.prg        - WVG sample calendar using wvgpushbuttom
frm1.prg            - sample using class for database console/wvg
menu.prg            - Menu in Clipper Style (with mouse) and wvg style
modalwindow.prg     - WVG modal window
pdf.prg             - sample of pdf class
progressbar.prg     - sample and progressbar with time
ze_frmclass.prg     - class for database console/wvg - draw part
ze_frmcadclass.prg  - class for database console/wvg - database movment
ze_messageclass.prg - class for message change
ze_errosys.prg      - alternative errorsys for wvg use
ze_functions.prg    - some generic functions used in samples, including copy/paste
ze_pdfclass.prg     - pdf class


All in One: hbmk2 test
Without WVG: hbmk2 testnowvg

NOTES:
- background is a small icon, to not increase sample size
- main module do not have screen. it will close when all modules are closed
To use multithread you need think on how prevent main module to be closed before other modules.
Closed don't means close window, because any module can run without a visible window.
- When using Windows menu, we lost last line, but progressbar is using it.
Test progressbar using console style menu
- Background is not possible using gtwvg.
  when move/resize/others, need repaint but is not possible
  If redraw picture text is lost, if redraw text picture is lost.
  All screen is text: empty screen is spaces (" ") like a console window.
- Toopltip of wvg don't works when using MSVC or mingw from QT5
- IF gt do not accept multiwindow hb_gtReload( x ) then change function AppMultiWindow() in ze_functions.prg
- Sample is sample. Can be ready to use or can need extra code.

If want separated EXEs for each sample, can be done.

hbmk2 about ze_functions
hbmk2 calculator      ze_functions
hbmk2 progressbar     ze_functions
hbmk2 calculator      ze_functions -DGTWVG gtwvg.hbc
hbmk2 calendar.prg    ze_functions -DGTWVG gtwvg.hbc
hbmk2 pdf ze_pdfclass ze_functions hbhpdf.hbc hbct.hbc
hbmk2 frm1 ze_frmclass ze_frmcadclass ze_functions
hbmk2 frm1 ze_frmclass ze_frmcadclass ze_functions -DGTWVG test.rc gtwvg.hbc
