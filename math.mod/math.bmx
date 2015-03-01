'Copyright (c) 2009 Peter J Rigby
'
'Permission is hereby granted, free of charge, to any person obtaining a copy
'of this software and associated documentation files (the "Software"), to deal
'in the Software without restriction, including without limitation the rights
'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
'copies of the Software, and to permit persons to whom the Software is
'furnished to do so, subject to the following conditions:
'
'The above copyright notice and this permission notice shall be included in
'all copies or substantial portions of the Software.
'
'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
'THE SOFTWARE.

SuperStrict

rem
	bbdoc: Math module for general math functions
end rem
Module rigz.math
ModuleInfo "Author: Peter J. Rigby"
ModuleInfo "Copyright: Peter J. Rigby 2009"
ModuleInfo "Purpose: A General Math Module"
ModuleInfo "Version: v1"

Import brl.basic

rem
	bbdoc: get the direction from 1 point to another
	returns: Angle of difference
	about: Thanks to "Snarkbait" for this little code snippit
end rem
Function GetDirection:Float(fromx:Float, fromy:Float, tox:Float, toy:Float)

	Return (ATan2(toy - fromy, tox - fromx) + 450) Mod 360
	
End Function

rem
	bbdoc: Get the difference between 2 angles
end rem
Function AngleDifference:Float(Angle1:Float, Angle2:Float)
	Local diff:Float = Abs((angle1 + 180 - angle2) Mod 360 - 180)
	If diff > 180 Return Abs(diff - 360) Else Return diff
End Function

rem
	bbdoc: The distance between 1 point and another
	returns: The distance between the 2 points
end rem
Function GetDistance:Float(fromx:Float, fromy:Float, tox:Float, toy:Float, fast:Int = False)

	Local w:Float = tox - fromx
	Local h:Float = toy - fromy
	
	Return Sqr(w * w + h * h)
	
End Function
rem
	bbdoc: Gets the texture size needed for an animation with a given size and number of frames
	returns: the texture width and height, along with the number of columns and rows of animation frames.
	about: this function will ensure that the texture width and height remain in powers of 2.
end rem
Function GetTexSize(w:Int, h:Int, frames:Int, powersof2:Int = True, texwidth:Int Var, texheight:Int Var, Cols:Int Var, rows:Int Var)

        Local area:Int=w*h*frames 
        texwidth=1 
        
        While area>texwidth^2 
        
                texwidth:*2 
        
        Wend 
        
        cols=texwidth/w 
                
        texheight=h 
        
		If texwidth Mod w
	        While area >= texheight * (Cols * w)
	        
	                texheight:+h 
	                
	        Wend
		Else
	        While area > texheight * texwidth
	        
	                texheight:+h 
	                
	        Wend
		End If
        
        rows=texheight/h 

End Function
Rem
	bbdoc: Interpolate between 2 values
	about: This is the function used to achieve render tweening by taking the old and new values and interpolating between the 2
end rem
Function TweenValues:Float(oldValue:Float, value:Float, tween:Float)
	Return oldValue + (value - oldValue) * tween
End Function

rem
	bbdoc: rounds a number to the nearest int
	returns: Rounded Int
end rem
Function Round:Int(v:Double)
	Return Int(v + (Sgn(v) * 0.5))
End Function

Rem 
	bbdoc: Round up to the nearest power of 2
end rem
Function GetNearestPowerOf2:Int(n:Int)
	Local t:Int = 1
	While t<n
		t:*2
	Wend
	Return t
End Function
