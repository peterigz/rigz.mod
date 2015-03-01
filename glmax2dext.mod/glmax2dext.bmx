
Strict

Rem
bbdoc: Extended Graphics/OpenGL Max2D
about:
The OpenGL Max2D module provides a few extra features for the standard glMax2d Driver
End Rem
Module rigz.glmax2dext

ModuleInfo "Version: 1"
ModuleInfo "Author: Peter Rigby"
ModuleInfo "License: MIT"
ModuleInfo "Copyright: RigzSoft"


Import rigz.max2dext
Import BRL.GLGraphics

Private

Global _driverext:TGLMax2DDriverEXT
Global color4ubext:Byte[4]

Global state_blendext

Public

Type TGLMax2DDriverEXT Extends TMax2DDriverEXT

	Field currentalpha:Float
	Field currentred:Int
	Field currentgreen:Int
	Field currentblue:Int

	Method Create:TGLMax2DDriverEXT()
		If Not GLGraphicsDriver() Return Null
		Return Self
	End Method

	Method SetBlend(blend)
		If blend = blend_mode Return
		blend_mode = blend
		Select blend
		Case MASKBLEND
			glDisable GL_BLEND
			glEnable GL_ALPHA_TEST
			glAlphaFunc GL_GEQUAL,.5
		Case SOLIDBLEND
			glDisable GL_BLEND
			glDisable GL_ALPHA_TEST
		Case ALPHABLEND
			glEnable GL_BLEND
			glBlendFunc GL_ONE, GL_ONE_MINUS_SRC_ALPHA
			glDisable GL_ALPHA_TEST
		Case LIGHTBLEND
			glEnable GL_BLEND
			glBlendFunc GL_ONE, GL_ONE
			glDisable GL_ALPHA_TEST
		Case SHADEBLEND
			glEnable GL_BLEND
			glBlendFunc GL_DST_COLOR, GL_ZERO
			glDisable GL_ALPHA_TEST
		Case SCREENBLEND
			glEnable GL_BLEND
			glBlendFunc GL_ONE, GL_ONE_MINUS_SRC_COLOR
			glDisable GL_ALPHA_TEST
		Default
			glDisable GL_BLEND
			glDisable GL_ALPHA_TEST
		End Select
	End Method

	Method SetAlpha(alpha:Float)
		If alpha > 1.0 alpha = 1.0
		If alpha < 0.0 alpha = 0.0
		color4ubext[0] = currentred * alpha
		color4ubext[1] = currentgreen * alpha
		color4ubext[2] = currentblue * alpha
		currentalpha = alpha
		color4ubext[3] = alpha * 255
		glColor4ubv color4ubext
	End Method
	
	Method SetColor(red, green, blue)
		currentred = red
		currentgreen = green
		currentblue = blue
		color4ubext[0] = Min(Max(red, 0), 255) * currentalpha
		color4ubext[1] = Min(Max(green, 0), 255) * currentalpha
		color4ubext[2] = Min(Max(blue, 0), 255) * currentalpha
		glColor4ubv color4ubext
	End Method

	Method SetClsColor(red, green, blue, alpha:Float = 1)
		red = Min(Max(red, 0), 255)
		green = Min(Max(green, 0), 255)
		blue = Min(Max(blue, 0), 255)
		If alpha > 1.0 alpha = 1.0
		If alpha < 0.0 alpha = 0.0
		glClearColor red / 255.0, green / 255.0, blue / 255.0, alpha
	End Method
	
	Method GrabPixmap:TPixmap(x, y, w, h)
		Local blend:Int = state_blendext
		DebugLog "EXT Grab"
		SetBlend SOLIDBLEND
		Local p:TPixmap=CreatePixmap( w,h,PF_RGBA8888 )
		glReadPixels x,GraphicsHeight()-h-y,w,h,GL_RGBA,GL_UNSIGNED_BYTE,p.pixels
		p=YFlipPixmap( p )
		SetBlendEXT blend
		Return p
	End Method
	
End Type

Rem
bbdoc: Get OpenGL Max2D EXT Driver
about:
The returned driver can be used with #SetGraphicsDriverEXT to enable OpenGL Max2D EXT commands.
End Rem
Function GLMax2DDriverEXT:TGLMax2DDriverEXT()
	Global _done
	If Not _done
		_driverext = New TGLMax2DDriverEXT.Create()
		_done=True
	EndIf
	Return _driverext
End Function
