
Rem
	bbdoc: Create a new particle manager
	returns: A new tlParticleManager
	about: Particle manager maintains a list of effects. See #tlParticleManager.
endrem
Function CreateParticleManager:tlParticleManager(Particles:Int = tlPARTICLE_LIMIT, Layers:Int = 1)
	Local pm:tlParticleManager = New tlParticleManager.Create(particles, Layers)
	Return pm
End Function
Rem
	bbdoc: Create a new Emitter
	returns: a New tlEmitter with a default set of attribute values
endrem
Function CreateParticle:tlEmitter(parent:tlEffect)
	Local e:tlEmitter = New tlEmitter
	e.name = "New Particle"
	
	e.addamount 0, 1
	e.addlife 0, 1000
	e.addsizex 0, 200
	e.addsizey 0, 200
	e.addbasespeed 0, 0
	e.addbasespin 0, 0
	e.addbaseweight 0, 0
	
	e.addvelvariation 0, 0
	e.addlifevariation 0, 0
	e.addamountvariation 0, 0
	e.addsizexvariation 0, 0	
	e.addsizeyvariation 0, 0
	e.addspinvariation 0, 0
	e.adddirectionvariation 0, 0
	e.addweightvariation 0, 0
	
	e.addalpha 0, 1
	e.addr 0, 255
	e.addg 0, 255
	e.addb 0, 255
	e.addscalex 0, 1
	e.addscaley 0, 1
	e.addspin 0, 0
	e.addvelocity 0, 0
	e.addweight 0, 0
	e.adddirection 0, 0
	e.adddirectionvariationot 0, 0
	e.addframerate 0, 30
	e.addglobalvelocity 0, 1
	
	e.setuseeffectemission 1
	
	e.setblendmode(LIGHTBLEND)
	e.sethandlecenter(True)
	
	'e.image = ERROR_IMAGE
	
	e.parentEffect = parent
	
	Return e
	
End Function
Rem
	bbdoc: Create a new emitter
	Returns: Blank tlEmitter
endrem
Function CreateEmitter:tlEmitter()
	Local e:tlEmitter = New tlEmitter
	Return e
End Function
Rem
	bbdoc: Create a new effect
	returns: A new effect with a default set of attributes.
	about: Pass the parent emitter if it is to be a sub effect.
endrem
Function CreateEffect:tlEffect(parent:tlEmitter = Null)
	Local e:tlEffect = New tlEffect
	e.name = "New Effect"
	e.addamount 0, 1
	e.addlife 0, 1
	e.addsizex 0, 1
	e.addsizey 0, 1
	e.addvelocity 0, 1
	e.addspin 0, 1
	e.addalpha 0, 1
	e.addemissionangle 0, 0
	e.addemissionrange 0, 0
	e.addwidth 0, 1
	e.addheight 0, 1
	e.addweight 0, 1
	e.addangle 0, 0
	If parent
		e.setparentEmitter parent
	End If
	e.SetEllipseArc(360)
	e.sethandlecenter(True)
	Return e
End Function
Rem
	bbdoc: Copy a list of attribute nodes
	returns: A new list of attribute nodes
endrem
Function CopyAttributeNodes:TList(e:TList)
	Local ec:TList = CreateList()
	Local ectemp:tlAttributeNode
	For Local ecs:tlAttributeNode = EachIn e
		ectemp = New tlAttributeNode
		ectemp.frame = ecs.frame
		ectemp.value = ecs.value
		ectemp.isCurve = ecs.isCurve
		ectemp.c0x = ecs.c0x
		ectemp.c0y = ecs.c0y
		ectemp.c1x = ecs.c1x
		ectemp.c1y = ecs.c1y
		ec.AddLast ectemp
		ectemp = Null
	Next
	Return ec
End Function
Rem
	bbdoc: Makes a copy of the emitter passed to it
	returns: A new clone of the emitter
	about: Generally you will want to copy an effect, which will in turn copy all emitters within it recursively
endrem
Function CopyEmitter:tlEmitter(em:tlEmitter, ParticleManager:tlParticleManager)
	Local ec:tlEmitter = CreateEmitter()
	ec.dob = ParticleManager.CURRENT_TIME
	ec.alpha = CopyAttributeNodes(em.alpha)
	ec.r = CopyAttributeNodes(em.r)
	ec.g = CopyAttributeNodes(em.g)
	ec.b = CopyAttributeNodes(em.b)
	ec.scalex = CopyAttributeNodes(em.scalex)
	ec.scaley = CopyAttributeNodes(em.scaley)
	ec.sizex = CopyAttributeNodes(em.sizex)
	ec.sizey = CopyAttributeNodes(em.sizey)
	ec.sizexvariation = CopyAttributeNodes(em.sizexvariation)
	ec.sizeyvariation = CopyAttributeNodes(em.sizeyvariation)
	ec.spin = CopyAttributeNodes(em.spin)
	ec.basespin = CopyAttributeNodes(em.basespin)
	ec.velocity = CopyAttributeNodes(em.velocity)
	ec.basespeed = CopyAttributeNodes(em.basespeed)
	ec.baseweight = CopyAttributeNodes(em.baseweight)
	ec.life = CopyAttributeNodes(em.life)
	ec.lifevariation = CopyAttributeNodes(em.lifevariation)
	ec.velvariation = CopyAttributeNodes(em.velvariation)
	ec.weightvariation = CopyAttributeNodes(em.weightvariation)
	ec.weight = CopyAttributeNodes(em.weight)
	ec.spinvariation = CopyAttributeNodes(em.spinvariation)
	ec.amount = CopyAttributeNodes(em.amount)
	ec.amountvariation = CopyAttributeNodes(em.amountvariation)
	ec.emissionangle = CopyAttributeNodes(em.emissionangle)
	ec.emissionrange = CopyAttributeNodes(em.emissionrange)
	ec.splatter = CopyAttributeNodes(em.splatter)
	ec.globalvelocity = CopyAttributeNodes(em.globalvelocity)
	ec.direction = CopyAttributeNodes(em.direction)
	ec.directionvariation = CopyAttributeNodes(em.directionvariation)
	ec.directionvariationot = CopyAttributeNodes(em.directionvariationot)
	ec.framerate = CopyAttributeNodes(em.framerate)
	ec.stretch = CopyAttributeNodes(em.stretch)
	ec.setuseeffectemission em.useeffectemission
	ec.setimage em.image
	ec.setframe em.frame
	ec.setangletype em.angletype
	ec.setangleoffset em.angleoffset
	ec.setangle em.angle
	ec.setblendmode em.blendmode
	ec.setParticlesrelative em.particlesrelative
	ec.setuniform em.uniform
	ec.setlockangle em.lockedangle
	ec.setanglerelative em.anglerelative
	ec.sethandlex em.handlex
	ec.sethandley em.handley
	ec.setname em.name
	ec.setsingleparticle em.singleparticle
	ec.setvisible em.visible
	ec.setrandomcolor em.randomcolor
	ec.setzlayer em.zlayer
	ec.setanimate em.animate
	ec.setrandomstartframe em.randomstartframe
	ec.setanimationdirection em.animationdirection
	ec.setframe em.frame
	ec.setcolorrepeat em.colorrepeat
	ec.setalpharepeat em.alpharepeat
	ec.setoneshot em.oneshot
	ec.sethandlecenter em.handlecenter
	ec.setonce em.once
	ec.path = em.path
	ec.groupparticles = em.groupparticles
	ec.SetOKToRender(False)
	
	'Bypassers
	ec.bypass_weight = em.bypass_weight
	ec.bypass_speed = em.bypass_speed
	ec.bypass_spin = em.bypass_spin
	ec.bypass_directionvariation = em.bypass_directionvariation
	ec.bypass_colour = em.bypass_colour
	ec.b_red = em.b_red
	ec.b_green = em.b_green
	ec.b_blue = em.b_blue
	ec.bypass_scalex = em.bypass_scalex
	ec.bypass_scaley = em.bypass_scaley
	ec.bypass_framerate = em.bypass_framerate
	ec.bypass_stretch = em.bypass_stretch
	ec.bypass_splatter = em.bypass_splatter
	
	For Local e:tlEffect = EachIn em.effects
		ec.addeffect CopyEffect(e, ParticleManager)
	Next
	
	LinkEmitterArrays(em, ec)
	Return ec
End Function
Rem
	bbdoc: Makes a copy of the effect passed to it
	returns: A new clone of the effect entire, including all emitters and sub effects.
endrem
Function CopyEffect:tlEffect(e:tlEffect, ParticleManager:tlParticleManager, copydirectory:Int = False)
	Local eff:tlEffect = New tlEffect
	Local ec:tlEmitter
	eff.amount = CopyAttributeNodes(e.amount)
	eff.life = CopyAttributeNodes(e.life)
	eff.sizex = CopyAttributeNodes(e.sizex)
	eff.sizey = CopyAttributeNodes(e.sizey)
	eff.velocity = CopyAttributeNodes(e.velocity)
	eff.weight = CopyAttributeNodes(e.weight)
	eff.alpha = CopyAttributeNodes(e.alpha)
	eff.spin = CopyAttributeNodes(e.spin)
	eff.emissionangle = CopyAttributeNodes(e.emissionangle)
	eff.emissionrange = CopyAttributeNodes(e.emissionrange)
	eff.width = CopyAttributeNodes(e.width)
	eff.height = CopyAttributeNodes(e.height)
	eff.effectangle = CopyAttributeNodes(e.effectangle)
	eff.stretch = CopyAttributeNodes(e.stretch)
	eff.globalz = CopyAttributeNodes(e.globalz)
	eff.class = e.class
	eff.SetEllipseArc e.ellipsearc
	eff.lockaspect = e.lockaspect
	eff.setname e.name
	eff.setmgx e.mgx
	eff.setmgy e.mgy
	eff.setemitatpoints e.emitatpoints
	eff.setemissiontype e.emissiontype
	eff.setEffectlength e.effectlength
	eff.settraverseedge e.traverseedge
	eff.setendbehaviour e.endbehaviour
	eff.setreversespawn e.reversespawn
	eff.setdistancesetbylife e.distancesetbylife
	eff.sethandlecenter e.handlecenter
	eff.sethandlex e.handlex
	eff.sethandley e.handley
	eff.dob = ParticleManager.CURRENT_TIME
	eff.setspawndirection
	eff.assignParticleManager(ParticleManager)
	eff.path = e.path
	eff.SetOKToRender(False)
	
	If e.issuper
		eff.MakeSuper()
		For Local se:tlEffect = EachIn e.effects
			Local sec:tlEffect = CopyEffect(se, ParticleManager)
			eff.AddGroupedEffect(sec)
		Next
	Else
		For Local em:tlEmitter = EachIn e.children
			ec:tlEmitter = CopyEmitter(em, ParticleManager)
			ec.setparentEffect eff
			ec.parent = eff
			eff.addchild ec
		Next
	End If
	LinkEffectArrays(e, eff)
	If copydirectory
		If Not eff.directory eff.directory = CreateMap()
		eff.AddEffect(eff)
	End If
	Return eff
End Function
Rem
	bbdoc: Replace the effect properties, inlcuding emitters with the effect properties you pass to it
	about: You can use this to overwrite an effect with another effect.
endrem
Function UpdateEffect(eff:tlEffect, e:tlEffect)
	If eff And e
		Local index:Int
		eff.amount = CopyAttributeNodes(e.amount)
		eff.life = CopyAttributeNodes(e.life)
		eff.sizex = CopyAttributeNodes(e.sizex)
		eff.sizey = CopyAttributeNodes(e.sizey)
		eff.velocity = CopyAttributeNodes(e.velocity)
		eff.alpha = CopyAttributeNodes(e.alpha)
		eff.spin = CopyAttributeNodes(e.spin)
		eff.emissionangle = CopyAttributeNodes(e.emissionangle)
		eff.emissionrange = CopyAttributeNodes(e.emissionrange)
		eff.width = CopyAttributeNodes(e.width)
		eff.height = CopyAttributeNodes(e.height)
		eff.effectangle = CopyAttributeNodes(e.effectangle)
		eff.weight = CopyAttributeNodes(e.weight)
		eff.stretch = CopyAttributeNodes(e.stretch)
		eff.globalz = CopyAttributeNodes(e.globalz)
		eff.class = e.class
		eff.SetEllipseArc e.ellipsearc
		eff.setmgx e.mgx
		eff.setmgy e.mgy
		eff.setemitatpoints e.emitatpoints
		eff.setemissiontype e.emissiontype
		eff.setEffectlength e.effectlength
		eff.settraverseedge e.traverseedge
		eff.setendbehaviour e.endbehaviour
		eff.setreversespawn e.reversespawn
		eff.setdistancesetbylife e.distancesetbylife
		eff.sethandlecenter e.handlecenter
		eff.sethandlex e.handlex
		eff.sethandley e.handley
		eff.setlockaspect e.lockaspect
		eff.setspawndirection
		LinkEffectArrays(e, eff)
		Local ec:Object[] = eff.children.ToArray()
		For Local em:tlEmitter = EachIn e.children
			If tlEmitter(ec[index])
				tlEmitter(ec[index]).alpha = CopyAttributeNodes(em.alpha)
				tlEmitter(ec[index]).r = CopyAttributeNodes(em.r)
				tlEmitter(ec[index]).g = CopyAttributeNodes(em.g)
				tlEmitter(ec[index]).b = CopyAttributeNodes(em.b)
				tlEmitter(ec[index]).scalex = CopyAttributeNodes(em.scalex)
				tlEmitter(ec[index]).scaley = CopyAttributeNodes(em.scaley)
				tlEmitter(ec[index]).sizex = CopyAttributeNodes(em.sizex)
				tlEmitter(ec[index]).sizey = CopyAttributeNodes(em.sizey)
				tlEmitter(ec[index]).sizexvariation = CopyAttributeNodes(em.sizexvariation)
				tlEmitter(ec[index]).sizeyvariation = CopyAttributeNodes(em.sizeyvariation)
				tlEmitter(ec[index]).spin = CopyAttributeNodes(em.spin)
				tlEmitter(ec[index]).basespin = CopyAttributeNodes(em.basespin)
				tlEmitter(ec[index]).baseweight = CopyAttributeNodes(em.baseweight)
				tlEmitter(ec[index]).velocity = CopyAttributeNodes(em.velocity)
				tlEmitter(ec[index]).weight = CopyAttributeNodes(em.weight)
				tlEmitter(ec[index]).basespeed = CopyAttributeNodes(em.basespeed)
				tlEmitter(ec[index]).life = CopyAttributeNodes(em.life)
				tlEmitter(ec[index]).lifevariation = CopyAttributeNodes(em.lifevariation)
				tlEmitter(ec[index]).velvariation = CopyAttributeNodes(em.velvariation)
				tlEmitter(ec[index]).weightvariation = CopyAttributeNodes(em.weightvariation)
				tlEmitter(ec[index]).spinvariation = CopyAttributeNodes(em.spinvariation)
				tlEmitter(ec[index]).amount = CopyAttributeNodes(em.amount)
				tlEmitter(ec[index]).amountvariation = CopyAttributeNodes(em.amountvariation)
				tlEmitter(ec[index]).emissionangle = CopyAttributeNodes(em.emissionangle)
				tlEmitter(ec[index]).emissionrange = CopyAttributeNodes(em.emissionrange)
				tlEmitter(ec[index]).splatter = CopyAttributeNodes(em.splatter)
				tlEmitter(ec[index]).globalvelocity = CopyAttributeNodes(em.globalvelocity)
				tlEmitter(ec[index]).direction = CopyAttributeNodes(em.direction)
				tlEmitter(ec[index]).directionvariation = CopyAttributeNodes(em.directionvariation)
				tlEmitter(ec[index]).directionvariationot = CopyAttributeNodes(em.directionvariationot)
				tlEmitter(ec[index]).framerate = CopyAttributeNodes(em.framerate)
				tlEmitter(ec[index]).stretch = CopyAttributeNodes(em.stretch)
				tlEmitter(ec[index]).setuseeffectemission em.useeffectemission
				tlEmitter(ec[index]).setimage em.image
				tlEmitter(ec[index]).setframe em.frame
				tlEmitter(ec[index]).setangletype em.angletype
				tlEmitter(ec[index]).setangleoffset em.angleoffset
				tlEmitter(ec[index]).setangle em.angle
				tlEmitter(ec[index]).setblendmode em.blendmode
				tlEmitter(ec[index]).setParticlesrelative em.particlesrelative
				tlEmitter(ec[index]).setuniform em.uniform
				tlEmitter(ec[index]).setlockangle em.lockedangle
				tlEmitter(ec[index]).setanglerelative em.anglerelative
				tlEmitter(ec[index]).sethandlex em.handlex
				tlEmitter(ec[index]).sethandley em.handley
				tlEmitter(ec[index]).setvisible em.visible
				tlEmitter(ec[index]).setsingleparticle em.singleparticle
				tlEmitter(ec[index]).setrandomcolor em.randomcolor
				tlEmitter(ec[index]).setzlayer em.zlayer
				tlEmitter(ec[index]).setanimate em.animate
				tlEmitter(ec[index]).setrandomstartframe em.randomstartframe
				tlEmitter(ec[index]).setanimationdirection em.animationdirection
				tlEmitter(ec[index]).setframe em.frame
				tlEmitter(ec[index]).setcolorrepeat em.colorrepeat
				tlEmitter(ec[index]).setalpharepeat em.alpharepeat
				tlEmitter(ec[index]).setoneshot em.oneshot
				tlEmitter(ec[index]).sethandlecenter em.handlecenter
				tlEmitter(ec[index]).setonce em.once
				tlEmitter(ec[index]).setgroupparticles em.groupparticles
				
				'Bypassers
				tlEmitter(ec[index]).bypass_weight = em.bypass_weight
				tlEmitter(ec[index]).bypass_speed = em.bypass_speed
				tlEmitter(ec[index]).bypass_spin = em.bypass_spin
				tlEmitter(ec[index]).bypass_directionvariation = em.bypass_directionvariation
				tlEmitter(ec[index]).bypass_colour = em.bypass_colour
				tlEmitter(ec[index]).b_red = em.b_red
				tlEmitter(ec[index]).b_green = em.b_green
				tlEmitter(ec[index]).b_blue = em.b_blue
				tlEmitter(ec[index]).bypass_scalex = em.bypass_scalex
				tlEmitter(ec[index]).bypass_scaley = em.bypass_scaley
				tlEmitter(ec[index]).bypass_framerate = em.bypass_framerate
				tlEmitter(ec[index]).bypass_stretch = em.bypass_stretch
				tlEmitter(ec[index]).bypass_splatter = em.bypass_splatter
				
				LinkEmitterArrays(em, tlEmitter(ec[index]))
				index:+1
			End If
		Next
	End If
End Function
Rem
	bbdoc: Copy a particle
	returns: a tlParticle clone of the particle you pass to the function
endrem
Function CopyParticle:tlParticle(e:tlParticle)
	Local ce:tlParticle = New tlParticle
	ce.x = e.x
	ce.y = e.y
	ce.z = e.z
	ce.wx = e.wx
	ce.wy = e.wy
	ce.emitter = e.emitter
	ce.avatar = e.avatar
	ce.parent = e.parent
	ce.dob = e.dob
	ce.angle = e.angle
	ce.relativeangle = e.relativeangle
	ce.scalevariationx = e.scalevariationx
	ce.scalevariationy = e.scalevariationy
	ce.scalex = e.scalex
	ce.scaley = e.scaley
	ce.red = e.red
	ce.green = e.green
	ce.blue = e.blue
	ce.blendmode = e.blendmode
	ce.alpha = e.alpha
	ce.speed = e.speed
	ce.handlex = e.handlex
	ce.handley = e.handley
	ce.direction = e.direction
	ce.spinvariation = e.spinvariation
	ce.directionvariaion = e.directionvariaion
	ce.emissionangle = e.emissionangle
	ce.velvariation = e.velvariation
	ce.weightvariation = e.weightvariation
	ce.currentframe = e.currentframe
	ce.relative = e.relative
	Return ce
End Function
Rem
	bbdoc: Load an effects library
	returns: New tlEffectsLibrary
	about: <p>Pass the url of the library and pass TRUE or FALSE for compile if you want to compile all the effects or not.</p>
	<p>Effects can be retrieved from the library using #GetEffect</p>
endrem
Function LoadEffects:tlEffectsLibrary(filename:String, compile:Int = True)
	
	If filename = Null
		Return Null
	End If
	
	Local zip:ZipReader = New ZipReader
	
	zip.OpenZip(filename)
	Local xmlstream:TStream = zip.ExtractFile("DATA.XML")
	
	If Not xmlstream Throw "Error loading effects file!"
	
	Local xmlstring:String
	
	xmlstring = xmlstream.ReadString(xmlstream.Size())

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
						Local shapestream:TStream = zip.ExtractFile(StripDir(shape.getAttribute("URL")))
						Local Sprite:TAnimImage
						Local importoption:String = shape.getAttribute("IMPORT_OPTION")
						If Not importoption importoption = IMAGE_PASSTHROUGH
						Local radius:Float = shape.getAttribute("MAX_RADIUS").ToFloat()
						Local findradius:Int = True
						If radius
							findradius = False
						End If
						If shapestream
							Sprite = LoadSpriteEffect(shapestream, shape.getAttribute("WIDTH").ToFloat(), shape.getAttribute("HEIGHT").ToFloat(), shape.getAttribute("FRAMES").ToInt(), findradius, importoption)
						End If
						'						End If
						If sprite
							sprite.largeindex = shape.getAttribute("INDEX").toint()
							sprite.url = shape.getAttribute("URL")
							Sprite.name = StripDir(Sprite.url)
							If radius Sprite.Max_Radius = radius
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
				If compile
					effect.compile_all()
				End If
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

'Copy Functions for compiled effects
Rem
	bbdoc: Makes a copy of the effect passed to it
	returns: A new clone of the effect entire, including all emitters and sub effects.
	about: This copies an effect that uses lookup arrays instead of interpolating attributes in real time. This is a quicker copy funtion then the copy effect, but bear in 
	mind that this will not copy the attribute graph data so you won't be able to use iterpolation mode when updating the particles. See #SetUpdateMode.
endrem
Function CopyCompiledEffect:tlEffect(e:tlEffect, ParticleManager:tlParticleManager, copydirectory:Int = False)
	Local eff:tlEffect = New tlEffect
	Local ec:tlEmitter
	eff.effectangle = CopyAttributeNodes(e.effectangle)
	eff.class = e.class
	eff.SetEllipseArc e.ellipsearc
	eff.lockaspect = e.lockaspect
	eff.setname e.name
	eff.setmgx e.mgx
	eff.setmgy e.mgy
	eff.setemitatpoints e.emitatpoints
	eff.setemissiontype e.emissiontype
	eff.setEffectlength e.effectlength
	eff.settraverseedge e.traverseedge
	eff.setendbehaviour e.endbehaviour
	eff.setreversespawn e.reversespawn
	eff.setdistancesetbylife e.distancesetbylife
	eff.sethandlecenter e.handlecenter
	eff.sethandlex e.handlex
	eff.sethandley e.handley
	eff.dob = ParticleManager.CURRENT_TIME
	eff.setspawndirection
	eff.assignParticleManager(ParticleManager)
	eff.path = e.path
	eff.SetOKToRender(False)
	For Local em:tlEmitter = EachIn e.children
		ec:tlEmitter = CopyCompiledEmitter(em, ParticleManager)
		ec.setparentEffect eff
		ec.parent = eff
		eff.addchild ec
	Next
	LinkEffectArrays(e, eff)
	If copydirectory
		eff.AddEffect(eff)
	End If
	Return eff
End Function
Function CopyCompiledEmitter:tlEmitter(em:tlEmitter, ParticleManager:tlParticleManager)
	Local ec:tlEmitter = CreateEmitter()
	ec.dob = ParticleManager.CURRENT_TIME
	ec.setuseeffectemission em.useeffectemission
	ec.setimage em.image
	ec.setframe em.frame
	ec.setangletype em.angletype
	ec.setangleoffset em.angleoffset
	ec.setangle em.angle
	ec.setblendmode em.blendmode
	ec.setParticlesrelative em.particlesrelative
	ec.setuniform em.uniform
	ec.setlockangle em.lockedangle
	ec.setanglerelative em.anglerelative
	ec.sethandlex em.handlex
	ec.sethandley em.handley
	ec.setname em.name
	ec.setsingleparticle em.singleparticle
	ec.setvisible em.visible
	ec.setrandomcolor em.randomcolor
	ec.setzlayer em.zlayer
	ec.setanimate em.animate
	ec.setrandomstartframe em.randomstartframe
	ec.setanimationdirection em.animationdirection
	ec.setframe em.frame
	ec.setcolorrepeat em.colorrepeat
	ec.setalpharepeat em.alpharepeat
	ec.setoneshot em.oneshot
	ec.sethandlecenter em.handlecenter
	ec.setonce em.once
	ec.path = em.path
	ec.groupparticles = em.groupparticles
	ec.SetOKToRender(False)

	'Bypassers
	ec.bypass_weight = em.bypass_weight
	ec.bypass_speed = em.bypass_speed
	ec.bypass_spin = em.bypass_spin
	ec.bypass_directionvariation = em.bypass_directionvariation
	ec.bypass_colour = em.bypass_colour
	ec.b_red = em.b_red
	ec.b_green = em.b_green
	ec.b_blue = em.b_blue
	ec.bypass_scalex = em.bypass_scalex
	ec.bypass_scaley = em.bypass_scaley
	ec.bypass_framerate = em.bypass_framerate
	ec.bypass_stretch = em.bypass_stretch
	ec.bypass_splatter = em.bypass_splatter
	
	For Local e:tlEffect = EachIn em.effects
		ec.addeffect CopyCompiledEffect(e, ParticleManager)
	Next
	LinkEmitterArrays(em, ec)
	Return ec
End Function

'--Internal functions
Function GetSpriteInList:TAnimImage(l:TList, index:Int)
	If l
		For Local s:TAnimImage = EachIn l
			If s.largeindex = index
				Return s
			End If
		Next
	End If
	Return Null
End Function
Function GetAlternativeSprite:TAnimImage(l:TList, search:String)
	If l
		For Local s:TAnimImage = EachIn l
			If Upper(s.name) = Upper(search)
				Return s
			End If
		Next
	End If
	Return Null
End Function
Function ShapeExists:Int(l:TList, search:String)
	If l
		For Local s:TAnimImage = EachIn l
			If Upper(s.name) = Upper(search)
				Return True
			End If
		Next
	End If
	Return False
End Function
Function FindShape:TAnimImage(l:TList, search:String)
	If l
		For Local s:TAnimImage = EachIn l
			If Upper(s.name) = Upper(search)
				Return s
			End If
		Next
	End If
	Return Null
End Function
Function GetnextPowerof2:Int(v:Int)
	v:-1
	v = v | (v Shr 1)
	v = v | (v Shr 2)
	v = v | (v Shr 4)
	v = v | (v Shr 8)
	v = v | (v Shr 16)
	v:+1
	Return v
End Function
Function GetNextEchange:tlAttributeNode(e:tlAttributeNode, l:TList)
	Local found:Int
	For Local ec:tlAttributeNode = EachIn l
		If found
			Return ec
		End If
		If ec = e
			found = True
		End If
	Next
End Function
Function LinkEffectArrays(efrom:tlEffect, eto:tlEffect)
	eto.c_life = efrom.c_life
	eto.c_amount = efrom.c_amount
	eto.c_sizex = efrom.c_sizex
	eto.c_sizey = efrom.c_sizey
	eto.c_velocity = efrom.c_velocity
	eto.c_weight = efrom.c_weight
	eto.c_spin = efrom.c_spin
	eto.c_alpha = efrom.c_alpha
	eto.c_emissionangle = efrom.c_emissionangle
	eto.c_emissionrange = efrom.c_emissionrange
	eto.c_width = efrom.c_width
	eto.c_height = efrom.c_height
	eto.c_angle = efrom.c_angle
	eto.c_stretch = efrom.c_stretch
	eto.c_globalz = efrom.c_globalz
End Function
Function LinkEmitterArrays(efrom:tlEmitter, eto:tlEmitter)
	eto.c_life = efrom.c_life
	eto.c_lifevariation = efrom.c_lifevariation
	eto.c_amount = efrom.c_amount
	eto.c_sizex = efrom.c_sizex
	eto.c_sizey = efrom.c_sizey
	eto.c_basespeed = efrom.c_basespeed
	eto.c_baseweight = efrom.c_baseweight
	eto.c_basespin = efrom.c_basespin
	eto.c_emissionangle = efrom.c_emissionangle
	eto.c_emissionrange = efrom.c_emissionrange
	eto.c_splatter = efrom.c_splatter
	eto.c_velvariation = efrom.c_velvariation
	eto.c_weightvariation = efrom.c_weightvariation
	eto.c_amountvariation = efrom.c_amountvariation
	eto.c_sizexvariation = efrom.c_sizexvariation
	eto.c_sizeyvariation = efrom.c_sizeyvariation
	eto.c_spinvariation = efrom.c_spinvariation
	eto.c_directionvariation = efrom.c_directionvariation
	eto.c_alpha = efrom.c_alpha
	eto.c_scalex = efrom.c_scalex
	eto.c_scaley = efrom.c_scaley
	eto.c_spin = efrom.c_spin
	eto.c_velocity = efrom.c_velocity
	eto.c_weight = efrom.c_weight
	eto.c_direction = efrom.c_direction
	eto.c_directionvariationot = efrom.c_directionvariationot
	eto.c_framerate = efrom.c_framerate
	eto.c_stretch = efrom.c_stretch
	eto.c_globalvelocity = efrom.c_globalvelocity
	eto.c_r = efrom.c_r
	eto.c_g = efrom.c_g
	eto.c_b = efrom.c_b
End Function
Function loadeffectxmltree:tlEffect(effectschild:TxmlNode, sprites:TList, parent:tlEmitter = Null, folderpath:String = "")
	Local e:tlEffect = New tlEffect
	Local ec:tlAttributeNode
	e.class = effectschild.getAttribute("TYPE").ToInt()
	e.emitatpoints = effectschild.getAttribute("EMITATPOINTS").ToInt()
	e.mgx = effectschild.getAttribute("MAXGX").ToInt()
	e.mgy = effectschild.getAttribute("MAXGY").ToInt()
	e.emissiontype = effectschild.getAttribute("EMISSION_TYPE").ToInt()
	e.ellipsearc = effectschild.getAttribute("ELLIPSE_ARC").ToInt()
	e.effectlength = effectschild.getAttribute("EFFECT_LENGTH").ToInt()
	e.lockaspect = effectschild.getAttribute("UNIFORM").ToInt()
	e.name = effectschild.getAttribute("NAME")
	e.handlecenter = effectschild.getAttribute("HANDLE_CENTER").toint()
	e.handlex = effectschild.getAttribute("HANDLE_X").ToInt()
	e.handley = effectschild.getAttribute("HANDLE_Y").ToInt()
	e.traverseedge = effectschild.getAttribute("TRAVERSE_EDGE").ToInt()
	e.endbehaviour = effectschild.getAttribute("END_BEHAVIOUR").ToInt()
	e.distancesetbylife = effectschild.getAttribute("DISTANCE_SET_BY_LIFE").ToInt()
	e.reversespawn = effectschild.getAttribute("REVERSE_SPAWN_DIRECTION").ToInt()
	e.setparentemitter parent
	If e.parentEmitter
		e.path = e.parentEmitter.path + "/" + e.name
	Else
		e.path = folderpath + e.name
	End If
	Local effectchildren:TList = effectschild.getChildren()
	For Local effectchild:TxmlNode = EachIn effectchildren
		Select effectchild.getName()
			Case "ANIMATION_PROPERTIES"
				e.setframes(effectchild.getAttribute("FRAMES").ToInt())
				e.setanimwidth(effectchild.getAttribute("WIDTH").ToInt())
				e.setanimheight(effectchild.getAttribute("HEIGHT").ToInt())
				e.setanimx(effectchild.getAttribute("X").ToInt())
				e.setanimy(effectchild.getAttribute("Y").ToInt())
				e.setseed(effectchild.getAttribute("SEED").ToInt())
				e.setlooped(effectchild.getAttribute("LOOPED").ToInt())
				e.setzoom(effectchild.getAttribute("ZOOM").ToFloat())
				e.setframeoffset(effectchild.getAttribute("FRAME_OFFSET").ToInt())
			Case "AMOUNT"
				ec = e.addamount(effectchild.getAttribute("FRAME").ToFloat(), effectchild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = effectchild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "LIFE"
				ec = e.addlife(effectchild.getAttribute("FRAME").ToFloat(), effectchild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = effectchild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "SIZEX"
				ec = e.addsizex(effectchild.getAttribute("FRAME").ToFloat(), effectchild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = effectchild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "SIZEY"
				ec = e.addsizey(effectchild.getAttribute("FRAME").ToFloat(), effectchild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = effectchild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "VELOCITY"
				ec = e.addvelocity(effectchild.getAttribute("FRAME").ToFloat(), effectchild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = effectchild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "WEIGHT"
				ec = e.addweight(effectchild.getAttribute("FRAME").ToFloat(), effectchild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = effectchild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "SPIN"
				ec = e.addspin(effectchild.getAttribute("FRAME").ToFloat(), effectchild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = effectchild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "ALPHA"
				ec = e.addalpha(effectchild.getAttribute("FRAME").ToFloat(), effectchild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = effectchild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "EMISSIONANGLE"
				ec = e.addemissionangle(effectchild.getAttribute("FRAME").ToFloat(), effectchild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = effectchild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "EMISSIONRANGE"
				ec = e.addemissionrange(effectchild.getAttribute("FRAME").ToFloat(), effectchild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = effectchild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "AREA_WIDTH"
				ec = e.addwidth(effectchild.getAttribute("FRAME").ToFloat(), effectchild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = effectchild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "AREA_HEIGHT"
				ec = e.addheight(effectchild.getAttribute("FRAME").ToFloat(), effectchild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = effectchild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "ANGLE"
				ec = e.addangle(effectchild.getAttribute("FRAME").ToFloat(), effectchild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = effectchild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "STRETCH"
				ec = e.addstretch(effectchild.getAttribute("FRAME").ToFloat(), effectchild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = effectchild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
								attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
								attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
								attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "GLOBAL_ZOOM"
				ec = e.addglobalz(effectchild.getAttribute("FRAME").ToFloat(), effectchild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = effectchild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
								attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
								attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
								attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "PARTICLE"
				e.addchild(loademitterxmltree(effectchild, sprites, e))
		End Select
	Next
	If Not e.stretch.Count()
		e.addstretch 0, 1
	End If
	Return e
End Function
Function loadfolderxmltree(folderchild:TxmlNode, sprites:TList, effects:tlEffectsLibrary, compile:Int)
	Local effectschildren:TList = folderchild.getChildren()
	If effectschildren
		For Local effectchild:TxmlNode = EachIn effectschildren
			Select effectchild.getname()
				Case "EFFECT"
					Local e:tlEffect = loadeffectxmltree(effectchild, sprites, Null, folderchild.getAttribute("NAME") + "/")
					effects.addeffect(e)
					If compile e.compile_all()
					e.directory = CreateMap()
					e.AddEffect(e)
			End Select
		Next
	End If
End Function
Function loademitterxmltree:tlEmitter(effectchild:TxmlNode, sprites:TList, e:tlEffect)
	Local particlechildren:TList = effectchild.getChildren()
	Local p:tlEmitter = New tlEmitter
	Local ec:tlAttributeNode
	p.handlex = effectchild.getAttribute("HANDLE_X").ToInt()
	p.handley = effectchild.getAttribute("HANDLE_Y").ToInt()
	p.blendmode = effectchild.getAttribute("BLENDMODE").ToInt()
	p.particlesrelative = effectchild.getAttribute("RELATIVE").ToInt()
	p.randomcolor = effectchild.getAttribute("RANDOM_COLOR").ToInt()
	p.zlayer = effectchild.getAttribute("LAYER").ToInt()
	p.singleparticle = effectchild.getAttribute("SINGLE_PARTICLE").ToInt()
	p.name = effectchild.getAttribute("NAME")
	p.animate = effectchild.getAttribute("ANIMATE").ToInt()
	p.once = effectchild.getAttribute("ANIMATE_ONCE").ToInt()
	p.frame = effectchild.getAttribute("FRAME").ToInt()
	p.randomstartframe = effectchild.getAttribute("RANDOM_START_FRAME").ToInt()
	p.animationdirection = effectchild.getAttribute("ANIMATION_DIRECTION").ToInt()
	p.uniform = effectchild.getAttribute("UNIFORM").ToInt()
	p.angletype = effectchild.getAttribute("ANGLE_TYPE").ToInt()
	p.angleoffset = effectchild.getAttribute("ANGLE_OFFSET").ToInt()
	p.lockedangle = effectchild.getAttribute("LOCK_ANGLE").ToInt()
	p.anglerelative = effectchild.getAttribute("ANGLE_RELATIVE").ToInt()
	p.useeffectemission = effectchild.getAttribute("USE_EFFECT_EMISSION").ToInt()
	p.colorrepeat = effectchild.getAttribute("COLOR_REPEAT").ToInt()
	p.alpharepeat = effectchild.getAttribute("ALPHA_REPEAT").ToInt()
	p.oneshot = effectchild.getAttribute("ONE_SHOT").ToInt()
	p.handlecenter = effectchild.getAttribute("HANDLE_CENTERED").ToInt()
	p.groupparticles = effectchild.getAttribute("GROUP_PARTICLES").ToInt()
	If Not p.animationdirection
		p.animationdirection = 1
	End If
	p.parenteffect = e
	p.path = p.parentEffect.path + "/" + p.name
	For Local particlechild:TxmlNode = EachIn particlechildren
		Select particlechild.getName()
			Case "SHAPE_INDEX"
				p.image = GetSpriteInList(sprites, particlechild.getContent().ToInt())
				If p.image = Null Then p.image = Null
			Case "ANGLE_TYPE"
				p.angletype = particlechild.getAttribute("VALUE").ToInt()
			Case "ANGLE_OFFSET"
				p.angleoffset = particlechild.getAttribute("VALUE").ToInt()
			Case "LOCK_ANGLE"
				p.lockedangle = particlechild.getAttribute("VALUE").ToInt()
			Case "ANGLE_RELATIVE"
				p.anglerelative = particlechild.getAttribute("VALUE").ToInt()
			Case "USE_EFFECT_EMISSION"
				p.useeffectemission = particlechild.getAttribute("VALUE").ToInt()
			Case "COLOR_REPEAT"
				p.colorrepeat = particlechild.getAttribute("VALUE").ToInt()
			Case "ALPHA_REPEAT"
				p.alpharepeat = particlechild.getAttribute("VALUE").ToInt()
			Case "ONE_SHOT"
				p.oneshot = particlechild.getAttribute("VALUE").ToInt()
			Case "HANDLE_CENTERED"
				p.handlecenter = particlechild.getAttribute("VALUE").ToInt()
			Case "LIFE"
				ec = p.addlife(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "AMOUNT"
				ec = p.addamount(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "BASE_SPEED"
				ec = p.addbasespeed(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "BASE_WEIGHT"
				ec = p.addbaseweight(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "BASE_SIZE_X"
				ec = p.addsizex(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "BASE_SIZE_Y"
				ec = p.addsizey(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "BASE_SPIN"
				ec = p.addbasespin(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "SPLATTER"
				ec = p.addsplatter(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "LIFE_VARIATION"
				ec = p.addlifevariation(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "AMOUNT_VARIATION"
				ec = p.addamountvariation(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "VELOCITY_VARIATION"
				ec = p.addvelvariation(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "WEIGHT_VARIATION"
				ec = p.addweightvariation(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "SIZE_X_VARIATION"
				ec = p.addsizexvariation(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "SIZE_Y_VARIATION"
				ec = p.addsizeyvariation(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "SPIN_VARIATION"
				ec = p.addspinvariation(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "DIRECTION_VARIATION"
				ec = p.adddirectionvariation(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "ALPHA_OVERTIME"
				ec = p.addalpha(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "VELOCITY_OVERTIME"
				ec = p.addvelocity(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "WEIGHT_OVERTIME"
				ec = p.addweight(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "SCALE_X_OVERTIME"
				ec = p.addscalex(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "SCALE_Y_OVERTIME"
				ec = p.addscaley(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "SPIN_OVERTIME"
				ec = p.addspin(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "DIRECTION"
				ec = p.adddirection(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "DIRECTION_VARIATIONOT"
				ec = p.adddirectionvariationot(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "FRAMERATE_OVERTIME"
				ec = p.addframerate(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "STRETCH_OVERTIME"
				ec = p.addstretch(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
								attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
								attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
								attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "RED_OVERTIME"
				p.addr(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
			Case "GREEN_OVERTIME"
				p.addg(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
			Case "BLUE_OVERTIME"
				p.addb(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
			Case "GLOBAL_VELOCITY"
				ec = p.addglobalvelocity(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "EMISSION_ANGLE"
				ec = p.addemissionangle(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "EMISSION_RANGE"
				ec = p.addemissionrange(particlechild.getAttribute("FRAME").ToFloat(), particlechild.getAttribute("VALUE").ToFloat())
				Local attlist:TList = particlechild.getChildren()
				If attlist
					For Local attchild:TxmlNode = EachIn attlist
						Select attchild.getName()
							Case "CURVE"
								ec.SetCurvePoints(attchild.getAttribute("LEFT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("LEFT_CURVE_POINT_Y").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_X").ToFloat(),  ..
									attchild.getAttribute("RIGHT_CURVE_POINT_Y").ToFloat())
						End Select
					Next
				End If
			Case "EFFECT"
				p.addeffect(loadeffectxmltree(particlechild, sprites, p))
				
		End Select
	Next
	Return p
End Function
Function effectexists:Int(l:TList, Search:String)
	For Local e:tlEffect = EachIn l
		If Upper(e.name) = Upper(search) Return True
	Next
End Function
Function emitterexists:Int(l:TList, Search:String)
	For Local e:tlEmitter = EachIn l
		If Upper(e.name) = Upper(search) Return True
	Next
End Function
Function GetBezierValue:Float(lastec:tlAttributeNode, a:tlAttributeNode, t:Float, ymin:Float, ymax:Float)
	If lastec
		If a.isCurve
			If lastec.isCurve
				Local p0:tlPoint = New tlPoint.Create(lastec.frame, lastec.value)
				Local p1:tlPoint = New tlPoint.Create(lastec.c1x, lastec.c1y)
				Local p2:tlPoint = New tlPoint.Create(a.c0x, a.c0y)
				Local p3:tlPoint = New tlPoint.Create(a.frame, a.value)
				Local value:tlPoint = GetCubicBezier(p0, p1, p2, p3, t, ymin, ymax)
				Return value.y
			Else
				Local p0:tlPoint = New tlPoint.Create(lastec.frame, lastec.value)
				Local p1:tlPoint = New tlPoint.Create(a.c0x, a.c0y)
				Local p2:tlPoint = New tlPoint.Create(a.frame, a.value)
				Local value:tlPoint = GetQuadBezier(p0, p1, p2, t, ymin, ymax)
				Return value.y
			End If
		ElseIf lastec.isCurve
			Local p0:tlPoint = New tlPoint.Create(lastec.frame, lastec.value)
			Local p1:tlPoint = New tlPoint.Create(lastec.c1x, lastec.c1y)
			Local p2:tlPoint = New tlPoint.Create(a.frame, a.value)
			Local value:tlPoint = GetQuadBezier(p0, p1, p2, t, ymin, ymax)
			Return value.y
		Else
			Return 0
		End If
	Else
		Return 0
	End If
End Function