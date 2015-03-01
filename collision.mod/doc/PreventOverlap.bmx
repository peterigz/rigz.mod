SuperStrict

Import rigz.collision
Import "TDungeon.bmx"

Const wallsize:Int = 64

'set up a maze using TDungeon - Thanks to impixi from the blitz forums for the code in archives found here: 
'http://www.blitzbasic.com/codearcs/codearcs.php?code=1891

Graphics 800, 600

Cls
DrawText "Please wait, generating a maze", 10, 10
Flip

Local WallGrid:Byte[,]

Local Columns:Int
Local Rows:Int

Local maze:TDungeon = New TDungeon
maze.generate(MilliSecs(), 128, 128)
wallgrid = maze.getWallGrid()
Local d:Int[] = WallGrid.Dimensions()
columns = d[0]
rows = d[1]

'create the quadtree. We're creating quite a big game world so the quad tree needs quite a few levels to create
'the amount of partitioning we need. 9 levels=256x256 possible partitions (2^(levels-1))
Local QTree:tlQuadTree = CreateQuadtree(0, 0, columns * wallsize, rows * wallsize, 9, 1)

'create and add all of the walls of the maze to the quadtree using tlBox for walls.
Local wall:tlBox
Local wallcount:Int
For Local c:Int = 0 To Columns - 1
	For Local r:Int = 0 To Rows - 1
		
		If wallgrid[c, r] = True
			wall = CreateBox(c * wallsize, r * wallsize, wallsize, wallsize)
			AddBoundaryToQuadtree(qtree, wall)
			wallcount:+1
		End If
		
	Next
Next

DebugLog wallcount + " walls added to quadtree"
DebugLog "World size is " + (columns * wallsize) + " x "+ (rows * wallsize)

Local direction:Float
Local speed:Float = 5.1
Local velvector:tlVector2 = CreateVector2(0, 0)
Local VelMatrix:tlMatrix2 = CreateMatrix2()

'create a player to move about the world, and a camera vector to scroll about with
Local camera:tlVector2 = CreateVector2(0, 0)
Local player:tlCircle = CreateCircle(96, 96, 16)

Local time:Int = MilliSecs()

While Not KeyDown(KEY_ESCAPE)
	
	Cls
	
	'some basic movement controls for the player
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
	
	'move the player
	player.Move(velvector.x, velvector.y)
	
	time = MilliSecs()
	'query the screen space of the quadtree and call the renderscreen callback funtion
	QueryQuadtreeArea(qtree, camera.x, camera.y, GraphicsWidth() , GraphicsHeight() , camera, RenderScreen)
	Local screenobjects:Int = qtree.GetObjectsFound()
	'query the quadtree with the player and call the PlayervsWall callback function
	'to prevent overlapping with the wall
	QueryQuadtreeCircle(qtree, player, player, PlayervsWall)
	
	'update the camera position
	camera.SetPosition(player.world.x - GraphicsWidth() / 2, player.world.y - GraphicsHeight() / 2)
	
	'draw the player
	setcolor 0, 255, 0
	player.draw(camera.x, camera.y)
	
	DrawText "Time to run all queries:" + (MilliSecs() - time), 10, 10
	DrawText "Render screen objects found: " + screenobjects + " / " + wallcount, 10, 20
	DrawText "Objects close to player found: " + qtree.GetObjectsFound() + " / " + wallcount, 10, 30
	
	Flip

Wend

'Here's the Render screen function called by the QueryQuadtreeArea function in the mainloop
'everytime it finds an object on screen to draw
Function RenderScreen(wall:Object, cam:Object)
	'Here, we're passing the wall and the camera as objects through to the callback function
	'so we can use casting to put them into local variables
	Local box:tlBox = tlBox(wall)
	Local camera:tlVector2 = tlVector2(cam)
	SetColor 128, 128, 128
	'draw the wall, offsetting it's location by the camera coordinates
	DrawRect box.world.x - camera.x - wallsize / 2, box.world.y - camera.y - wallsize / 2, wallsize, wallsize
End Function

'And here's the function called by the QueryQuadtreeCircle function in the mainloop
'evertime it finds an object in the same space as the player
Function PlayervsWall(wall:Object, player:Object)
	'cast the objects into locals
	Local box:tlBox = tlBox(wall)
	Local p:tlCircle = tlCircle(player)
	
	'check for a collision between the player, and the wall
	Local result:tlCollisionResult = CheckCollision(p, box)
	'prevent the 2 from overlapping if necessary.
	PreventOverlap(result)
End Function
