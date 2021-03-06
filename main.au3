#Region ;**** 参数创建于 ACNWrapper_GUI ****
#PRE_Icon=AutoSD.dll|-3
#PRE_Outfile=AutoSD.exe
#PRE_Compression=4
#PRE_UseX64=n
#PRE_Res_Comment=自动关机程序。
#PRE_Res_Description=AutoSD
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
#include <Constants.au3>
#include "Functions.au3"
#NoTrayIcon
Opt("GUIOnEventMode", 1)   			  ; 设置为 事件驱动 模式
Opt("TrayOnEventMode", 1)			; 启用 托盘 事件驱动 模式
Opt("TrayMenuMode", 3)			; 取消 托盘 默认菜单

; 全局变量
Local $config_path, $file_config, $Startup_Shortcut
Local $Setting_Values, $Temp_Setting_Values, $Task, $Timer, $Countdown
Local $Progress_Value = 0, $temp_timer = 0
Local $Timer_Active = False, $About_Active = False
; 全局对象变量
Local $root
Local $Label1, $Combo_Task, $Label2, $Input_Timer, $Button_Start, $Button_Reset, $Icon_Setting
Local $Label_Countdown, $Label_EndDate, $Progress, $StatusBar, $MenuItem_Openview, $MenuItem_Start
Local $MenuItem_Pause, $MenuItem_About, $MenuItem_Setting, $MenuItem_Exit

Local $setting
Local $Icon_About, $Checkbox_launch, $Checkbox_launch_min, $Radio_exit, $Checkbox_nobox, $Radio_min
Local $Checkbox_launch_startCountdown, $Button_Setting_ok, $Button_Setting_apply, $Button_Setting_cancel

Local $About
; 主函数
Func Main()
	#Region ### START Koda GUI section ###
	$config_path = @MyDocumentsDir & '\AutoSD'          ; 程序文档文件目录
	$file_config = $config_path & '\config.ini'	       ; 配置文件路径
	$Startup_Shortcut = @StartupDir & '\AutoSD.lnk'     ; 启动组快捷方式路径
	If Not FileExists($config_path) Then DirCreate($config_path)    ; 检测配置文件夹
	FileInstall('AutoSD.jpg', $config_path & '\AutoSD')            ; 释放 log 图片
	FileInstall('AutoSD.dll', $config_path & '\AutoSD.dll')       ; 释放 log dll
	FileInstall('config.ini', $file_config)                 ; 释放 配置文件
	$Setting_Values = IniReadSection($file_config, 'Setting')		  ; 读取配置文件
	If @error Or $Setting_Values[0][0] <> 6 Then Local $Setting_Values = [[6, ''],['launch',False],['launch_min',False],['exit',False],['min',False],['nobox',False],['launch_startCountdown',False]]
	$Temp_Setting_Values = $Setting_Values
	$Task = IniRead($file_config, 'Config', 'task', '关机')
	$Timer = IniRead($file_config, 'Config', 'timing', 1800)
	$Countdown = $Timer

	$About
	$root = GUICreate("AutoSD by ONE-CCS", 500, 300)

	$setting = GUICreate("AutoSD - 设置", 300, 250, -1, -1, -1, -1, $root)
	GUICtrlCreateLabel("关于", 226, 66, 28, 17)
	$Icon_About = GUICtrlCreateIcon($config_path & '\AutoSD.dll', -2, 222, 32, 32, 32)
	GUICtrlCreateGroup("开机启动项", 24, 20, 150, 76)
	$Checkbox_launch = GUICtrlCreateCheckbox("随计算机启动", 44, 44, 97, 17)
	$Checkbox_launch_min = GUICtrlCreateCheckbox("启动后最小化", 59, 68, 97, 17)
	GUICtrlCreateGroup("关闭主面板", 24, 110, 150, 100)
	$Radio_exit = GUICtrlCreateRadio("退出 AutoSD", 44, 134, 100, 17)
	$Checkbox_nobox = GUICtrlCreateCheckbox("不显示提示框", 59, 158, 100, 17)
	$Radio_min = GUICtrlCreateRadio("最小化到系统托盘", 44, 182, 120, 17)
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
	$Label_EndDate = GUICtrlCreateLabel("0000-00-00  00:00:00", 167, 238, 166, 20, $SS_CENTER)
	$Progress = GUICtrlCreateProgress(135, 262, 230, 17, $PBS_SMOOTH)
	$StatusBar = _GUICtrlStatusBar_Create($root)
	; 托盘
	TraySetIcon("", -1)
	TraySetClick("16")
	$MenuItem_Openview = TrayCreateItem("打开主面板")
	$MenuItem_Start = TrayCreateItem("开始")
	$MenuItem_Pause = TrayCreateItem("暂停")
	$MenuItem_About = TrayCreateItem("关于")
	TrayCreateItem('')
	$MenuItem_Setting = TrayCreateItem("设置")
	TrayCreateItem('')
	$MenuItem_Exit = TrayCreateItem("退出 AutoSD")


	; 设置对象事件
	GUISetOnEvent($GUI_EVENT_CLOSE, "Root_Close", $root)
	GUISetOnEvent($GUI_EVENT_CLOSE, "Setting_Close", $setting)
	TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "Tray_Event")
	GUICtrlSetOnEvent($Combo_Task, "Combo_Task_Change")
	GUICtrlSetOnEvent($Button_Start, "Button_Start_Click")
	GUICtrlSetOnEvent($Button_Reset, "Button_Reset_Click")
	GUICtrlSetOnEvent($Checkbox_launch, "Setting_Change")
	GUICtrlSetOnEvent($Checkbox_launch_min, "Setting_Change")
	GUICtrlSetOnEvent($Radio_exit, "Setting_Change")
	GUICtrlSetOnEvent($Checkbox_nobox, "Setting_Change")
	GUICtrlSetOnEvent($Radio_min, "Setting_Change")
	GUICtrlSetOnEvent($Checkbox_launch_startCountdown, "Setting_Change")
	GUICtrlSetOnEvent($Button_Setting_ok, "Button_Setting")
	GUICtrlSetOnEvent($Button_Setting_apply, "Button_Setting")
	GUICtrlSetOnEvent($Button_Setting_cancel, "Button_Setting")
	GUICtrlSetOnEvent($Icon_Setting, "Icon_Setting_Click")
	GUICtrlSetOnEvent($Icon_About, "Icon_About_Click")
	TrayItemSetOnEvent($MenuItem_Openview, "Tray_Event")
	TrayItemSetOnEvent($MenuItem_Start, "Tray_Event")
	TrayItemSetOnEvent($MenuItem_Pause, "Tray_Event")
	TrayItemSetOnEvent($MenuItem_About, "Tray_Event")
	TrayItemSetOnEvent($MenuItem_Setting, "Tray_Event")
	TrayItemSetOnEvent($MenuItem_Exit, "MenuItem_Exit_Click")

	; 设置对象属性
	GUISetBkColor(0xC8C8C8, $root)
	GUISetBkColor(0xC8C8C8, $setting)
	GUICtrlSetFont($Button_Start, 12, 400, 0, "宋体")
	GUICtrlSetFont($Button_Reset, 12, 400, 0, "宋体")
	GUICtrlSetLimit($Input_Timer, 7)
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
	TraySetState()

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
				TraySetToolTip($Countdown)
			EndIf
			If $Progress_Value > 0 And Int($Progress_Value) <> Int(Persent($Countdown, $Timer)) Then
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
	
	Return 1
EndFunc

;~ 程序入口 ------------------------------------------------------------------ ~;
Root_Load()
Main()
;~ 程序出口 ------------------------------------------------------------------ ~;

;~ Event ------------------------------------------------------------------ ~;

Func Root_Load()
	;;; 程序 加载 事件
	If WinExists('AutoSD by ONE-CCS') Then
		TraySetState()
		TrayTip('您已打开一个窗口！', '如遇窗口无法操作，请点击托盘图标！', 10, 1)
		WinSetState('AutoSD by ONE-CCS', '', @SW_SHOW)
		WinFlash('AutoSD by ONE-CCS')
		Exit(0)
	EndIf
EndFunc

Func Root_Init()
	;;; 程序 初始化 事件
	Shortcut(Bool($Setting_Values[1][1]), $Startup_Shortcut)
	If $Task <> '关机' And $Task <> '重启' And $Task <> '注销' Then $Task = '关机'
	If $Timer < 10 Then $Timer = 1800
	Setting_Refresh()
	If Bool($Setting_Values[6][1]) = True Then Button_Start_Click()
EndFunc

Func Root_Close()
	; 主窗口 关闭按钮 事件
	Local $root_close
	Shortcut(Bool($Setting_Values[1][1]), $Startup_Shortcut)
	If Bool($Setting_Values[5][1]) = True Then
		GUISetState(@SW_HIDE, $root)
		Return
	EndIf
	If Bool($Setting_Values[4][1]) = False Then
		$root_close = MsgBox(33,'提示', '确定要退出吗？'& @CRLF & @CRLF & 'tip：可在设置中禁用该提示。', 3, $root)
		If $root_close <> 1 Then Return
	EndIf
	IniWrite($file_config, 'Config', 'task', $Task)
	IniWrite($file_config, 'Config', 'timing', $Timer)
	Setting_Refresh()
	IniWriteSection($file_config, 'Setting', $Setting_Values)
	
	Exit(0)
EndFunc

Func MenuItem_Exit_Click()
	;;; 托盘菜单 退出 单击事件
	Local $root_close
	Shortcut(Bool($Setting_Values[1][1]), $Startup_Shortcut)
	If Bool($Setting_Values[4][1]) = False Then
		$root_close = MsgBox(33,'提示', '确定要退出吗？'& @CRLF & @CRLF & 'tip：可在设置中禁用该提示。', 3, $root)
		If $root_close <> 1 Then Return
	EndIf
	IniWrite($file_config, 'Config', 'task', $Task)
	IniWrite($file_config, 'Config', 'timing', $Timer)
	Setting_Refresh()
	IniWriteSection($file_config, 'Setting', $Setting_Values)
	
	Exit(0)
EndFunc

Func Setting_Close()
	; 设置窗口 关闭按钮 事件
	GUISetState(@SW_HIDE, $setting)
	; If @TRAY_ID = $MenuItem_Setting Then Return
	GUISetState(@SW_SHOW, $root)
EndFunc

Func About_Close()
	; 关于窗口 关闭按钮 事件
	GUIDelete($About)
	$About_Active = False
EndFunc

Func Tray_Event()
	;;; 托盘 事件
	Switch @TRAY_ID
		Case $TRAY_EVENT_PRIMARYDOWN, $MenuItem_Openview
			GUISetState(@SW_SHOWNORMAL, $root)
		Case $MenuItem_Start
			If GUICtrlRead($Button_Start) = '开始' Then Button_Start_Click()
		Case $MenuItem_Pause
			If GUICtrlRead($Button_Start) = '暂停' Then Button_Start_Click()
		Case $MenuItem_About
			Icon_About_Click()
		Case $MenuItem_Setting
			Icon_Setting_Click()
		Case $MenuItem_Exit
			Root_Close()
	EndSwitch
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
	
	If $temp_f = 1 And $temp_b = '开始' Then
		$Countdown = $Timer
		GUICtrlSetData($Label_EndDate, EndDate($Countdown))
		$Progress_Value = 100
		GUICtrlSetData($Progress, $Progress_Value)
		$temp_timer = 0
		$Timer_Active = True
		GUICtrlSetData($Button_Start, '暂停')
	ElseIf $temp_b = '继续' Then
		$Timer_Active = True
		GUICtrlSetData($Label_EndDate, EndDate($Countdown))
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
	;;; 设置按钮 单击 事件
	GUISetState(@SW_HIDE, $root)
	GUISetState(@SW_SHOW, $setting)
	Setting_Refresh()
EndFunc

Func Setting_Refresh()
	;;; 设置 刷新
	; 单选框
	If Bool($Setting_Values[3][1]) = True Then
		GUICtrlSetState($Radio_exit, $GUI_CHECKED)
		GUICtrlSetState($Radio_min, $GUI_UNCHECKED)
		$Setting_Values[5][1] = 'False'
	Else
		GUICtrlSetState($Radio_exit, $GUI_UNCHECKED)
		GUICtrlSetState($Radio_min, $GUI_CHECKED)
		$Setting_Values[5][1] = 'True'
	EndIf
	; 复选框
	If Bool($Setting_Values[1][1]) = True Then
		GUICtrlSetState($Checkbox_launch, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_launch, $GUI_UNCHECKED)
		GUICtrlSetState($Checkbox_launch_min, $GUI_DISABLE)
	EndIf
	If Bool($Setting_Values[2][1]) = True Then
		GUICtrlSetState($Checkbox_launch_min, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_launch_min, $GUI_UNCHECKED)
	EndIf
	If Bool($Setting_Values[4][1]) = True Then
		GUICtrlSetState($Checkbox_nobox, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_nobox, $GUI_UNCHECKED)
	EndIf
	If Bool($Setting_Values[6][1]) = True Then
		GUICtrlSetState($Checkbox_launch_startCountdown, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_launch_startCountdown, $GUI_UNCHECKED)
	EndIf
EndFunc

Func Setting_Change()
	;;; 设置改变 事件
	Switch @GUI_CtrlId
		; 单选框
		Case $Radio_exit, $Radio_min
			If GUICtrlRead($Radio_exit) = $GUI_CHECKED Then
				$Temp_Setting_Values[3][1] = 'True'
				$Temp_Setting_Values[5][1] = 'False'
			Else
				$Temp_Setting_Values[3][1] = 'False'
				$Temp_Setting_Values[5][1] = 'True'
			EndIf
		; 复选框
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
		Case $Checkbox_nobox
			If GUICtrlRead($Checkbox_nobox) = $GUI_CHECKED Then
				$Temp_Setting_Values[4][1] = 'True'
			Else
				$Temp_Setting_Values[4][1] = 'False'
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
			Setting_Refresh()
			IniWriteSection($file_config, 'Setting', $Setting_Values)
			Setting_Close()
		Case $Button_Setting_apply
			$Setting_Values = $Temp_Setting_Values
			Setting_Refresh()
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
		$About = GUICreate("AutoSD - 关于", 316, 220)
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
