#Region ;**** 参数创建于 ACNWrapper_GUI ****
#PRE_icon=C:\WINDOWS\System32\SHELL32.dll|-168
#PRE_Outfile=AutoSD.exe
#PRE_Compression=4
#PRE_UseX64=n
#PRE_Res_Description=自动关机程序。
#PRE_Res_Fileversion=1.0.0.1
#PRE_Res_LegalCopyright=AutoAD
#PRE_Res_requestedExecutionLevel=None
#EndRegion ;**** 参数创建于 ACNWrapper_GUI ****

#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>
#include "Functions.au3"

Opt("GUIOnEventMode", 1)   			  ; 设置为 事件驱动 模式

#Region ### START Koda GUI section ###
Local $config_path = @MyDocumentsDir & '\AutoSD'          ; 程序文档文件路径
Local $file_config = $config_path & '\config.ini'	       ; 配置文件路径
If Not FileExists($config_path) Then DirCreate($config_path)    ; 检测配置文件夹
FileInstall('AutoSD.jpg', $config_path & '\AutoSD')            ; 释放 log 图片
FileInstall('AutoSD.dll', $config_path & '\AutoSD.dll')       ; 释放 log dll
FileInstall('config.ini', $file_config)                 ; 释放 配置文件
Local $Setting_Values = IniReadSection($file_config, 'Setting')		  ; 读取配置文件
If @error Or $Setting_Values[0][0] <> 6 Then Local $Setting_Values = [[6, ''],['launch',False],['launch_min',False],['exit',False],['min',False],['nobox',False],['launch_startCountdown',False]]
Local $Temp_Setting_Values = $Setting_Values
Local $Task = IniRead($file_config, 'Config', 'task', '关机')
Local $Timer = IniRead($file_config, 'Config', 'timing', 1800)
Local $Countdown = $Timer
Local $Progress_Value = 0, $temp_timer = 0
Local $Timer_Active = False, $About_Active = False

Local $About
$root = GUICreate("AutoSD by ONE-CCS", 500, 300)

$setting = GUICreate("设置", 300, 250, -1, -1, -1, -1, $root)
GUICtrlCreateLabel("关于", 226, 66, 28, 17)
$Icon_About = GUICtrlCreateIcon($config_path & '\AutoSD.dll', -2, 222, 32, 32, 32)
GUICtrlCreateGroup("开机启动项", 24, 20, 150, 76)
$Checkbox_launch = GUICtrlCreateCheckbox("随计算机启动", 44, 44, 97, 17)
$Checkbox_launch_min = GUICtrlCreateCheckbox("启动后最小化", 59, 68, 97, 17)
GUICtrlCreateGroup("关闭主面板", 24, 110, 150, 100)
$Checkbox_exit = GUICtrlCreateCheckbox("退出 AutoSD", 44, 134, 97, 17)
$Checkbox_min = GUICtrlCreateCheckbox("最小化到系统托盘", 44, 158, 120, 17)
$Checkbox_nobox = GUICtrlCreateCheckbox("不显示确认提示框", 44, 182, 120, 17)
$Checkbox_launch_startCountdown = GUICtrlCreateCheckbox("启动时立即执行倒计时", 30, 220, 146, 17)
$Button_Setting_ok = GUICtrlCreateButton("确定", 200, 112, 75, 25)
$Button_Setting_apply = GUICtrlCreateButton("应用", 200, 152, 75, 25)
$Button_Setting_cancel = GUICtrlCreateButton("取消", 200, 192, 75, 25)

GUISwitch($root)
If FileExists($config_path & '\AutoSD') Then
	GUICtrlCreatePic($config_path & "\AutoSD", 135, 18, 0, 0)
Else
	GUICtrlCreateLabel("A u t o S D", 100, 18, 300, 80, $SS_CENTER)
	GUICtrlSetFont(-1, 38, 400, 6)
	GUICtrlSetColor(-1, 0x800001)
EndIf
$Label1 = GUICtrlCreateLabel("任务", 32, 105, 36, 20)
$Combo_Task = GUICtrlCreateCombo("", 72, 102, 90, 25, $CBS_DROPDOWNLIST)
$Label2 = GUICtrlCreateLabel("定时(s)", 174, 105, 60, 20)
$Input_Timer = GUICtrlCreateInput($Timer, 238, 102, 66, 24, $ES_NUMBER)
$Button_Start = GUICtrlCreateButton("开始", 312, 99, 60, 30)
$Button_Reset = GUICtrlCreateButton("重置", 372, 99, 60, 30)
$Icon_Setting = GUICtrlCreateIcon($config_path & '\AutoSD.dll', -1, 438, 98, 32, 32)
$Label_Countdown = GUICtrlCreateLabel($Timer, 125, 152, 250, 80, $SS_CENTER)
$Label_EndDate = GUICtrlCreateLabel("0000-00-00  00:00:00", 168, 238, 164, 20, $SS_CENTER)
$Progress = GUICtrlCreateProgress(135, 262, 230, 17, $PBS_SMOOTH)
$StatusBar = _GUICtrlStatusBar_Create($root)

; 设置对象事件
GUISetOnEvent($GUI_EVENT_CLOSE, "Root_Close", $root)
GUISetOnEvent($GUI_EVENT_CLOSE, "Setting_Close", $setting)
GUICtrlSetOnEvent($Combo_Task, "Combo_Task_Change")
GUICtrlSetOnEvent($Button_Start, "Button_Start_Click")
GUICtrlSetOnEvent($Button_Reset, "Button_Reset_Click")
GUICtrlSetOnEvent($Checkbox_launch, "Checkbox_Setting")
GUICtrlSetOnEvent($Checkbox_launch_min, "Checkbox_Setting")
GUICtrlSetOnEvent($Checkbox_exit, "Checkbox_Setting")
GUICtrlSetOnEvent($Checkbox_min, "Checkbox_Setting")
GUICtrlSetOnEvent($Checkbox_nobox, "Checkbox_Setting")
GUICtrlSetOnEvent($Checkbox_launch_startCountdown, "Checkbox_Setting")
GUICtrlSetOnEvent($Button_Setting_ok, "Button_Setting")
GUICtrlSetOnEvent($Button_Setting_apply, "Button_Setting")
GUICtrlSetOnEvent($Button_Setting_cancel, "Button_Setting")
GUICtrlSetOnEvent($Icon_Setting, "Icon_Setting_Click")
GUICtrlSetOnEvent($Icon_About, "Icon_About_Click")

; 设置对象属性
GUISetBkColor(0xC8C8C8, $root)
GUISetBkColor(0xC8C8C8, $setting)
GUICtrlSetFont($Button_Start, 12, 400, 0, "宋体")
GUICtrlSetFont($Button_Reset, 12, 400, 0, "宋体")
GUICtrlSetLimit($Input_Timer, 6)
GUICtrlSetFont($Input_Timer, 12, 400, 0, "宋体")
GUICtrlSetData($Combo_Task, "注销|关机|重启|强制关机|关闭电源|待机|休眠", $Task)
GUICtrlSetFont($Combo_Task, 12, 400, 0, "宋体")
GUICtrlSetFont($Label1, 12, 400, 0, "宋体")
GUICtrlSetFont($Label2, 12, 400, 0, "宋体")
GUICtrlSetFont($Label_Countdown, 56, 400, 0, "宋体")
GUICtrlSetColor($Label_Countdown, 0x000000)
GUICtrlSetFont($Label_EndDate, 12, 400, 0, "宋体")
Dim $StatusBar_PartsWidth[6] = [100, 190, 280, 350, 430, -1]
_GUICtrlStatusBar_SetParts($StatusBar, $StatusBar_PartsWidth)
_GUICtrlStatusBar_SetText($StatusBar, @TAB & "今年第 " & @YDAY & " 天", 0)
_GUICtrlStatusBar_SetText($StatusBar, @TAB & "剩余 " & Surplus_day() & " 天", 1)
_GUICtrlStatusBar_SetText($StatusBar, @TAB & Date(), 2)
_GUICtrlStatusBar_SetText($StatusBar, @TAB & "00:00:00", 3)
_GUICtrlStatusBar_SetText($StatusBar, @TAB & year(), 4)
_GUICtrlStatusBar_SetText($StatusBar, @TAB & Week(), 5)

GUISetState(@SW_SHOW, $root)
#EndRegion ### END Koda GUI section ###

Root_Init()      ; 程序初始化

; 主循环
While 1
	_GUICtrlStatusBar_SetText($StatusBar, @TAB & Time(), 3)
	Sleep(250)
	If $Timer_Active Then
		$temp_timer += 1
		If $temp_timer >= 4 Then
			$temp_timer = 0
			$Countdown -= 1
			GUICtrlSetData($Label_Countdown, $Countdown)
		EndIf
		If $Progress_Value > 0 Then
			$Progress_Value = Persent($Countdown, $Timer)
			GUICtrlSetData($Progress, $Progress_Value)
		EndIf
		If $Countdown = 1 Then
			IniWrite($file_config, 'Config', 'task', $Task)
			IniWrite($file_config, 'Config', 'timing', $Timer)
		ElseIf $Countdown <= 0 Then
			$Timer_Active = False
			Button_Reset_Click()
			Command($Task)
		EndIf
	EndIf
WEnd

;~ Event ------------------------------------------------------------------ ~;

Func Root_Init()
	;;; 程序 初始化 事件
	If $Task <> '关机' And $Task <> '重启' And $Task <> '注销' Then $Task = '关机'
	If $Timer < 10 Then $Timer = 1800
EndFunc

Func Root_Close()
	; 主窗口 关闭按钮 事件
	Local $info
	If $Setting_Values[5][1] = 'False' Then
		$info = MsgBox(33,'提示', '确定要退出吗？'& @CRLF & @CRLF & 'tip：可在设置中禁用该提示。', 3, $root)
		If $info <> 1 Then Return
	EndIf
	IniWrite($file_config, 'Config', 'task', $Task)
	IniWrite($file_config, 'Config', 'timing', $Timer)
	Exit(0)
EndFunc

Func Setting_Close()
	; 设置窗口 关闭按钮 事件
	GUISetState(@SW_HIDE, $setting)
	GUISetState(@SW_SHOW, $root)
EndFunc

Func About_Close()
	; 关于窗口 关闭按钮 事件
	GUIDelete($About)
	$About_Active = False
EndFunc

Func Combo_Task_Change()
	; 任务下拉组合框 改变事件
	$Task = GUICtrlRead($Combo_Task)
EndFunc

Func Button_Start_Click()
	; 开始按钮 单击 事件
	Local $temp_f, $temp_b
	$temp_f = Timer_Refresh()
	$temp_b = GUICtrlRead($Button_Start)
	
	If $temp_b = '开始' Or $temp_b = '继续' Then GUICtrlSetData($Label_EndDate, EndDate($Countdown))
	If $temp_f = 1 And $temp_b = '开始' Then
		$Countdown = $Timer
		$Progress_Value = 100
		GUICtrlSetData($Progress, $Progress_Value)
		$temp_timer = 0
		$Timer_Active = True
		GUICtrlSetData($Button_Start, '暂停')
	ElseIf $temp_b = '继续' Then
		$Timer_Active = True
		GUICtrlSetData($Button_Start, '暂停')
	ElseIf $temp_b = '暂停' Then
		$Timer_Active = False
		GUICtrlSetData($Button_Start, '继续')
	EndIf
EndFunc

Func Button_Reset_Click()
	; 重置按钮 单击 事件
	Timer_Refresh()
	GUICtrlSetData($Label_Countdown, $Timer)
	GUICtrlSetData($Button_Start, '开始')
	$Timer_Active = False
	$Countdown = $Timer
	GUICtrlSetData($Label_EndDate, '0000-00-00  00:00:00')
	$Progress_Value = 0
	GUICtrlSetData($Progress, $Progress_Value)
	$temp_timer = 0
	GUICtrlSetData($Input_Timer, $Timer)
EndFunc

Func Icon_Setting_Click()
	; 设置按钮 单击 事件
	GUISetState(@SW_HIDE, $root)
	GUISetState(@SW_SHOW, $setting)
	Checkbox_Setting_Refresh()
EndFunc

Func Checkbox_Setting_Refresh()
	If $Setting_Values[1][1] = 'True' Then
		GUICtrlSetState($Checkbox_launch, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_launch, $GUI_UNCHECKED)
	EndIf
	If $Setting_Values[2][1] = 'True' Then
		GUICtrlSetState($Checkbox_launch_min, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_launch_min, $GUI_UNCHECKED)
	EndIf
	If $Setting_Values[3][1] = 'True' Then
		GUICtrlSetState($Checkbox_exit, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_exit, $GUI_UNCHECKED)
	EndIf
	If $Setting_Values[4][1] = 'True' Then
		GUICtrlSetState($Checkbox_min, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_min, $GUI_UNCHECKED)
	EndIf
	If $Setting_Values[5][1] = 'True' Then
		GUICtrlSetState($Checkbox_nobox, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_nobox, $GUI_UNCHECKED)
	EndIf
	If $Setting_Values[6][1] = 'True' Then
		GUICtrlSetState($Checkbox_launch_startCountdown, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_launch_startCountdown, $GUI_UNCHECKED)
	EndIf
EndFunc

Func Checkbox_Setting()
	; 设置窗口 复选框 事件
	Switch @GUI_CtrlId
		Case $Checkbox_launch
			If GUICtrlRead($Checkbox_launch) = $GUI_CHECKED Then
				GUICtrlSetState($Checkbox_launch_min, $GUI_ENABLE)
				$Temp_Setting_Values[1][1] = 'True'
			Else
				GUICtrlSetState($Checkbox_launch_min, $GUI_DISABLE)
				$Temp_Setting_Values[1][1] = 'False'
			EndIf
		Case $Checkbox_launch_min
			If GUICtrlRead($Checkbox_launch_min) = $GUI_CHECKED Then
				$Temp_Setting_Values[2][1] = 'True'
			Else
				$Temp_Setting_Values[2][1] = 'False'
			EndIf
		Case $Checkbox_exit
			If GUICtrlRead($Checkbox_exit) = $GUI_CHECKED Then
				$Temp_Setting_Values[3][1] = 'True'
			Else
				$Temp_Setting_Values[3][1] = 'False'
			EndIf
		Case $Checkbox_min
			If GUICtrlRead($Checkbox_min) = $GUI_CHECKED Then
				$Temp_Setting_Values[4][1] = 'True'
			Else
				$Temp_Setting_Values[4][1] = 'False'
			EndIf
		Case $Checkbox_nobox
			If GUICtrlRead($Checkbox_nobox) = $GUI_CHECKED Then
				$Temp_Setting_Values[5][1] = 'True'
			Else
				$Temp_Setting_Values[5][1] = 'False'
			EndIf
		Case $Checkbox_launch_startCountdown
			If GUICtrlRead($Checkbox_launch_startCountdown) = $GUI_CHECKED Then
				$Temp_Setting_Values[6][1] = 'True'
			Else
				$Temp_Setting_Values[6][1] = 'False'
			EndIf
	EndSwitch
EndFunc

Func Button_Setting()
	; 设置窗口 按钮单击 事件
	Switch @GUI_CtrlId
		Case $Button_Setting_ok
			$Setting_Values = $Temp_Setting_Values
			Checkbox_Setting_Refresh()
			IniWriteSection($file_config, 'Setting', $Setting_Values)
			Setting_Close()
		Case $Button_Setting_apply
			$Setting_Values = $Temp_Setting_Values
			Checkbox_Setting_Refresh()
			IniWriteSection($file_config, 'Setting', $Setting_Values)
		Case $Button_Setting_cancel
			Setting_Close()
	EndSwitch
EndFunc

Func Icon_About_Click()
	; 关于按钮 单击 事件
	If $About_Active Then
		Return
	Else
		$About = GUICreate("关于", 316, 220)
		GUISetBkColor(0xC8C8C8, $About)
		GUICtrlCreateGroup("", 8, 8, 300, 170)
		GUICtrlCreatePic($config_path & "\AutoSD", 43, 24, 230, 60)
		GUICtrlCreateLabel("产品名称：AutoSD", 108, 100, 105, 17)
		GUICtrlCreateLabel("版本：1.0.0.1", 116, 127, 80, 17)
		GUICtrlCreateLabel("版权：ONE-CCS", 116, 154, 90, 17)
		GUICtrlCreateGroup("", -99, -99, 1, 1)
		$About_Bok = GUICtrlCreateButton("确定", 121, 186, 75, 25)
		GUICtrlSetOnEvent($About_Bok, "About_Close")
		GUISetOnEvent($GUI_EVENT_CLOSE, "About_Close", $About)
		GUISetState(@SW_SHOW, $About)
		$About_Active = True
	EndIf
EndFunc

Func Timer_Refresh()
	; 倒计时刷新
	Local $temp = GUICtrlRead($Input_Timer)
	If $temp = '' Then Return -1
	If $temp < 10 Then
		ToolTip('请输入一个">= 10"的数！')
		Sleep(700)
		ToolTip('')
		Return 0
	EndIf
	If GUICtrlRead($Button_Start) = '开始' Or @GUI_CtrlId = $Button_Reset Then
		$Timer = GUICtrlRead($Input_Timer)
	EndIf
	Return 1
EndFunc
