SuperStrict

Import rigz.collision

Local verts:Float[] = [0.0, 0.0, -150.0, 100.0, 50.0, 150.0, 185.0, 100.0, 300.0, 0.0]
Local poly1:tlPolygon = CreatePolygon(150, 150, verts)
Local poly2:tlPolygon = CreatePolygon(450, 250, verts)

Local time:Int = MilliSecs()
Local collisions:Int

Print "Starting test..."
While MilliSecs() - time <= 1000
	CheckCollision(poly1, poly2)
	collisions = collisions + 1
Wend

Print "Collisions done in 1 second: " + collisions