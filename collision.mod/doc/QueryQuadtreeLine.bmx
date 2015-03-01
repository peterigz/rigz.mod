SuperStrict

Import rigz.collision

Graphics 1024, 768

'Create our quadtree. Here we're allowing for 5 levels of subdivision and upto 1 object before subdividing
'a quadtree node
Local QTree:tlQuadTree = CreateQuadtree(0, 0, GraphicsWidth() , GraphicsHeight(), 5, 1)

'Populate the quadtree with a bunch of objects
For Local c:Int = 1 To 1000
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
Local line:tlLine = CreateLine(200, 200, 500, 500)

While Not KeyDown(KEY_ESCAPE)
	
	Cls
	
	'set the ray to point towards the mouse pointer
	If MouseDown(1) line.SetPosition(MouseX(), MouseY())
	If MouseDown(2) line.Rotate(1)
	
	'Query screen space and render all on screen
	QueryQuadtreeArea(QTree, 0, 0, GraphicsWidth(), GraphicsHeight(), Null, RenderScreen)
	
	'query the quadtree with the ray and run our call back if it hit. Otherwise draw the full length of the ray (300)
	'we're using the data variable here to pass through the Point to the callback function	
	QueryQuadtreeLine(qtree, line, line, LineHandler)
	
	SetColor 255, 255, 255
	line.draw()
	
	SetColor 0, 255, 0
	DrawText "Click and drag to move the line about", 10, 10
	DrawText "Use right mouse to rotate the line", 10, 20
	
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
Function LineHandler(o:Object, data:Object, result:tlCollisionResult)
	
	'cast the objects to some local variables
	Local line:tlLine = tlLine(data)
	Local box:tlBox = tlBox(o)
	
	SetColor 0, 255, 0
	box.Draw()

End Function