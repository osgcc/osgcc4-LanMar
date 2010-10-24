#Include "fbgfx.bi"
#Define dGREY RGB(127, 127, 127)
#Define dRED RGB(255, 0, 0)
#Define dWHITE RGB(255, 255, 255)
#Define dYELLOW RGB(255, 255, 0)

Declare Function Distance(x1 As Double, x2 As Double, y1 As Double, y2 As Double) As Double
Declare Function Main() As Integer

Declare Sub DrawScreen()
Declare Sub GameOver()
Declare Sub InitCities()
Declare Sub InitEnemies()
Declare Sub InitGame()
Declare Sub InitLevel()
Declare Sub InitPlayer()
Declare Sub MouseEvents()
Declare Sub UpdateCities()
Declare Sub UpdateEnemy()
Declare Sub UpdateFire()
Declare Sub UpdateGame()

Const cEXPLODECOUNT = 60
Const cFPS = 60
Const cFALSE = 0
Const cNUMCITIES = 6
Const cNUMFIRES = 10
Const cTRUE = 1

Type typeCity
	alive As Integer
	explode As Integer
	explodeCount As Integer
	explodeRad As Double
	x As Integer
	y As Integer
	w As Integer
	h As Integer
End Type
Type typeEnemy
	alive As Integer
	dirX As Double
	dirY As Double
	explode As Integer
	explodeCount As Integer
	explodeRad As double
	fx As Double
	fy As Double
	speed As Double
	sx As Double
	sy As Double
	variant As Integer
	
	x As Double
	y As Double
	w As Integer
	h As Integer
End Type
Type typeFire
	cx As Double
	cy As Double
	dirX As Double
	dirY As Double
	explode As Integer
	explodeCount As Integer
	explodeRad As double
	fired As Integer
	fx As Double
	fy As Double
	sx As Double
	sy As Double
	speed As Double
End Type
Type typeLevel
	level As Integer
	numCitiesAlive As Integer
	numEnemiesAlive As Integer
	numEnemiesTotal As Integer
End Type
Type typeMouse
	x As Integer
	y As Integer
	w As Integer
	h As Integer
End Type
Type typePlayer
	cities As Integer
	lives As Integer
	fires As Integer
	
	x As Integer
	y As Integer
	w As Integer
	h As Integer
End Type
Type typeScreen
	w As Integer
	h As Integer
End Type

Dim Shared city(0 To cNUMCITIES - 1) As typeCity
Dim Shared cityImg(0 To cNUMCITIES - 1) As Any Ptr
Dim Shared fire(0 To cNUMFIRES - 1) As typeFire
Dim Shared level As typeLevel
Dim Shared mouse As typeMouse
Dim Shared mouseImg As Any Ptr
Dim Shared player As typePlayer
Dim Shared playerImg As Any Ptr
Dim Shared scrnInfo As typeScreen

ReDim Shared enemy(0 To 1) As typeEnemy
ReDim Shared enemyImg(0 To 1) As Any ptr

Screen 18, 32, 2, fb.GFX_FULLSCREEN
Randomize Timer
Main()


Function Main() As Integer
	'Print ATan2(1, 1), Cos(ATan2(1, 1))
	'Sleep : End
	
	InitGame()
	Do
		MouseEvents()
		UpdateGame()
		DrawScreen()
	Loop Until UCase(InKey$) = "Q"
	
	Return cTrue
	
End Function

Function Distance(x1 As Double, x2 As Double, y1 As Double, y2 As Double) As Double
	Dim d As Double
	
	Return Abs(Sqr(((x2 - x1) ^ 2) + ((y2 - y1) ^ 2)))
	
End Function

Sub GameOver()
	ScreenSet (0, 0) : Cls
	Draw String (scrnInfo.w / 2 - 80, scrnInfo.h / 2 - 32), "MARTIANS WON! YOU SUCK!"
	Draw String (scrnInfo.w / 2 - 32, scrnInfo.h / 2 - 16), "GAME OVER"
	Draw String (scrnInfo.w / 2 - 88, scrnInfo.h / 2 + 16), "Last Level Completed: " & level.level
	Sleep 5000
	End
End Sub

Sub DrawScreen()
	Dim col As Integer
	Dim index As Integer
	
	ScreenSync
	
	col = 255
	For index = scrnInfo.h To scrnInfo.h - player.h \ 2 Step -1
		Line (0, index)-(scrnInfo.w, index), RGB(0, col, 0)
		col -= 8 
	Next
	col = 255
	For index = scrnInfo.h - player.h \ 2 To scrnInfo.h - player.h \ 2 - 255 Step -1
		Line (0, index)-(scrnInfo.w, index), RGB(0, 0, col)
		col -= 1
	Next
	
	Put (player.x, player.y), playerImg, Trans
	
	For index = 0 To cNUMCITIES - 1
		If (city(index).alive = cTRUE) Then
			If (city(index).explode = cFALSE) Then
				Put (city(index).x, city(index).y), cityImg(index), Trans
			Else
				Circle (city(index).x + city(index).w \ 2, city(index).y + city(index).h \ 2), city(index).explodeRad, RGB(Rnd * 255, Rnd * 255, Rnd * 255), , , , F
			EndIf
		EndIf
	Next
	
	For index = 0 To level.numEnemiesTotal - 1
		If (enemy(index).alive = cTRUE) Then
			If (enemy(index).explode = cFALSE) Then
				Put (enemy(index).x, enemy(index).y), enemyImg(index), Trans
			Else
				Circle (enemy(index).x + enemy(index).w \ 2, enemy(index).y + enemy(index).h \ 2), enemy(index).explodeRad, RGB(Rnd * 63, Rnd * 255, Rnd * 63), , , , F
			EndIf
		EndIf
		
	Next
	
	For index = 0 To cNUMFIRES - 1
		If (fire(index).fired = cTRUE And fire(index).explode = cFALSE) Then
			Line (fire(index).sx, fire(index).sy)-(fire(index).cx, fire(index).cy), dRED
		
		elseIf (fire(index).fired = cTRUE And fire(index).explode = cTRUE) Then
			Circle (fire(index).cx, fire(index).cy), fire(index).explodeRad, RGB(Rnd * 255, Rnd * 63, 0), , , , F
		End If
	Next
	
	Put (mouse.x, mouse.y), mouseImg, Trans
	
	col = 255
	For index = 0 To 16
		Line (0, index)-(80, index), RGB(col * .75 , col * .50, col * .25)
		Line (scrnInfo.w - 80, index)-(scrnInfo.w, index), RGB(col * .75 , col * .50, col * .25)
		col -= 12
	Next
	Draw String (4, 1), "Fires: " & player.fires, RGB(255, 255, 200)
	Draw String (scrnInfo.w - 75, 1), "Level: " & level.level, RGB(255, 255, 200)

	ScreenCopy 1, 0
	ScreenSet 1, 0
	Cls
End Sub

Sub InitCities()
	Dim cw As Integer = 40
	Dim ch As Integer = 29
	Dim index As Integer
	
	For index = 0 To cNUMCITIES \ 2 - 1
		city(index).alive = cTRUE
		city(index).x = ((scrnInfo.w \ 2) \ (cNUMCITIES \ 2)) * (index)
		city(index).y = scrnInfo.h - ch - 4
		city(index).w = cw
		city(index).h = ch
		city(index).explode = cFALSE
		city(index).explodeCount = 90
		city(index).explodeRad = city(index).w + city(index).h
		cityImg(index) = ImageCreate(cw, ch)
		BLoad "cityR.bmp", cityImg(index)
		'Line cityImg(index), (0, 0)-(cw - 1, ch - 1), dWHITE, B
	Next
	For index = cNUMCITIES - 1 To cNUMCITIES \ 2 Step -1
		city(index).alive = cTRUE
		city(index).x = (((scrnInfo.w \ 2) \ (cNUMCITIES \ 2))  * (index + 1)) - cw 
		city(index).y = scrnInfo.h - ch - 4
		city(index).w = cw
		city(index).h = ch
		city(index).explode = cFALSE
		city(index).explodeCount = 90
		city(index).explodeRad = city(index).w + city(index).h
		cityImg(index) = ImageCreate(cw, ch)
		BLoad "cityR.bmp", cityImg(index)
		'Line cityImg(index), (0, 0)-(cw - 1, ch - 1), dWHITE, B
	Next
End Sub

Sub InitEnemies()
	Dim index As Integer
	
	ReDim enemy(0 To level.numEnemiesTotal - 1)
	ReDim enemyImg(0 To level.numEnemiesTotal - 1)

	For index = 0 To level.numEnemiesTotal - 1
		enemy(index).alive = cTRUE
		enemy(index).speed = .5 + ((Rnd * level.level + 1) / 10)
		enemy(index).w = 16
		enemy(index).h = 16
		enemy(index).fx = Rnd * scrnInfo.w
		enemy(index).fy = scrnInfo.h
		enemy(index).sx = (Rnd * (scrnInfo.w - enemy(index).w * 2)) + enemy(index).w
		enemy(index).sy = -1 * (Rnd * (100 + level.level * 10)) * enemy(index).speed
		enemy(index).dirX = cos(ATan2(enemy(index).fy - enemy(index).sy, enemy(index).fx - enemy(index).sx))
		enemy(index).dirY = sin(ATan2(enemy(index).fy - enemy(index).sy, enemy(index).fx - enemy(index).sx))
		enemy(index).variant = 1
		enemy(index).x = enemy(index).sx - enemy(index).w
		enemy(index).y = enemy(index).sy - enemy(index).h
		enemy(index).explode = cFALSE
		enemy(index).explodeCount = cEXPLODECOUNT
		enemy(index).explodeRad = enemy(index).w + (level.level / 2)
		enemyImg(index) = ImageCreate(enemy(index).w, enemy(index).h)
		Line enemyImg(index), (0, 0)-(enemy(index).w - 1, enemy(index).h - 1), dWHITE, b
	Next
	
End Sub

Sub InitGame()
	ScreenInfo scrnInfo.w, scrnInfo.h
	
	SetMouse ( , , 0)
	mouse.w = 16
	mouse.h = 16
	mouseImg = ImageCreate(mouse.w, mouse.h)
	Line mouseImg, (0, mouse.h \ 2)-(mouse.w - 1, mouse.h \ 2), dYELLOW
	Line mouseImg, (mouse.w \ 2, 0)-(mouse.w \ 2, mouse.h - 1), dYELLOW
	
	level.level = 0
	level.numCitiesAlive = cNUMCITIES
	level.numEnemiesAlive = 0
	level.numEnemiesTotal = 0
	
	InitCities()
	InitPlayer()
	
	InitLevel()
End Sub

Sub InitLevel()
	Dim index As Integer
	If (level.numCitiesAlive <= 0) Then
		GameOver()
	EndIf
	If (level.level <> 0) Then

			For index = 0 To cNUMFIRES - 1
				fire(index).explode = cFALSE
				fire(index).explodeCount = cEXPLODECOUNT
				fire(index).explodeRad = 32 - (level.level / 4)
				fire(index).fired = cFALSE
				fire(index).speed = 1 - (level.level / 8)
				fire(index).sx = player.x + player.w \ 2
				fire(index).sy = player.y
				fire(index).cx = fire(index).sx
				fire(index).cy = fire(index).sy
			Next

			level.numEnemiesTotal = level.level + (Rnd * (level.level \ 4))
			level.numEnemiesAlive = level.numEnemiesTotal
			player.fires = level.numEnemiesTotal * 4 - (level.level / 2)
			If (player.fires < level.numEnemiesTotal) Then player.fires = level.numEnemiesTotal
			InitEnemies()
	
	
		ScreenSet (0, 0) : Cls
		Draw String (scrnInfo.w / 2 - 32, scrnInfo.h / 2 - 16), "Level " & level.level
		Sleep 2500
	EndIf
End Sub

Sub InitPlayer()
	Dim pw As Integer = 32
	Dim ph As Integer = 48
	
	playerImg = ImageCreate(pw, ph)
	Line playerImg, (0, 0)-(pw - 1, ph - 1), dWHITE, B
	player.cities = cNUMCITIES
	player.x = (scrnInfo.w \ 2) - (pw \ 2)
	player.y = scrnInfo.h - ph - 8
	player.w = pw
	player.h = ph
	player.fires = 0
End Sub

Sub MouseEvents()
	Dim button As Integer
	Dim ind As Integer
	Static index As Integer = 0
	
	Static ready As Integer = cFALSE
	GetMouse(mouse.x, mouse.y, , button)

	If (button = FB.BUTTON_LEFT And ready = cFALSE) Then
		ready = cTRUE
	EndIf
	If (button <> FB.BUTTON_LEFT And ready = cTRUE) Then
		If (mouse.y < player.y - 8) Then
			ready = cFALSE
			For ind = 0 To cNUMFIRES - 1
				If (fire(ind).fired <> cTRUE And player.fires > 0) Then
					player.fires -= 1
					fire(ind).fired = cTRUE
					fire(ind).fx = mouse.x + mouse.w \ 2
					fire(ind).fy = mouse.y + mouse.h \ 2
					fire(ind).dirX = (fire(ind).fx - fire(ind).sx) / cFPS
					fire(ind).dirY = (fire(ind).fy - fire(ind).sy) / cFPS
					fire(ind).cx += fire(ind).dirX
					fire(ind).cy += fire(ind).dirY
					index += IIf(index = 9, -9, 1)
				
					Exit For
				EndIf
			Next
		Else
			ready = cFALSE
		EndIf
	EndIf
End Sub

Sub UpdateCities()
	Dim index As Integer
	
	For index = 0 To cNUMCITIES - 1
		If (city(index).alive= cTRUE) Then
			If (city(index).explode = cTRUE) Then
				If (city(index).explodeCount > 0) Then
					city(index).explodeCount -= 1
				Else
					city(index).alive = cFALSE
					level.numCitiesAlive -= 1
				EndIf
			EndIf
		EndIf
		
	Next
	
End Sub

Sub UpdateEnemy()
	Dim ind As Integer
	Dim index As Integer
	Dim dist As Double
	
	For index = 0 To level.numEnemiesTotal - 1
		If (enemy(index).alive = cTRUE) Then
			If (enemy(index).explode = cFALSE) Then
				enemy(index).x += enemy(index).dirX * enemy(index).speed
				enemy(index).y += enemy(index).dirY * enemy(index).speed
				If (enemy(index).y > scrnInfo.h - 8) Then enemy(index).y = scrnInfo.h - 8
			
				'Collision dection -> Player's missles on Enemy
				For ind = 0 To cNUMFIRES - 1
					If (fire(ind).fired = cTRUE And fire(ind).explode = cTRUE) Then
						dist = Distance(fire(ind).cx, enemy(index).x, fire(ind).cy, enemy(index).y)
						If (dist <= fire(ind).explodeRad) Then
							enemy(index).explode = cTRUE
							Exit For
						EndIf
					EndIf
				Next
				
				'Collision dection -> Enemy on Cities
				If (enemy(index).explode = cFALSE) Then
					If (enemy(index).y >= scrninfo.h - city(0).h \ 2) Then
						enemy(index).explode = cTRUE
						For ind = 0 To cNUMCITIES - 1
							dist = Distance(city(ind).x + city(ind).w \ 2, enemy(index).x, city(ind).y + city(ind).h \ 2, enemy(index).y)
							If (dist <= enemy(index).explodeRad) Then
								city(ind).explode = cTRUE
							EndIf
						Next
					EndIf
				EndIf
				
			Else
				enemy(index).explodeCount -= 1
				If (enemy(index).explodeCount = 0) Then
					enemy(index).alive = cFALSE
					level.numEnemiesAlive -= 1
				EndIf
			End If
		End If
	Next
	
End Sub

Sub UpdateFire()
	Dim index As Integer
	
	For index = 0 To cNUMFIRES - 1
		If (fire(index).fired = cTRUE) Then
			If (fire(index).cy < fire(index).fy) Then
				fire(index).explode = cTRUE
				fire(index).explodeCount -= 1
				If (fire(index).explodeCount = 0) Then
					fire(index).cx = fire(index).sx
					fire(index).cy = fire(index).sy
					fire(index).explode = cFALSE
					fire(index).explodeCount = cEXPLODECOUNT
					fire(index).fired = cFALSE
				EndIf
			Else
				fire(index).cx += fire(index).dirX
				fire(index).cy += fire(index).dirY
			EndIf
		EndIf
	Next
End Sub

Sub UpdateGame()
	Dim index As Integer
	
	If (level.numCitiesAlive <= 0) Then
		GameOver()
	ElseIf (level.numEnemiesAlive <> 0) Then
		UpdateCities()
		UpdateEnemy()
		UpdateFire()	
	Else
		index = 60
		For index = 0 To 60	'Bug fixes where city exploding is still shown on next level
			UpdateCities()
		Next
		level.level += 1
		InitLevel()
	EndIf
End Sub
