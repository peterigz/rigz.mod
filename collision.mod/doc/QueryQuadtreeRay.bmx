SuperStrict

Import rigz.collision

Graphics 1024, 768

'Create our quadtree. Here we're allowing for 5 levels of subdivision and upto 1 object before subdividing
'a quadtree node
Local QTree:tlQuadTree = CreateQuadtree(0, 0, GraphicsWidth() , GraphicsHeight(), 5, 1)

'Populate the quadtree with a bunch of objects
For Local c:Int = 1 To 250
	Local t:Int = Rnd(3)
	Local rect:tlBox
	Select t
		Case 0
			'Create a Basic bounding box boundary
			rect = CreateBox(Rnd(GraphicsWidth()), Rnd(GraphicsHeight()), 10, 10)
		Case 1
			'Create a circle Boundary
			rect = CreateCircle(Rnd(GraphicsWidth()), Rnd(GraphicsHeight()), 5)
		Case 2
			'Create a polygon boundary
			Local verts:Float[] = [- 10.0, -10.0, -15.0, 0.0, -10.0, 10.0, 10.0, 10.0, 15.0, 0.0, 10.0, -10.0]
			rect = CreatePolygon(Rnd(GraphicsWidth()), Rnd(GraphicsHeight()), verts)
			RotatePolygon(tlPolygon(rect), Rnd(360))
	End Select
	'Add the boundary to the quadtree
	AddBoundaryToQuadtree(QTree, rect)
Next

'create a ray vector and its point of origin
Local ray:tlVector2 = New tlVector2.Create(0, 0)
Local point:tlVector2 = New tlVector2.Create(400, 300)

While Not KeyDown(KEY_ESCAPE)
	
	Cls
	
	'set the ray to point towards the mouse pointer
	If MouseDown(1) point.SetPosition(MouseX(), MouseY())
	ray.SetPosition(MouseX() - point.x, MouseY() - point.y)
	'normalise the ray into a unit vector. Not necessary for the ray cast query, it's just so
	'I can draw the ray a specific length
	ray.Normalise()
	
	'Query screen space and render all on screen
	QueryQuadtreeArea(QTree, 0, 0, GraphicsWidth(), GraphicsHeight(), Null, RenderScreen, 1)
	
	'query the quadtree with the ray and run our call back if it hit. Otherwise draw the full length of the ray (300)
	'we're using the data variable here to pass through the Point to the callback function	
	If Not QueryQuadtreeRay(qtree, point.x, point.y, ray.x, ray.y, 300, point, RayHandler, 1)
		SetColor 255, 0, 0
		DrawLine point.x, point.y, point.x + ray.x * 300, point.y + ray.y * 300
	End If
	
	SetColor 255, 255, 255
	DrawText "Click and drag to move the ray origin about", 10, 10
	
	Flip 1

Wend

'Our first callback function which is called when space is pressed and objects are found within the screen space
Function RenderScreen(o:Object, data:Object)
	'use casting to create the local rect
	Local rect:tlBox = tlBox(o)
	'and draw it
	SetColor 255, 255, 255
	rect.draw()
End Function

'Our call back function to handle the ray cast. Note that a ray cast callback must also have a tlCollisionResult parameter.
Function RayHandler(o:Object, data:Object, result:tlCollisionResult)
	
	'cast the objects to some local variables
	Local point:tlVector2 = tlVector2(data)
	Local box:tlBox = tlBox(o)
	
	SetColor 255, 0, 0
	
	'if the ray does not originate inside an object then draw the ray and intersection point
	If Not result.GetRayOriginInside()
		DrawLine point.x, point.y, result.GetRayIntersection().x, result.GetRayIntersection().y
		DrawOval result.GetRayIntersection().x - 4, result.GetRayIntersection().y - 4, 8, 8
	End If
	
	'draw the box we collided with in a different colour
	box.Draw()

End Function