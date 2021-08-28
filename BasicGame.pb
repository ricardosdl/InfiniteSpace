Global ExitGame.a = #False
Enumeration SpriteResources
  #SpaceShip
  #SpaceBackgorund
EndEnumeration

Structure TRect
  x.f
  y.f
  w.f
  h.f
EndStructure

Structure TCamera Extends TRect
  
EndStructure

Structure TSpaceShip Extends TRect
  VelX.f
  VelY.f
  Angle.f
EndStructure

Global Event, ElapsedTimneInS.f, LastTimeInMs, Time.f = 0
Global Camera.TCamera, SpaceShip.TSpaceShip, CameraFrame.TRect




Procedure LoadSprites()
  LoadSprite(#SpaceShip, "SpaceShip.png", #PB_Sprite_AlphaBlending)
  LoadSprite(#SpaceBackgorund, "SpaceBackground.png", #PB_Sprite_AlphaBlending)
EndProcedure

Procedure UpdateCamera()
  ;camera code, camera is position is based on the sapceshipt position
  ;Camera\x = (SpaceShip\x + SpaceShip\w / 2) - Camera\w / 2
  ;Camera\y = (SpaceShip\y + SpaceShip\h / 2) - Camera\h / 2
  Camera\x = (CameraFrame\x + CameraFrame\w / 2) - Camera\w / 2
  Camera\y = (CameraFrame\y + CameraFrame\h / 2) - Camera\h / 2
EndProcedure


Procedure StartGame()
  SpaceShip\x = ScreenWidth() / 2
  SpaceShip\y = ScreenHeight() / 2
  
  SpaceShip\w = SpriteWidth(#SpaceShip)
  SpaceShip\h = SpriteHeight(#SpaceShip)
  SpaceShip\VelX = 0
  SpaceShip\VelY = 0
  SpaceShip\Angle = 0
  
  Camera\w = ScreenWidth()
  Camera\h = ScreenHeight()
  
  
  CameraFrame\w = ScreenWidth() / 3
  CameraFrame\h = ScreenHeight() / 3
  CameraFrame\x = ScreenWidth() / 2 - (CameraFrame\w / 2)
  CameraFrame\y = ScreenHeight() / 2 - (CameraFrame\h / 2)
  
  UpdateCamera()
  
  
EndProcedure

Procedure UpdateShip(Elapsed.f)
  If KeyboardPushed(#PB_Key_Left)
    SpaceShip\Angle - 180 * Elapsed
  EndIf
  
  If KeyboardPushed(#PB_Key_Right)
    SpaceShip\Angle + 180 * Elapsed
  EndIf
  
  If KeyboardPushed(#PB_Key_Up)
    SpaceShip\VelX = Cos(Radian(SpaceShip\Angle)) * 200
    SpaceShip\VelY = Sin(Radian(SpaceShip\Angle)) * 200
  Else
    SpaceShip\VelX = 0
    SpaceShip\VelY = 0
  EndIf
  
  SpaceShip\x + SpaceShip\VelX * Elapsed
  SpaceShip\y + SpaceShip\VelY * Elapsed
  
EndProcedure

Procedure.f Clamp(Value.f, Low.f, High.f)
  If Value < Low
    ProcedureReturn Low
  ElseIf Value > High
    ProcedureReturn High
  EndIf
  
  ProcedureReturn Value
  
EndProcedure


Procedure UpdateCameraFrame(Elapsed.f)
  Protected SpaceShipMiddleX.f = SpaceShip\x + SpaceShip\w / 2
  If SpaceShipMiddleX < CameraFrame\x
    CameraFrame\x = SpaceShipMiddleX
  EndIf
  
  If SpaceShipMiddleX > CameraFrame\x + CameraFrame\w
    CameraFrame\x = SpaceShipMiddleX - CameraFrame\w
  EndIf
  
  Protected SpaceShipMiddleY.f = SpaceShip\y + SpaceShip\h / 2
  If SpaceShipMiddleY < CameraFrame\y
    CameraFrame\y = SpaceShipMiddleY
  EndIf
  
  If SpaceShipMiddleY > CameraFrame\y + CameraFrame\h
    CameraFrame\y = SpaceShipMiddleY - CameraFrame\h
  EndIf
  
  
  ;CameraFrame\x = Clamp(CameraFrame\x, SpaceShipMiddleX, 
EndProcedure



Procedure UpdateGame(Elapsed.f)
  UpdateShip(Elapsed)
  UpdateCameraFrame(Elapsed)
  UpdateCamera()
EndProcedure

Procedure DrawSpaceShip()
  RotateSprite(#SpaceShip, SpaceShip\Angle, #PB_Absolute)
  DisplayTransparentSprite(#SpaceShip, SpaceShip\x - Camera\x, SpaceShip\y - Camera\y)
EndProcedure

Procedure.a AABBIsColliding(x1.f, y1.f, w1.f, h1.f, x2.f, y2.f, w2.f, h2.f)
  Protected RightAndLeft.a = Bool(x1 + w1 > x2 And x1 < x2 + w2)
  Protected TopAndBottom.a = Bool(y1 + h1 > y2 And y1 < y2 + h2)
  ProcedureReturn Bool(RightAndLeft And TopAndBottom)
EndProcedure

Procedure DrawBackground()
  Protected CameraQuadrantX = Camera\x / SpriteWidth(#SpaceBackgorund)
  Protected CameraQuadrantY = Camera\y / SpriteHeight(#SpaceBackgorund)
  
  Protected x, y
  For x = CameraQuadrantX - 1 To CameraQuadrantX + 1
    For y = CameraQuadrantY - 1 To CameraQuadrantY + 1
      Protected x1 = x * SpriteWidth(#SpaceBackgorund)
      Protected y1 = y * SpriteHeight(#SpaceBackgorund)
      
      If AABBIsColliding(x1, y1, SpriteWidth(#SpaceBackgorund), SpriteHeight(#SpaceBackgorund),
                         Camera\x, Camera\y, Camera\w, Camera\h)
        DisplayTransparentSprite(#SpaceBackgorund, x1 - Camera\x, y1 - Camera\y)
      EndIf
    Next
    
  Next x
  
  
  
EndProcedure

Procedure DrawCameraFrame()
  StartDrawing(ScreenOutput())
  DrawingMode(#PB_2DDrawing_Outlined)
  Box(CameraFrame\x - Camera\x, CameraFrame\y - Camera\y, CameraFrame\w, CameraFrame\h, #Red)
  StopDrawing()
EndProcedure



Procedure Draw()
  DrawBackground()
  ;draw space ship
  DrawSpaceShip()
  DrawCameraFrame()
EndProcedure

If InitSprite() = 0 Or InitKeyboard() = 0
  CompilerIf #PB_Compiler_Processor = #PB_Processor_JavaScript
    MessageRequester("Sprite system Or keyboard system can't be initialized", 0)
  CompilerElse
    MessageRequester("Error", "Sprite system or keyboard system can't be initialized", 0)
  CompilerEndIf
  End
EndIf


CompilerIf #PB_Compiler_Processor <> #PB_Processor_JavaScript
  UsePNGImageDecoder()
CompilerEndIf

Procedure RenderFrame()
  ElapsedTimneInS = (ElapsedMilliseconds() - LastTimeInMs) / 1000.0
  If ElapsedTimneInS >= 0.05;never let the elapsed time be higher than 20 fps
    ElapsedTimneInS = 0.05
  EndIf
  
  Repeat; Always process all the events to flush the queue at every frame
    Event = WindowEvent()
    Select Event
      Case #PB_Event_CloseWindow
        ExitGame = #True
    EndSelect
  Until Event = 0 ; Quit the event loop only when no more events are available
  
  ClearScreen(RGB(0, 0, 0))
  ExamineKeyboard()
  UpdateGame(ElapsedTimneInS)
  Draw()
  LastTimeInMs = ElapsedMilliseconds()
  FlipBuffers()
EndProcedure


If OpenWindow(0, 0, 0, 800, 600, "Infinite Space", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  If OpenWindowedScreen(WindowID(0), 0, 0, 800, 600, 0, 0, 0)
    LoadSprites()
    ;Start game code
    StartGame()
    LastTimeInMs = ElapsedMilliseconds()
    
    Repeat
      RenderFrame()
    Until ExitGame
    
  EndIf
EndIf