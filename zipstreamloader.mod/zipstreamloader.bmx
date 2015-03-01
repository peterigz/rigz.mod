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
	bbdoc:	Zipstream based effects loader for TimelineFX
	about: This module provides an alternative way to load eff files using koriolis.zipstream module available from http://www.koriolis-fx.com/forum/index.php?topic=15.0. (Registration is no longer required)
			**This is an optional mod and you only really need to use it if you're loading effects files from incbin. It will not compile (with makemods) unless you have koriolis.zipstream
			so you can either make sure you download that, or simply delete this mod from your mods folder**
EndRem
Module rigz.zipstreamloader
ModuleInfo "Author: Peter J. Rigby"
ModuleInfo "Copyright: Peter J. Rigby 2009"
ModuleInfo "Purpose: To add rich particle effects to games and applications, quickly and easily"

ModuleInfo "History v1: 12th March 2010 - Initial version"

Import koriolis.zipstream
Import rigz.timelinefx

Rem
	bbdoc: Load an effects library using koriolis.zipstream
	returns: New tlEffectsLibrary
	about: <p>Pass the url of the library and pass TRUE or FALSE for compile if you want to compile all the effects or not.</p>
	<p>This is an alternative loader that has the added benefit of loading from incbin.</p>
	<p>Effects can be retrieved from the library using #GetEffect</p>
endrem
Function LoadEffects2:tlEffectsLibrary(filename:String, compile:Int = True)
	
	If filename = Null
		Return Null
	End If
			
	Local xmlstring:String
	
	xmlstring = LoadText(filename + "//DATA.XML")
	
	If Not xmlstring Throw "Error loading effects file!"

	Local x:TxmlDoc = TxmlDoc.parseDoc(xmlstring)
	
	If x = Null
		Notify "Not a valid effects library"
		Return Null
	End If
	
	Local libnode:TxmlNode = x.getRootElement()
	
	If libnode = Null Or libnode.getName() <> "EFFECTS"
		Notify "Not a valid effects file"
		Return Null
	End If
	
	Local effects:tlEffectsLibrary = New tlEffectsLibrary
	Local sprites:TList = CreateList()

	Local libchildren:TList = libnode.getChildren()
	Local ProblemLoadingShapes:Int
	For Local effectschild:TxmlNode = EachIn libchildren
		Select effectschild.getName()
			Case "SHAPES"
				Local shapeschildren:TList = effectschild.getChildren()
				If shapeschildren
					For Local shape:TxmlNode = EachIn shapeschildren
						Local shapestream:TStream = OpenStream(StripDir(shape.getAttribute("URL")))
						Local Sprite:TAnimImage
						'						If StripDir(shape.getAttribute("URL")).EndsWith(".tpa")
						'							sprite = loadTPA(shapestream)
						'						Else'

						Sprite = LoadSprite(filename + "//" + StripDir(shape.getAttribute("URL")), shape.getAttribute("WIDTH").ToFloat(), shape.getAttribute("HEIGHT").ToFloat(), shape.getAttribute("FRAMES").ToInt(), True)

						'						End If
						If sprite
							sprite.largeindex = shape.getAttribute("INDEX").toint()
							sprite.url = shape.getAttribute("URL")
							sprite.name = StripDir(sprite.url)
							sprites.AddLast sprite
						Else
							DebugLog "ERROR - Could not load " + StripDir(shape.getAttribute("URL"))
							ProblemLoadingShapes = True
						End If
					Next
				End If
		End Select
	Next
	If ProblemLoadingShapes
		Notify "Problems loading the shapes for the effects library, check debuglog"
		Return Null
	End If
	For Local effectschild:TxmlNode = EachIn libchildren
		Select effectschild.getName()
			Case "EFFECT"
				Local effect:tlEffect = loadeffectxmltree(effectschild, sprites)
				If compile effect.compile_all()
				effects.addeffect effect
				effect.directory = CreateMap()
				effect.AddEffect(effect)
			Case "FOLDER"
				loadfolderxmltree(effectschild, sprites, effects, compile)
		End Select
	Next
	effects.shapelist = sprites
	effects.name = filename
	
	Return effects
End Function