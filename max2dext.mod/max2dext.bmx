SuperStrict

Rem
bbdoc: Extended Max2D
about: <p>Max2D module provides a few extra features for the standard max2d, mainly the loading of images in PreMultipliedAlpha mode which enables 
		and additional blend mode - screen blend, plus making it a lot easier to grab a screen with the lpaha channel intact.</p>
		<p>In order to use this properly for your own use (this is mainly for use internally by timelinefx you need to follow a few rules:</p>
		<ol>
		<li>Use #SetGraphicsDriverEXT and set the driver to the specific max2d driver you're using, ie., GLMax2DDriverEXT(),D3D7Max2DDriverEXT() or
		D3D9Max2DDriverEXT()</li>
		<li>After setting that make sure you call InitEXTGraphics() to initialise the extended driver.</li>
		<li>For all images you load with #LoadImageEXT or #LoadAnimImageEXT with the PreMultiAlpha falg set to true, you need to use the following
		max2d state change commands instead of the normal ones: #SetBlendEXT, #SetColorEXT and #SetAlphaEXT.</li>
		<li>If you want to switch between SetBlend for a normal image (non-premultiplied alpha) and SetBlendEXT then you need to use #ResetBlendMode after
		calling #SetBlendEXT and ResetBlendModeEXT after using the normal SetBlend. This is only necessary when you switch bettwen the two, so if you used 
		#SetBlendEXT 10 times in a row you' only have to use ResetBlendMode after the 10th one befoer using the normal SetBlend command.</li>
		<li></li>
		</ol>
End Rem
Module rigz.max2dext

ModuleInfo "Version: 1"
ModuleInfo "Author: Peter Rigby"
ModuleInfo "License: MIT"
ModuleInfo "Copyright: RigzSoft"

Import brl.max2d
Import rigz.graphicsext

Private

Global _max2ddriverext:TMax2DDriverEXT

Public

Const SCREENBLEND:Int = 6

Type TMax2DDriverEXT Extends TGraphicsDriverEXT

	Field blend_mode:Int

	Method SetBlend(blend:Int) Abstract
	Method SetAlpha( alpha# ) Abstract
	Method SetColor(red:Int, green:Int, blue:Int) Abstract
	Method SetClsColor(red:Int, green:Int, blue:Int, alpha:Float = 1) Abstract
	Method GrabPixmap:TPixmap(x:Int, y:Int, w:Int, h:Int) Abstract

End Type

rem
	bbdoc: Reset the state_blend of the normal SetBlend command
	about: After using #SetBlendEXT, Max2d won't know whether it's blendmode is the same anymore, so use this to reset it and ensure it works properly
	next time you use it.
end	rem
Function ResetBlendMode()
	SetBlend 10
	SetBlend GetBlend()
End Function

rem
	bbdoc: Reset the state_blend of the #SetBlendEXT command
	about: After using #SetBlend, Max2dEXT won't know whether it's blendmode is the same anymore, so use this to reset it and ensure it works properly
	next time you use it.
end	rem
Function ResetBlendModeEXT()
	SetBlendEXT 10
	SetBlend GetBlendEXT()
End Function

Rem
bbdoc: Set current #Cls color plus the alpha level
about:
The @red, @green and @blue parameters should be in the range of 0 to 255. Alpha should be in the range 0 to 1.

The default cls color is black.
End Rem
Function SetClsColorEXT(red:Int, green:Int, blue:Int, alpha:Float = 1)
	Assert _max2ddriverext, "Make sure you SetGraphicsDriverEXT and InitEXTGraphics before calling these EXT functions!"
	_max2ddriverext.SetClsColor red, green, blue, alpha
End Function

Rem
bbdoc: Set current blend mode
about: 
SetBlend controls how pixels are combined with existing pixels in the back buffer when drawing
commands are used in BlitzMax.

@blend should be one of:

[ @{Blend mode} | @Effect
* MASKBLEND | Pixels are drawn only if their alpha component is greater than .5
* SOLIDBLEND | Pixels overwrite existing backbuffer pixels
* ALPHABLEND | Pixels are alpha blended with existing backbuffer pixels
* LIGHTBLEND | Pixel colors are added to backbuffer pixel colors, giving a 'lighting' effect
* SCREENBLEND | Blends the colours similar to the photoshop screen blend
* SHADEBLEND | Pixel colors are multiplied with backbuffer pixel colors, giving a 'shading' effect
]
End Rem
Function SetBlendEXT(blend:Int)
	Assert _max2ddriverext, "Make sure you SetGraphicsDriverEXT and InitEXTGraphics before calling these EXT functions!"
	_max2ddriverext.SetBlend blend
End Function

rem
	bbdoc: get the current Blend Mode of #SetBlendEXT
	returns: the current blendmode
end rem
Function GetBlendEXT:Int()
	Assert _max2ddriverext, "Make sure you SetGraphicsDriverEXT and InitEXTGraphics before calling these EXT functions!"
	Return _max2ddriverext.blend_mode
End Function

Rem
bbdoc: Set current color
about: Use this when working with images that have premultiplied alpha

The @red, @green and @blue parameters should be in the range of 0 to 255.
End Rem
Function SetColorEXT(red:Int, green:Int, blue:Int)
	Assert _max2ddriverext, "Make sure you SetGraphicsDriverEXT and InitEXTGraphics before calling these EXT functions!"
	_max2ddriverext.SetColor red, green, blue
End Function

Rem
bbdoc: Set current alpha level
about: Use this when working with images that have premultiplied alpha
@alpha should be in the range 0 to 1.

@alpha controls the transparancy level when the ALPHABLEND blend mode is in effect.
The range from 0.0 to 1.0 allows a range of transparancy from completely transparent 
to completely solid.
End Rem
Function SetAlphaEXT(alpha:Float)
	Assert _max2ddriverext, "Make sure you SetGraphicsDriverEXT and InitEXTGraphics before calling these EXT functions!"
	_max2ddriverext.SetAlpha alpha
End Function

Rem
bbdoc: Grab pixmap
end rem
Function GrabPixmapEXT:TPixmap(x:Int, y:Int, width:Int, height:Int)
	Return _max2ddriverext.GrabPixmap(x, y, width, height)
End Function

Rem
	bbdoc: Load an image
	returns: A new image object
	about: This will load an image and pre multiply all it's colour with the alpha channel if PreMultiAlpha is set to True
End Rem
Function LoadImageEXT:TImage(url:Object, flags:Int = -1, ChangeImage:TPixmap(pixmap:TPixmap))
	Local pixmap:TPixmap = TPixmap(url)
	If Not pixmap pixmap = LoadPixmap(url)
	If Not pixmap Return Null
	pixmap = ChangeImage(pixmap)
	Return LoadImage(pixmap, flags)
End Function

Rem
	bbdoc: Load a multi-frame image
	returns: An image object
	about: This will load an animation image and pre multiply all it's colour with the alpha channel PreMultiAlpha is set to true
End Rem
Function LoadAnimImageEXT:TImage(url:Object, cell_width:Int, cell_height:Int, first_cell:Int, cell_count:Int, flags:Int = -1, PreMultiAlpha:Int = False)
	Local pixmap:TPixmap=TPixmap(url)
	If Not pixmap pixmap = LoadPixmap(url)
	If Not pixmap Return Null
	If PreMultiAlpha pixmap = PreMultiplyAlpha(pixmap)
	Return LoadAnimImage(pixmap, cell_width, cell_height, first_cell, cell_count, flags)
End Function

rem
	bbdoc: Initialise the Extended Graphics Driver
	about: It's important that you run this before attemtping to use any of the EXT commands
end rem
Function InitEXTGraphics()
	_max2ddriverext = TMax2DDriverEXT(GetGraphicsDriverEXT())
End Function

Private
Function PreMultiplyAlpha:TPixmap(pixmap:TPixmap)
	
	Local pixmapcopy:TPixmap = CopyPixmap(pixmap)
	pixmapcopy.Convert(PF_RGBA8888)

	Local p:Byte Ptr
	For Local loc:Int = 0 Until pixmapcopy.capacity Step 4
		p = pixmapcopy.pixels + loc
		p[3] = (p[0] + p[1] + p[2]) / 3
		p[0] = 255 * Float(p[3]) / 255.0
		p[1] = p[0]
		p[2] = p[0]
	Next
	
	Return pixmapcopy

End Function
