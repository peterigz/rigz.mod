'Copyright (c) 2009 Peter J Rigby
'
'Permission is hereby granted, free of charge, to any person obtaining a copy
'of this software and associated documentation files (the "Software"), to deal
'in the Software without restriction, including without limitation the rights
'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
'copies of the Software, and to permit persons to whom the Software is
'furnished to do so, subject to the following conditions:
'
'The above copyright notice and this permission notice shall be included in
'all copies or substantial portions of the Software.
'
'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
'THE SOFTWARE.

SuperStrict

Rem
	bbdoc: Collision Module with quadtrees for spatial partitioning of boundaries
	about: <p>This modules provides a way to check for collisions between boxes, circles, lines and polygons (referred to as boundaries throughout
	to documentation). The option of using a quadtree
	is also there to speed up collision checking between large numbers of objects.</p>
	<p>Thanks to matibee, Leadwerks and Oddball from the Blitzmax forums, plus the authors of these sites http://en.wikipedia.org/wiki/Quadtree, 
	http://www.kyleschouviller.com/wsuxna/quadtree-source-included/, http://www.heroicvirtuecreations.com/QuadTree.html,
	http://www.metanetsoftware.com/technique/tutorialA.html and http://www.codeproject.com/KB/GDI-plus/PolygonCollision.aspx where I found lots of useful
	info!</p>
	<p>The aim of this module was to try as much as possible to combine ease of use with performance. In terms of performance it uses a collision checking
	technique called separating axis theorem, which is quite a common and fast approach to collision detection, as well as providing an easy way to find
	out about each collision that happens in order to calculate things such as overlap prevention, and rebound vector calculation.</p>
	<p>For an example as to how easy the module is to use, to calculate a collision between 2 objects, you can simply use #CheckCollisions like so:
	&{local result:tlCollisionResult=CheckCollisions(SourceObject, TargetObject)}
	Where source and target objects can be either a #tlBox, #tlCircle, #tlLine or #tlPolygon. Once the check is done the results of the collision are
	returned in a #tlCollisionResult where you can find out a number of things about the nature of the collision. To prevent 2 objects from overlapping
	you can simply do:
	&{PreventOverlap(result)}
	and if a collision occurred then the 2 objects will be separated. See #PreventOverlap for more info and an example</p>
	<p>Quadtrees are also simple to use, see #tlQuadtree for more info and an example.</p>
	<p>All boundaries can be placed on one or more layers (up to 32) to help you organise collisions more easily. You can use the constants tlLAYER_1, tlLAYER_2..
	etc. up to 32 or tlLAYER_ALL to place a boundary on all layers. To set a layer you can either do it on creation of a boundary ie., with #CreateBox, or
	you can use #SetBoundaryLayer. Use #GetBoundaryLayer to find out the layer of a boudnary.</p>
	<p>It's might be worth noting, that whilst function wrappers for most types have been created for extra convienience, you can still access the those methods
	directly in a more OO approach if you wish. Peruse the documentation for the specific methods etc.</p>
end rem
Module rigz.collision
ModuleInfo "Author: Peter J. Rigby"
ModuleInfo "Copyright: Peter J. Rigby 2009"
ModuleInfo "Purpose: Provide a way of testing for collisions between boxes, circles, polygons and lines with the added option of using quadtrees"
ModuleInfo "Version: 1.01"

ModuleInfo "History: 20.06.10 - Fixed a bug with velocity not being taken into account after querying a quadtree which was causing tunnelling to occurr."
ModuleInfo "History: 06.01.10 - Initial Release"

Import rigz.vector
Import brl.linkedlist
Import brl.max2d
Import rigz.math

Rem 
	bbdoc: Quadtree type for managing a quadtree
	about: <p>Rather then go on about what a quadtree is, here's some useful resources I used myself to find out about them:
	http://en.wikipedia.org/wiki/Quadtree, http://www.kyleschouviller.com/wsuxna/quadtree-source-included/ and http://www.heroicvirtuecreations.com/QuadTree.html</p>
	<p>Quadtrees vary with each implementation based on the users needs. I've tried to be flexible here with a emphasis on handling objects that will
	move about a lot. If an object moves within a quadtree then it will generally have to be re-added to the quadtree, so I've implemented that possibility here. 
	Thankfully there's no need to rebuild the quadtree every time an object moves, the object just removes and adds itself back to the tree, and it will only do it if
	it's moved outside of it's containing #tlQuadTreeNode.</p>
	<p>When I say object, I mean a #tlBox, which is a simple axis aligned bounding box type that can be added to the quadtree, the more complex #tlCircle, #tlLine and
	#tlPolygon which extend #tlBox can also be added, but the quadtree will only concern itself with bounding boxes when a query is made on the 
	quadtree.</p>
	<p>Using the quadtree is simple enough, create a new quadtree with whatever dimensions you want and then use #AddBox to add bounding boxes to it. In 
	your main loop you might want to put #RunQuadtreeMaintenance which tidies up the quadtree by finding empty partitions and deleting them. Of course
	the whole point of a quadtree is to find out which objects are within a particular area so that you can do collision checking, rendering, updating or whatever. To do that,
	you can query the quadtree by simply calling either #QueryQuadtreeArea or #QueryQuadtreeBox which will run a callback function of your choice to perform your 
	specific tasks on them. There's also queries available to check for objects within a radius by using, #QueryQuadtreeRange and #QueryQuadtreeCircle, and also
	for lines and rays using #QueryQuadtreeEdge, #QueryQuadtreeLine and #QueryQuadtreeRay.</p>
	<p>Here is a list of the query functions you can use to query the quadtree, along with the type of callback function you'll need to create to handle the results
	of each query:</p>
	<table>
	<tr>
	<td> #QueryQuadtreeArea / #QueryQuadtreeBox </td>
	<td>For querying the quadtree with a rectangular area. All objects within the area will be passed through to a callback function that needs the following
	parameters: &{Callback(ObjectFoundInQuadtree:object, Data:object)} You don't have to use those exact variable names, just as long as the 2 variables are objects.</td>
	</tr>
	<tr>
	<td> #QueryQuadtreeRange / #QueryQuadtreeCircle </td>
	<td>For querying the quadtree with a specific radius. All objects within the radius will be passed through to the call back function:
	&{Callback(ObjectFoundInQuadtree:object, Data:object)}</td>
	</tr>
	<tr>
	<td> #QueryQuadtreeRay </td>
	<td>This is for casting a ray from any point and doing a callback on the first object that is hit. The callback differs slightly in that the results
	of the ray collision are passed through to the callback aswell. This is because the collision check vs the ray has to be done during the query, so 
	there is no need to do any further ray checks in your callback. The callback should look like this: &{Callback(ObjectFoundInQuadtree:object, Data:object, Result:tlCollisionResult)}</td>
	</tr>
	<tr>
	<td> #QueryQuadtreeEdge / #QueryQuadtreeLine </td>
	<td>This is for querying the QuadTree with a line. Every object in the Quadtree that collides with the line is passed To the callback function, and like
	the ray query, the collision result is also passed through too: &{Callback(ObjectFoundInQuadtree:object, Data:object, Result:tlCollisionResult)}
	</td>
	</tr>
	</table>
	<p>Implementing this quadtree within your game will probably involve including #tlBox, #tlCircle, #tlLine or #tlPolygon as a field within your entity/actor etc types.
	When your actors move about, just make sure you update the position of the Box as well using #SetBoxPosition or #MoveBox. When this happens all the necessary updating 
	of the quadtree will happen automatically behind the scenes. Be aware that if an object moves outside of the quadtree bounds it will drop out of the quadtree.</p>
	<p><b>FAQ:</b></p>
	<p><b>What happens when a object overlaps more then one quadtreenode?</b></p>
	<p>The object is added to each node it overlaps. No object will ever be added to a node that has children, they will be moved down the quadtree to the bottom level of that branch.</p>
	<p><b>What happens when an object is found more then once because it is contained within more than 1 node?</b></p>
	<p>tlBoxs are aware if they have already been found and a callback has been made within the same search, so a callback will never be made twice on 
	the same search query.</p>
	<p><b>What happens if a node no longer contains more then the maximium allowed for a node, are it's objects moved back up the tree?</b></p>
	<p>No, onced a node is partioned and objects moved down, they're there to stay, however if you #RunQuadtreeMaintenance then empty nodes will be unpartitioned. I
	didn't think it was worth the overhead to worry about moving objects back up the tree again.</p>
	<p><b>What collision checking is done when calling, for example, #QueryQuadtreeArea?</b></p>
	<p>The quadtree will just concern itself with doing callbacks on objects it finds with rect->rect collision in the case of #QueryQuadtreeArea, and circle->rect
	 collision in the case of #QueryQuadtreeRange. Once you've found those objects you can then go on and do more complex collision checking such as poly->poly. If
	however you only need to check for rect->rect then you can assume a hit straight away as the quadtree will only callback actual hits, potential hits are 
	already excluded automatically if their bounding box is outside the area being queried.</p>
	<p><b>What are potential hits?</b></p>
	<p>A potential hit would be an object in the same quadtree node that the area check overlaps. So if the area you're checking a collision for overlaps
	2 quadnodes, all the objects in those 2 nodes would be considered potential hits. I decided that I may aswell cull any of those bounding boxes that
	don't overlap the area being checked before doing the callback so that the amount of potential hits is reduced further, and to save wasting the time doing it in the callback function. 
	This applies to both #QueryQuadtreeArea and #QueryQuadtreeRange functions, but as mentioned before, it will only cull according to bounding boxes, you'll have 
	to do a further check in your callback to manage the more complex poly->poly, poly->rect etc., collisions.</p>
	<p><b>If I have to use a callback function, how can I do stuff with an object without resorting to globals?</b></p>
	<p>When you run a #QueryQuadtreeArea (of any type) you can pass an object that will be passed through to the callback function. So the call back function
	you create should look like: &{Function MyCallBackFunction(ObjectFoundInQuadtree:Object, MyData:object)}So your data could be anything such as a bullet
	or player ship etc., and assuming that object has a tlBox field you can do further collision checks between the 2. If you don't need to pass any 
	data then just leave it null.</p>
	<p><b>How do I know what kind of tlBox has been passed back from from the quadtree?</b></p>
	<p>tlBoundaries have a field called collisiontype which you can find out by calling #GetCollisionType. This will return either tlBOX_COLLISION, 
	tlCIRCLE_COLLISION, tlPOLY_COLLISION or tlLINE_COLLISION. The chances are though, that you won't need to know the type, as a call to #CheckCollision
	will automatically determine the type and perform the appropriate collision check.</p>
	<p><b>Can I have more then one quadtree</b></p>
	<p>Yes you can create as many quadtrees as you want, however, bear in mind that a #tlBox can only ever exist in 1 quadtree at a time. I most cases, with 
	the use of layers, 1 quadtree will probably be enough.</p>
end rem
Type tlQuadTree
	
	Field maxlevels:Int
	Field Box:tlBox
	Field rootnode:tlQuadTreeNode
	Field maxpernode:Int
	Field areacheckcount:Int
	
	Field objectsfound:Int
	Field objectsupdated:Int
	Field totalobjectsintree:Int
	
	Field min_nodewidth:Float
	Field min_nodeheight:Float
	
	Field map:tlQuadTreeNode[,]
	
	Field dimension:Int
	
	Rem
		bbdoc: Create a new tlQuadTree
		returns: A new quadtree
		about: Creates a new quad tree with the coordinates and dimensions given. _maxlevels determines how many times the quadtree can be sub divided. A
		quadtreenode is only subdivided when a certain amount of objects have been added, which is set by passing _maxpernode. There's no optimum values for
		these, it largely depends on your specific needs, so you will probably do well to experiment.
	end rem
	Method Create:tlQuadTree(x:Float, y:Float, w:Float, h:Float, _maxlevels:Int = 4, _maxpernode:Int = 4)
		Box = New tlBox.Create(x, y, w, h)
		maxlevels = _maxlevels
		maxpernode = _maxpernode
		rootnode = New tlQuadTreeNode.Create(x, y, w, h, Self)
		dimension = 2 ^ (maxlevels - 1)
		min_nodewidth = w / dimension
		min_nodeheight = h / dimension
		map = New tlQuadTreeNode[dimension, dimension]
		For Local x:Int = 0 To dimension - 1
			For Local y:Int = 0 To dimension - 1
				map[x, y] = rootnode
			Next
		Next
		rootnode.dimension = dimension
		Return Self
	End Method
	
	Rem
		bbdoc: Add a new bounding box to the Quadtree
		returns: False if the box doesn't overlap the qaudtree, otherwise True.
		about: A quadtree isn't much use without any objects. Use this to add a #tlBox to the quadtree. If the bounding box does not overlap the 
		quadtree then null is returned.
	end rem
	Method AddBox:Int(r:tlBox)
		If Box.BoundingBoxOverlap(r)
			r.quadtree = Self
			rootnode.AddBox(r)
			totalobjectsintree:+1
			Return True
		Else
			Return False
		End If
	End Method
	
	Rem
		bbdoc: Query the Quadtree to find objects with an area
		about: When you want to find objects within a particular area of the quadtree you can use this method.  Pass the area coordinates and dimensions
		that you want to check, an object that can be anything that you want to pass through to the callback function, and the function callback that you want 
		to perform whatever tasks you need on the objects that are found within the area.
		The callback function you create needs to have 2 parameters: ReturnedObject:object which will be the tlBox/circle/poly, and Data:object which can be
		and object you want to pass through to the call back function.
	end rem
	Method ForEachObjectInArea(x:Float, y:Float, w:Float, h:Float, Data:Object, callback:Int(ReturnedObject:Object, Data:Object), Layer:Int = tlLAYER_ALL)
		Local area:tlBox = New tlBox.Create(x, y, w, h)
		AreaCheckCount:+1
		objectsfound = 0
		rootnode.ForEachInAreaDo(area, Data, callback, False, layer)
	End Method
	
	Rem
		bbdoc: Query the quadtree to find objects within a #tlBox
		about: This does the same thing as #ForEachObjectInArea except you can pass a #tlBox instead to query the quadtree.
	end rem
	Method ForEachObjectInBox(area:tlBox, Data:Object, callback:Int(o:Object, Data:Object), Layer:Int = tlLAYER_ALL)
		AreaCheckCount:+1
		objectsfound = 0
		rootnode.ForEachInAreaDo(area, Data, callback, True, layer)
	End Method
	
	Rem
		bbdoc: Query the quadtree to find objects within a certain radius
		about: This will query the quadtree and do a callback on any objects it finds within a given radius.
	end rem
	Method ForEachObjectWithinRange(x:Float, y:Float, radius:Float, Data:Object, callback:Int(ReturnedObject:Object, Data:Object), Layer:Int = tlLAYER_ALL)
		Local range:tlCircle = New tlCircle.CreateCircle(x, y, radius)
		AreaCheckCount:+1
		objectsfound = 0
		rootnode.ForEachWithinRangeDo(range, Data, callback, layer)
	End Method
	
	Rem
		bbdoc: Query the quadtree to find objects within a #tlCircle
		about: This will query the quadtree and do a callback on any objects it finds within the given tlCircle
	end rem
	Method ForEachObjectInBoxCircle(circle:tlCircle, Data:Object, callback:Int(ReturnedObject:Object, Data:Object), Layer:Int = tlLAYER_ALL)
		AreaCheckCount:+1
		objectsfound = 0
		rootnode.ForEachWithinRangeDo(circle, Data, callback, layer)
	End Method
	
	Rem
		bbdoc: Query a quadtree with a #tlLine
		returns: False if the line did not touch anything, otherwise True
		about: This will query the quadtree with a line and perform a callback on all the objects the #tlLine intersects. Pass the quadtree to do the query on, the
		#tlLine to query with, an object you want to pass through to the callback, and the callback itself. It's worth noting that the callback also requires
		you have a #tlCollisionResult parameter which will be passed to the callback function with information about the results of the raycast.
	end rem
	Method ForEachObjectAlongLine:Int(line:tlLine, data:Object, callback:Int(ReturnedObject:Object, Data:Object, Result:tlCollisionResult), Layer:Int = tlLAYER_ALL)
		AreaCheckCount:+1
		objectsfound = 0
		
		Local d:tlVector2 = New tlVector2.Create(line.tformvertices[1].x - line.tformvertices[0].x, line.tformvertices[1].y - line.tformvertices[0].y)
		Local maxdistance:Float = d.DotProduct(d)
		d.Normalise()
		If Not d.x And Not d.y
			Return False
		End If
		
		Local x1:Float = line.tformvertices[0].x + line.world.x
		Local y1:Float = line.tformvertices[0].y + line.world.y

		Local x:Int = x1 / min_nodewidth
		Local y:Int = y1 / min_nodeheight
		
		Local wx:Float = x * min_nodewidth
		Local wy:Float = y * min_nodeheight
		
		Local tMaxX:Float
		Local tMaxY:Float
		Local direction:Int
		
		Local StepX:Int
		Local StepY:Int
		
		Local DeltaX:Float
		Local DeltaY:Float
		
		If d.x < 0
			stepx = -1
			tmaxx = (wx - x1) / d.x
			deltax = (min_nodewidth) / -d.x
		ElseIf d.x > 0
			stepx = 1
			tmaxx = (wx - x1 + min_nodewidth) / d.x
			deltax = (min_nodewidth) / d.x
		Else
			stepx = 0
			direction = 1
			deltax = 0
		End If
		
		If d.y < 0
			stepy = -1
			tmaxy = (wy - y1) / d.y
			deltay = (min_nodeheight) / -d.y
		ElseIf d.y > 0
			stepy = 1
			tmaxy = (wy - y1 + min_nodeheight) / d.y
			deltay = (min_nodeheight) / d.y
		Else
			stepy = 0
			direction = 2
			deltay = 0
		End If
		
		Local objectfound:Int
		Local lastquad:tlQuadTreeNode = Null
		
		Local dv:tlVector2 = New tlVector2.Create(0, 0)
		Local endofline:Int
		
		'if line starts outside of quadtree
		If x < 0 Or x >= dimension Or y < 0 Or y >= dimension
			Local result:tlCollisionResult = rootnode.Box.LineCollide(line)
			If Not result Return False
			If result.intersecting
				Select direction
					Case 0
						While x < 0 Or x >= dimension Or y < 0 Or y >= dimension
							If tMaxX < tMaxY
								tMaxX:+DeltaX
								X = X + stepX
							Else
								tMaxY:+DeltaY
								Y = Y + stepY
							End If
						Wend
					Case 1
						While y < 0 Or y >= dimension
							tMaxY:+DeltaY
							Y:+stepY
						Wend
					Case 2
						While x < 0 Or x >= dimension
							tMaxX:+DeltaX
							X:+stepX
						Wend
				End Select
			Else
				Return False
			End If
		End If
		
		Select direction
			Case 0
				While x >= 0 And x < dimension And y >= 0 And y < dimension
					If map[x, y] <> lastquad
						map[x, y].ForEachObjectAlongLine(line, data, callback, layer)
					End If
					lastquad = map[x, y]
					
					dv.SetPosition(map[x, y].Box.world.x - x1, map[x, y].Box.world.x - x1)
					If endofline Exit
					If dv.DotProduct(dv) > maxdistance endofline = True
					
					If tMaxX < tMaxY
						tMaxX:+DeltaX
						X = X + stepX
					Else
						tMaxY:+DeltaY
						Y = Y + stepY
					End If
				Wend
			Case 1	'vertically only
				While y >= 0 And y < dimension And Not objectfound
					If map[x, y] <> lastquad
						map[x, y].ForEachObjectAlongLine(line, data, callback, layer)
					End If
					lastquad = map[x, y]
					
					dv.SetPosition(map[x, y].Box.world.x - x1, map[x, y].Box.world.x - x1)
					If endofline Exit
					If dv.DotProduct(dv) > maxdistance endofline = True
					
					tMaxY:+DeltaY
					Y:+stepY
				Wend
			Case 2	'horizontally only
				While x >= 0 And x < dimension And Not objectfound
					If map[x, y] <> lastquad
						map[x, y].ForEachObjectAlongLine(line, data, callback, layer)
					End If
					lastquad = map[x, y]
					
					dv.SetPosition(map[x, y].Box.world.x - x1, map[x, y].Box.world.x - x1)
					If endofline Exit
					If dv.DotProduct(dv) > maxdistance endofline = True
					
					tMaxX:+DeltaX
					X:+stepX
				Wend
		End Select
		
		If objectfound
			objectsfound = 1
			Return True
		Else
			Return False
		End If
	End Method
	
	Rem
		bbdoc:
		about:
	end rem
	Method RayCast:Int(px:Float, py:Float, dx:Float, dy:Float, maxdistance:Float = 0, Data:Object, callback:Int(ReturnedObject:Object, Data:Object, Result:tlCollisionResult), Layer:Int = tlLAYER_ALL)
	
		areacheckcount:+1
		objectsfound = 0
		
		Local d:tlVector2 = New tlVector2.Create(dx, dy)
		d.Normalise()
		If Not d.x And Not d.y
			Return False
		End If
				
		Local x:Int = px / min_nodewidth
		Local y:Int = py / min_nodeheight
		
		Local wx:Float = x * min_nodewidth
		Local wy:Float = y * min_nodeheight
		
		Local tMaxX:Float
		Local tMaxY:Float
		Local direction:Int
		
		Local StepX:Int
		Local StepY:Int
		
		Local DeltaX:Float
		Local DeltaY:Float
		
		If d.x < 0
			stepx = -1
			tmaxx = (wx - px) / d.x
			deltax = (min_nodewidth) / -d.x
		ElseIf d.x > 0
			stepx = 1
			tmaxx = (wx - px + min_nodewidth) / d.x
			deltax = (min_nodewidth) / d.x
		Else
			stepx = 0
			direction = 1
			deltax = 0
		End If
		
		If d.y < 0
			stepy = -1
			tmaxy = (wy - py) / d.y
			deltay = (min_nodeheight) / -d.y
		ElseIf d.y > 0
			stepy = 1
			tmaxy = (wy - py + min_nodeheight) / d.y
			deltay = (min_nodeheight) / d.y
		Else
			stepy = 0
			direction = 2
			deltay = 0
		End If
		
		Local objectfound:Int
		Local lastquad:tlQuadTreeNode = Null
		
		Select direction
			Case 0
				While x >= 0 And x < dimension And y >= 0 And y < dimension And Not objectfound
					If map[x, y] <> lastquad
						objectfound = map[x, y].RayCast(px, py, dx, dy, maxdistance, data, callback, layer)
					End If
					lastquad = map[x, y]
					If(tMaxX < tMaxY)
						tMaxX:+DeltaX
						X = X + stepX
					Else
						tMaxY = tMaxY + DeltaY
						Y = Y + stepY
					End If
				Wend
			Case 1	'vertically only
				While y >= 0 And y < dimension And Not objectfound
					If map[x, y] <> lastquad
						objectfound = map[x, y].RayCast(px, py, dx, dy, maxdistance, data, callback, layer)
					End If
					lastquad = map[x, y]
					tMaxY:+DeltaY
					Y = Y + stepY
				Wend
			Case 2	'horizontally only
				While x >= 0 And x < dimension And Not objectfound
					If map[x, y] <> lastquad
						objectfound = map[x, y].RayCast(px, py, dx, dy, maxdistance, data, callback, layer)
					End If
					lastquad = map[x, y]
					tMaxX:+DeltaX
					X = X + stepX
				Wend
		End Select
		
		If objectfound
			objectsfound = 1
			Return True
		Else
			Return False
		End If
	End Method
	
	Rem
		bbdoc: Find out how many objects were found on the last query
		returns: Number of objects found.
		about: Use this to retrieve the amount of object that were found when the last query was run.
	end rem
	Method GetObjectsFound:Int()
		Return objectsfound
	End Method
	
	Rem
		bbdoc: Find out how many objects are currently in the quadtree
		returns: Number of Total Objects in Tree
		about: Use this to retrieve the total amount of objects that are stored in the quadtree.
	end rem
	Method GetTotalObjects:Int()
		Return totalobjectsintree
	End Method
	
	Rem
		bbdoc: Perform some house keeping on the quadtree
		about: This will search the quadtree tree for any empty #tlQuadTreeNodes and unpartition them if necessary. 
	end rem
	Method RunMaintenance()
		rootnode.UnpartitionEmptyQuads()
	End Method
	
	Rem
		bbdoc: Draw the quadtree
		about: This can be used for debugging purposes. *Warning: This will be very slow if the quadtree has more then 6 or 7 levels!*
	end rem
	Method Draw(offsetx:Float = 0, offsety:Float = 0)
		rootnode.Draw(offsetx, offsety)
	End Method
	
	'Internal Stuff-----------------------------------
	Method UpdateRect(r:tlBox)
		'This is run automatically when a tlBox decides it needs to be moved within the quadtree
		r.RemoveFromQuadTree()
		objectsupdated:+1
		AddBox(r)
	End Method

	Method GetQuadNode:tlQuadTreeNode(x:Float, y:Float)
		Local tx:Int = x / min_nodewidth
		Local ty:Int = y / min_nodeheight
		If tx >= 0 And tx < dimension And ty >= 0 And ty < dimension
			Return map[tx, ty]
		End If
		Return Null
	End Method
End Type

Rem
	bbdoc: tlQuadTreeNode type for containing objects within the QuadTree
	about: This type is use internally by #tlQuadTree so you shouldn't have to worry about it.
end rem
Type tlQuadTreeNode
	Field parenttree:tlQuadTree
	Field parent:tlQuadTreeNode
	'Node layout:
	'01
	'23
	Field childnode:tlQuadTreeNode[4]
	Field Box:tlBox
	Field objects:TList = CreateList()
	Field numberofobjects:Int
	Field nodelevel:Int
	Field partitioned:Int
	Field gridx:Int
	Field gridy:Int
	Field dimension:Int
	
	'Internal Stuff------------------------------------
	'This whole type should be handled automatically by the quadtree it belongs to, so you don't have to worry about it.
	Rem
		bbdoc: Create a new tlQuadTreeNode
		about: This will create a new node within the quad tree. You shouldn't have to worry about this, as it's performed automatically as objects are
		added to the quadtree.
	end rem
	Method Create:tlQuadTreeNode(x:Float, y:Float, w:Float, h:Float, _parenttree:tlQuadTree, parentnode:tlQuadTreeNode = Null, gridref:Int = -1)
		Box = New tlBox.Create(x, y, w, h)
		parenttree = _parenttree
		If parentnode
			nodelevel = parentnode.nodelevel + 1
			parent = parentnode
		Else
			nodelevel = 1
		End If
		If parentnode
			dimension = parentnode.dimension / 2
			Select gridref
				Case 0
					gridx = parentnode.gridx
					gridy = parentnode.gridy
				Case 1
					gridx = parentnode.gridx + dimension
					gridy = parentnode.gridy			
				Case 2
					gridx = parentnode.gridx
					gridy = parentnode.gridy + dimension
				Case 3
					gridx = parentnode.gridx + dimension
					gridy = parentnode.gridy + dimension
			End Select
			For Local x:Int = 0 To dimension - 1
				For Local y:Int = 0 To dimension - 1
					parenttree.map[x + gridx, y + gridy] = Self
				Next
			Next
		End If
		Return Self
	End Method
	
	Method Partition()
		'When this quadtreenode contains more objects then parenttree.maxpernode it is partitioned
		childnode[0] = New tlQuadTreeNode.Create(Box.tl_corner.x, Box.tl_corner.y, Box.width / 2, Box.height / 2, parenttree, Self, 0)
		childnode[1] = New tlQuadTreeNode.Create(Box.tl_corner.x + Box.width / 2, Box.tl_corner.y, Box.width / 2, Box.height / 2, parenttree, Self, 1)
		childnode[2] = New tlQuadTreeNode.Create(Box.tl_corner.x, Box.tl_corner.y + Box.height / 2, Box.width / 2, Box.height / 2, parenttree, Self, 2)
		childnode[3] = New tlQuadTreeNode.Create(Box.tl_corner.x + Box.width / 2, Box.tl_corner.y + Box.height / 2, Box.width / 2, Box.height / 2, parenttree, Self, 3)
		partitioned = True
	End Method
	
	Method AddBox(r:tlBox)
		'Adds a new bounding box to the node, and partitions/moves objects down the tree as necessary.
		If Not partitioned
			objects.AddLast(r)
			r.AddQuad(Self)
			numberofobjects:+1
			If numberofobjects > parenttree.maxpernode And nodelevel < parenttree.maxlevels
				If Not partitioned partition()
				For Local rect:tlBox = EachIn objects
					moverectdown(rect)
					RemoveRect(rect)
				Next
			End If
		Else
			moverectdown(r)
		End If
	End Method
	
	Method RemoveRect(r:tlBox)
		'remove a boudning box from the node
		objects.Remove(r)
		numberofobjects:-1
		r.RemoveQuad(Self)
	End Method
	
	Method MoveRectDown(r:tlBox)
		'moves a bounding box down the quadtree to any children it overlaps
		If childnode[0].Box.BoundingBoxOverlap(r) childnode[0].AddBox(r)
		If childnode[1].Box.BoundingBoxOverlap(r) childnode[1].AddBox(r)
		If childnode[2].Box.BoundingBoxOverlap(r) childnode[2].AddBox(r)
		If childnode[3].Box.BoundingBoxOverlap(r) childnode[3].AddBox(r)
	End Method
	
	Method ForEachInAreaDo(area:tlBox, Data:Object, callback:Int(ReturnedObject:Object, Data:Object), velocitycheck:Int, Layer:Int)
		'run a callback on objects found within the nodes that the area overlaps
		If Box.BoundingBoxOverlap(area, velocitycheck)
			If partitioned
				childnode[0].ForEachInAreaDo(area, data, callback, velocitycheck, layer)
				childnode[1].ForEachInAreaDo(area, data, callback, velocitycheck, layer)
				childnode[2].ForEachInAreaDo(area, data, callback, velocitycheck, layer)
				childnode[3].ForEachInAreaDo(area, data, callback, velocitycheck, layer)
			Else
				For Local r:tlBox = EachIn objects
					If r.AreaCheckCount <> parenttree.AreaCheckCount And r.collisionlayer & layer And r <> area
						If r.BoundingBoxOverlap(area, True)
							callback(r, Data)
						End If
						r.AreaCheckCount = parenttree.AreaCheckCount
						parenttree.objectsfound:+1
					End If
				Next
			End If
		End If
	End Method
	
	Method ForEachWithinRangeDo(Range:tlCircle, Data:Object, callback:Int(ReturnedObject:Object, Data:Object), Layer:Int)
		'run a callback on objects found within the nodes that the circle overlaps
		If Box.CircleOverlap(Range)
			If partitioned
				childnode[0].ForEachWithinRangeDo(Range, data, callback, layer)
				childnode[1].ForEachWithinRangeDo(Range, data, callback, layer)
				childnode[2].ForEachWithinRangeDo(Range, data, callback, layer)
				childnode[3].ForEachWithinRangeDo(Range, data, callback, layer)
			Else
				For Local r:tlBox = EachIn objects
					If r.AreaCheckCount <> parenttree.AreaCheckCount And layer & r.collisionlayer And range <> r
						If range.BoundingBoxOverlap(r)
							callback(r, data)
						End If
						r.AreaCheckCount = parenttree.AreaCheckCount
						parenttree.objectsfound:+1
					End If
				Next
				
			End If
		End If
	End Method
	
	Method ForEachObjectAlongLine(Line:tlLine, Data:Object, callback:Int(ReturnedObject:Object, Data:Object, Result:tlCollisionResult), Layer:Int)
		Local result:tlCollisionResult
		For Local r:tlBox = EachIn objects
			If r.AreaCheckCount <> parenttree.areacheckcount And layer & r.collisionlayer And line <> r
				result = r.LineCollide(line)
				If result
					If result.intersecting Or result.willintersect
						callback(r, data, result)
						parenttree.objectsfound:+1
					End If
				End If
				r.AreaCheckCount = parenttree.areacheckcount
			End If
		Next
	End Method
	
	Method RayCast:Int(px:Float, py:Float, dx:Float, dy:Float, maxdistance:Float, Data:Object, callback:Int(ReturnedObject:Object, Data:Object, Result:tlCollisionResult), Layer:Int)
		
		Local result:tlCollisionResult
		Local nearestobject:tlBox
		Local nearestresult:tlCollisionResult
		Local mindistance:Float = $7fffffff
		
		For Local r:tlBox = EachIn objects
			If layer & r.collisionlayer
				result = r.RayCollide(px, py, dx, dy, maxdistance)
				If result.rayorigininside
					mindistance = result.raydistance
					nearestresult = result
					nearestobject = r
					Exit
				End If
				If result.raydistance < mindistance And result.rayintersection
					mindistance = result.raydistance
					nearestresult = result
					nearestobject = r
				End If
			End If
		Next
		
		If nearestobject
			callback(nearestobject, data, nearestresult)
			Return True
		End If
		
		Return False
		
	End Method
	
	Method UnpartitionEmptyQuads()
		'This is run when RunMaintenance is run in the quadtree type.
		If partitioned
			If childnode[0] childnode[0].UnpartitionEmptyQuads()
			If childnode[1] childnode[1].UnpartitionEmptyQuads()
			If childnode[2] childnode[2].UnpartitionEmptyQuads()
			If childnode[3] childnode[3].UnpartitionEmptyQuads()
		Else
			If parent parent.DeleteEmptyPartitions()
		End If
	End Method
	
	Method DeleteEmptyPartitions()
		'deletes the partitions from this node
		If childnode[0].numberofobjects + childnode[1].numberofobjects + childnode[2].numberofobjects + childnode[3].numberofobjects = 0
			If Not childnode[0].partitioned And Not childnode[1].partitioned And Not childnode[2].partitioned And Not childnode[3].partitioned
				partitioned = False
				childnode[0] = Null
				childnode[1] = Null
				childnode[2] = Null
				childnode[3] = Null
			End If
		End If
	End Method
	
	Method Draw(offsetx:Float = 0, offsety:Float = 0)
		'called when the draw method is called in tlQuadTreeNode
		Box.draw(offsetx, offsety)
		If partitioned
			childnode[0].Draw(offsetx, offsety)
			childnode[1].Draw(offsetx, offsety)
			childnode[2].Draw(offsetx, offsety)
			childnode[3].Draw(offsetx, offsety)
		End If
	End Method
End Type

Rem
	bbdoc: Type to store the results of collisions
	about: When you check for a collision between 2 objects (see #CheckCollision) the result of that check will be a #tlCollisionResult. This contains information about
	how the 2 objects collided and can be used to do further calculations. Call #GetIntersecting to find out if the 2 objects overlap each other and call
	#GetWillIntersect to see if they will overlap based on their velocities. #GetSourceBoundary and #GetTargetBoundary will return the object making the collision check and 
	the object being checked against respectively with the exception when using #CheckRayCollision where only the target us set. Preventing objects from overlapping can be achieved by simply calling #PreventOverlap.
end rem
Type tlCollisionResult
	Field willintersect:Int = True
	Field intersecting:Int = True
	Field rayorigininside:Int
	Field translationvector:tlVector2
	Field surfacenormal:tlVector2
	Field rayintersection:tlVector2
	Field raydistance:Float
	Field source:tlBox
	Field target:tlBox
	
	Rem
		bbdoc: Find out if the last collision check is intersecting
		returns: true if there was an intersection
	end rem
	Method GetIntersecting:Int()
		Return intersecting
	End Method
	
	Rem
		bbdoc: Find out if the last collision check is intersecting
		returns: true if there will be an intersection
		about: knowing if there will be an intersection allows you to adjust the position of objects so that visually they will never overlap. Do do this
		you can use the information stored in the translation vector, which is the vector describing how much the objects need to move so that they no longer
		overlap. See #GetTranslationVector
	end rem
	Method GetWillIntersect:Int()
		Return willintersect
	End Method
	
	Rem
		bbdoc: Get the distance from the ray origin to the instersection point
		returns: float value of distance the ray travelled, 0 if there was no intersection
	end rem
	Method GetRayDistance:Float()
		Return raydistance
	End Method
	
	Rem
		bbdoc: Get the translation vector of the collision
		returns: #tlVector2
		about: If the collision check finds that either the objects are intersecting, or they will intersect, then the translation vector hold exactly
		how much they do or will overlap. This can then be used to move the 2 objects apart to prevent them overlapping. Handy if you have a wall that you don't
		want a player to move through. See #PreventOverlap to automate this process further.
	end rem
	Method GetTranslationVector:tlVector2()
		Return translationvector
	End Method
	
	Rem
		bbdoc: Get the intersection point of the raycast
		returns: #tlvector2
		about: If a ray cast has been performed and the ray successfully connected, then this will return the point of intersection as a #tlVector2.
	end rem
	Method GetRayIntersection:tlVector2()
		Return rayintersection
	End Method
	
	Rem
		bbdoc: Gets the Source boundary of a collision check
		returns: #tlBox Or null if no collision occurred
	end rem
	Method GetSourceBoundary:tlBox()
		Return source
	End Method
	
	Rem
		bbdoc: Gets the Target boundary of a collision check
		returns: #tlBox Or null if no collision occurred
	end rem
	Method GetTargetBoundary:tlBox()
		Return source
	End Method

	Rem
		bbdoc: Get the rebound vector
		returns: New #tlVector2 with the resulting rebound vector
		about: When an object collides with a surface you may want to know a resulting vector based on bounce and friction. So you can call this
		and pass the velocity vector of the incoming object, and the amount of bounce and friction to have, where a bounce value of 1 and a friction value of 0
		will result in a perfect bounce.
	end rem
	Method GetReboundVector:tlVector2(v:tlVector2, friction:Float = 0, bounce:Float = 1)
		
		If surfacenormal And (intersecting Or willintersect)
			Local Vn:tlVector2 = surfacenormal.Scale(v.DotProduct(surfacenormal))
			Local Vt:tlVector2 = v.SubtractVector(Vn)
	
			Return vt.Scale(1 - friction).AddVector(vn.Scale(-bounce))
		EndIf
		
		Return v
	End Method
	
	Rem
		bbdoc: Find out if the last ray cast found that the ray originated inside the boundary
		returns: true if the last ray check originated inside the boundary
	end rem
	Method GetRayOriginInside:Int()
		Return rayorigininside
	End Method
End Type

Rem 
	bbdoc: Type for handling Axis Aligned Bounding Boxes
	about: <p>This type can be used to create bounding boxes for the purpose of collision checking. This is the type used to stored objects in #tlQuadTree. It's
	extended by #tlCircle and #tlPolygon. To implement collision checking in you game/app will probably end up inlcluding these as a field within
	your own types, and possibly extending these types so that they can contain a field linking back to your own entity/actor types. Use #SetPosistion and #Move
	to align them in your game world, using these methods also ensures that they will be updated within the quadtree if they belong in one.</p>
	<p>It's worth noting that if you want a bounding box that can be orientated then create a 4 sided poly using a #tlPolygon.</p>
	<p>The world coordinates are stored as a vector within the field World, so you can use world.x and world.y to retreive the coordinates of the box.</p>
end rem
Type tlBox

	Field vertices:tlVector2[]
	Field tformvertices:tlVector2[]
	Field normals:tlVector2[]
	Field tformmatrix:tlMatrix2 = New tlMatrix2.Create()
	
	Field tl_corner:tlVector2	'top left corner
	Field br_corner:tlVector2	'bottom right corner
	
	Field width:Float
	Field height:Float
	
	Field quadlist:TList = CreateList()	'list of quad nodes this rect is in
	Field quads:Int						'number of quads the rect is in
	Field AreaCheckCount:Int
	
	Field quadtree:tlQuadTree
	Field collisiontype:Int
	
	Field world:tlVector2
	Field boxoffset:tlVector2 = New tlVector2.Create(0, 0)
	
	Field scale:tlVector2 = New tlVector2.Create(1, 1)
	Field velocity:tlVector2 = New tlVector2.Create(0, 0)
	
	Field handle:tlVector2 = New tlVector2.Create(0, 0)
	
	Field collisionlayer:Int
		
	Field _data:Object
		
	Rem
		bbdoc: Create a new #tlBox
		returns: New tlBox
		about: Creates a new Bounding box that you can use for collision checking and adding to a #tlQuadTree. The x and y coordinates represent
		the top left corner of the bounding box. You can also assign some data to the boundary as handy way to store some extra info about the boundary.
	end rem
	Method Create:tlBox(x:Float, y:Float, w:Float, h:Float, layer:Int = tlLAYER_1, Data:Object = Null)
		If w < 0
			x:+w
			w = Abs(w)
		End If
		If h < 0
			y:+h
			h = Abs(h)
		End If
		vertices = New tlVector2[4]
		handle.x = w / 2
		handle.y = h / 2
		vertices[0] = New tlVector2.Create(-handle.x, -handle.y)
		vertices[1] = New tlVector2.Create(-handle.x, h - handle.y)
		vertices[2] = New tlVector2.Create(w - handle.x, h - handle.y)
		vertices[3] = New tlVector2.Create(w - handle.x, -handle.y)
		normals = New tlVector2[4]
		tformvertices = New tlVector2[4]
		For Local c:Int = 0 To 3
			normals[c] = New tlVector2.Create(0, 0)
			tformvertices[c] = New tlVector2.Create(0, 0)
		Next
		handle.x = 0
		handle.y = 0
		tl_corner = New tlVector2.Create(0, 0)
		br_corner = New tlVector2.Create(0, 0)
		world = New tlVector2.Create(x + w / 2, y + h / 2)
		updatenormals()
		tform()
		collisionlayer = layer
		_data = data
		Return Self
	End Method
	
	Rem
		bbdoc: Assign an object to the boundary
		about: This can be handy to store extra custom info about the boundary. 
	end rem
	Method SetData(d:Object)
		_data = d
	End Method
	
	Rem
		bbdoc: Get the data assigned to this boundary
		about: Use this to retrieve the custom data you have assign to the boundary.
	end rem
	Method GetData:Object()
		Return _data
	End Method
	
	Rem
		bbdoc: Get the collision layer that this boundary is on
		Returns: The Collision layer flag
		about: Every boundary can exist on a sepcific layer from 1-32 to make it easier to handle what objects you want to collide with each other.
	End Rem
	Method GetCollisionLayer:Int()
		Return collisionlayer
	End Method

	Rem
		bbdoc: Set the collision layer that this boundary is on
		about: The layer a boundary is on can determine what other boundarys this one can collide with. You may not want some objects to be able to collide
		with each other, so you can arrange them of different layers. There are 32 layers, assigned to constants: tlLAYER_1, tlLAYER2, tlLAYER_3.. and so on up
		to 32, so to assign a layer, simply pass the appropriate constant:
		&{MyBox.SetCollisionLayer(tlLAYER_1)}
		You can also assign to more then one layer using OR:
		&{MyBox.SetCollisionLayer(tlLAYER_1 | tlLAYER_2 | tlLAYER_3)}
		Finally, assign it to all layers using:
		&{MyBox.SetCollisionLayer(tlLAYER_ALL)}
	End Rem
	Method SetCollisionLayer(Layer:Int)
		collisionlayer = layer
	End Method
	
	Rem
		bbdoc: Set the position of the bounding box.
		about: This sets the position of the top left corner of the bounding box. If the box is within quadtree it will automatically update itself
		within it.
	end rem
	Method SetPosition(x:Float, y:Float)
		tl_corner.Move(x - world.x, y - world.y)
		br_corner.Move(x - world.x, y - world.y)
		world.SetPosition(x, y)
		If needsmoving() quadtree.UpdateRect(Self)
	End Method
	
	Rem
		bbdoc: Move the bounding box by a given amount.
		about: This sets the position of the top left corner of the bounding box by moving it by the x and y amount. If the box is within quadtree it 
		will automatically update itself within it.
	end rem
	Method Move(x:Float, y:Float)
		world.Move(x, y)
		tl_corner.Move(x, y)
		br_corner.Move(x, y)
		If needsmoving() quadtree.UpdateRect(Self)
	End Method
	
	Rem
		bbdoc: Update the position of the boundary
		about: You can use this method to update it's position according to its current velocity vector
	end rem
	Method UpdatePosition()
		move(velocity.x, velocity.y)
	End Method
	
	Rem
		bbdoc: Get the x world coordinate of the boundary
		returns: Float with the current x coordinate
		about: You can use this to find out the current x coordinate of the boundary. This would be especially useful if you have just used #PreventOverlap
		and need to know the new position of the object to update your game object.
	end rem
	Method GetWorldX:Float()
		Return world.x
	End Method
	
	Rem
		bbdoc: Get the y world coordinate of the boundary
		returns: Float with the current y coordinate
		about: You can use this to find out the current y coordinate of the boundary. This would be especially useful if you have just used #PreventOverlap
		and need to know the new position of the object to update your game object.
	end rem
	Method GetWorldY:Float()
		Return world.y
	End Method
	
	Rem
		bbdoc: Set the velocity of the boundary
		about: It's import to set the velocity of the boundary so that collisions can be more accurately calculated. If you're attaching this
		to an entity in your game then you'll just need to match this to your entities velocity.
	end rem
	Method SetVelocity(Velocity_x:Float, Velocity_y:Float)
		velocity.SetPosition(velocity_x, velocity_y)
	End Method
	
	Rem
		bbdoc: Set the scale of the Box
		about: This sets scale of the Box.
	end rem
	Method SetScale(x:Float, y:Float)
		scale.SetPosition(x, y)
		TForm()
	End Method
	
	Rem
		bbdoc: Find out if a point is within the bounding box
		returns: True if the point is within
		about: Use this to find out if a point at x,y falls with the bounding box of this #tlBox
	end rem
	Method PointInside:Int(x:Float, y:Float)
		Return x >= tl_corner.x And x <= br_corner.x And y >= tl_corner.y And y <= br_corner.y
	End Method
	
	Rem
		bbdoc: Compare this #tlBox with another to see if they overlap
		returns: True if they do overlap
		about: Use this to find out if this #tlBox overlaps the #tlBox you pass to it. This is a very simple overlap to see if the bounding box overlaps only
		Set VelocityCheck to true if you want to see if they will overlap next frame based on their velocities.
	end rem
	Method BoundingBoxOverlap:Int(rect:tlBox, VelocityCheck:Int = False)
		Local check1:Int = tl_corner.x <= rect.br_corner.x And br_corner.x >= rect.tl_corner.x And tl_corner.y <= rect.br_corner.y And br_corner.y >= rect.tl_corner.y
		If velocitycheck
			Local check2:Int = tl_corner.x + velocity.x <= rect.br_corner.x + rect.velocity.x And br_corner.x + velocity.x >= rect.tl_corner.x + rect.velocity.x And tl_corner.y + velocity.y <= rect.br_corner.y + rect.velocity.y And br_corner.y + velocity.y >= rect.tl_corner.y + rect.velocity.y
			If check2 Return True
		End If
		Return check1
	End Method
		
	Rem
		bbdoc: Find out if a #tlBox lies within this objects bounding box
		returns: True if it is within
		about: If you need to know whether a #tlBox you pass to this method, lies entirely with this #tlBox (no overlapping) then you can use this method. 
		Remember, if you call this method from a poly, line or circle, it will only check against the bounding boxes.
	end rem
	Method RectWithin:Int(rect:tlBox)
		Return tl_corner.x < rect.tl_corner.x And br_corner.x > rect.br_corner.x And tl_corner.y < rect.tl_corner.y And br_corner.y > rect.br_corner.y
	End Method
	
	Rem
		bbdoc: Compare this #tlBox with a #tlCircle
		returns: True if they do overlap
		about: This will perfrom a simple bounding box to circle collision check on the #tlCircle you pass to it. 
	end rem
	Method CircleOverlap:Int(circle:tlCircle)
		If Not BoundingBoxOverlap(circle) Return False
		If pointinside(circle.world.x, circle.world.y) Return True
		If LineToCircle(tl_corner.x, tl_corner.y, br_corner.x, tl_corner.y, circle.world.x, circle.world.y, circle.radius) Return True
		If LineToCircle(br_corner.x, tl_corner.y, br_corner.x, br_corner.y, circle.world.x, circle.world.y, circle.radius) Return True
		If LineToCircle(br_corner.x, br_corner.y, tl_corner.x, br_corner.y, circle.world.x, circle.world.y, circle.radius) Return True
		If LineToCircle(tl_corner.x, br_corner.y, tl_corner.x, tl_corner.y, circle.world.x, circle.world.y, circle.radius) Return True
	End Method
	
	Rem
		bbdoc: Check for a collision with another #tlBox
		returns: #tlCollisionResult type containing info about the collision
		about: Use this to check for a collision with another #tlBox that you pass to the method. You can then use the information stored in 
		#tlCollisionResult to perform various things based on the result of the collision check.
	end rem
	Method BoxCollide:tlCollisionResult(Box:tlBox)
		
		Local result:tlCollisionResult = New tlCollisionResult
		
		Local min0:Float, max0:Float
		Local min1:Float, max1:Float
		
		Local overlapdistance:Float
		Local veloverlapdistance:Float
		Local minoverlapdistance:Float = $7fffffff
		
		For Local c:Int = 0 To 1
		
			Select c
				Case 0
					min0 = tl_corner.y
					max0 = br_corner.y
					min1 = Box.tl_corner.y
					max1 = Box.br_corner.y
					
					overlapdistance = IntervalDistance(min0, max0, min1, max1)
					If overlapdistance > 0
						result.intersecting = False
					End If
					
					If velocity.y Or Box.velocity.y
						If velocity.y
							min0:+velocity.y
							max0:+velocity.y
						End If
						If Box.velocity.y
							min1:+Box.velocity.y
							max1:+Box.velocity.y
						End If
						veloverlapdistance = IntervalDistance(min0, max0, min1, max1)
						If veloverlapdistance > 0
							result.willintersect = False
						Else
							overlapdistance = veloverlapdistance
						End If
					Else
						result.willintersect = False
					End If
					
					If Not result.intersecting And Not result.willintersect Return result
					
					overlapdistance = Abs(overlapdistance)
								
					If overlapdistance < minoverlapdistance
						minoverlapdistance = overlapdistance
						If world.y > Box.world.y
							result.translationvector = New tlVector2.Create(0, minoverlapdistance)
						Else
							result.translationvector = New tlVector2.Create(0, -minoverlapdistance)
						End If
					End If
					
				Case 1
					min0 = tl_corner.x
					max0 = br_corner.x
					min1 = Box.tl_corner.x
					max1 = Box.br_corner.x
					
					overlapdistance = IntervalDistance(min0, max0, min1, max1)
					If overlapdistance > 0
						result.intersecting = False
					End If
					
					If velocity.x Or Box.velocity.x
						If velocity.x
							min0:+velocity.x
							max0:+velocity.x
						End If
						If Box.velocity.x
							min1:+Box.velocity.x
							max1:+Box.velocity.x
						End If
						veloverlapdistance = IntervalDistance(min0, max0, min1, max1)
						If veloverlapdistance > 0
							result.willintersect = False
						Else
							overlapdistance = veloverlapdistance
						End If
					Else
						result.willintersect = False
					End If
					
					If Not result.intersecting And Not result.willintersect Return result
					
					overlapdistance = Abs(overlapdistance)
								
					If overlapdistance < minoverlapdistance
						minoverlapdistance = overlapdistance
						If world.x > Box.world.x
							result.translationvector = New tlVector2.Create(minoverlapdistance, 0)
						Else
							result.translationvector = New tlVector2.Create(-minoverlapdistance, 0)
						End If
					End If
					
			End Select
			
		Next
		
		result.source = Self
		result.target = Box
		Return result
	
	End Method
	
	Rem
		bbdoc: Check for a collision with a #tlCircle
		returns: #tlCollisionResult type containing info about the collision
		about: Use this to check for a collision with a #tlCircle that you pass to the method. You can then use the information stored in 
		#tlCollisionResult to perform various things based on the result of the collision check.
	end rem
	Method CircleCollide:tlCollisionResult(circle:tlCircle)
		If Not BoundingBoxOverlap(circle, True) Return Null
	
		Local result:tlCollisionResult = New tlCollisionResult
		
		Local axis:tlVector2
		
		Local min0:Float, max0:Float
		Local min1:Float, max1:Float
		
		Local dotoffset:Float
		
		Local velocityoffset0:Float
		Local velocityoffset1:Float
		
		Local overlapdistance:Float
		Local veloverlapdistance:Float
		Local minoverlapdistance:Float = $7fffffff
		
		
		Local woffset:tlVector2 = New tlVector2.Create(world.x - circle.world.x, world.y - circle.world.y)

		For Local c:Int = 0 To 2
			
			If c < 2
				axis = normals[c]
			Else
				axis = GetVoronoiAxis(circle.world)
				If Not axis Exit
			End If
		
			project(axis, min0, max0)
			circle.Project(axis, min1, max1)
			
			dotoffset = axis.DotProduct(woffset)
			
			min0:+dotoffset
			max0:+dotoffset
			
			overlapdistance = intervaldistance(min0, max0, min1, max1)
			If overlapdistance > 0
				result.intersecting = False
			End If
			
			If velocity.x Or velocity.y Or circle.velocity.x Or circle.velocity.y
				If velocity.x Or velocity.y
					velocityoffset0 = axis.DotProduct(velocity)
					min0:+velocityoffset0
					max0:+velocityoffset0
				End If
				If circle.velocity.x Or circle.velocity.y
					velocityoffset1 = axis.DotProduct(circle.velocity)
					min1:+velocityoffset1
					max1:+velocityoffset1
				End If
				veloverlapdistance = IntervalDistance(min0, max0, min1, max1)
				If veloverlapdistance > 0
					result.willintersect = False
				Else
					overlapdistance = veloverlapdistance
				End If
			Else
				result.willintersect = False
			End If
			
			If Not result.intersecting And Not result.willintersect Return result
			
			overlapdistance = Abs(overlapdistance)
						
			If overlapdistance < minoverlapdistance
				minoverlapdistance = overlapdistance
				result.surfacenormal = axis.Clone()
				Local polytopolyvec:tlVector2 = world.SubtractVector(circle.world)
				If polytopolyvec.DotProduct(result.surfacenormal) < 0 result.surfacenormal.SetPosition(-result.surfacenormal.x, -result.surfacenormal.y)
			End If
			
		Next
		
		result.translationvector = result.surfacenormal.Scale(minoverlapdistance)
		result.source = Self
		result.target = circle
		Return result
	End Method

	Rem
		bbdoc: Check for a collision with a #tlLine
		returns: #tlCollisionResult type containing info about the collision
		about: Use this to check for a collision with a #tlLine that you pass to the method. You can then use the information stored in 
		#tlCollisionResult to perform various things based on the result of the collision check.
	end rem
	Method LineCollide:tlCollisionResult(Line:tlLine)
		If Not BoundingBoxOverlap(Line, True) Return Null
	
		Local result:tlCollisionResult = New tlCollisionResult
		
		Local axis:tlVector2
		
		Local min0:Float, max0:Float
		Local min1:Float, max1:Float
		
		Local dotoffset:Float
		
		Local velocityoffset0:Float
		Local velocityoffset1:Float
		
		Local overlapdistance:Float
		Local veloverlapdistance:Float
		Local minoverlapdistance:Float = $7fffffff
		
		
		Local woffset:tlVector2 = New tlVector2.Create(world.x - Line.world.x, world.y - Line.world.y)
		
		For Local c:Int = 0 To 3
		
			If c < 2
				axis = Line.normals[c]
			Else
				axis = normals[c - 1]
			End If
		
			project(axis, min0, max0)
			Line.Project(axis, min1, max1)
			
			dotoffset = axis.DotProduct(woffset)
			
			min0:+dotoffset
			max0:+dotoffset
			
			overlapdistance = intervaldistance(min0, max0, min1, max1)
			If overlapdistance > 0
				result.intersecting = False
			End If
			
			If velocity.x Or velocity.y Or Line.velocity.x Or Line.velocity.y
				If velocity.x Or velocity.y
					velocityoffset0 = axis.DotProduct(velocity)
					min0:+velocityoffset0
					max0:+velocityoffset0
				End If
				If Line.velocity.x Or Line.velocity.y
					velocityoffset1 = axis.DotProduct(Line.velocity)
					min1:+velocityoffset1
					max1:+velocityoffset1
				End If
				veloverlapdistance = IntervalDistance(min0, max0, min1, max1)
				If veloverlapdistance > 0
					result.willintersect = False
				Else
					overlapdistance = veloverlapdistance
				End If
			Else
				result.willintersect = False
			End If
			
			If Not result.intersecting And Not result.willintersect Return result
			
			overlapdistance = Abs(overlapdistance)
						
			If overlapdistance < minoverlapdistance
				minoverlapdistance = overlapdistance
				result.surfacenormal = axis.Clone()
				Local vec:tlVector2 = world.SubtractVector(Line.world)
				If vec.DotProduct(result.surfacenormal) < 0 result.surfacenormal.SetPosition(-result.surfacenormal.x, -result.surfacenormal.y)
			End If
			
		Next
		
		result.translationvector = result.surfacenormal.Scale(minoverlapdistance)
		result.source = Self
		result.target = Line
		Return result
	End Method

	Rem
		bbdoc: Check for a collision with a #tlPolygon
		returns: #tlCollisionResult type containing info about the collision
		about: Use this to check for a collision with a #tlPolygon that you pass to the method. You can then use the information stored in 
		#tlCollisionResult to perform various things based on the result of the collision check.
	end rem
	Method PolyCollide:tlCollisionResult(poly:tlPolygon)
		If Not BoundingBoxOverlap(Poly, True) Return Null

		Local result:tlCollisionResult = New tlCollisionResult
		
		Local axis:tlVector2
		
		Local min0:Float, max0:Float
		Local min1:Float, max1:Float
		
		Local dotoffset:Float
		
		Local velocityoffset0:Float
		Local velocityoffset1:Float
		
		Local overlapdistance:Float
		Local veloverlapdistance:Float
		Local minoverlapdistance:Float = $7fffffff
		
		
		Local woffset:tlVector2 = New tlVector2.Create(world.x - poly.world.x, world.y - poly.world.y)

		For Local c:Int = 0 To poly.vertices.Length + 1
		
			If c < poly.vertices.Length
				axis = poly.normals[c]
			Else
				axis = normals[c - poly.vertices.Length]
			End If
		
			project(axis, min0, max0)
			poly.Project(axis, min1, max1)
			
			dotoffset = axis.DotProduct(woffset)
			
			min0:+dotoffset
			max0:+dotoffset
			
			overlapdistance = intervaldistance(min0, max0, min1, max1)
			If overlapdistance > 0
				result.intersecting = False
			End If
			
			If velocity.x Or velocity.y Or poly.velocity.x Or poly.velocity.y
				If velocity.x Or velocity.y
					velocityoffset0 = axis.DotProduct(velocity)
					min0:+velocityoffset0
					max0:+velocityoffset0
				End If
				If poly.velocity.x Or poly.velocity.y
					velocityoffset1 = axis.DotProduct(poly.velocity)
					min1:+velocityoffset1
					max1:+velocityoffset1
				End If
				veloverlapdistance = IntervalDistance(min0, max0, min1, max1)
				If veloverlapdistance > 0
					result.willintersect = False
				Else
					overlapdistance = veloverlapdistance
				End If
			Else
				result.willintersect = False
			End If
			
			If Not result.intersecting And Not result.willintersect Return result
			
			overlapdistance = Abs(overlapdistance)
						
			If overlapdistance < minoverlapdistance
				minoverlapdistance = overlapdistance
				result.surfacenormal = axis.Clone()
				Local vec:tlVector2 = world.SubtractVector(poly.world)
				If vec.DotProduct(result.surfacenormal) < 0 result.surfacenormal.SetPosition(-result.surfacenormal.x, -result.surfacenormal.y)
			End If
			
		Next
		
		result.translationvector = result.surfacenormal.Scale(minoverlapdistance)
		result.source = Self
		result.target = poly
		Return result
	End Method
	
	Rem
		bbdoc: See is a ray collides with this #tlbox
		returns: #tlCollisionResult with the results of the collision
		about: You can use this to test for a collision with a ray. Pass the origin of the ray with px and py, and set the direction of the ray with dx and dy.
		dx and dy will be normalised and extended infinitely, if maxdistance equals 0 (default), otherwise set maxdistance to how ever far you want the ray 
		to extend to. If the ray starts inside the box then result.rayorigininside will be set to true.
	end rem
	Method RayCollide:tlCollisionResult(px:Float, py:Float, dx:Float, dy:Float, maxdistance:Float = 0)
		
		Local result:tlCollisionResult = New tlCollisionResult
		
		If PointInside(px, py)
			result.rayorigininside = True
			result.rayintersection = New tlVector2.Create(0, 0)
			Return result
		End If
		
		Local p:tlVector2 = CreateVector2(px, py)
		Local d:tlVector2 = CreateVector2(dx, dy)
		
		Local raydot:Float
		Local edge:tlVector2
		Local iedge:tlVector2
		
		Local vw:tlVector2
		Local intersect:tlVector2
		Local distance:Float
		
		d.Normalise()
		
		For Local c:Int = 0 To 3
			raydot = d.DotProduct(normals[c])
			If raydot < 0 And p.SubtractVector(tformvertices[c].AddVector(world)).DotProduct(normals[c]) > 0
				vw = tformvertices[c].AddVector(world)
				distance = normals[c].DotProduct(p.SubtractVector(vw))
				distance = Abs(distance / raydot)
				If (maxdistance > 0 And distance <= maxdistance) Or maxdistance = 0
					intersect = d.Scale(distance).AddVector(p)
					vw = intersect.SubtractVector(world)
					If c = 0
						edge = tformvertices[3].SubtractVector(tformvertices[c])
						iedge = tformvertices[3].SubtractVector(vw)
					Else
						edge = tformvertices[c - 1].SubtractVector(tformvertices[c])
						iedge = tformvertices[c - 1].SubtractVector(vw)
					End If
					raydot = edge.DotProduct(iedge)
					If raydot >= 0 And raydot <= edge.DotProduct(edge)
						result.rayintersection = intersect
						result.surfacenormal = normals[c]
						result.raydistance = distance
						result.target = Self
						Return result
					End If
				End If
			End If
		Next
		
		result.intersecting = False
		result.willintersect = False
		
		Return result
	
	End Method
	
	Rem
		bbdoc: Draw this tlBox
		about: Use this if you need to draw the bounding box for debugging purposes
	end rem
	Method Draw(offsetx:Float = 0, offsety:Float = 0, boundingbox:Int = False)
		DrawLine (tl_corner.x - offsetx, tl_corner.y - offsety, br_corner.x - offsetx, tl_corner.y - offsety, False)
		DrawLine (br_corner.x - offsetx, tl_corner.y - offsety, br_corner.x - offsetx, br_corner.y - offsety, False)
		DrawLine (br_corner.x - offsetx, br_corner.y - offsety, tl_corner.x - offsetx, br_corner.y - offsety, False)
		DrawLine (tl_corner.x - offsetx, br_corner.y - offsety, tl_corner.x - offsetx, tl_corner.y - offsety, False)
	End Method
	
	Rem
		bbdoc: Remove the tlBox from the quadtree
		about: This will remove the tlBox from the quadtree. You'll need to do this when an actor/entity is destroyed, blown up or whatever!
	end rem
	Method RemoveFromQuadTree()
		For Local q:tlQuadTreeNode = EachIn quadlist
			q.RemoveRect(Self)
		Next
		quadtree.totalobjectsintree:-1
	End Method
	
	Rem
		bbdoc: Get the collision type of the Box
		returns: Either tlBOX_COLLISION, tlCIRCLE_COLLISION, tlLINE_COLLISION or tlPOLY_COLLISION
		about: the collision type can help you determine what type of collision you should be performing on objects calledback from quadtree queries.
	end rem
	Method GetCollisionType:Int()
		Return collisiontype
	End Method
	
	Rem
		bbdoc: Prevent the boundary from overlapping another based on the result of a collision.
		about: When you check for a collision, the results of that collision are stored with a #tlCollisionResult. This can be passed to this method
		to prevent 2 boundaries from overlapping. If push is set to true, then the source boundary will push the target boundary along it's velocity vector.
	end rem
	Method PreventOverlap(result:tlCollisionResult, push:Int = False)
		If result
			If Not push
				If result.willintersect
					If Self = result.source
						move(result.translationvector.x, result.translationvector.y)
					Else
						result.target.move(-result.translationvector.x, -result.translationvector.y)
					End If
				ElseIf result.intersecting
					If Self = result.source
						move(result.translationvector.x, result.translationvector.y)
					Else
						move(-result.translationvector.x, -result.translationvector.y)
					End If
				End If
			Else
				If result.willintersect
					If Self = result.source
						result.target.move(-result.translationvector.x, -result.translationvector.y)
					Else
						result.source.move(result.translationvector.x, result.translationvector.y)
					End If
				ElseIf result.intersecting
					If Self = result.source
						result.target.move(-result.translationvector.x, -result.translationvector.y)
					Else
						result.source.move(result.translationvector.x, result.translationvector.y)
					End If
				End If
			End If
		End If
	End Method
	
	Rem
		bbdoc: Get a poly represting the shadow of the box
		returns: tList of tlPolygons representing each shadow cast by each line in the box
		about: This will take a light located at Light:tlVector2 and create a list of tlPolygons representing a shadow cast by each line in the box.
	end rem
	Method GetShadowPolys:TList (Light:tlVector2, lType:Int = tlDIRECTIONAL_LIGHT, lengthfactor:Float = 1)
	
		Local sedge1:tlVector2
		Local sedge2:tlVector2
		Local lv1:tlVector2
		Local lv2:tlVector2
		Local shadows:TList = CreateList()
		Local lastc:Int = 3
		
		Select ltype
			Case tlSPOT_LIGHT
				lv1 = light.SubtractVector(tformvertices[3].AddVector(world))
				For Local c:Int = 0 To 3
					lv2 = light.SubtractVector(tformvertices[c].AddVector(world))
					If lv2.DotProduct(normals[c]) < 0
						sedge1 = tformvertices[lastc].AddVector(world).subtractVector(lv1.Scale(lengthfactor))
						sedge2 = tformvertices[c].AddVector(world).subtractVector(lv2.Scale(lengthfactor))
						shadows.AddLast(New tlPolygon.CreatePolyWorld([tformvertices[lastc].x + world.x, tformvertices[lastc].y + world.y,  ..
											  sedge1.x, sedge1.y,  ..
											  sedge2.x, sedge2.y,  ..
											  tformvertices[c].x + world.x, tformvertices[c].y + world.y]))
					End If
					lv1 = lv2
					lastc=c
				Next
			Case tlDIRECTIONAL_LIGHT
				light = light.Scale(-1)
				For Local c:Int = 0 To 3
					If light.DotProduct(normals[c]) < 0
						sedge1 = tformvertices[lastc].AddVector(world).subtractVector(light.Scale(lengthfactor))
						sedge2 = tformvertices[c].AddVector(world).subtractVector(light.Scale(lengthfactor))
						shadows.AddLast(New tlPolygon.CreatePolyWorld([tformvertices[lastc].x + world.x, tformvertices[lastc].y + world.y,  ..
											  sedge1.x, sedge1.y,  ..
											  sedge2.x, sedge2.y,  ..
											  tformvertices[c].x + world.x, tformvertices[c].y + world.y]))
					End If
					lv1 = lv2
					lastc=c
				Next
		End Select
		
		Return shadows
	
	End Method
	
	'internal stuff---------------------------------
	Method AddQuad(q:tlQuadTreeNode)
		'tlBoundaries are aware of all the quadtreenodes they exist within, so when they're added to a node, that node is added to the Box's list of nodes.
		quadlist.AddLast(q)
		quads:+1
	End Method
	
	Method RemoveQuad(q:tlQuadTreeNode)
		'removes a node from the boundaries list of nodes.
		quadlist.Remove(q)
		quads:-1
	End Method
	
	Method GetVoronoiAxis:tlVector2(point:tlVector2)
		'Finds the voronoi region of a point and returns the axis vector between the nearest vertex and the point.
		'returns null is the region is an edge rather then a vector.
		If point.x >= tl_corner.x And point.x <= br_corner.x Return Null
		If point.y >= tl_corner.y And point.y <= br_corner.y Return Null
		
		Local axis:tlVector2
		
		If point.x < tl_corner.x And point.y < tl_corner.y
			axis = point.SubtractVector(tl_corner)
			axis.Normalise()
			Return axis
		ElseIf point.x > br_corner.x And point.y < tl_corner.y
			axis = New tlVector2.Create(point.x - br_corner.x, point.y - tl_corner.y)
			axis.Normalise()
			Return axis
		ElseIf point.x < tl_corner.x And point.y > br_corner.y
			axis = New tlVector2.Create(point.x - tl_corner.x, point.y - br_corner.y)
			axis.Normalise()
			Return axis
		ElseIf point.x > br_corner.x And point.y > br_corner.y
			axis = point.SubtractVector(br_corner)
			axis.Normalise()
			Return axis
		End If
		
		Return Null
		
	End Method
	
	Method NeedsMoving:Int()
		'This determines whether the tlBox needs to move within the quadtree. If it exists within more then 1 quad (ie., it overlaps quads), then 
		'it will always be moved as there's no easy way to say whether it still overlaps the same nodes or not (atleast not without more Box check which 
		'I don't think's worth it). If it only exists within 1 node then it does a quick check to see if it is still contained entirely within that node, otherwise
		'it adds itself back into the quadtree
		If quads > 1
			Return True
		ElseIf quads = 1
			Local q:tlQuadTreeNode = tlQuadTreeNode(quadlist.First())
			If q
				If q.Box.RectWithin(Self)
					Return False
				Else
					Return True
				End If
			End If
		EndIf
	End Method

	Method UpdateNormals()
		Local v1:tlVector2 = vertices[3]
		Local v2:tlVector2
		For Local c:Int = 0 To 3
			v2 = vertices[c]
			normals[c].SetPosition(-(v2.y - v1.y), v2.x - v1.x)
			normals[c].Normalise()
			v1 = v2
		Next
	End Method
	
	Method UpdateDimensions()
		'If the scale of the poly has changed then the width and height values need to be updated
		tl_corner.SetPosition(tformvertices[0].x + world.x, tformvertices[0].y + world.y)
		br_corner.SetPosition(tformvertices[2].x + world.x, tformvertices[2].y + world.y)
		width = br_corner.x - tl_corner.x
		height = br_corner.y - tl_corner.y
	End Method
	
	Method TForm()
		For Local i:Int = 0 To 3
			tformvertices[i].SetPosition(vertices[i].x + handle.x, vertices[i].y + handle.y)
			tformvertices[i] = tformvertices[i].Multiply(scale)
		Next
		UpdateDimensions()
	End Method
	
	Method Project(axis:tlVector2, minimum:Float Var, maximum:Float Var)
		'This projects the Box onto an axis and lets us know the min and max dotproduct values
		Local dotproduct:Float = axis.DotProduct(tformvertices[0])
		minimum = dotproduct
		maximum = dotproduct
		For Local c:Int = 1 To 3
			dotproduct = tformvertices[c].DotProduct(axis)
			If dotproduct < minimum
				minimum = dotproduct
			ElseIf dotproduct > maximum
				maximum = dotproduct
			End If
		Next
	End Method

End Type

Rem
	bbdoc: tlCircle for circular boundaries for collision checking
	about: This extends #tlBox so automatically inherits a bounding box, which can be checked first before doing a more complicated circle collision
	check. You can add this type to a #tlQuadTree just as though it were a standard #tlBox, as the quadtree only concerns itself with Boxs.
end rem
Type tlCircle Extends tlBox
	
	Field radius:Float
	Field tformradius:Float
	
	Rem
		bbdoc: Create a #tlCircle
		returns: New #tlCircle
		about: Create a new #tlCircle at the given coordinates with the given radius. The coordinates will represent where the center of the circle is located
		in the world. You can also assign some data to the boundary as handy way to store some extra info about the boundary.
	end rem
	Method CreateCircle:tlCircle(x:Float, y:Float, _radius:Float, layer:Int = tlLAYER_1, Data:Object = Null)
		radius = _radius
		tl_corner = New tlVector2.Create(x - radius, y - radius)
		br_corner = New tlVector2.Create(x + radius, y + radius)
		world = New tlVector2.Create(x, y)
		width = radius * 2
		height = radius * 2
		collisiontype = tlCIRCLE_COLLISION
		tformradius = radius
		collisionlayer = layer
		_data = data
		Return Self
	End Method
	
	Rem
		bbdoc: Find out if a point is within the circle
		returns: True if the point is within
		about: Use this to find out if a point at x,y falls with the radius of this #tlCircle
	end rem
	Method PointInside:Int(x:Float, y:Float)
		Return getdistance(x, y, world.x, world.y) <= radius
	End Method
	
	Rem
		bbdoc: Compare this circle with another #tlCircle
		returns: True if they do overlap
		about: This will perfrom a simple circle to circle collision check on the #tlCircle you pass to it.
	end rem
	Method CircleOverlap:Int(circle:tlCircle)
		Return getdistance(world.x, world.y, circle.world.x, circle.world.y) <= radius + circle.radius
	End Method
	
	Rem
		bbdoc: Compare this #tlCircle with a #tlBox
		returns: True if they do overlap
		about: This will perfrom a simple circle to bounding box overlap check on the #tlBox you pass to it.
	end rem
	Method BoundingBoxOverlap:Int(rect:tlBox, VelocityCheck:Int = False)
		'If Not rect.BoundingBoxOverlap(Self, velocitycheck) Return False
		If rect.pointinside(world.x, world.y) Return True
		If LineToCircle(rect.tl_corner.x, rect.tl_corner.y, rect.br_corner.x, rect.tl_corner.y, world.x, world.y, radius) Return True
		If LineToCircle(rect.br_corner.x, rect.tl_corner.y, rect.br_corner.x, rect.br_corner.y, world.x, world.y, radius) Return True
		If LineToCircle(rect.br_corner.x, rect.br_corner.y, rect.tl_corner.x, rect.br_corner.y, world.x, world.y, radius) Return True
		If LineToCircle(rect.tl_corner.x, rect.br_corner.y, rect.tl_corner.x, rect.tl_corner.y, world.x, world.y, radius) Return True
	End Method
	
	Rem
		bbdoc: Check for a collision with a #tlBox
		returns: #tlCollisionResult type containing info about the collision
		about: Use this to check for a collision with a #tlBox that you pass to the method. You can then use the information stored in 
		#tlCollisionResult to perform various things based on the result of the collision check.
	end rem
	Method BoxCollide:tlCollisionResult(Box:tlBox)
		If Not Super.BoundingBoxOverlap(Box, True) Return Null
	
		Local result:tlCollisionResult = New tlCollisionResult
		
		Local axis:tlVector2
		
		Local min0:Float, max0:Float
		Local min1:Float, max1:Float
		
		Local dotoffset:Float
		
		Local velocityoffset0:Float
		Local velocityoffset1:Float
		
		Local overlapdistance:Float
		Local veloverlapdistance:Float
		Local minoverlapdistance:Float = $7fffffff
		
		
		Local woffset:tlVector2 = New tlVector2.Create(world.x - Box.world.x, world.y - Box.world.y)

		For Local c:Int = 0 To 2
			
			If c < 2
				axis = Box.normals[c]
			Else
				axis = Box.GetVoronoiAxis(world)
				If Not axis Exit
			End If
		
			project(axis, min0, max0)
			Box.Project(axis, min1, max1)
			
			dotoffset = axis.DotProduct(woffset)
			
			min0:+dotoffset
			max0:+dotoffset
			
			overlapdistance = intervaldistance(min0, max0, min1, max1)
			If overlapdistance > 0
				result.intersecting = False
			End If
			
			If velocity.x Or velocity.y Or Box.velocity.x Or Box.velocity.y
				If velocity.x Or velocity.y
					velocityoffset0 = axis.DotProduct(velocity)
					min0:+velocityoffset0
					max0:+velocityoffset0
				End If
				If Box.velocity.x Or Box.velocity.y
					velocityoffset1 = axis.DotProduct(Box.velocity)
					min1:+velocityoffset1
					max1:+velocityoffset1
				End If
				veloverlapdistance = IntervalDistance(min0, max0, min1, max1)
				If veloverlapdistance > 0
					result.willintersect = False
				Else
					overlapdistance = veloverlapdistance
				End If
			Else
				result.willintersect = False
			End If
			
			If Not result.intersecting And Not result.willintersect Return result
			
			overlapdistance = Abs(overlapdistance)
						
			If overlapdistance < minoverlapdistance
				minoverlapdistance = overlapdistance
				result.surfacenormal = axis.Clone()
				Local polytopolyvec:tlVector2 = world.SubtractVector(Box.world)
				If polytopolyvec.DotProduct(result.surfacenormal) < 0 result.surfacenormal.SetPosition(-result.surfacenormal.x, -result.surfacenormal.y)
			End If
			
		Next
		
		result.translationvector = result.surfacenormal.Scale(minoverlapdistance)
		result.source = Self
		result.target = Box
		Return result
	End Method
	
	Rem
		bbdoc: Check for a collision with another #tlCircle
		returns: #tlCollisionResult type containing info about the collision
		about: Use this to check for a collision with another #tlCircle that you pass to the method. You can then use the information stored in 
		#tlCollisionResult to perform various things based on the result of the collision check.
	end rem
	Method CircleCollide:tlCollisionResult(circle:tlCircle)
		
		If Not Super.BoundingBoxOverlap(circle, True) Return Null
	
		Local result:tlCollisionResult = New tlCollisionResult
		
		Local axis:tlVector2
		
		Local min0:Float, max0:Float
		Local min1:Float, max1:Float
		
		Local dotoffset:Float
		
		Local velocityoffset0:Float
		Local velocityoffset1:Float
		
		Local overlapdistance:Float
		Local veloverlapdistance:Float
		Local minoverlapdistance:Float = $7fffffff
		
		
		Local woffset:tlVector2 = New tlVector2.Create(world.x - circle.world.x, world.y - circle.world.y)

		axis = circle.world.SubtractVector(world)
		axis.Normalise()
		
		dotoffset = axis.DotProduct(woffset)
		
		project(axis, min0, max0)
		circle.Project(axis, min1, max1)
		
		min0:+dotoffset
		max0:+dotoffset
		
		overlapdistance = intervaldistance(min0, max0, min1, max1)
		If overlapdistance > 0
			result.intersecting = False
		End If
		
		If velocity.x Or velocity.y Or circle.velocity.x Or circle.velocity.y
			If velocity.x Or velocity.y
				velocityoffset0 = axis.DotProduct(velocity)
				min0:+velocityoffset0
				max0:+velocityoffset0
			End If
			If circle.velocity.x Or circle.velocity.y
				velocityoffset1 = axis.DotProduct(circle.velocity)
				min1:+velocityoffset1
				max1:+velocityoffset1
			End If
			veloverlapdistance = IntervalDistance(min0, max0, min1, max1)
			If veloverlapdistance > 0
				result.willintersect = False
			Else
				overlapdistance = veloverlapdistance
			End If
		Else
			result.willintersect = False
		End If
		
		If Not result.intersecting And Not result.willintersect Return result
		
		overlapdistance = Abs(overlapdistance)
					
		If overlapdistance < minoverlapdistance
			minoverlapdistance = overlapdistance
			result.surfacenormal = axis.Clone()
			Local vec:tlVector2 = world.SubtractVector(circle.world)
			If vec.DotProduct(result.surfacenormal) < 0 result.surfacenormal.SetPosition(-result.surfacenormal.x, -result.surfacenormal.y)
		End If
					
		result.translationvector = result.surfacenormal.Scale(minoverlapdistance)
		result.source = Self
		result.target = circle
		Return result
	End Method

	Rem
		bbdoc: Check for a collision with a #tlLine
		returns: #tlCollisionResult type containing info about the collision
		about: Use this to check for a collision with a #tlLine that you pass to the method. You can then use the information stored in 
		#tlCollisionResult to perform various things based on the result of the collision check.
	end rem
	Method LineCollide:tlCollisionResult(Line:tlLine)
		
		If Not Super.BoundingBoxOverlap(Line, True) Return Null
	
		Local result:tlCollisionResult = New tlCollisionResult
		
		Local axis:tlVector2
		
		Local min0:Float, max0:Float
		Local min1:Float, max1:Float
		
		Local dotoffset:Float
		
		Local velocityoffset0:Float
		Local velocityoffset1:Float
		
		Local overlapdistance:Float
		Local veloverlapdistance:Float
		Local minoverlapdistance:Float = $7fffffff
		
		
		Local woffset:tlVector2 = New tlVector2.Create(world.x - Line.world.x, world.y - Line.world.y)

		For Local c:Int = 0 To 2
		
			If c = 2
				axis = Line.GetVoronoiAxis(world)
				If Not axis Exit
				
				project(axis, min0, max0)
				Line.Project(axis, min1, max1)
			Else
				axis = Line.normals[c]
	
				project(axis, min0, max0)
				Line.Project(axis, min1, max1)
			End If
			
			dotoffset = axis.DotProduct(woffset)
			
			min0:+dotoffset
			max0:+dotoffset
			
			overlapdistance = intervaldistance(min0, max0, min1, max1)
			If overlapdistance > 0
				result.intersecting = False
			End If
			
			If velocity.x Or velocity.y Or Line.velocity.x Or Line.velocity.y
				If velocity.x Or velocity.y
					velocityoffset0 = axis.DotProduct(velocity)
					min0:+velocityoffset0
					max0:+velocityoffset0
				End If
				If Line.velocity.x Or Line.velocity.y
					velocityoffset1 = axis.DotProduct(Line.velocity)
					min1:+velocityoffset1
					max1:+velocityoffset1
				End If
				veloverlapdistance = IntervalDistance(min0, max0, min1, max1)
				If veloverlapdistance > 0
					result.willintersect = False
				Else
					overlapdistance = veloverlapdistance
				End If
			Else
				result.willintersect = False
			End If
			
			If Not result.intersecting And Not result.willintersect Return result
			
			overlapdistance = Abs(overlapdistance)
						
			If overlapdistance < minoverlapdistance
				minoverlapdistance = overlapdistance
				result.surfacenormal = axis.Clone()
				Local polytocirclevec:tlVector2 = world.SubtractVector(Line.world)
				If polytocirclevec.DotProduct(result.surfacenormal) < 0 result.surfacenormal.SetPosition(-result.surfacenormal.x, -result.surfacenormal.y)
			End If
			
		Next
		
		result.translationvector = result.surfacenormal.Scale(minoverlapdistance)
		result.source = Self
		result.target = Line
		Return result
	End Method
	
	Rem
		bbdoc: Check for a collision with a #tlPolygon
		returns: #tlCollisionResult type containing info about the collision
		about: Use this to check for a collision with another #tlPolygon that you pass to the method. You can then use the information stored in 
		#tlCollisionResult to perform various things based on the result of the collision check.
	end rem
	Method PolyCollide:tlCollisionResult(poly:tlPolygon)
		
		If Not Super.BoundingBoxOverlap(poly, True) Return Null
	
		Local result:tlCollisionResult = New tlCollisionResult
		
		Local axis:tlVector2
		
		Local min0:Float, max0:Float
		Local min1:Float, max1:Float
		
		Local dotoffset:Float
		
		Local velocityoffset0:Float
		Local velocityoffset1:Float
		
		Local overlapdistance:Float
		Local veloverlapdistance:Float
		Local minoverlapdistance:Float = $7fffffff
		
		
		Local woffset:tlVector2 = New tlVector2.Create(world.x - poly.world.x, world.y - poly.world.y)

		For Local c:Int = 0 To poly.vertices.Length
		
			If c = poly.tformvertices.Length
				axis = poly.GetVoronoiAxis(world)
				If Not axis Exit
				
				project(axis, min0, max0)
				poly.Project(axis, min1, max1)
			Else
				axis = poly.normals[c]
	
				project(axis, min0, max0)
				poly.Project(axis, min1, max1)
			End If
			
			dotoffset = axis.DotProduct(woffset)
			
			min0:+dotoffset
			max0:+dotoffset
			
			overlapdistance = intervaldistance(min0, max0, min1, max1)
			If overlapdistance > 0
				result.intersecting = False
			End If
			
			If velocity.x Or velocity.y Or poly.velocity.x Or poly.velocity.y
				If velocity.x Or velocity.y
					velocityoffset0 = axis.DotProduct(velocity)
					min0:+velocityoffset0
					max0:+velocityoffset0
				End If
				If poly.velocity.x Or poly.velocity.y
					velocityoffset1 = axis.DotProduct(poly.velocity)
					min1:+velocityoffset1
					max1:+velocityoffset1
				End If
				veloverlapdistance = IntervalDistance(min0, max0, min1, max1)
				If veloverlapdistance > 0
					result.willintersect = False
				Else
					overlapdistance = veloverlapdistance
				End If
			Else
				result.willintersect = False
			End If
			
			If Not result.intersecting And Not result.willintersect Return result
			
			overlapdistance = Abs(overlapdistance)
						
			If overlapdistance < minoverlapdistance
				minoverlapdistance = overlapdistance
				result.surfacenormal = axis.Clone()
				Local vec:tlVector2 = world.SubtractVector(poly.world)
				If vec.DotProduct(result.surfacenormal) < 0 result.surfacenormal.SetPosition(-result.surfacenormal.x, -result.surfacenormal.y)
			End If
			
		Next
		
		result.translationvector = result.surfacenormal.Scale(minoverlapdistance)
		result.source = Self
		result.target = poly
		Return result
	End Method
	
	Rem
		bbdoc: See is a ray collides with this #tlCircle
		returns: #tlCollisionResult with the results of the collision
		about: You can use this to test for a collision with a ray. Pass the origin of the ray with px and py, and set the direction of the ray with dx and dy.
		dx and dy will be normalised and extended infinitely, if maxdistance equals 0 (default), otherwise set maxdistance to how ever far you want the ray 
		to extend to. If the ray starts inside the poly then result.rayorigininside will be set to true.
	end rem
	Method RayCollide:tlCollisionResult(px:Float, py:Float, dx:Float, dy:Float, maxdistance:Float = 0)
		
		Local result:tlCollisionResult = New tlCollisionResult
		
		If PointInside(px, py)
			result.rayorigininside = True
			result.rayintersection = New tlVector2.Create(0, 0)
			Return result
		End If
		
		Local p:tlVector2 = CreateVector2(px, py)
		Local dv:tlVector2 = CreateVector2(dx, dy)
		
		dv.Normalise()

		Local cp:tlVector2 = p.SubtractVector(world)
		
		Local a:Float = dv.DotProduct(dv)
		Local b:Float = dv.DotProduct(cp) * 2
		Local c:Float = cp.DotProduct(cp) - (radius * radius)
		
		Local q:Float = b * b - (4 * a * c)
		
		If Not maxdistance maxdistance = $7fffffff
		
		If q >= 0
			
			Local sq:Float = Sqr(q)
			Local d:Float = 1 / (2 * a) 	
			Local u0:Float = (-b + sq) * d
			Local u1:Float = (-b - sq) * d

			Local u:Float
			
			If u1 < 0
				If u0 >= 0
					u = u0
				Else
					result.intersecting = False
				End If
			ElseIf u0 < 0
				u = u1
			Else
				If u1 < u0
					u = u1
				Else
					u = u0
				EndIf
			End If
			
			If result.intersecting And u <= maxdistance
				result.rayintersection = New tlVector2.Create(px + u * dx, py + u * dy)
				result.surfacenormal = result.rayintersection.SubtractVector(world)
				result.surfacenormal.Normalise()
				result.raydistance = u
				result.target = Self
				Return result
			End If
			
		End If
		
		result.intersecting = False
		result.willintersect = False
		
		Return result
	
	End Method

	
	Rem
		bbdoc:Set the Box of the circle
		about: this lets you change the size and location of the #tlCircle
	End Rem
	Method SetCircle(x:Float, y:Float, _radius:Float)
		radius = _radius
		tl_corner.SetPosition(x - radius, y - radius)
		br_corner.SetPosition(x + radius, y + radius)
		world.SetPosition(x, y)
		width = radius * 2
		height = radius * 2
	End Method
	
	Rem
		bbdoc: Draw this tlBox
		about: Use this if you need to draw the bounding box for debugging purposes. Pass true of false to draw the bounding box as well.
	end rem
	Method draw(offsetx:Float = 0, offsety:Float = 0, BoundingBox:Int = False)
		DrawOval world.x - radius - offsetx, world.y - radius - offsety, width, height
		If boundingbox Super.draw(offsetx, offsety, boundingbox)
	End Method
	
	'internal stuff--------------------
	Method Project(axis:tlVector2, minimum:Float Var, maximum:Float Var)
		'This projects the circle onto an axis and lets us know the min and max dotproduct values
		minimum = -tformradius
		maximum = tformradius
	End Method
	
	Method TForm()
		tformradius:*Max(scale.x, scale.y)
	End Method
End Type

Rem
	bbdoc: tlPolygon for convex polygon collisions
	about: This extends #tlBox so automatically inherits a bounding box, which can be checked first before doing a more complicated polygon collision
	check. You can add this type to a #tlQuadTree just as though it were a standard #tlBox, as the quadtree only concerns itself with Boxs.
end rem
Type tlPolygon Extends tlBox
		
	Field angle:Float
	
	Rem
		bbdoc: Create a #tlPolygon
		returns: New #tlPolygon, or Null if verts[] contained the wrong amount.
		about: Create a new #tlPolygon at the given coordinates with the given array of vertices. The coordinates will represent the center of the polygon, but this
		can be changed with #SetPolyHandle. The array must contain more then 5 values (2 per vertex) and be an even number or null will be returned. The coordinates of
		the vertices in the array are arranged like so: [x,y,x,y,x,y .. etc]. You can also assign some data to the boundary as handy way to store some extra info about the boundary.
	end rem
	Method CreatePoly:tlPolygon(x:Float, y:Float, verts:Float[], layer:Int = tlLAYER_1, Data:Object = Null)
		If verts.length < 6 Or verts.length Mod 2
			Return Null
		Else
			world = New tlVector2.Create(x, y)
			vertices = New tlVector2[verts.length / 2]
			tformvertices = New tlVector2[verts.length / 2]
			normals = New tlVector2[verts.length / 2]
			
			tl_corner = New tlVector2.Create(0, 0)
			br_corner = New tlVector2.Create(0, 0)
			For Local c:Int = 0 To vertices.Length - 1
				vertices[c] = New tlVector2.Create(verts[c * 2], verts[c * 2 + 1])
				handle.x:+vertices[c].x
				handle.y:+vertices[c].y
				tformvertices[c] = New tlVector2.Create(0, 0)
				normals[c] = New tlVector2.Create(0, 0)
			Next
			handle.x:/vertices.Length
			handle.y:/vertices.Length
			For Local c:Int = 0 To vertices.Length - 1
				vertices[c] = vertices[c].subtractVector(handle)
			Next
			handle.SetPosition(0, 0)
			collisiontype = tlPOLY_COLLISION
			tformmatrix.set(Cos(angle) * scale.x, Sin(angle) * scale.y, -Sin(angle) * scale.x, Cos(angle) * scale.y)
			TForm()
			collisionlayer = layer
			_data = data
		End If
		Return Self
	End Method
	
	Rem
		bbdoc: Create a #tlPolygon
		returns: New #tlPolygon, or Null if verts[] contained the wrong amount.
		about: Create a new #tlPolygon at the given coordinates with the given array of vertices. The coordinates will represent the center of the polygon, but this
		can be changed with #SetPolyHandle. The array must contain more then 5 values (2 per vertex) and be an even number or null will be returned. The coordinates of
		the vertices in the array are arranged like so: [x,y,x,y,x,y .. etc]. You can also assign some data to the boundary as handy way to store some extra info about the boundary.
	end rem
	Method CreatePolyWorld:tlPolygon(verts:Float[], layer:Int = tlLAYER_1, Data:Object = Null)
		If verts.length < 6 Or verts.length Mod 2
			Return Null
		Else
			world = New tlVector2.Create(0, 0)
			vertices = New tlVector2[verts.length / 2]
			tformvertices = New tlVector2[verts.length / 2]
			normals = New tlVector2[verts.length / 2]
			
			tl_corner = New tlVector2.Create(0, 0)
			br_corner = New tlVector2.Create(0, 0)
			For Local c:Int = 0 To vertices.Length - 1
				vertices[c] = New tlVector2.Create(verts[c * 2], verts[c * 2 + 1])
				world.x:+vertices[c].x
				world.y:+vertices[c].y
				tformvertices[c] = New tlVector2.Create(0, 0)
				normals[c] = New tlVector2.Create(0, 0)
			Next
			world.x:/vertices.Length
			world.y:/vertices.Length
			For Local c:Int = 0 To vertices.Length - 1
				vertices[c] = vertices[c].subtractVector(world)
			Next
			handle.SetPosition(0, 0)
			collisiontype = tlPOLY_COLLISION
			tformmatrix.set(Cos(angle) * scale.x, Sin(angle) * scale.y, -Sin(angle) * scale.x, Cos(angle) * scale.y)
			TForm()
			collisionlayer = layer
			_data = data
		End If
		Return Self
	End Method
	
	Rem
		bbdoc: Rotate the polygon 
		about: This will rotate the polygon by the given amount
	end rem
	Method Rotate(_angle:Float)
		angle:+_angle
		tformmatrix.set(Cos(angle) , Sin(angle) , -Sin(angle) , Cos(angle))
		TForm()
	End Method
	
	Rem
		bbdoc: Set the angle of the polygon
		about: This will adjust the angle of the polygon by the given amount.
	end rem
	Method SetAngle(_angle:Float)
		angle = _angle
		tformmatrix.set(Cos(angle) , Sin(angle) , -Sin(angle), Cos(angle))
		TForm()
	End Method
	
	Rem
		bbdoc: Set the scale of the Polygon
		about: This sets scale of the polygon.
	end rem
	Method SetScale(x:Float, y:Float)
		ResetBoundingBox()
		scale.x = x
		scale.y = y
		TForm()
	End Method
	
	Rem
		bbdoc: Find out if a point resides withing the #tlPolygon
		returns: True if they do overlap
		about: Use this to check if a point with the given coordinates lies within the polygon
	end rem
	Method PointInside:Int(x:Float, y:Float)
		
		Local x1:Float = tformvertices[tformvertices.Length - 1].x + world.x
		Local y1:Float = tformvertices[tformvertices.Length - 1].y + world.y
		Local cur_quad:Int = GetQuad(x, y, x1, y1)
		Local next_quad:Int
		Local total:Int
		
		For Local i:Int = 0 Until tformvertices.Length
			Local x2:Float = tformvertices[i].x + world.x
			Local y2:Float = tformvertices[i].y + world.y
			next_quad = GetQuad(x, y, x2, y2)
			Local diff:Int = next_quad - cur_quad
			
			Select diff
			Case 2, -2
				If (x2 - (((y2 - y) * (x1 - x2)) / (y1 - y2))) < x
					diff = -diff
				EndIf
			Case 3
				diff = -1
			Case -3
				diff = 1
			End Select
			
			total:+diff
			cur_quad = next_quad
			x1 = x2
			y1 = y2
		Next
		
		If Abs(total)=4 Then Return True Else Return False
	End Method
	
	Rem
		bbdoc: Check for a collision with a #tlBox
		returns: #tlCollisionResult type containing info about the collision
		about: Use this to check for a collision with a #tlBox that you pass to the method. You can then use the information stored in 
		#tlCollisionResult to perform various things based on the result of the collision check.
	end rem
	Method BoxCollide:tlCollisionResult(Box:tlBox)
		If Not Super.BoundingBoxOverlap(Box, True) Return Null
	
		Local result:tlCollisionResult = New tlCollisionResult
		
		Local axis:tlVector2
		
		Local min0:Float, max0:Float
		Local min1:Float, max1:Float
		
		Local dotoffset:Float
		
		Local velocityoffset0:Float
		Local velocityoffset1:Float
		
		Local overlapdistance:Float
		Local veloverlapdistance:Float
		Local minoverlapdistance:Float = $7fffffff
		
		
		Local woffset:tlVector2 = New tlVector2.Create(world.x - Box.world.x, world.y - Box.world.y)

		For Local c:Int = 0 To vertices.Length + 1
		
			If c < vertices.Length
				axis = normals[c]
			Else
				axis = Box.normals[c - vertices.Length]
			End If
		
			project(axis, min0, max0)
			Box.Project(axis, min1, max1)
			
			dotoffset = axis.DotProduct(woffset)
			
			min0:+dotoffset
			max0:+dotoffset
			
			overlapdistance = intervaldistance(min0, max0, min1, max1)
			If overlapdistance > 0
				result.intersecting = False
			End If
			
			If velocity.x Or velocity.y Or Box.velocity.x Or Box.velocity.y
				If velocity.x Or velocity.y
					velocityoffset0 = axis.DotProduct(velocity)
					min0:+velocityoffset0
					max0:+velocityoffset0
				End If
				If Box.velocity.x Or Box.velocity.y
					velocityoffset1 = axis.DotProduct(Box.velocity)
					min1:+velocityoffset1
					max1:+velocityoffset1
				End If
				veloverlapdistance = IntervalDistance(min0, max0, min1, max1)
				If veloverlapdistance > 0
					result.willintersect = False
				Else
					overlapdistance = veloverlapdistance
				End If
			Else
				result.willintersect = False
			End If
			
			If Not result.intersecting And Not result.willintersect Return result
			
			overlapdistance = Abs(overlapdistance)
						
			If overlapdistance < minoverlapdistance
				minoverlapdistance = overlapdistance
				result.surfacenormal = axis.Clone()
				Local vec:tlVector2 = world.SubtractVector(Box.world)
				If vec.DotProduct(result.surfacenormal) < 0 result.surfacenormal.SetPosition(-result.surfacenormal.x, -result.surfacenormal.y)
			End If
			
		Next
		
		result.translationvector = result.surfacenormal.Scale(minoverlapdistance)
		result.source = Self
		result.target = Box
		Return result
	End Method
	
	Rem
		bbdoc: Check for a collision with a #tlCircle
		returns: #tlCollisionResult type containing info about the collision
		about: Use this to check for a collision with a #tlCircle that you pass to the method. You can then use the information stored in 
		#tlCollisionResult to perform various things based on the result of the collision check.
	end rem
	Method CircleCollide:tlCollisionResult(circle:tlCircle)
		
		If Not Super.BoundingBoxOverlap(circle, True) Return Null
	
		Local result:tlCollisionResult = New tlCollisionResult
		
		Local axis:tlVector2
		
		Local min0:Float, max0:Float
		Local min1:Float, max1:Float
		
		Local dotoffset:Float
		
		Local velocityoffset0:Float
		Local velocityoffset1:Float
		
		Local overlapdistance:Float
		Local veloverlapdistance:Float
		Local minoverlapdistance:Float = $7fffffff
		
		
		Local woffset:tlVector2 = New tlVector2.Create(world.x - circle.world.x, world.y - circle.world.y)

		For Local c:Int = 0 To vertices.Length
		
			If c = tformvertices.Length
				axis = GetVoronoiAxis(circle.world)
				If Not axis Exit
				
				project(axis, min0, max0)
				circle.Project(axis, min1, max1)
			Else
				axis = normals[c]
	
				project(axis, min0, max0)
				circle.Project(axis, min1, max1)
			End If
			
			dotoffset = axis.DotProduct(woffset)
			
			min0:+dotoffset
			max0:+dotoffset
			
			overlapdistance = intervaldistance(min0, max0, min1, max1)
			If overlapdistance > 0
				result.intersecting = False
			End If
			
			If velocity.x Or velocity.y Or circle.velocity.x Or circle.velocity.y
				If velocity.x Or velocity.y
					velocityoffset0 = axis.DotProduct(velocity)
					min0:+velocityoffset0
					max0:+velocityoffset0
				End If
				If circle.velocity.x Or circle.velocity.y
					velocityoffset1 = axis.DotProduct(circle.velocity)
					min1:+velocityoffset1
					max1:+velocityoffset1
				End If
				veloverlapdistance = IntervalDistance(min0, max0, min1, max1)
				If veloverlapdistance > 0
					result.willintersect = False
				Else
					overlapdistance = veloverlapdistance
				End If
			Else
				result.willintersect = False
			End If
			
			If Not result.intersecting And Not result.willintersect Return result
			
			overlapdistance = Abs(overlapdistance)
						
			If overlapdistance < minoverlapdistance
				minoverlapdistance = overlapdistance
				result.surfacenormal = axis.Clone()
				Local polytocirclevec:tlVector2 = world.SubtractVector(circle.world)
				If polytocirclevec.DotProduct(result.surfacenormal) < 0 result.surfacenormal.SetPosition(-result.surfacenormal.x, -result.surfacenormal.y)
			End If
			
		Next
		
		result.translationvector = result.surfacenormal.Scale(minoverlapdistance)
		result.source = Self
		result.target = circle
		Return result
	End Method
	
	Rem
		bbdoc: Check for a collision with a #tlLine
		returns: #tlCollisionResult type containing info about the collision
		about: Use this to check for a collision with a #tlLine that you pass to the method. You can then use the information stored in 
		#tlCollisionResult to perform various things based on the result of the collision check.
	end rem
	Method LineCollide:tlCollisionResult(Line:tlLine)
		
		If Not Super.BoundingBoxOverlap(Line, True) Return Null
	
		Local result:tlCollisionResult = New tlCollisionResult
		
		Local axis:tlVector2
		
		Local min0:Float, max0:Float
		Local min1:Float, max1:Float
		
		Local dotoffset:Float
		
		Local velocityoffset0:Float
		Local velocityoffset1:Float
		
		Local overlapdistance:Float
		Local veloverlapdistance:Float
		Local minoverlapdistance:Float = $7fffffff
		
		
		Local woffset:tlVector2 = New tlVector2.Create(world.x - Line.world.x, world.y - Line.world.y)

		For Local c:Int = 0 To 2 + vertices.Length - 1
		
			If c < 2
				axis = Line.normals[c]
			Else
				axis = normals[c - 2]
			End If
		
			project(axis, min0, max0)
			Line.Project(axis, min1, max1)
			
			dotoffset = axis.DotProduct(woffset)
			
			min0:+dotoffset
			max0:+dotoffset
			
			overlapdistance = intervaldistance(min0, max0, min1, max1)
			If overlapdistance > 0
				result.intersecting = False
			End If
			
			If velocity.x Or velocity.y Or Line.velocity.x Or Line.velocity.y
				If velocity.x Or velocity.y
					velocityoffset0 = axis.DotProduct(velocity)
					min0:+velocityoffset0
					max0:+velocityoffset0
				End If
				If Line.velocity.x Or Line.velocity.y
					velocityoffset1 = axis.DotProduct(Line.velocity)
					min1:+velocityoffset1
					max1:+velocityoffset1
				End If
				veloverlapdistance = IntervalDistance(min0, max0, min1, max1)
				If veloverlapdistance > 0
					result.willintersect = False
				Else
					overlapdistance = veloverlapdistance
				End If
			Else
				result.willintersect = False
			End If
			
			If Not result.intersecting And Not result.willintersect Return result
			
			overlapdistance = Abs(overlapdistance)
						
			If overlapdistance < minoverlapdistance
				minoverlapdistance = overlapdistance
				result.surfacenormal = axis.Clone()
				Local polytopolyvec:tlVector2 = world.SubtractVector(Line.world)
				If polytopolyvec.DotProduct(result.surfacenormal) < 0 result.surfacenormal.SetPosition(-result.surfacenormal.x, -result.surfacenormal.y)
			End If
			
		Next
		
		result.translationvector = result.surfacenormal.Scale(minoverlapdistance)
		result.source = Self
		result.target = Line
		Return result
	End Method
	
	Rem
		bbdoc: Check for a collision with another #tlpolygon
		returns: #tlCollisionResult type containing info about the collision
		about: Use this to check for a collision with a #tlPolygon that you pass to the method. You can then use the information stored in 
		#tlCollisionResult to perform various things based on the result of the collision check.
	end rem
	Method PolyCollide:tlCollisionResult(poly:tlPolygon)
		
		If Not Super.BoundingBoxOverlap(poly, True) Return Null
	
		Local result:tlCollisionResult = New tlCollisionResult
		
		Local axis:tlVector2
		
		Local min0:Float, max0:Float
		Local min1:Float, max1:Float
		
		Local dotoffset:Float
		
		Local velocityoffset0:Float
		Local velocityoffset1:Float
		
		Local overlapdistance:Float
		Local veloverlapdistance:Float
		Local minoverlapdistance:Float = $7fffffff
		
		
		Local woffset:tlVector2 = New tlVector2.Create(world.x - poly.world.x, world.y - poly.world.y)

		For Local c:Int = 0 To vertices.Length + poly.vertices.Length - 1
		
			If c < vertices.Length
				axis = normals[c]
			Else
				axis = poly.normals[c - vertices.Length]
			End If
		
			project(axis, min0, max0)
			poly.Project(axis, min1, max1)
			
			dotoffset = axis.DotProduct(woffset)
			
			min0:+dotoffset
			max0:+dotoffset
			
			overlapdistance = intervaldistance(min0, max0, min1, max1)
			If overlapdistance > 0
				result.intersecting = False
			End If
			
			If velocity.x Or velocity.y Or poly.velocity.x Or poly.velocity.y
				If velocity.x Or velocity.y
					velocityoffset0 = axis.DotProduct(velocity)
					min0:+velocityoffset0
					max0:+velocityoffset0
				End If
				If poly.velocity.x Or poly.velocity.y
					velocityoffset1 = axis.DotProduct(poly.velocity)
					min1:+velocityoffset1
					max1:+velocityoffset1
				End If
				veloverlapdistance = IntervalDistance(min0, max0, min1, max1)
				If veloverlapdistance > 0
					result.willintersect = False
				Else
					overlapdistance = veloverlapdistance
				End If
			Else
				result.willintersect = False
			End If
			
			If Not result.intersecting And Not result.willintersect Return result
			
			overlapdistance = Abs(overlapdistance)
						
			If overlapdistance < minoverlapdistance
				minoverlapdistance = overlapdistance
				result.surfacenormal = axis.Clone()
				Local polytopolyvec:tlVector2 = world.SubtractVector(poly.world)
				If polytopolyvec.DotProduct(result.surfacenormal) < 0 result.surfacenormal.SetPosition(-result.surfacenormal.x, -result.surfacenormal.y)
			End If
			
		Next
		
		result.translationvector = result.surfacenormal.Scale(minoverlapdistance)
		result.source = Self
		result.target = poly
		Return result
	End Method
	
	Rem
		bbdoc: See is a ray collides with this #tlpolygon
		returns: #tlCollisionResult with the results of the collision
		about: You can use this to test for a collision with a ray. Pass the origin of the ray with px and py, and set the direction of the ray with dx and dy.
		dx and dy will be normalised and extended infinitely, if maxdistance equals 0 (default), otherwise set maxdistance to how ever far you want the ray 
		to extend to. If the ray starts inside the poly then result.rayorigininside will be set to true.
	end rem
	Method RayCollide:tlCollisionResult(px:Float, py:Float, dx:Float, dy:Float, maxdistance:Float = 0)
		
		Local result:tlCollisionResult = New tlCollisionResult
		
		If PointInside(px, py)
			result.rayorigininside = True
			result.rayintersection = New tlVector2.Create(0, 0)
			Return result
		End If
		
		Local p:tlVector2 = CreateVector2(px, py)
		Local d:tlVector2 = CreateVector2(dx, dy)
		
		Local raydot:Float
		Local edge:tlVector2
		Local iedge:tlVector2
		
		Local vw:tlVector2
		Local intersect:tlVector2
		Local distance:Float
		
		d.Normalise()
		
		For Local c:Int = 0 To vertices.Length - 1
			raydot = d.DotProduct(normals[c])
			If raydot < 0 And p.SubtractVector(tformvertices[c].AddVector(world)).DotProduct(normals[c]) > 0
				vw = tformvertices[c].AddVector(world)
				distance = normals[c].DotProduct(p.SubtractVector(vw))
				distance = Abs(distance / raydot)
				If (maxdistance > 0 And distance <= maxdistance) Or maxdistance = 0
					intersect = d.Scale(distance).AddVector(p)
					vw = intersect.SubtractVector(world)
					If c = 0
						edge = tformvertices[vertices.Length - 1].SubtractVector(tformvertices[c])
						iedge = tformvertices[vertices.Length - 1].SubtractVector(vw)
					Else
						edge = tformvertices[c - 1].SubtractVector(tformvertices[c])
						iedge = tformvertices[c - 1].SubtractVector(vw)
					End If
					raydot = edge.DotProduct(iedge)
					If raydot >= 0 And raydot <= edge.DotProduct(edge)
						result.rayintersection = intersect
						result.surfacenormal = normals[c]
						result.raydistance = distance
						result.target = Self
						Return result
					End If
				End If
			End If
		Next
		
		result.intersecting = False
		result.willintersect = False
		
		Return result
	
	End Method
	
	Rem
		bbdoc: Draw the polygon
		about: You can use this for debugging purposes. Pass true of false to draw the bounding box as well.
	end rem
	Method draw(offsetx:Float = 0, offsety:Float = 0, BoundingBox:Int = False)
		Local v1:tlVector2 = tformvertices[tformvertices.Length - 1]
		Local v2:tlVector2
		For Local c:Int = 0 To tformvertices.Length - 1
			v2 = tformvertices[c]
			DrawLine(v1.x + world.x - offsetx, v1.y + world.y - offsety, v2.x + world.x - offsetx, v2.y + world.y - offsety, False)
			v1 = v2
		Next
		If boundingbox Super.draw(offsetx, offsety, boundingbox)
	End Method
	
	Method DrawShadow(offsetx:Float = 0, offsety:Float = 0)
		DrawPoly([tformvertices[3].x + world.x - offsetx, tformvertices[3].y + world.y - offsety,  ..
				 tformvertices[0].x + world.x - offsetx, tformvertices[0].y + world.y - offsety,  ..
				 tformvertices[1].x + world.x - offsetx, tformvertices[1].y + world.y - offsety,  ..
				 tformvertices[2].x + world.x - offsetx, tformvertices[2].y + world.y - offsety])
	End Method
	
	'internal stuff---------------------------------
	Method TForm()
		'This transforms the polygon according to the current scale/angle. Both local and transformed vertices are stored within the type, which
		'while takes more memory, makes things a bit easier, and I think a bit faster. The memory overhead is extremely low unless you have stupendously
		'complex polys!
		ResetBoundingBox()
		For Local i:Int = 0 To vertices.Length - 1
			tformvertices[i].SetPosition(scale.x * vertices[i].x + handle.x, scale.y * vertices[i].y + handle.y)
			tformvertices[i] = tformmatrix.transformvector(tformvertices[i])
			UpdateBoundingBox(tformvertices[i].x, tformvertices[i].y)
		Next
		UpdateNormals()
		UpdateDimensions()
		TFormBoundingBox()
	End Method
	
	Method UpdateNormals()
		Local v1:tlVector2 = tformvertices[tformvertices.Length - 1]
		Local v2:tlVector2
		For Local c:Int = 0 To tformvertices.Length - 1
			v2 = tformvertices[c]
			normals[c].SetPosition(-(v2.y - v1.y), v2.x - v1.x)
			normals[c].Normalise()
			v1 = v2
		Next
	End Method
	
	Method GetVoronoiAxis:tlVector2(point:tlVector2)
		
		Local v1:tlVector2 = tformvertices[tformvertices.Length - 1].AddVector(world)
		Local v2:tlVector2
		Local v3:tlVector2
		Local edge:tlVector2
		Local vc:tlVector2
		Local dot:Float
		
		For Local c:Int = 0 To tformvertices.Length - 1
			v2 = tformvertices[c].AddVector(world)
			edge = v2.SubtractVector(v1)
			vc = point.SubtractVector(v1)
			dot = vc.DotProduct(edge)
			If dot > edge.DotProduct(edge)
				If c + 1 < tformvertices.Length Then v3 = tformvertices[c + 1].AddVector(world) Else v3 = tformvertices[0].AddVector(world)
				edge = v3.SubtractVector(v2)
				vc = point.SubtractVector(v2)
				dot = edge.DotProduct(vc)
				If dot < 0
					vc.Normalise()
					Return vc
				End If
			ElseIf dot < 0
				Select c
					Case 0
						v3 = tformvertices[tformvertices.Length - 2].AddVector(world)
					Case 1
						v3 = tformvertices[tformvertices.Length - 1].AddVector(world)
					Default
						v3 = tformvertices[c - 2].AddVector(world)
				End Select
				edge = v1.SubtractVector(v3)
				vc = point.SubtractVector(v3)
				dot = edge.DotProduct(vc)
				If dot > edge.DotProduct(edge)
					vc.Normalise()
					Return vc
				End If
			Else
				If vc.DotProduct(edge.Normal()) > 0
					Return Null
				End If
			End If
			v1 = v2
		Next
		
		Return Null
		
	End Method
	
	Method ResetBoundingBox()
		'Reset the bounding box. Performed before it's updated.
		tl_corner.x = 0
		tl_corner.y = 0
		br_corner.x = 0
		br_corner.y = 0
	End Method
	
	Method UpdateBoundingBox(x:Float, y:Float)
		'When the scale/angle of the poly changes, its bounding box needs to be updated, and that's what happens here.
		tl_corner.x = Min(tl_corner.x, x)
		tl_corner.y = Min(tl_corner.y, y)
		br_corner.x = Max(x, br_corner.x)
		br_corner.y = Max(y, br_corner.y)
	End Method
	
	Method UpdateDimensions()
		'If the scale of the poly has changed then the width and height values need to be updated
		width = br_corner.x - tl_corner.x
		height = br_corner.y - tl_corner.y
	End Method
	
	Method TFormBoundingBox()
		'After the bounding box is updated, it needs to be moved into world space.
		boxoffset.x = tl_corner.x
		boxoffset.y = tl_corner.y
		tl_corner.x:+world.x
		tl_corner.y:+world.y
		br_corner.x:+world.x
		br_corner.y:+world.y
	End Method
	
	Method Project(axis:tlVector2, minimum:Float Var, maximum:Float Var)
		'This projects the poly onto an axis and lets us know the min and max dotproduct values
		Local dotproduct:Float = axis.DotProduct(tformvertices[0])
		minimum = dotproduct
		maximum = dotproduct
		For Local c:Int = 1 To tformvertices.Length - 1
			dotproduct = tformvertices[c].DotProduct(axis)
			If dotproduct < minimum
				minimum = dotproduct
			ElseIf dotproduct > maximum
				maximum = dotproduct
			End If
		Next
	End Method
	
End Type

Rem
	bbdoc: tlLine for line collisions
	about: This type extends #tlPolygon and can be used to check for collisions with any of the other types of collision.
end rem
Type tlLine Extends tlPolygon
	
	Rem
		bbdoc: Create a #tlLine
		returns: New #tlLine
		about: Create a new #tlLine at the coordinates given, x1 and y1 being the start of the line and x2 and y2 being the end. The will placed exactly
		according to the coordinates you give, but it's worth bearing in mind that the handle of the line will be at the center point along the line. Therefore
		the world coordinates will be set to half way point along the line. You can also assign some data to the boundary as handy way to store some extra info about the boundary.
	end rem
	Method CreateLine:tlLine(x1:Float, y1:Float, x2:Float, y2:Float, layer:Int = tlLAYER_1, Data:Object = Null)
		vertices = New tlVector2[2]
		tformvertices = New tlVector2[2]
		normals = New tlVector2[2]
		tl_corner = New tlVector2.Create(0, 0)
		br_corner = New tlVector2.Create(0, 0)
		vertices[0] = New tlVector2.Create(0, 0)
		vertices[1] = New tlVector2.Create(x2 - x1, y2 - y1)
		For Local c:Int = 0 To 1
			tformvertices[c] = New tlVector2.Create(0, 0)
			normals[c] = New tlVector2.Create(0, 0)
		Next
		handle.x = vertices[1].x / 2
		handle.y = vertices[1].y / 2
		For Local c:Int = 0 To vertices.Length - 1
			vertices[c] = vertices[c].subtractVector(handle)
		Next
		world = New tlVector2.Create(x1 + handle.x, y1 + handle.y)
		'move(x1 - world.x, y1 - world.y)
		handle.SetPosition(0, 0)
		collisiontype = tlLINE_COLLISION
		tformmatrix.set(Cos(angle) * scale.x, Sin(angle) * scale.y, -Sin(angle) * scale.x, Cos(angle) * scale.y)
		TForm()
		collisionlayer = layer
		_data = data
		Return Self
	End Method
	
	Rem
		bbdoc: Check for a collision with a #tlBox
		returns: #tlCollisionResult type containing info about the collision
		about: Use this to check for a collision with a #tlBox that you pass to the method. You can then use the information stored in 
		#tlCollisionResult to perform various things based on the result of the collision check.
	end rem
	Method BoxCollide:tlCollisionResult(Box:tlBox)
		If Not Super.BoundingBoxOverlap(Box, True) Return Null
	
		Local result:tlCollisionResult = New tlCollisionResult
		
		Local axis:tlVector2
		
		Local min0:Float, max0:Float
		Local min1:Float, max1:Float
		
		Local dotoffset:Float
		
		Local velocityoffset0:Float
		Local velocityoffset1:Float
		
		Local overlapdistance:Float
		Local veloverlapdistance:Float
		Local minoverlapdistance:Float = $7fffffff
		
		
		Local woffset:tlVector2 = New tlVector2.Create(world.x - Box.world.x, world.y - Box.world.y)
		
		For Local c:Int = 0 To 3
		
			If c < 2
				axis = normals[c]
			Else
				axis = Box.normals[c - 1]
			End If
		
			project(axis, min0, max0)
			Box.Project(axis, min1, max1)
			
			dotoffset = axis.DotProduct(woffset)
			
			min0:+dotoffset
			max0:+dotoffset
			
			overlapdistance = intervaldistance(min0, max0, min1, max1)
			If overlapdistance > 0
				result.intersecting = False
			End If
			
			If velocity.x Or velocity.y Or Box.velocity.x Or Box.velocity.y
				If velocity.x Or velocity.y
					velocityoffset0 = axis.DotProduct(velocity)
					min0:+velocityoffset0
					max0:+velocityoffset0
				End If
				If Box.velocity.x Or Box.velocity.y
					velocityoffset1 = axis.DotProduct(Box.velocity)
					min1:+velocityoffset1
					max1:+velocityoffset1
				End If
				veloverlapdistance = IntervalDistance(min0, max0, min1, max1)
				If veloverlapdistance > 0
					result.willintersect = False
				Else
					overlapdistance = veloverlapdistance
				End If
			Else
				result.willintersect = False
			End If
			
			If Not result.intersecting And Not result.willintersect Return result
			
			overlapdistance = Abs(overlapdistance)
						
			If overlapdistance < minoverlapdistance
				minoverlapdistance = overlapdistance
				result.surfacenormal = axis.Clone()
				Local vec:tlVector2 = world.SubtractVector(Box.world)
				If vec.DotProduct(result.surfacenormal) < 0 result.surfacenormal.SetPosition(-result.surfacenormal.x, -result.surfacenormal.y)
			End If
			
		Next
		
		result.translationvector = result.surfacenormal.Scale(minoverlapdistance)
		result.source = Self
		result.target = Box
		Return result
	End Method
	
	Rem
		bbdoc: Check for a collision with a #tlCircle
		returns: #tlCollisionResult type containing info about the collision
		about: Use this to check for a collision with a #tlCircle that you pass to the method. You can then use the information stored in 
		#tlCollisionResult to perform various things based on the result of the collision check.
	end rem
	Method CircleCollide:tlCollisionResult(circle:tlCircle)
		
		If Not Super.BoundingBoxOverlap(circle, True) Return Null
	
		Local result:tlCollisionResult = New tlCollisionResult
		
		Local axis:tlVector2
		
		Local min0:Float, max0:Float
		Local min1:Float, max1:Float
		
		Local dotoffset:Float
		
		Local velocityoffset0:Float
		Local velocityoffset1:Float
		
		Local overlapdistance:Float
		Local veloverlapdistance:Float
		Local minoverlapdistance:Float = $7fffffff
		
		
		Local woffset:tlVector2 = New tlVector2.Create(world.x - circle.world.x, world.y - circle.world.y)

		For Local c:Int = 0 To 2
		
			If c = 2
				axis = GetVoronoiAxis(circle.world)
				If Not axis Exit
				
				project(axis, min0, max0)
				circle.Project(axis, min1, max1)
			Else
				axis = normals[c]
	
				project(axis, min0, max0)
				circle.Project(axis, min1, max1)
			End If
			
			dotoffset = axis.DotProduct(woffset)
			
			min0:+dotoffset
			max0:+dotoffset
			
			overlapdistance = intervaldistance(min0, max0, min1, max1)
			If overlapdistance > 0
				result.intersecting = False
			End If
			
			If velocity.x Or velocity.y Or circle.velocity.x Or circle.velocity.y
				If velocity.x Or velocity.y
					velocityoffset0 = axis.DotProduct(velocity)
					min0:+velocityoffset0
					max0:+velocityoffset0
				End If
				If circle.velocity.x Or circle.velocity.y
					velocityoffset1 = axis.DotProduct(circle.velocity)
					min1:+velocityoffset1
					max1:+velocityoffset1
				End If
				veloverlapdistance = IntervalDistance(min0, max0, min1, max1)
				If veloverlapdistance > 0
					result.willintersect = False
				Else
					overlapdistance = veloverlapdistance
				End If
			Else
				result.willintersect = False
			End If
			
			If Not result.intersecting And Not result.willintersect Return result
			
			overlapdistance = Abs(overlapdistance)
						
			If overlapdistance < minoverlapdistance
				minoverlapdistance = overlapdistance
				result.surfacenormal = axis.Clone()
				Local polytocirclevec:tlVector2 = world.SubtractVector(circle.world)
				If polytocirclevec.DotProduct(result.surfacenormal) < 0 result.surfacenormal.SetPosition(-result.surfacenormal.x, -result.surfacenormal.y)
			End If
			
		Next
		
		result.translationvector = result.surfacenormal.Scale(minoverlapdistance)
		result.source = Self
		result.target = circle
		Return result
	End Method
	
	Rem
		bbdoc: Check for a collision with another #tlLine
		returns: #tlCollisionResult type containing info about the collision
		about: Use this to check for a collision with another #tlLine that you pass to the method. You can then use the information stored in 
		#tlCollisionResult to perform various things based on the result of the collision check.
	end rem
	Method LineCollide:tlCollisionResult(Line:tlLine)
		
		If Not Super.BoundingBoxOverlap(Line, True) Return Null
	
		Local result:tlCollisionResult = New tlCollisionResult
		
		Local axis:tlVector2
		
		Local min0:Float, max0:Float
		Local min1:Float, max1:Float
		
		Local dotoffset:Float
		
		Local velocityoffset0:Float
		Local velocityoffset1:Float
		
		Local overlapdistance:Float
		Local veloverlapdistance:Float
		Local minoverlapdistance:Float = $7fffffff
		
		
		Local woffset:tlVector2 = New tlVector2.Create(world.x - Line.world.x, world.y - Line.world.y)

		For Local c:Int = 0 To 3
		
			If c < 2
				axis = normals[c]
			Else
				axis = Line.normals[c - 2]
			End If
		
			project(axis, min0, max0)
			Line.Project(axis, min1, max1)
			
			dotoffset = axis.DotProduct(woffset)
			
			min0:+dotoffset
			max0:+dotoffset
			
			overlapdistance = intervaldistance(min0, max0, min1, max1)
			If overlapdistance > 0
				result.intersecting = False
			End If
			
			If velocity.x Or velocity.y Or Line.velocity.x Or Line.velocity.y
				If velocity.x Or velocity.y
					velocityoffset0 = axis.DotProduct(velocity)
					min0:+velocityoffset0
					max0:+velocityoffset0
				End If
				If Line.velocity.x Or Line.velocity.y
					velocityoffset1 = axis.DotProduct(Line.velocity)
					min1:+velocityoffset1
					max1:+velocityoffset1
				End If
				veloverlapdistance = IntervalDistance(min0, max0, min1, max1)
				If veloverlapdistance > 0
					result.willintersect = False
				Else
					overlapdistance = veloverlapdistance
				End If
			Else
				result.willintersect = False
			End If
			
			If Not result.intersecting And Not result.willintersect Return result
			
			overlapdistance = Abs(overlapdistance)
						
			If overlapdistance < minoverlapdistance
				minoverlapdistance = overlapdistance
				result.surfacenormal = axis.Clone()
				Local polytopolyvec:tlVector2 = world.SubtractVector(Line.world)
				If polytopolyvec.DotProduct(result.surfacenormal) < 0 result.surfacenormal.SetPosition(-result.surfacenormal.x, -result.surfacenormal.y)
			End If
			
		Next
		
		result.translationvector = result.surfacenormal.Scale(minoverlapdistance)
		result.source = Self
		result.target = Line
		Return result
	End Method
	
	Rem
		bbdoc: Check for a collision with a #tlPoly
		returns: #tlCollisionResult type containing info about the collision
		about: Use this to check for a collision with a #tlPoly that you pass to the method. You can then use the information stored in 
		#tlCollisionResult to perform various things based on the result of the collision check.
	end rem
	Method PolyCollide:tlCollisionResult(poly:tlPolygon)
		
		If Not Super.BoundingBoxOverlap(poly, True) Return Null
	
		Local result:tlCollisionResult = New tlCollisionResult
		
		Local axis:tlVector2
		
		Local min0:Float, max0:Float
		Local min1:Float, max1:Float
		
		Local dotoffset:Float
		
		Local velocityoffset0:Float
		Local velocityoffset1:Float
		
		Local overlapdistance:Float
		Local veloverlapdistance:Float
		Local minoverlapdistance:Float = $7fffffff
		
		
		Local woffset:tlVector2 = New tlVector2.Create(world.x - poly.world.x, world.y - poly.world.y)

		For Local c:Int = 0 To 2 + poly.vertices.Length - 1
		
			If c < 2
				axis = normals[c]
			Else
				axis = poly.normals[c - 2]
			End If
		
			project(axis, min0, max0)
			poly.Project(axis, min1, max1)
			
			dotoffset = axis.DotProduct(woffset)
			
			min0:+dotoffset
			max0:+dotoffset
			
			overlapdistance = intervaldistance(min0, max0, min1, max1)
			If overlapdistance > 0
				result.intersecting = False
			End If
			
			If velocity.x Or velocity.y Or poly.velocity.x Or poly.velocity.y
				If velocity.x Or velocity.y
					velocityoffset0 = axis.DotProduct(velocity)
					min0:+velocityoffset0
					max0:+velocityoffset0
				End If
				If poly.velocity.x Or poly.velocity.y
					velocityoffset1 = axis.DotProduct(poly.velocity)
					min1:+velocityoffset1
					max1:+velocityoffset1
				End If
				veloverlapdistance = IntervalDistance(min0, max0, min1, max1)
				If veloverlapdistance > 0
					result.willintersect = False
				Else
					overlapdistance = veloverlapdistance
				End If
			Else
				result.willintersect = False
			End If
			
			If Not result.intersecting And Not result.willintersect Return result
			
			overlapdistance = Abs(overlapdistance)
						
			If overlapdistance < minoverlapdistance
				minoverlapdistance = overlapdistance
				result.surfacenormal = axis.Clone()
				Local polytopolyvec:tlVector2 = world.SubtractVector(poly.world)
				If polytopolyvec.DotProduct(result.surfacenormal) < 0 result.surfacenormal.SetPosition(-result.surfacenormal.x, -result.surfacenormal.y)
			End If
			
		Next
		
		result.translationvector = result.surfacenormal.Scale(minoverlapdistance)
		result.source = Self
		result.target = poly
		Return result
	End Method
	
	Rem
		bbdoc: See is a ray collides with this #tlLine
		returns: #tlCollisionResult with the results of the collision
		about: You can use this to test for a collision with a ray. Pass the origin of the ray with px and py, and set the direction of the ray with dx and dy.
		dx and dy will be normalised and extended infinitely, if maxdistance equals 0 (default), otherwise set maxdistance to how ever far you want the ray 
		to extend to. If the ray starts inside the poly then result.rayorigininside will be set to true.
	end rem
	Method RayCollide:tlCollisionResult(px:Float, py:Float, dx:Float, dy:Float, maxdistance:Float = 0)
		
		Local result:tlCollisionResult = New tlCollisionResult
		
		If PointInside(px, py)
			result.rayorigininside = True
			result.rayintersection = New tlVector2.Create(0, 0)
			Return result
		End If
		
		Local p:tlVector2 = CreateVector2(px, py)
		Local d:tlVector2 = CreateVector2(dx, dy)
		
		Local raydot:Float
		Local edge:tlVector2
		Local iedge:tlVector2
		
		Local vw:tlVector2
		Local intersect:tlVector2
		Local distance:Float
		
		d.Normalise()
		
		For Local c:Int = 0 To 1
			raydot = d.DotProduct(normals[c])
			If raydot < 0 And p.SubtractVector(tformvertices[c].AddVector(world)).DotProduct(normals[c]) > 0
				vw = tformvertices[c].AddVector(world)
				distance = normals[c].DotProduct(p.SubtractVector(vw))
				distance = Abs(distance / raydot)
				If (maxdistance > 0 And distance <= maxdistance) Or maxdistance = 0
					intersect = d.Scale(distance).AddVector(p)
					vw = intersect.SubtractVector(world)
					If c = 0
						edge = tformvertices[1].SubtractVector(tformvertices[0])
						iedge = tformvertices[1].SubtractVector(vw)
					Else
						edge = tformvertices[0].SubtractVector(tformvertices[1])
						iedge = tformvertices[0].SubtractVector(vw)
					End If
					raydot = edge.DotProduct(iedge)
					If raydot >= 0 And raydot <= edge.DotProduct(edge)
						result.rayintersection = intersect
						result.surfacenormal = normals[c]
						result.raydistance = distance
						result.target = Self
						Return result
					End If
				End If
			End If
		Next
		
		result.intersecting = False
		result.willintersect = False
		
		Return result
	
	End Method
	
	'internal stuff---------------------------------
	Method GetVoronoiAxis:tlVector2(point:tlVector2)
		
		Local edge:tlVector2
		Local vc:tlVector2
		Local dot:Float
		
		point = point.SubtractVector(world)
		
		edge = tformvertices[1].SubtractVector(tformvertices[0])
		vc = point.SubtractVector(tformvertices[0])
		dot = vc.DotProduct(edge)
		
		If dot > edge.DotProduct(edge)
			vc = point.SubtractVector(tformvertices[1])
			vc.Normalise()
			Return vc
		ElseIf dot < 0
			vc.Normalise()
			Return vc
		Else
			Return Null
		End If
		
		Return Null
		
	End Method
	
	Method TForm()
		'This transforms the line according to the current scale/angle. Both local and transformed vertices are stored within the type, which
		'while takes more memory, makes things a bit easier, and I think a bit faster!
		ResetBoundingBox()
		tformvertices[0].SetPosition(scale.x * vertices[0].x + handle.x, scale.x * vertices[0].y + handle.y)
		tformvertices[0] = tformmatrix.transformvector(tformvertices[0])
		UpdateBoundingBox(tformvertices[0].x, tformvertices[0].y)
		tformvertices[1].SetPosition(scale.x * vertices[1].x + handle.x, scale.x * vertices[1].y + handle.y)
		tformvertices[1] = tformmatrix.transformvector(tformvertices[1])
		UpdateBoundingBox(tformvertices[1].x, tformvertices[1].y)
		UpdateNormals()
		UpdateDimensions()
		TFormBoundingBox()
	End Method
	
	Method UpdateNormals()
		normals[0].SetPosition(-(tformvertices[1].y - tformvertices[0].y), tformvertices[1].x - tformvertices[0].x)
		normals[1].SetPosition(-(tformvertices[0].y - tformvertices[1].y), tformvertices[0].x - tformvertices[1].x)
		normals[0].Normalise()
		normals[1].Normalise()
	End Method
	
	Method Project(axis:tlVector2, minimum:Float Var, maximum:Float Var)
		'This projects the line onto an axis and lets us know the min and max dotproduct values
		Local dotproduct:Float = axis.DotProduct(tformvertices[0])
		minimum = dotproduct
		maximum = dotproduct
		dotproduct = tformvertices[1].DotProduct(axis)
		If dotproduct < minimum
			minimum = dotproduct
		ElseIf dotproduct > maximum
			maximum = dotproduct
		End If
	End Method

End Type

'Quadtree Wrapper

Rem
	bbdoc: Create a new #tlQuadTree
	returns: A new #tlQuadtree
	about: Creates a new quad tree with the coordinates and dimensions given. Maxlevels determines how many times the quadtree can be sub divided. A
	quadtreenode is only subdivided when a certain amount of objects have been added, which is set by passing maxpernode. There's no optimum values for
	these, it largely depends on your specific needs, so you will probably do well to experiment.
end rem
Function CreateQuadtree:tlQuadtree(x:Float, y:Float, w:Float, h:Float, maxlevels:Int = 4, maxpernode:Int = 4)
	Local quadtree:tlQuadTree = New tlQuadTree.Create(x, y, w, h, maxlevels, maxpernode)
	Return quadtree
End Function

Rem
	bbdoc: Add a new bounding box to the Quadtree
	returns: False if the box doesn't overlap the quadtree, otherwise True.
	about: A quadtree isn't much use without any objects. Use this to add a #tlBox to the quadtree. If the bounding box does not overlap the 
	quadtree then null is returned.
end rem
Function AddBoundaryToQuadtree:Int(quadtree:tlQuadTree, Box:tlBox)
	Return QuadTree.AddBox(Box)
End Function

Rem
	bbdoc: Query a Quadtree to find objects with an area
	about: When you want to find objects within a particular area of the quadtree you can use this method.  Pass the area coordinates and dimensions
	that you want to check, an object (Data) that can be anything that you want to pass through to the callback function, and the function callback that you want 
	to perform whatever tasks you need on the objects that are found within the area.
	The callback function you create needs to have 2 parameters: ReturnedObject:object which will be the Box/circle/poly, and Data:object which can be
	an object you want to pass through to the call back function.
	Use #GetObjectsFound to find out how many objects were found on the last search.
end rem
Function QueryQuadtreeArea(Quadtree:tlQuadTree, x:Float, y:Float, w:Float, h:Float, Data:Object, callback:Int(ReturnedObject:Object, Data:Object), Layer:Int = tlLAYER_ALL)
	QuadTree.ForEachObjectInArea(x, y, w, h, data, callback, layer)
End Function

Rem
	bbdoc: Query a quadtree to find objects within a #tlBox
	about: This does the same thing as #QueryQuadtreeArea except you can pass a #tlBox instead to query the quadtree.
end rem
Function QueryQuadtreeBox(Quadtree:tlQuadTree, area:tlBox, Data:Object, callback:Int(o:Object, Data:Object), Layer:Int = tlLAYER_ALL)
	QuadTree.ForEachObjectInBox(area, data, callback, layer)
End Function

Rem
	bbdoc: Query a quadtree to find objects within a certain radius
	about: This will query the quadtree and do a callback on any objects it finds within a given radius. See #QueryQuadtreeArea for more info.
end rem
Function QueryQuadtreeRange(Quadtree:tlQuadTree, x:Float, y:Float, radius:Float, Data:Object, callback:Int(ReturnedObject:Object, Data:Object), Layer:Int = tlLAYER_ALL)
	QuadTree.ForEachObjectWithinRange(x, y, radius, data, callback, layer)
End Function

Rem
	bbdoc: Query a quadtree to find objects within a #tlCircle
	about: This will query the quadtree and do a callback on any objects it finds within the given #tlCircle.
end rem
Function QueryQuadtreeCircle(Quadtree:tlQuadTree, circle:tlCircle, Data:Object, callback:Int(ReturnedObject:Object, Data:Object), Layer:Int = tlLAYER_ALL)
	QuadTree.ForEachObjectInBoxCircle(circle, data, callback, layer)
End Function

Rem
	bbdoc: Query a quadtree with a Ray
	returns: False if the ray did not hit anything, otherwise True
	about: This will query the quadtree with a ray and perform a callback on the first object the ray hits. Pass the quadtree to do the query on, the
	starting point of the ray (px,py), the direction vector of the ray (dx,dy), the maximum distance you want the ray to travel (maxdistance, 0 means
	an infinit ray will be cast), an object you want to pass through to the callback, and the callback itself. It's worth noting that the callback also requires
	you have a #tlCollisionResult parameter which will be passed to the callback function with information about the results of the raycast.
end rem
Function QueryQuadtreeRay:Int(Quadtree:tlQuadTree, px:Float, py:Float, dx:Float, dy:Float, maxdistance:Float = 0, Data:Object, callback:Int(ReturnedObject:Object, Data:Object, Result:tlCollisionResult), Layer:Int = tlLAYER_ALL)
	Return QuadTree.RayCast(px, py, dx, dy, maxdistance, data, callback, layer)
End Function

Rem
	bbdoc: Query a quadtree with a line edge
	returns: False if the line did not touch anything, otherwise True
	about: This will query the quadtree with a line and perform a callback on all the objects the line intersects. Pass the quadtree to do the query on, the
	start and end point of the line (x1,y1,x2,y2), an object you want to pass through to the callback, and the callback itself. It's worth noting that the callback also requires
	you have a #tlCollisionResult parameter which will be passed to the callback function with information about the results of the raycast.
end rem
Function QueryQuadtreeEdge:Int(Quadtree:tlQuadTree, x1:Float, y1:Float, x2:Float, y2:Float, Data:Object, callback:Int(ReturnedObject:Object, Data:Object, Result:tlCollisionResult), Layer:Int = tlLAYER_ALL)
	Local line:tlLine = New tlLine.CreateLine(x1, y1, x2, y2)
	Return QuadTree.ForEachObjectAlongLine(line, data, callback, layer)
End Function

Rem
	bbdoc: Query a quadtree with a #tlLine
	returns: False if the line did not touch anything, otherwise True
	about: This will query the quadtree with a line and perform a callback on all the objects the #tlLine intersects. Pass the quadtree to do the query on, the
	#tlLine to query with, an object you want to pass through to the callback, and the callback itself. It's worth noting that the callback also requires
	you have a #tlCollisionResult parameter which will be passed to the callback function with information about the results of the raycast.
end rem
Function QueryQuadtreeLine:Int(Quadtree:tlQuadTree, Line:tlLine, Data:Object, callback:Int(ReturnedObject:Object, Data:Object, Result:tlCollisionResult), Layer:Int = tlLAYER_ALL)
	Return QuadTree.ForEachObjectAlongLine(line, data, callback, layer)
End Function

Rem
	bbdoc: Perform some house keeping on a quadtree
	about: This will search a quadtree tree for any empty #tlQuadTreeNodes and unpartition them if necessary. It's probably unnecessary to run to every frame.
	Every other frame should be more then enough, and maybe not even necessary at all, it will depend on how you're using the quadtree.
end rem
Function RunQuadtreeMaintenance(Quadtree:tlQuadtree)
	quadtree.RunMaintenance()
End Function

Rem
	bbdoc: Remove a boundary from the quadtree
	about: This will remove a boundary from the quadtree. You'll need to do this when your actor/entity using the boundary is destroyed, blown up or whatever!
	No need to pass the quadtree as the boundary knows what quadtree it lives in.
end rem
Function RemoveBoundaryFromQuadTree(Box:tlBox)
	Box.RemoveFromQuadTree()
End Function


'Box Wrappers

Rem
	bbdoc: Create a new #tlBox
	returns: New #tlBox
	about: Creates a new Bounding box that you can use for collision checking and adding to a #tlQuadTree. Use layer to specify a particular layer
	to place the box on so that you can more easily organise your collisions. You use tlLAYER_1, tlLAYER_2..and so on up to tlLAYER_32, or tlLAYER_ALL
	to place the boundary on all layers.
end rem
Function CreateBox:tlBox(x:Float, y:Float, w:Float, h:Float, layer:Int = tlLAYER_1)
	Return New tlBox.Create(x, y, w, h, layer)
End Function

Rem
	bbdoc: Create a #tlCircle
	returns: New #tlCircle
	about: Create a new #tlLine at the coordinates given, x1 and y1 being the start of the line and x2 and y2 being the end. The will placed exactly
	according to the coordinates you give, but it's worth bearing in mind that the handle of the line will be at the center point along the line. Therefore
	the world coordinates will be set to half way point along the line. Use layer to specify a particular layer
	to place the box on so that you can more easily organise your collisions. You use tlLAYER_1, tlLAYER_2..and so on up to tlLAYER_32, or tlLAYER_ALL
	to place the boundary on all layers.
end rem
Function CreateLine:tlLine(x1:Float, y1:Float, x2:Float, y2:Float, layer:Int = tlLAYER_1)
	Return New tlLine.CreateLine(x1, y1, x2, y2, layer)
End Function

Rem
	bbdoc: Create a #tlLine
	returns: New #tlLine
	about: Create a new #tlLine at the given coordinates with the given radius. The coordinates will represent the center of the circle. Use layer to specify a particular layer
	to place the box on so that you can more easily organise your collisions. You use tlLAYER_1, tlLAYER_2..and so on up to tlLAYER_32, or tlLAYER_ALL
	to place the boundary on all layers.
end rem
Function CreateCircle:tlCircle(x:Float, y:Float, radius:Float, layer:Int = tlLAYER_1)
	Return New tlCircle.CreateCircle(x, y, radius, layer)
End Function

Rem
	bbdoc: Create a #tlPolygon
	returns: New #tlPolygon, or Null if verts[] contained the wrong amount.
	about: Create a new #tlPolygon at the given coordinates with the given array of vertices. The coordinates will represent the center of the polygon which is
	automatically calculated. The array must contain more then 5 values (2 per vertex) and be an even number or null will be returned. The coordinates of
	the vertices in the array are arranged like so: [x,y,x,y,x,y .. etc]. Use layer to specify a particular layer
	to place the box on so that you can more easily organise your collisions. You use tlLAYER_1, tlLAYER_2..and so on up to tlLAYER_32, or tlLAYER_ALL
	to place the boundary on all layers.
end rem
Function CreatePolygon:tlPolygon(x:Float, y:Float, verts:Float[], layer:Int = tlLAYER_1)
	Return New tlPolygon.CreatePoly(x, y, verts, layer)
End Function

Rem
	bbdoc: Set the position of a Boundary.
	about: Sets the position of a #tlBox, #tlCircle or #tlPolygon.
end rem
Function SetBoundaryPosition(Boundary:tlBox, x:Float, y:Float)
	Boundary.SetPosition(x, y)
End Function

Rem
	bbdoc: Set the collision layer that this boundary is on
	about: The layer a boundary is on can determine what other boundarys this one can collide with. You may not want some objects to be able to collide
	with each other, so you can arrange them of different layers. There are 32 layers, assigned to constants: tlLAYER_1, tlLAYER2, tlLAYER_3.. and so on up
	to 32, so to assign a layer, simply pass the appropriate constant:
	&{MyBox.SetCollisionLayer(tlLAYER_1)}
	You can also assign to more then one layer using OR:
	&{MyBox.SetCollisionLayer(tlLAYER_1 | tlLAYER_2 | tlLAYER_3)}
	Finally, assign it to all layers using:
	&{MyBox.SetCollisionLayer(tlLAYER_ALL)}
End Rem
Function SetBoundaryLayer(Boundary:tlBox, layer:Int)
	Boundary.SetCollisionLayer(layer)
End Function

Rem
	bbdoc: Get the collision layer that this boundary is on
	Returns: The Collision layer flag
	about: Every boundary can exist on a sepcific layer from 1-32 to make it easier to handle what objects you want to collide with each other.
End Rem
Function GetBoundaryLayer:Int(Boundary:tlBox)
	Return Boundary.GetCollisionLayer()
End Function

Rem
	bbdoc: Assign an object to a boundary
	about: This can be handy to store extra custom info about a boundary. 
end rem
Function SetBoundaryData(Boundary:tlBox, Data:Object)
	boundary.SetData(data)
End Function

Rem
	bbdoc: Get the data assigned to a boundary
	about: Use this to retrieve the custom data you have assign to a boundary.
end rem
Function GetBoundaryData:Object(Boundary:tlBox, Data:Object)
	Return boundary.GetData()
End Function

Rem
	bbdoc: Move a Boundary by a given amount.
	about: This sets the position of a #tlBox, #tlCircle or #tlPolygon by moving it by the x and y amount.
end rem
Function MoveBoundary(Boundary:tlBox, x:Float, y:Float)
	Boundary.Move(x, y)
End Function

Rem
	bbdoc: Find out if a point is within a boundary
	returns: True if the point is within
	about: Use this to find out if a point at x,y falls within a #tlBox, #tlCircle or #tlPolygon
end rem
Function PointInside:Int(Boundary:tlBox, x:Float, y:Float)
	Return boundary.PointInside(x, y)
End Function

Rem
	bbdoc: Set the scale of a Boundary
	about: This sets the scale a #tlBox, #tlCircle or #tlPolygon by x and y (or just x in the case if a #tlCircle)
end rem
Function ScaleBoundary(Boundary:tlBox, x:Float, y:Float)
	Boundary.SetScale(x, y)
End Function

Rem
	bbdoc: Set the velocity of a boundary
	about: It's import to set the velocity of the boundary so that collisions can be more accurately calculated. If you're attaching this
	to an entity in your game then you'll just need to match this to your entities velocity.
end rem
Function SetBoundaryVelocity(Boundary:tlBox, Velocity_x:Float, Velocity_y:Float)
	boundary.SetVelocity(velocity_x, velocity_y)
End Function

Rem
	bbdoc: Update the position of the boundary
	about: You can use this function to update a boundary's position according to its current velocity vector
end rem
Function UpdateBoundaryPosition(Boundary:tlBox)
	boundary.UpdatePosition()
End Function

Rem
	bbdoc: Rotate a #tlPolygon
	about: This will rotate the polygon by the given amount
end rem
Function RotatePolygon(Poly:tlPolygon, angle:Float)
	Poly.Rotate(angle)
End Function

Rem
	bbdoc: Set the angle of a #tlPolygon
	about: This will set the angle of a polygon to the given amount
end rem
Function SetPolygonAngle(Poly:tlPolygon, angle:Float)
	Poly.SetAngle(angle)
End Function

Rem
	bbdoc: Check for a collision between 2 Boundaries
	returns: #tlCollisionResult.
	about: You can use this function to check for collisions between any type of boundary: #tlBox, #tlCircle, #tlLine and #tlPolygon. The #tlCollisionResult
	can then be used to determine what you want to do if a collision happened (or will happen). See #PreventOverlap to make boundaries block or push
	each other.
end rem
Function CheckCollision:tlCollisionResult(Source:tlBox, Target:tlBox)
	Select Source.collisiontype
		Case tlBOX_COLLISION
			Select Target.collisiontype
				Case tlBOX_COLLISION
					Return source.BoxCollide(target)
				Case tlCIRCLE_COLLISION
					Return source.CircleCollide(tlCircle(target))
				Case tlPOLY_COLLISION
					Return source.PolyCollide(tlPolygon(target))
				Case tlLINE_COLLISION
					Return source.LineCollide(tlLine(target))
			End Select
		Case tlCIRCLE_COLLISION
			Select Target.collisiontype
				Case tlBOX_COLLISION
					Return tlCircle(source).BoxCollide(target)
				Case tlCIRCLE_COLLISION
					Return tlCircle(source).CircleCollide(tlCircle(target))
				Case tlPOLY_COLLISION
					Return tlCircle(source).PolyCollide(tlPolygon(target))
				Case tlLINE_COLLISION
					Return tlCircle(source).LineCollide(tlLine(target))
			End Select
		Case tlPOLY_COLLISION
			Select Target.collisiontype
				Case tlBOX_COLLISION
					Return tlPolygon(source).BoxCollide(target)
				Case tlCIRCLE_COLLISION
					Return tlPolygon(source).CircleCollide(tlCircle(target))
				Case tlPOLY_COLLISION
					Return tlPolygon(source).PolyCollide(tlPolygon(target))
				Case tlLINE_COLLISION
					Return tlPolygon(source).LineCollide(tlLine(target))
			End Select
		Case tlLINE_COLLISION
			Select Target.collisiontype
				Case tlBOX_COLLISION
					Return tlLine(source).BoxCollide(target)
				Case tlCIRCLE_COLLISION
					Return tlLine(source).CircleCollide(tlCircle(target))
				Case tlPOLY_COLLISION
					Return tlLine(source).PolyCollide(tlPolygon(target))
				Case tlLINE_COLLISION
					Return tlLine(source).LineCollide(tlLine(target))
			End Select
	End Select
End Function

Rem
	bbdoc: Find out if 2 boundaries are on the same collision layers.
	returns: True if they are on the same layer, otherwise false.
end rem
Function SameLayer:Int(Source:tlBox, Target:tlBox)
	If source.collisionlayer & target.collisionlayer Return True
	Return False
End Function

Rem
	bbdoc: See if a ray collides with a boundary
	returns: #tlCollisionResult with the results of the collision
	about: You can use this to test for a collision with a ray and any type of boundary: #tlBox, #tlCircle, #tlLine and #tlPolygon. 
	Pass the origin of the ray with px and py, and set the direction of the raycast with dx and dy vector. dx and dy will be normalised and extended 
	infinitely if maxdistance equals 0 (default), otherwise set maxdistance to how ever far you want the ray to extend to before stopping. If the ray starts 
	inside the poly then result.rayorigininside will be set to true. You can find the angle of reflection to bounce the ray using #GetReboundVector. 
end rem
Function CheckRayCollision:tlCollisionResult(Target:tlBox, px:Float, py:Float, dx:Float, dy:Float, maxdistance:Float = 0)
	
	Return target.RayCollide(px, py, dx, dy, maxdistance)

End Function

Rem
	bbdoc: Prevent boundaries from overlapping, based on a #tlCollisionResult
	about: After you have retrieved a #tlCollisionResult from calling #CheckCollision you can call this function to separate 2 boundaries from each other.
	If push is false (default) then the source boundary will be stopped by the target boundary, otherwsie the source bouandry will push the target boundary
	along it's veloctity vector and the normal of the edge it's pushing against.
	***NOTE*** Remember that after an overlap has been been prevented, the coordinates of the boundary wil have change in order to separate it from the other
	boundary, so remember to update any other objects coordinates to match this (such as your game object). If your game object is dictating where the boundary 
	is located then it might inadvertantly place the bouandary back inside the object it's colliding with causing strange things to happen.
end rem
Function PreventOverlap(Result:tlCollisionResult, Push:Int = False)
	If result
		If result.source
			result.source.PreventOverlap(result, push)
		End If
	End If
End Function

Rem
	bbdoc: Get the rebound vector
	returns: New #tlVector2 with the resulting rebound vector, or v, if there was nothing to rebound
	about: When an object collides with a surface you may want to know a resulting vector based on bounce and friction. So you can call this
	and pass the velocity vector of the incoming object, and the amount of bounce and friction to have, where a bounce value of 1 and a friction value of 0
	will result in a perfect bounce.
end rem
Function GetReboundVector:tlVector2(Result:tlCollisionResult, v:tlVector2, friction:Float = 0, bounce:Float = 1)
	Return result.GetReboundVector(v, friction, bounce)
End Function

'helper functions

Rem
	bbdoc: Do a Line to Circle collision check
	returns: True if line and circle overlap
	about: x1, y1 and x2, y2 represent the beginning and end line coordinates, and px, py and r represent the circle coordinates and radius. 
end rem
Function LineToCircle:Int(x1:Float, y1:Float, x2:Float, y2:Float, px:Float, py:Float, r:Float)
	
	Local sx:Float = x2-x1
	Local sy:Float = y2-y1
	
	Local q:Float = ((px-x1) * (x2-x1) + (py - y1) * (y2-y1)) / (sx*sx + sy*sy)
	
	If q < 0.0 Then q = 0.0
	If q > 1.0 Then q = 1.0
	
	Local cx:Float = (1 - q) * x1 + q * x2
	Local cy:Float = (1 - q) * y1 + q * y2
	
	If getdistance(px, py, cx, cy) < r
		Return True
	Else
		Return False
	EndIf
	
End Function
Rem
	bbdoc: Do a Line to Line collision check
	returns: True if lines overlap
	about: x0, y0, x1, y1 is the first line and x2, y2, x3, y3 is the second line you want want check for an intersection
end rem
Function LinesCross:Int(x0:Float, y0:Float, x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float)
	  
	Local n:Float=(y0-y2)*(x3-x2)-(x0-x2)*(y3-y2)
	Local d:Float=(x1-x0)*(y3-y2)-(y1-y0)*(x3-x2)
	
	If Abs(d) < 0.0001
		Return False
	Else
		Local Sn:Float = (y0 - y2) * (x1 - x0) - (x0 - x2) * (y1 - y0)
		Local AB:Float=n/d
		If AB>0.0 And AB<1.0
			Local CD:Float=Sn/d
			If CD > 0.0 And CD < 1.0 Return True
		End If
	EndIf
	
	Return False

End Function
Rem
	bbdoc: Do a Line to Line collision check and return the point of intersection.
	returns: True if lines overlap, and Sets X_Point and Y_Point to the point of interection.
	about: x0, y0, x1, y1 is the first line and x2, y2, x3, y3 is the second line you want want check for an intersection
end rem
Function LinesCrossAtPoint:Int(x0:Float, y0:Float, x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, X_Point:Float Var, Y_Point:Float Var)
	  
	Local n:Float=(y0-y2)*(x3-x2)-(x0-x2)*(y3-y2)
	Local d:Float=(x1-x0)*(y3-y2)-(y1-y0)*(x3-x2)
	
	If Abs(d) < 0.0001
		Return False
	Else
		Local Sn:Float = (y0 - y2) * (x1 - x0) - (x0 - x2) * (y1 - y0)
		Local AB:Float=n/d
		If AB>0.0 And AB<1.0
			Local CD:Float=Sn/d
			If CD > 0.0 And CD < 1.0
				X_Point:Float = x0 + AB * (x1 - x0)
		       	Y_Point:Float = y0 + AB * (y1 - y0)
				Return True
			End If
		End If
	EndIf
	
	Return False

End Function
Rem
	bbdoc: Get the quad a vertex lies within
	about: This will return the quad a vertex lies within according to the x and y axis you pass it.
end rem
Function GetQuad:Int(axis_x:Float, axis_y:Float, vert_x:Float, vert_y:Float)
	If vert_x<axis_x
		If vert_y<axis_y
			Return 1
		Else
			Return 4
		EndIf
	Else
		If vert_y<axis_y
			Return 2
		Else
			Return 3
		EndIf	
	EndIf
End Function
Rem
	bbdoc: Check if a point is with a field of view
	returns: True if if point is withing observers fov, otherwise false
end rem
Function WithinFieldOfView:Int(Observer_x:Float, Observer_y:Float, FOV:Float, Direction:Float, PointX:Float, PointY:Float)
	Return AngleDifference(GetDirection(observer_x, observer_y, pointx, pointy), direction) <= fov *.5
End Function
Rem
	bbdoc: Return the nearest point on a line to the center of a circle
	returns: NearestPoint_x and NearestPoint_y
	about: x1, y1 and x2, y2 represent the beginning and end line coordinates, and px, py and r represent the circle coordinates and radius. 
end rem
Function NearestPointToCircle:Int(x1:Float, y1:Float, x2:Float, y2:Float, px:Float, py:Float, r:Float, NearestPoint_x:Float, NearestPoint_y:Float)
	
	Local sx:Float = x2-x1
	Local sy:Float = y2-y1
	
	Local q:Float = ((px-x1) * (x2-x1) + (py - y1) * (y2-y1)) / (sx*sx + sy*sy)
	
	If q < 0.0 Then q = 0.0
	If q > 1.0 Then q = 1.0
	
	NearestPoint_x = (1 - q) * x1 + q * x2
	NearestPoint_y = (1 - q) * y1 + q * y2
	
End Function
Rem
	bbdoc: Find the amount of overlap between 2 1D lines
	returns: The amount of overlap. Any value less then 0 is not overlapping.
end rem
Function IntervalDistance:Float(min0:Float, max0:Float, min1:Float, max1:Float)
	If min0 < min1
		Return min1 - max0
	Else
		Return min0 - max1
	End If
End Function

'Constants

'Types of collision
Const tlBOX_COLLISION:Int = 0
Const tlCIRCLE_COLLISION:Int = 1
Const tlPOLY_COLLISION:Int = 2
Const tlLINE_COLLISION:Int = 3

'Types of Light
Const tlSPOT_LIGHT:Int = 0
Const tlDIRECTIONAL_LIGHT:Int = 1

'Collision Layer bit Flags
Const tlLAYER_1:Int = 1
Const tlLAYER_2:Int = 1 Shl 1
Const tlLAYER_3:Int = 1 Shl 2
Const tlLAYER_4:Int = 1 Shl 3
Const tlLAYER_5:Int = 1 Shl 4
Const tlLAYER_6:Int = 1 Shl 5
Const tlLAYER_7:Int = 1 Shl 6
Const tlLAYER_8:Int = 1 Shl 7
Const tlLAYER_9:Int = 1 Shl 8
Const tlLAYER_10:Int = 1 Shl 9
Const tlLAYER_11:Int = 1 Shl 10
Const tlLAYER_12:Int = 1 Shl 11
Const tlLAYER_13:Int = 1 Shl 12
Const tlLAYER_14:Int = 1 Shl 13
Const tlLAYER_15:Int = 1 Shl 14
Const tlLAYER_16:Int = 1 Shl 15
Const tlLAYER_17:Int = 1 Shl 16
Const tlLAYER_18:Int = 1 Shl 17
Const tlLAYER_19:Int = 1 Shl 18
Const tlLAYER_20:Int = 1 Shl 19
Const tlLAYER_21:Int = 1 Shl 20
Const tlLAYER_22:Int = 1 Shl 21
Const tlLAYER_23:Int = 1 Shl 22
Const tlLAYER_24:Int = 1 Shl 23
Const tlLAYER_25:Int = 1 Shl 24
Const tlLAYER_26:Int = 1 Shl 25
Const tlLAYER_27:Int = 1 Shl 26
Const tlLAYER_28:Int = 1 Shl 27
Const tlLAYER_29:Int = 1 Shl 28
Const tlLAYER_30:Int = 1 Shl 29
Const tlLAYER_31:Int = 1 Shl 30
Const tlLAYER_32:Int = 1 Shl 31
Const tlLAYER_ALL:Int = $FFFFFFFF