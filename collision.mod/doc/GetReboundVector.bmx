SuperStrict

Import rigz.collision

Graphics 800, 600

Local qtree:tlQuadTree = CreateQuadtree(0, 0, GraphicsWidth(), GraphicsHeight())

'Add some obstacles to the quadtree
AddBoundaryToQuadtree(qtree, CreateBox(10, 0, GraphicsWidth() - 20, 10))
AddBoundaryToQuadtree(qtree, CreateBox(10, GraphicsHeight() - 10, GraphicsWidth() - 20, 10))
AddBoundaryToQuadtree(qtree, CreateBox(0, 10, 10, GraphicsHeight() - 20))
AddBoundaryToQuadtree(qtree, CreateBox(GraphicsWidth() - 10, 10, 10, GraphicsHeight() - 20))
Local verts:Float[] = [- 50.0, -50.0, -70.0, 0.0, -50.0, 50.0, 50.0, 50.0, 100.0, 0.0, 50.0, -50.0]
AddBoundaryToQuadtree(qtree, CreatePolygon(Rnd(GraphicsWidth()), Rnd(GraphicsHeight()), verts))
AddBoundaryToQuadtree(qtree, CreateCircle(500, 400, 100))
AddBoundaryToQuadtree(qtree, CreateBox(500, 200, 50, 50))
AddBoundaryToQuadtree(qtree, CreateLine(300, 300, 350, 590))

'create a ball to bounce about
Local ball:tlCircle = CreateCircle(200, 200, 10)
SetBoundaryVelocity(ball, 5, 5)

While Not KeyDown(KEY_ESCAPE)
	
	Cls
	
	'Query the quadtree with the screen area and call a function that will draw the stuff it finds
	QueryQuadtreeArea(qtree, 0, 0, GraphicsWidth(), GraphicsHeight(), Null, renderscreen)
	'Query the quadtree with the ball  and call the function to handle it colliding with stuff in the quadtree
	QueryQuadtreeBox(qtree, ball, ball, BounceBall)
	
	UpdateBoundaryPosition(ball)
	
	ball.draw()
	
	Flip 1

Wend

'render screen callback function
Function renderscreen(o:Object, data:Object)
	
	Local box:tlBox = tlBox(o)
	SetColor 255, 255, 255
	box.Draw()

End Function

'ball colliding callback function
Function BounceBall(o:Object, data:Object)
	'o will be the object found in the quadtree
	'data is our ball we passed through to this function	

	'cast the objects into local variables
	Local ball:tlCircle = tlCircle(data)
	Local wall:tlBox = tlBox(o)
	
	'check for collisions between the ball and the obstacle found in the quadtree
	Local result:tlCollisionResult = CheckCollision(ball, wall)
	'prevent the 2 objects from overlapping
	PreventOverlap(result)
	'set the ball velocity to the appropriate rebound vector to make it bounce off the walls.
	ball.velocity = GetReboundVector(result, ball.velocity)
	
End Function