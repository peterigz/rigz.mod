SuperStrict

Import rigz.Tweener

SetGraphicsDriver GLMax2DDriver()

Graphics (800, 600, 0)

Global Tweener:tTweener = New tTweener.Create(10)

'A little test oval we can move about the screen
Type Testoval
	Field x:Float
	Field oldx:Float
	
	'The speed should be measured in pixels per second as the number will be divided be the current updatetime.
	Field speed:Float = 200
	
	Method Create:Testoval()
		Return New Testoval
	End Method
	
	Method update()
		'capture the old coordinate so that we have something to tween with
		capture()
		'divide the speed by the updatefrequency to get the proper pixels per second value and update x
		X:+speed / Tweener.UpdateFrequency
		'Bounce the oval off the side of the screens
		If x > GraphicsWidth() speed = -speed
		If x < 0 speed = -speed
	End Method
	
	'render the oval
	Method Render(tween:Float)
		'work out the interpolated position using the tweenvalues function in the tweener
		Local TweenedX:Float = Tweener.TweenValues(oldX, X, tween)
		'draw the tweened oval
		DrawOval TweenedX - 10, 200 - 25, 50, 50
		'and draw and untweened oval for comparison
		DrawOval X - 10, 300 - 25, 50, 50
	End Method
	
	'method to capture the old coordinates
	Method capture()
		oldx = x
	End Method
End Type

Local oval:Testoval = New Testoval.Create()

'Our main loop
While Not KeyDown(KEY_ESCAPE)
	
	Cls
		
	'here is the timing code, update the tweener to get the number of ticks for this loop
	Tweener.Update()
	
	For Local Ticks:Int = 1 To Tweener.FrameTicks
		'Update the execution time for the tweener
		Tweener.UpdateExecutionTime()
		oval.update()
	Next
	
	'Draw the oval
	oval.Render(Tweener.Tween)
		
	Flip 0
	
Wend
