SuperStrict

Rem
	bbdoc: Single Surface mod 
	about: Most of the credit For this goes To indiepath from Blitzmax forums. I changed a few things And made it work with the DX9 Mod by Dstastny
	Its questionable how much faster this makes things, but it might make improvements on slower cards, and it doesn't seem to slow down faster ones so...
	This depends on DStastny's DX9 mod. If you don't have that and don't want to use it then rem out where marked below
end rem
Module rigz.singlesurface
ModuleInfo "Author: Tim Fisher (Indiepath) Modified by Peter Rigby"
ModuleInfo "Purpose: Single surface image drawing when using animated images"
ModuleInfo "Version: v1"

ModuleInfo "No longer uses DBS dx9 mod, now uses official BRL dx9 mod"
ModuleInfo "Added DX 9 compatibility using DStastny mod."
ModuleInfo "Added drawsprite and load sprite helper functions"
ModuleInfo "Now returns null if the given dimensions don't fit the animation being loaded"
ModuleInfo ""

Import brl.max2d
Import rigz.math

Rem
	bbdoc: Type for creating single surface animations
	about: This type replaces the usual drawimage with one that lets you draw animations using a single surface. 
	Its questionable how much faster this makes things, but it might make improvements on slower cards, and it 
	doesn't seem to slow down faster ones so. You can use the helper functions #LoadSprite and #DrawSprite to create
	and draw your images.
end rem
Type TAnimImage
	
	Field Image:TImage
	Field original:TPixmap		'for tfx editor
	Field importoption:String		'for tfx editor
	Field width:Int
	Field height:Int
	Field u0:Float[] 
	Field v0:Float[] 
	Field u1:Float[] 
	Field v1:Float[]
	Field sx:Float[]
	Field sy:Float[]
	Field url:String
	Field name:String
	Field frames:Int
	Field displayframe:Int
	Field smallindex:Int
	Field largeindex:Int
	Field selected:Int
	Field freshsave:Int = False
	Field Max_Radius:Float

	Function Load:TAnimImage(url:Object, cell_width:Float, cell_height:Float, start:Int, frames:Int, flags:Int = -1)
		Local t:TAnimImage = New TAnimImage
		Local tx:Float
		Local ty:Float
		Local x_Cells:Int
		t.u0 = New Float[frames] 
		t.v0 = New Float[frames]
		t.u1 = New Float[frames] 
		t.v1 = New Float[frames]
		t.sx = New Float[frames]
		t.sy = New Float[frames]
		If TStream(url)
			TStream(url).Seek(0)
		End If
		t.Image = LoadImage(url, flags)
		If t.image.width * t.image.height < cell_width * cell_height * frames Return Null
		t.frames = frames
		Local xDelta:Float = 1
		Local yDelta:Float = 1
		x_cells = t.Image.Width / cell_width
		If x_cells
			For Local f:Int = start To frames - 1
				tx = (f Mod x_cells * cell_width) * xdelta
				ty = (f / x_cells * cell_Height) * ydelta
				t.u0[f] = Float(tx) / Float(t.Image.Width) 
				t.v0[f] = Float(ty) / Float(t.Image.Height) 
				t.u1[f] = Float(tx + cell_width * xdelta) / Float(t.Image.Width) 
				t.v1[f] = Float(ty + cell_Height * ydelta) / Float(t.Image.Height)
				t.sx[f] = tx
				t.sy[f] = ty
			Next
			Return t
		Else
			Return Null
		End If
	End Function
	
	Method FindImageMax:Float()
		If image
			For Local frame:Int = 0 To frames - 1
				Local pixmap:TPixmap = LockImage(image)
				pixmap = PixmapWindow(pixmap, Int(u0[frame] * image.width), Int(v0[frame] * image.height), getwidth(), getheight())
				For Local x:Int = 0 To pixmap.width - 1
					For Local y:Int = 0 To pixmap.height - 1
						Local RGBA:Int = pixmap.ReadPixel(x, y)
						Local a:Int = (RGBA Shr 24) & $ff
						If a > 0
							max_radius = Max(max_radius, getdistance(Abs(width / 2), Abs(height / 2), x, y))
						End If
					Next
				Next
			Next
		End If
		Return max_radius
	End Method
	
	Function Pow2Size:Float(n:Int) 
		Local t:Int = 1
		While t < n
			t:*2
		Wend
		Return t
	End Function

	Function Free(t:TAnimImage)
		t.Image = Null
		t = Null
	End Function
	
	Method Draw(x:Float, y:Float, width:Float, height:Float, frame:Int = 0)
		DrawSubImageRect(Self.image, x, y, width, height, sx[frame], sy[frame], width, height, image.handle_x, image.handle_y)
	End Method
	
	Method nextframe() 
		displayframe:+1
		If displayframe > frames - 1
			displayframe = 0
		End If
	End Method
	Method previousframe() 
		displayframe:-1
		If displayframe < 0
			displayframe = frames - 1
		End If
	End Method
	
	Method getwidth:Int()
		Return width
	End Method
	Method getheight:Int()
		Return height
	End Method
End Type

Rem
	bbdoc: Load an image and store it as a tAnimImage
	about: <p>Very similar to BRL's loadanimimage except of course it returns a tAnimImage.</p>
	<p>Parametres:</p>
	<ul>
	<li><b>url: </b>The path or stream to your image.</li>
	<li><b>width: </b>The width of each frame of animation.</li>
	<li><b>height: </b>The height of each frame of animation.</li>
	<li><b>frames: </b>The number of frames of the aniamtion. If you're loading a single frame image then you can omit this</li>
	</ul>
end rem
Function LoadSprite:TAnimImage(url:Object, width:Float = 0, height:Float = 0, frames:Int = 1, FindRadius:Int = False)
	
	If width = 0
		Local i:TImage = LoadImage(url, FILTEREDIMAGE)
		width = i.width
		height = i.height
	End If
	Local s:TAnimImage = TAnimImage.Load(url, width, height, 0, frames)
	If s
		s.width = width
		s.height = height
		If String(url)
			s.url = url.ToString()
		End If
		If FindRadius s.FindImageMax()
		Return s
	Else
		Return Null
	End If
	
End Function
Rem
	bbdoc: Draw a tAnimImage to the screen
	about: <p>Very similar to BRL's DrawImage except of course it draws a tAnimImage.</p>
	<p>Parametres:</p>
	<ul>
	<li><b>sprite: </b>The tAnimImage that you want to draw</li>
	<li><b>x: </b>The horizontal location that you want to draw to.</li>
	<li><b>y: </b>The vertical location that you want to draw to.</li>
	<li><b>frame: </b>The frame of the animation that you want to draw. The frame index starts from 0.</li>
	</ul>
end rem
Function DrawSprite(sprite:TAnimImage, x:Float, y:Float, frame:Float = 0)
	sprite.Draw(x, y, sprite.width, sprite.height, Int(frame)) 
End Function

'internal functions

Const IMAGE_GREYSCALE:String = "GREYSCALE"
Const IMAGE_FULLCOLOUR:String = "FULLCOLOUR"
Const IMAGE_PASSTHROUGH:String = "PASSTHROUGH"

Function LoadSpriteEffect:TAnimImage(url:Object, width:Float = 0, height:Float = 0, frames:Int = 1, FindRadius:Int = False, Colour:String = IMAGE_GREYSCALE)
	
	If width = 0
		Local i:TImage = LoadImage(url, FILTEREDIMAGE)
		width = i.width
		height = i.height
	End If
	Local s:TAnimImage = LoadtAnimImage(url, width, height, 0, frames, Colour)
	If s
		s.width = width
		s.height = height
		If String(url)
			s.url = url.ToString()
		End If
		If FindRadius s.FindImageMax()
		Return s
	Else
		Return Null
	End If
	
	Function LoadtAnimImage:TAnimImage(url:Object, cell_width:Float, cell_height:Float, start:Int, frames:Int, Colour:String)
		Local t:TAnimImage = New TAnimImage
		Local tx:Float
		Local ty:Float
		Local x_Cells:Int
		t.importoption = colour
		t.u0 = New Float[frames] 
		t.v0 = New Float[frames]
		t.u1 = New Float[frames] 
		t.v1 = New Float[frames]
		t.sx = New Float[frames]
		t.sy = New Float[frames]
		If TStream(url)
			TStream(url).Seek(0)
		End If
		If TPixmap(url)
			t.original = TPixmap(url)
		Else
			t.original = LoadPixmap(url)
		End If
		Select Colour
			Case IMAGE_GREYSCALE
				t.Image = LoadImage(GreyScale(t.original))
			Case IMAGE_FULLCOLOUR
				t.Image = LoadImage(t.original)
			Default
				t.Image = LoadImage(t.original)
		End Select
		If t.image.width * t.image.height < cell_width * cell_height * frames Return Null
		t.frames = frames
		Local xDelta:Float = 1
		Local yDelta:Float = 1
		x_cells = t.Image.Width / cell_width
		If x_cells
			For Local f:Int = start To frames - 1
				tx = (f Mod x_cells * cell_width) * xdelta
				ty = (f / x_cells * cell_Height) * ydelta
				t.u0[f] = Float(tx) / Float(t.Image.Width) 
				t.v0[f] = Float(ty) / Float(t.Image.Height)
				t.u1[f] = Float(tx + cell_width * xdelta) / Float(t.Image.Width) 
				t.v1[f] = Float(ty + cell_Height * ydelta) / Float(t.Image.Height)
				t.sx[f] = tx
				t.sy[f] = ty
			Next
			Return t
		Else
			Return Null
		End If
	End Function
	
	Function GreyScale:TPixmap(pixmap:TPixmap)
		
		Local pixmapcopy:TPixmap = CopyPixmap(pixmap).Convert(PF_RGBA8888)
	
		Local p:Byte Ptr
		Local c:Int
		
		For Local loc:Int = 0 Until pixmapcopy.capacity Step 4
			p = pixmapcopy.pixels + loc
			c = Min((p[0] *.3) + (p[1] *.59) + (p[2] *.11), p[3])
			p[0] = 255
			p[1] = p[0]
			p[2] = p[0]
			p[3] = c
		Next
		
		Return pixmapcopy
	
	End Function
	
	Function FullColour:TPixmap(pixmap:TPixmap)
		
		Local pixmapcopy:TPixmap = CopyPixmap(pixmap).Convert(PF_RGBA8888)
	
		Local p:Byte Ptr
		For Local loc:Int = 0 Until pixmapcopy.capacity Step 4
			p = pixmapcopy.pixels + loc
			p[0] = p[0] * (Float(p[3]) / 255.0)
			p[1] = p[1] * (Float(p[3]) / 255.0)
			p[2] = p[2] * (Float(p[3]) / 255.0)
		Next
		
		Return pixmapcopy
	
	End Function
	
	Function PassThrough:TPixmap(pixmap:TPixmap)
		Return pixmap
	End Function
	
End Function
