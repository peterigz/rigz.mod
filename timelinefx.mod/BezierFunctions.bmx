SuperStrict

Const BEZIER_ACCURACY:Float = 0.01

Function GetQuadBezier:tlPoint(p0:tlPoint, p1:tlPoint, p2:tlPoint, t:Float, ymin:Float, ymax:Float, clamp:Int = True)
	Local b:tlPoint = New tlPoint
	b.x = (1 - t) ^ 2 * p0.x + 2 * t * (1 - t) * p1.x + t ^ 2 * p2.x
	b.y = (1 - t) ^ 2 * p0.y + 2 * t * (1 - t) * p1.y + t ^ 2 * p2.y
	If b.x < p0.x Then b.x = p0.x
	If b.x > p2.x Then b.x = p2.x
	If clamp
		If b.y < ymin Then b.y = ymin
		If b.y > ymax Then b.y = ymax
	End If
	Return b
End Function

Function GetCubicBezier:tlPoint(p0:tlPoint, p1:tlPoint, p2:tlPoint, p3:tlPoint, t:Float, ymin:Float, ymax:Float, clamp:Int = True)
	Local b:tlPoint = New tlPoint
	b.x = (1 - t) ^ 3 * p0.x + 3 * t * (1 - t) ^ 2 * p1.x + 3 * t ^ 2 * (1 - t) * p2.x + t ^ 3 * p3.x
	b.y = (1 - t) ^ 3 * p0.y + 3 * t * (1 - t) ^ 2 * p1.y + 3 * t ^ 2 * (1 - t) * p2.y + t ^ 3 * p3.y
	If b.x < p0.x Then b.x = p0.x
	If b.x > p3.x Then b.x = p3.x
	If clamp
		If b.y < ymin Then b.y = ymin
		If b.y > ymax Then b.y = ymax
	End If
	Return b
End Function

Function DrawQuadBezier(p0:tlPoint, p1:tlPoint, p2:tlPoint, ymin:Float, ymax:Float)
	Local prevx:Float
	Local prevy:Float
	Local lastb:tlPoint
	For Local t:Float = 0 To 1 Step BEZIER_ACCURACY
		Local b:tlPoint = GetQuadBezier(p0, p1, p2, t, ymin, ymax, False)
		If t > 0
			If b.y > ymin Then b.y = ymin
			If b.y < ymax Then b.y = ymax
			DrawLine prevx, prevy, b.x, b.y, False
		End If
		prevx = b.x
		prevy = b.y
		lastb = b
	Next
	Local b:tlPoint = GetQuadBezier(p0, p1, p2, 1, ymin, ymax, False)
	If b.y > ymin Then b.y = ymin
	If b.y < ymax Then b.y = ymax
	DrawLine prevx, prevy, b.x, b.y, False
End Function

Function DrawCubicBezier(p0:tlPoint, p1:tlPoint, p2:tlPoint, p3:tlPoint, ymin:Float, ymax:Float)
	Local prevx:Float
	Local prevy:Float
	Local lastb:tlPoint
	For Local t:Float = 0 To 1 Step BEZIER_ACCURACY
		Local b:tlPoint = GetCubicBezier(p0, p1, p2, p3, t, ymin, ymax, False)
		If t > 0
			If b.y > ymin Then b.y = ymin
			If b.y < ymax Then b.y = ymax
			DrawLine prevx, prevy, b.x, b.y, False
		End If
		prevx = b.x
		prevy = b.y
		lastb = b
	Next
	Local b:tlPoint = GetCubicBezier(p0, p1, p2, p3, 1, ymin, ymax, False)
	If b.y > ymin Then b.y = ymin
	If b.y < ymax Then b.y = ymax
	DrawLine prevx, prevy, b.x, b.y, False
End Function

Type tlPoint
	
	Field x:Float
	Field y:Float
	
	Field q0:tlPoint
	Field q1:tlPoint
	
	Field selected:Int
	
	Field side:Int
		
	Method Create:tlPoint(x:Float, y:Float)
		Local p:tlPoint = New tlPoint
		p.x = x
		p.y = y
		Return p
	End Method
	
End Type
