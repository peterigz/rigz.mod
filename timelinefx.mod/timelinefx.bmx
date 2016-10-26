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
	bbdoc:	TimelineFX for BlitzMax
	about:	<p>TimelineFX is a system for creating particle effects within your games and applications</p>
	<p>Big thanks to the following: Bruce Henderson (Brucey) for all the great modules, Garritt Grandberg (gman) for the zipengine module,
	 Manel Ibáñez (Ziggy) for a great IDE, Doug Stastny for the DX9 module and Mark Sibly of course for everything Blitz.</p>
	<p>For more help and tutorials that expand on the Docs below visit <a href="http://www.rigzsoft.co.uk" target="_blank">www.rigzsoft.co.uk</a></p>
EndRem
Module rigz.timelinefx
ModuleInfo "Author: Peter J. Rigby"
ModuleInfo "Copyright: Peter J. Rigby 2009-2010"
ModuleInfo "Purpose: To add rich particle effects to games and applications, quickly and easily"

ModuleInfo "History v1.18: 26 October 2016 - Added missing super effect code for loading effects"
ModuleInfo "History v1.17: 17 November 2015 - Fixed locked angle not taking into account anngle offset"
ModuleInfo "History v1.16: 17 March 2015 - Introduced super effects"
ModuleInfo "History v1.15: 30 October 2010 - Fixed a bug with interpolated mode and loading effects with compile flag set to false"
ModuleInfo "History v1.14: 07 October 2010 - Added new effect method, DoNotTimeout() which stops effects from timingout and destroying themselves"
ModuleInfo "History v1.14: 05 October 2010 - Added effects layers to particle manager to help with z-ordering, see tlParticleManager Docs for more info."
ModuleInfo "History v1.13: 20 June 2010 - Fixed a bug with stretch causing recycled particles to stretch way out of shaped on spawning"
ModuleInfo "History v1.13: 20 June 2010 - Added SetGlobalAmountScale to the particle manger, for controlling the amount of particles spawned."
ModuleInfo "History v1.12: 25 May 2010 - Parent effects should now properly play out their graphs right to the end."
ModuleInfo "History v1.12: 25 May 2010 - Particles that animate in reverse should now work properly"
ModuleInfo "History v1.11: 03 May 2010 - You can now change the way particles are drawn by grouping them by the emitter that spawns them. Use"
ModuleInfo "effect.SetGroupParticles(true) to achieve this. You won't notice any difference unless you're using  effects that have sub effects"
ModuleInfo "however."
ModuleInfo "History v1.11: 03 May 2010 - Fixed a bug where emitters that use the splatter graph are not effected by global zoom properly."
ModuleInfo "History v1.10: 04 April 2010 - Fixed an error on loading effects files with empty folders"
ModuleInfo "History v1.09: 29 March 2010 - Added a new attribute - Splatter"
ModuleInfo "History v1.09: 29 March 2010 - Fixed a memory leak when effects files are loaded over and over again"
ModuleInfo "History v1.09: 13th February 2010 - Particles will now only stretch along their relative velocities."
ModuleInfo "History v1.09: 26th Januray 2010 - Fixed a bug where the wrong frame would be drawn causing array out of bounds error"
ModuleInfo "History v1.08: 23rd November 2009 - Improved the way DrawParticles decides whether a particle is on screen to be drawn."
ModuleInfo "History v1.08: 19th November 2009 - The particle radius and bounding box are now initialised initialised properly when spawning."
ModuleInfo "History v1.07: 08th November 2009 - Tidied up the behaviour of adjusting the Z value of effects and implented globalz as a graph attribute"
ModuleInfo "History v1.07: 07th November 2009 - Particle manager now restores the GFX states (alpha, scale etc.) after drawing particles."
ModuleInfo "History v1.07: 29th October 2009 - Added Destroy method to tlParticleManager. Use to avoid memory leaks."
ModuleInfo "History v1.06: 20th September 2009 - Initial implementation of Z on effects (changes the overal scale of an effect)"
ModuleInfo "History v1.06: 4th August 2009 - Fixed a bug where clicking on the shape preview wouldn't set the handle to the correct place"
ModuleInfo "History v1.06: 4th August 2009 - Fixed a bug where locking the angle of a particle reversed the direction it was going in"
ModuleInfo "History v1.05: 18th August 2009 - Fixed a bug causing large angle changes to tween incorrectly"
ModuleInfo "History v1.05: 18th August 2009 - Added a Global Stretch attribute to tlEffects"
ModuleInfo "History v1.04: 15th August 2009 - Emitters that spawn particles with a random frame, now have the correct range of frames to choose from"
ModuleInfo "History v1.03: 8th August 2009 - Particle manager now sets oktorender to false for the particles it renders, see SetOKToRender in entity.mod"
ModuleInfo "History v1.03: 8th August 2009 - Added new method SetEffectParticleSize, which rolls SetSizeX and Y into one method"
ModuleInfo "History v1.02: 19th July 2009 - Single particles will now playout their graphs in a loop providing more oppertunities for animated sprites"
ModuleInfo "History v1.02: 18th July 2009 - When lockedangle is used, particles will now take into account gravity when aligning themselves"
ModuleInfo "History v1.02: 18th July 2009 - Fixed a bug where the speed of new particles being spawned was not the correct value"
ModuleInfo "History v1.02: 18th July 2009 - Fixed a bug where life variation was being halved"
ModuleInfo "History v1.02: 18th July 2009 - Added new attribute Stretch. Particles are stretched according to how fast they're travelling"
ModuleInfo "History v1.01: 16th July 2009 - Added new command to pre load effects to tlParticleManager - AddPreLoadedEffect()"
ModuleInfo "History v1.01: 14th July 2009 - Moved some globals from entity.mod to here because it made more sense. Created globals.bmx"
ModuleInfo "History v1.00: 28th March 2009 - First Release"

Import bah.libxml
Import brl.random
Import brl.map
Import gman.zipengine
Import rigz.entity
Import brl.pngloader
Import rigz.graphbeziers
Import rigz.math
Import "globals.bmx"
Include "functions.bmx"

?Debug
Global tlParticlesCreated:Int
?

Const tlPOINT_EFFECT:Int = 0
Const tlAREA_EFFECT:Int = 1
Const tlLINE_EFFECT:Int = 2
Const tlELLIPSE_EFFECT:Int = 3
Const tlCONTINUOUS:Int = 0
Const tlFINITE:Int = 1
Const tlANGLE_ALIGN:Int = 0
Const tlANGLE_RANDOM:Int = 1
Const tlANGLE_SPECIFY:Int = 2
Const tlEMISSION_INWARDS:Int = 0
Const tlEMISSION_OUTWARDS:Int = 1
Const tlEMISSION_SPECIFIED:Int = 2
Const tlEMISSION_IN_AND_OUT:Int = 3
Const tlEND_KILL:Int = 0
Const tlEND_LOOPAROUND:Int = 1
Const tlEND_LETFREE:Int = 2
Const tlAREA_EFFECT_TOP_EDGE:Int = 0
Const tlAREA_EFFECT_RIGHT_EDGE:Int = 1
Const tlAREA_EFFECT_BOTTOM_EDGE:Int = 2
Const tlAREA_EFFECT_LEFT_EDGE:Int = 3

Const tlGLOBAL_PERCENT_MIN:Float = 0
Const tlGLOBAL_PERCENT_MAX:Float = 20
Const tlGLOBAL_PERCENT_STEPS:Float = 100

Const tlGLOBAL_PERCENT_V_MIN:Float = 0
Const tlGLOBAL_PERCENT_V_MAX:Float = 10
Const tlGLOBAL_PERCENT_V_STEPS:Float = 200

Const tlANGLE_MIN:Float = 0
Const tlANGLE_MAX:Float = 1080
Const tlANGLE_STEPS:Float = 54

Const tlEMISSION_RANGE_MIN:Float = 0
Const tlEMISSION_RANGE_MAX:Float = 180
Const tlEMISSION_RANGE_STEPS:Float = 30

Const tlDIMENSIONS_MIN:Float = 0
Const tlDIMENSIONS_MAX:Float = 2000
Const tlDIMENSIONS_STEPS:Float = 40

Const tlLIFE_MIN:Float = 0
Const tlLIFE_MAX:Float = 100000
Const tlLIFE_STEPS:Float = 200

Const tlAMOUNT_MIN:Float = 0
Const tlAMOUNT_MAX:Float = 2000
Const tlAMOUNT_STEPS:Float = 100

Const tlVELOCITY_MIN:Float = 0
Const tlVELOCITY_MAX:Float = 10000
Const tlVELOCITY_STEPS:Float = 100

Const tlVELOCITY_OVERTIME_MIN:Float = -20
Const tlVELOCITY_OVERTIME_MAX:Float = 20
Const tlVELOCITY_OVERTIME_STEPS:Float = 200

Const tlWEIGHT_MIN:Float = -2500
Const tlWEIGHT_MAX:Float = 2500
Const tlWEIGHT_STEPS:Float = 200

Const tlWEIGHT_VARIATION_MIN:Float = 0
Const tlWEIGHT_VARIATION_MAX:Float = 2500
Const tlWEIGHT_VARIATION_STEPS:Float = 250

Const tlSPIN_MIN:Float = -2000
Const tlSPIN_MAX:Float = 2000
Const tlSPIN_STEPS:Float = 100

Const tlSPIN_VARIATION_MIN:Float = 0
Const tlSPIN_VARIATION_MAX:Float = 2000
Const tlSPIN_VARIATION_STEPS:Float = 100

Const tlSPIN_OVERTIME_MIN:Float = -20
Const tlSPIN_OVERTIME_MAX:Float = 20
Const tlSPIN_OVERTIME_STEPS:Float = 200

Const tlDIRECTION_OVERTIME_MIN:Float = 0
Const tlDIRECTION_OVERTIME_MAX:Float = 4320
Const tlDIRECTION_OVERTIME_STEPS:Float = 216

Const tlFRAMERATE_MIN:Float = 0
Const tlFRAMERATE_MAX:Float = 200
Const tlFRAMERATE_STEPS:Float = 100

Const tlMAX_DIRECTION_VARIATION:Float = 22.5
Const tlMAX_VELOCITY_VARIATION:Float = 30
Const tlMOTION_VARIATION_INTERVAL:Int = 30

Const tlPARTICLE_LIMIT:Int = 5000

Const tlUPDATE_MODE_COMPILED:Int = 0
Const tlUPDATE_MODE_INTERPOLATED:Int = 1

Rem
	bbdoc: Effects library for storing a list of effects and particle images/animations
	about: When using #LoadEffects, all the effects and images that go with them are stored in this type.
endrem
Type tlEffectsLibrary
	Field effects:TMap = CreateMap()
	Field name:String
	Field shapelist:TList = CreateList()
	
	Rem
	bbdoc: Create an effect library for storing your effects
	returns: A new tlEffectsLibrary
	endrem
	Method Create:tlEffectsLibrary()
		Return Self
	End Method
	Rem
	bbdoc: Add a new effect to the library including any sub effects and emitters. Effects are stored using a tMap and can be retrieved using #GetEffect.
	endrem
	Method AddEffect(e:tlEffect)
		effects.Insert(Upper(e.getpath()), e)
		For Local em:tlEmitter = EachIn e.children
			addemitter(em)
		Next
	End Method
	Rem
	bbdoc: Add a new emitter to the library. Emitters are stored using a map and can be retrieved using #GetEmitter. Generally you don't want to call this at all unless
	you're building your effects manually, just use #AddEffect and all its emitters will be added also.
	endrem
	Method AddEmitter(e:tlEmitter)
		effects.Insert(Upper(e.getpath()), e)
		For Local ef:tlEffect = EachIn e.effects
			addeffect(ef)
		Next
	End Method
	Rem
	bbdoc: Clear all effects in the library
	about: Use this to empty the library of all effects and shapes.
	endrem
	Method ClearAll()
		Self.name = ""
		effects.Values()
		For Local e:tlEffect = EachIn effects.Values()
			e.destroy()
		Next
		Self.effects.Clear()
		Self.effects = Null
		Self.shapelist.Clear()
		Self.shapelist = Null
	End Method
	Rem
	bbdoc: Retrieve an effect from the library
	returns: tlEffect
	about: <p>Use this to get an effect from the library by passing the name of the effect you want. Example:</p>
	&{local explosion:tlEffect=MyEffectsLibrary.Geteffect("explosion")}
	<p>All effects and emitters are stored using a directory like path structure so to get at sub effects you can do:</p>
	&{local explosion:tlEffect=MyEffectsLibrary.Geteffect("Effect/Emitter/Sub Effect/Another Emitter/A deeper sub effect")}
	<p>Note that you should always use forward slashes.</p>
	endrem
	Method GetEffect:tlEffect(name:String)
		Return tlEffect(effects.ValueForKey(Upper(name)))
	End Method
	Rem
	bbdoc: Retrieve an emitter from the library
	returns: tlEmitter
	about:<p> Use this To get an emitter from the library by passing the name of the emitter you want. All effects And emitters are
	stored using a map with a directory like path structure. So retrieving an emitter called blast wave inside an effect called explosion
	would be done like so:</p>
	&{local blastwave:tlemitter=MyEffectsLibrary.GetEmitter("explosion/blast wave")}
	<p>Note that you should always use forward slashes.</p>
	endrem
	Method GetEmitter:tlEmitter(name:String)
		Return tlEmitter(effects.ValueForKey(Upper(name)))
	End Method
End Type
Rem
	bbdoc: Effect type - extension of tlEntity
	about: <p>Effect types are the main containers for emitters and has a set of global attributes that can effect any emitters it stores.</p>
	<p>The basic entity structure of an effect is: Effect -> Emitter(s) -> Particle(s)</p>
	Both Effect types and Emitter types have a set of attributes that control how the Particles behave over the duration of the effect and over the duration of
	the particles lifetime. Most of the effects' attributes scale the equivalent attribute of the emitters to enable a more global control of the emitters 
	within the effect.</p>
	<p>The value of these attributes is then looked up over the course of the effect using methods that interpolate between values - the equivalent to looking them up on 
	a graph. There are 2 ways of doing this: either by interpolating in realtime, or by pre-compiling into lookup tables stored in arrays for faster performance.
	There is very little difference in accuracy between the two.</p>
	<p>To do this the tlemitterarray is used which stores the value of each attribute overtime for each frame. A frame can be whatever length of time in millisecs
	you set it to, eg. 30 millisecs. Because there are 2 types of attribute - base attributes and overtime - you can can change the resolution of each one separately. It's
	more necessary to have a higher resolution for overtime attributes as it becomes much more noticable. The default resolution for overtime attributes is 1 millisec - the 
	most precise resolution possible.
	<p>To adjust the resolution of the lookup tables you can call #SetLookupFrequency which affects the base attributes resolution and 
	#SetLookupFrequencyOvertime to adjust the overtime attributes.</p>
	<p>The following table shows each method used to either interpolate in realtime, or compile and lookup the values in an array plus the method used
	to actually add an attribute value. Click on the add methods for a more detailed description of what that attribute actually does.</p>
	<table>
	<tr><th>Interpolation Methods</th><th>Equivalent Compiler Methods</th><th>Lookup Table Methods</th><th>Add Methods</th></tr>
	<tr><td>interpolate_amount</td><td>compile_amount</td><td>get_life</td><td> #addlife</td></tr>
	<tr><td>interpolate_life</td><td>compile_life</td><td>get_amount</td><td> #addamount</td></tr>
	<tr><td>interpolate_sizex</td><td>compile_sizex</td><td>get_sizex</td><td> #addsizex</td></tr>
	<tr><td>interpolate_sizey</td><td>compile_sizey</td><td>get_sizey</td><td> #addsizey</td></tr>
	<tr><td>interpolate_velocity</td><td>compile_velocity</td><td>get_velocity</td><td> #addvelocity</td></tr>
	<tr><td>interpolate_weight</td><td>compile_weight</td><td>get_weight</td><td> #addweight</td></tr>
	<tr><td>interpolate_spin</td><td>compile_spin</td><td>get_spin</td><td> #addspin</td></tr>
	<tr><td>interpolate_alpha</td><td>compile_alpha</td><td>get_alpha</td><td> #addalpha</td></tr>
	<tr><td>interpolate_emissionangle</td><td>compile_emissionangle</td><td>get_emissionangle</td><td> #addemissionangle</td></tr>
	<tr><td>interpolate_emissionrange</td><td>compile_emissionrange</td><td>get_emissionrange</td><td> #addemissionrange</td></tr>
	<tr><td>interpolate_width</td><td>compile_width</td><td>get_width</td><td> #addwidth</td></tr>
	<tr><td>interpolate_height</td><td>compile_height</td><td>get_height</td><td> #addheight</td></tr>
	<tr><td>interpolate_angle</td><td>compile_angle</td><td>get_angle</td><td> #addangle</td></tr>
	</table>
	<p>Generally most of the values returned by these values are stored temporarily in the following variables for quicker access rather then having to
	look them up again that frame:</p>
	<table><tr><th>Variable name</th></tr>
	<tr><td>currentamount</td></tr>
	<tr><td>currentlife</td></tr>
	<tr><td>currentsizex</td></tr>
	<tr><td>currentsizey</td></tr>
	<tr><td>currentvelocity</td></tr>
	<tr><td>currentweight</td></tr>
	<tr><td>currentspin</td></tr>
	<tr><td>currentalpha</td></tr>
	<tr><td>currentemissionangle</td></tr>
	<tr><td>currentemissionrange</td></tr>
	<tr><td>currentwidth</td></tr>
	<tr><td>currentheight</td></tr>
	</table>
	<p>To precompile all attributes in the effect and any emitters and sub effects then you can call #compile_all</p>
endrem
Type tlEffect Extends tlEntity
	Field directory:TMap				'The directory of all the effect's sub effects and emitters.
	Field class:Int						'The type of effect - point, area, line or ellipse
	Field currentframe:Int				'the current frame, each frame lasts x amout of millisecs according to the global tp_UPDATE_FREQUENCY
	Field handlecenter:Int				'Whether the handle of the effect is automatically at the center
	Field path:String					'the path to the effect for where in the effect hierarchy the effect is
	'Field source:tlEntity
	Field complete:Int
	Field lockaspect:Int = True			'Set to true if the effect should scale uniformly
	Field tlParticlesCreated:Int		'Set to true if the effect's emitters have created any particles
	'Field SuspendTime:Int				
	Field gx:Float						'Grid x coords for emitting at points
	Field gy:Float						'Grid y coords for emitting at points
	Field mgx:Int						'The maximum value of gx
	Field mgy:Int						'The maximum value of gy
	Field emitatpoints:Int				'True to set the effect to emit at points
	Field emissiontype:Int				'Set to either inwards, outwards or specified according to emmision angle
	Field effectlength:Int				'How long the effect lasts before looping back round to the beginning
	Field parentEmitter:tlEmitter		'If the effect is a sub effect then this is set to the emitter that it's a sub effect of
	Field spawnage:Int					'length of time (millisecs) the effect has been spawing for
	Field index:Int
	Field particlecount:Int				'Number of particles this effect has active
	Field idletime:Int					'Length of time the effect has been idle for without any particles
	Field traverseedge:Int				'Whether the particles within this effect should traverse the edge of the line (lline effects only)
	Field endbehaviour:Int				'Set to whatever the particles should do when they reach the end of the line
	Field distancesetbylife:Int			'True if the distance travelled along the line is set accoding to the age of the particles traversing it
	Field reversespawn:Int				'True if the particles should spawn from right to left or anti clockwise (n/a for point effects)
	Field spawndirection:Int = 1		'set to 1 or -1 if reverse spawn is true or false
	Field dying:Int						'Set to true if the effect is in the process of dying, ie no long producing particles.
	Field allowspawning:Int = True		'Set to false to disable emitters from spawning any new particles
	Field ellipsearc:Float = 360		'With ellipse effects this sets the degrees of which particles emit around the edge
	Field ellipseoffset:Int				'This is the offset needed to make arc center at the top of the circle.
	Field inuse:TList[9]				'This stores particles created by the effect, for drawing purposes only.
	Field effectlayer:Int				'The layer that the effect resideson in its particle manager
	Field doesnottimeout:Int			'Whether the effect never timeouts automatically
	Field issuper:Int = False			'Super effects are used to group other effects together. they don't container emitters.
	Field effects:TList					'The list to contain the super effects list
	
	Field PM:tlParticleManager			'The particle manager that this effect belongs to
	
	'Animtion Properties
	Field frames:Int = 32				'Number number of frames the animation has
	Field animwidth:Int = 128			'Width of the animtion
	Field animheight:Int = 128			'Height of the animtion
	Field looped:Int					'True if the animation should loop
	Field animx:Int						'the x offset from the center of the animation
	Field animy:Int						'the y offset from the center of the animation
	Field seed:Int						'the number used for the random number generator
	Field zoom:Float = 1				'level of zoom of the animation
	Field frameoffset:Int				'Starting frame offset
	
	'----Global Settings, Graph attributes----
	Field life:TList = CreateList()
	Field amount:TList = CreateList()
	Field sizex:TList = CreateList()
	Field sizey:TList = CreateList()
	Field velocity:TList = CreateList()
	Field weight:TList = CreateList()
	Field spin:TList = CreateList()
	Field alpha:TList = CreateList()
	Field emissionangle:TList = CreateList()
	Field emissionrange:TList = CreateList()
	Field width:TList = CreateList()
	Field height:TList = CreateList()
	Field effectangle:TList = CreateList()
	Field stretch:TList = CreateList()
	Field globalz:TList = CreateList()
	
	'Compiled arrays of global settings
	Field c_life:tlEmitterArray
	Field c_amount:tlEmitterArray
	Field c_sizex:tlEmitterArray
	Field c_sizey:tlEmitterArray
	Field c_velocity:tlEmitterArray
	Field c_weight:tlEmitterArray
	Field c_spin:tlEmitterArray
	Field c_alpha:tlEmitterArray
	Field c_emissionangle:tlEmitterArray
	Field c_emissionrange:tlEmitterArray
	Field c_width:tlEmitterArray
	Field c_height:tlEmitterArray
	Field c_angle:tlEmitterArray
	Field c_stretch:tlEmitterArray
	Field c_globalz:tlEmitterArray
	
	Field currentlife:Float
	Field currentamount:Float
	Field currentsizex:Float
	Field currentsizey:Float
	Field currentvelocity:Float
	Field currentspin:Float
	Field currentweight:Float
	Field currentwidth:Float
	Field currentheight:Float
	Field currentalpha:Float
	Field currentemissionangle:Float
	Field currentemissionrange:Float
	Field currentstretch:Float
	Field currentglobalz:Float
	
	Field OverrideSize:Int
	Field OverrideEmissionAngle:Int
	Field OverrideEmissionRange:Int
	Field OverrideAngle:Int
	Field OverrideLife:Int
	Field OverrideAmount:Int
	Field OverrideVelocity:Int
	Field OverrideSpin:Int
	Field OverrideSizex:Int
	Field OverrideSizey:Int
	Field OverrideWeight:Int
	Field OverrideAlpha:Int
	Field OverrideStretch:Int
	Field OverrideGlobalz:Int
	
	Field bypass_weight:Int
	
	Method New()
		For Local l:Int = 0 To 8
			inuse[l] = CreateList()
		Next
	End Method
	
	Rem
	bbdoc: Sort all attribute lists
	about: Sorts all the graph nodes into the proper order for every effect attribute
	endrem
	Method sortall()
		SortList(life)
		SortList(amount)
		SortList(sizex)
		SortList(sizey)
		SortList(velocity)
		SortList(spin)
		SortList(alpha)
		SortList(emissionangle)
		SortList(emissionrange)
		SortList(width)
		SortList(height)
		SortList(effectangle)
		SortList(stretch)
		SortList(globalz)
	End Method
	Rem
	bbdoc: Show all Emitters
	about: Sets all emitters to visible so that they will be rendered. This also applies to any sub effects and their emitters.
	endrem
	Method showall()
		For Local e:tlEmitter = EachIn children
			e.showall()
		Next
	End Method
	Rem
	bbdoc: Hide all Emitters
	about: Sets all emitters to hidden so that they will no longer be rendered. This also applies to any sub effects and their emitters.
	endrem
	Method hideall()
		For Local e:tlEmitter = EachIn children
			e.hideall()
		Next
	End Method
	Rem
	bbdoc: Show one Emitter
	about: Sets the emitter passed to the method to visible so that it will be rendered, all the other emitters are made invisible.
	endrem
	Method showone(emm:tlEmitter)
		For Local e:tlEmitter = EachIn children
			e.setvisible False
		Next
		emm.setvisible True
	End Method
	Rem
	bbdoc: Get count of emitters within this effect
	returns: Number of emitters
	about: Use this to find out how many emitters the effect has
	endrem
	Method emittercount:Int()
		Return childcount
	End Method
	Rem
	bbdoc: Assign Particle Manager
	about: Sets the Particle Manager that this effect is managed by. See #tlParticleManager
	endrem
	Method assignParticleManager(partman:tlParticleManager)
		PM = partman
	End Method
	Rem
	bbdoc: Assigns a shape to each emitter
	about: <p>Recursively goes through each emitter within this effect and any sub effects and assigns a shape to each emitter.</p>
	<p>The list passed to the method should contain the list of shapes, which will then be searched using the name stored in emitter.image.name and assigned if one is found, 
	Otherwsie null is assign to the shape. Generally used only when the effects library is loaded.</p>
	endrem
	Method assignshapes(shapes:TList)
		For Local e:tlEmitter = EachIn children
			e.image = GetAlternativeSprite(shapes, e.image.name)
			For Local eff:tlEffect = EachIn e.children
				eff.assignshapes(shapes)
			Next
		Next
	End Method
	Rem
	bbdoc: Add an amount attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This scales the number of particles that are spawned per second for all particles within the effect.</p>
	endrem
	Method addamount:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		amount.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a life attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p> This scales each particle's lifetime attribute within the effect thus affecting how Long the particles last for. Note that this attribute only effects 
	the lifetime as they are spawned and will not extend or reduce the lifetime of particles already in existence.</P>
	endrem
	Method addlife:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		life.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a size x attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This scales each particle's width attribute within the effect thus controlling the overall width of the particle. </p>
	<p>If <i>lockaspect</i> is set to true then this attribute is used to control the particles height aswell so it scales uniformly</p>
	endrem
	Method addsizex:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		sizex.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a size y attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This scales each particle's height attribute within the effect thus controlling the overall height of the particle. </p>
	<p>if <i>lockaspect</i> is set to true then this attribute will not have any effect.</p>
	endrem
	Method addsizey:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		sizey.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a velocity attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This scales each particle's basespeed attribute within the effect thus controlling fast the particle can travel. 
	Note that this attribute only effects the base speed of the particle therefore only effecting newly spawned particles. 
	It does not effect the partciles over their lifetime.</p>
	endrem
	Method addvelocity:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		velocity.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a weight attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This scales each particle's baseweigth attribute within the effect thus controlling how much the particle is effected by gravity. 
	Note that this attribute only effects the base weight of the particle therefore only effecting newly spawned particles. 
	It does not effect the partciles over their lifetime.</p>
	endrem
	Method addweight:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		weight.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a spin attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>Global spin scales each particle's spin attribute within the effect thus controlling how fast the particle spins. 
	Note that this attribute will instantly effect all particles within the effect.</p>
	endrem
	Method addspin:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		spin.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add an alpha attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>Alpha effects the visibility of all particles within the effect. Global alpha is a scaling factor, so a value of 1 will not effect 
	any of the individual alpha values of particles. A global alpha value of 0.5 will half the value of all particle alpha values. 
	For example if global alpha is 0.5 and a particles alpha is 1 then the particles alpha wil be reduced to 0.5 (0.5*1=0.5). 
	Note that this attribute will instantly effect all particles within the effect.</p>
	endrem
	Method addalpha:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		alpha.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add an emission angle attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>Emission angle determines the direction particles will travel initially when they spawn.</p>
	endrem
	Method addemissionangle:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		emissionangle.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add an emission range attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This specifies the range of direction that particles will spawn and travel. Each degree on the graph represents both sides of 
	the emission angle. So for example if you set it to 10 degrees that means 10 degrees to the left and 10 degrees to the right of 
	the emission angle equally a total arc of 20 degrees. So setting an emission range of 180 degrees will mean particles travel 360 
	degrees randomly around the emission angle.</p>
	endrem
	Method addemissionrange:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		emissionrange.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a width attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>If the effect is of an area or ellipse type this controls the width. If the effect is a line then this controls the line length. 
	New particles that are created will only spawn within the area defined here.</p>
	endrem
	Method addwidth:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		width.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a height attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p><p>If the effect is of an area or ellipse type this controls the height. If the effect is a line then this control is not used. 
	New particles that are created will only spawn within the area defined here.</p>
	endrem
	Method addheight:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		height.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add an angle attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>Controls the angle of the effect over the life time of the effect. Particles that are set to Relative will rotate according to the effect, 
	otherwise they will only take into account the effect angle when they spawn.</p>
	endrem
	Method addangle:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		effectangle.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a stretch attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This will scale the stretch overtime attribute of all particles within the effect.</p>
	endrem
	Method addstretch:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		stretch.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a globalz attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This will affect the overal scale of the effect, effecticvely zooming into or out of the effect</p>
	endrem
	Method addglobalz:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		globalz.AddLast e
		Return e
	End Method
	
	Rem
		bbdoc: Capture world coordinates, entity angle and scale for tweening.
		about: Tweening is used in applications that use fixed rate timing. This is where the logic routines of an application are updated a fixed
		amount of times each frame, but the drawing routines are updated as many times as possible. Each time the entity is updated during a logic
		update you can capture its coordinates, then, depending on how much time has passed since the last logic update, the entity can be interpolated
		between the old coordinates and the new ones creating a nice smooth movement no matter the PC you're running it on. To simplify things you
		can use the tweener.mod to implement fixed rate timing. See the tweener.mod for more info.
	endrem
	Method Capture()
		If issuper
			For Local e:tlEffect = EachIn effects
				e.Capture
			Next
		Else
			oldz = z
			oldwx = wx
			oldwy = wy
			oldx = x
			oldy = y
			oldangle = angle
			oldrelativeangle = relativeangle
			oldscalex = scalex
			oldscaley = scaley
			oldcurrentframe = currentframe
		End If
	End Method
	Rem
	bbdoc: Set the x coordinates of the Effect
	about: <p>Sets the x coordinate of the effect. If the effect is a super effect, then set the coordinates of the sub effects it contains</p>
	endrem
	Method SetX(v:Float)
		If issuper
			For Local e:tlEffect = EachIn effects
				e.x = v
			Next
		End If
		x = v
	End Method
	Rem
	bbdoc: Set the x coordinates of the Effect
	about: <p>Sets the x coordinate of the effect. If the effect is a super effect, then set the coordinates of the sub effects it contains</p>
	endrem
	Method SetY(v:Float)
		If issuper
			For Local e:tlEffect = EachIn effects
				e.y = v
			Next
		End If
		y = v
	End Method
	Rem
	bbdoc: Set the class of the Effect
	about: <p>Sets the effect to one of 4 types - point, area, ellipse and line. To set one of these use one of the 4 corresponding consts: tlPOINT_EFFECT, 
	tlAREA_EFFECT, tlLINE_EFFECT, tlELLIPSE_EFFECT</p>
	endrem
	Method setclass(v:Int)
		class = v
	End Method
	Rem
	bbdoc: Sets lockaspect
	about: <p>Set to true to make the size of particles scale uniformly</p>
	endrem
	Method setlockaspect(v:Int)
		lockaspect = v
	End Method
	Rem
	bbdoc: Set Name
	about: Sets the name of the effect
	endrem
	Method setname(v:String)
		name = v
	End Method
	Rem
	bbdoc: Set maximum width grid points
	about: In area and ellipse effects this value represents the number of grid points along the width, in the case of area and line effect, or around the 
	circumference, in the case of ellipses.
	endrem
	Method setmgx(v:Int)
		mgx = v
	End Method
	Rem
	bbdoc: Set maximum height grid points
	about: In area effects this value represents the number of grid points along the height, it has no relevence for other effect types.
	endrem
	Method setmgy(v:Int)
		mgy = v
	End Method
	Rem
	bbdoc: Sets whether the effect should emit at points
	about: If set to true then the particles within the effect will emit from evenly spaced points with the area, line or ellipse. The number of points is determined
	by <i>mgx</i> and <i>mgy</i>. The value is not applicable to point effects.
	endrem
	Method setemitatpoints(v:Int)
		emitatpoints = v
	End Method
	Rem
	bbdoc: Set the emission type
	about: <p>In area, line and ellipse effects the emission type determines the direction that the particles travel once spawned. Use the following consts to determine
	the direction:</p>
	<p><b>tlEMISSION_INWARDS: </b>Particles will emit towards the handle of the effect.<br/>
	<b>tlEMISSION_OUTWARDS: </b>Particles will emit away from the handle of the effect.<br/>
	<b>tlEMISSION_SPECIFIED: </b>Particles will emit in the direction specified by the <i>emission_angle</i> and <i>emission_range</i> attributes.<br/>
	<b>tlEMISSION_IN_AND_OUT: </b>Particles will alternative between emitting towards and away from the handle of the effect.</p>
	endrem
	Method setemissiontype(v:Int)
		emissiontype = v
	End Method
	Rem
	bbdoc: Set the length of the effect
	about: Effects can be looped by setting the effect length. Just pass it the length in milliseconds that you want it to loop by or set to 0 if 
	you don't want the effect to loop.
	endrem
	Method setEffectlength(v:Int)
		effectlength = v
	End Method
	Rem
	bbdoc: Set the parent emitter
	about: Effects can be sub effects within effects. To do this emitters can store a list of effects that they attach to particles they spawn. This sets the emitter
	that the effect is parented to.
	endrem
	Method setparentEmitter(v:tlEmitter)
		parentEmitter = v
	End Method
	Rem
	bbdoc: Sets the number of frames
	about: Currently only relevent to the Timeline Particles editor
	endrem
	Method setframes(v:Int)
		frames = v
	End Method
	Rem
	bbdoc: Sets the anim width
	about: Currently only relevent to the Timeline Particles editor
	endrem
	Method setanimwidth(v:Int)
		animwidth = v
	End Method
	Rem
	bbdoc: Sets the anim height
	about: Currently only relevent to the Timeline Particles editor
	endrem
	Method setanimheight(v:Int)
		animheight = v
	End Method
	Rem
	bbdoc: Sets the whehter the animation loops seamlessly
	about: Currently only relevent to the Timeline Particles editor
	endrem
	Method setlooped(v:Int)
		looped = v
	End Method
	Rem
	bbdoc: Sets the x offset
	about: Currently only relevent to the Timeline Particles editor
	endrem
	Method setanimx(v:Int)
		animx = v
	End Method
	Rem
	bbdoc: Sets the y offset
	about: Currently only relevent to the Timeline Particles editor
	endrem
	Method setanimy(v:Int)
		animy = v
	End Method
	Rem
	bbdoc: Sets the random seed for the effect animation
	about: Currently only relevent to the Timeline Particles editor
	endrem
	Method setseed(v:Int)
		seed = v
	End Method
	Rem
	bbdoc: Sets the zoom of the animation
	about: Currently only relevent to the Timeline Particles editor
	endrem
	Method setzoom(v:Float)
		zoom = v
	End Method
	Rem
	bbdoc: Sets the frame offset of the animation
	about: Currently only relevent to the Timeline Particles editor
	endrem
	Method setframeoffset(v:Int)
		frameoffset = v
	End Method
	Rem
	bbdoc: Set to true for particles to traverse line type effects
	about: Only applying to line effects, setting this to true makes the particles travel along the length of the line always remaining relative to it.
	endrem
	Method settraverseedge(v:Int)
		traverseedge = v
	End Method
	Rem
	bbdoc: Set the end behaviour of particles traversing a line
	about: <p>If an effect if set so that particles traverse the edge of the line, then this makes the particles behave in one of 3 ways when they reach 
	the end of the line.  By passing it either of the following const they can:</p>
	<p><b>tlEND_LOOPAROUND</b>: The particles will loop back round to the beginning of the line.<br/>
	<b>tlEND_KILL</b>: The particles will be killed even if they haven't reached the end of their lifetimes yet.<br/>
	<b>tlLET_FREE</b>: The particles will be free to continue on their merry way.</p>
	endrem
	Method setendbehaviour(v:Int)
		endbehaviour = v
	End Method
	Rem
	bbdoc: Set to true to make the distance travelled determined by the life of the particle.
	about: When <i>traverseedge</i> is set to true and <i>endbehaviour</i> is set to true then the distance travelled along the line will be determined by the 
	age of the particle.
	endrem
	Method setdistancesetbylife(v:Int)
		distancesetbylife = v
	End Method
	Rem
	bbdoc: Sets the x handle of the effect
	about: This effects where the effect will be placed on screen. A value of 0 represents the left of the effect.
	endrem
	Method sethandlex(v:Int)
		handlex = v
	End Method
	Rem
	bbdoc: Sets the y handle of the effect
	about: This effects where the effect will be placed on screen. A value of 0 represents the top of the effect.
	endrem
	Method sethandley(v:Int)
		handley = v
	End Method
	Rem
	bbdoc: Sets to true to center the handle of the effect
	about: If set to true then then position of the handle is automatically set to to the center of the effect.
	endrem
	Method sethandlecenter(v:Int)
		handlecenter = v
	End Method
	Rem
	bbdoc: Set the order particles spawn
	about: A vlaue of true means that in area, line and ellipse effects, particles will spawn from right to left or anti-clockwise.
	endrem
	Method setreversespawn(v:Int)
		reversespawn = v
	End Method
	Rem
		bbdoc: This sets the direction particles are spawned.
		about: theres no need to call this, as its called internally by the emitter depending on the reverse spawn flag. see #setreversespawn.
	end rem
	Method setspawndirection()
		If reversespawn
			spawndirection = -1
		Else
			spawndirection = 1
		End If
	End Method
	Rem
	bbdoc: Set the effects particle manager
	about: Every effect needs a particle manager. For more info see #tlParticleManager
	endrem
	Method setparticlemanager(v:tlParticleManager)
		pm = v
	End Method
	Rem
	bbdoc: Set the area size of the effect
	about: For area and ellipse effects, use this function to override the graph and set the width and height of the area to whatever you want.
	endrem
	Method SetAreaSize(Width:Float, Height:Float)
		overridesize = True
		currentwidth = Width
		currentheight = Height
	End Method
	Rem
	bbdoc: Set the line length of the effect
	about: For line effects, use this function to override the graph and set the length of the line to whatever you want.
	endrem
	Method SetLineLength(Length:Float)
		overridesize = True
		currentwidth = Length
	End Method
	Rem
	bbdoc: Set the Emission Angle of the effect
	about: This overides whatever angle is set on the graph and sets the emission angle of the effect. This won't effect emitters that have <i>UseEffectEmission</i> set
	to FALSE.
	endrem
	Method SetEmissionAngle(angle:Float)
		overrideemissionangle = True
		currentemissionangle = angle
	End Method
	Rem
	bbdoc: Set the Angle of the effect
	about: This overides the whatever angle is set on the graph and sets the angle of the effect.
	endrem
	Method SetEffectAngle(_angle:Float)
		OverrideAngle = True
		angle = _angle
	End Method
	Rem
	bbdoc: Set the Global attribute Life of the effect
	about: This overides the graph the effect uses to set the Global Attribute Life
	endrem
	Method SetLife(life:Float)
		OverrideLife = True
		currentlife = life
	End Method
	Rem
	bbdoc: Set the Global attribute Amount of the effect
	about: This overides the graph the effect uses to set the Global Attribute Amount
	endrem
	Method SetAmount(amount:Float)
		OverrideAmount = True
		currentamount = amount
	End Method
	Rem
	bbdoc: Set the Global attribute velocity of the effect
	about: This overides the graph the effect uses to set the Global Attribute velocity
	endrem
	Method SetVelocity(velocity:Float)
		OverrideVelocity = True
		currentamount = velocity
	End Method
	Rem
	bbdoc: Set the Global attribute Spin of the effect
	about: This overides the graph the effect uses to set the Global Attribute Spin
	endrem
	Method SetSpin(spin:Float)
		OverrideSpin = True
		currentspin = Spin
	End Method
	Rem
	bbdoc: Set the Global attribute Weight of the effect
	about: This overides the graph the effect uses to set the Global Attribute Weight
	endrem
	Method SetWeight(Weight:Float)
		OverrideWeight = True
		currentweight = Weight
	End Method
	Rem
	bbdoc: Set the Global attribute Sizex of the effect
	about: This overides the graph the effect uses to set the Global Attribute Sizex and sizey
	endrem
	Method SetEffectParticleSize(Sizex:Float, Sizey:Float)
		OverrideSizex = True
		OverrideSizey = True
		currentsizex = Sizex
		currentsizey = Sizey
	End Method
	Rem
	bbdoc: Set the Global attribute Sizex of the effect
	about: This overides the graph the effect uses to set the Global Attribute Sizex
	endrem
	Method SetSizex(Sizex:Float)
		OverrideSizex = True
		currentsizex = Sizex
	End Method
	Rem
	bbdoc: Set the Global attribute Sizey of the effect
	about: This overides the graph the effect uses to set the Global Attribute Sizey
	endrem
	Method SetSizey(Sizey:Float)
		OverrideSizey = True
		currentSizey = Sizey
	End Method
	Rem
	bbdoc: Set the Global attribute Alpha of the effect
	about: This overides the graph the effect uses to set the Global Attribute Alpha
	endrem
	Method SetEffectAlpha(Alpha:Float)
		OverrideAlpha = True
		currentalpha = Alpha
	End Method
	Rem
	bbdoc: Set the Global attribute EmissionRange of the effect
	about: This overides the graph the effect uses to set the Global Attribute EmissionRange
	endrem
	Method SetEffectEmissionRange(EmissionRange:Float)
		OverrideEmissionRange = True
		currentemissionrange = EmissionRange
	End Method
	Rem
	bbdoc: Set range in degrees of the arc
	about: When an effect uses an ellipse as its effect type, you can adjust how far round the ellipse particles will spawn
	by setting the ellipse arc. 360 degrees will spawn around the full amount.
	endrem
	Method SetEllipseArc(degrees:Float)
		ellipsearc = degrees
		ellipseoffset = 90 - degrees / 2
	End Method
	Rem
		bbdoc:Set the current zoom level of the effect
		about:This overides the graph the effect uses to set the Global Attribute Global Zoom
	End Rem
	Method SetZ(v:Float)
		overrideglobalz = True
		z = v
	End Method
	Rem
	bbdoc: Set the Global attribute Stretch of the effect
	about: This overides the graph the effect uses to set the Global Attribute Stretch
	endrem
	Method SetStretch(v:Float)
		OverrideStretch = True
		currentstretch = v
	End Method
	Rem
	bbdoc: Sets the current state of whether spawned particles are added to the particle managers pool, or the emitters own pool. True means that
			they're grouped together under each emitter. This will change all emitters with the effect, and is recommended you use this rather then individually
			for each emitter.
	endrem
	Method SetGroupParticles(v:Int)
		For Local e:tlEmitter = EachIn children
			e.setgroupparticles(v)
			For Local ef:tlEffect = EachIn e.effects
				ef.setgroupparticles(v)
			Next
		Next
	End Method
	Rem
	bbdoc: Turns the effect into a super effect which can basically group effect together. A super effect does not contain emitters, only effects.
	endrem
	Method MakeSuper()
		issuper = True
		effects = CreateList()
	End Method
	Rem
	bbdoc: If the effect is a super effect, then you can use this method to add effects to it.
	endrem
	Method AddGroupedEffect(e:tlEffect)
		If Not issuper
			Throw "This is not a super effect. Use MakeSuper first before adding effects."
		End If
		effects.AddLast(e)
		e.parent = Self
	End Method
	Rem
	bbdoc: Get class
	returns: The current class of the effect - tlAREA_EFFECT, tlLINE_EFFECT, tlELLIPSE_EFFECT or tlPOINT_EFFECT
	endrem
	Method getclass:Int()
		Return class
	End Method
	Rem
	bbdoc: Returns the <i>lockaspect</i> 
	returns: Either TRUE or FALSE
	endrem
	Method getlockaspect:Int()
		Return lockaspect
	End Method
	Rem
	bbdoc: Get the path of the entity
	about: the path will be the address of where the entity is within the hierarchy of parent and child entities
	endrem
	Method getpath:String()
		Return path
	End Method
	Rem
	bbdoc: Get the current maximum grid points along the width
	endrem
	Method getmgx:Int()
		Return mgx
	End Method
	Rem
	bbdoc: Get the current maximum grid points along the height
	endrem
	Method getmgy:Int()
		Return mgy
	End Method
	Rem
	bbdoc: Get wheter the effect is currently set to emit at points
	returns: Either TRUE or FALSE
	endrem
	Method getemitatpoints:Int()
		Return emitatpoints
	End Method
	Rem
	bbdoc: Get the current emission type
	returns: The current emission type: tlEMISSION_INWARDS, tlEMISSION_OUTWARDS, tlEMISSION_SPECIFIED, tlEMISSION_IN_AND_OUT
	endrem
	Method getemissiontype:Int()
		Return emissiontype
	End Method
	Rem
	bbdoc: Get the effect length
	returns: Length in millisecs
	endrem
	Method getEffectlength:Int()
		Return effectlength
	End Method
	Rem
	bbdoc: Get the parent emitter of the effect
	endrem
	Method getparentEmitter:tlEmitter()
		Return parentEmitter
	End Method
	Rem
	bbdoc: Get the parent entity of the effect
	endrem
	Method getparent:tlEntity()
		Return parent
	End Method
	Rem
	bbdoc: Get the number of frames in the animation
	endrem
	Method getframes:Int()
		Return frames
	End Method
	Rem
	bbdoc: Get the width of the animation
	endrem
	Method getanimwidth:Int()
		Return animwidth
	End Method
	Rem
	bbdoc: Get the Height of the animation
	endrem
	Method getanimheight:Int()
		Return animheight
	End Method
	Rem
	bbdoc: Get whether the animation is looped or not
	returns: either TRUE or FALSE
	endrem
	Method getlooped:Int()
		Return looped
	End Method
	Rem
	bbdoc: Get the x offset of the effect in the animation
	endrem
	Method getanimx:Int()
		Return animx
	End Method
	Rem
	bbdoc: Get the y offset of the effect in the animation
	endrem
	Method getanimy:Int()
		Return animy
	End Method
	Rem
	bbdoc: Get the current random seed value of the animation
	endrem
	Method getseed:Int()
		Return seed
	End Method
	Rem
	bbdoc: Get the current zoom factor of the animation
	endrem
	Method getzoom:Float()
		Return zoom
	End Method
	Rem
	bbdoc: Get the frame offset of the animation
	endrem
	Method getframeoffset:Int()
		Return frameoffset
	End Method
	Rem
	bbdoc: Get whether particles should traverse the line (if it's a line effect)
	returns: Either TRUE or FALSE
	endrem
	Method gettraverseedge:Int()
		Return traverseedge
	End Method
	Rem
	bbdoc: Gets the end behaviour for when particles reach the end of the line
	returns: Either tlEND_KILL, tlEND_LOOPAROUND, tlEND_LETFREE
	endrem
	Method getendbehaviour:Int()
		Return endbehaviour
	End Method
	Rem
	bbdoc: Gets whether the distance along the traversed line is determined by the particle age
	returns: Either TRUE or FALSE
	endrem
	Method getdistancesetbylife:Int()
		Return distancesetbylife
	End Method
	Rem
	bbdoc: Get the x handle of the effect
	endrem
	Method gethandlex:Int()
		Return handlex
	End Method
	Rem
	bbdoc: Get the y handle of the effect
	endrem
	Method gethandley:Int()
		Return handley
	End Method
	Rem
	bbdoc: Get whether the effect's handle is automatically set to center
	returns: Either TRUE or FALSE
	endrem
	Method gethandlecenter:Int()
		Return handlecenter
	End Method
	Rem
	bbdoc: Gets whether the particles should spawn in the opposite direction
	returns: Either TRUE or FALSE
	endrem
	Method getreversespawn:Int()
		Return reversespawn
	End Method
	Rem
	bbdoc: Gets the current number of particles spawned by this effects' emitters including any sub effects
	endrem
	Method getParticlecount:Int()
		particlecount = 0
		For Local e:tlEmitter = EachIn children
			For Local p:tlParticle = EachIn e.children
				For Local eff:tlEffect = EachIn p.children
					particlecount:+eff.getParticlecount()
				Next
			Next
			particlecount:+e.childcount
		Next
		Return particlecount
	End Method
	Rem
	bbdoc: get the range in degrees of the arc
	about: see #SetEllipseArc
	endrem
	Method GetEllipseArc:Int()
		Return ellipsearc
	End Method	

	Method HasParticles:Int()
		For Local e:tlEmitter = EachIn children
			If e.childcount Return True
		Next
		Return False
	End Method
	
	Rem
	bbdoc: Add a new effect to the directory including any sub effects and emitters. Effects are stored using a map and can be retrieved using #GetEffect.
	endrem
	Method AddEffect(e:tlEffect)
		directory.Insert(Upper(e.getpath()), e)
		For Local em:tlEmitter = EachIn e.children
			addemitter(em)
		Next
	End Method
	Rem
	bbdoc: Add a new emitter to the directory. Emitters are stored using a map and can be retrieved using #GetEmitter. Generally you don't want to call this at all, 
	just use #AddEffect and all its emitters will be added also.
	endrem
	Method AddEmitter(e:tlEmitter)
		directory.Insert(Upper(e.getpath()), e)
		For Local ef:tlEffect = EachIn e.effects
			addeffect(ef)
		Next
	End Method
	Rem
	bbdoc: Retrieve an effect from the directory of the effect
	returns: tlEffect
	about: <p>Use this to get an effect from the effect directory by passing the name of the effect you want. Example:</p>
	&{local explosion:tlEffect=MyEffectsLibrary.Geteffect("explosion")}
	<p>All effects and emitters are stored using a directory like path structure so to get at sub effects you can do:</p>
	&{local explosion:tlEffect=MyEffectsLibrary.Geteffect("Effect/Emitter/Sub Effect/Another Emitter/A deeper sub effect")}
	<p>Note that you should always use forward slashes.</p>
	endrem
	Method GetEffect:tlEffect(name:String)
		Return tlEffect(directory.ValueForKey(Upper(name)))
	End Method
	Rem
	bbdoc: Retrieve an emitter from the of the effect
	returns: tlEmitter
	about:< p > Use this To get an emitter from the effect directory by passing the name of the emitter you want. All effects And emitters are
	stored using a map with a directory like path structure. So retrieving an emitter called blast wave inside an effect called explosion
	would be done like so:</p>
	&{local blastwave:tlemitter=MyEffectsLibrary.GetEmitter("explosion/blast wave")}
	<p>Note that you should always use forward slashes.</p>
	endrem
	Method GetEmitter:tlEmitter(name:String)
		Return tlEmitter(directory.ValueForKey(Upper(name)))
	End Method
	Rem
		bbdoc: Stop the effect from timing out and be automatically removed
		about: By default, if the effect has no particles, it will timeout and destroy itself after a certain amount of time as dictated by
		the particle manager it belongs to. Call this method to stop the process from happening. Bear in mind that if you do this
		you will have to destroy the effect yourself, either by calling Destroy, Hardkill ir Softkill. This method propergates to all subeffects
		as well. For best results this method should called when the effect is created before it starts spawning particles.
	end rem	
	Method DoNotTimeout(v:Int = True)
		doesnottimeout = v
		For Local e:tlEmitter = EachIn children
			For Local eff:tlEffect = EachIn e.effects
				eff.DoNotTimeout(v)
			Next
		Next
	End Method
	
	Rem
	bbdoc: Updates the effect
	about: Call this once every frame to update the effect. Updating effects is handled by the Particle Manager unless you want to manage things on your own.
	endrem
	Method update()
		
		capture()
		
		age = pm.CURRENT_TIME - dob
		
		If spawnage < age
			spawnage = age
		End If
		
		If effectlength
			If age > effectlength
				dob = pm.CURRENT_TIME
				age = 0
			End If
		End If
		
		currentframe = age / tp_LOOKUP_FREQUENCY
		
		Select pm.updatemode
			Case tlUPDATE_MODE_COMPILED
				If Not overridesize
					Select class
						Case tlPOINT_EFFECT
							currentwidth = 0
							currentheight = 0
						Case tlAREA_EFFECT, tlELLIPSE_EFFECT
							currentwidth = get_width(currentframe)
							currentheight = get_height(currentframe)
						Case tlLINE_EFFECT
							currentwidth = get_width(currentframe)
							currentheight = 0
					End Select
				End If
			Case tlUPDATE_MODE_INTERPOLATED
				If Not overridesize
					Select class
						Case tlPOINT_EFFECT
							currentwidth = 0
							currentheight = 0
						Case tlAREA_EFFECT, tlELLIPSE_EFFECT
							currentwidth = interpolate_width(age)
							currentheight = interpolate_height(age)
						Case tlLINE_EFFECT
							currentwidth = interpolate_width(age)
							currentheight = 0
					End Select
				End If
		End Select
		
		'can be optimised
		If handlecenter And class <> tlPOINT_EFFECT
			handlex = currentwidth / 2
			handley = currentheight / 2
		ElseIf handlecenter
			handlex = 0
			handley = 0
		End If
		
		If HasParticles() Or doesnottimeout
			idletime = 0
		Else
			idletime:+1
		End If
				
		If parentemitter
			Select pm.updatemode
				Case tlUPDATE_MODE_COMPILED
					If Not overridelife currentlife = get_life(currentframe) * parentemitter.parentEffect.currentlife
					If Not overrideamount currentamount = get_amount(currentframe) * parentemitter.parentEffect.currentamount
					If lockaspect
						If Not overridesizex currentsizex = get_sizex(currentframe) * parentemitter.parentEffect.currentsizex
						If Not overridesizey currentsizey = currentsizex * parentemitter.parentEffect.currentsizey
					Else
						If Not overridesizex currentsizex = get_sizex(currentframe) * parentemitter.parentEffect.currentsizex
						If Not overridesizey currentsizey = get_sizey(currentframe) * parentemitter.parentEffect.currentsizey
					End If
					If Not overridevelocity currentvelocity = get_velocity(currentframe) * parentemitter.parentEffect.currentvelocity
					If Not overrideweight currentweight = get_weight(currentframe) * parentemitter.parentEffect.currentweight
					If Not overridespin currentspin = get_spin(currentframe) * parentemitter.parentEffect.currentspin
					If Not overridealpha currentalpha = get_alpha(currentframe) * parentemitter.parentEffect.currentalpha
					If Not overrideemissionangle currentemissionangle = get_emissionangle(currentframe)
					If Not overrideemissionrange currentemissionrange = get_emissionrange(currentframe)
					If Not overrideangle angle = interpolate_angle(age)
					If Not overridestretch currentstretch = get_stretch(age) * parentemitter.parentEffect.currentstretch
					If Not overrideglobalz currentglobalz = get_globalz(age) * parentemitter.parentEffect.currentglobalz
				Case tlUPDATE_MODE_INTERPOLATED
					If Not overridelife currentlife = interpolate_life(age) * parentemitter.parentEffect.currentlife
					If Not overrideamount currentamount = interpolate_amount(age) * parentemitter.parentEffect.currentamount
					If lockaspect
						If Not overridesizex currentsizex = interpolate_sizex(age) * parentemitter.parentEffect.currentsizex
						If Not overridesizey currentsizey = currentsizex * parentemitter.parentEffect.currentsizey
					Else
						If Not overridesizex currentsizex = interpolate_sizex(age) * parentemitter.parentEffect.currentsizex
						If Not overridesizey currentsizey = interpolate_sizey(age) * parentemitter.parentEffect.currentsizey
					End If
					If Not overridevelocity currentvelocity = interpolate_velocity(age) * parentemitter.parentEffect.currentvelocity
					If Not overrideweight currentweight = interpolate_weight(age) * parentemitter.parentEffect.currentweight
					If Not overridespin currentspin = interpolate_spin(age) * parentemitter.parentEffect.currentspin
					If Not overridealpha currentalpha = interpolate_alpha(age) * parentemitter.parentEffect.currentalpha
					If Not overrideemissionangle currentemissionangle = interpolate_emissionangle(age)
					If Not overrideemissionrange currentemissionrange = interpolate_emissionrange(age)
					If Not overrideangle angle = interpolate_angle(age)
					If Not overridestretch currentstretch = interpolate_stretch(age) * parentemitter.parentEffect.currentstretch
					If Not overrideglobalz currentglobalz = interpolate_globalz(age) * parentemitter.parentEffect.currentglobalz
			End Select
		Else
			Select pm.updatemode
				Case tlUPDATE_MODE_COMPILED
					If Not overridelife currentlife = get_life(currentframe)
					If Not overrideamount currentamount = get_amount(currentframe)
					If lockaspect
						If Not overridesizex currentsizex = get_sizex(currentframe)
						If Not overridesizey currentsizey = currentsizex
					Else
						If Not overridesizex currentsizex = get_sizex(currentframe)
						If Not overridesizey currentsizey = get_sizey(currentframe)
					End If
					If Not overridevelocity currentvelocity = get_velocity(currentframe)
					If Not overrideweight currentweight = get_weight(currentframe)
					If Not overridespin currentspin = get_spin(currentframe)
					If Not overridealpha currentalpha = get_alpha(currentframe)
					If Not overrideemissionangle currentemissionangle = get_emissionangle(currentframe)
					If Not overrideemissionrange currentemissionrange = get_emissionrange(currentframe)
					If Not overrideangle angle = interpolate_angle(age)
					If Not overridestretch currentstretch = get_stretch(age)
					If Not overrideglobalz currentglobalz = get_globalz(age)
				Case tlUPDATE_MODE_INTERPOLATED
					If Not overridelife currentlife = interpolate_life(age)
					If Not overrideamount currentamount = interpolate_amount(age)
					If lockaspect
						If Not overridesizex currentsizex = interpolate_sizex(age)
						If Not overridesizey currentsizey = currentsizex
					Else
						If Not overridesizex currentsizex = interpolate_sizex(age)
						If Not overridesizey currentsizey = interpolate_sizey(age)
					End If
					If Not overridevelocity currentvelocity = interpolate_velocity(age)
					If Not overrideweight currentweight = interpolate_weight(age)
					If Not overridespin currentspin = interpolate_spin(age)
					If Not overridealpha currentalpha = interpolate_alpha(age)
					If Not overrideemissionangle currentemissionangle = interpolate_emissionangle(age)
					If Not overrideemissionrange currentemissionrange = interpolate_emissionrange(age)
					If Not overrideangle angle = interpolate_angle(age)
					If Not overridestretch currentstretch = interpolate_stretch(age)
					If Not overrideglobalz currentglobalz = interpolate_globalz(age)
			End Select
		End If
		
		If Not overrideglobalz
			z = currentglobalz
		End If
		
		If Not currentweight bypass_weight = True
		
		If parentemitter dying = parentemitter.dying
		
		Super.update()
		
		If idletime > pm.idletimelimit dead = True
		
		If dead
			If Not childcount
				If parent
					parent.removechild(Self)
				End If
				destroy()
			Else
				killchildren()
			End If
		End If
		
	End Method
	Rem
	bbdoc: Softly kill an effect
	about: Call this to kill an effect by stopping it from spawning any more particles. This will make the effect slowly die about as any remaining 
	particles cease to exist. Any single particles are converted to one shot particles.
	endrem
	Method softkill()
		dying = 1
	End Method
	Rem
	bbdoc: Hard kill an effect
	about: immediatley kills an effect by destroying all particles created by it.
	endrem
	Method hardkill()
		destroy()
		pm.removeeffect(Self)
	End Method

	Method destroy()
		parentemitter = Null
		directory = Null
		For Local c:Int = 0 To 8
			inuse[c].Clear()
		Next
		Super.Destroy()
	End Method
		
	Method interpolate_amount:Float(_age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn amount
			If _age < a.frame
				p = (_age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_life:Float(_age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn life
			If _age < a.frame
				p = (_age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_sizex:Float(_age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn sizex
			If _age < a.frame
				p = (_age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_sizey:Float(_age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn sizey
			If _age < a.frame
				p = (_age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_velocity:Float(_age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn velocity
			If _age < a.frame
				p = (_age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_weight:Float(_age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn weight
			If _age < a.frame
				p = (_age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_spin:Float(_age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn spin
			If _age < a.frame
				p = (_age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_alpha:Float(_age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn alpha
			If _age < a.frame
				p = (_age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, 0, 1)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_emissionangle:Float(_age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn emissionangle
			If _age < a.frame
				p = (_age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlANGLE_MIN, tlANGLE_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_emissionrange:Float(_age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn emissionrange
			If _age < a.frame
				p = (_age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlEMISSION_RANGE_MIN, tlEMISSION_RANGE_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_width:Float(_age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn width
			If _age < a.frame
				p = (_age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlDIMENSIONS_MIN, tlDIMENSIONS_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_height:Float(_age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn height
			If _age < a.frame
				p = (_age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlDIMENSIONS_MIN, tlDIMENSIONS_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_angle:Float(_age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn effectangle
			If _age < a.frame
				p = (_age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlANGLE_MIN, tlANGLE_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_stretch:Float(_age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn stretch
			If _age < a.frame
				p = (_age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_globalz:Float(_age:Int)
		If Not globalz.Last()
			Return 1
		End If
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn globalz
			If _age < a.frame
				p = (_age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	
	'Compilers
	Rem
	bbdoc: Pre-Compile all attributes.
	about: In order to use look-up arrays to access attribute values over the course of the effects life you need to compile all of the attribute values
	into an array. This method will compile all of them together in one go including all of it children emiters and any sub effects and so on.
	endrem
	Method compile_all()
		If issuper
			For Local e:tlEffect = EachIn effects
				e.compile_all()
			Next
		Else
			compile_life()
			compile_amount()
			compile_sizex()
			compile_sizey()
			compile_velocity()
			compile_weight()
			compile_spin()
			compile_alpha()
			compile_emissionangle()
			compile_emissionrange()
			compile_width()
			compile_height()
			compile_angle()
			compile_stretch()
			compile_globalz()
			For Local e:tlEmitter = EachIn children
				e.compile_all()
			Next
		End If
	End Method
	Method compile_quick()
		If issuper
			For Local e:tlEffect = EachIn effects
				e.compile_quick()
			Next
		Else
			For Local e:tlEmitter = EachIn children
				e.compile_quick()
				e.ResetByPassers()
			Next
		End If
	End Method
	'-------------
	Method compile_amount()
		If amount.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(amount.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_amount = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_amount.changes[frame] = interpolate_amount(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_amount.changes[frame] = lastec.value
		Else
			c_amount = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_life()
		If life.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(life.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_life = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_life.changes[frame] = interpolate_life(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_life.changes[frame] = lastec.value
		Else
			c_life = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_sizex()
		If sizex.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(sizex.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_sizex = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_sizex.changes[frame] = interpolate_sizex(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_sizex.changes[frame] = lastec.value
		Else
			c_sizex = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_sizey()
		If sizey.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(sizey.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_sizey = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_sizey.changes[frame] = interpolate_sizey(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_sizey.changes[frame] = lastec.value
		Else
			c_sizey = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_velocity()
		If velocity.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(velocity.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_velocity = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_velocity.changes[frame] = interpolate_velocity(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_velocity.changes[frame] = lastec.value
		Else
			c_velocity = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_weight()
		If weight.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(weight.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_weight = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_weight.changes[frame] = interpolate_weight(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_weight.changes[frame] = lastec.value
		Else
			c_weight = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_spin()
		If spin.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(spin.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_spin = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_spin.changes[frame] = interpolate_spin(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_spin.changes[frame] = lastec.value
		Else
			c_spin = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_alpha()
		If alpha.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(alpha.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_alpha = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_alpha.changes[frame] = interpolate_alpha(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_alpha.changes[frame] = lastec.value
		Else
			c_alpha = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_emissionangle()
		If emissionangle.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(emissionangle.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_emissionangle = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_emissionangle.changes[frame] = interpolate_emissionangle(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_emissionangle.changes[frame] = lastec.value
		Else
			c_emissionangle = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_emissionrange()
		If emissionrange.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(emissionrange.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_emissionrange = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_emissionrange.changes[frame] = interpolate_emissionrange(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_emissionrange.changes[frame] = lastec.value
		Else
			c_emissionrange = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_width()
		If width.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(width.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_width = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_width.changes[frame] = interpolate_width(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_width.changes[frame] = lastec.value
		Else
			c_width = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_height()
		If height.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(height.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_height = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_height.changes[frame] = interpolate_height(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_height.changes[frame] = lastec.value
		Else
			c_height = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_angle()
		If effectangle.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(effectangle.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_angle = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_angle.changes[frame] = interpolate_angle(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_angle.changes[frame] = lastec.value
		Else
			c_angle = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_stretch()
		If stretch.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(stretch.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_stretch = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_stretch.changes[frame] = interpolate_stretch(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_stretch.changes[frame] = lastec.VALUE
		Else
			c_stretch = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_globalz()
		If globalz.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(globalz.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_globalz = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_globalz.changes[frame] = interpolate_globalz(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_globalz.changes[frame] = lastec.VALUE
		Else
			c_globalz = New tlEmitterArray.Create(1)
			c_globalz.changes[c_globalz.lastframe] = 1
		End If
	End Method
	'-------------
	'Lookups
	Method get_life:Float(frame:Int)
		If frame <= c_life.lastframe
			Return c_life.changes[frame]
		Else
			Return c_life.changes[c_life.lastframe]
		End If
	End Method
	Method get_amount:Float(frame:Int)
		If frame <= c_amount.lastframe
			Return c_amount.changes[frame]
		Else
			Return c_amount.changes[c_amount.lastframe]
		End If
	End Method
	Method get_sizex:Float(frame:Int)
		If frame <= c_sizex.lastframe
			Return c_sizex.changes[frame]
		Else
			Return c_sizex.changes[c_sizex.lastframe]
		End If
	End Method
	Method get_sizey:Float(frame:Int)
		If frame <= c_sizey.lastframe
			Return c_sizey.changes[frame]
		Else
			Return c_sizey.changes[c_sizey.lastframe]
		End If
	End Method
	Method get_velocity:Float(frame:Int)
		If frame <= c_velocity.lastframe
			Return c_velocity.changes[frame]
		Else
			Return c_velocity.changes[c_velocity.lastframe]
		End If
	End Method
	Method get_weight:Float(frame:Int)
		If frame <= c_weight.lastframe
			Return c_weight.changes[frame]
		Else
			Return c_weight.changes[c_weight.lastframe]
		End If
	End Method
	Method get_spin:Float(frame:Int)
		If frame <= c_spin.lastframe
			Return c_spin.changes[frame]
		Else
			Return c_spin.changes[c_spin.lastframe]
		End If
	End Method
	Method get_alpha:Float(frame:Int)
		If frame <= c_alpha.lastframe
			Return c_alpha.changes[frame]
		Else
			Return c_alpha.changes[c_alpha.lastframe]
		End If
	End Method
	Method get_emissionangle:Float(frame:Int)
		If frame <= c_emissionangle.lastframe
			Return c_emissionangle.changes[frame]
		Else
			Return c_emissionangle.changes[c_emissionangle.lastframe]
		End If
	End Method
	Method get_emissionrange:Float(frame:Int)
		If frame <= c_emissionrange.lastframe
			Return c_emissionrange.changes[frame]
		Else
			Return c_emissionrange.changes[c_emissionrange.lastframe]
		End If
	End Method
	Method get_width:Float(frame:Int)
		If frame <= c_width.lastframe
			Return c_width.changes[frame]
		Else
			Return c_width.changes[c_width.lastframe]
		End If
	End Method
	Method get_height:Float(frame:Int)
		If frame <= c_height.lastframe
			Return c_height.changes[frame]
		Else
			Return c_height.changes[c_height.lastframe]
		End If
	End Method
	Method get_angle:Float(frame:Int)
		If frame <= c_angle.lastframe
			Return c_angle.changes[frame]
		Else
			Return c_angle.changes[c_angle.lastframe]
		End If
	End Method
	Method get_stretch:Float(frame:Int)
		If frame <= c_stretch.lastframe
			Return c_stretch.changes[frame]
		Else
			Return c_stretch.changes[c_stretch.lastframe]
		End If
	End Method
	Method get_globalz:Float(frame:Int)
		If frame <= c_globalz.lastframe
			Return c_globalz.changes[frame]
		Else
			Return c_globalz.changes[c_globalz.lastframe]
		End If
	End Method

	Method ChangeDob(_DoB:Float)
		dob = _DoB
		For Local e:tlEmitter = EachIn children
			e.ChangeDob(_DoB)
		Next
	End Method
End Type
Rem
	bbdoc: Emitter Type - Extension of tlEntity
	about: <p>An emitter type is an entity whose sole purpose is to spawn particles. Like the effect type it too has number of attributes that can tell the particles
	that it spawns how to move, orientate and scale themselves on screen to create the effects.</p>
	<p>The attributes an emitter has can be put into a few different categories:</p>
	<h4>Base Attributes</h4>
	<p>Base attributes set the base level that life overtime values will scale to. 	The x axis of the graph represents the time in seconds the the 
	effect has been running for. So for example you may set the velocity to 200 for at the start of the effect then have it slowly reduce to 0 over 5 
	seconds of the effect running.</p>
	<h3>Life</h3>
	<p>This attribute determines how long the particle will live before before ceasing to exist. You can plot points on the graph so that the life of 
	particles will vary over the lifetime of the effect.</p>
	<h3>Amount</h3>
	<p>This controls how many particles per second that the emitter will spawn at that point in time of the effect running.</p>
	<h3>Size</h3>
	<p>Size controls the base level that the size over-life attributes scale to. By right clicking the particle attributes list you can toggle 
	"Uniform Size" which will enable the size attribute to split into width and height attributes so that these can be changed independantly of each other.</p>
	<h3>Velocity</h3>
	<p>This controls the base speed of the particles being spawned that the velocity over-life attributes scale to.</p>
	<h3>Spin</h3>
	<p>Spin controls the base speed with which particles rotate in either direction and determines what the spin over-life scales too.</p>
	<h3>Weight</h3>
	<p>This controls the base weight of the particle that the weight over-life attribute is scaled to.</p>
	<H4>Variation Attributes</H4>
	<p>Variation attributes represent random values that are added to the base values in order to add some variation and unpredicatability to the particles 
	behaviour.</p>
	<h3>Life Variation</h3>
	<p>This will add a random amount of seconds onto the base attribute of life so that particles that spawn will vary in the amount of time they stay alive.</p>
	<h3>Amount Variation</h3>
	<p>This will apply variation to the base amount attribute so that the amount of particles spawned over the effect's life time will vary.</p>
	<h3>Size Variation</h3>
	<p>Applies a random value onto the base size so the particles spawned will vary in size.</p>
	<h3>Velocitiy Variation</h3>
	<p>This will vary the base velocity of the particle based by the amount you plot on the graph so that partcicles will spawn and move with varying speeds.</p>
	<h3>Spin Variation</h3>
	<p>This will vary the speed at which the particles spawned will rotate.</p>
	<h3>Weight Variation</h3>
	<p>Applies a random amount of weight onto the base weight of the particles that are spawned.</p>
	<h3>Motion Randomness</h3>
	<p>Motion randomness does not vary any of the base values, but it does dictate to what degree the particle will move about in a random fashion. 
	Motion randomness effects the speed and direction of the particle so the higher this value the more erratically the particles will move about.</p>
	<H4>Overtime Attributes</H4>
	<p>These attribute control how the particle behaves over the lifetime of the particle. The x axis of the graph represents the life time of the 
	particle so you can control exactly how the particle behaves at each stage of its life. The y axis represents a percentage of the base value set in the 
	Base Attributes and Variation Attrbutes. So if for example you have velocity set at 100 and the velocity overtime is set to 0.5 then the particle will 
	therefore be travelling at half it's speed; 50 pixels per second.</p>
	<h3>Alpha Overtime</h3>
	<p>This doesn't actually scale any base attribute, it simply controls the alpha value of the particle, or how visible the particle is. Values should range
	from 0 to 1.</p>
	<h3>Size Overtime</h3>
	<p>This enables you to control the size of the particle over its life time by scaling the base size attribute.</p>
	<h3>Velocity Overtime</h3>
	<p>This enables you to control how fast the the partcle travels over its life time by scaling the base velocity attribute.</p>
	<h3>Spin Overtime</h3>
	<p>This controls the speed with which the particle spins by scaling the base spin attribute.</p>
	<h3>Weight Overtime</h3>
	<p>This controls the weight overtime of the particle by scaling the base weight attribute.</p>
	<h3>Direction Overtime</h3>
	<p>This dictates the direction that the particle travels in over its lifetime.</p>
	<h3>Motion Randomness Overtime</h3>
	<p>This scales the Motion Randomness attribute over the particles lifetime so you can finely tune how erratically the particle moves.</p>
	<h3>Frame Rate</h3>
	<p>If the particle is set to animate then you can use this attribute to control how fast is animates over the lifetime of the particle.</p>
	<H4>Velocity Adjuster</H4>
	<p>This attribute scales the speed of all particles currently in existence for a more global control</p>
	<h3>Adding and retrieving attribute values</h3>
	<p>This is all handled by the effect, emitter and particle update methods so theres not much need to worry about these methods 
	but here is some info about how this is achieved.</p>
	<p>To add a value to each of these attributes use the corresponding add method ie., #addlife
	<p>As in the effect type the values of attributes are looked up using interpolation or pre compiled in arrays. The following table lists all the interpolation
	methods and their equivalent compiler methods, look-up methods and add methdods for adding new attribute values.</p>
	<table>
	<tr><th>Interpolation Methods</th><th>Equivalent Compiler Methods</th><th>Lookup Table Methods</th><th>Add Methods</th></tr>
	<tr><td>interpolate_amount</td><td>compile_amount</td><td>get_amount</td><td> #addamount</td></tr>
	<tr><td>interpolate_life</td><td>compile_life</td><td>get_life</td><td> #addlife</td></tr>
	<tr><td>interpolate_sizex</td><td>compile_sizex</td><td>get_sizex</td><td> #addsizex</td></tr>
	<tr><td>interpolate_sizey</td><td>compile_sizey</td><td>get_sizey</td><td> #addsizey</td></tr>
	<tr><td>interpolate_basespeed</td><td>compile_basespeed</td><td>get_basespeed</td><td> #addbasespeed</td></tr>
	<tr><td>interpolate_baseweight</td><td>compile_baseweight</td><td>get_baseweight</td><td> #addbaseweight</td></tr>
	<tr><td>interpolate_basespin</td><td>compile_basespin</td><td>get_basespin</td><td> #addbasespin</td></tr>
	<tr><td>interpolate_emissionangle</td><td>compile_emissionangle</td><td>get_emissionangle</td><td> #addemissionangle</td></tr>
	<tr><td>interpolate_emissionrange</td><td>compile_emissionrange</td><td>get_emissionrange</td><td> #addemissionrange</td></tr>
	<tr><td>interpolate_velvariation</td><td>compile_velvariation</td><td>get_velvariation</td><td> #addvelvariation</td></tr>
	<tr><td>interpolate_weightvariation</td><td>compile_weightvariation</td><td>get_weightvariation</td><td> #addweightvariation</td></tr>
	<tr><td>interpolate_lifevariation</td><td>compile_lifevariation</td><td>get_lifevariation</td><td> #addlifevariation</td></tr>
	<tr><td>interpolate_amountvariation</td><td>compile_amountvariation</td><td>get_amountvariation</td><td> #addamountvariation</td></tr>
	<tr><td>interpolate_sizexvariation</td><td>compile_sizexvariation</td><td>get_sizexvariation</td><td> #addsizexvariation</td></tr>
	<tr><td>interpolate_sizeyvariation</td><td>compile_sizeyvariation</td><td>get_sizeyvariation</td><td> #addsizeyvariation</td></tr>
	<tr><td>interpolate_spinvariation</td><td>compile_spinvariation</td><td>get_spinvariation</td><td> #addspinvariation</td></tr>
	<tr><td>interpolate_directionvariation</td><td>compile_directionvariation</td><td>get_directionvariation</td><td> #adddirectionvariation</td></tr>
	<tr><td>interpolate_alpha</td><td>compile_alpha</td><td>get_alpha</td><td> #addalpha</td></tr>
	<tr><td>interpolate_r</td><td>compile_r</td><td>get_r</td><td> #addr</td></tr>
	<tr><td>interpolate_g</td><td>compile_g</td><td>get_g</td><td> #addg</td></tr>
	<tr><td>interpolate_b</td><td>compile_b</td><td>get_b</td><td> #addb</td></tr>
	<tr><td>interpolate_scalex</td><td>compile_scalex</td><td>get_scalex</td><td> #addscalex</td></tr>
	<tr><td>interpolate_scaley</td><td>compile_scaley</td><td>get_scaley</td><td> #addscaley</td></tr>
	<tr><td>interpolate_spin</td><td>compile_spin</td><td>get_spin</td><td> #addspin</td></tr>
	<tr><td>interpolate_velocity</td><td>compile_velocity</td><td>get_velocity</td><td> #addvelocity</td></tr>
	<tr><td>interpolate_weight</td><td>compile_weight</td><td>get_weight</td><td> #addweight</td></tr>
	<tr><td>interpolate_direction</td><td>compile_direction</td><td>get_direction</td><td> #adddirection</td></tr>
	<tr><td>interpolate_directionvariationot</td><td>compile_directionvariationot</td><td>get_directionvariationot</td><td> #adddirectionvariationot</td></tr>
	<tr><td>interpolate_framerate</td><td>compile_framerate</td><td>get_framerate</td><td> #addframerate</td></tr>
	<tr><td>interpolate_globalvelocity</td><td>compile_globalvelocity</td><td>get_globalvelocity</td><td> #addglobalvelocity</td></tr>
	</table>
	<p>There are also a number of properties that controll further how the particles look, how they're spawned and how they're drawn:</p>
	<table><th>Property</th>
	<tr><td> #setimage</td></tr>
	<tr><td> #setframe</td></tr>
	<tr><td> #setangleoffset</td></tr>
	<tr><td> #setuniform</td></tr>
	<tr><td> #setsplatter</td></tr>
	<tr><td> #setangletype</td></tr>
	<tr><td> #setuseeffectemission</td></tr>
	<tr><td> #setsingleparticle</td></tr>
	<tr><td> #setrandomcolor</td></tr>
	<tr><td> #setzlayer</td></tr>
	<tr><td> #setanimate</td></tr>
	<tr><td> #setrandomstartframe</td></tr>
	<tr><td> #setanimationdirection</td></tr>
	<tr><td> #setcolorrepeat</td></tr>
	<tr><td> #setalpharepeat</td></tr>
	<tr><td> #setoneshot</td></tr>
	<tr><td> #sethandlecenter</td></tr>
	<tr><td> #setParticlesrelative</td></tr>
	<tr><td> #settweenspawns</td></tr>
	</table>
endrem
Type tlEmitter Extends tlEntity
	Field currentlife:Float									'the current life of the emitter as it will vary over time
	Field uniform:Int = True								'whether it scales uniformly
	Field parentEffect:tlEffect								'the effect it belongs to
	Field image:TAnimImage									'the sprite of the emitter
	Field frame:Int											'the frame of the sprite
	Field centerhandle:Int = True							'true if the handle of the sprite should be set to the middle
	Field handlecenter:Int									'Whether or not the particle's handle is in centered automatically
	Field angleoffset:Int					 				'angle variation and offset
	Field lockedangle:Int									'entity rotation is locked to the direction it's going
	Field gx:Float, gy:Float								'Grid Coords from grid spawning in an area
	Field counter:Float										'counter for the spawning of particles
	Field oldcounter:Float									'old counter value for tweening
	Field angletype:Int										'Set to either Align to motion, Random or Specify
	Field anglerelative:Int									'Whether the angle of the particles should be drawn relative to the parent
	Field useeffectemission:Int								'whether the emitter has it's own set of emission settings
	Field deleted:Int = False								'Whether it's been deleted and awaiting removal from emitter lsit
	Field visible:Int = True								'Whether this children particles will be drawn
	Field singleparticle:Int = False						'Whether the emitter spawns just a one-off particle, for glow children and blast waves etc.
	Field startedspawning:Int = False						'Whether any particles have been spawned yet
	Field spawned:Int										'count of how many particles spawned so far
	Field randomcolor:Int = False							'Whether or not the particle picks a colour at random from the gradient
	Field zlayer:Int = 0									'The z order that the emitter should be drawn in (1-8 layers)
	Field animate:Int = False								'Whether or not to use anly 1 frame of the animation
	Field randomstartframe:Int = False						'should the animation start from a random frame each spawn?
	Field animationdirection:Int = 1						'Play the animation backwards or forwards
	Field colorrepeat:Int									'Number of times the color sequence should be repeated over the particles lifetime
	Field alpharepeat:Int									'Number of times the alpha sequence should be repeated over the particles lifetime
	Field diralternater:Int									'can use this to alternate between travelling inwards and outwards.
	Field oneshot:Int										'a singleparticle that just fires once and dies
	Field particlesrelative:Int								'Whether or not the particles are relative
	Field tweenspawns:Int									'whether the emitter should tween spawning between old and current coords
	Field effects:TList = CreateList()						'list of sub effects added to each particle when they're spawned
	Field once:Int											'Whether the particles of this emitter should animate just the once
	Field path:String										'the path to the emitter for where in the effect hierarchy the emitter is
	Field dying:Int											'true if the emitter is in the process of dying ie, no longer spawning particles
	Field groupparticles:Int										'Set to true to add particles to one big pool, instead of the emitters own pool.
	
	'----All the lists for controlling the particle over time
	Field r:TList = CreateList()  							'Red
	Field g:TList = CreateList()  							'Green
	Field b:TList = CreateList()  							'Blue
	Field basespin:TList = CreateList() 					'base speed of spin
	Field spin:TList = CreateList() 						'spin speed
	Field spinvariation:TList = CreateList() 				'spin variation
	Field velocity:TList = CreateList()  					'speed overtime
	Field baseweight:TList = CreateList()  					'base weight of particle
	Field weight:TList = CreateList()  						'weight overtime
	Field weightvariation:TList = CreateList()    			'weight variation
	Field basespeed:TList = CreateList()      				'speed of it
	Field velvariation:TList = CreateList() 				'Velocity variation over time
	Field cvelvar:TList = CreateList()   					'current varinace of the velocity
	Field as:TList = CreateList() 							'how fast it accelerates to velocity
	Field alpha:TList = CreateList() 						'how visible it is
	Field sizex:TList = CreateList() 						'spawn size over time
	Field sizey:TList = CreateList() 						'spawnsize over time
	Field scalex:TList = CreateList() 						'size over time
	Field scaley:TList = CreateList()  						'size over time
	Field sizexvariation:TList = CreateList() 				'Size x variation
	Field sizeyvariation:TList = CreateList() 				'Size y variation
	Field lifevariation:TList = CreateList() 				'how much the lifetime varies
	Field life:TList = CreateList() 						'how long the particles last in frames
	Field amount:TList = CreateList() 						'the amount of particals per frame
	Field amountvariation:TList = CreateList()     			'the variable amount of particals per frame
	Field emissionangle:TList = CreateList()  				'direction of travel when the particle is spawned
	Field emissionrange:TList = CreateList()   				'range of direction
	Field globalvelocity:TList = CreateList()     			'children the velocity of all particles at any time in the children lifetime
	Field direction:TList = CreateList()       				'direction the particle is going over the life of the particle
	Field directionvariation:TList = CreateList()      		'direction variation
	Field directionvariationot:TList = CreateList()   		'direction variation overtime
	Field framerate:TList = CreateList()    				'the speed of the animation over time
	Field stretch:TList = CreateList()    					'amount the particle is stretched by the speed it's travelling
	Field splatter:TList = CreateList()						'this will randomise the distance where the particle spawns to it's point.
	
	'----Arrays for quick access to attribute values
	Field c_r:tlEmitterArray
	Field c_g:tlEmitterArray
	Field c_b:tlEmitterArray
	Field c_basespin:tlEmitterArray
	Field c_spin:tlEmitterArray
	Field c_spinvariation:tlEmitterArray
	Field c_velocity:tlEmitterArray
	Field c_baseweight:tlEmitterArray
	Field c_weight:tlEmitterArray
	Field c_weightvariation:tlEmitterArray
	Field c_basespeed:tlEmitterArray
	Field c_velvariation:tlEmitterArray
	Field c_cvelvar:tlEmitterArray
	Field c_as:tlEmitterArray
	Field c_alpha:tlEmitterArray
	Field c_sizex:tlEmitterArray
	Field c_sizey:tlEmitterArray
	Field c_scalex:tlEmitterArray
	Field c_scaley:tlEmitterArray
	Field c_sizexvariation:tlEmitterArray
	Field c_sizeyvariation:tlEmitterArray
	Field c_lifevariation:tlEmitterArray
	Field c_life:tlEmitterArray
	Field c_amount:tlEmitterArray
	Field c_amountvariation:tlEmitterArray
	Field c_emissionangle:tlEmitterArray
	Field c_emissionrange:tlEmitterArray
	Field c_globalvelocity:tlEmitterArray
	Field c_direction:tlEmitterArray
	Field c_directionvariation:tlEmitterArray
	Field c_directionvariationot:tlEmitterArray
	Field c_framerate:tlEmitterArray
	Field c_stretch:tlEmitterArray
	Field c_splatter:tlEmitterArray

	'Bypassers
	Field bypass_weight:Int
	Field bypass_speed:Int
	Field bypass_spin:Int
	Field bypass_directionvariation:Int
	Field bypass_colour:Int
	Field b_red:Int
	Field b_green:Int
	Field b_blue:Int
	Field bypass_scalex:Int
	Field bypass_scaley:Int
	Field bypass_lifevariaton:Int
	Field bypass_framerate:Int
	Field bypass_stretch:Int
	Field bypass_splatter:Int
	
	'Bounding Box Info
	Field AABB_ParticleMaxWidth:Float
	Field AABB_ParticleMaxHeight:Float
	Field AABB_ParticleMinWidth:Float
	Field AABB_ParticleMinHeight:Float
	
	Field current_lifevariation:Float
	Field current_weight:Float
	Field current_weightvariation:Float
	Field current_speed:Float
	Field current_speedvariation:Float
	Field current_spin:Float
	Field current_spinvariation:Float
	Field current_directionvariation:Float
	Field current_emissionangle:Float
	Field current_emissionrange:Float
	Field current_sizex:Float
	Field current_sizey:Float
	Field current_sizexvariation:Float
	Field current_sizeyvariation:Float
	Field current_framerate:Float
	
	Rem
	bbdoc: Sort all attribute lists
	about: Sorts all the graph nodes into the proper order for every emitter attribute
	endrem
	Method sortall()
		SortList(r)
		SortList(g)
		SortList(b)
		SortList(basespin)
		SortList(spin)
		SortList(spinvariation)
		SortList(velocity)
		SortList(basespeed)
		SortList(velvariation)
		SortList(cvelvar)
		SortList(as)
		SortList(alpha)
		SortList(sizex)
		SortList(sizey)
		SortList(scalex)
		SortList(scaley)
		SortList(sizexvariation)
		SortList(sizeyvariation)
		SortList(lifevariation)
		SortList(life)
		SortList(amount)
		SortList(amountvariation)
		SortList(emissionangle)
		SortList(emissionrange)
		SortList(framerate)
		SortList(stretch)
		SortList(globalvelocity)
	End Method
	Rem
	bbdoc:Show all Emitters
	about: Sets all emitters to visible so that they will be rendered. This also applies to any sub effects and their emitters.
	endrem
	Method showall()
		setvisible True
		For Local e:tlEffect = EachIn effects
			e.showall()
		Next
	End Method
	Rem
	bbdoc: Hide all Emitters
	about: Sets all emitters to hidden so that they will no longer be rendered. This also applies to any sub effects and their emitters.
	endrem
	Method hideall()
		setvisible False
		For Local e:tlEffect = EachIn effects
			e.hideall()
		Next
	End Method
	
	Rem
	bbdoc: Add a scale x attribute node
	returns: Emitter change object.
	about: <p>Pass the method a value between 0 and 1 representing the percentage of the lifetime of the particle (f) and the value (v)</p>
	<p>This is an <b>Overtime Attribute</b>, meaning it is a scaling factor for the equivalent <b>Base Attribute</b> - in this case <i>sizex</i>. This enables you to control the width of the 
	particle over its life time by scaling the sizex attribute. If uniform is set to true then this also controls the height of teh particle aswell</p>
	<p>So for example, if you pass addscalex(0.5,2), this will tell the particle to be twice it's base width (sizex) halfway through its life.</p>
	endrem
	Method addscalex:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		scalex.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a scale y attribute node
	returns: Emitter change object.
	about: <p>Pass the method a value between 0 and 1 representing the percentage of the lifetime of the particle (f) and the value (v)</p>
	<p>This is an <b>Overtime Attribute</b>, meaning it is a scaling factor for the equivalent <b>Base Attribute</b> - in this case <i>sizex</i>. This enables you to control the width of the 
	particle over its life time by scaling the sizex attribute. If <i>uniform</i> is set to true then this attribute is ignored and only scalex is used</p>
	<p>So for example, if you pass addscaley(0.5,2), this will tell the particle to be twice it's base height (sizey) halfway through its life.</p>
	endrem
	Method addscaley:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		scaley.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a Size x attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p> This is a <b>Base Attribute</b> for setting the base width of the particles.This value is Then scaled using the <b>Overtime Attribute</b> %Scalex.
	If %uniform is true then this attribute also sets the base height.</p>
	endrem
	Method addsizex:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		sizex.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a Size y attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p> This is a <b>Base Attribute</b> for setting the base height of the particles. This value is then scaled using the <b>Overtime Attribute</b> %Scaley.
	If %uniform is true then this attribute is ignored.</p>
	endrem
	Method addsizey:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		sizey.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a Size x variation attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This is a <b>Variation Attribute</b> for effecting how much the base sizex attribute varies. So if sizex is 100, and the sizexvariation is 50 then
	the base particle width can cary from 100-150.</p>
	endrem
	Method addsizexvariation:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		sizexvariation.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a Size y variation attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This is a <b>Variation Attribute</b> for effecting how much the base sizey attribute varies. So if sizey is 100, and the sizeyvariation is 50 then
	the base particle height can vary from 100-150. This attribute is ignores if %uniform is true.</p>
	endrem
	Method addsizeyvariation:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		sizeyvariation.AddLast e
		Return e
	End Method
	Rem
		bbdoc: Add a Base Speed attribute node
		returns: Emitter change object.
		about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
		<p>This is a <b>Base Attribute</b> for setting the base speed of the particle. Speed is then scaled over the lifetime of the particle using the 
		<b>Overtime Attribute</b> Velocity</p>
	endrem
	Method addbasespeed:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		basespeed.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a Velocity attribute node
	returns: Emitter change object.
	about: <p>Pass the method a value between 0 and 1 representing the percentage of the lifetime of the particle (f) and the value (v)</p>
	<p>This is an <b>Overtime Attribute</b> for scaling the base speed of the particle. For example if you wanted a particle to start off travelling fast
	and slow down to a stop over the course of its life time you would add the following attribute values:</p>
	&{
	addbasespeed(0,200)
	addvelocity(0,1)
	addvelocity(1,0)
	}
	<p>This would mean that the particle starts out travelling at 200 pixels per second which reduces to 0 over the particles lifetime.</p>
	endrem
	Method addvelocity:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		velocity.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a Base weight attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This is a <b>Base Attribute</b> for setting the base weight of the particle. weight is then scaled over the lifetime of the particle using the 
	<b>Overtime Attribute</b> weight</p>
	endrem
	Method addbaseweight:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		baseweight.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a weight variation attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This is a <b>Variation Attribute</b> for effecting how much the base weight attribute varies. So if weight is 20, and the weightvariation is 10 then
	the base particle width can cary from 10-30.</p>
	endrem
	Method addweightvariation:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		weightvariation.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a weight attribute node
	returns: Emitter change object.
	about: <p>Pass the method a value between 0 and 1 representing the percentage of the lifetime of the particle (f) and the value (v)</p>
	<p>This is an <b>Overtime Attribute</b> for scaling the base weight of the particle.
	endrem
	Method addweight:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		weight.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a velocity variation attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This is a <b>Variation Attribute</b> for effecting how much the base speed attribute varies. So if basespeed is 100, and the velvariation is 50 then
	the base particle speed can vary from 50-150 pixels per second.</p>
	endrem
	Method addvelvariation:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		velvariation.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Currently unused, will probably be deleted at some point
	endrem
	Method addas:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		as.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add an alpha attribute node
	returns: Emitter change object.
	about: <p>Pass the method a value between 0 and 1 representing the percentage of the lifetime of the particle (f) and the value (v)</p>
	<p>This is an <b>Overtime Attribute</b> for adjust the visibility of the particle over its lifetime where 1 is opaque and 0 is transparent.
	endrem
	Method addalpha:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		alpha.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a spin attribute node
	returns: Emitter change object.
	about: <p>Pass the method a value between 0 and 1 representing the percentage of the lifetime of the particle (f) and the value (v)</p>
	<p>This is an <b>Overtime Attribute</b> for scaling the base spin of the particle.
	endrem
	Method addspin:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		spin.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a Base spin attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This is a <b>Base Attribute</b> for setting the base spin of the particle which effects the speed of rotation of the particle. You can also 
	effect the direction that the particle spins by using values less then 0. Spin is then scaled over the lifetime of the particle using the 
	<b>Overtime Attribute</b> spin</p>
	endrem
	Method addbasespin:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		basespin.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a spin variation attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This is a <b>Variation Attribute</b> for effecting how much the base spin attribute varies. So if basespin is 50, and the spinvariation is 25 then
	the base particle spin can vary from 25-75 degrees per second.</p>
	endrem
	Method addspinvariation:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		spinvariation.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a Colour Red attribute node
	returns: Emitter change object.
	about: <p>Pass the method a value between 0 and 1 representing the percentage of the lifetime of the particle (f) and the value (v)</p>
	<p>This is an <b>Overtime Attribute</b> for effecting the red colour channel of the particle. Values can range from 0 to 255.
	endrem
	Method addr:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		r.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a Colour Green attribute node
	returns: Emitter change object.
	about: <p>Pass the method a value between 0 and 1 representing the percentage of the lifetime of the particle (f) and the value (v)</p>
	<p>This is an <b>Overtime Attribute</b> for effecting the Green colour channel of the particle. Values can range from 0 to 255.
	endrem
	Method addg:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		g.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a Colour Blue attribute node
	returns: Emitter change object.
	about: <p>Pass the method a value between 0 and 1 representing the percentage of the lifetime of the particle (f) and the value (v)</p>
	<p>This is an <b>Overtime Attribute</b> for effecting the Blue colour channel of the particle. Values can range from 0 to 255.
	endrem
	Method addb:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		b.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a life variation attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This is a <b>Variation Attribute</b> for varying how long the particle lives for. So if life is 5000, and the lifevariation is 1000 then
	the life can vary from 4000-6000 milliseconds.</p>
	endrem
	Method addlifevariation:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.VALUE = v
		lifevariation.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a Base life attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This is a <b>Base Attribute</b> for setting how long the particle lives for in milliseconds.</p>
	endrem
	Method addlife:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		life.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a Base amount attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This is a <b>Base Attribute</b> for setting how many particles are spawned per second by the emitter.</p>
	endrem
	Method addamount:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		amount.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add an amount variation attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This is a <b>Variation Attribute</b> for varying how many particles are spawned per second by the emitter. So if amount is 50, 
	and the amountvariation is 10 then the amount spawned can vary from 50-60.</p>
	endrem
	Method addamountvariation:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		amountvariation.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add an emission angle attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This attribute controls the direction newly spawned particles travel in but only if %useeffectemission is false.</p>
	endrem
	Method addemissionangle:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		emissionangle.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add an emission range attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This attribute controls the random range newly spawned particles travel in but only if %useeffectemission is false. So if the emission range is 
	45 degrees and the emission angle is 0 then the range can vary from -45 to 45 degrees (or 315-45 degrees). emission range can be passed any value from 0-180</p>
	endrem
	Method addemissionrange:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		emissionrange.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a global velocity attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This attribute effects all particles currently in existance that the emitter has spawned. It will instantly scale the velocity of all particles essentially
	controlling their speed globally.</p>
	endrem
	Method addglobalvelocity:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		globalvelocity.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a direction attribute node
	returns: Emitter change object.
	about: <p>Pass the method a value between 0 and 1 representing the percentage of the lifetime of the particle (f) and the value (v)</p>
	<p>This is an <b>Overtime Attribute</b> for effecting the direction the particle travels in over the lifetime of the particle.
	endrem
	Method adddirection:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		direction.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a direction variation attribute node
	returns: Emitter change object.
	about: <p>Pass the method the time in millisecs (f) and the value (v)</p>
	<p>This is a <b>Variation Attribute</b> for giving particles a degree of motion randomness. This value is further scaled by %directionvariationot</p>
	endrem
	Method adddirectionvariation:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		directionvariation.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a direction variaiton overtime attribute node
	returns: Emitter change object.
	about: <p>Pass the method a value between 0 and 1 representing the percentage of the lifetime of the particle (f) and the value (v)</p>
	<p>This is an <b>Overtime Attribute</b> scaling the direction variation over the lifetime of the particle. This gives the particle a motion randomness effecting
	its direction and speed at vary degrees of variation.</p>
	endrem
	Method adddirectionvariationot:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		directionvariationot.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a framerate overtime attribute node
	returns: Emitter change object.
	about: <p>Pass the method a value between 0 and 1 representing the percentage of the lifetime of the particle (f) and the value (v)</p>
	<p>This is an <b>Overtime Attribute</b> for controlling the framerate of particles that have more then one frame of animation. This attribute is only relevant
	if %animate is true.</p>
	endrem
	Method addframerate:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		framerate.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a stretch overtime attribute node
	returns: Emitter change object.
	about: <p>Pass the method a value between 0 and 1 representing the percentage of the lifetime of the particle (f) and the value (v)</p>
	<p>This is an <b>Overtime Attribute</b> for controlling how much the particle stretches depending on the speed it is travelling.</p>
	endrem
	Method addstretch:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		stretch.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add a splatter overtime attribute node
	returns: Emitter change object.
	about: <p>Pass the time in milliseconds (f) and the value (v)</p>
	<p>This will control how close to the point the particle will spawn. Higher values mean the particle will appear randomnly around the point of spawning.</p>
	endrem
	Method addsplatter:tlAttributeNode(f:Float, v:Float)
		Local e:tlAttributeNode = New tlAttributeNode
		e.frame = f
		e.value = v
		splatter.AddLast e
		Return e
	End Method
	Rem
	bbdoc: Add an effect to the emitters list of effects.
	about: Effects that are in the effects list are basically sub effects that are added to any particles that this emitter spawns which in turn should
	contain their own emitters that spawn more particles and so on.</p>
	endrem
	Method addeffect(e:tlEffect)
		effects.AddLast(e)
	End Method
	
	Rem
	bbdoc: Set Parent Effect
	about: Assigns the effect that is the parent to this emitter
	endrem
	Method setparentEffect(v:tlEffect)
		parentEffect = v
	End Method
	Rem
	bbdoc: Set image
	about: When Particles are spawned this image is the image that is assigned to them. Not a tImage but a tAnimImage, a custom image type written
	by indiepath.
	endrem
	Method setimage(v:TAnimImage)
		image = v
		AABB_ParticleMaxWidth = image.width *.5
		AABB_ParticleMaxHeight = image.height *.5
		AABB_ParticleMinWidth = image.width * -.5
		AABB_ParticleMinHeight = image.height * -.5
	End Method
	Rem
	bbdoc: Set the image frame
	about: If the image has more then one frame then setting this can determine which frame the particle uses to draw itself.
	endrem
	Method setframe(v:Int)
		frame = v
	End Method
	Rem
	bbdoc: Set the angle offset or variation
	about: Depending on the value of %angletype (tlANGLE_ALIGN, tlANGLE_RANDOM or tlANGLE_SPECIFY), this will either set the angle offset of the particle in the 
	case of tlANGLE_ALIGN and tlANGLE_SPECIFY, or act as the range of degrees for tlANGLE_RANDOM.
	endrem
	Method setangleoffset(v:Int)
		angleoffset = v
	End Method
	Rem
	bbdoc: Set Uniform
	about: Dictates whether the particles size scales uniformally. Set to either TRUE or FALSE.
	endrem
	Method setuniform(v:Int)
		uniform = v
	End Method
	Rem
	bbdoc: Set the angle type
	about:<p>Angle type tells the particle how it show orientate itself when spawning. Either tlANGLE_ALIGN, tlANGLE_RANDOM or tlANGLE_SPECIFY.</p>
	<p> @tlANGLE_ALIGN: Force the particle to align itself with the direction that it's travelling in.<br/>
	@tlANGLE_RANDOM: Choose a random angle.<br/>
	@tlANGLE_SPECIFY: Specify the angle that the particle spawns with.</p>
	<p>Use %angleoffset to control the either both the specific angle, random range of angles and an offset if aligning.</p>
	endrem
	Method setangletype(v:Int)
		angletype = v
	End Method
	Rem
	bbdoc: Set Use effect emission
	about: Set to TRUE by default, this tells the emitter to take the emission range and emission angle attributes from the parent effect, otherwise if set to FALSE it
	will take the values from the emitters own emission attributes.
	endrem
	Method setuseeffectemission(v:Int)
		useeffectemission = v
	End Method
	Rem
	bbdoc: Set to FALSE to stop drawing the particles this emitter spawns
	endrem
	Method setvisible(v:Int)
		visible = v
	End Method
	Rem
	bbdoc: Set Single Particle
	about: You can have particles that do not age and will only be spawned once for point emitters, or just for one frame with area, line and ellipse emitters.
	Single particles will remain until they are destroyed and will one behave according the values stored in the first temmiterchange nodes - in otherwords they
	will not change at all over time.
	endrem
	Method setsingleparticle(v:Int)
		singleparticle = v
	End Method
	Rem
	bbdoc: Sets whether the particle chooses random colour from the colour attributes
	endrem
	Method setrandomcolor(v:Int)
		randomcolor = v
	End Method
	Rem
	bbdoc: Set the z layer
	about: Emitters can be set to draw on different layers depending on what kind of effect you need. By default everything is drawn on layer 0, higher layers
	makes those particles spawned by that emitter drawn on top of emitters below them in layers. The layer value can range from 0-8 giving a total of 9 layers.
	endrem
	Method setzlayer(v:Int)
		zlayer = v
	End Method
	Rem
	bbdoc: Set whether the particle should animate
	about: Only applies if the particle's image has more then one frame of animation.
	endrem
	Method setanimate(v:Int)
		animate = v
	End Method
	Rem
	bbdoc: Set the particles to spawn with a random frame
	about: Only applies if the particle has more then one frame of animation
	endrem
	Method setrandomstartframe(v:Int)
		randomstartframe = v
	End Method
	Rem
	bbdoc: Set the direction the animation plays in
	about: Set to 1 for forwards playback and set to -1 for reverse playback of the image aniamtion
	endrem
	Method setanimationdirection(v:Int)
		animationdirection = v
	End Method
	Rem
	bbdoc: Set to the number of times the colour should cycle within the particle lifetime
	about: Timeline Particles editor allows values from 1 to 10. 1 is the default.
	endrem
	Method setcolorrepeat(v:Int)
		colorrepeat = v
	End Method
	Rem
	bbdoc: Set to the number of times the alpha of the particle should cycle within the particle lifetime.
	about: Timeline Particles editor allows values from 1 to 10. 1 is the default.
	endrem
	Method setalpharepeat(v:Int)
		alpharepeat = v
	End Method
	Rem
	bbdoc: Make a particle a one shot particle or not.
	about: Emitters that have this set to true will only spawn one particle and that particle will just play out once and die. The is only relevant if
	%singleparticle is also set to true.
	endrem
	Method setoneshot(v:Int)
		oneshot = v
	End Method
	Rem
	bbdoc: Set the handle of the particle to its center
	about: Set to TRUE for the hande to be placed automatically at the center of the particle, or FALSE for the handle to be dictated by %handlex and %handley.
	endrem
	Method sethandlecenter(v:Int)
		handlecenter = v
	End Method
	Rem
	bbdoc: Set wheter the particles and emitter remain relative to the effect.
	about: Emitters that are relative spawn particles that move and rotate with the effect they're contained in.
	endrem
	Method setParticlesrelative(v:Int)
		particlesrelative = v
	End Method
	Rem
	bbdoc: Set to TRUE for particles to spawn imbetween th effects old and new coordinates.
	about: This creates better spawning behaviour especially for smoke trails.
	endrem
	Method settweenspawns(v:Int)
		tweenspawns = v
	End Method
	Rem
	bbdoc: Set to TRUE to make th particles spawned have their angle of rotation locked to direction
	endrem
	Method setlockangle(v:Int)
		lockedangle = v
	End Method
	Rem
	bbdoc: Set to TRUE to make th particles spawned have their angle of rotation relative to the parent effect
	endrem
	Method setanglerelative(v:Int)
		anglerelative = v
	End Method
	Rem
	bbdoc: Set to TRUE to make the particles spawned playback the animation just once 
	endrem
	Method setonce(v:Int)
		once = v
	End Method
	Rem
	bbdoc: Sets the current state of whether spawned particles are added to the particle managers pool, or the emitters own pool. True means that
			they're grouped together under each emitter
	endrem
	Method SetGroupParticles(v:Int)
		groupparticles = v
	End Method
	Rem
	bbdoc: Get the current parent effect
	returns: tlEffect
	endrem
	Method getparentEffect:tlEffect()
		Return parentEffect
	End Method
	Rem
	bbdoc: Get the tAnimImage currently used by the emitter
	returns: tAnimimage
	endrem
	Method getimage:TAnimImage()
		Return image
	End Method
	Rem
	bbdoc: Get the animation frame of the tAnimImage used by the emitter
	endrem
	Method getframe:Int()
		Return frame
	End Method
	Rem
	bbdoc: Get the current angle offset used by %angletype (see #setangletype)
	endrem
	Method getangleoffset:Int()
		Return angleoffset
	End Method
	Rem
	bbdoc: Get whether the particles spawned by this emitter scale uniformally
	returns: TRUE or FALSE
	endrem
	Method getuniform:Int()
		Return uniform
	End Method
	Rem
	bbdoc: Get the current angletype for particles spawned by this emitter
	returns: either tlANGLE_ALIGN, tlANGLE_RANDOM or tlANGLE_SPECIFY
	endrem
	Method getangletype:Int()
		Return angletype
	End Method
	Rem
	bbdoc: Get whether the emitter uses the effect emission instead of its own
	returns: either TRUE or FALSE
	endrem
	Method getuseeffectemission:Int()
		Return useeffectemission
	End Method
	Rem
	bbdoc: Get the visibility status of the emitter
	returns: either TRUE or FALSE
	endrem
	Method getvisible:Int()
		Return visible
	End Method
	Rem
	bbdoc: Find out if the emitter spawns a single particle
	returns: Either TRUE or FALSE
	endrem
	Method getsingleparticle:Int()
		Return singleparticle
	End Method
	Rem
	bbdoc: Get whether the emitter chooses a random colour for the particles it spawns
	returns: Either TRUE or FALSE
	endrem
	Method getrandomcolor:Int()
		Return randomcolor
	End Method
	Rem
	bbdoc: Get the current z layer of the emitter
	returns: Value from 0 - 8
	endrem
	Method getzlayer:Int()
		Return zlayer
	End Method
	Rem
	bbdoc: Get whether this emitter spawns particles that animate
	returns: Either TRUE or FALSE
	endrem
	Method getanimate:Int()
		Return animate
	End Method
	Rem
	bbdoc: Get whether the emitter chooses a random start frame for the particles it spawns
	returns: Either TRUE or FALSE
	endrem
	Method getrandomstartframe:Int()
		Return randomstartframe
	End Method
	Rem
	bbdoc: Get the current animation direction
	returns: Either -1 for reverse playback or 1 for normal playback for particles spawned by this emitter.
	endrem
	Method getanimationdirection:Int()
		Return animationdirection
	End Method
	Rem
	bbdoc: Get the number of times the colour cycles over the lifetime of the particles spawned by this emitter.
	endrem
	Method getcolorrepeat:Int()
		Return colorrepeat
	End Method
	Rem
	bbdoc: Get the number of times the alpha cycles over the lifetime of the particles spawned by this emitter.
	endrem
	Method getalpharepeat:Int()
		Return alpharepeat
	End Method
	Rem
	bbdoc: Get whether this emitter spawns a one shot particle (see #setoneshot)
	returns: either TRUE or FALSE
	endrem
	Method getoneshot:Int()
		Return oneshot
	End Method
	Rem
	bbdoc: Get whether the handle of the particles spawned by this emitter are set to the center.
	returns: Either TRUE or FALSE
	endrem
	Method gethandlecenter:Int()
		Return handlecenter
	End Method
	Rem
	bbdoc: Get whether the particles spawned by this emitter remain relative to the containg effect
	returns: Either TRUE or FALSE
	endrem
	Method getParticlesrelative:Int()
		Return particlesrelative
	End Method
	Rem
	bbdoc: Get whether particles are being spawned from the old effect coordinates to the new.
	returns: Either TRUE or FALSE
	endrem
	Method gettweenspawns:Int()
		Return tweenspawns
	End Method
	Rem
	bbdoc: Get whether particles spawned are having their angles locked to direction
	returns: Either TRUE or FALSE
	endrem
	Method getlockangle:Int()
		Return lockedangle
	End Method
	Rem
	bbdoc: Get whether particles spawned will have there angle relative to the parent
	returns: Either TRUE or FALSE
	endrem
	Method getanglerelative:Int()
		Return anglerelative
	End Method
	Rem
	bbdoc: Returns the current state of whether spawned particles playback the animation just once
	endrem
	Method getonce:Int()
		Return once
	End Method
	Rem
	bbdoc: Returns the current state of whether spawned particles are added to the particle managers pool, or the emitters own pool. True means that
			they're added to the particle managers pool.
	endrem
	Method getgroupparticles:Int()
		Return groupparticles
	End Method
	Rem
	bbdoc: Get the path of the entity
	about: the path will be the address of where the entity is within the hierarchy of parent and child entities
	endrem
	Method getpath:String()
		Return path
	End Method
	Rem
		bbdoc:Set the Radius Calculate value for this tlEntity object.
		about: This overides the tlentity method so that the effects list can be updated too
	End Rem
	Method SetRadiusCalculate(Value:Int)
		Radius_Calculate = VALUE
		For Local e:tlEntity = EachIn children
			e.SetRadiusCalculate(Value)
		Next
		For Local e:tlEffect = EachIn effects
			e.SetRadiusCalculate(VALUE)
		Next
	End Method
	
	Method destroy()
		parenteffect = Null
		image = Null
		For Local e:tlEffect = EachIn effects
			e.destroy()
		Next
		Super.Destroy()
	End Method
	Rem
		bbdoc: Change the dob of the emitter. dob being date of birth, or time it was created.
		about: This will also change the dob of any effects the emitter contains. This is more of an internal method used by
		the tlParticleManager method #AddPreLoadedEffect
	end rem
	Method ChangeDob(_DoB:Float)
		dob = _DoB
		For Local e:tlEffect = EachIn effects
			e.ChangeDob(_DoB)
		Next
	End Method
	Rem
	bbdoc: Update the emitter
	about: This is an internal method called by the parent effect when updating each frame. This method will update its position and spawn new particles
	depending on whatever settings the emitter has by calling #updatespawns
	endrem
	Method update()
	
		capture()
		
		matrix.set(Cos(angle), Sin(angle), -Sin(angle), Cos(angle))
		
		If parent And relative
			setz(parent.z)
			matrix = matrix.transform(parent.matrix)
			rotvec:tlVector2 = parent.matrix.transformvector(New tlVector2.Create(x, y))
			If z <> 1
				wx = parent.wx + rotvec.x * z
				wy = parent.wy + rotvec.y * z
			Else
				wx = parent.wx + rotvec.x
				wy = parent.wy + rotvec.y
			End If
			relativeangle = parent.relativeangle + angle
		Else
			wx = x
			wy = y
		End If
		
		If Not tweenspawns
			capture()
			tweenspawns = True
		End If
		
		dying = parenteffect.dying
		
		Super.UpdateBoundingBox()
		
		If radius_calculate
			Super.UpdateEntityRadius()
		End If
		
		updatechildren()
				
		If Not dead And Not dying
			If visible And parentEffect.PM.spawningallowed
				updatespawns()
			End If
		Else
			If Not childcount
				parent.removechild(Self)
				destroy()
			Else
				killchildren()
			End If
		End If
				
	End Method
	Rem
	bbdoc: Updates all the particles this emitter has spawned
	about: This method is called by #update each frame.
	endrem
	Method updatechildren()
		For Local p:tlParticle = EachIn children
			p.update()
		Next
	End Method
	Rem
	bbdoc: Spawns a new lot of particles if necessary and assign all properties and attributes to the particle.
	about: This method is called by #update each frame.
	endrem
	Method updatespawns(esingle:tlParticle = Null)
	
		'spawn some particles
		
		Local tween:Float
		
		Local tx:Float
		Local ty:Float
		Local sizetemp:Float
		Local intcounter:Int
		Local e:tlParticle
				
		Local rotvec:tlVector2
		Local cellsizew:Float
		Local cellsizeh:Float
		Local th:Float
		Local er:Float
		Local dv:Float
		Local randomage:Int
		Local scaletemp:Float
		Local splattertemp:Float
		Local splatx:Float
		Local splaty:Float
		
		Local qty:Float
		
		Select parenteffect.PM.updatemode
			Case tlUPDATE_MODE_COMPILED
				qty = ((get_amount(parentEffect.currentframe) + Rnd(get_amountvariation(parentEffect.currentframe))) * parentEffect.currentamount * parenteffect.PM.globalamountscale) / tp_CURRENT_UPDATE_TIME
				If Not singleparticle
					counter:+qty
				End If
				intcounter = counter
				If intcounter >= 1 Or (singleparticle And Not startedspawning)
					If Not startedspawning And singleparticle
						Select parentEffect.class
							Case tlPOINT_EFFECT
								intcounter = 1
							Case tlAREA_EFFECT
								intcounter = parentEffect.mgx * parentEffect.mgy
							Case tlLINE_EFFECT, tlELLIPSE_EFFECT
								intcounter = parentEffect.mgx
						End Select
					ElseIf singleparticle And startedspawning
						intcounter = 0
					End If
					'Preload Attributes----
					currentlife = get_life(parentEffect.currentframe) * parentEffect.currentlife
					If Not bypass_weight
						current_weight = get_baseweight(parentEffect.currentframe)
						current_weightvariation = get_weightvariation(parentEffect.currentframe)
					End If
					If Not bypass_speed
						current_speed = get_basespeed(parentEffect.currentframe)
						current_speedvariation = get_velvariation(parentEffect.currentframe)
					End If
					If Not bypass_spin
						current_spin = get_basespin(parenteffect.currentframe)
						current_spinvariation = get_spinvariation(parentEffect.currentframe)
					End If
					current_directionvariation = get_directionvariation(parentEffect.currentframe)
					If useeffectemission
						er = parentEffect.currentemissionrange
						current_emissionangle = parentEffect.currentemissionangle
					Else
						er = get_emissionrange(parentEffect.currentframe)
						current_emissionangle = get_emissionangle(parentEffect.currentframe)
					End If
					current_lifevariation = get_lifevariation(parentEffect.currentframe)
					current_sizex = get_sizex(parentEffect.currentframe)
					current_sizey = get_sizey(parentEffect.currentframe)
					current_sizexvariation = get_sizexvariation(parentEffect.currentframe)
					current_sizeyvariation = get_sizeyvariation(parentEffect.currentframe)
					'----------------------
					For Local c:Float = 1 To intcounter
						startedspawning = True
						If Not parentEffect.PM Throw "No Partical Manager assigned to effect"
						If Not esingle
							e = parentEffect.PM.GrabParticle(parenteffect, groupparticles, zlayer)
						Else
							e = esingle
						End If
						If e
							?Debug
							tlParticlesCreated:+1
							?
							'-----Link to it's emitter and assign the control source (which is this emitter)----
							e.emitter = Self
							e.parent = Self
							e.PM = parentEffect.PM
							e.effectlayer = parentEffect.effectlayer
							'-------------------------------
							e.dob = e.PM.CURRENT_TIME
							If parentEffect.traverseedge And parentEffect.class = tlLINE_EFFECT
								particlesrelative = True
							End If
							e.relative = particlesrelative
							Select parentEffect.class
								Case tlPOINT_EFFECT
									If e.relative
										e.x = 0 - parentEffect.handlex
										e.y = 0 - parentEffect.handley
									Else
										tween = c / intcounter
										If parenteffect.handlecenter Or parentEffect.handlex + parentEffect.handley = 0
											tween = c / intcounter
											e.x = TweenValues(oldwx, wx, tween)
											e.y = TweenValues(oldwy, wy, tween)
											If z <> 1
												e.wx = e.x - parentEffect.handlex * z
												e.wy = e.y - parentEffect.handley * z
											Else
												e.wx = e.x - parentEffect.handlex
												e.wy = e.y - parentEffect.handley
											End If
										Else
											e.x = 0 - parentEffect.handlex
											e.y = 0 - parentEffect.handley
											rotvec = parent.matrix.transformvector(New tlVector2.Create(e.x, e.y))
											e.x = TweenValues(oldwx, wx, tween) + rotvec.x
											e.y = TweenValues(oldwy, wy, tween) + rotvec.y
											If z <> 1
												e.wx = e.x * z
												e.wy = e.y * z
											Else
												e.wx = e.x
												e.wy = e.y
											End If
										End If
									End If
								Case tlAREA_EFFECT
									If parentEffect.emitatpoints
										If parentEffect.spawndirection = -1
											gx:+parentEffect.spawndirection
											If gx < 0
												gx = parentEffect.mgx - 1
												gy:+parentEffect.spawndirection
												If gy < 0
													gy = parentEffect.mgy - 1
												End If
											End If
										End If
										If parentEffect.mgx > 1
											e.x = (gx / (parentEffect.mgx - 1) * parentEffect.currentwidth) - parentEffect.handlex
										Else
											e.x = -parentEffect.handlex
										End If
										If parentEffect.mgy > 1
											e.y = (gy / (parentEffect.mgy - 1) * parentEffect.currentheight) - parentEffect.handley
										Else
											e.y = -parentEffect.handley
										End If
										If parentEffect.spawndirection = 1
											gx:+parentEffect.spawndirection
											If gx >= parentEffect.mgx
												gx = 0
												gy:+parentEffect.spawndirection
												If gy >= parentEffect.mgy
													gy = 0
												End If
											End If
										End If
									Else
										e.x = Rnd(parentEffect.currentwidth) - parentEffect.handlex
										e.y = Rnd(parentEffect.currentheight) - parentEffect.handley
									End If
									If Not e.relative
										rotvec = parent.matrix.transformvector(New tlVector2.Create(e.x, e.y))
										If z <> 1
											e.x = parent.wx + rotvec.x * z
											e.y = parent.wy + rotvec.y * z
										Else
											e.x = parent.wx + rotvec.x
											e.y = parent.wy + rotvec.y
										End If
									End If
								Case tlELLIPSE_EFFECT
									If parentEffect.emitatpoints
										
										cellsizew = parentEffect.currentwidth / 2
										cellsizeh = parentEffect.currentheight / 2
										
										If (parentEffect.mgx = 0)
											parentEffect.mgx = 1
										End If
									
										tx = cellsizew
										ty = cellsizeh
		
										gx:+parentEffect.spawndirection
										If gx >= parentEffect.mgx
											gx = 0
										ElseIf gx < 0
											gx = parentEffect.mgx - 1
										End If
									
										th = gx * (parenteffect.ellipsearc / parentEffect.mgx) + parenteffect.ellipseoffset
										
										e.x = Cos(th) * tx - parentEffect.handlex + tx
										e.y = -Sin(th) * ty - parentEffect.handley + ty

									Else
										tx = parentEffect.currentwidth / 2
										ty = parentEffect.currentheight / 2
									
										th = Rnd(parenteffect.ellipsearc) + parenteffect.ellipseoffset
										
										e.x = Cos(th) * tx - parentEffect.handlex + tx
										e.y = -Sin(th) * ty - parentEffect.handley + ty
									End If
									If Not e.relative
										rotvec = parent.matrix.transformvector(New tlVector2.Create(e.x, e.y))
										If z <> 1
											e.x = parent.wx + rotvec.x * z
											e.y = parent.wy + rotvec.y * z
										Else
											e.x = parent.wx + rotvec.x 
											e.y = parent.wy + rotvec.y
										End If
									End If
								Case tlLINE_EFFECT
									If Not parentEffect.traverseedge
										If parentEffect.emitatpoints
											If parentEffect.spawndirection = -1
												gx:+parentEffect.spawndirection
												If gx < 0
													gx = parentEffect.mgx - 1
												End If
											End If
											If parentEffect.mgx > 1
												e.x = (gx / (parentEffect.mgx - 1) * parentEffect.currentwidth) - parentEffect.handlex
											Else
												e.x = -parentEffect.handlex
											End If
											e.y = -parentEffect.handley
											If parentEffect.spawndirection = 1
												gx:+parentEffect.spawndirection
												If gx >= parentEffect.mgx
													gx = 0
												End If
											End If
										Else
											e.x = Rnd(parentEffect.currentwidth) - parentEffect.handlex
											e.y = -parentEffect.handley
										End If
									Else
										If parentEffect.distancesetbylife
											e.x = -parentEffect.handlex
											e.y = -parentEffect.handley
										Else
											If parentEffect.emitatpoints
												If parentEffect.spawndirection = -1
													gx:+parentEffect.spawndirection
													If gx < 0
														gx = parentEffect.mgx - 1
													End If
												End If
												If parentEffect.mgx > 1
													e.x = (gx / (parentEffect.mgx - 1) * parentEffect.currentwidth) - parentEffect.handlex
												Else
													e.x = -parentEffect.handlex
												End If
												e.y = -parentEffect.handley
												If parentEffect.spawndirection = 1
													gx:+parentEffect.spawndirection
													If gx >= parentEffect.mgx
														gx = 0
													End If
												End If
											Else
												e.x = Rnd(parentEffect.currentwidth) - parentEffect.handlex
												e.y = -parentEffect.handley
											End If
										End If
									End If
									'rotate
									If Not e.relative
										rotvec = parent.matrix.transformvector(New tlVector2.Create(e.x, e.y))
										If z <> 1
											e.x = parent.wx + rotvec.x * z
											e.y = parent.wy + rotvec.y * z
										Else
											e.x = parent.wx + rotvec.x 
											e.y = parent.wy + rotvec.y
										End If
									End If
							End Select
							'Set the zoom level
							e.setz(z)
							'-----Set up the image----------
							e.avatar = image
							e.handlex = handlex
							e.handley = handley
							e.autocenter = handlecenter
							'-------------------------------
							'-----Set lifetime properties---
							e.lifetime = currentlife + Rnd(-current_lifevariation, current_lifevariation) * parentEffect.currentlife
							'-------------------------------
							'-----Speed---------------------
							e.speedvec.x = 0
							e.speedvec.y = 0
							If Not bypass_speed
								e.speed = c_velocity.changes[0]
								e.velvariation = Rnd(-current_speedvariation, current_speedvariation)
								e.basespeed = (current_speed + e.velvariation) * parentEffect.currentvelocity
								e.velseed = Rnd(0, 1.0)
								e.speed = c_velocity.changes[0] * e.basespeed * c_globalvelocity.changes[0]
							Else
								e.speed = 0
							End If
							'--------------------------------
							'-----Size----------------------
							e.gsizex = parentEffect.currentsizex
							e.gsizey = parentEffect.currentsizey
							If uniform
								scaletemp = c_scalex.changes[0]
								e.scalevariationx = Rnd(current_sizexvariation)
								e.width = e.scalevariationx + current_sizex
								If scaletemp
									sizetemp = (e.width / image.width) * scaletemp * e.gsizex
								Else
									sizetemp = 0
								End If
								e.scalex = sizetemp
								e.scaley = sizetemp
								If Not bypass_stretch
									e.scaley = (c_scalex.changes[0] * e.gsizex * (e.width + (Abs(e.speed) * c_stretch.changes[0] * parenteffect.currentstretch))) / image.width
									If e.scaley < e.scalex e.scaley = e.scalex
								End If
								e.AABB_MaxWidth = AABB_ParticleMaxWidth
								e.AABB_MinWidth = AABB_ParticleMinWidth
								e.AABB_MaxHeight = e.AABB_MaxWidth
								e.AABB_MinHeight = e.AABB_MinWidth
							Else
								'width
								scaletemp = c_scalex.changes[0]
								e.scalevariationx = Rnd(current_sizexvariation)
								e.width = e.scalevariationx + current_sizex
								If scaletemp
									sizetemp = (e.width / image.width) * scaletemp * e.gsizex
								Else
									sizetemp = 0
								End If
								e.scalex = sizetemp
								'height
								scaletemp = c_scaley.changes[0]
								e.scalevariationy = Rnd(current_sizeyvariation)
								e.height = e.scalevariationy + current_sizey
								If scaletemp
									sizetemp = (e.height / image.height) * scaletemp * e.gsizey
								Else
									sizetemp = 0
								End If
								e.scaley = sizetemp
								If Not bypass_stretch And e.speed
									e.scaley = (c_scaley.changes[0] * e.gsizey * (e.height + (Abs(e.speed) * c_stretch.changes[0] * parenteffect.currentstretch))) / image.height
									If e.scaley < e.scalex e.scaley = e.scalex
								End If
								e.AABB_MaxWidth = AABB_ParticleMaxWidth
								e.AABB_MinWidth = AABB_ParticleMinWidth
								e.AABB_MaxHeight = AABB_ParticleMaxHeight
								e.AABB_MinHeight = AABB_ParticleMinHeight
							End If
							'-------------------------------
							'-----Splatter-------------------
							If Not bypass_splatter
								splattertemp = get_splatter(parenteffect.currentframe)
								splatx = Rnd(-splattertemp, splattertemp)
								splaty = Rnd(-splattertemp, splattertemp)
								While GetDistance(0, 0, splatx, splaty) >= splattertemp And splattertemp > 0
									splatx = Rnd(-splattertemp, splattertemp)
									splaty = Rnd(-splattertemp, splattertemp)
								Wend
								If z = 1 Or e.relative
									e.x:+splatx
									e.y:+splaty
								Else
									e.x:+splatx * z
									e.y:+splaty * z
								End If
							End If
							'--------------------------------
							'rotation  and direction of travel settings-----
							e.miniupdate()
							If parentEffect.traverseedge And parentEffect.class = tlLINE_EFFECT
								e.directionlocked = True
								e.direction = 90
							Else
								If parentEffect.class <> tlPOINT_EFFECT
									If Not bypass_speed Or angletype = tlANGLE_ALIGN
										Select parentEffect.emissiontype
											Case tlEMISSION_INWARDS
												e.emissionangle = current_emissionangle + Rnd(-er, er)
												If e.relative
													e.emissionangle:+GetDirection(e.x, e.y, 0, 0)
												Else
													e.emissionangle:+GetDirection(e.wx, e.wy, e.parent.wx, e.parent.wy)
												End If
											Case tlEMISSION_OUTWARDS
												e.emissionangle = current_emissionangle + Rnd(-er, er)
												If e.relative
													e.emissionangle:+GetDirection(0, 0, e.x, e.y)
												Else
													e.emissionangle:+GetDirection(e.parent.wx, e.parent.wy, e.wx, e.wy)
												End If
											Case tlEMISSION_IN_AND_OUT
												e.emissionangle = current_emissionangle + Rnd(-er, er)
												If diralternater
													If e.relative
														e.emissionangle:+GetDirection(0, 0, e.x, e.y)
													Else
														e.emissionangle:+GetDirection(e.parent.wx, e.parent.wy, e.wx, e.wy)
													End If
												Else
													If e.relative
														e.emissionangle:+GetDirection(e.x, e.y, 0, 0)
													Else
														e.emissionangle:+GetDirection(e.wx, e.wy, e.parent.wx, e.parent.wy)
													End If
												End If
												diralternater = Not diralternater
											Case tlEMISSION_SPECIFIED
												e.emissionangle = current_emissionangle + Rnd(-er, er)
										End Select
									End If
								Else
									e.emissionangle = current_emissionangle + Rnd(-er, er)
								End If
								If Not bypass_directionvariation
									e.directionvariaion = current_directionvariation
									dv = e.directionvariaion * c_directionvariationot.changes[0]
									e.direction = e.emissionangle + c_direction.changes[0] + Rnd(-dv, dv)
								Else
									e.direction = e.emissionangle + c_direction.changes[0]
								End If
							End If
							'-------------------------------
							'e.lockedangle = lockedangle----
							If Not bypass_spin
								e.spinvariation = Rnd(-current_spinvariation, current_spinvariation) + current_spin
							End If
							'-----Weight---------------------
							If Not bypass_weight
								e.weight = c_weight.changes[0]
								e.weightvariation = Rnd(-current_weightvariation, current_weightvariation)
								e.baseweight = (current_weight + e.weightvariation) * parentEffect.currentweight
							End If
							'--------------------------------
							If lockedangle
								If Not bypass_weight And Not bypass_speed And Not parenteffect.bypass_weight
									e.speedvec.x = Sin(e.direction)
									e.speedvec.y = Cos(e.direction)
									e.angle = GetDirection(0, 0, e.speedvec.x, -e.speedvec.y)
								Else
									If parentEffect.traverseedge
										e.angle = parentEffect.angle + angleoffset
									Else
										e.angle = e.direction + angle + angleoffset
									End If
								End If
							Else
								Select angletype
									Case tlANGLE_ALIGN
										If parentEffect.traverseedge
											e.angle = parentEffect.angle + angleoffset
										Else
											e.angle = e.direction + angleoffset
										End If
									Case tlANGLE_RANDOM
										e.angle = Rnd(angleoffset)
									Case tlANGLE_SPECIFY
										e.angle = angleoffset
								End Select
							End If
							'-------------------------------
							'-----Colour Settings-----------
							If randomcolor
								randomage = Rnd(c_r.lastframe)
								e.red = c_r.changes[randomage]
								e.green = c_g.changes[randomage]
								e.blue = c_b.changes[randomage]
							Else
								e.red = c_r.changes[0]
								e.green = c_g.changes[0]
								e.blue = c_b.changes[0]
							End If
							e.alpha = e.emitter.get_alpha(e.age, e.lifetime) * parenteffect.currentalpha
							'-------------------------------
							'-----blend mode-----------------
							e.blendmode = blendmode
							'-----Animation and framerate----
							e.animating = animate
							e.animateonce = once
							e.framerate = c_framerate.changes[0]
							If randomstartframe
								e.currentframe = Rnd(e.avatar.frames)
							Else
								e.currentframe = frame
							End If
							'---------------------------------
							'-----add any sub children--------
							For Local eff:tlEffect = EachIn effects
								Local neweff:tlEffect = CopyCompiledEffect(eff, parentEffect.PM)
								neweff.parent = e
								neweff.parentEmitter = Self
								neweff.effectlayer = e.effectlayer
								e.addchild(neweff)
							Next
							parentEffect.tlParticlesCreated = True
							e.parent.addchild(e)
							'get the relativeangle
							If Not e.relative
								e.matrix.set(Cos(angle), Sin(e.angle), -Sin(e.angle), Cos(e.angle))
								e.matrix = e.matrix.transform(parent.matrix)
							End If
							e.relativeangle = parent.relativeangle + e.angle
							e.UpdateEntityRadius()
							e.UpdateBoundingBox()
							'Capture old values for tweening
							e.capture()
						End If
					Next
					counter:-intcounter
				End If
			Case tlUPDATE_MODE_INTERPOLATED
				qty = ((interpolate_amount(parentEffect.age) + Rnd(interpolate_amountvariation(parentEffect.age))) * parentEffect.currentamount * parenteffect.PM.globalamountscale) / tp_CURRENT_UPDATE_TIME
				If Not singleparticle
					counter:+qty
				End If
				intcounter = counter
				If intcounter >= 1 Or (singleparticle And Not startedspawning)
					If Not startedspawning And singleparticle
						Select parentEffect.class
							Case tlPOINT_EFFECT
								intcounter = 1
							Case tlAREA_EFFECT
								intcounter = parentEffect.mgx * parentEffect.mgy
							Case tlLINE_EFFECT, tlELLIPSE_EFFECT
								intcounter = parentEffect.mgx
						End Select
					ElseIf singleparticle And startedspawning
						intcounter = 0
					End If
					'Preload Attributes----
					currentlife = interpolate_life(parentEffect.age) * parentEffect.currentlife
					If Not bypass_weight
						current_weight = interpolate_baseweight(parentEffect.age)
						current_weightvariation = interpolate_weightvariation(parentEffect.age)
					End If
					If Not bypass_speed
						current_speed = interpolate_basespeed(parentEffect.age)
						current_speedvariation = interpolate_velvariation(parentEffect.age)
					End If
					If Not bypass_spin
						current_spin = interpolate_basespin(parenteffect.age)
						current_spinvariation = interpolate_spinvariation(parentEffect.age)
					End If
					current_directionvariation = interpolate_directionvariation(parentEffect.age)
					If useeffectemission
						er = parentEffect.currentemissionrange
						current_emissionangle = parentEffect.currentemissionangle
					Else
						er = interpolate_emissionrange(parentEffect.age)
						current_emissionangle = interpolate_emissionangle(parentEffect.age)
					End If
					current_lifevariation = interpolate_lifevariation(parentEffect.age)
					current_sizex = interpolate_sizex(parentEffect.age)
					current_sizey = interpolate_sizey(parentEffect.age)
					current_sizexvariation = interpolate_sizexvariation(parentEffect.age)
					current_sizeyvariation = interpolate_sizeyvariation(parentEffect.age)
					'					----------------------
					For Local c:Float = 1 To intcounter
						startedspawning = True
						If Not parentEffect.PM Throw "No Partical Manager assigned to effect"
						e = parentEffect.PM.GrabParticle(parenteffect, groupparticles, zlayer)
						If e
							?Debug
							tlParticlesCreated:+1
							?
							'-----Link to it's emitter and assign the control source (which is this emitter)----
							e.emitter = Self
							e.parent = Self
							e.PM = parentEffect.PM
							e.effectlayer = parentEffect.effectlayer
							'-------------------------------
							e.dob = e.PM.CURRENT_TIME
							If parentEffect.traverseedge And parentEffect.class = tlLINE_EFFECT
								particlesrelative = True
							End If
							e.relative = particlesrelative
							Select parentEffect.class
								Case tlPOINT_EFFECT
									If e.relative
										e.x = 0 - parentEffect.handlex
										e.y = 0 - parentEffect.handley
									Else
										tween = c / intcounter
										If parenteffect.handlecenter Or parentEffect.handlex + parentEffect.handley = 0
											tween = c / intcounter
											e.x = TweenValues(oldwx, wx, tween)
											e.y = TweenValues(oldwy, wy, tween)
											If z <> 1
												e.wx = e.x - parentEffect.handlex * z
												e.wy = e.y - parentEffect.handley * z
											Else
												e.wx = e.x - parentEffect.handlex
												e.wy = e.y - parentEffect.handley
											End If
										Else
											e.x = 0 - parentEffect.handlex
											e.y = 0 - parentEffect.handley
											rotvec = parent.matrix.transformvector(New tlVector2.Create(e.x, e.y))
											e.x = TweenValues(oldwx, wx, tween) + rotvec.x
											e.y = TweenValues(oldwy, wy, tween) + rotvec.y
											If z <> 1
												e.wx = e.x * z
												e.wy = e.y * z
											Else
												e.wx = e.x
												e.wy = e.y
											End If
										End If
									End If
								Case tlAREA_EFFECT
									If parentEffect.emitatpoints
										If parentEffect.spawndirection = -1
											gx:+parentEffect.spawndirection
											If gx < 0
												gx = parentEffect.mgx - 1
												gy:+parentEffect.spawndirection
												If gy < 0
													gy = parentEffect.mgy - 1
												End If
											End If
										End If
										If parentEffect.mgx > 1
											e.x = (gx / (parentEffect.mgx - 1) * parentEffect.currentwidth) - parentEffect.handlex
										Else
											e.x = -parentEffect.handlex
										End If
										If parentEffect.mgy > 1
											e.y = (gy / (parentEffect.mgy - 1) * parentEffect.currentheight) - parentEffect.handley
										Else
											e.y = -parentEffect.handley
										End If
										If parentEffect.spawndirection = 1
											gx:+parentEffect.spawndirection
											If gx >= parentEffect.mgx
												gx = 0
												gy:+parentEffect.spawndirection
												If gy >= parentEffect.mgy
													gy = 0
												End If
											End If
										End If
									Else
										e.x = Rnd(parentEffect.currentwidth) - parentEffect.handlex
										e.y = Rnd(parentEffect.currentheight) - parentEffect.handley
									End If
									If Not e.relative
										rotvec = parent.matrix.transformvector(New tlVector2.Create(e.x, e.y))
										If z <> 1
											e.x = parent.wx + rotvec.x * z
											e.y = parent.wy + rotvec.y * z
										Else
											e.x = parent.wx + rotvec.x
											e.y = parent.wy + rotvec.y
										End If
									End If
								Case tlELLIPSE_EFFECT
									If parentEffect.emitatpoints
										
										cellsizew = parentEffect.currentwidth / 2
										cellsizeh = parentEffect.currentheight / 2
										
										If (parentEffect.mgx = 0)
											parentEffect.mgx = 1
										End If
									
										tx = cellsizew
										ty = cellsizeh
		
										gx:+parentEffect.spawndirection
										If gx >= parentEffect.mgx
											gx = 0
										ElseIf gx < 0
											gx = parentEffect.mgx - 1
										End If
									
										th = gx * (parenteffect.ellipsearc / parentEffect.mgx) + parenteffect.ellipseoffset
										
										e.x = Cos(th) * tx - parentEffect.handlex + tx
										e.y = -Sin(th) * ty - parentEffect.handley + ty

									Else
										tx = parentEffect.currentwidth / 2
										ty = parentEffect.currentheight / 2
									
										th = Rnd(parenteffect.ellipsearc) + parenteffect.ellipseoffset
										
										e.x = Cos(th) * tx - parentEffect.handlex + tx
										e.y = -Sin(th) * ty - parentEffect.handley + ty
									End If
									If Not e.relative
										rotvec = parent.matrix.transformvector(New tlVector2.Create(e.x, e.y))
										If z <> 1
											e.x = parent.wx + rotvec.x * z
											e.y = parent.wy + rotvec.y * z
										Else
											e.x = parent.wx + rotvec.x 
											e.y = parent.wy + rotvec.y
										End If
									End If
								Case tlLINE_EFFECT
									If Not parentEffect.traverseedge
										If parentEffect.emitatpoints
											If parentEffect.spawndirection = -1
												gx:+parentEffect.spawndirection
												If gx < 0
													gx = parentEffect.mgx - 1
												End If
											End If
											If parentEffect.mgx > 1
												e.x = (gx / (parentEffect.mgx - 1) * parentEffect.currentwidth) - parentEffect.handlex
											Else
												e.x = -parentEffect.handlex
											End If
											e.y = -parentEffect.handley
											If parentEffect.spawndirection = 1
												gx:+parentEffect.spawndirection
												If gx >= parentEffect.mgx
													gx = 0
												End If
											End If
										Else
											e.x = Rnd(parentEffect.currentwidth) - parentEffect.handlex
											e.y = -parentEffect.handley
										End If
									Else
										If parentEffect.distancesetbylife
											e.x = -parentEffect.handlex
											e.y = -parentEffect.handley
										Else
											If parentEffect.emitatpoints
												If parentEffect.spawndirection = -1
													gx:+parentEffect.spawndirection
													If gx < 0
														gx = parentEffect.mgx - 1
													End If
												End If
												If parentEffect.mgx > 1
													e.x = (gx / (parentEffect.mgx - 1) * parentEffect.currentwidth) - parentEffect.handlex
												Else
													e.x = -parentEffect.handlex
												End If
												e.y = -parentEffect.handley
												If parentEffect.spawndirection = 1
													gx:+parentEffect.spawndirection
													If gx >= parentEffect.mgx
														gx = 0
													End If
												End If
											Else
												e.x = Rnd(parentEffect.currentwidth) - parentEffect.handlex
												e.y = -parentEffect.handley
											End If
										End If
									End If
									'rotate
									If Not e.relative
										rotvec = parent.matrix.transformvector(New tlVector2.Create(e.x, e.y))
										If z <> 1
											e.x = parent.wx + rotvec.x * z
											e.y = parent.wy + rotvec.y * z
										Else
											e.x = parent.wx + rotvec.x 
											e.y = parent.wy + rotvec.y
										End If
									End If
							End Select
							'Set the zoom level
							e.setz(z)
							'-----Set up the image----------
							e.avatar = image
							e.handlex = handlex
							e.handley = handley
							e.autocenter = handlecenter
							'-------------------------------
							'-----Set lifetime properties---
							e.lifetime = currentlife + Rnd(-current_lifevariation, current_lifevariation) * parentEffect.currentlife
							'-------------------------------
							'-----Speed---------------------
							e.speedvec.x = 0
							e.speedvec.y = 0
							If Not bypass_speed
								e.speed = interpolate_velocity(0, e.lifetime)
								e.velvariation = Rnd(-current_speedvariation, current_speedvariation)
								e.basespeed = (current_speed + e.velvariation) * parentEffect.currentvelocity
								e.velseed = Rnd(0, 1.0)
								e.speed = interpolate_velocity(0, e.lifetime) * e.basespeed * interpolate_globalvelocity(parentEffect.age)
							Else
								e.speed = 0
							End If
							'--------------------------------
							'-----Size----------------------
							e.gsizex = parentEffect.currentsizex
							e.gsizey = parentEffect.currentsizey
							If uniform
								scaletemp = interpolate_scalex(0, e.lifetime)
								e.scalevariationx = Rnd(current_sizexvariation)
								e.width = e.scalevariationx + current_sizex
								If scaletemp
									sizetemp = (e.width / image.width) * scaletemp * e.gsizex
								Else
									sizetemp = 0
								End If
								e.scalex = sizetemp
								e.scaley = sizetemp
								If Not bypass_stretch And e.speed
									e.scaley = (interpolate_scalex(0, e.lifetime) * e.gsizex * (e.width + (Abs(e.speed) * interpolate_stretch(0, e.lifetime) * parentEffect.currentstretch))) / image.width
									If e.scaley < e.scalex e.scaley = e.scalex
								End If
								e.AABB_MaxWidth = AABB_ParticleMaxWidth
								e.AABB_MinWidth = AABB_ParticleMinWidth
								e.AABB_MaxHeight = e.AABB_MaxWidth
								e.AABB_MinHeight = e.AABB_MinWidth
							Else
								'width
								scaletemp = interpolate_scalex(0, e.lifetime)
								e.scalevariationx = Rnd(current_sizexvariation)
								e.width = e.scalevariationx + current_sizex
								If scaletemp
									sizetemp = (e.width / image.width) * scaletemp * e.gsizex
								Else
									sizetemp = 0
								End If
								e.scalex = sizetemp
								'height
								scaletemp = interpolate_scaley(0, e.lifetime)
								e.scalevariationy = Rnd(current_sizeyvariation)
								e.height = e.scalevariationy + current_sizey
								If scaletemp
									sizetemp = (e.height / image.height) * scaletemp * e.gsizey
								Else
									sizetemp = 0
								End If
								e.scaley = sizetemp
								If Not bypass_stretch And e.speed
									e.scaley = (interpolate_scaley(0, e.lifetime) * e.gsizey * (e.height + (Abs(e.speed) * interpolate_stretch(0, e.lifetime) * parentEffect.currentstretch))) / image.height
									If e.scaley < e.scalex e.scaley = e.scalex
								End If
								e.AABB_MaxWidth = AABB_ParticleMaxWidth
								e.AABB_MinWidth = AABB_ParticleMinWidth
								e.AABB_MaxHeight = AABB_ParticleMaxHeight
								e.AABB_MinHeight = AABB_ParticleMinHeight
							End If
							'-------------------------------
							'-----Splatter-------------------
							If Not bypass_splatter
								splattertemp = interpolate_splatter(parenteffect.age)
								splatx = Rnd(-splattertemp, splattertemp)
								splaty = Rnd(-splattertemp, splattertemp)
								While GetDistance(0, 0, splatx, splaty) >= splattertemp And splattertemp > 0
									splatx = Rnd(-splattertemp, splattertemp)
									splaty = Rnd(-splattertemp, splattertemp)
								Wend
								If z = 1 Or e.relative
									e.x:+splatx
									e.y:+splaty
								Else
									e.x:+splatx * z
									e.y:+splaty * z
								End If
							End If
							'--------------------------------
							'rotation  and direction of travel settings-----
							e.miniupdate()
							If parentEffect.traverseedge And parentEffect.class = tlLINE_EFFECT
								e.directionlocked = True
								e.direction = 90
							Else
								If parentEffect.class <> tlPOINT_EFFECT
									If Not bypass_speed Or angletype = tlANGLE_ALIGN
										Select parentEffect.emissiontype
											Case tlEMISSION_INWARDS
												e.emissionangle = current_emissionangle + Rnd(-er, er)
												If e.relative
													e.emissionangle:+GetDirection(e.x, e.y, 0, 0)
												Else
													e.emissionangle:+GetDirection(e.wx, e.wy, e.parent.wx, e.parent.wy)
												End If
											Case tlEMISSION_OUTWARDS
												e.emissionangle = current_emissionangle + Rnd(-er, er)
												If e.relative
													e.emissionangle:+GetDirection(0, 0, e.x, e.y)
												Else
													e.emissionangle:+GetDirection(e.parent.wx, e.parent.wy, e.wx, e.wy)
												End If
											Case tlEMISSION_IN_AND_OUT
												e.emissionangle = current_emissionangle + Rnd(-er, er)
												If diralternater
													If e.relative
														e.emissionangle:+GetDirection(0, 0, e.x, e.y)
													Else
														e.emissionangle:+GetDirection(e.parent.wx, e.parent.wy, e.wx, e.wy)
													End If
												Else
													If e.relative
														e.emissionangle:+GetDirection(e.x, e.y, 0, 0)
													Else
														e.emissionangle:+GetDirection(e.wx, e.wy, e.parent.wx, e.parent.wy)
													End If
												End If
												diralternater = Not diralternater
											Case tlEMISSION_SPECIFIED
												e.emissionangle = current_emissionangle + Rnd(-er, er)
										End Select
									End If
								Else
									e.emissionangle = current_emissionangle + Rnd(-er, er)
								End If
								If Not bypass_directionvariation
									e.directionvariaion = current_directionvariation
									dv = e.directionvariaion * interpolate_directionvariationot(0, e.lifetime)
									e.direction = e.emissionangle + interpolate_direction(0, e.lifetime) + Rnd(-dv, dv)
								Else
									e.direction = e.emissionangle + interpolate_direction(0, e.lifetime)
								End If
							End If
							'-------------------------------
							'e.lockedangle = lockedangle----
							If Not bypass_spin
								e.spinvariation = Rnd(-current_spinvariation, current_spinvariation) + current_spin
							End If
							'-----Weight---------------------
							If Not bypass_weight
								e.weight = interpolate_weight(0, e.lifetime)
								e.weightvariation = Rnd(-current_weightvariation, current_weightvariation)
								e.baseweight = (current_weight + e.weightvariation) * parentEffect.currentweight
							End If
							'--------------------------------
							If lockedangle
								If Not bypass_weight And Not bypass_speed And Not parenteffect.bypass_weight
									e.speedvec.x = Sin(e.direction)
									e.speedvec.y = Cos(e.direction)
									e.angle = GetDirection(0, 0, e.speedvec.x, -e.speedvec.y)
								Else
									If parentEffect.traverseedge
										e.angle = parentEffect.angle + angleoffset
									Else
										e.angle = e.direction + angle + angleoffset
									End If
								End If
							Else
								Select angletype
									Case tlANGLE_ALIGN
										If parentEffect.traverseedge
											e.angle = parentEffect.angle + angleoffset
										Else
											e.angle = e.direction + angleoffset
										End If
									Case tlANGLE_RANDOM
										e.angle = Rnd(angleoffset)
									Case tlANGLE_SPECIFY
										e.angle = angleoffset
								End Select
							End If
							'-------------------------------
							'-----Colour Settings-----------
							If randomcolor
								randomage = Rnd(e.lifetime)
								e.red = randomise_r(e, randomage)
								e.green = randomise_g(e, randomage)
								e.blue = randomise_b(e, randomage)
							Else
								e.red = interpolate_r(0, e.lifetime)
								e.green = interpolate_g(0, e.lifetime)
								e.blue = interpolate_b(0, e.lifetime)
							End If
							e.alpha = interpolate_alpha(0, e.lifetime) * parentEffect.currentalpha
							'-------------------------------
							'-----blend mode-----------------
							e.blendmode = blendmode
							'-----Animation and framerate----
							e.animating = animate
							e.animateonce = once
							e.framerate = interpolate_framerate(0, e.lifetime)
							If randomstartframe
								e.currentframe = Rnd(e.avatar.frames)
							Else
								e.currentframe = frame
							End If
							'--------------------------------
							'-----add any sub children--------
							e.runchildren = False
							For Local eff:tlEffect = EachIn effects
								Local neweff:tlEffect = CopyEffect(eff, parentEffect.PM)
								neweff.parent = e
								neweff.parentEmitter = Self
								neweff.effectlayer = e.effectlayer
								e.addchild(neweff)
							Next
							parentEffect.tlParticlesCreated = True
							e.parent.addchild(e)
							'get the relativeangle
							If Not e.relative
								e.matrix.set(Cos(angle), Sin(e.angle), -Sin(e.angle), Cos(e.angle))
								e.matrix = e.matrix.transform(parent.matrix)
							End If
							e.relativeangle = parent.relativeangle + e.angle
							e.UpdateEntityRadius()
							e.UpdateBoundingBox()
							'Capture old values for tweening
							e.capture()
						End If
					Next
					counter:-intcounter
				End If
		End Select
	End Method
	Rem
	bbdoc: Control a particle
	about: Any particle spawned by an emitter is controlled by it. When a particle is updated it calls this method to find out how it should behave.
	endrem
	Method controlparticle(e:tlParticle)
		Select parenteffect.PM.updatemode
			Case tlUPDATE_MODE_COMPILED
				'-----Alpha Change-----
				If alpharepeat > 1
					e.rptageA:+tp_UPDATE_TIME * alpharepeat
					e.alpha = get_alpha(e.rptageA, e.lifetime) * parenteffect.currentalpha
					If e.rptageA > e.lifetime And e.acycles < alpharepeat
						e.rptageA:-e.lifetime
						e.acycles:+1
					End If
				Else
					e.alpha = get_alpha(e.age, e.lifetime) * parenteffect.currentalpha
				End If
				'----------------------
				'-----Angle Changes----
				If lockedangle And angletype = tlANGLE_ALIGN
					If e.directionlocked
						e.angle = parenteffect.angle + angle + angleoffset
					Else
						If Not bypass_weight And Not parenteffect.bypass_weight Or e.direction
							If e.oldwx <> e.wx And e.oldwy <> e.wy
								If e.relative
									e.angle = GetDirection(e.oldx, e.oldy, e.x, e.y) + angleoffset
								Else
									e.angle = GetDirection(e.oldwx, e.oldwy, e.wx, e.wy) + angleoffset
								End If
								If Abs(e.oldangle - e.angle) > 180
									If e.oldangle > e.angle e.oldangle:-360 Else e.oldangle:+360
								End If
							End If
						Else
							e.angle = e.direction + angle + angleoffset
						End If
					End If
				Else
					If Not bypass_spin
						e.angle:+(get_spin(e.age, e.lifetime) * e.spinvariation * parenteffect.currentspin) / tp_CURRENT_UPDATE_TIME
					End If
				End If
				'----------------------
				'----Direction Changes and Motion Randomness--
				Local dv:Float
				If e.directionlocked
					e.direction = 90
					Select parenteffect.class
						Case tlLINE_EFFECT
							If parenteffect.distancesetbylife
								Local life:Float = e.age / e.lifetime
								e.x = (life * parenteffect.currentwidth) - parenteffect.handlex
							Else
								Select parenteffect.endbehaviour
									Case tlEND_KILL
										If e.x > parenteffect.currentwidth - parenteffect.handlex Or e.x < 0 - parenteffect.handlex
											e.dead = 2
										End If
									Case tlEND_LOOPAROUND
										If e.x > parenteffect.currentwidth - parenteffect.handlex
											e.x = -parenteffect.handlex
											e.miniupdate
											e.oldx = e.x
											e.oldwx = e.wx
											e.oldwy = e.wy
										ElseIf e.x < 0 - parenteffect.handlex
											e.x = parenteffect.currentwidth - parenteffect.handlex
											e.miniupdate
											e.oldx = e.x
											e.oldwx = e.wx
											e.oldwy = e.wy
										End If
								End Select
							End If
					End Select
				Else
					If Not bypass_directionvariation
						dv = e.directionvariaion * get_directionvariationot(e.age, e.lifetime)
						e.timetracker:+tp_UPDATE_TIME
						If e.timetracker > tlMOTION_VARIATION_INTERVAL
							e.randomdirection:+tlMAX_DIRECTION_VARIATION * Rnd(-dv, dv)
							e.randomspeed:+tlMAX_VELOCITY_VARIATION * Rnd(-dv, dv)
							e.timetracker = 0
						End If
					End If
					e.direction = e.emissionangle + get_direction(e.age, e.lifetime) + e.randomdirection
				End If
				'-----------------------
				'------Size Changes-----
				If uniform
					If Not bypass_scalex
						e.scalex = (get_scalex(e.age, e.lifetime) * e.gsizex * e.width) / image.width
						e.scaley = e.scalex
					End If
				Else
					If Not bypass_scalex
						e.scalex = (get_scalex(e.age, e.lifetime) * e.gsizex * e.width) / image.width
					End If
					If Not bypass_scaley
						e.scaley = (get_scaley(e.age, e.lifetime) * e.gsizey * e.height) / image.height
					End If
				End If
				'-----------------------
				'-----Colour Changes----
				If Not bypass_colour
					If Not randomcolor
						If colorrepeat > 1
							e.rptageC:+tp_UPDATE_TIME * colorrepeat
							e.red = get_r(e.rptageC, e.lifetime)
							e.green = get_g(e.rptageC, e.lifetime)
							e.blue = get_b(e.rptageC, e.lifetime)
							If e.rptageC > e.lifetime And e.ccycles < colorrepeat
								e.rptageC:-e.lifetime
								e.ccycles:+1
							End If
						Else
							e.red = get_r(e.age, e.lifetime)
							e.green = get_g(e.age, e.lifetime)
							e.blue = get_b(e.age, e.lifetime)
						End If
					End If
				End If
				'-----------------------
				'-------Animation-------
				If Not bypass_framerate
					e.framerate = get_framerate(e.age, e.lifetime) * animationdirection
				End If
				'-----------------------
				'-----Speed Changes-----
				If Not bypass_speed
					e.speed = get_velocity(e.age, e.lifetime) * e.basespeed * get_globalvelocity(parenteffect.currentframe)
					e.speed:+e.randomspeed
				Else
					e.speed = e.randomspeed
				End If
				'-------Stretch---------
				If Not bypass_stretch
					If Not bypass_weight And Not parenteffect.bypass_weight
						If e.speed
							e.speedvec.x = e.speedvec.x * tp_CURRENT_UPDATE_TIME
							e.speedvec.y = e.speedvec.y * tp_CURRENT_UPDATE_TIME - e.gravity
						Else
							e.speedvec.x = 0
							e.speedvec.y = -e.gravity
						End If
						If uniform
							e.scaley = (get_scalex(e.age, e.lifetime) * e.gsizex * (e.width + (GetDistance(0, 0, e.speedvec.x, e.speedvec.y) * get_stretch(e.age, e.lifetime) * parenteffect.currentstretch))) / image.width
						Else
							e.scaley = (get_scaley(e.age, e.lifetime) * e.gsizey * (e.height + (GetDistance(0, 0, e.speedvec.x, e.speedvec.y) * get_stretch(e.age, e.lifetime) * parenteffect.currentstretch))) / image.height
						End If
					Else
						If uniform
							e.scaley = (get_scalex(e.age, e.lifetime) * e.gsizex * (e.width + (Abs(e.speed) * get_stretch(e.age, e.lifetime) * parenteffect.currentstretch))) / image.width
						Else
							e.scaley = (get_scaley(e.age, e.lifetime) * e.gsizey * (e.height + (Abs(e.speed) * get_stretch(e.age, e.lifetime) * parenteffect.currentstretch))) / image.height
						End If
					EndIf
					If e.scaley < e.scalex e.scaley = e.scalex
				End If
				'------------------------
				'-----Weight Changes-----
				If Not bypass_weight
					e.weight = get_weight(e.age, e.lifetime) * e.baseweight
				End If
			'------------------------
			Case tlUPDATE_MODE_INTERPOLATED
				'-----Alpha Change-----
				If alpharepeat > 1
					e.rptageA:+tp_UPDATE_TIME * alpharepeat
					e.alpha = interpolate_alpha(e.rptageA, e.lifetime) * parenteffect.currentalpha
					If e.rptageA > e.lifetime And e.acycles < alpharepeat
						e.rptageA:-e.lifetime
						e.acycles:+1
					End If
				Else
					e.alpha = interpolate_alpha(e.age, e.lifetime) * parenteffect.currentalpha
				End If
				'----------------------
				'-----Angle Changes----
				If lockedangle And angletype = tlANGLE_ALIGN
					If e.directionlocked
						e.angle = parenteffect.angle + angle + angleoffset
					Else
						If Not bypass_weight And Not parenteffect.bypass_weight Or e.direction
							If e.oldwx <> e.wx And e.oldwy <> e.wy
								If e.relative
									e.angle = GetDirection(e.oldx, e.oldy, e.x, e.y)
								Else
									e.angle = GetDirection(e.oldwx, e.oldwy, e.wx, e.wy)
								End If
								If Abs(e.oldangle - e.angle) > 180
									If e.oldangle > e.angle e.oldangle:-360 Else e.oldangle:+360
								End If
							End If
						Else
							e.angle = e.direction + angle + angleoffset
						End If
					End If
				Else
					If Not bypass_spin
						e.angle:+(interpolate_spin(e.age, e.lifetime) * e.spinvariation * parenteffect.currentspin) / tp_CURRENT_UPDATE_TIME
					End If
				End If
				'----------------------
				'----Direction Changes and Motion Randomness--
				Local dv:Float
				If e.directionlocked
					e.direction = 90
					Select parenteffect.class
						Case tlLINE_EFFECT
							If parenteffect.distancesetbylife
								Local life:Float = e.age / e.lifetime
								e.x = (life * parenteffect.currentwidth) - parenteffect.handlex
							Else
								Select parenteffect.endbehaviour
									Case tlEND_KILL
										If e.x > parenteffect.currentwidth - parenteffect.handlex Or e.x < 0 - parenteffect.handlex
											e.dead = 2
										End If
									Case tlEND_LOOPAROUND
										If e.x > parenteffect.currentwidth - parenteffect.handlex
											e.x = -parenteffect.handlex
											e.miniupdate
											e.oldx = e.x
											e.oldwx = e.wx
											e.oldwy = e.wy
										ElseIf e.x < 0 - parenteffect.handlex
											e.x = parenteffect.currentwidth - parenteffect.handlex
											e.miniupdate
											e.oldx = e.x
											e.oldwx = e.wx
											e.oldwy = e.wy
										End If
								End Select
							End If
					End Select
				Else
					If Not bypass_directionvariation
						dv = e.directionvariaion * interpolate_directionvariationot(e.age, e.lifetime)
						e.timetracker:+tp_UPDATE_TIME
						If e.timetracker > tlMOTION_VARIATION_INTERVAL
							e.randomdirection:+tlMAX_DIRECTION_VARIATION * Rnd(-dv, dv)
							e.randomspeed:+tlMAX_VELOCITY_VARIATION * Rnd(-dv, dv)
							e.timetracker = 0
						End If
					End If
					e.direction = e.emissionangle + interpolate_direction(e.age, e.lifetime) + e.randomdirection
				End If
				'-----------------------
				'------Size Changes-----
				If uniform
					If Not bypass_scalex
						e.scalex = (interpolate_scalex(e.age, e.lifetime) * e.gsizex * e.width) / image.width
						e.scaley = e.scalex
					End If
				Else
					If Not bypass_scalex
						e.scalex = (interpolate_scalex(e.age, e.lifetime) * e.gsizex * e.width) / image.width
					End If
					If Not bypass_scaley
						e.scaley = (interpolate_scaley(e.age, e.lifetime) * e.gsizey * e.height) / image.height
					End If
				End If
				'-----------------------
				'-----Colour Changes----
				If Not bypass_colour
					If Not randomcolor
						If colorrepeat > 1
							e.rptageC:+tp_UPDATE_TIME * colorrepeat
							e.red = interpolate_r(e.rptageC, e.lifetime)
							e.green = interpolate_g(e.rptageC, e.lifetime)
							e.blue = interpolate_b(e.rptageC, e.lifetime)
							If e.rptageC > e.lifetime And e.ccycles < colorrepeat
								e.rptageC:-e.lifetime
								e.ccycles:+1
							End If
						Else
							e.red = interpolate_r(e.age, e.lifetime)
							e.green = interpolate_g(e.age, e.lifetime)
							e.blue = interpolate_b(e.age, e.lifetime)
						End If
					End If
				End If
				'-----------------------
				'-------Animation-------
				If Not bypass_framerate
					e.framerate = interpolate_framerate(e.age, e.lifetime) * animationdirection
				End If
				'-----------------------
				'-----Speed Changes-----
				If Not bypass_speed
					e.speed = interpolate_velocity(e.age, e.lifetime) * e.basespeed * interpolate_globalvelocity(parenteffect.age)
					e.speed:+e.randomspeed
				Else
					e.speed = e.randomspeed
				End If
				'--------Stretch---------
				If Not bypass_stretch
					If Not bypass_weight And Not parenteffect.bypass_weight
						If e.speed
							e.speedvec.x = e.speedvec.x * tp_CURRENT_UPDATE_TIME
							e.speedvec.y = e.speedvec.y * tp_CURRENT_UPDATE_TIME - e.gravity
						Else
							e.speedvec.x = 0
							e.speedvec.y = -e.gravity
						End If
						If uniform
							e.scaley = (interpolate_scalex(e.age, e.lifetime) * e.gsizex * (e.width + (GetDistance(0, 0, e.speedvec.x, e.speedvec.y) * interpolate_stretch(e.age, e.lifetime) * parenteffect.currentstretch))) / image.width
						Else
							e.scaley = (interpolate_scaley(e.age, e.lifetime) * e.gsizey * (e.height + (GetDistance(0, 0, e.speedvec.x, e.speedvec.y) * interpolate_stretch(e.age, e.lifetime) * parenteffect.currentstretch))) / image.height
						End If
					Else
						If uniform
							e.scaley = (interpolate_scalex(e.age, e.lifetime) * e.gsizex * (e.width + (Abs(e.speed) * interpolate_stretch(e.age, e.lifetime) * parenteffect.currentstretch))) / image.width
						Else
							e.scaley = (interpolate_scaley(e.age, e.lifetime) * e.gsizey * (e.height + (Abs(e.speed) * interpolate_stretch(e.age, e.lifetime) * parenteffect.currentstretch))) / image.height
						End If
					EndIf
					If e.scaley < e.scalex e.scaley = e.scalex
				End If
				'------------------------
				'-----Weight Changes-----
				If Not bypass_weight
					e.weight = interpolate_weight(e.age, e.lifetime) * e.baseweight
				End If
				'------------------------
		End Select
	End Method
	Rem
	bbdoc: Draws the current image frame
	about: Draws on screen the current frame of teh image the emitter uses to create particles with. Mainly just a Timeline Particles Editor method.
	endrem	
	Method drawcurrentframe(x:Float = 0, y:Float = 0, w:Float = 128, h:Float = 128)
		If image
			SetAlpha 1
			SetBlend blendmode
			SetImageHandle image.image, 0, 0
			SetColor 255, 255, 255
			SetScale w / image.width, h / image.height
			DrawSprite image, x, y, frame
		End If
	End Method
	Rem
	bbdoc: Cycle forward through the image frames
	endrem
	Method nextframe()
		frame:+1
		If frame > image.frames - 1
			frame = 0
		End If
	End Method
	Rem
	bbdoc: Cycle backwards throught the image frames.
	endrem
	Method previousframe()
		frame:-1
		If frame < 0
			frame = image.frames - 1
		End If
	End Method
	'-----Spawn values over effect age-----
	Method interpolate_amount:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn amount
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlAMOUNT_MIN, tlAMOUNT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		
		Return lastv
	End Method
	Method interpolate_life:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn life
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlLIFE_MIN, tlLIFE_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_sizex:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local lastec:tlAttributeNode
		Local p:Float
		For Local a:tlAttributeNode = EachIn sizex
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlDIMENSIONS_MIN, tlDIMENSIONS_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_sizey:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn sizey
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlDIMENSIONS_MIN, tlDIMENSIONS_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_basespeed:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn basespeed
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlVELOCITY_MIN, tlVELOCITY_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_baseweight:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn baseweight
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlWEIGHT_MIN, tlWEIGHT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_basespin:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn basespin
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlSPIN_MIN, tlSPIN_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_emissionangle:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn emissionangle
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlANGLE_MIN, tlANGLE_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_emissionrange:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn emissionrange
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlEMISSION_RANGE_MIN, tlEMISSION_RANGE_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_splatter:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn splatter
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlDIMENSIONS_MIN, tlDIMENSIONS_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	'-----Variations over effect age----
	Method interpolate_velvariation:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn velvariation
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlVELOCITY_MIN, tlVELOCITY_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_weightvariation:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn weightvariation
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlWEIGHT_VARIATION_MIN, tlWEIGHT_VARIATION_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_lifevariation:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn lifevariation
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlLIFE_MIN, tlLIFE_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_amountvariation:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn amountvariation
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlAMOUNT_MIN, tlAMOUNT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_sizexvariation:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn sizexvariation
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlDIMENSIONS_MIN, tlDIMENSIONS_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_sizeyvariation:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn sizeyvariation
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlDIMENSIONS_MIN, tlDIMENSIONS_MIN)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_spinvariation:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn spinvariation
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlSPIN_VARIATION_MIN, tlSPIN_VARIATION_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_directionvariation:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn directionvariation
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	'-----Particle over life interpolations----
	Method interpolate_alpha:Float(age:Int, lifetime:Float)
		Local lastv:Float
		Local lastf:Float
		Local frame:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn alpha
			frame = a.frame * lifetime
			If age < frame
				p = (age - lastf) / (frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, 0, 1)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_r:Float(age:Int, lifetime:Float)
		Local lastv:Float
		Local lastf:Float
		Local frame:Float
		Local p:Float
		For Local a:tlAttributeNode = EachIn r
			frame = a.frame * lifetime
			If age < frame
				p = (age - lastf) / (frame - lastf)
				Return lastv - p * (lastv - a.value)
			End If
			lastv = a.value
			lastf = frame - 1
		Next
		Return lastv
	End Method
	Method interpolate_g:Float(age:Int, lifetime:Float)
		Local lastv:Float
		Local lastf:Float
		Local frame:Float
		Local p:Float
		For Local a:tlAttributeNode = EachIn g
			frame = a.frame * lifetime
			If age < frame
				p = (age - lastf) / (frame - lastf)
				Return lastv - p * (lastv - a.value)
			End If
			lastv = a.value
			lastf = frame - 1
		Next
		Return lastv
	End Method
	Method interpolate_b:Float(age:Int, lifetime:Float)
		Local lastv:Float
		Local lastf:Float
		Local frame:Float
		Local p:Float
		For Local a:tlAttributeNode = EachIn b
			frame = a.frame * lifetime
			If age < frame
				p = (age - lastf) / (frame - lastf)
				Return lastv - p * (lastv - a.value)
			End If
			lastv = a.value
			lastf = frame - 1
		Next
		Return lastv
	End Method
	Method randomise_r:Float(e:tlParticle, randomage:Int)
		Local lastv:Float
		Local lastf:Float
		Local frame:Float
		Local p:Float
		For Local a:tlAttributeNode = EachIn r
			frame = a.frame * e.lifetime
			If randomage < frame
				p = (randomage - lastf) / (frame - lastf)
				Return lastv - p * (lastv - a.value)
			End If
			lastv = a.value
			lastf = frame - 1
		Next
		Return lastv
	End Method
	Method randomise_g:Float(e:tlParticle, randomage:Int)
		Local lastv:Float
		Local lastf:Float
		Local frame:Float
		Local p:Float
		For Local a:tlAttributeNode = EachIn g
			frame = a.frame * e.lifetime
			If randomage < frame
				p = (randomage - lastf) / (frame - lastf)
				Return lastv - p * (lastv - a.value)
			End If
			lastv = a.value
			lastf = frame - 1
		Next
		Return lastv
	End Method
	Method randomise_b:Float(e:tlParticle, randomage:Int)
		Local lastv:Float
		Local lastf:Float
		Local frame:Float
		Local p:Float
		For Local a:tlAttributeNode = EachIn b
			frame = a.frame * e.lifetime
			If randomage < frame
				p = (randomage - lastf) / (frame - lastf)
				Return lastv - p * (lastv - a.value)
			End If
			lastv = a.value
			lastf = frame - 1
		Next
		Return lastv
	End Method
	Method interpolate_scalex:Float(age:Int, lifetime:Float)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local frame:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn scalex
			frame = a.frame * lifetime
			If age < frame
				p = (age - lastf) / (frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_scaley:Float(age:Int, lifetime:Float)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local frame:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn scaley
			frame = a.frame * lifetime
			If age < frame
				p = (age - lastf) / (frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_spin:Float(age:Int, lifetime:Float)
		Local lastv:Float
		Local lastf:Float
		Local frame:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn spin
			frame = a.frame * lifetime
			If age < frame
				p = (age - lastf) / (frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlSPIN_OVERTIME_MIN, tlSPIN_OVERTIME_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_velocity:Float(age:Int, lifetime:Float)
		Local lastv:Float
		Local lastf:Float
		Local frame:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn velocity
			frame = a.frame * lifetime
			If age < frame
				p = (age - lastf) / (frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlVELOCITY_OVERTIME_MIN, tlVELOCITY_OVERTIME_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_weight:Float(age:Int, lifetime:Float)
		Local lastv:Float
		Local lastf:Float
		Local frame:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn weight
			frame = a.frame * lifetime
			If age < frame
				p = (age - lastf) / (frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_direction:Float(age:Int, lifetime:Float)
		Local lastv:Float
		Local lastf:Float
		Local frame:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn direction
			frame = a.frame * lifetime
			If age < frame
				p = (age - lastf) / (frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlDIRECTION_OVERTIME_MIN, tlDIRECTION_OVERTIME_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_directionvariationot:Float(age:Int, lifetime:Float)
		Local lastv:Float
		Local lastf:Float
		Local frame:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn directionvariationot
			frame = a.frame * lifetime
			If age < frame
				p = (age - lastf) / (frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_framerate:Float(age:Int, lifetime:Float)
		Local lastv:Float
		Local lastf:Float
		Local frame:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn framerate
			frame = a.frame * lifetime
			If age < frame
				p = (age - lastf) / (frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlFRAMERATE_MIN, tlFRAMERATE_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	Method interpolate_stretch:Float(age:Int, lifetime:Float)
		Local lastv:Float
		Local lastf:Float
		Local frame:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn stretch
			frame = a.frame * lifetime
			If age < frame
				p = (age - lastf) / (frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	'-----Global interpolations-----
	Method interpolate_globalvelocity:Float(age:Int)
		Local lastv:Float
		Local lastf:Float
		Local p:Float
		Local lastec:tlAttributeNode
		For Local a:tlAttributeNode = EachIn globalvelocity
			If age < a.frame
				p = (age - lastf) / (a.frame - lastf)
				Local BezierValue:Float = GetBezierValue(lastec, a, p, tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX)
				If BezierValue
					Return BezierValue
				Else
					Return lastv - p * (lastv - a.value)
				End If
			End If
			lastv = a.value
			lastf = a.frame - 1
			lastec = a
		Next
		Return lastv
	End Method
	
	'Compilers
	Method compile_all()
		compile_life()
		compile_lifevariation()
		compile_amount()
		compile_sizex()
		compile_sizey()
		compile_basespeed()
		compile_baseweight()
		compile_basespin()
		compile_emissionangle()
		compile_emissionrange()
		compile_splatter()
		compile_velvariation()
		compile_weightvariation()
		compile_amountvariation()
		compile_sizexvariation()
		compile_sizeyvariation()
		compile_spinvariation()
		compile_directionvariation()
		compile_alpha()
		compile_scalex()
		compile_scaley()
		compile_spin()
		compile_velocity()
		compile_weight()
		compile_direction()
		compile_directionvariationot()
		compile_framerate()
		compile_stretch()
		compile_globalvelocity()
		compile_r()
		compile_g()
		compile_b()
		For Local e:tlEffect = EachIn effects
			e.compile_all()
		Next
		analyse_emitter()
	End Method
	Method Compile_Quick()
		Local longestlife:Float = getlongestlife()
		c_alpha = New tlEmitterArray.Create(1)
		c_alpha.changes[0] = interpolate_alpha(0, longestlife)
		c_r = New tlEmitterArray.Create(1)
		c_g = New tlEmitterArray.Create(1)
		c_b = New tlEmitterArray.Create(1)
		c_r.changes[0] = interpolate_r(0, longestlife)
		c_g.changes[0] = interpolate_g(0, longestlife)
		c_b.changes[0] = interpolate_b(0, longestlife)
		c_scalex = New tlEmitterArray.Create(1)
		c_scaley = New tlEmitterArray.Create(1)
		c_scalex.changes[0] = interpolate_scalex(0, longestlife)
		c_scaley.changes[0] = interpolate_scaley(0, longestlife)
		c_velocity = New tlEmitterArray.Create(1)
		c_velocity.changes[0] = interpolate_velocity(0, longestlife)
		c_weight = New tlEmitterArray.Create(1)
		c_weight.changes[0] = interpolate_weight(0, longestlife)
		c_direction = New tlEmitterArray.Create(1)
		c_direction.changes[0] = interpolate_direction(0, longestlife)
		c_directionvariationot = New tlEmitterArray.Create(1)
		c_directionvariationot.changes[0] = interpolate_directionvariationot(0, longestlife)
		c_framerate = New tlEmitterArray.Create(1)
		c_framerate.changes[0] = interpolate_framerate(0, longestlife)
		c_stretch = New tlEmitterArray.Create(1)
		c_stretch.changes[0] = interpolate_stretch(0, longestlife)
		c_splatter = New tlEmitterArray.Create(1)
		c_splatter.changes[0] = interpolate_splatter(0)
	End Method
	Method Analyse_Emitter()
		resetbypassers()
		If Not c_lifevariation.lastframe
			If Not get_lifevariation(0)
				bypass_lifevariaton = True
			End If
		End If
		If Not get_stretch(0, 1)
			bypass_stretch = True
		End If
		If Not c_framerate.lastframe
			If Not get_splatter(0)
				bypass_framerate = True
			End If
		End If
		If Not c_splatter.lastframe And Not c_splatter.changes[0]
			bypass_splatter = True
		End If
		If Not c_baseweight.lastframe And Not c_weightvariation.lastframe
			If Not get_baseweight(0) And Not get_weightvariation(0)
				bypass_weight = True
			End If
		End If
		If Not c_weight.lastframe And Not c_weight.changes[0]
			bypass_weight = True
		End If
		If Not c_basespeed.lastframe And Not c_velvariation.lastframe
			If Not get_basespeed(0) And Not get_velvariation(0)
				bypass_speed = True
			End If
		End If
		If Not c_basespin.lastframe And Not c_spinvariation.lastframe
			If Not get_basespin(0) And Not get_spinvariation(0)
				bypass_spin = True
			End If
		End If
		If Not c_directionvariation.lastframe
			If Not get_directionvariation(0)
				bypass_directionvariation = True
			End If
		End If
		If Not r.Count() Or r.Count() = 1
			b_red = get_r(0, 1)
			b_green = get_g(0, 1)
			b_blue = get_b(0, 1)
			bypass_colour = True
		End If
		If Not scalex.Count() Or scalex.Count() = 1
			bypass_scalex = True
		End If
		If Not scaley.Count() Or scaley.Count() = 1
			bypass_scaley = True
		End If
	End Method
	Method ResetByPassers()
		bypass_weight = False
		bypass_speed = False
		bypass_spin = False
		bypass_directionvariation = False
		bypass_colour = False
		b_red = False
		b_green = False
		b_blue = False
		bypass_scalex = False
		bypass_scaley = False
		bypass_lifevariaton = False
		bypass_framerate = False
		bypass_stretch = False
		bypass_splatter = False
	End Method
	'-------------
	Method getlongestlife:Float()
		Local longestlife:Float
		If c_life.lastframe >= c_lifevariation.lastframe And c_life.lastframe >= parentEffect.c_life.lastframe
			For Local frame:Int = 0 To c_life.lastframe
				Local templife:Float = (get_lifevariation(frame) + get_life(frame)) * parentEffect.get_life(frame)
				If templife > longestlife
					longestlife = templife
				End If
			Next
		End If
		If c_lifevariation.lastframe >= c_life.lastframe And c_lifevariation.lastframe >= parentEffect.c_life.lastframe
			For Local frame:Int = 0 To c_lifevariation.lastframe
				Local templife:Float = (get_lifevariation(frame) + get_life(frame)) * parentEffect.get_life(frame)
				If templife > longestlife
					longestlife = templife
				End If
			Next
		End If
		If parentEffect.c_life.lastframe >= c_life.lastframe And parentEffect.c_life.lastframe >= c_lifevariation.lastframe
			For Local frame:Int = 0 To parentEffect.c_life.lastframe
				Local templife:Float = (get_lifevariation(frame) + get_life(frame)) * parentEffect.get_life(frame)
				If templife > longestlife
					longestlife = templife
				End If
			Next
		End If
		Return longestlife
	End Method
	'-----Spawn values over effect age compilers-----
	Method compile_life()
		If life.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(life.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_life = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_life.changes[frame] = interpolate_life(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_life.changes[frame] = lastec.value
		Else
			c_life = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_lifevariation()
		If lifevariation.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(lifevariation.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_lifevariation = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_lifevariation.changes[frame] = interpolate_lifevariation(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_lifevariation.changes[frame] = lastec.value
		Else
			c_lifevariation = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_amount()
		If amount.count()
			Local lastec:tlAttributeNode = tlAttributeNode(amount.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_amount = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_amount.changes[frame] = interpolate_amount(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_amount.changes[frame] = lastec.value
		Else
			c_amount = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_sizex()
		If sizex.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(sizex.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_sizex = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_sizex.changes[frame] = interpolate_sizex(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_sizex.changes[frame] = lastec.value
		Else
			c_sizex = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_sizey()
		If sizey.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(sizey.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_sizey = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_sizey.changes[frame] = interpolate_sizey(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_sizey.changes[frame] = lastec.value
		Else
			c_sizey = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_basespeed()
		If basespeed.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(basespeed.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_basespeed = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_basespeed.changes[frame] = interpolate_basespeed(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_basespeed.changes[frame] = lastec.value
		Else
			c_basespeed = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_baseweight()
		If baseweight.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(baseweight.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_baseweight = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_baseweight.changes[frame] = interpolate_baseweight(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_baseweight.changes[frame] = lastec.value
		Else
			c_baseweight = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_basespin()
		If basespin.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(basespin.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_basespin = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_basespin.changes[frame] = interpolate_basespin(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_basespin.changes[frame] = lastec.value
		Else
			c_basespin = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_emissionangle()
		If emissionangle.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(emissionangle.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_emissionangle = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_emissionangle.changes[frame] = interpolate_emissionangle(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_emissionangle.changes[frame] = lastec.value
		Else
			c_emissionangle = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_emissionrange()
		If emissionrange.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(emissionrange.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_emissionrange = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_emissionrange.changes[frame] = interpolate_emissionrange(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_emissionrange.changes[frame] = lastec.value
		Else
			c_emissionrange = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_splatter()
		If splatter.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(splatter.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_splatter = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_splatter.changes[frame] = interpolate_splatter(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_splatter.changes[frame] = lastec.VALUE
		Else
			c_splatter = New tlEmitterArray.Create(1)
		End If
	End Method
	'-----Spawn variation values over effect age compilers-----
	Method compile_velvariation()
		If velvariation.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(velvariation.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_velvariation = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_velvariation.changes[frame] = interpolate_velvariation(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_velvariation.changes[frame] = lastec.value
		Else
			c_velvariation = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_weightvariation()
		If weightvariation.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(weightvariation.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_weightvariation = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_weightvariation.changes[frame] = interpolate_weightvariation(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_weightvariation.changes[frame] = lastec.value
		Else
			c_weightvariation = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_amountvariation()
		If amountvariation.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(amountvariation.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_amountvariation = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_amountvariation.changes[frame] = interpolate_amountvariation(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_amountvariation.changes[frame] = lastec.value
		Else
			c_amountvariation = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_sizexvariation()
		If sizexvariation.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(sizexvariation.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_sizexvariation = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_sizexvariation.changes[frame] = interpolate_sizexvariation(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_sizexvariation.changes[frame] = lastec.value
		Else
			c_sizexvariation = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_sizeyvariation()
		If sizeyvariation.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(sizeyvariation.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_sizeyvariation = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_sizeyvariation.changes[frame] = interpolate_sizeyvariation(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_sizeyvariation.changes[frame] = lastec.value
		Else
			c_sizeyvariation = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_spinvariation()
		If spinvariation.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(spinvariation.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_spinvariation = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_spinvariation.changes[frame] = interpolate_spinvariation(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_spinvariation.changes[frame] = lastec.value
		Else
			c_spinvariation = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_directionvariation()
		If directionvariation.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(directionvariation.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_directionvariation = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_directionvariation.changes[frame] = interpolate_directionvariation(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_directionvariation.changes[frame] = lastec.value
		Else
			c_directionvariation = New tlEmitterArray.Create(1)
		End If
	End Method
	'-----Particle over life interpolation Compilers----
	Method compile_alpha()
		If alpha.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(alpha.Last())
			Local frame:Int
			Local _age:Int
			Local longestlife:Int = getlongestlife()
			While _age < longestlife
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_alpha = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < longestlife
				c_alpha.changes[frame] = interpolate_alpha(_age, longestlife)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_alpha.changes[frame] = lastec.value
			c_alpha.life = longestlife
		Else
			c_alpha = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_r()
		If r.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(r.Last())
			Local frame:Int
			Local _age:Int
			Local longestlife:Int = getlongestlife()
			While _age < longestlife
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_r = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < longestlife
				c_r.changes[frame] = interpolate_r(_age, longestlife)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_r.changes[frame] = lastec.value
			c_r.life = longestlife
		Else
			c_r = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_g()
		If g.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(g.Last())
			Local frame:Int
			Local _age:Int
			Local longestlife:Int = getlongestlife()
			While _age < longestlife
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_g = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < longestlife
				c_g.changes[frame] = interpolate_g(_age, longestlife)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_g.changes[frame] = lastec.value
			c_g.life = longestlife
		Else
			c_g = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_b()
		If b.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(b.Last())
			Local frame:Int
			Local _age:Int
			Local longestlife:Int = getlongestlife()
			While _age < longestlife
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_b = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < longestlife
				c_b.changes[frame] = interpolate_b(_age, longestlife)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_b.changes[frame] = lastec.value
			c_b.life = longestlife
		Else
			c_b = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_scalex()
		If scalex.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(scalex.Last())
			Local frame:Int
			Local _age:Int
			Local longestlife:Int = getlongestlife()
			While _age < longestlife
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_scalex = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < longestlife
				c_scalex.changes[frame] = interpolate_scalex(_age, longestlife)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_scalex.changes[frame] = lastec.value
			c_scalex.life = longestlife
		Else
			c_scalex = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_scaley()
		If scaley.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(scaley.Last())
			Local frame:Int
			Local _age:Int
			Local longestlife:Int = getlongestlife()
			While _age < longestlife
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_scaley = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < longestlife
				c_scaley.changes[frame] = interpolate_scaley(_age, longestlife)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_scaley.changes[frame] = lastec.value
			c_scaley.life = longestlife
		Else
			c_scaley = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_spin()
		If spin.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(spin.Last())
			Local frame:Int
			Local _age:Int
			Local longestlife:Int = getlongestlife()
			While _age < longestlife
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_spin = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < longestlife
				c_spin.changes[frame] = interpolate_spin(_age, longestlife)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_spin.changes[frame] = lastec.value
			c_spin.life = longestlife
		Else
			c_spin = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_velocity()
		If velocity.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(velocity.Last())
			Local frame:Int
			Local _age:Int
			Local longestlife:Int = getlongestlife()
			While _age < longestlife
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_velocity = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < longestlife
				c_velocity.changes[frame] = interpolate_velocity(_age, longestlife)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_velocity.changes[frame] = lastec.value
			c_velocity.life = longestlife
		Else
			c_velocity = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_weight()
		If weight.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(weight.Last())
			Local frame:Int
			Local _age:Int
			Local longestlife:Int = getlongestlife()
			While _age < longestlife
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_weight = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < longestlife
				c_weight.changes[frame] = interpolate_weight(_age, longestlife)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_weight.changes[frame] = lastec.value
			c_weight.life = longestlife
		Else
			c_weight = New tlEmitterArray.Create(1)
		End If

	End Method
	Method compile_direction()
		If direction.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(direction.Last())
			Local frame:Int
			Local _age:Int
			Local longestlife:Int = getlongestlife()
			While _age < longestlife
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_direction = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < longestlife
				c_direction.changes[frame] = interpolate_direction(_age, longestlife)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_direction.changes[frame] = lastec.value
			c_direction.life = longestlife
		Else
			c_direction = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_directionvariationot()
		If directionvariationot.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(directionvariationot.Last())
			Local frame:Int
			Local _age:Int
			Local longestlife:Int = getlongestlife()
			While _age < longestlife
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_directionvariationot = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < longestlife
				c_directionvariationot.changes[frame] = interpolate_directionvariationot(_age, longestlife)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_directionvariationot.changes[frame] = lastec.value
			c_directionvariationot.life = longestlife
		Else
			c_directionvariationot = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_framerate()
		If framerate.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(framerate.Last())
			Local frame:Int
			Local _age:Int
			Local longestlife:Int = getlongestlife()
			While _age < longestlife
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_framerate = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < longestlife
				c_framerate.changes[frame] = interpolate_framerate(_age, longestlife)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_framerate.changes[frame] = lastec.value
			c_framerate.life = longestlife
		Else
			c_framerate = New tlEmitterArray.Create(1)
		End If
	End Method
	Method compile_stretch()
		If stretch.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(stretch.Last())
			Local frame:Int
			Local _age:Int
			Local longestlife:Int = getlongestlife()
			While _age < longestlife
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_stretch = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < longestlife
				c_stretch.changes[frame] = interpolate_stretch(_age, longestlife)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY_OVERTIME
			Wend
			c_stretch.changes[frame] = lastec.VALUE
			c_stretch.life = longestlife
		Else
			c_stretch = New tlEmitterArray.Create(1)
		End If
	End Method
	'-----Global Compilers-----
	Method compile_globalvelocity()
		If globalvelocity.Count()
			Local lastec:tlAttributeNode = tlAttributeNode(globalvelocity.Last())
			Local frame:Int
			Local _age:Int
			While _age < lastec.frame
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_globalvelocity = New tlEmitterArray.Create(frame + 1)
			frame = 0
			_age = 0
			While _age < lastec.frame
				c_globalvelocity.changes[frame] = interpolate_globalvelocity(_age)
				frame:+1
				_age:+tp_LOOKUP_FREQUENCY
			Wend
			c_globalvelocity.changes[frame] = lastec.value
		Else
			c_globalvelocity = New tlEmitterArray.Create(1)
		End If
	End Method
	'lookups
	'Base
	Method get_life:Float(frame:Int)
		If frame <= c_life.lastframe
			Return c_life.changes[frame]
		Else
			Return c_life.changes[c_life.lastframe]
		End If
	End Method
	Method get_lifevariation:Float(frame:Int)
		If frame <= c_lifevariation.lastframe
			Return c_lifevariation.changes[frame]
		Else
			Return c_lifevariation.changes[c_lifevariation.lastframe]
		End If
	End Method
	Method get_amount:Float(frame:Int)
		If frame <= c_amount.lastframe
			Return c_amount.changes[frame]
		Else
			Return c_amount.changes[c_amount.lastframe]
		End If
	End Method
	Method get_sizex:Float(frame:Int)
		If frame <= c_sizex.lastframe
			Return c_sizex.changes[frame]
		Else
			Return c_sizex.changes[c_sizex.lastframe]
		End If
	End Method
	Method get_sizey:Float(frame:Int)
		If frame <= c_sizey.lastframe
			Return c_sizey.changes[frame]
		Else
			Return c_sizey.changes[c_sizey.lastframe]
		End If
	End Method
	Method get_basespeed:Float(frame:Int)
		If frame <= c_basespeed.lastframe
			Return c_basespeed.changes[frame]
		Else
			Return c_basespeed.changes[c_basespeed.lastframe]
		End If
	End Method
	Method get_baseweight:Float(frame:Int)
		If frame <= c_baseweight.lastframe
			Return c_baseweight.changes[frame]
		Else
			Return c_baseweight.changes[c_baseweight.lastframe]
		End If
	End Method
	Method get_basespin:Float(frame:Int)
		If frame <= c_basespin.lastframe
			Return c_basespin.changes[frame]
		Else
			Return c_basespin.changes[c_basespin.lastframe]
		End If
	End Method
	Method get_emissionangle:Float(frame:Int)
		If frame <= c_emissionangle.lastframe
			Return c_emissionangle.changes[frame]
		Else
			Return c_emissionangle.changes[c_emissionangle.lastframe]
		End If
	End Method
	Method get_emissionrange:Float(frame:Int)
		If frame <= c_emissionrange.lastframe
			Return c_emissionrange.changes[frame]
		Else
			Return c_emissionrange.changes[c_emissionrange.lastframe]
		End If
	End Method
	Method get_splatter:Float(frame:Int)
		If frame <= c_splatter.lastframe
			Return c_splatter.changes[frame]
		Else
			Return c_splatter.changes[c_splatter.lastframe]
		End If
	End Method
	'Variations
	Method get_velvariation:Float(frame:Int)
		If frame <= c_velvariation.lastframe
			Return c_velvariation.changes[frame]
		Else
			Return c_velvariation.changes[c_velvariation.lastframe]
		End If
	End Method
	Method get_weightvariation:Float(frame:Int)
		If frame <= c_weightvariation.lastframe
			Return c_weightvariation.changes[frame]
		Else
			Return c_weightvariation.changes[c_weightvariation.lastframe]
		End If
	End Method
	Method get_amountvariation:Float(frame:Int)
		If frame <= c_amountvariation.lastframe
			Return c_amountvariation.changes[frame]
		Else
			Return c_amountvariation.changes[c_amountvariation.lastframe]
		End If
	End Method
	Method get_sizexvariation:Float(frame:Int)
		If frame <= c_sizexvariation.lastframe
			Return c_sizexvariation.changes[frame]
		Else
			Return c_sizexvariation.changes[c_sizexvariation.lastframe]
		End If
	End Method
	Method get_sizeyvariation:Float(frame:Int)
		If frame <= c_sizeyvariation.lastframe
			Return c_sizeyvariation.changes[frame]
		Else
			Return c_sizeyvariation.changes[c_sizeyvariation.lastframe]
		End If
	End Method
	Method get_spinvariation:Float(frame:Int)
		If frame <= c_spinvariation.lastframe
			Return c_spinvariation.changes[frame]
		Else
			Return c_spinvariation.changes[c_spinvariation.lastframe]
		End If
	End Method
	Method get_directionvariation:Float(frame:Int)
		If frame <= c_directionvariation.lastframe
			Return c_directionvariation.changes[frame]
		Else
			Return c_directionvariation.changes[c_directionvariation.lastframe]
		End If
	End Method
	'Over lifetime
	Method get_alpha:Float(age:Float, lifetime:Float)
		Local frame:Int
		If lifetime > 0
			If tp_LOOKUP_FREQUENCY_OVERTIME = 1
				frame = age / lifetime * c_alpha.life
			Else
				frame = ((age / lifetime) * c_alpha.life) / tp_LOOKUP_FREQUENCY_OVERTIME
			End If
		End If
		If frame <= c_alpha.lastframe
			Return c_alpha.changes[frame]
		Else
			Return c_alpha.changes[c_alpha.lastframe]
		End If
	End Method
	Method get_r:Float(age:Float, lifetime:Float)
		Local frame:Int
		If lifetime > 0
			If tp_LOOKUP_FREQUENCY_OVERTIME = 1
				frame = age / lifetime * c_r.life
			Else
				frame = ((age / lifetime) * c_r.life) / tp_LOOKUP_FREQUENCY_OVERTIME
			End If
		End If
		If frame <= c_r.lastframe
			Return c_r.changes[frame]
		Else
			Return c_r.changes[c_r.lastframe]
		End If
	End Method
	Method get_g:Float(age:Float, lifetime:Float)
		Local frame:Int
		If lifetime > 0
			If tp_LOOKUP_FREQUENCY_OVERTIME = 1
				frame = age / lifetime * c_g.life
			Else
				frame = ((age / lifetime) * c_g.life) / tp_LOOKUP_FREQUENCY_OVERTIME
			End If
		End If
		If frame <= c_g.lastframe
			Return c_g.changes[frame]
		Else
			Return c_g.changes[c_g.lastframe]
		End If
	End Method
	Method get_b:Float(age:Float, lifetime:Float)
		Local frame:Int
		If lifetime > 0
			If tp_LOOKUP_FREQUENCY_OVERTIME = 1
				frame = age / lifetime * c_b.life
			Else
				frame = ((age / lifetime) * c_b.life) / tp_LOOKUP_FREQUENCY_OVERTIME
			End If
		End If
		If frame <= c_b.lastframe
			Return c_b.changes[frame]
		Else
			Return c_b.changes[c_b.lastframe]
		End If
	End Method
	Method get_scalex:Float(age:Float, lifetime:Float)
		Local frame:Int
		If lifetime > 0
			If tp_LOOKUP_FREQUENCY_OVERTIME = 1
				frame = age / lifetime * c_scalex.life
			Else
				frame = ((age / lifetime) * c_scalex.life) / tp_LOOKUP_FREQUENCY_OVERTIME
			End If
		End If
		If frame <= c_scalex.lastframe
			Return c_scalex.changes[frame]
		Else
			Return c_scalex.changes[c_scalex.lastframe]
		End If
	End Method
	Method get_scaley:Float(age:Float, lifetime:Float)
		Local frame:Int
		If lifetime > 0
			If tp_LOOKUP_FREQUENCY_OVERTIME = 1
				frame = age / lifetime * c_scaley.life
			Else
				frame = ((age / lifetime) * c_scaley.life) / tp_LOOKUP_FREQUENCY_OVERTIME
			End If
		End If
		If frame <= c_scaley.lastframe
			Return c_scaley.changes[frame]
		Else
			Return c_scaley.changes[c_scaley.lastframe]
		End If
	End Method
	Method get_spin:Float(age:Float, lifetime:Float)
		Local frame:Int
		If lifetime > 0
			If tp_LOOKUP_FREQUENCY_OVERTIME = 1
				frame = age / lifetime * c_spin.life
			Else
				frame = ((age / lifetime) * c_spin.life) / tp_LOOKUP_FREQUENCY_OVERTIME
			End If
		End If
		If frame <= c_spin.lastframe
			Return c_spin.changes[frame]
		Else
			Return c_spin.changes[c_spin.lastframe]
		End If
	End Method
	Method get_velocity:Float(age:Float, lifetime:Float)
		Local frame:Int
		If lifetime > 0
			If tp_LOOKUP_FREQUENCY_OVERTIME = 1
				frame = age / lifetime * c_velocity.life
			Else
				frame = ((age / lifetime) * c_velocity.life) / tp_LOOKUP_FREQUENCY_OVERTIME
			End If
		End If
		If frame <= c_velocity.lastframe
			Return c_velocity.changes[frame]
		Else
			Return c_velocity.changes[c_velocity.lastframe]
		End If
	End Method
	Method get_weight:Float(age:Float, lifetime:Float)
		Local frame:Int
		If lifetime > 0
			If tp_LOOKUP_FREQUENCY_OVERTIME = 1
				frame = age / lifetime * c_weight.life
			Else
				frame = ((age / lifetime) * c_weight.life) / tp_LOOKUP_FREQUENCY_OVERTIME
			End If
		End If
		If frame <= c_weight.lastframe
			Return c_weight.changes[frame]
		Else
			Return c_weight.changes[c_weight.lastframe]
		End If
	End Method
	Method get_direction:Float(age:Float, lifetime:Float)
		Local frame:Int
		If lifetime > 0
			If tp_LOOKUP_FREQUENCY_OVERTIME = 1
				frame = age / lifetime * c_direction.life
			Else
				frame = ((age / lifetime) * c_direction.life) / tp_LOOKUP_FREQUENCY_OVERTIME
			End If
		End If
		If frame <= c_direction.lastframe
			Return c_direction.changes[frame]
		Else
			Return c_direction.changes[c_direction.lastframe]
		End If
	End Method
	Method get_directionvariationot:Float(age:Float, lifetime:Float)
		Local frame:Int
		If lifetime > 0
			If tp_LOOKUP_FREQUENCY_OVERTIME = 1
				frame = age / lifetime * c_directionvariationot.life
			Else
				frame = ((age / lifetime) * c_directionvariationot.life) / tp_LOOKUP_FREQUENCY_OVERTIME
			End If
		End If
		If frame <= c_directionvariationot.lastframe
			Return c_directionvariationot.changes[frame]
		Else
			Return c_directionvariationot.changes[c_directionvariationot.lastframe]
		End If
	End Method
	Method get_framerate:Float(age:Float, lifetime:Float)
		Local frame:Int
		If lifetime > 0
			If tp_LOOKUP_FREQUENCY_OVERTIME = 1
				frame = age / lifetime * c_framerate.life
			Else
				frame = ((age / lifetime) * c_framerate.life) / tp_LOOKUP_FREQUENCY_OVERTIME
			End If
		End If
		If frame <= c_framerate.lastframe
			Return c_framerate.changes[frame]
		Else
			Return c_framerate.changes[c_framerate.lastframe]
		End If
	End Method
	Method get_stretch:Float(age:Float, lifetime:Float)
		Local frame:Int
		If lifetime > 0
			If tp_LOOKUP_FREQUENCY_OVERTIME = 1
				frame = age / lifetime * c_stretch.life
			Else
				frame = ((age / lifetime) * c_stretch.life) / tp_LOOKUP_FREQUENCY_OVERTIME
			End If
		End If
		If frame <= c_stretch.lastframe
			Return c_stretch.changes[frame]
		Else
			Return c_stretch.changes[c_stretch.lastframe]
		End If
	End Method
	'global adjusters
	Method get_globalvelocity:Float(frame:Int)
		If frame <= c_globalvelocity.lastframe
			Return c_globalvelocity.changes[frame]
		Else
			Return c_globalvelocity.changes[c_globalvelocity.lastframe]
		End If
	End Method
End Type
Rem
	bbdoc: Particle Type - extends tlEntity
	about: This is the object that is spawned by emitter types and maintained by a Particle Manager. Particles are controlled by the emitters and effects they're
	parented to.
endrem
Type tlParticle Extends tlEntity
	'---------------------------------
	Field emitter:tlEmitter									'emitter it belongs to
	'---------------------------------
	Field weightvariation:Float								'Particle weight variation
	Field scalevariationx:Float								'particle size x variation
	Field scalevariationy:Float								'particle size y variation
	Field gsizex:Float										'Particle global size x
	Field gsizey:Float										'Particle global size y
	'---------------------------------
	Field velvariation:Float								'velocity variation
	Field velseed:Float										'rnd seed
	'---------------------------------
	Field spinvariation:Float								'variation of spin speed
	'---------------------------------
	Field directionvariaion:Float							'Direction variation at spawn time
	Field timetracker:Int									'This is used to keep track of game ticks so that some things can be updated between specific time intervals
	Field randomdirection:Float								'current direction of the random motion that pulls the particle in different directions
	Field randomspeed:Float									'random speed to apply to the particle movement
	Field emissionangle:Float								'Direction variation at spawn time
	Field releasesingleparticle:Int							'set to true to release single particles and let them decay and die
	'---------------------------------
	Field PM:tlParticleManager								'link to the particle manager
	Field layer:Int											'layer the particle belongs to
	Field groupparticles:Int								'whether the particle is added the PM pool or kept in the emitter's pool
	Field effectlayer:Int

	Rem
		bbdoc: Updates the particle.
		about: This is called by the emitter the particle is parented to.
	endrem
	Method update()
	
		capture()
		
		If emitter.dying = 1 Or emitter.oneshot Or dead releasesingleparticle = True
	
		If emitter.singleparticle And Not releasesingleparticle
			age = PM.CURRENT_TIME - dob
			If age > lifetime
				age = 0
				dob = PM.CURRENT_TIME
			End If
		Else
			age = PM.CURRENT_TIME - dob
		End If
		
		Super.update()
				
		If age > lifetime Or dead = 2	'if dead=2 then that means its reached the end of the line (in kill mode) for line traversal effects
			dead = True
			If Not childcount
				pm.ReleaseParticle(Self)
				If emitter.groupparticles
					emitter.parentEffect.inuse[layer].Remove Self
				End If
				parent.removechild(Self)
				reset()
			Else
				emitter.controlparticle(Self)
				killchildren()
			End If
			
			Return
		End If
		
		emitter.controlparticle(Self)
			
	End Method
	Rem
		bbdoc: Resets the particle so it's ready to be recycled by the particle manager
	endrem
	Method reset()
		age = 0
		wx = 0
		wy = 0
		z = 1
		avatar = Null
		dead = False
		clearchildren()
		childcount = 0
		directionvariaion = 0
		direction = 0
		directionlocked = False
		randomspeed = 0
		randomdirection = 0
		parent = Null
		rootparent = Null
		acycles = 0
		ccycles = 0
		rptageA = 0
		rptageC = 0
		releasesingleparticle = 0
		gravity = 0
		weight = 0
		emitter = Null
	End Method
	Method destroy()
		pm.ReleaseParticle(Self)
		Super.Destroy()
		reset()
	End Method
	Rem
		bbdoc: Set the current x coordinate of the particle and capture the old value
	endrem
	Method setx(v:Float)
		If age
			oldx = x
		Else
			oldx = v
		End If
		x = v
	End Method
	Rem
		bbdoc: Set the current y coordinate of the particle and capture the old value
	endrem
	Method sety(v:Float) 
		If age
			oldy = y
		Else
			oldy = v
		End If
		y = v
	End Method
	Rem
		bbdoc: Set the current zoom factor of the particle and capture the old value
	endrem
	Method setz(v:Float)
		If age
			oldz = z
		Else
			oldz = v
		End If
		z = v
	End Method
End Type
Rem
	bbdoc: Attribute Node type
	about: <p>An Attribute Node is basically a type used to store effect and emitter attributes. They are in effect nodes on a line graph so that when an effect plays 
	out the attribute value is looked up on the line graph and interpolated if the current time is imbetween 2 attribute nodes. Think of the x-axis of the graph
	as the time in milliseconds and the y-axis representing the value of the attribute. The line don't have to just be linear either, they can also be curves, see
	#togglecurve and #setcurvepoints. The Timeline Particle Editor that comes with this module uses graphs to design the particle effects.</p>
endrem
Type tlAttributeNode
	Field frame:Float
	Field value:Float
	
	Field isCurve:Int
	
	Field c0x:Float
	Field c0y:Float
	Field c1x:Float
	Field c1y:Float
	
	Method compare:Int(obj:Object)
		If tlAttributeNode(obj)
			Return Sgn(frame - tlAttributeNode(obj).frame)
		End If
		Return - 1
	End Method
	Rem
	bbdoc: Set the curve points for the emitterchange
	about: x0 and y0 are the coordinates of the point to the left of the attribute node, x1 and y1 are the coordinates to the right of the attribute node. Setting
	these will create a bezier curve. The bezier curves are restricted so that they cannot be drawn so that they loop over or behind the frame of the attribute nodes.
	endrem
	Method SetCurvePoints(x0:Float, y0:Float, x1:Float, y1:Float)
		c0x = x0
		c0y = y0
		c1x = x1
		c1y = y1
		isCurve = True
	End Method
	Rem
	bbdoc: Toggle whether this attribute node is curved or linear
	endrem
	Method ToggleCurve()
		iscurve = Not iscurve
	End Method
End Type
Rem
	bbdoc: An attribute array type
	about: This Type stores the Attribute node graphs inside arrays for a faster lookup rather then having to interpolate in real-time. See #Compile_All
endrem
Type tlEmitterArray
	Field changes:Float[]
	Field lastframe:Int
	Field life:Int
	Method Create:tlEmitterArray(_frames:Int)
		changes = New Float[_frames]
		lastframe = _frames - 1
		Return Self
	End Method
	Method GetLastFrame:Int()
		Return lastframe
	End Method
End Type
Rem
	bbdoc: Particle manager for managing a list of effects and all the emitters and particles they contain
	about: <p>The particle manger is the main type you can use to easily manage all of the effects you want to use in your application. It will automatically update 
	all of the effects and draw the particles with a simple call to #Update and #DrawParticles.</p>
	<p>The simplist use of the particle manager would be to, create it, add an effect and then update and draw in your main loop:</p>
	&{<pre>
	Local MyEffectsLib:tlEffectsLibrary=LoadEffects("MyEffects.eff")
	local MyEffect:tlEffect=MyEffectsLib.GetEffect("Explosion")
	local MyParticleManager:tlParticleManager=CreateParticleManager()
	MyParticleManager.SetScreenSize(GraphicsWidth(),GraphicsHeight())
	MyParticleManager.AddEffect(MyEffect)
	Repeat
		cls
		MyParticleManager.Update()
		MyParticleManager.DrawParticles()
		flip
	Forever</pre>
	}
	<p>The particle manager maintains 2 lists of particles, an Inuse list for particles currently in the rendering pipeline and an UnUsed list for a pool of particles
	that can be used by emitters at any time. You can control the maximum number of particles a particle manager can use when you create it:</p>
	&{
		local MaximumParticles:int=2500
		local MyParticleManager:tlParticleManager=CreateParticleManager(MaximumParticles)
	}
	<p>When emitters need to spawn new particles they will try and grab the next available particle in the Unused list.</p>
	<p>The command #SetScreenSize tells the particle manager the size of the viewport currently being rendered to. With this information it locates the center of the
	screen. This is important because the effects do not locate themselves using screen coordinates, they instead use an abritrary set of world coordinates. So if you 
	place an effect at the coordinates 0,0 it will be drawn at the center of the screen. But don't worry, if you want to use screen coordinates to place your
	effects you can use the #SetOrigin command to offset the world coordinates to screen space:</p>
	&{
		MyParticleManager.SetScreenSize(GraphicsWidth(),GraphicsHeight())
		MyParticleManager.SetOrigin(GraphicsWidth()/2,GraphicsHeight()/2)
	}
	<p>This will place the origin at the top-left of the viewport so effects placed at 0,0 now will be drawn in the top-left corner of the screen in the same way DrawImage
	would. If however you application uses it's own world coordinate system to postion entities then it should be easy to use #SetOrigin to syncronise the location of any 
	effects with your app.</p>
	<p>You can now also define a number of effect layers when creating a particle manager. This enables you to control more easily the order
	in which effects are drawn. For example, if you create a particle manager with 10 layers, when you use #AddEffect you can specify
	which layer the effect is added to. Effects on layers 1 will draw on top of layers on layer 0, 2 over 1 etc. The layer index starts from 0, 
	so if you create 10 layers, their index will range from 0 to 9.</p>
endrem
Type tlParticleManager

	Field InUse:TList[,]
	Field UnUsed:TList = CreateList()
	
	Field unusedcount:Int
	Field inusecount:Int
	
	Field effects:TList[]
	
	Field Origin_X:Float
	Field Origin_Y:Float
	Field Origin_Z:Float = 1
	
	Field Old_Origin_X:Float
	Field Old_Origin_Y:Float
	Field Old_Origin_Z:Float = 1
	
	Field angle:Float
	Field oldangle:Float
	
	Field matrix:tlMatrix2 = New tlMatrix2.Create()
	Field rotvec:tlVector2 = New tlVector2.Create(0, 0)
	
	Field vp_w:Float
	Field vp_h:Float
	Field vp_x:Float
	Field vp_y:Float
	Field center_x:Float
	Field center_y:Float
	
	Field tv:Float
	Field tx:Float
	Field ty:Float
	Field tz:Float
	Field px:Float
	Field py:Float
	Field angletweened:Float
	
	Field globalamountscale:Float = 1
	
	Field camtx:Float
	Field camty:Float
	Field camtz:Float
	
	Field spawningallowed:Int = True
	Field testcount:Int
	
	Field paused:Int
	
	Field CURRENT_TIME:Float
	
	Field idletimelimit:Int = 100				'The time in game ticks before idle effects are automatically deleted
	
	Field updatemode:Int
	
	Field rendercount:Int
	Field currenttween:Float
	
	Field effectlayers:Int
		
	Rem
	bbdoc: Update the Particle Manager
	about: Run this method in your main loop to update all particle effects.
	endrem
	Method Update()
		If Not paused
			CURRENT_TIME:+tp_UPDATE_TIME
			For Local el:Int = 0 To effectlayers - 1
				For Local e:tlEffect = EachIn effects[el]
					e.update()
					If e.destroyed
						removeeffect(e)
					End If
				Next
			Next
			old_origin_x = origin_x
			old_origin_y = origin_y
			old_origin_z = origin_z
		End If
	End Method
	Rem
	bbdoc: Create a new Particle Manager
	about: Creates a new particle manager and sets the maximum number of particles. Default maximum is 5000.
	endrem
	Method Create:tlParticleManager(Particles:Int = tlPARTICLE_LIMIT, Layers:Int = 1)
		Local p:tlParticle
		InUse = New TList[Layers, 9]
		effects = New TList[Layers]
		effectlayers = Layers
		For Local el:Int = 0 To Layers - 1
			effects[el] = CreateList()
			For Local l:Int = 0 To 8
				InUse[el, l] = CreateList()
			Next
		Next
		For Local c:Int = 1 To particles
			p = New tlParticle
			p.SetOKToRender(False)
			UnUsed.AddLast p
		Next
		unusedcount = Particles
		Return Self
	End Method
	Method GrabParticle:tlParticle(effect:tlEffect, pool:Int, layer:Int = 0)
		If unusedcount
			Local p:tlParticle = tlParticle(unused.First())
			If p
				p.layer = layer
				unused.Remove p
				p.groupparticles = pool
				If pool
					effect.InUse[layer].AddLast p
				Else
					InUse[effect.effectlayer, layer].AddLast p
				End If
				unusedcount:-1
				inusecount:+1
				Return p
			End If
		End If
	End Method
	Method ReleaseParticle(p:tlParticle)
		unusedcount:+1
		inusecount:-1
		unused.AddLast p
		If Not p.groupparticles
			InUse[p.effectlayer, p.layer].Remove p
		End If
	End Method
	
	Rem
	bbdoc: Draw all particles currently in use
	about: Draws all pariticles in use and uses the tween value you pass to use render tween in order to smooth out the movement of effects assuming you
	use some kind of tweening code in your app. You can also specify the effect layer that is drawn, otherwise by default, all layers will be drawn.
	endrem
	Method DrawParticles(tween:Float = 1, Layer:Int = -1)
		'tween origin
		currenttween = tween
		camtx = -TweenValues(Old_Origin_X, Origin_X, tween)
		camty = -TweenValues(Old_Origin_Y, Origin_Y, tween)
		camtz = TweenValues(Old_Origin_Z, Origin_Z, tween)
		'record current GFX states
		Local c_alpha:Float = GetAlpha()
		Local c_rotation:Float = GetRotation()
		Local c_scalex:Float, c_scaley:Float
		GetScale(c_scalex, c_scaley)
		Local c_red:Int, c_green:Int, c_blue:Int
		GetColor(c_red, c_green, c_blue)
		'rendercount = 0
		If angle
			angletweened = TweenValues(oldangle, angle, tween)
			matrix.set(Cos(angletweened), Sin(angletweened), -Sin(angletweened), Cos(angletweened))
		End If
		Local layers:Int
		Local startlayer:Int
		If Layer = -1 Or Layer >= effectlayers
			layers = effectlayers - 1
		Else
			layers = Layer
			startlayer = Layer
		End If
		For Local el:Int = startlayer To layers
			For Local l:Int = 0 To 8
				For Local e:tlParticle = EachIn InUse[el, l]
					DrawParticle(e)
				Next
			Next
		Next
		DrawEffects()
		'restore GFX States
		SetAlpha c_alpha
		SetRotation c_rotation
		SetScale c_scalex, c_scaley
		SetColor c_red, c_green, c_blue
	End Method
	Method DrawBoundingBoxes()
		For Local el:Int = 0 To effectlayers - 1
			For Local e:tlEffect = EachIn effects[el]
				e.DrawBoundingBox()
			Next
		Next
	End Method
	Rem
	bbdoc: Set the Origin of the particle Manager.
	about: An origin at 0,0 represents the center of the screen assuming you have called #SetScreenSize. Passing a z value will zoom in or out. Values above 1
	will zoom out whilst values from 1 - 0 will zoom in. Values less then 0 will flip the particles being drawn.
	endrem
	Method SetOrigin(x:Float, y:Float, z:Float = 1)
		Old_Origin_X = Origin_X
		Old_Origin_Y = Origin_Y
		Old_Origin_Z = Origin_Z
		Origin_X = x
		Origin_Y = y
		Origin_Z = z
	End Method
	Rem
	bbdoc: Set the x origin
	about: See #SetOrigin
	endrem
	Method SetOrigin_X(v:Float)
		old_origin_x = Origin_X
		Origin_X = v
	End Method
	Rem
	bbdoc: Set the y origin
	about: See #SetOrigin
	endrem
	Method SetOrigin_Y(v:Float)
		old_origin_y = Origin_Y
		Origin_Y = v
	End Method
	Rem
	bbdoc: Set the level of zoom
	about: Values above 1 will zoom out whilst values from 1 - 0 will zoom in. Values less then 0 will flip the particles being drawn.
	endrem
	Method SetOrigin_Z(v:Float)
		old_origin_z = Origin_Z
		Origin_Z = v
	End Method
	Rem
	bbdoc: Set the angle of the particle manager
	about: Setting the angle of the particle manager will rotate all of the particles around the origin
	endrem
	Method SetAngle(v:Float)
		oldangle = angle
		angle = v
	End Method
	Rem
	bbdoc: Set the update mode for the particle manager
	about: There are 2 types of mode, compiled and interpolated. Compiled mode will force the particles to be updated using compiled lookup tables whereas interpolated mode
	will force the particles to use interpolation to update. Pass either either @tlUPDATE_MODE_COMPILED or @tlUPDATE_MODE_INTERPOLATED to set either mode. The default mode
	is compiled mode.
	end rem
	Method SetUpdateMode(mode:Int)
		updatemode = mode
	End Method
	Rem
	bbdoc: Set the current screen size
	about: Tells the particle manager the current size of the view port, whether its the screen size or canvas size if you're using a gui. 
	endrem
	Method SetScreenSize(w:Int, h:Int)
		vp_w = w
		vp_h = h
		center_x = vp_w / 2
		center_y = vp_h / 2
	End Method
	Rem
	bbdoc: Set the current screen position
	about: If you're rendering to a particular section of the screen then you can set the position of the viewport's top left coordinates using
			this command. Thanks to Imphy for the suggestion!
	endrem
	Method SetScreenPosition(x:Int, y:Int)
	   vp_x = x
	   vp_y = y
	End Method
	Rem
	bbdoc: Set the amount of time before idle effects are deleted from the particle manager
	about: Any effects that have no active particles being drawn on the screen will be automatically removed from the particle manager after a given time set by this function.
	endrem
	Method SetIdleTimeLimit(v:Int)
		idletimelimit = v
	End Method
	Rem
	bbdoc: Get the current x origin of the particle manager
	endrem
	Method GetOrigin_X:Float()
		Return Origin_X
	End Method
	Rem
	bbdoc: Get the current y origin of the particle manager
	endrem
	Method GetOrigin_Y:Float()
		Return Origin_Y
	End Method
	Rem
	bbdoc: Get the current z origin/zoom factor of the particle manager
	endrem
	Method GetOrigin_Z:Float()
		Return Origin_Z
	End Method
	Rem
	bbdoc: Get the current update mode for the particle manager
	returns: The current update mode of the particle manager. See #SetUpdateMode.
	end rem
	Method GetUpdateMode:Int()
		Return updatemode
	End Method
	Rem
		bbdoc: Get the globalamountscale value of the particle manager
		about: see #SetGlobalAmountScale for info about setting this value
	End Rem
	Method GetGlobalAmountScale:Float()
		Return globalamountscale
	End Method
	Rem
		bbdoc: Set the globalamountscale value of the particle manager
		about: Setting this value will scale the amount of the particles spawned by all emitters contained within the particle manager, making it a handy way
		to control globally, the amount of particles that are spawned. This can help improve performance on lower end hardware that struggle to draw
		lots of particles. A value of 1 (the default value) will spawn the default amount for each effect. A value of 0.5 though for example, will spawn
		half the amount of particles of each effect.
	End Rem
	Method SetGlobalAmountScale(Value:Float)
		globalamountscale = Value
	End Method
	
	Rem
	bbdoc: Get the current number of particles in use
	endrem
	Method GetParticlesInUse:Int()
		Return inusecount
	End Method
	Rem
	bbdoc: Get the current number of un used particles
	endrem
	Method GetParticlesUnUsed:Int()
		Return unusedcount
	End Method

	Rem
		bbdoc: Adds a New effect To the particle manager, and pre loads a given number of frames
		about: Use this method to add a new effect to the particle and start the effect running from whatever number of frames you pass to it.
		In most cases the overhead for this will be small, but for extremely heavy effects with many particles you may experience some performance hit.
		Use this instead of #addeffect if you want to pre load an effect. If the particle manager has more then one layer, then you can specify
		which layer the effect is added to. If the layer you pass does not exist then it will default to 0.
	endrem
	Method AddPreLoadedEffect(e:tlEffect, frames:Int, Layer:Int = 0)
		If Layer >= effectlayers Layer = 0
		Local temptime:Float = CURRENT_TIME
		CURRENT_TIME:-frames * tp_UPDATE_TIME
		e.ChangeDob(CURRENT_TIME)
		For Local c:Int = 1 To frames
			CURRENT_TIME:+tp_UPDATE_TIME
			e.update()
			If e.destroyed
				removeeffect(e)
			End If
		Next
		CURRENT_TIME = temptime
		e.effectlayer = Layer
		effects[Layer].AddLast e
	End Method	
	Rem
	bbdoc: Adds a new effect to the particle manager
	about: Use this method to add new effects to the particle manager which will be updated automatically. If the particle manager has more 
	then one layer, then you can specify which layer the effect is added to. If the layer you pass does not exist then it will default to 0.
	endrem
	Method AddEffect(e:tlEffect, Layer:Int = 0)
		If Layer >= effectlayers Layer = 0
		e.effectlayer = Layer
		'if the effect is a super effect, then just add the effects in the list
		If e.issuper
			For Local se:tlEffect = EachIn e.effects
				AddEffect(se, Layer)
			Next
		Else
			effects[Layer].AddLast e
		End If
	End Method
	Rem
	bbdoc: Removes an effect from the particle manager
	about: Use this method to remove effects from the particle manager. It's best to destroy the effect as well to avoid memory leaks
	endrem
	Method removeeffect(e:tlEffect)
		effects[e.effectlayer].Remove e
	End Method
	Rem
	bbdoc: Clear all particles in use
	about: Call this method to empty the list of in use particles and move them to the un used list.
	endrem
	Method ClearInUse()
		For Local el:Int = 0 To effectlayers - 1
			For Local l:Int = 0 To 8
				For Local p:tlParticle = EachIn InUse[el, l]
					unused.AddLast p
					unusedcount:+1
					inusecount:-1
					InUse[el, l].Remove p
					p.emitter.parentEffect.inuse[p.layer].Remove p
					p.reset()
				Next
			Next
		Next
	End Method
	Rem
	bbdoc: Destroy the particle manager
	about: This will destroy the particle, clearing all effects and particles. Use only when you are finished with the particle manager and want it removed
	to avoid any memory leaks.
	endrem
	Method destroy()
		Self.ClearAll()
		Self.ClearInUse()
		Self.UnUsed.Clear()
	End Method
	Rem
	bbdoc: Remove all effects and clear all particles in use
	about: If you want to remove all effects and particles from the manager then use this command. Every effect will instantly stop being
	rendered.
	endrem
	Method ClearAll()
		For Local el:Int = 0 To effectlayers - 1
			For Local e:tlEffect = EachIn effects[el]
				e.destroy()
			Next
			effects[el].Clear()
		Next
	End Method
	Rem
		bbdoc: Remove all effects and particles from a specific layer
		about: If you want to remove all effects and particles from a specific layer in the particle manager then use this command. Every effect will instantly stop being
		rendered.
	endrem
	Method ClearLayer(Layer:Int)
		For Local e:tlEffect = EachIn effects[Layer]
			e.destroy()
		Next
		effects[Layer].Clear()
	End Method
	Rem
	bbdoc: Release single particles
	about: If there are any singleparticles (see #SetSingleParticle) this will release all of them and allow them to age and die.
	endrem
	Method ReleaseParticles()
		For Local el:Int = 0 To effectlayers - 1
			For Local l:Int = 0 To 8
				For Local p:tlParticle = EachIn InUse[el, l]
					p.releasesingleparticle = True
				Next
			Next
		Next
	End Method
	Rem
	bbdoc: Pause and unpause the particle manager
	about: Pauses the drawing and updating of all effects within the particle manager.
	endrem
	Method Togglepause()
		paused = Not paused
	End Method
	Rem
		bbdoc: Interpolate between 2 values
		about: This is the function used to achieve render tweening by taking the old and new values and interpolating between the 2
	end rem
	Function TweenValues:Float(oldValue:Float, value:Float, tween:Float)
		Return oldValue + (value - oldValue) * tween
	End Function
	'internal methods-------
	Method DrawEffects()
		For Local el:Int = 0 To effectlayers - 1
			For Local eff:tlEffect = EachIn Self.effects[el]
				DrawEffect(eff)
			Next
		Next
	End Method
	Method DrawEffect(effect:tlEffect)
		For Local c:Int = 0 To 8
			For Local e:tlParticle = EachIn effect.inuse[c]
				DrawParticle(e)
				For Local subeff:tlEffect = EachIn e.children
					draweffect(subeff)
				Next
			Next
		Next
	End Method
	Method DrawParticle(e:tlParticle)
		If e.age Or e.emitter.singleparticle
			px = TweenValues(e.oldwx, e.wx, currenttween)
			py = TweenValues(e.oldwy, e.wy, currenttween)
			If angle
				rotvec:tlVector2 = matrix.transformvector(New tlVector2.Create(px, py))
				px = (rotvec.x * camtz) + center_x + (camtz * camtx)
				py = (rotvec.y * camtz) + center_y + (camtz * camty)
			Else
				px = (px * camtz) + center_x + (camtz * camtx)
				py = (py * camtz) + center_y + (camtz * camty)
			End If
			If px > vp_x - e.Image_Diameter And px < vp_x + vp_w + e.Image_Diameter And py > vp_y - e.Image_Diameter And py < vp_y + vp_h + e.Image_Diameter
				If e.avatar
					If e.emitter.handlecenter
						If e.avatar.frames = 1
							MidHandleImage(e.avatar.Image)
						Else
							SetImageHandle e.avatar.Image, e.avatar.width / 2, e.avatar.height / 2
						End If
					Else
						SetImageHandle e.avatar.image, e.handlex, e.handley
					End If
					SetBlend e.emitter.blendmode
					tv = TweenValues(e.oldangle, e.angle, currenttween)
					If e.emitter.anglerelative
						If Abs(e.oldrelativeangle - e.relativeangle) > 180
							tx = TweenValues(e.oldrelativeangle - 360, e.relativeangle, currenttween)
						Else
							tx = TweenValues(e.oldrelativeangle, e.relativeangle, currenttween)
						End If
						SetRotation tv + tx + angletweened
					Else
						SetRotation tv + angletweened
					End If
					tx = TweenValues(e.oldscalex, e.scalex, currenttween)
					ty = TweenValues(e.oldscaley, e.scaley, currenttween)
					tz = TweenValues(e.oldz, e.z, currenttween)
					If tz <> 1
						SetScale tx * tz * camtz, ty * tz * camtz
					Else
						SetScale tx * camtz, ty * camtz
					End If
					SetAlpha e.alpha
					SetColor e.Red, e.Green, e.Blue
					If e.animating
						tv = TweenValues(e.oldcurrentframe, e.currentframe, currenttween)
						If tv < 0
							tv = e.avatar.frames + tv Mod e.avatar.frames
							If tv = e.avatar.frames
								tv = 0
							End If
						Else
							tv = tv Mod e.avatar.frames
						End If
					Else
						tv = e.currentframe
					End If
					DrawSprite e.avatar, px, py, tv
					'rendercount:+1
				End If
			End If
		End If
	End Method
End Type