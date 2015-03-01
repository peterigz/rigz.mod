SuperStrict

Import rigz.collision

Graphics 800, 600

'create a polygon to collide with
Local verts:Float[] = [0.0, 0.0, -150.0, 100.0, 50.0, 150.0, 185.0, 100.0, 300.0, 0.0]
'verts = [- 10.0, -10.0, 10.0, -10.0, 10.0, 10.0, -10.0, 10.0]
Local poly:tlPolygon = CreatePolygon(400, 200, verts)

'create a box to move about
Local box:tlBox = CreateBox(100, 100, 20, 20)

'a local collision result to store the result of the collision test
Local result:tlCollisionResult = New tlCollisionResult

'some velocity vectors to move the box about
Local VelVector:tlVector2 = CreateVector2(0, 0)
Local VelMatrix:tlMatrix2 = CreateMatrix2()
Local Direction:Float
Local speed:Float = 4

While Not KeyDown(KEY_ESCAPE)
	
	Cls
	
	'rotate the polygon by 1 degree every frame
	poly.Rotate(1)
	
	'some basic movement controls for the box
	If KeyDown(KEY_UP) direction = 0
	If KeyDown(KEY_RIGHT) direction = 90
	If KeyDown(KEY_DOWN) direction = 180
	If KeyDown(KEY_LEFT) direction = 270
	If KeyDown(KEY_RIGHT) And KeyDown(KEY_DOWN) direction = 135
	If KeyDown(KEY_DOWN) And KeyDown(KEY_LEFT) direction = 225
	If KeyDown(KEY_UP) And KeyDown(KEY_RIGHT) direction = 45
	If KeyDown(KEY_LEFT) And KeyDown(KEY_UP) direction = 315
	If KeyDown(KEY_UP) Or KeyDown(KEY_DOWN) Or KeyDown(KEY_LEFT) Or KeyDown(KEY_RIGHT)
		velvector.SetPosition(0, -speed)
	Else
		velvector.SetPosition(0, 0)
	End If
	velmatrix.set(Cos(direction) , Sin(direction) , -Sin(direction) , Cos(direction))
	velvector = velmatrix.transformvector(velvector).Unit()
	'set the box velocity so that the collision check can see whether the 2 objects will collide
	'the next frame. You don't *have* to do this, but it makes for more accurate collisions
	box.velocity = velvector.Scale(speed)

	'check for a collision with the poly
	result = CheckCollision(box, poly)
	
	'prevent the box from overlapping the poly
	PreventOverlap(result)
	
	'move the box. Important to do this after the collision check, but only if you're setting
	'the box velicity.
	box.Move(box.velocity.x, box.velocity.y)
	
	box.draw()
	poly.draw()
	
	Flip
	
Wend