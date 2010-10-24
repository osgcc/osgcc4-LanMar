#Include "fbgfx.bi"
#Define dGREY RGB(127, 127, 127)
#Define dWHITE RGB(255, 255, 255)

Declare Function Main() As Integer

Declare Sub DrawScreen()
Declare Sub InitCities()
Declare Sub InitEnemies()
Declare Sub InitGame()
Declare Sub InitLevel()
Declare Sub InitPlayer()
Declare Sub MouseEvents()
Declare Sub UpdateEnemy()
Declare Sub UpdateFire()

Const cFALSE = 0
Const cNUMCITIES = 6
Const cNUMFIRES = 10
Const cTRUE = 1

Type typeCity
	x As Integer
	y As Integer
	w As Integer
	h As Integer
End Type
Type typeEnemy
	alive As Integer
	dirX As Double
	dirY As Double
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
	fired As Integer
	fx As Double
	fy As Double
	sx As Double
	sy As Double
	speed As Double
End Type
Type typeLevel
	level As Integer
	numEnemies As Integer
	
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

Dim Shared city(0 To cNUMCITIES - 1) As typeCity
Dim Shared cityImg(0 To cNUMCITIES - 1) As Any Ptr
Dim Shared fire(0 To cNUMFIRES - 1) As typeFire
Dim Shared level As typeLevel
Dim Shared mouse As typeMouse
Dim Shared mouseImg As Any Ptr
Dim Shared player As typePlayer
Dim Shared playerImg As Any Ptr

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
		InitLevel()
		Do
			MouseEvents()
			UpdateEnemy()
			UpdateFire()
			DrawScreen()
			
			If (UCase(InKey$) = "Q") Then
				End
			EndIf			
		Loop While (cTRUE)
	Loop Until UCase(InKey$) = "Q"
	
	Return cTrue
	
End Function


Sub DrawScreen()
	Dim index As Integer
	
	ScreenSync
	
	Put (player.x, player.y), playerImg, Trans
	
	For index = 0 To cNUMCITIES - 1
		Put (city(index).x, city(index).y), cityImg(index), Trans
	Next
	
	For index = 0 To level.numEnemies - 1
		Put (enemy(index).x, enemy(index).y), enemyImg(index), Trans
	Next
	
	For index = 0 To cNUMFIRES - 1
		If (fire(index).fired = cTRUE) Then
			Line (fire(index).sx, fire(index).sy)-(fire(index).cx, fire(index).cy), dWHITE
		EndIf
	Next
	
	Put (mouse.x, mouse.y), mouseImg, Trans
	
	'Draw String (0, 0), "Test"

	ScreenCopy 1, 0
	ScreenSet 1, 0
	Cls
End Sub

Sub InitCities()
	Dim cw As Integer = 32
	Dim ch As Integer = 16
	Dim index As Integer
	Dim w As Integer
	Dim h As Integer
	
	ScreenInfo w, h
	
	For index = 0 To cNUMCITIES \ 2 - 1
		city(index).x = ((w \ 2) \ (cNUMCITIES \ 2)) * (index)
		city(index).y = h - ch
		city(index).w = cw
		city(index).h = ch
		cityImg(index) = ImageCreate(cw, ch)
		Line cityImg(index), (0, 0)-(cw - 1, ch - 1), dWHITE, B
	Next
	For index = cNUMCITIES - 1 To cNUMCITIES \ 2 Step -1
		city(index).x = (((w \ 2) \ (cNUMCITIES \ 2))  * (index + 1)) - cw 
		city(index).y = h - ch
		city(index).w = cw
		city(index).h = ch
		cityImg(index) = ImageCreate(cw, ch)
		Line cityImg(index), (0, 0)-(cw - 1, ch - 1), dWHITE, B
	Next
End Sub

Sub InitEnemies()
	Dim index As Integer
	Dim w As Integer
	Dim h As Integer
	
	ScreenInfo w, h
	
	ReDim enemy(0 To level.numEnemies - 1)
	ReDim enemyImg(0 To level.numEnemies - 1)

	For index = 0 To level.numEnemies - 1
		enemy(index).alive = cTRUE
		enemy(index).speed = .5
		enemy(index).w = 16
		enemy(index).h = 16
		enemy(index).fx = Rnd * w
		enemy(index).fy = h
		enemy(index).sx = (Rnd * (w - enemy(index).w * 2)) + enemy(index).w
		enemy(index).sy = 0
		enemy(index).dirX = cos(ATan2(enemy(index).fy - enemy(index).sy, enemy(index).fx - enemy(index).sx))
		enemy(index).dirY = sin(ATan2(enemy(index).fy - enemy(index).sy, enemy(index).fx - enemy(index).sx))
		enemy(index).variant = 1
		enemy(index).x = enemy(index).sx - enemy(index).w
		enemy(index).y = enemy(index).sy - enemy(index).h
		enemyImg(index) = ImageCreate(enemy(index).w, enemy(index).h)
		Line enemyImg(index), (0, 0)-(enemy(index).w - 1, enemy(index).h - 1), dWHITE, b
	Next
	
End Sub

Sub InitGame()
	SetMouse ( , , 0)
	mouse.w = 16
	mouse.h = 16
	mouseImg = ImageCreate(mouse.w, mouse.h)
	Line mouseImg, (0, 0)-(mouse.w - 1, mouse.h - 1), dWHITE, B
	
	level.level = 1
	
	InitCities()
	InitPlayer()
End Sub

Sub InitLevel()
	Dim index As Integer
	
	Select Case (level.level)
		Case 1
			For index = 0 To cNUMFIRES - 1
				fire(index).fired = cFALSE
				fire(index).speed = 1
				fire(index).sx = player.x + player.w \ 2
				fire(index).sy = player.y
				fire(index).cx = fire(index).sx
				fire(index).cy = fire(index).sy
			Next
			level.numEnemies = 5
			player.fires = 15
			InitEnemies()
	End Select
End Sub

Sub InitPlayer()
	Dim pw As Integer = 32
	Dim ph As Integer = 48
	Dim w As Integer
	Dim h As Integer
	
	ScreenInfo w, h
	
	playerImg = ImageCreate(pw, ph)
	Line playerImg, (0, 0)-(pw - 1, ph - 1), dWHITE, B
	player.cities = cNUMCITIES
	player.x = (w \ 2) - (pw \ 2)
	player.y = h - ph
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
		ready = cFALSE
		For ind = 0 To cNUMFIRES - 1
			If (fire(ind).fired <> cTRUE And player.fires > 0) Then
				player.fires -= 1
				fire(ind).fired = cTRUE
				fire(ind).fx = mouse.x + mouse.w \ 2
				fire(ind).fy = mouse.y + mouse.h \ 2
				fire(ind).dirX = (fire(ind).fx - fire(ind).sx) / 60
				fire(ind).dirY = (fire(ind).fy - fire(ind).sy) / 60
				fire(ind).cx += fire(ind).dirX
				fire(ind).cy += fire(ind).dirY
				index += IIf(index = 9, -9, 1)
				
				
				Exit For
			EndIf
		Next
	EndIf
End Sub

Sub UpdateEnemy()
	Dim index As Integer
	
	For index = 0 To level.numEnemies - 1
		enemy(index).x += enemy(index).dirX * enemy(index).speed
		enemy(index).y += enemy(index).dirY * enemy(index).speed
	Next
	
End Sub

Sub UpdateFire()
	Dim index As Integer
	
	For index = 0 To cNUMFIRES - 1
		If (fire(index).fired = cTRUE) Then
			fire(index).cx += fire(index).dirX
			fire(index).cy += fire(index).dirY
			If (fire(index).cy < fire(index).fy) Then
				fire(index).fired = cFALSE
				fire(index).cx = fire(index).sx
				fire(index).cy = fire(index).sy
			EndIf
		EndIf
	Next
End Sub
