SuperStrict

Framework brl.max2d
Import rigz.entity
Import rigz.tweener
Import brl.pngloader

SetGraphicsDriver GLMax2DDriver()

Graphics 800, 600

'set up a type that extends tlEntity
Type tAstralBody Extends tlEntity
	
	'create an update method that uses capture to store the old entity values for tweening
	Method update()
		capture()
		
		'call the main update method
		Super.update()
	End Method

End Type

'setup some locals for our solar system
Local Sun:tAstralBody = New tAstralBody
Local Earth:tAstralBody = New tAstralBody
Local Moon:tAstralBody = New tAstralBody
Local Moonlet:tAstralBody = New tAstralBody

sun.setsprite(LoadSprite("sun.png",,, , True))
earth.setsprite(LoadSprite("earth.png",,, , True))
moon.setsprite(LoadSprite("moon.png",,, , True))
moonlet.setsprite(LoadSprite("moon.png",,, , True))
sun.SetHandleX(-100)
sun.SetHandleY(-100)
sun.SetentityScale(.75, .75)
sun.SetAutoCenter(False)
sun.SetZ(0.5)
'add the earth to the sun as a child
sun.addchild(earth)
'set the suns postion
sun.SetPosition(400, 300)
'call capture so there's no tweening at the start
sun.capture()
'add the moon to the earth as a child
earth.addchild(moon)

'as the earth is parented to the sun, its position will be relative to the sun.
'set x will set the earths position 250 pixels to the sun's right
earth.setx(250)
'scale the earth sprite down by half
earth.SetentityScale(0.5, 0.5)
earth.capture()
earth.SetHandleX(-100)
earth.SetHandleY(100)
earth.name = "earth"
earth.SetAutoCenter(False)


'set the moon 75 pixels to the right of the earth
moon.setx(75)
'scale it down to a quarter of its size
moon.SetentityScale(0.25, 0.25)
moon.capture()

moonlet.SetX(25)
moonlet.SetEntityScale(0.1, 0.1)
moonlet.Capture
moonlet.SetSpeed(25)
moonlet.name = "Moonlet"
moon.AddChild(moonlet)

sun.SetRadiusCalculate(True)

'set up a tweener using the tweener module
Local tweener:tTweener = New tTweener.Create(30)
SetUpdateFrequency(30)

'main loop
While Not KeyDown(KEY_ESCAPE)
	Cls
	
	'update the tweener to get the current tween value
	tweener.Update
	
	'logic update loop
	For Local c:Int = 0 To tweener.getFrameTicks()
		'update the sun, which will update its children. For this reason there
		'is no need to update the earth or the moon as the sun will did it for us
		tweener.UpdateExecutionTime()
		sun.update()
		'rotate the sun and the earth
		sun.rotate(1)
		earth.rotate(-5)
		moon.Rotate(2.5)
		If KeyDown(KEY_SPACE) moonlet.SetSpeed(0)
	Next
	
	'draw them all to the screen
	sun.render(1)
	'sun.DrawBoundingBox()
	sun.DrawEntityBoundary()
	earth.DrawentityBoundary()
	moon.DrawEntityBoundary()
	moonlet.DrawEntityBoundary()
	
	Flip 0
	
Wend
