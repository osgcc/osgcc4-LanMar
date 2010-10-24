#Include "fbgfx.bi"
#Define dGREY RGB(127, 127, 127)
#Define dWHITE RGB(255, 255, 255)

Declare Function Main() As Integer

Declare Sub DrawScreen()
Declare Sub InitCities()
Declare Sub InitGame()
Declare Sub InitPlayer()

Const cFALSE = 0
Const cNUMCITIES = 6
Const cTRUE = 1

Type typeCity
	x As Integer
	y As Integer
	w As Integer
	h As Integer
End Type
Type typePlayer
	cities As Integer
	lives As Integer
	x As Integer
	y As Integer
	w As Integer
	h As Integer
End Type

Dim Shared player As typePlayer
Dim Shared playerImg As Any Ptr
Dim Shared city(0 To 5) As typeCity
Dim Shared cityImg(0 To 5) As Any Ptr

Screen 18, 32, 2, fb.GFX_FULLSCREEN

Main()


Function Main() As Integer
	
	InitGame()
	Do
		DrawScreen()
	
	Loop Until UCase(InKey$) = "Q"
	
	Return cTrue
End Function


Sub DrawScreen()
	Dim index As Integer
	
	ScreenSync
	
	Put (player.x, player.y), playerImg, PSet
	
	For index = 0 To cNUMCITIES - 1
		Put (city(index).x, city(index).y), cityImg(index), PSet
	Next
	
End Sub

Sub InitGame()
	InitCities()
	InitPlayer()
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
End Sub
