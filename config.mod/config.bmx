'Copyright (c) 2010 Peter J Rigby
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

rem
	bbdoc: Simple config type using reflection
	about: You can use this module to create simple configuration files
end rem
Module rigz.config
ModuleInfo "Author: Peter J. Rigby"
ModuleInfo "Copyright: Peter J. Rigby 2010"
ModuleInfo "Purpose: Simple way of creating configuration files for saving basic settings"
ModuleInfo "Version: 1.0"

Import brl.map
Import brl.stream
Import brl.reflection

rem
	bbdoc: Configuration type for creating .cfg files
	about: You can use configuration files to store whatever settings you want. To use this type you must extend it and create your own type from it. Any fields you put
	into that type you create will become a setting that's saved in the configuration file. Simply use #LoadConfig and #SaveConfig to load and save those
	settings.
end rem
Type tlConfig Abstract
	
	Field map:TMap = CreateMap() {exclude}
	
	rem
		bbdoc: Load a config into the type
		about: This will take a configuration file and populate all the fields of the type with the settings found in the config file. Use #SaveConfig to save a configuration
		file
	end rem
	Method LoadConfig:Int(url:Object)
	
		Local configline:String
		Local linearray:String[]
		Local stream:TStream = OpenStream(url)
		
		map.Clear()
		If Not stream Return 0
		While Not stream.Eof()
			configline = ReadLine(stream)
			If configline
				linearray = configline.Split("=")
				If linearray.Length = 2
					map.Insert(linearray[0].Trim(), linearray[1].Trim())
				End If
			End If
		Wend
		
		populate()
		
		Return True
		
	End Method
	
	rem
		bbdoc: Save this type to a config file
		about: This will take all of the fields in this type and save them to a sonfig file. You can load them in again at anytime using #LoadConfig
	end rem
	Method SaveConfig(url:Object)
		
		Local stream:TStream = WriteStream(url)
		Local typeid:TTypeId = TTypeId.ForObject(Self)
		
		If stream
			For Local fld:TField = EachIn typeid.EnumFields()
				If Not fld.MetaData("exclude")
					stream.WriteLine(fld.Name() + "=" + fld.GetString(Self))
				End If
			Next
		End If
		
		stream.Close()
	
	End Method
	
	'internal use only--------------
	Method populate()
		'This method populates the fields of the type with the settings found in a configuration file
		Local typeid:TTypeId = TTypeId.ForObject(Self)
		
		For Local fld:TField = EachIn typeid.EnumFields()
			If map.Contains(fld.Name())
				fld.Set(Self, String(map.ValueForKey(fld.Name())))
			End If
		Next
	
	End Method

End Type