SuperStrict

Import rigz.collision

Graphics 800, 600

'Quick example show how you might incorperate rigz.collisison into your game objects

'a very simple game entity type
Type tEntity
	
	Field x:Float
	Field y:Float
	
	Field xspeed:Float
	Field yspeed:Float
	
	'Here's the field containing the collision box
	Field CollisionBox:tlBox
	
	Field velmatrix:tlMatrix2 = CreateMatrix2()
	Field velvector:tlVector2 = CreateVector2(0, 0)
	
	Field direction:Int
	Field speed:Float = 5

	Function Create:tEntity(x:Float, y:Float)
		Local e:tEntity = New tEntity
		e.x = x
		e.y = y
		e.CollisionBox = CreateBox(x - 10, y - 10, 20, 20)
		Return e
	End Function
	
	Method control()
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
		velvector = velvector.Scale(speed)
	End Method
	
	'the update method which moves the player, and also updates the position of the collision box
	Method update()
		x:+velvector.x
		y:+velvector.y
		collisionbox.SetPosition(x, y)
	End Method
	
	Method draw()
		collisionbox.Draw()
	End Method
	
End Type

'create a player entity
Local player:tEntity = tEntity.Create(100, 100)

'Create our quadtree. Here we're allowing for 5 levels of subdivision and upto 1 object before subdividing
'a quadtree node
Local QTree:tlQuadTree = CreateQuadtree(0, 0, GraphicsWidth() , GraphicsHeight(), 5, 1)
'Add the player collision box to the quadtree
AddBoundaryToQuadtree(qtree, player.CollisionBox)

'Populate the quadtree with a bunch of objects
For Local c:Int = 1 To 100
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


While Not KeyDown(KEY_ESCAPE)
	
	Cls
	
	player.control()
	player.update()
	
	'run a query on the quadtree to find objects near the player, and call the PlayerCallback Function
	'We can use the data parameter to pass the player tEntity to the callback function
	QueryQuadtreeBox(qtree, player.CollisionBox, player, PlayerCallback)
	'Query the quadtree to find all teh objects on the screen and call teh RenderScreen function for each object
	QueryQuadtreeArea(QTree, 0, 0, GraphicsWidth(), GraphicsHeight(), Null, RenderScreen)
		
	Flip

Wend

'Our first callback function which is called when space is pressed and objects are found within the screen space
Function RenderScreen(o:Object, data:Object)
	'use casting to create the local rect
	Local rect:tlBox = tlBox(o)
	'and draw it
	SetColor 255, 255, 255
	rect.draw()
End Function

'The player callback function, run when the quadtree finds objects near the player
Function PlayerCallback(o:Object, p:Object)
	'cast the onject found into a local variable
	Local box:tlBox = tlBox(o)
	'cast the player tEntity into a local variable
	Local player:tEntity = tEntity(p)
	
	'Check for a collision between the player collision box and the object found in the quadtree
	'and store the result
	Local result:tlCollisionResult = CheckCollision(player.CollisionBox, box)
	
	'prevent the 2 from overlapping if necessary
	PreventOverlap(result)
	
	'Having prevented the overlap the collision box will have been moved, so we can copy the
	'world coordinates of the box to the player as well.
	player.x = player.CollisionBox.GetWorldX()
	player.y = player.CollisionBox.GetWorldY()
	
End Function