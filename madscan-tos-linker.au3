#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <Misc.au3>
#include <Array.au3>


; ������ �� xml, ���������� �������� �������
Global Const $yqlAPICompanyNameRequest = "http://d.yimg.com/autoc.finance.yahoo.com/autoc?query=<SYMBOL>&callback=YAHOO.Finance.SymbolSuggest.ssCallback"

; ������ �� xml, ���������� ������ � ��������� ��������
Global Const $yqlAPICompanySectorRequest = "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.stocks%20where%20symbol%3D%22<SYMBOL>%22&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"

; ����������� ������� ESC ��� ������ �� ���������
HotKeySet("{ESC}", "Terminate")

; ������� ���� �����
$pic = GUICreate("Linker", 400, 30, 620, 80, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_TOPMOST)) ;

; ������ �� ����� �������� � ���������� �����
$basti_stay = GUICtrlCreatePic("bground.gif", 0, 0, 400, 30,-1, $GUI_WS_EX_PARENTDRAG)

; ������� ������� (���� ������)
$hDC = GUICtrlCreateLabel("",0, 0, 400, 30)
; ��������� �������
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor($hDC, 0xffd800)

; ���������� ���� �����
GUISetState(@SW_SHOW)

; ������������� ������
$symbPrev = ""

; "������" ���� ����������� ���� �����
While 1
   
   ; ����� ������� ����� � ��������� ����
   Local $hActiveText = WinGetText("[ACTIVE]", "")

   ; ���������� ���������� ���� ������ � ��������� ��������� WinGetText() ��� �������� Madscan
   If StringInStr($hActiveText, "toolStripContainer1") = 1 Then
	  
	  ; ������� ���������� �������� �������
      ControlSetText($pic, "", $hDC, "")
	  
	  ; ���� �������� ���� - ��� ������ Madscan, �� �������� ��� Ctrl+C ��� ����������� � ����� ���� ������, ������� ��� ������
      Send("{CTRLDOWN}C{CTRLUP}")

	  ; ������� �� ������ ����� �� ������� ������ (������� � ������������ �������, �������� 1:13 PM)
      Local $Clip = StringRegExpReplace (ClipGet(), ":\d+\s[A|P]M", "", 0)
	  
      ; �������� �� �������� ������ �����
      Local $TickerArray = StringRegExp($Clip, '([A-Z|\.\-\+]+)\s', 1, 1)
      Local $Ticker = _ArrayToString($TickerArray, "")
	  ; ConsoleWrite($TickerArray & @CRLF)
	  ; ConsoleWrite($Ticker & @CRLF)
	  
	  ; ��������� $symbPrev
	  $symbPrev = $Ticker

	  ; ���������� ���� Level2 � Arche
       _WinWaitActivate("[CLASS:SunAwtFrame]", "")
      Local $hLevelII = ControlGetHandle("[CLASS:SunAwtFrame]", "", "")
	  ConsoleWrite($hLevelII & @CRLF)
	  ; ControlClick("", "", "[CLASS:SunAwtFrame]", "left", 2, 106, 66)
      ControlSend ("", "", $hLevelII, $Ticker & "{ENTER}", 0)
	  ; ConsoleWrite(@error & @CRLF)
;~ 	  
;~ 	  For $element In $TickerArray
;~ 		 Send($element)
;~ 	  Next
;~ 	  Send( "{ENTER}")
	  
	  ; ����� ������� ��� ��������� ���� �������� �� ������
      $sSymbolInfo = GetCompanyInfo($Ticker)
	  
	  ; ������������� �������� ������� � ������������ � ���� � ��������
      GUICtrlSetData($hDC, $sSymbolInfo)

   EndIf

   ; ������ �������������� :)
   
   ; ���������� ��������� ��������� ����
   Local $windowTitle = WinGetTitle("[ACTIVE]", "")
   ; ConsoleWrite("$windowTitle=" & $windowTitle & @LF)
  
   ; ���� �������� ���� - ��� ���� Level2, ��
   If StringInStr($windowTitle, "Level2") = 1 Then
     
      ; ���������� ������� ����� ���� Level2
      Local $hActiveText = $windowTitle
      ; ConsoleWrite("$hActiveText=" & $hActiveText & @LF)
     
      ; �� �������� ������ �������� �����, �� ��������
      $symbArray = StringRegExp($hActiveText, '([A-Z|\.\-\+]+)~', 1, 1)
      If @error > 0 Then
         ; ConsoleWrite("StringRegExp@error=" & @error & @LF)
         MsgBox(0, "StringRegExp@error", @error)
      EndIf
     
      ; �����
      Local $symbNew = _ArrayToString($symbArray, "")
     
      ; ���� �������� ������ ����������, ��
      If $symbNew <> $symbPrev Then
         ; ConsoleWrite("$symbNew=" & $symbNew & @LF )
         
         ; ������� ���������� �������� �������
         ControlSetText($pic, "", $hDC, "")
         
         ; ����� ������� ��� ��������� ���� �������� �� ������
         $sSymbolInfo = GetCompanyInfo($symbNew)
     
         ; ������������� �������� ������� � ������������ � ���� � ��������
         GUICtrlSetData($hDC, $sSymbolInfo)
         
         ; �������� ���������� �������� ������ �� �����
         $symbPrev = $symbNew
      EndIf
     
   EndIf   
   ; ���� ������ ������ ������� ����� - ����� �� �����
   If _IsPressed("02") Then
      ExitLoop
   EndIf

WEnd

; ������� ��������� ����
Func _WinWaitActivate($title,$text,$timeout=0)
    WinWait($title,$text,$timeout)
    If Not WinActive($title,$text) Then WinActivate($title,$text)
    WinWaitActive($title,$text,$timeout)
 EndFunc

; ����� �� ���������
Func Terminate()
    Exit 0
 EndFunc

; ��������� ���� � �������� �� ������
Func GetCompanyInfo($sSymbol)

   $sRequest = StringReplace($yqlAPICompanyNameRequest, "<SYMBOL>", $sSymbol)
   ; ConsoleWrite($sRequest & @CRLF)

   ; ��������� ���������� �� ����� ��������
   $bData = InetRead($sRequest)

   $aLines = BinaryToString($bData, 4)
   $aLines = StringReplace($aLines, "},{", @CRLF)
   ; ConsoleWrite($aLines & @CRLF)

   $array = StringRegExp($aLines, '"name": (".*"),"exch".*":(.*),', 1, 1)
   ; '"name": (".*"),"exch".*exchDisp":(.*),'
   If @error = 0 then
	  ; ConsoleWrite ($array[0] & @CRLF)
	  ;ConsoleWrite ($array[1] & @CRLF)
	  $sCompanyInfo = ($array[0] & @CRLF & $array[1] & ", ")
   Else
	  $sCompanyInfo = "N/A, "
   EndIf

   ; ��������� ���������� � ������� � ��������� ��������

   $sRequest = StringReplace($yqlAPICompanySectorRequest, "<SYMBOL>", $sSymbol)
   ; ConsoleWrite($sRequest & @CRLF)
   $bData = InetRead($sRequest)

   $aLines = BinaryToString($bData, 4)
   ; ConsoleWrite($aLines & @CRLF)
   
   $array = StringRegExp($aLines, '<Sector>(.*)<\/Sector><Industry>(.*)<\/Industry>', 1, 1)
   If @error = 0 then
      ; ConsoleWrite ($array[0] & @CRLF)
      ; ConsoleWrite ($array[1] & @CRLF)
      $sCompanyInfo = $sCompanyInfo & $array[0] & ", " & $array[1]
   Else
	  $sCompanyInfo = $sCompanyInfo & "N/A"
   EndIf

   Return $sCompanyInfo

EndFunc