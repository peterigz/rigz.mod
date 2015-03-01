Rem
	bbdoc:	Fixed timing object for tweening animation
EndRem
Module rigz.tweener
ModuleInfo "Author: Peter J. Rigby"
ModuleInfo "Copyright: Peter J. Rigby 2009"
ModuleInfo "Purpose: Easily implement fixed rate timing code to your apps/games"
ModuleInfo "Version: v1.0"

ModuleInfo "History v1.03: Added GetTween now returns tween like it's supposed to!"
ModuleInfo "History v1.02: Added GetFps() Method for finding out the current FPS of the game/app using it"
ModuleInfo "History v1.01: Fixed create method so it now returns self - thanks redspark!"
ModuleInfo "History v1.00: 11th April 2009 - Initial Version"

rem
	bbdoc: The tweener type
	about: By creating a tweener you can use it to control how many frames per second your game/app logic updates but let the stuff on screen be
			drawn as many times as possible, interpolating between each position to get very smooth results.
end rem
Type tTweener

	Field UpdateFrequency:Double
	Field UpdateTime:Double
	Field Ticker:Double
	
	Field FrameTicks:Int
	Field Tween:Double
	
	Field fpscounter:Int								'Just some fps counters
	Field fps:Int
	Field fpstime:Int = MilliSecs()
	Field fpsdiff:Int
	
	rem
		bbdoc: Create a tweener
		returns: a new tTweener object
		about: Pass the frequency that you want your app to update every second. 30 = 30 updates per second
	end rem	
	Method Create:tTweener(_UpdateFrequency:Float)
		UpdateFrequency = _UpdateFrequency
		UpdateTime = 1000 / UpdateFrequency
		Ticker = MilliSecs() - UpdateTime
		fpstime = MilliSecs()
		Return Self
	End Method
	
	rem
		bbdoc: Keep a track of the execution time
		about: This command needs to be called inside the logic update loop
	end rem
	Method UpdateExecutionTime()
		Ticker:+UpdateTime
	End Method

	rem
		bbdoc: Update the tweener
		about: This needs to be called just before the logic update loop. It basically calculates how many logic updates need to be made this frame, if at all.
	end rem
	Method Update()
	
		Local TimeElapsed:Float

		Repeat
			TimeElapsed = MilliSecs() - Ticker
		Until TimeElapsed
		
		If TimeElapsed > 200
			TimeElapsed = 200
			Ticker = MilliSecs()
		End If
		
		FrameTicks = TimeElapsed / UpdateTime
		
		Tween = Float(TimeElapsed Mod UpdateTime) / UpdateTime
		
	End Method
	rem
		bbdoc: Interpolate between 2 values
		returns: The interpolated value
		about: You can use this function to find out where something should be drawn based on its old and new positions
	end rem
	Function TweenValues:Float(oldValue:Float, value:Float, tween:Float)
		Return oldValue + (value - oldValue) * tween
	End Function
	rem
		bbdoc: Get the current number of frame ticks
		about: this gets the current number of frames you need to update for your for..next loop.
	end rem
	Method getFrameTicks:Int()
		Return frameticks
	End Method
	rem
		bbdoc: Get the current tween value
		about: You need the tween value to know how much you need to interpolate between old and new positions.
	end rem
	Method getTween:Float()
		Return tween
	End Method
	
	rem
		bbdoc: Get the current FPS
	end rem
	Method GetFps:Int()
		fpsdiff = MilliSecs() - fpstime
		If fpsdiff >= 1000
			fps = fpscounter
			fpscounter = 0
			fpstime = MilliSecs()
		Else
			fpscounter:+1
		End If
		Return fps
	End Method
	Rem
		bbdoc: Get the UpdateFrequency value in this tTweener object.
	End Rem
	Method GetUpdateFrequency:Double()
		Return UpdateFrequency
	End Method
	Rem
		bbdoc: Set the UpdateFrequency value for this tTweener object.
	End Rem
	Method SetUpdateFrequency(Value:Double)
		UpdateFrequency = Value
		UpdateTime = 1000 / UpdateFrequency
	End Method
	Rem
		bbdoc: Get the UpdateTime value in this tTweener object.
	End Rem
	Method GetUpdateTime:Double()
		Return UpdateTime
	End Method
	Rem
		bbdoc: Set the UpdateTime value for this tTweener object.
	End Rem
	Method SetUpdateTime(Value:Double)
		UpdateTime = Value
	End Method

End Type

Function TweenValues:Float(oldValue:Float, value:Float, tween:Float)
	Return oldValue + (value - oldValue) * tween
End Function