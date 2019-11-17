;~ Function ------------------------------------------------------------------ ~;

Func Command(Const $Task)
	Switch $Task
		; ע��|�ػ�|����|ǿ�ƹػ�|�رյ�Դ|����|����
		Case 'ע��'
;~ 			Shutdown(0)
			MsgBox(0,'','ע��')
		Case '�ػ�'
;~ 			Shutdown(1)
			MsgBox(0,'','�ػ�')
		Case '����'
;~ 			Shutdown(2)
			MsgBox(0,'','����')
		Case 'ǿ�ƹػ�'
;~ 			Shutdown(0)
			MsgBox(0,'','ǿ�ƹػ�')
		Case '�رյ�Դ'
;~ 			Shutdown(0)
			MsgBox(0,'','�رյ�Դ')
		Case '����'
;~ 			Shutdown(0)
			MsgBox(0,'','����')
		Case '����'
;~ 			Shutdown(0)
			MsgBox(0,'','����')
		Case Else
;~ 			Shutdown(1)
			MsgBox(0,'','�ػ�')
	EndSwitch
EndFunc

Func Persent(Const $num1,Const $num2)
	; ���� $num1 ����� $num2 ȡ���İٷֱ�
	Local $one_persent = $num2 * 0.01
	Local $p
	$p = Round($num1 / $one_persent, 3)

	Return $p
EndFunc

Func EndDate($second)
	If $second > 31536000 Then Return -1
	Local $sec = @SEC, $min = @MIN, $hour = @HOUR
	Local $day = @MDAY, $mon = @MON, $year = @YEAR
	Local $leap_year = False
	Local $max_day = 28
	
	If Mod($year, 4) = 0 And Mod($year, 100) <> 0 Or Mod($year, 400) = 0 Then
		$leap_year = True
	EndIf
	While $second > 0
		Switch $mon
			Case 1, 3, 5, 7, 8, 10, 12
				$max_day = 31
			Case 2
				If $leap_year Then
					$max_day = 29
				Else
					$max_day = 28
				EndIf
			Case 4, 6, 9, 11
				$max_day = 30
		EndSwitch
		If $sec < 60 Then
			$sec += 1
			$second -= 1
			If $sec = 60 And $min < 60 Then
				$sec = 0
				$min += 1
				If $min = 60 And $hour < 24 Then
					$min = 0
					$hour += 1
					If $hour = 24 And $day < $max_day Then
						$hour = 0
						$day += 1
						If $day = $max_day And $mon < 12 Then
							$day = 1
							$mon += 1
							If $mon = 12 And $year < 9999 Then
								$mon = 1
								$year += 1
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	WEnd
	If $sec < 10 Then $sec = '0' & $sec
	If $min < 10 Then $min = '0' & $sec
	If $hour < 10 Then $hour = '0' & $hour
	If $day < 10 Then $dat = '0' & $day
	If $mon < 10 Then $mon = '0' & $mon
	If $year < 10 Then $year = '000' & $year
	If $year >= 10 And $year < 100 Then $year = '00' & $year
	If $year >= 100 And $year < 1000 Then $year = '0' & $year
	
	Return $year & '-' & $mon & '-' & $day & '  ' & $hour & ':' & $min & ':' & $sec
EndFunc

Func Time()
	Local $time = @HOUR & ':' & @MIN & ':' & @SEC

	Return $time
EndFunc

Func Date()
	Local $date = @YEAR & '-' & @MON & '-' & @MDAY

	Return $date
EndFunc

Func Week()
	Local $info
	Switch @WDAY
		Case 1
			$info = '������'
		Case 2
			$info = '����һ'
		Case 3
			$info = '���ڶ�'
		Case 4
			$info = '������'
		Case 5
			$info = '������'
		Case 6
			$info = '������'
		Case 7
			$info = '������'
		Case Else
			$info = 'Error'
	EndSwitch
	
	Return $info
EndFunc

Func Surplus_day()
	Local $day
	If Mod(@YEAR, 4) == 0 And Mod(@YEAR, 100) <> 0 Or Mod(@YEAR, 400) == 0 Then
		$day = 366 - @YDAY
	Else
		$day = 365 - @YDAY
	EndIf
	
	Return $day
EndFunc

Func year()
	Local $y
	If Mod(@YEAR, 4) == 0 And Mod(@YEAR, 100) <> 0 Or Mod(@YEAR, 400) == 0 Then
		$y = '����(366)'
	Else
		$y = 'ƽ��(365)'
	EndIf
	
	Return $y
EndFunc