SuperStrict

Import rigz.collision

SetGraphicsDriver GLMax2DDriver()

Graphics 1024, 768

'Create our quadtree. Here we're allowing for 5 levels of subdivision and upto 20 objects before subdividing
'a quadtree node
Local QTree:tlQuadTree = CreateQuadtree(0, 0, GraphicsWidth() , GraphicsHeight(), 5, 20)

'Populate the quadtree with a bunch of objects
For Local c:Int = 1 To 1000
	Local t:Int = Rnd(3)
	Local rect:tlBox
	Select t
		Case 0
			'Create a Basic bounding box boundary
			rect = CreateBox(Rnd(GraphicsWidth()), Rnd(GraphicsHeight()), 10, 10, tlLAYER_1)
		Case 1
			'Create a circle Boundary
			rect = CreateCircle(Rnd(GraphicsWidth()), Rnd(GraphicsHeight()), 5, tlLAYER_2)
		Case 2
			'Create a polygon boundary
			Local verts:Float[] = [- 10.0, -10.0, -15.0, 0.0, -10.0, 10.0, 10.0, 10.0, 15.0, 0.0, 10.0, -10.0]
			rect = CreatePolygon(Rnd(GraphicsWidth()), Rnd(GraphicsHeight()), verts, tlLAYER_3)
	End Select
	'Add the boundary to the quadtree
	AddBoundaryToQuadtree(QTree, rect)
Next

'Create a circle that we can move about the screen with the mouse
Local player:tlBox = CreateBox(0, 0, 50, 50)

While Not KeyDown(KEY_ESCAPE)
	
	Cls
	
	'Update the position of the mouse controlled boundary poly
	SetBoundaryPosition(player, MouseX(), MouseY())
	
	'If the space is pressed then query the quadtree to do a callback on all 
	'the objects on the screen. You could use something similar to cull all 
	'off screen objects
	If KeyDown(KEY_SPACE) QueryQuadtreeArea(QTree, 0, 0, GraphicsWidth(), GraphicsHeight(), Null, RenderScreen, tlLAYER_ALL)
	
	'Query the quadtree with our poly and pass the callback where we can check 
	'for collisions with the potential hits the quadtree finds
	QueryQuadtreeBox(QTree, player, player, MyCallback)
	
	'Draw the quadtree, just to show you how it partitions space
	SetColor 128, 128, 128
	QTree.Draw()

	'Draw the player circle
	SetColor 255, 255, 255
	player.draw()
	
	DrawText "Hold space to render the whole screen", 10, 10
	
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

'This callback is called when the quadtree finds objects within the bounding box of our poly
Function MyCallback(o:Object, data:Object)
	'Use casting to create a local rect of whatever boundary object the quad tree has found.
	'This could be either a tlBoundary, tlBoundaryCircle, tlBoundaryLine or tlBoundaryPoly
	Local rect:tlBox = tlBox(o)
	'We used the data variable to pass the poly we're using to move around the screen. This could be
	'any object, such as a game entity, which could have a field containing a tlBoundary representing
	'its bounding box/poly etc.
	Local player:tlBox = tlBox(data)
	'Do a collision check and store the result
	Local collisionresult:tlCollisionResult = CheckCollision(player, rect)
	If collisionresult.intersecting = True
		If rect.collisiontype = tlPOLY_COLLISION
			tlPolygon(rect).Rotate(1)
		End If
		SetColor 0, 255, 0
		rect.Draw
	End If
End Function