Function getdirection:Float(fromx:Float, fromy:Float, tox:Float, toy:Float)

	Return (ATan2(fromy - toy, fromx - tox) + 450) Mod 360
	
End Function
Function getdistance:Float(fromx:Float, fromy:Float, tox:Float, toy:Float, fast:Int = False)

	Local w:Float
	Local h:Float
	
	w=tox-fromx
	h=toy-fromy
	
	If fast
		Return w * w + h * h
	Else
		Return Sqr(w*w+h*h)
	End If
	
End Function
Function GetTexSize(w:Int, h:Int, frames:Int, powersof2:Int = True, texwidth:Int Var, texheight:Int Var, Cols:Int Var, rows:Int Var)

        Local area:Int=w*h*frames 
        texwidth=1 
        
        While area>texwidth^2 
        
                texwidth:*2 
        
        Wend 
        
        cols=texwidth/w 
                
        texheight=h 
        
		If texwidth Mod w
	        While area >= texheight * texwidth
	        
	                texheight:+h 
	                
	        Wend
		Else
	        While area > texheight * texwidth
	        
	                texheight:+h 
	                
	        Wend
		End If
        
        rows=texheight/h 

End Function 
