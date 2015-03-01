SuperStrict

Import rigz.collision

Graphics 800, 600

'create some shapes for collisions
Local verts:Float[] = [- 100.0, 0.0, -150.0, 100.0, 50.0, 150.0, 185.0, 100.0, 300.0, 0.0]
Local poly:tlPolygon = New tlPolygon.CreatePoly(400, 200, verts)
Local line:tlLine = CreateLine(200, 500, 800, 100)
Local box:tlBox = CreateBox(400, 300, 100, 100)
Local circle:tlCircle = CreateCircle(400, 300, 40)

Local ray:tlVector2 = CreateVector2(0, 0)
Local result:tlCollisionResult = New tlCollisionResult
Local point:tlVector2 = CreateVector2(0, 0)

Local shape:Int

While Not KeyDown(KEY_ESCAPE)
	
	Cls
	
	'set the ray vector based on the point->mouse vector
	If MouseDown(1) point.SetPosition(MouseX(), MouseY())
	ray.SetPosition(MouseX() - point.x, MouseY() - point.y)
	
	'normalise the ray so we can draw the laser a fixed length a bit more easily
	ray.Normalise()
	
	'iterate through shapes if space is pressed
	If KeyHit(KEY_SPACE)
		shape:+1
		If shape > 3 shape = 0
	End If
	
	SetColor 255, 255, 255
	
	DrawText "Press space to change shape", 10, 10
	DrawText "Click and drag to move the laser, mouse pointer set the laser direction", 10, 20
	
	'do a ray collision checked on the selected shape and store the result
	Select shape
		Case 0
			box.draw()
			result = CheckRayCollision(box, point.x, point.y, ray.x, ray.y)
		Case 1
			line.Rotate(1)
			line.draw()
			result = CheckRayCollision(line, point.x, point.y, ray.x, ray.y)
		Case 2
			circle.draw()
			result = CheckRayCollision(circle, point.x, point.y, ray.x, ray.y)
		Case 3
			poly.Rotate(1)
			poly.draw()
			result = CheckRayCollision(poly, point.x, point.y, ray.x, ray.y)
	End Select
	
	SetColor 255, 0, 0
	DrawRect point.x - 5, point.y - 5, 10, 10

	'if the result shows an intersection and it wasn't insise the shape
	If result.GetRayIntersection() And Not result.GetRayOriginInside()
		'draw the ray upto the intersection point
		DrawLine point.x, point.y, result.rayintersection.x, result.rayintersection.y
		DrawOval result.rayintersection.x - 4, result.rayintersection.y - 4, 8, 8
		'find the rebound vector
		Local rebound:tlVector2 = GetReboundVector(result, ray)
		'draw the rebounded ray
		DrawLine result.rayintersection.x, result.rayintersection.y,  ..
				result.rayintersection.x + rebound.x * 500, result.rayintersection.y + rebound.y * 500
	ElseIf result.rayorigininside
		DrawText "Ray starts inside object!", 10, 30
	Else
		'no intersection, draw a line for the ray
		DrawLine point.x, point.y, point.x + ray.x * 1000, point.y + ray.y * 1000
	EndIf

	Flip 
	
Wend