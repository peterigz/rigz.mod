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
	bbdoc: 2d Vector and Matrix types for basic 2d geometry stuff
	about: These types are basic with the minimum functionality required for the rest of the rigz collection of modules. 
	These type grow as the overal need grows.
end rem
Module rigz.vector
ModuleInfo "Author: Peter J. Rigby"
ModuleInfo "Copyright: Peter J. Rigby 2009"
ModuleInfo "Purpose: Classes for vectors and matrices"
ModuleInfo "Version: v1.07"

Import brl.math

rem
	bbdoc: Matrix type which can be used to easily transform vectors
	about: Matrices come in handy for transforming vectors such as scale and rotation
end rem
Type tlMatrix2
	
	Field aa:Float, ab:Float
	Field ba:Float, bb:Float
	
	rem
		bbdoc: Create a new matrix
		returns: New matrix type
	end rem
	Function Create:tlMatrix2(aa:Float = 1, ab:Float = 0, ba:Float = 0, bb:Float = 1)
		Local m:tlMatrix2 = New tlMatrix2
		m.aa = aa
		m.ab = ab
		m.ba = ba
		m.bb = bb
		Return m
	End Function
	
	rem
		bbdoc: Set the matrix to a new set of values
		about: Use this to prepare the matrix for a new transform. For example if you wanted to to rotate a vector, then you could do 
		&{<matrix.set(cos(angle),sin(angle),-sin(angle),cos(angle))}
		and then transform the vector with 
		&{matrix.transformvector(vector)}
	end rem
	Method set(_aa:Float = 1, _ab:Float = 0, _ba:Float = 0, _bb:Float = 1)
		aa = _aa
		ab = _ab
		ba = _ba
		bb = _bb
	End Method
	
	rem
		bbdoc: Transpose the matrix
	end rem
	Method transpose()
		Local abt:Float = ab
		ab = ba
		ba = abt
	End Method
	
	rem
		bbdoc: Scale the matrix by a given amount
	end rem
	Method scale(s:Float)
		aa:*s
		ab:*s
		ba:*s
		bb:*s
	End Method
	
	rem
		bbdoc: Transfrom the matrix
		about: Multiplies 2 matrices together
		returns: New transformed matrix
	end rem
	Method transform:tlMatrix2(m:tlMatrix2)
		Local r:tlMatrix2 = New tlMatrix2
		r.aa = aa * m.aa + ab * m.ba;r.ab = aa * m.ab + ab * m.bb
		r.ba = ba * m.aa + bb * m.ba;r.bb = ba * m.ab + bb * m.bb
		Return r
	End Method
	
	rem
		bbdoc: Transfrom a vector with the matrix
		returns: New transformed vector
		about: You can use this to transfrom a vector, rotating it, scaling it etc.
	end rem
	Method transformvector:tlVector2(v:tlVector2)
		Local tV:tlVector2 = New tlVector2.Create(0, 0)
		tV.x = v.x * aa + v.y * ba
		tV.y = v.x * ab + v.y * bb
		Return tV
	End Method
	
	rem
		bbdoc: Transfrom a point
		returns: New coordinates for the tranformed point in tx and ty
		about: This will transform a point (x,y) and appply the new coordinates into tx and ty.
	end rem
	Method transformpoint(x:Float, y:Float, tx:Float Var, ty:Float Var)
		tx = x * aa + y * ba
		ty = x * ab + y * bb
	End Method

End Type

rem
	bbdoc: 2d vector type for basic vector handling
end rem
Type tlVector2
	
	Field x:Float, y:Float
	
	rem
		bbdoc: Create a new vector with the given coordinates
		returns: New #tlVector2
	end rem
	Method Create:tlVector2(vx:Float, vy:Float)
		x = vx
		y = vy
		Return Self
	End Method
	
	rem
		bbdoc: Clone a Vector
		returns: Newly cloned #tlVector2
	end rem
	Method Clone:tlVector2()
		Return New tlVector2.Create(x, y)
	End Method
	
	rem
		bbdoc: Move a vector but the given x and y amount
	end rem
	Method Move(distance_x:Float, distance_y:Float)
		x:+distance_x
		y:+distance_y
	End Method
	
	rem
		bbdoc: Move a vector buy the given vector
	end rem
	Method MoveByVector(distance:tlVector2)
		x:+distance.x
		y:+distance.y
	End Method
	
	rem
		bbdoc: Reposition the vector by the new x,y coordinates given
	end rem
	Method SetPosition(_x:Float, _y:Float)
		x = _x
		y = _y
	End Method
	
	rem
		bbdoc: Reposition the vector by the given vector
	end rem
	Method SetPositionByVector(v:tlVector2)
		x = v.x
		y = v.y
	End Method
	
	rem
		bbdoc: Subtract this tlVector2 vector by another and return the result in a new vector
		returns: A new #tlVector2
	end rem
	Method SubtractVector:tlVector2(v:tlVector2)
		Return New tlVector2.Create(x - v.x, y - v.y)
	End Method
	
	rem
		bbdoc: Add this tlVector2 vector to another and return the result in a new vector
		returns: A new #tlVector2
	end rem
	Method AddVector:tlVector2(v:tlVector2)
		Return New tlVector2.Create(x + v.x, y + v.y)
	End Method
	
	rem
		bbdoc: multiply this vector with another and return the result
		returns: New #tlvector2
	end rem
	Method Multiply:tlVector2(v:tlVector2)
		Return New tlVector2.Create(x * v.x, y * v.y)
	End Method
	
	rem
		bbdoc: Scale the vector by the given amount and return the result in a new vector
		returns: new scaled #tlvector2
	end rem
	Method Scale:tlVector2(scale:Float)
		Return New tlVector2.Create(x * scale, y * scale)
	End Method
	
	rem
		bbdoc: Get the length of the vector
		returns: The length or magnitude of the vector.
	end rem
	Method Length:Float()
		Return Sqr(x * x + y * y)
	End Method
	
	rem
		bbdoc: Get the unit vector of the vector
		returns: New unit vector of this vector
	end rem
	Method Unit:tlVector2()
		Local length:Float = Length()
		Local v:tlVector2 = clone()
		If length
			v.x = x / length
			v.y = y / length
		End If
		Return v
	End Method
	
	rem
		bbdoc: get the normal of the vector
		returns: New #tlVector2 normal of this vector
	end rem
	Method Normal:tlVector2()
		Return New tlVector2.Create(-y, x)
	End Method
	
	Method LeftNormal:tlVector2()
		Return New tlVector2.Create(y, -x)
	End Method
	
	rem
		bbdoc: Normalise the vector
	end rem
	Method Normalise()
		Local length:Float = length()
		If length
			x:/length
			y:/length
		End If
	End Method
	
	rem
		bbdoc: Get the dot product of the vector
		returns: The dot product of the vector.
	end rem
	Method DotProduct:Float(v:tlVector2)
		Return x * v.x + y * v.y
	EndMethod
End Type

rem
	bbdoc: Create a new 2d vector
end rem
Function CreateVector2:tlVector2(x:Float, y:Float)
	Return New tlVector2.Create(x, y)
End Function

rem
	bbdoc: Create a new 2d matrix
end rem
Function CreateMatrix2:tlMatrix2(aa:Float = 1, ab:Float = 0, ba:Float = 0, bb:Float = 1)
	Return tlMatrix2.Create(aa, ab, ba, bb)
End Function