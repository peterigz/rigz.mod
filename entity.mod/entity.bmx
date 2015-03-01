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
	bbdoc: Timeline Entity System for blitzmax
	about: This module provides a base entity class for use in any applications that need to have objects in world that need to be controlled
	and drawn onto the screen. tlEntity provides the means to control these objects in a structured hierarchy with parent and child entities.
	Entities are drawn using sprites from the single surface module; singlesurface.mod.
end rem
Module rigz.entity
ModuleInfo "Author: Peter J. Rigby"
ModuleInfo "Copyright: Peter J. Rigby 2009"
ModuleInfo "Purpose: A base entity class"
ModuleInfo "Version: v1.07"

ModuleInfo "History v1.07: 8th November 2009 - Tidied up the behaviour of entities that have a z value other then 1"
ModuleInfo "History v1.07: 7th November 2009 - New field: RootParent. This is the absolute root parent of the entity. Set when you add the entity as a child. see AssignRootParent"
ModuleInfo "History v1.07: 1st November 2009 - You can now SetRadiusCalculate Which starts calculating the entity's area of influence. See SetRadiusCalculate"
ModuleInfo "History v1.06: 20th September 2009 - Initial implementation of Z on entities (changes the overal scale of an entity and its children)"
ModuleInfo "History v1.04: 7th September 2009 - Added a few more Getters and Setters"
ModuleInfo "History v1.04: 7th September 2009 - Fixed a bug with animated entities causing a crash"
ModuleInfo "History v1.03: 8th August 2009 - Added new variables for storing the bounding boxes of the entity"
ModuleInfo "History v1.03: 8th August 2009 - Render method now only renders if avatar is not null and OKToRender is true"
ModuleInfo "History v1.03: 8th August 2009 - Added OKToRender field so you can control wheter entities are actually rendered"
ModuleInfo "History v1.03: 8th August 2009 - Add a few more getters and settings for various variables"
ModuleInfo "History v1.03: 7th August 2009 - Added UpdateSpeed flag to tlEntity so you can override the updating of the entity speed and movement"
ModuleInfo "History v1.02: 27th July 2009 - Changed field cs to speed for more readability and added GetSpeed method"
ModuleInfo "History v1.01: 14th July 2009 - Moved tp_LOOKUP_FREQUENCY and tp_LOOKUP_FREQUENCY_OVERTIME over to timelinefx.mod"
ModuleInfo "History v1.01: 14th July 2009 - Render method now renders all children as well"
ModuleInfo "History v1.01: 14th July 2009 - Tidied up the documentation and fleshed it out a bit"
ModuleInfo "History v1.01: 14th July 2009 - Fixed bug in tlEntity example - import brl.pngloader was omitted"
ModuleInfo "History v1.01: 13th July 2009 - Fixed a bug in tAnimImage where it wouldn't load images properly"
ModuleInfo "History v1.00: 28th March 2009 - First Release"

Import rigz.singlesurface
Import "consts.bmx"
Import rigz.math
Import rigz.vector

Rem
	bbdoc: Entity type for basic object information
	about: <p>This is the main type for storing entity information such as coordinates, colour and other information. This type is designed to be a base
	type that you can use to extend and create other types, for example tPlayer or tBullet. </p>
	<p>Entities can be parented to other entities and maintain and update a list of children. These children can be relative to their parents therefore
	minimising the work needed to calculate where entities should be drawn to the screen. If a parent rotates, then it's children will rotate with it and
	likewise, if the parent moves then its children will move with it as well. Children don't have to be relative however, set realative to false using #setrelative
	to make the children move independantly, however they will still be updated by their parent</p>
	<p>If you have an entity with children, and those children in turn have children, in order to update all of those entities only one call to the parent
	#update method is required to see all of the children updated too. This also applies to rendering the entities on screen - by calling #render on the parent entity
	all children entities will also be rendered. See the code below for an example</p>
	<p>Entities draw to the screen using tAnimImage, a type that allows for single surface drawing from the singlesurface.mod. To set the image use #setavatar
	and loadsprite() to set the tAnimImage. You can adjust the appearence of the entity such as colour and scale using commands such as #setentitycolor, #setentityalpha,
	#setentityscale and #setangle</p>
	<p>When entities are rendered they can be tweened so that their animation and movement on the screen is smoothed out using fixed rate timing. To do this you need to make a call
	to #capture each time the entity is updated which stores the entities last position and other details. #Capture is not included in the #udpate method because it makes things
	too inflexible. There are situations where you might want to specify when exactly you want to #capture the entity. This means that when you extend tlentity it's a good idea to 
	overide the update method with your own and include a call to capture within it. Then you can make a call to super.update so that the base update method is still tun. Again, see 
	the example to see how it can work.</p>
endrem
Type tlEntity
	
	'Coordinates----------------------
	Field x:Float, y:Float									'x and y coords
	Field oldx:Float, oldy:Float							'old x and y coords for tweening
	Field wx:Float, wy:Float								'World Coords
	Field oldwx:Float, oldwy:Float							'Old world coords for tweening
	Field z:Float = 1										'z height off ground
	Field oldz:Float = 1									'old z coords for tweening
	Field relative:Int = 1									'whether the entity remains relative to it's parent. Relative is the default.
	'---------------------------------
	Field matrix:tlMatrix2 = New tlMatrix2.Create()			'A matrix to calculate entity rotation relative to the parent
	Field spawnmatrix:tlMatrix2 = New tlMatrix2.Create()	'May be moved in the future to tlParticle!
	Field rotvec:tlVector2 = New tlVector2.Create(0, 0)		'Vector formed between the parent and the children
	Field speedvec:tlVector2 = New tlVector2.Create(0, 0)	'vector created by he speed and direction of the entity
	Field gravvec:tlVector2 = New tlVector2.Create(0, 0)	'vector created by the current down force of the entity
	'Entity name----------------------
	Field name:String										'name
	'---------------------------------
	'Colours--------------------------
	Field r:Int, g:Int, b:Int								'Avatar color in editor
	Field red:Int = 255										'Tint Colours
	Field green:Int = 255
	Field blue:Int = 255
	Field oldred:Int = 255
	Field oldgreen:Int = 255
	Field oldblue:Int = 255
	'---------------------------------
	'Size attributes and weight-------
	Field width:Float, height:Float							'width and height
	Field weight:Float										'current weight
	Field gravity:Float										'current speed of the drop
	Field baseweight:Float									'base weight
	Field oldweight:Float									'tween weight
	Field scalex:Float = 1, scaley:Float = 1				'scale
	Field sizex:Float = 1, sizey:Float = 1					'size
	Field oldscalex:Float = 1, oldscaley:Float = 1			'Tweening
	'---------------------------------
	'Speed settings and variables-----
	Field speed:Float										'current speed
	Field basespeed:Float									'base speed of entity
	Field oldcs:Float										'Old speed for tweening
	Field UpdateSpeed:Float = True							'Set to false to make the update method avoid updating the speed and movement
	'---------------------------------
	'Direction and rotation-----------
	Field direction:Float									'current direction
	Field directionlocked:Int								'Locks the direction to the edge of the effect, for edage traversal
	Field angle:Float										'current rotation of the entity
	Field oldangle:Float									'Tweening angle
	Field relativeangle:Float								'To store the angle imposed by the parent
	Field oldrelativeangle:Float
	'---------------------------------
	'Image settings and animation-----
	Field avatar:TAnimImage									'link to the image that represents the entity
	Field frameoffset:Float									'animation offset
	Field framerate:Float = 1
	Field currentframe:Float								'current frame of animation
	Field oldcurrentframe:Float
	Field animating:Int										'whether or not the entity should be animating
	Field animateonce:Int									'whether the entity should animate just the once
	Field animaction:Int									'how the entity should animate
	Field handlex:Int
	Field handley:Int
	Field autocenter:Int = True								'True if the handle of the entity is at the center of the image
	Field oktorender:Int = True								'Set to false if you don't want this to be rendered
	'---------------------------------
	'life and age variables-----------
	Field dob:Float
	Field age:Float
	Field rptageA:Float
	Field rptageC:Float
	Field acycles:Int
	Field ccycles:Int
	Field oldage:Float
	Field dead:Int
	Field destroyed:Int
	Field lifetime:Int
	Field timediff:Float
	'---------------------------------
	'Bounding Box info
	Field AABB_Calculate:Int = True
	Field Collision_xmin:Float
	Field Collision_ymin:Float
	Field Collision_xmax:Float
	Field Collision_ymax:Float
	Field AABB_xmin:Float
	Field AABB_ymin:Float
	Field AABB_xmax:Float
	Field AABB_ymax:Float
	Field AABB_MaxWidth:Float
	Field AABB_MaxHeight:Float
	Field AABB_MinWidth:Float
	Field AABB_MinHeight:Float
	Field Radius_Calculate:Int = True
	Field Image_Radius:Float								'This is the radius of which the image can be drawn within
	Field Entity_Radius:Float								'This is the radius that encompasses the whole entity, including children
	Field Image_Diameter:Float
	'---------------------------------
	'Ownerships-----------------------
	Field parent:tlEntity									'parent of the entity, for example bullet fired by the entity
	Field rootparent:tlEntity								'The root parent of the entity
	'Children
	Field children:TList = CreateList()						'list of child entities
	Field childcount:Int									'count of children
	'---------------------------------
	Field blendmode:Int = ALPHABLEND						'blend mode of the entity
	'Alpha settings-------------------
	Field alpha:Float = 1									'current alpha level of the entity
	Field oldalpha:Float									'Tweening alpha
	'---------------------------------
	'Flags----------------------------
	Field runchildren:Int									'When the entity is created, this is false to avoid runninng it's children on creation to avoid recursion
	'Temps
	Field pixelspersecond:Float
	'methods--------------------------
	Rem
		bbdoc: Update the entity
		about: Updates its coordinates based on the current speed (cs), applies any gravity, updates the current frame of the image and also updates the world coordinates. World
		coordinates (wx and wy) represent the location of the entity where it will be drawn on screen. This is calculated based on where the entity is in relation to
		it's parent entities. Update also updates the entity's children so only a single call to the parent entity is required to see all the children updated.
	endrem
	Method Update()
	
		'Update speed in pixels per second
		If UpdateSpeed And speed
			pixelspersecond = speed / tp_CURRENT_UPDATE_TIME
			speedvec.x = Sin(direction) * pixelspersecond
			speedvec.y = Cos(direction) * pixelspersecond
			If relative
					x:+speedvec.x
					y:-speedvec.y
			Else
				If z <> 1
					x:+speedvec.x * z
					y:-speedvec.y * z
				Else
					x:+speedvec.x
					y:-speedvec.y				
				End If
			End If
		End If
		
		'update the gravity
		If weight
			If relative
				gravity:+weight / tp_CURRENT_UPDATE_TIME
				y:+gravity / tp_CURRENT_UPDATE_TIME
			Else
				If z <> 1
					gravity:+weight / tp_CURRENT_UPDATE_TIME
					y:+(gravity / tp_CURRENT_UPDATE_TIME) * z
				Else
					gravity:+weight / tp_CURRENT_UPDATE_TIME
					y:+gravity / tp_CURRENT_UPDATE_TIME
				End If
			End If
		End If
		
		'set the matrix if it is relative to the parent
		If relative matrix.set(Cos(angle), Sin(angle), -Sin(angle), Cos(angle))
		
		'calculate where the entity is in the world
		If parent And relative
			setz(parent.z)
			matrix = matrix.transform(parent.matrix)
			rotvec:tlVector2 = parent.matrix.transformvector(New tlVector2.Create(x, y))
			If z <> 1
				wx = parent.wx + rotvec.x * z
				wy = parent.wy + rotvec.y * z
			Else
				wx = parent.wx + rotvec.x
				wy = parent.wy + rotvec.y
			End If
			relativeangle = parent.relativeangle + angle
		Else
			'If parent setz(parent.z)
			wx = x
			wy = y
		End If
		
		If Not parent
			relativeangle = angle
		End If
		
		'update animation frame
		If avatar And animating
			currentframe:+framerate / tp_CURRENT_UPDATE_TIME
			If animateonce
				If currentframe > avatar.frames - 1
					currentframe = avatar.frames - 1
				Else If currentframe <= 0
					currentframe = 0
				End If
			End If
		End If
		
		'update the Axis Aligned Bounding Box
		If AABB_Calculate
			UpdateBoundingBox()
		End If
		
		'update the radius of influence
		If Radius_Calculate
			UpdateEntityRadius()
		End If
		
		'update the children		
		updatechildren()
		
	End Method
	Rem
		bbdoc: A mini update called when the entity is created
		about: This is sometimes necessary to get the correct world coordinates for when new entities are spawned so that tweening is updated too. Otherwise
		you might experience the entity shooting across the screen as it tweens between locations.
	endrem
	Method MiniUpdate()
	
		matrix.set(Cos(angle), Sin(angle), - Sin(angle), Cos(angle))
		
		If parent And relative
			setz(parent.z)
			matrix = matrix.transform(parent.matrix)
			Local rotvec:tlVector2 = parent.matrix.transformvector(New tlVector2.Create(x, y))
			If z <> 1
				wx = parent.wx + rotvec.x * z
				wy = parent.wy + rotvec.y * z
			Else
				wx = parent.wx + rotvec.x
				wy = parent.wy + rotvec.y
			End If
		Else
			If parent setz(parent.z)
			wx = x
			wy = y
		End If
		
	End Method
	Rem
		bbdoc: Update all children of this entity.
	endrem
	Method UpdateChildren()
		For Local e:tlEntity = EachIn children
			e.update()
		Next
	End Method
	Rem
		bbdoc: Capture world coordinates, entity angle and scale for tweening.
		about: Tweening is used in applications that use fixed rate timing. This is where the logic routines of an application are updated a fixed
		amount of times each frame, but the drawing routines are updated as many times as possible. Each time the entity is updated during a logic
		update you can capture its coordinates, then, depending on how much time has passed since the last logic update, the entity can be interpolated
		between the old coordinates and the new ones creating a nice smooth movement no matter the PC you're running it on. To simplify things you
		can use the tweener.mod to implement fixed rate timing. See the tweener.mod for more info.
	endrem
	Method Capture()
		oldz = z
		oldwx = wx
		oldwy = wy
		oldx = x
		oldy = y
		oldangle = angle
		oldrelativeangle = relativeangle
		oldscalex = scalex
		oldscaley = scaley
		oldcurrentframe = currentframe
	End Method
	Rem
		bbdoc: Capture all including all children
	end rem
	Method CaptureAll()
		Capture()
		For Local e:tlEntity = EachIn getchildren()
			e.CaptureAll()
		Next
	End Method
	Rem
		bbdoc: Update the entities bounding box
		about: This will update the entities bounding box, and if the entity has no children it will update its parent bounding box if it has one.
	end rem
	Method UpdateBoundingBox()
	
		If z <> 1
			Collision_xmin = AABB_MinWidth * scalex * z
			Collision_ymin = AABB_MinHeight * scaley * z
			Collision_xmax = AABB_MaxWidth * scalex * z
			Collision_ymax = AABB_MaxHeight * scaley * z
		Else
			Collision_xmin = AABB_MinWidth * scalex
			Collision_ymin = AABB_MinHeight * scaley
			Collision_xmax = AABB_MaxWidth * scalex
			Collision_ymax = AABB_MaxHeight * scaley
		End If
	
		AABB_xmin = Collision_xmin
		AABB_ymin = Collision_ymin
		AABB_xmax = Collision_xmax
		AABB_ymax = Collision_ymax
		
		If Not childcount
			updateparentboundingbox()
		End If
	End Method
	Rem
		bbdoc: Update the entity's radius of influence
		about: The radius of influence is the area around the entity that could possibly be drawn to. This is used in the timelinefx editor where
		it's used to autofit the effect to the animation frame
	end rem
	Method UpdateEntityRadius()
		If autocenter
			If avatar
				If avatar.Max_Radius
					Image_Radius = Max(avatar.Max_Radius * scalex * z, avatar.Max_Radius * scaley * z)
				Else
					Image_Radius = GetDistance(avatar.width / 2 * scalex * z, avatar.height / 2 * scaley * z, avatar.width * scalex * z, avatar.height * scaley * z)
				End If
			Else
				Image_Radius = 0
			End If
		Else
			If avatar.Max_Radius
				Image_Radius = getdistance(handlex * scalex * z, handley * scaley * z, avatar.width / 2 * scalex * z, avatar.height / 2 * scaley * z) ..
				+ Max(avatar.Max_Radius * scalex * z, avatar.Max_Radius * scaley * z)
			Else
				Image_Radius = getdistance(handlex * scalex * z, handley * scaley * z, avatar.width * scalex * z, avatar.height * scaley * z)
			End If
		End If
		entity_radius = image_radius
		image_diameter = image_radius * 2
		If rootparent
			UpdateRootParentEntityRadius()
		End If
	End Method
	rem
		bbdoc: Update the entity's parent radius of influence
	end rem
	Method UpdateParentEntityRadius()
		If parent
			If childcount
				parent.entity_radius:+Max(0, getdistance(wx, wy, parent.wx, parent.wy) + entity_radius - parent.Entity_Radius)
			Else
				parent.entity_radius:+Max(0, getdistance(wx, wy, parent.wx, parent.wy) + image_radius - parent.Entity_Radius)
			End If
			DebugLog name + " - Radius: " + entity_Radius + " | Distance to Parent: " + getdistance(wx, wy, parent.wx, parent.wy)
			parent.UpdateParentEntityRadius()
		End If
	End Method
	rem
		bbdoc: Update the entity's parent radius of influence
	end rem
	Method UpdateRootParentEntityRadius()
		If rootparent
			If Alpha rootparent.entity_radius:+Max(0, getdistance(wx, wy, rootparent.wx, rootparent.wy) + image_radius - rootparent.Entity_Radius)
			'DebugLog name + " - Radius: " + entity_Radius + " | Distance to Parent: " + getdistance(wx, wy, rootparent.wx, rootparent.wy)
		End If
	End Method
	rem
		bbdoc: Update the entity's parent bounding box
	end rem
	Method UpdateParentBoundingBox()
		If parent
			parent.AABB_xmax:+Max(0, wx - parent.wx + AABB_xmax - parent.AABB_xmax)
			parent.AABB_ymax:+Max(0, wy - parent.wy + AABB_ymax - parent.AABB_ymax)
			parent.AABB_xmin:+Min(0, wx - parent.wx + AABB_xmin - parent.AABB_xmin)
			parent.AABB_ymin:+Min(0, wy - parent.wy + AABB_ymin - parent.AABB_ymin)
			parent.UpdateParentBoundingBox()
		End If
	End Method
	Rem
		bbdoc: Assign the root parent of the entity
		about: This assigns the root parent of the entity which will be the highest level in the entity hierarchy. This method is generally only used
		internally, when an entity is added as a child to another entity.
	end rem
	Method AssignRootParent(e:tlEntity)
		If parent
			parent.AssignRootParent(e)
		Else
			e.rootparent = Self
		End If
	End Method
	rem
		bbdoc: draw the bounding box for debugging
	end rem
	Method DrawBoundingBox()
		SetScale 1, 1
		SetRotation 0
		SetAlpha 0.1
		SetColor 0, 255, 0
		DrawRect wx + AABB_xmin, wy + AABB_ymin, AABB_xmax - AABB_xmin, AABB_ymax - AABB_ymin
	End Method
	Rem
		bbdoc: Draw the image boundary of the entity
	end rem
	Method DrawImageBoundary()
		SetScale 1, 1
		SetRotation 0
		SetAlpha 0.5
		SetColor 255, 0, 255
		DrawOval wx - image_radius, wy - image_radius, image_radius * 2, image_radius * 2
	End Method
	rem
		bbdoc: Draw the whole boundary of the entity including children
	end rem
	Method DrawEntityBoundary()
		SetScale 1, 1
		SetRotation 0
		SetAlpha 0.5
		SetColor 255, 0, 255
		DrawOval wx - entity_radius, wy - entity_radius, entity_radius * 2, entity_radius * 2
	End Method
	rem
		bbdoc: Change the level of zoom for the particle.
	endrem
	Method Zoom(v:Float)
		z:+v
		oldz = z
	End Method
	Rem
		bbdoc: Add a new child entity to the entity
		about: This will also automatically set the childs parent.
	endrem		
	Method AddChild(e:tlEntity)
		children.AddLast(e)
		e.parent = Self
		e.Radius_Calculate = radius_calculate
		e.AssignRootParent(e)
		childcount:+1
	End Method
	Rem
		bbdoc:Destroy the entity
		about:This will destroy the entity and all it's children, ensuring all references are removed. Best to call this
		when you're finished with the entity to avoid memory leaks.
	end rem
	Method Destroy()
		parent = Null
		avatar = Null
		rootparent = Null
		For Local e:tlEntity = EachIn children
			e.destroy()
		Next
		children.Clear()
		destroyed = True
	End Method
	Rem
		bbdoc: Remove a child entity from this entity's list of children
	endrem
	Method RemoveChild(e:tlEntity)
		children.Remove(e)
		e.parent = Null
		childcount:-1
	End Method
	Rem
		bbdoc: Clear all child entities from this list of children
		about: This completely destroys them so the garbage collector can free the memory
	endrem
	Method ClearChildren()
		For Local e:tlEntity = EachIn children
			e.Destroy()
		Next
		children.Clear()
		childcount = 0
	End Method
	Rem
		bbdoc: Recursively kills all child entities and any children within those too and so on.
		about: This sets all the children's dead field to true so that you can tidy them later on however you need. If you just want to 
		get rid of them completely use #clearchildren.
	endrem
	Method KillChildren()
		For Local e:tlEntity = EachIn children
			e.killchildren()
			e.dead = True
		Next
	End Method
	Rem
		bbdoc: Rotate the entity by the number of degrees you pass to it
	end rem
	Method Rotate(degrees:Float)
		angle:+degrees
	End Method
	Rem
		bbdoc: Move the entity by the amount x and y that you pass to it
	end rem
	Method Move(xamount:Float, yamount:Float)
		x:+xamount
		y:+yamount
	End Method
	Rem
		bbdoc: Get the red value in this tlEntity object.
	End Rem
	Method GetRed:Int()
		Return red
	End Method
	Rem
		bbdoc: Set the red value for this tlEntity object.
	End Rem
	Method SetRed(Value:Int)
		red = Value
	End Method
	Rem
		bbdoc: Get the green value in this tlEntity object.
	End Rem
	Method GetGreen:Int()
		Return green
	End Method
	Rem
		bbdoc: Set the green value for this tlEntity object.
	End Rem
	Method SetGreen(Value:Int)
		green = Value
	End Method
	Rem
		bbdoc: Get the blue value in this tlEntity object.
	End Rem
	Method GetBlue:Int()
		Return blue
	End Method
	Rem
		bbdoc: Set the blue value for this tlEntity object.
	End Rem
	Method SetBlue(Value:Int)
		blue = Value
	End Method
	Rem
		bbdoc: Set the colour for the tlEntity object.
	End Rem
	Method SetEntityColor(_red:Int, _green:Int, _blue:Int)
		red = _red
		green = _green
		blue = _blue
	End Method
	Rem
		bbdoc: Get the alpha value in this tlEntity object.
	End Rem
	Method GetEntityAlpha:Float()
		Return alpha
	End Method
	Rem
		bbdoc: Get the Image Radius value in this tlEntity object.
		about: The image radius is the area that the entity could possible be drawn to. This takes into account scale and more importantly, the handle
		of the image. Radius_Calculate needs to be set to true for this value to be kept updated.
	End Rem
	Method GetImageRadius:Float()
		Return Image_Radius
	End Method
	Rem
		bbdoc: Get the Entity Radius value in this tlEntity object.
		about: The entity radius is similar to the Image_Radius except that it also takes into account all the children of the entity as well.
		Radius_Calculate needs to be set to true for this value to be kept updated.
	End Rem
	Method GetEntityRadius:Float()
		Return Entity_Radius
	End Method
	Rem
		bbdoc: Set the alpha value for this tlEntity object.
	End Rem
	Method SetEntityAlpha(Value:Float)
		alpha = Value
	End Method
	Rem
		bbdoc: Set the current x coordinate of the entity
		about: This will be relative to the parent if relative is set to true
	endrem
	Method SetX(v:Float)
		x = v
	End Method
	Rem
		bbdoc: Set the current y coordinate of the entity
		about: This will be relative to the parent if relative is set to true
	endrem
	Method SetY(v:Float)
		y = v
	End Method
	Rem
		bbdoc: Set the current zoom level of the entity
	endrem
	Method SetZ(v:Float)
		z = v
	End Method
	Rem
		bbdoc: Get the current x coordinate of the entity
		about: This will be relative to the parent if relative is set to true
	endrem
	Method GetX:Float()
		Return x
	End Method
	Rem
		bbdoc: Get the current y coordinate of the entity
		about: This will be relative to the parent if relative is set to true
	endrem
	Method GetY:Float()
		Return y
	End Method
	Rem
		bbdoc: The the x and y position of the entity
		about: This will be relative to the parent if relative is set to true
	end rem
	Method SetPosition(_x:Float, _y:Float)
		x = _x
		y = _y
	End Method
	Rem
		bbdoc: Set the current world x coordinate of the entity
	endrem
	Method SetWX(v:Float)
		wx = v
	End Method
	Rem
		bbdoc: Set the current world y coordinate of the entity
	endrem
	Method SetWY(v:Float)
		wy = v
	End Method
	Rem
		bbdoc: Set to true to position the handle of the entity at the center
	endrem
	Method SetAutoCenter(v:Int)
		autocenter = v
	End Method
	Rem
		bbdoc: Set the current angle of rotation of the entity
	endrem
	Method SetAngle(v:Float)
		angle = v
	End Method
	Rem
		bbdoc: Set the current blendmode of the entity ie., ALPHABLEND/LIGHTBLEND
	endrem
	Method SetBlendMode(v:Int)
		blendmode = v
	End Method
	Rem
		bbdoc: Set the entities x handle
		about: This will not apply if autocenter is set to true
	endrem
	Method SetHandleX(v:Int)
		handlex = v
	End Method
	Rem
		bbdoc: Set the entities y handle
		about: This will not apply if autocenter is set to true
	endrem
	Method SetHandleY(v:Int)
		handley = v
	End Method
	Rem
		bbdoc: Set the name of the entity
	endrem
	Method SetName(v:String)
		name = v
	End Method
	Rem
		bbdoc: Set the parent of the entity
		about: Entities can have parents and children. Entities are drawn relative to their parents if the relative flag is set to true. 
		Using this command and #addchild you can create a hierarchy of entities. There's no need to call #addchild as well as #setparent
		because both commands will automatically set both accordingly
	end rem
	Method SetParent(e:tlEntity)
		e.addchild(Self)
	End Method
	Rem
		bbdoc: Sets whether this entity remains relative to it's parent
		about: Entities that are relative to their parent entity will position, rotate and scale with their parent.
	endrem
	Method SetRelative(v:Int)
		relative = v
	End Method
	Rem
		bbdoc: Sets the scale of the entity.
		about: This will set both the x and y scale of the entity based on the values you pass it.
	end rem
	Method SetEntityScale(sx:Float, sy:Float)
		scalex = sx
		scaley = sy
	End Method
	Rem
		bbdoc: Set the current speed of the entity
		abput: Sets the speed which is measured in pixels per second
	end rem
	Method SetSpeed(v:Float)
		speed = v
	End Method
	Rem
		bbdoc: Get the current speed of the entity
		abput: Gets the speed which is measured in pixels per second
	end rem
	Method GetSpeed:Float()
		Return speed
	End Method
	Rem
		bbdoc: Get the Radius Calculate value in this tlEntity object.
		about: see #SetRadiusCalculate for more info
	End Rem
	Method GetRadiusCalculate:Int()
		Return Radius_Calculate
	End Method
	Rem
		bbdoc: Set the Radius Calculate value for this tlEntity object.
		about: Radius is the radius of the entity where it could possible be drawn to. This includes all of it's children as well. 
		This will also propagate to all children, so it's best to set this to true before adding children to the entity, that way, the children will acquire
		the same value as the parent. By default this is false. 
	End Rem
	Method SetRadiusCalculate(Value:Int)
		Radius_Calculate = Value
		For Local e:tlEntity = EachIn children
			e.SetRadiusCalculate(Value)
		Next
	End Method
	Rem
		bbdoc: Get the framerate value in this tlEntity object.
		about: see #SetFrameRate for more info.
	End Rem
	Method GetFrameRate:Float()
		Return framerate
	End Method
	Rem
		bbdoc: Set the framerate value for this tlEntity object.
		about: the frame rate dicates how fast the entity animates if it has more then 1 frame
		of animation. The framerate is measured in frames per second.
	End Rem
	Method SetFrameRate(Value:Float)
		framerate = Value
	End Method
	Rem
		bbdoc: Returns true if the entity is animating 
	End Rem
	Method GetAnimating:Int()
		Return animating
	End Method
	Rem
		bbdoc: Set to true to make the entity animate
	End Rem
	Method SetAnimating(Value:Int)
		animating = Value
	End Method
	Rem
		bbdoc: Get the currentframe of the entity sprite animation
	End Rem
	Method GetCurrentFrame:Float()
		Return currentframe
	End Method
	Rem
		bbdoc: Set the currentframe of the entity sprite animation
	End Rem
	Method SetCurrentFrame(Value:Float)
		currentframe = Value
	End Method
	Rem
		bbdoc: Set the sprite (tAnimImage) that the entity uses when it draws to the screen
		about: tAnimImage is defined in singlesurface.mod, and is a type that draws animated images using a single surface for extra speed.
	End Rem
	Method SetSprite(sprite:TAnimImage)
		avatar = sprite
		AABB_MaxWidth = avatar.width *.5
		AABB_MaxHeight = avatar.height *.5
		AABB_MinWidth = avatar.width * -.5
		AABB_MinHeight = avatar.height * -.5
	End Method
	Rem
		bbdoc: Set to true to make the entity animate just once
		about: Once the entity as reached the end of the animation cycle it will stop animating.
	end rem
	Method SetAnimateOnce(v:Int)
		animateonce = v
	End Method
	Rem
		bbdoc: Set the UpdateSpeed value for this tlEntity object.
		about: Set to true or false, default is true. Setting to false will make the update method
		ignore any speed calculations. This is useful in situations where you want to extend tlEntity
		and calculate speed in your own way.
	End Rem
	Method SetUpdateSpeed(Value:Int)
		UpdateSpeed = Value
	End Method
	Rem
		bbdoc: Get the current angle of rotation
	endrem
	Method GetAngle:Float()
		Return angle
	End Method
	Rem
		bbdoc: Get the current entity handle x
	endrem
	Method GetHandleX:Int()
		Return handlex
	End Method
	Rem
		bbdoc: Get the current entity image handle y
	endrem
	Method GetHandleY:Int()
		Return handley
	End Method
	Rem
		bbdoc: Get the current blendmode
	endrem
	Method GetBlendMode:Int()
		Return blendmode
	End Method
	Rem
		bbdoc: Get whether this entity is relative to it's parent
	endrem
	Method GetRelative:Int()
		Return relative
	End Method
	Rem
		bbdoc: Get the name of the entity
	endrem
	Method GetName:String()
		Return name
	End Method
	Rem
		bbdoc: Gets the x and y scale of the entity.
	end rem
	Method GetEntityScale(sx:Float Var, sy:Float Var)
		 sx = scalex
		 sy = scaley
	End Method
	Rem
		bbdoc: Get the current sprite (tAnimImage) that the entity uses when it draws to the screen
	end rem
	Method GetSprite:TAnimImage()
		Return avatar
	End Method
	Rem
		bbdoc: Get the current parent of the entity
		about: Entities can have parents and children. Entities are drawn relative to their parents if the relative flag is true. 
		Using this command and #addchild you can create a hierarchy of entities.
	end rem
	Method GetParent:tlEntity()
		Return parent
	End Method
	Rem
		bbdoc: Get the children that this entity has
		about: This will return a list of children that the entity currently has
	end rem
	Method GetChildren:TList()
		Return children
	End Method
	Rem
		bbdoc: Get the lifetime value in this tlEntity object.
		about: See #SetLifeTime
	End Rem
	Method GetLifeTime:Int()
		Return lifetime
	End Method
	Rem
		bbdoc: Set the lifetime value for this tlEntity object.
		about: LifeTime represents the length of time that the entity should "Live" for. This allows entities to decay and expire in a given time.
		LifeTime is measured in milliseconds. See #SetAge and #Decay for adjusting the age of the entity.
	End Rem
	Method SetLifeTime(Value:Int)
		lifetime = Value
	End Method
	Rem
		bbdoc: Get the age value in this tlEntity object.
		about: See #SetAge and #Decay.
	End Rem
	Method GetAge:Float()
		Return age
	End Method
	Rem
		bbdoc: Set the age value for this tlEntity object.
		about: Setting the age of of the entity allows you to keep track of how old the entity so that something can happen after a given amount of time.
		See #Decay to increase the age by a given amount.
	End Rem
	Method SetAge(Value:Float)
		age = Value
	End Method
	Rem
		bbdoc: Increases the age value by a given amount
	End Rem
	Method Decay(MilliSeconds:Float)
		age:+MilliSeconds
	End Method
	Rem
		bbdoc: Get the wx value in this tlEntity object.
		about: WX represents the current x world coordinate of the entity. This may differ to x, which will contain the x coordinate relative 
		to the parent entity
	End Rem
	Method GetWX:Float()
		Return wx
	End Method
	Rem
		bbdoc: Get the wy value in this tlEntity object.
		about: WY represents the current Y world coordinate of the entity. This may differ to y, which will contain the Y coordinate relative 
		to the parent entity
	End Rem
	Method GetWY:Float()
		Return wy
	End Method
	Rem
		bbdoc: Get the direction value in this tlEntity object.
		about: Get the current direction the entity is travelling in
	End Rem
	Method GetEntityDirection:Float()
		Return direction
	End Method
	Rem
		bbdoc: Set the direction value for this tlEntity object.
		about: Set the current direction the entity is travelling in
	End Rem
	Method SetEntityDirection(Value:Float)
		direction = Value
	End Method
	Rem
		bbdoc: Get the oktorender value in this tlEntity object
		about: see #SetOKToRender
	End Rem
	Method GetOKToRender:Int()
		Return oktorender
	End Method
	Rem
		bbdoc: Set the oktorender value for this tlEntity object.
		about: Somethimes you might not always want entities to be rendered. When the render method is called, it will always render the children aswell,
		but if some of those children are effects which are rendered by a particle manager, then you don't want them rendered twice, so you can set this
		to false to avoid them being rendered.
	End Rem
	Method SetOKToRender(Value:Int)
		oktorender = Value
	End Method
	Rem
		bbdoc: Returns true if the axis aligned bounding box is being calculated for this entity
	End Rem
	Method HasBoundingBox:Int()
		If AABB_Calculate
			Return True
		End If
		Return False
	End Method
	Rem
		bbdoc: Set the AABB Include value for this tlEntity object.
	End Rem
	Method CalculateBoundingBox(Value:Int = True)
		AABB_Calculate = Value
	End Method
	'---------------------------------
	Rem
		bbdoc: Render the entity
		about: This will Draw the entity onto the screen using the tween value you pass to it to interpolate between old and new positions when
		using fixed rate timing.
	end rem
	Method Render(tween:Float)
		If avatar And oktorender
			If autocenter
				If avatar.frames = 1
					MidHandleImage(avatar.Image)
				Else
					SetImageHandle avatar.Image, avatar.width / 2, avatar.height / 2
				End If
			Else
				SetImageHandle avatar.image, handlex, handley
			End If
			SetBlend blendmode
			Local tv:Float = TweenValues(oldangle, angle, tween)
			SetRotation tv
			Local tx:Float = TweenValues(oldscalex, scalex, tween)
			Local ty:Float = TweenValues(oldscaley, scaley, tween)
			Local tz:Float = TweenValues(oldz, z, tween)
			If tz <> 1
				SetScale tx * tz, ty * tz
			Else
				SetScale tx * tz, ty * tz
			End If
			SetColor red, green, blue
			SetAlpha Alpha
			If animating
				tv = TweenValues(oldcurrentframe, currentframe, tween) Mod avatar.frames
				If tv < 0
					tv = avatar.frames - Abs(tv)
				End If
			Else
				tv = currentframe
			End If
			DrawSprite(avatar, TweenValues(oldwx, wx, tween), TweenValues(oldwy, wy, tween), tv Mod avatar.frames)
		End If
		For Local e:tlEntity = EachIn children
			e.render(tween)
		Next
	End Method
	Rem
		bbdoc: Interpolate between 2 values
		about: This is the function used to achieve render tweening by taking the old and new values and interpolating between the 2
	end rem
	Function TweenValues:Float(oldValue:Float, value:Float, tween:Float)
		Return oldValue + (value - oldValue) * tween
	End Function
End Type

Rem
	bbdoc: Create a new entity
end rem
Function CreateEntity:tlEntity()
	Return New tlEntity
End Function

