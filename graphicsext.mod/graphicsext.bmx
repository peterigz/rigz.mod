SuperStrict

rem
	bbdoc: Base driver forextended Max2d Commands, used internally by rigz.max2dext
end rem
Module rigz.graphicsext

Private

Global _driverext:TGraphicsDriverEXT

Public

Type TGraphicsDriverEXT

	Method SetBlend(blend:Int) Abstract
	Method SetAlpha(alpha:Float) Abstract
	Method SetColor(red:Int, green:Int, blue:Int) Abstract
	Method SetClsColor(red:Int, green:Int, blue:Int, alpha:Float = 1) Abstract

End Type

Function SetGraphicsDriverEXT(driver:TGraphicsDriverEXT)
	If _driverext <> Driver
		_driverext = Driver
	End If
	If Not _driverext RuntimeError "Couldnt't set extended drivers"
End Function

Function GetGraphicsDriverEXT:TGraphicsDriverEXT()
	Return _driverext
End Function