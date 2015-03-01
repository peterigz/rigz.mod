' Copyright (c) 2010 Peter J Rigby
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.

rem
	bbdoc: HTML Tools module for building HTML documents
	about: This is a simple module for aiding in the creation of HTML documents. Note: requires BaH.LibXML.
end rem
Module rigz.htmltools

ModuleInfo "Version: 1.0"
ModuleInfo "License: MIT"
ModuleInfo "Copyright: 2010 Peter J Rigby"

ModuleInfo "History: v1.0 Initial Version"

Import bah.libxml
Import brl.textstream

rem
	bbdoc: Global #tDoctype storing the doctype for an XHTML Transitional HTML document
end rem
Global DXHTMLTransitional:tDoctype = tdoctype.Create("-//W3C//DTD XHTML 1.0 Transitional//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd", "html")
rem
	bbdoc: Global #tDoctype storing the doctype for an XHTML Strict HTML document
end rem
Global DXHTMLStrict:tdoctype = tdoctype.Create("-//W3C//DTD XHTML 1.0 Strict//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd", "html")

rem
	bbdoc: Global #tHTMLConstructor type for accessing preset HTML tags and constructors for #tHTMLTag
end rem
Global TAGS:tHTMLConstructor = New tHTMLConstructor

rem
	bbdoc: Type for storing HTML tags and #tHTMLTag constructors
	about: This type can be accessed through the global #Tags and provides a convienient way of constructing #tTags.
end rem
Type tHTMLConstructor
	Const TAG_HTML:String = "html"
	Const TAG_HEAD:String = "head"
	Const TAG_TITLE:String = "title"
	Const TAG_META:String = "meta"
	Const TAG_BODY:String = "body"
	Const TAG_DIV:String = "div"
	Const TAG_SPAN:String = "span"
	Const TAG_P:String = "p"
	Const TAG_H1:String = "h1"
	Const TAG_H2:String = "h2"
	Const TAG_H3:String = "h3"
	Const TAG_H4:String = "h4"
	Const TAG_H5:String = "h5"
	Const TAG_H6:String = "h6"
	Const TAG_STRONG:String = "strong"
	Const TAG_EM:String = "em"
	Const TAG_UL:String = "ul"
	Const TAG_LI:String = "li"
	Const TAG_TABLE:String = "table"
	Const TAG_TR:String = "tr"
	Const TAG_TD:String = "td"
	Const TAG_TH:String = "th"
	Const TAG_B:String = "b"
	Const TAG_I:String = "i"
	Const TAG_TT:String = "tt"
	Const TAG_SUB:String = "sub"
	Const TAG_SUP:String = "sup"
	Const TAG_BIG:String = "big"
	Const TAG_SMALL:String = "small"
	Const TAG_HR:String = "hr"
	Const TAG_IMG:String = "img"
	Const TAG_STYLE:String = "style"
	Const TAG_BR:String = "br"
	Const TAG_A:String = "a"
	
	rem
		bbdoc: Create and return the HTML tag: html
		returns: New tHTMLTag
	end rem
	Method HTML:tHTMLTag()
		Return tHTMLTag.Create(TAG_HTML, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: head
		returns: New tHTMLTag
	end rem
	Method HEAD:tHTMLTag()
		Return tHTMLTag.Create(TAG_HEAD, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: title
		returns: New tHTMLTag
	end rem
	Method TITLE:tHTMLTag()
		Return tHTMLTag.Create(TAG_TITLE, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: meta
		returns: New tHTMLTag
	end rem
	Method META:tHTMLTag()
		Return tHTMLTag.Create(TAG_META, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: body
		returns: New tHTMLTag
	end rem
	Method BODY:tHTMLTag()
		Return tHTMLTag.Create(TAG_BODY, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: div
		returns: New tHTMLTag
	end rem
	Method DIV:tHTMLTag()
		Return tHTMLTag.Create(TAG_DIV, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: span
		returns: New tHTMLTag
	end rem
	Method SPAN:tHTMLTag()
		Return tHTMLTag.Create(TAG_SPAN, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: p
		returns: New tHTMLTag
	end rem
	Method P:tHTMLTag()
		Return tHTMLTag.Create(TAG_P, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: h1
		returns: New tHTMLTag
	end rem
	Method H1:tHTMLTag()
		Return tHTMLTag.Create(TAG_H1, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: h2
		returns: New tHTMLTag
	end rem
	Method H2:tHTMLTag()
		Return tHTMLTag.Create(TAG_H2, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: h3
		returns: New tHTMLTag
	end rem
	Method H3:tHTMLTag()
		Return tHTMLTag.Create(TAG_H3, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: h4
		returns: New tHTMLTag
	end rem
	Method H4:tHTMLTag()
		Return tHTMLTag.Create(TAG_H4, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: h5
		returns: New tHTMLTag
	end rem
	Method H5:tHTMLTag()
		Return tHTMLTag.Create(TAG_H5, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: h6
		returns: New tHTMLTag
	end rem
	Method H6:tHTMLTag()
		Return tHTMLTag.Create(TAG_H6, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: strong
		returns: New tHTMLTag
	end rem
	Method STRONG:tHTMLTag()
		Return tHTMLTag.Create(TAG_STRONG, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: em
		returns: New tHTMLTag
	end rem
	Method EM:tHTMLTag()
		Return tHTMLTag.Create(TAG_EM, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: ul
		returns: New tHTMLTag
	end rem
	Method UL:tHTMLTag()
		Return tHTMLTag.Create(TAG_UL, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: li
		returns: New tHTMLTag
	end rem
	Method LI:tHTMLTag()
		Return tHTMLTag.Create(TAG_LI, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: table
		returns: New tHTMLTag
	end rem
	Method TABLE:tHTMLTag()
		Return tHTMLTag.Create(TAG_TABLE, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: tr
		returns: New tHTMLTag
	end rem
	Method TR:tHTMLTag()
		Return tHTMLTag.Create(TAG_TR, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: td
		returns: New tHTMLTag
	end rem
	Method TD:tHTMLTag()
		Return tHTMLTag.Create(TAG_TD, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: th
		returns: New tHTMLTag
	end rem
	Method TH:tHTMLTag()
		Return tHTMLTag.Create(TAG_TH, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: b
		returns: New tHTMLTag
	end rem
	Method B:tHTMLTag()
		Return tHTMLTag.Create(TAG_B, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: i
		returns: New tHTMLTag
	end rem
	Method I:tHTMLTag()
		Return tHTMLTag.Create(TAG_I, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: tt
		returns: New tHTMLTag
	end rem
	Method TT:tHTMLTag()
		Return tHTMLTag.Create(TAG_TT, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: sub
		returns: New tHTMLTag
	end rem
	Method SUB:tHTMLTag()
		Return tHTMLTag.Create(TAG_SUB, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: sup
		returns: New tHTMLTag
	end rem
	Method SUP:tHTMLTag()
		Return tHTMLTag.Create(TAG_SUP, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: big
		returns: New tHTMLTag
	end rem
	Method BIG:tHTMLTag()
		Return tHTMLTag.Create(TAG_BIG, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: small
		returns: New tHTMLTag
	end rem
	Method SMALL:tHTMLTag()
		Return tHTMLTag.Create(TAG_SMALL, True)
	End Method
	rem
		bbdoc: Create and return the HTML tag: hr
		returns: New tHTMLTag
	end rem
	Method HR:tHTMLTag()
		Return tHTMLTag.Create(TAG_HR, False)
	End Method
	rem
		bbdoc: Create and return the HTML tag: img
		returns: New tHTMLTag
	end rem
	Method IMG:tHTMLTag(src:String = "", alt:String = "")
		Local tag:tHTMLTag = New tHTMLTag.Create(tag_img, False)
		If src <> "" tag.AddProperty("src", src)
		If alt <> "" tag.AddProperty("alt", alt)
		Return tag
	End Method
	rem
		bbdoc: Create and return the HTML tag: a
		returns: New tHTMLTag
	end rem
	Method A:tHTMLTag(href:String = "", title:String = "")
		Local tag:tHTMLTag = tHTMLTag.Create(tag_a)
		If href <> "" tag.AddProperty("href", href)
		If title <> "" tag.AddProperty("title", title)
		Return tag
	End Method
	rem
		bbdoc: Create and return the HTML tag: style
		returns: New tHTMLTag
	end rem
	Method STYLE:tHTMLTag()
		Local tag:tHTMLTag = tHTMLTag.Create(TAG_STYLE, True)
		tag.AddProperty("type", "text/css")
		Return tag
	End Method
	rem
		bbdoc: Create and return the HTML tag: br
		returns: New tHTMLTag
	end rem
	Method BR:tHTMLTag()
		Local tag:tHTMLTag = tHTMLTag.Create(TAG_BR, False)
		tag.newline = False
		Return tag
	End Method
	rem
		bbdoc: Create and return a #tHTMLTag that is just plain text (no html tag)
		returns: New tHTMLTag
	end rem
	Method PlainText:tHTMLTag(text:String = "")
		Local tag:tHTMLTag = tHTMLTag.Create("", False, True)
		tag.text = text
		Return tag
	End Method
	
	rem
		bbdoc: See if a particular tag requires a new line when being formatted into a string
		Returns: True or False
		about: when tHTMLDoc.ToString() is used certain tags will be started on a new line to make easier to read HTML code. This method decides which tags
		start on a new line
	end rem
	Method NeedsNewLine:Int(tag:String)
		Select tag
			Case "br"
				Return False
			Default
				Return True
		End Select
	End Method
	
	rem
		bbdoc: Find out whether an HTML tag can contain other tags
		Returns: True or False
	end rem
	Method IsContainer:Int(tag:String)
		Select tag
			Case "br", "hr", "img", "text", "meta"
				Return False
			Default
				Return True
		End Select
	End Method
	
	rem
		bbdoc: Find out if a node name is plaintext
		returns: True or False
	end rem
	Method IsPlainText:Int(name:String)
		Select name
			Case "text"
				Return True
			Default
				Return False
		End Select
	End Method

End Type

rem
	bbdoc: tStyle type for storing CSS
	about: This type is used for storing CSS properties.
end rem
Type tStyle
	
	Field inline:Int = True
	Field name:String
	Field properties:TList = CreateList()
	
	rem
		bbdoc: Create new tStyle
		returns: New tStyle
		about: Pass the name of the style, for example "#content" and true or false as to whether the style is inline, ie., should appear inline with an HTML tag
	end rem
	Function Create:tStyle(name:String, inline:Int = True)
		Local style:tStyle = New tStyle
		style.name = name
		style.inline = inline
		Return style
	End Function
	
	rem
		bbdoc: Convert the tStyle to a string
		returns: Formatted string
	end rem
	Method ToString:String()
		If properties.Count()
			Local output:String
			If Not inline output = name + " {"
			For Local property:tStyleProperty = EachIn properties
				output:+property.ToString()
			Next
			If Not inline output:+"}"
			Return output
		Else
			Return ""
		End If
	End Method
	
	rem
		bbdoc: Add a new property to the style, or update an existing one
		about: Adds a style property, such as text-align, width, background-color etc., pass the name and the value. If the property already exists
			   then it is updated rather then a new one added.
	end rem
	Method AddProperty(name:String, value:String)
		If StyleExists(name)
			FindStyleProperty(name).SetValue(value)
		Else
			properties.AddLast(tStyleProperty.Create(name, value))
		End If
	End Method
	
	rem
		bbdoc: Update an existing style property.
		about: If the property is not found then nothing happens
	end rem
	Method UpdateProperty(name:String, value:String)
		If StyleExists(name)
			FindStyleProperty(name).SetValue(value)
		End If
	End Method
	
	rem
		bbdoc: Find out if a property exists
		Returns: True if the property exists, otherwise false
	end rem
	Method StyleExists:Int(name:String)
		For Local property:tStyleProperty = EachIn properties
			If property.name = name Return True
		Next
		Return False
	End Method
	
	rem
		bbdoc: Find a style property
		returns: The #tStyleProperty if found, otherwise null is returned
	end rem
	Method FindStyleProperty:tStyleProperty(name:String)
		For Local property:tStyleProperty = EachIn properties
			If property.name = name Return property
		Next
		Return Null
	End Method

End Type

rem
	bbdoc: Type for storing HTML properties/attributes
	about: An HTML property is for example, on an img tag, you could have the property src and alt.
end rem
Type tProperty
	
	Field name:String
	Field value:String
	
	rem
		bbdoc: Create a new tProperty
		returns: New tProperty
	end rem
	Function Create:tProperty(name:String, value:String)
		Local property:tProperty = New tProperty
		property.name = name
		property.value = value
		Return property
	End Function
	
	rem
		bbdoc: Convert the tProperty to a string
		returns: Formated string
	end rem
	Method ToString:String()
		Return name + "=" + Chr(34) + value + Chr(34)
	End Method
	
	rem
		bbdoc: Set the value of the property
	end rem
	Method SetValue(v:String)
		value = v
	End Method
	
	rem
		bbdoc: Get the value of the property
		returns: String containing the value
	end rem
	Method GetValue:String()
		Return value
	End Method

End Type

rem
	bbdoc: Type for storing Style properties
end rem
Type tStyleProperty Extends tProperty

	rem
		bbdoc: Create a new tStyleProperty
		returns: New tStyleProperty
	end rem
	Function Create:tStyleProperty(name:String, value:String)
		Local property:tStyleProperty = New tStyleProperty
		property.name = name
		property.value = value
		Return property
	End Function

	rem
		bbdoc: Convert the tStyleProperty to a string
		returns: Formatted string
	end rem
	Method ToString:String()
		Return name + ": " + value + ";"
	End Method

End Type

rem
	bbdoc: Type for storing Blocks of HTML
	about: this type provides the means to store HTML data, with each block being capable of containing child blocks to achieve a proper HTML document structure
end rem
Type tHTMLTag
	
	Field name:String
	Field style:tStyle = New tStyle
	Field properties:TList = CreateList()
	Field children:TList = CreateList()
	Field container:Int = True
	Field text:String
	Field plaintext:Int = False
	Field level:Int
	Field newline:Int = True
	
	rem
		bbdoc: Create a new tHTMLTag
		returns: New tHTMLTag
		about: Pass the name of the tag, whehter it can contain children, and specify if it should or shouldn't be plain text (no tag). For best results, use #tHTMLConstructors
		for an easier way to create html blocks.
	end rem
	Function Create:tHTMLTag(name:String, container:Int = True, plaintext:Int = False)
		Local htmlblock:tHTMLTag = New tHTMLTag
		htmlblock.name = name
		htmlblock.container = container
		htmlblock.plaintext = plaintext
		Return htmlblock
	End Function
	
	rem
		bbdoc: Convert the tHTMLTag into a string
		returns: Formatted string
	end rem
	Method ToString:String()
		Local output:String
		If Not plaintext
			If newline output:+Chr(10) + GetTabLevel()
			output:+GetOpenTag()
			For Local block:tHTMLTag = EachIn children
				output:+block.ToString()
			Next
			If container output:+Chr(10) + GetTabLevel() + GetClosingTag()
			Return output
		Else
			If newline output:+Chr(10)
			output:+GetTabLevel() + GetText().Replace(Chr(10), Chr(10) + GetTabLevel())
			Return output
		End If
	End Method
	
	rem
		bbdoc: Add a new property to the html block
		about: Adds a new property yo the type for example "src" would be a property of an image tag.
	end rem
	Method AddProperty(name:String, value:String)
		properties.AddLast(tProperty.Create(name, value))
	End Method
	
	rem
		bbdoc: Add an inline style to the html block
		about: Adds new style property to the html block, passing the name and the value. eg. style="float: right" where float would be the name and left the value.
	end rem
	Method AddStyle(name:String, value:String)
		style.AddProperty(name, value)
	End Method
	
	rem
		bbdoc: Add a child tHTMLTag
		about: This is essential if want to add nested html blocks.
	end rem
	Method AddChild(HTMLBlock:tHTMLTag)
		children.AddLast(HTMLBlock)
		HTMLBlock.UpdateLevel(level)
	End Method
	
	'-----Getters/Setters------
	
	rem
		bbdoc: Get the text of a plain text html block
		about: If an html block is plain text only, then you can use this to retrieve the text.
	end rem
	Method GetText:String()
		Return text
	End Method

	rem
		bbdoc: Set the text of a plain text html block
		about: If an html block is plain text only, then you can use this to set the text.
	end rem
	Method SetText(value:String)
		text = value
	End Method
	
	rem
		bbdoc: Append text to a plain text html block
		about: If an html block is plain text only, then you can use this to append some text.
	end rem
	Method AppendText(value:String)
		text:+value
	End Method
	
	rem
		bbdoc: Set the style of this html block
		about: the style will be applied inline to the HTML block
	end rem
	Method SetStyle(value:tStyle)
		style = value
	End Method
	
	rem
		bbdoc: Set the style of this html block
	end rem
	Method GetStyle:tStyle()
		Return style
	End Method
	
	rem
		bbdoc: Set the value of newline
		about: Set newline to false if you don't want this HTML tag to start on a new line when parsed into a string. By default newline is true
	end rem
	Method SetNewline(value:Int)
		newline = value
	End Method
	
	rem
		bbdoc: Get the value of newline
		about: If Newline is true then this HTML tag will start on a new line when parsed into a string. By default newline is true.
	end rem
	Method GetNewline(value:Int)
		newline = value
	End Method
	
	'Internal methods
	Method GetTabLevel:String()
		'this returns a number of horizontal tabs depending on the level of the tag
		Local tabs:String = ""
		For Local c:Int = 1 To level
			tabs:+Chr(9)
		Next
		Return tabs
	End Method
	Method GetOpenTag:String()
		Local output:String = "<" + name + " "
		If style.properties.Count()
			output:+"style=" + Chr(34) + style.ToString() + Chr(34)
			output:+" "
		End If
		output:+PropertiesToString()
		output = output.Trim()
		If container
			output:+">"
		Else
			output:+"/>"
		End If
		Return output
	End Method
	Method GetClosingTag:String()
		Return "</" + name + ">"
	End Method
	Method PropertiesToString:String()
		Local output:String
		For Local property:tProperty = EachIn properties
			output:+property.ToString() + " "
		Next
		Return output
	End Method
	Method UpdateLevel(rootlevel:Int)
		level = rootlevel + 1
		For Local child:tHTMLTag = EachIn children
			child.UpdateLevel(level)
		Next
	End Method
	
End Type

rem
	bbdoc: type for storing different doctypes for WW3 Doctypes
end rem
Type tDoctype
	Field systemid:String
	Field externalid:String
	Field name:String
	
	rem
		bbdoc: Create a new Doctype
		returns: a new tDoctype
	end rem
	Function Create:tDoctype(externalid:String, systemid:String, name:String)
		Local dtd:tDoctype = New tdoctype
		dtd.systemid = systemid
		dtd.externalid = externalid
		dtd.name = name
		Return dtd
	End Function
	
	rem
		bbdoc: convert this doctype into a string.
	end rem
	Method ToString:String()
		Local output:String = "<!DOCTYPE "
		output:+name + " PUBLIC "
		output:+Chr(34) + externalid + Chr(34) + " "
		output:+Chr(34) + systemid + Chr(34) + ">"
		Return output
	End Method
End Type

rem
	bbdoc: An html doc type 
	about: This type can be used to store an HTML document, specifying a doctype and containing the root html tag.
end rem
Type tHTMLDoc
	Field doctype:tDoctype
	Field html:tHTMLTag
	
	rem
		bbdoc: Create a new tHTMLDoc
		about: Pass the doctype, you can use the follwing consts for this: DOCTYPE_XHTML1_TRANSITIONAL, DOCTYPE_XHTML1_STRICT
	end rem
	Function Create:tHTMLDoc(doctype:tDoctype)
		Local htmldoc:tHTMLDoc = New tHTMLDoc
		htmldoc.doctype = doctype
		htmldoc.SetRootHTML(Tags.html())
		Return htmldoc
	End Function
	
	rem
		bbdoc: Convert the HTML document to a string
		returns: Formatted string.
		about: The string this returns can be loaded into an HTML viewer
	end rem
	Method ToString:String()
		Local output:String = doctype.ToString()
		output:+html.ToString()
		Return output
	End Method
	
	rem
		bbdoc: set the root html tag of the document
		about: this should be an "HTML" tag
	end rem
	Method SetRootHTML(htmlblock:tHTMLTag)
		html = htmlblock
	End Method
	
	rem
		bbdoc: Get the root html tag of the document
		returns: tHTMLTag
	end rem
	Method GetRootHTML:tHTMLTag()
		Return html
	End Method
	
	rem
		bbdoc: Add a child #tHTMLTag to the root html tag of this HTML doc
	end rem
	Method AddChild(block:tHTMLTag)
		html.AddChild(block)
	End Method
	
End Type

'Helper Functions

rem
	bbdoc: Create a new tHTMLDoc
	about: Pass the doctype, you can use the follwing consts for this: DXHTMLTransitional, DXHTMLStrict
end rem
Function CreateHTMLDoc:tHTMLDoc(doctype:tDoctype)
	Local htmldoc:tHTMLDoc = New tHTMLDoc
	htmldoc.doctype = doctype
	htmldoc.SetRootHTML(Tags.html())
	Return htmldoc
End Function
rem
	bbdoc: Create a new tHTMLTag
	returns: New tHTMLTag
	about: Pass the name of the tag, whehter it can contain children, and specify if it should or shouldn't be plain text (no tag). For best results, use #tHTMLConstructors
	for an easier way to create html blocks.
end rem
Function CreateHTMLBlock:tHTMLTag(name:String, container:Int = True, plaintext:Int = False)
	Local htmlblock:tHTMLTag = New tHTMLTag
	htmlblock.name = name
	htmlblock.container = container
	htmlblock.plaintext = plaintext
	Return htmlblock
End Function

rem
	bbdoc: Save a tHTMLDoc to a file
end rem
Function SaveHTMLDoc(url:String, htmldoc:tHTMLDoc)
	
	Local html:String = htmldoc.ToString()
	Local xml:TxmlDoc = TxmlDoc.parseDoc(PrepHTML(html))
	Local node:TxmlNode = xml.getRootElement()
	xml.saveFile(url)
	
	Function PrepHTML:String(html:String)
		html = html.Replace("&amp;", "&")
		html = html.Replace("&", "&amp;")
		Return html
	End Function

End Function

rem
	bbdoc: Load an HTML Document from a file
	Returns: #tHTMLDoc 
end rem
Function LoadHTMLDoc:tHTMLDoc(url:Object)
	
	
	Local xml:TxmlDoc = TxmlDoc.parseDoc(CleanHTML(LoadText(url)))
	If Not xml Return Null
	Local libnode:TxmlNode = xml.getRootElement()
	Local dtd:TxmlDtd = xml.getInternalSubset()
	
	Local doctype:tDoctype = tdoctype.Create(dtd.getExternalID(), dtd.getSystemID(), dtd.getName())
	Local htmldoc:tHTMLDoc = thtmldoc.Create(doctype)
	htmldoc.SetRootHTML(Tags.HTML())
	
	LoadBlock(libnode, htmldoc.GetRootHTML())
	
	Function LoadBlock:tHTMLTag(node:TxmlNode, lastblock:tHTMLTag)
		If node.getChildren(0)
			For Local child:TxmlNode = EachIn node.getChildren(0)
				Local block:tHTMLTag = tHTMLTag.Create(child.getName(), Tags.IsContainer(child.getName()), Tags.IsPlainText(child.getName()))
				block.SetNewline(Tags.NeedsNewLine(child.getName()))
				block.SetText(child.getContent().Trim())
				If block.GetText() <> "" And block.plaintext
					lastblock.AddChild(block)
				ElseIf Not block.plaintext
					lastblock.AddChild(block)
				End If
				If child.getAttributeList()
					For Local att:TxmlAttribute = EachIn child.getAttributeList()
						If att.getName() = "style"
							Local styles:String[] = att.getValue().Split(";")
							For Local style:String = EachIn styles
								If style <> ""
									Local split:String[] = style.Split(":")
									block.AddStyle(split[0].Trim(), split[1].Trim())
								End If
							Next
						Else
							block.AddProperty(att.getName(), att.getValue().Trim())
						End If
					Next
				End If
				LoadBlock(child, block)
			Next
		End If
	End Function
	
	Function CleanHTML:String(html:String)
		html = html.Replace("&amp;", "&")
		html = html.Replace("&", "&amp;")
		html = html.Replace(Chr(10), "")
		html = html.Replace(Chr(9), "")
		Return html
	End Function
	
	Return htmldoc
End Function