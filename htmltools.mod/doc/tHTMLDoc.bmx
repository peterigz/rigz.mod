Import rigz.htmltools

'Create an HTML document
Local htmldoc:tHTMLDoc = CreateHTMLDoc(DXHTMLStrict)

'Create some HTML Tags using Tags object to construct them more easily.
Local head:tHTMLTag = Tags.HEAD()
Local title:tHTMLTag = Tags.TITLE()
'Use addchild to create a structured HTML document
title.AddChild(Tags.PlainText("A Simple HTML Document"))
head.AddChild(title)
Local body:tHTMLTag = Tags.BODY()
Local div:tHTMLTag = Tags.DIV()
'You can also use AddStyle to add inline CSS to HTML Tags
div.AddStyle("text-align", "center")
div.AddStyle("font-family", "Arial, Verdana, Times New Roman")
Local p:tHTMLTag = Tags.P()
p.AddChild(Tags.PlainText("This is a very simple HTML document"))
div.AddChild(p)
body.AddChild(div)

htmldoc.AddChild(head)
htmldoc.AddChild(body)

Print htmldoc.ToString()