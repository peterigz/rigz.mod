
Rem

TDungeon
V0.1

December 2006


PURPOSE

	A simple class for generating 'perfect' mazes and 'imperfect' dungeons


TEST SYSTEMS

	Athlon 64 3200+, 2GB DDR400, ATI Radeon X800 GT 256MB GDDR3
	Intel Centrino 1600, 512MB DDR2, ATI Radeon Mobility X700 128MB
	Windows XP Pro SP2
	BlitzMax V1.24


MINIMUM REQUIREMENTS

	BlitzMax 1.24
	Windows XP (Linux and MacOS untested)


VERSION CHANGES

	0.1
	  * Initial release
	
	
CONSTANTS

	AREACLEAR_FULL
	AREACLEAR_PERIMETER
	
	AREATYPE_VOID
	AREATYPE_PILLARS
	AREATYPE_WALLED
	
	ENTRY_INCLUDECORNERS
	ENTRY_EXCLUDECORNERS
	
	
METHODS AND FUNCTIONS:
		
	generate
		checkNeighbour
		
	createArea
		clearCell
	makeAreas
	
	getWallGrid
	getAreaGrid

NOTES:
	
	Initially, all generated dungeons are 'perfect' mazes (that is, every cell in the maze is reachable by 
	every other cell).
	
	To create a more interesting dungeon, 'areas' are added to the maze. An area is a space that may be
	blank (void), or an empty 'room' with a number of 'entries'. Clever use of areas, alone or in combinations,
	can offer interesting results. See the relevent method and the associated examples for more 
	information.  
		
End Rem


SuperStrict

Const AREACLEAR_FULL:Int = 0
Const AREACLEAR_PERIMETER:Int = 1
Const AREATYPE_VOID:Int = 0
Const AREATYPE_PILLARS:Int = 1
Const AREATYPE_WALLED: Int = 2
Const ENTRY_INCLUDECORNERS:Int = 0
Const ENTRY_EXCLUDECORNERS:Int = 1


Type TDungeon

	Field SizeX:Int
	Field SizeZ:Int
	Field Dungeon:TDungeonCell[,]


	Method generate(seed:Int = 0, szx:Int = 16, szz:Int = 16)
	Rem
  	Creates a 'perfect' maze.
  	seed: random seed. Use Millisecs() to generate a different result every time.
  	szx: number of grid columns. Minimum 16.
	szz: number of grid rows. Minimum 16.
  	End Rem
	
		If szx < 1 Then SizeX = 16 Else SizeX = szx
		If szz < 1 Then SizeZ = 16 Else SizeZ = szz
	
		Dungeon = New TDungeonCell[SizeX, SizeZ]
	
		For Local x:Int = 0 To SizeX - 1
			For Local z:Int = 0 To SizeZ - 1
				Dungeon[x, z] = New TDungeonCell
				Dungeon[x, z].X = x
				Dungeon[x, z].Z = z
			Next
		Next
		
		SeedRnd seed
		
		Local totalcells:Int = SizeX * SizeZ
		Local cellstack:TDungeonCell[]
		cellstack = cellstack[..cellstack.length + 1]
		cellstack[cellstack.length - 1] = Dungeon[Rand(0, SizeX - 1), Rand(0, SizeZ - 1)]
		Local currentcell:TDungeonCell = cellstack[cellstack.length - 1]
		Local visitedcells:Int = 1

		Local x:Int = currentcell.X
		Local z:Int = currentcell.Z
	
		While visitedcells < totalcells And (Not KeyHit(KEY_ESCAPE))
		
			Local i:Int = -1
			Local neighbors:TDungeonCell[4]
			Local neighborsdir:Int[4]
	
			If x > 0 Then checkNeighbour(Dungeon[x - 1, z], 2, i, neighbors, neighborsdir)
			If x < (SizeX - 1) Then checkNeighbour(Dungeon[x + 1, z], 3, i, neighbors, neighborsdir)
			If z > 0 Then checkNeighbour(Dungeon[x, z - 1], 0, i, neighbors, neighborsdir)
			If z < (SizeZ - 1) Then checkNeighbour(Dungeon[x, z + 1], 1, i, neighbors, neighborsdir)
	
			If (i > -1)
				Local n:Int = Rand(0,i)
		
				Select neighborsdir[n]
					Case 0
						currentcell.WallN = False
						neighbors[n].WallS = False
					Case 1
						currentcell.WallS = False
						neighbors[n].WallN = False
					Case 2
						currentcell.WallW = False
						neighbors[n].WallE = False
					Case 3
						currentcell.WallE = False
						neighbors[n].WallW = False
				End Select
		
				cellstack = cellstack[..cellstack.length + 1]
				cellstack[cellstack.length - 1] = neighbors[n]
				currentcell = cellstack[cellstack.length - 1]
				x = currentcell.X
				z = currentcell.Z
		
				visitedcells :+ 1
			Else
				If cellstack.length > 0  
					currentcell = cellstack[cellstack.length - 1]
					x = currentcell.X
					z = currentcell.Z
					cellstack = cellstack[..cellstack.length - 1]
				EndIf
			EndIf
	
		Wend
	
	EndMethod


	Function checkNeighbour(cell:TDungeonCell Var, ndir:Int, i:Int Var, neighbors:TDungeonCell[] Var, neighborsdir:Int[] Var)
	Rem
	Utility Function used by the generate method.
	EndRem
	
		If ((cell.WallN = True) And (cell.WallS = True) And (cell.WallE = True) And (cell.WallW = True))
			i :+ 1
			neighbors[i] = cell
			neighborsdir[i] = ndir
		EndIf

	EndFunction
	

	Method createArea(id:Byte = 0, posx:Int, posz:Int, sx:Int, sz:Int, cleartyp:Int = AREACLEAR_FULL, typ:Int = AREATYPE_VOID, typdata1:Int = 0, typdata2:Int = ENTRY_INCLUDECORNERS)
	Rem
  	Create an 'area' within the dungeon.
	id: Area id number to assign to the area' cells. Minimum 0. Maximum 255.
  	posx: Top left column of the area. > 0 and less than the dungeon's width.
	posz: Top left row of the area. > 0 and less than the dungeon's height.
	sx: width of the area. Minimum 3. Some area types require higher minimums for full effect.
	sz: height of the area. Minumum 3. Some area types require higher minimums for full effect.
	cleartyp: Clearing type. 	AREACLEAR_FULL - clear the entire area of walls. 
								AREACLEAR_PERIMETER - clear only the perimeter, preserving the inner contents.
	typ: Type of area to create. AREATYPE_VOID - completely blank.
								AREATYPE_PILLARS - pillars effect.
								AREATYPE_WALLED - a walled room.
	typdata1: if type is AREATYPE_WALLED then typdata1 = number of doors into room. Minimum 0.
	typdata2: if type is AREATYPE_WALLED then typdata2 = corner door placement type. ENTRY_INCLUDECORNERS or ENTRY_EXCLUDECORNERS
  	End Rem

		If (posx < 0) Or (posx > (SizeX - 1)) Then Return
		If (posz < 0) Or (posz > (SizeZ - 1)) Then Return
		If (sx < 3) Or (sx >= SizeX) Then sx = 3
		If (sz < 3) Or (sz >= SizeZ) Then sz = 3

		'Tag relevent cells with the area id. Any existing id will be overwritten. ie a cell can only be 
		'classified as one room (though the visual effects will accrue)
		For Local x:Int = posx + 1 To (posx + sx) - 2
			For Local z:Int = posz + 1 To (posz + sz) - 2
				If (x >= 0) And (x < SizeX) And (z >= 0) And (z < SizeZ) Then Dungeon[x, z].AreaID = id
			Next
		Next

		If cleartyp = AREACLEAR_FULL 

			For Local x:Int = posx To (posx + sx) - 1
				For Local z:Int = posz To (posz + sz) - 1
					clearCell(x, z)
				Next
			Next
		
		Else If cleartyp = AREACLEAR_PERIMETER 
			
			For Local x:Int = posx To (posx + sx) - 1
				For Local z:Int = posz To (posz + 1)
					clearCell(x, z)
				Next
			Next
			For Local x:Int = posx To (posx + 1)
				For Local z:Int = posz To (posz + sz) - 1
					clearCell(x, z)
				Next
			Next
			For Local x:Int = (posx + sx - 2) To (posx + sx) - 1
				For Local z:Int = posz To (posz + sz) - 1
					clearCell(x, z)
				Next
			Next
			For Local x:Int = posx To (posx + sx) - 1
				For Local z:Int = (posz + sz - 2) To (posz + sz) - 1
					clearCell(x, z)
				Next
			Next
			
		EndIf
				
		Select typ
		
			Case AREATYPE_VOID 
		
			Case AREATYPE_PILLARS 
		
				If sx >= 5 And sz >= 5 'Only possible if the width and height of the area is >= 5
					For Local x:Int = (posx + 1) To (posx - 1 + sx) - 1 Step 2
						For Local z:Int = (posz + 1) To (posz - 1 + sz) - 1 Step 2
							If (x =< (SizeX - 1)) And (z =< (SizeZ - 1))
								Local cell:TDungeonCell = Dungeon[x, z]
								If (Not (x = 0)) Then cell.WallW = True
								If (Not (z = 0)) Then cell.WallN = True
								If (Not (x = (SizeX - 1))) Then cell.WallE = True
								If (Not (z = (SizeZ - 1))) Then cell.WallS = True
							EndIf
						Next
					Next
				EndIf 
			
			Case AREATYPE_WALLED 'Walled room with entries.
				'typdata1: number of doors
				'typdata2 = 1: exclude corners

				Local pdcells:TDungeonCell[]	'Potential room entries

				'West and East
				For Local z:Int = (posz + 1) To (posz + sz - 2)
					If (z =< (SizeZ - 1))
						Local x:Int = posx + 1
						If x < SizeX
							Local cell:TDungeonCell = Dungeon[x, z]
							cell.WallW = True
						
							pdcells = pdcells[..pdcells.length + 1]
							pdcells[pdcells.length - 1] = cell
						
							x = posx + sx - 2
							If (x =< (SizeX - 1))
								cell = Dungeon[x, z]
								cell.WallE = True
								pdcells = pdcells[..pdcells.length + 1]
								pdcells[pdcells.length - 1] = cell
							EndIf
						EndIf
					EndIf
				Next
				
				'North and South
				For Local x:Int = (posx + 1) To (posx + sx - 2)
					If (x =< (SizeX - 1))
						Local z:Int = posz + 1
						If z < SizeZ
							Local cell:TDungeonCell = Dungeon[x, z]
							cell.WallN = True
				
							pdcells = pdcells[..pdcells.length + 1]
							pdcells[pdcells.length - 1] = cell

							z = posz + sz - 2
							If (z =< (SizeZ - 1))
								cell = Dungeon[x, z]
								pdcells = pdcells[..pdcells.length + 1]
								pdcells[pdcells.length - 1] = cell
								cell.WallS = True
							EndIf
						EndIf
					EndIf
				Next
				
				'If necessary, remove corners from potential entry list
				If typdata2 = ENTRY_EXCLUDECORNERS
				
					Local eol:Int = False
					Local i:Int = 0
					
					While (Not eol)
					
						Local remove:Int = False
						
						If pdcells 
						
						If (pdcells[i].X = (posx + 1) And pdcells[i].Z = (posz + 1))
							remove = True
 						Else
							If (pdcells[i].X = (posx + sx - 2) And pdcells[i].Z = (posz + sz - 2))
								remove = True
							Else
								If (pdcells[i].X = (posx + 1) And pdcells[i].Z = (posz + sz - 2))
									remove = True
								Else
									If (pdcells[i].X = (posx + sx - 2) And pdcells[i].Z = (posz + 1))
										remove = True
									EndIf
								EndIf
							EndIf
						EndIf
						
						EndIf
												
						If remove
							pdcells[i] = pdcells[pdcells.length - 1]
							pdcells = pdcells[..pdcells.length - 1]
						Else
							i :+ 1
						EndIf
							
							
												
						If i > pdcells.length - 1 Then eol = True

					Wend
					
				EndIf
				
				'shuffle potential room entries
				If (pdcells.length > 0)
				
					For Local n:Int = 1 To 100
						Local i1:Int = Rand(0, pdcells.length - 1)
						Local i2:Int = Rand(0, pdcells.length - 1)
						Local cell1:TDungeonCell = pdcells[i1]
						Local cell2:TDungeonCell = pdcells[i2]
						pdcells[i1] = cell2
						pdcells[i2] = cell1
					Next
				
					'create entries
					For Local n:Int = 0 To (typdata1 - 1)
						If n < pdcells.length
							clearCell(pdcells[n].X, pdcells[n].Z)
						EndIf
					Next
					
				EndIf
				
		EndSelect	
	
	EndMethod


	Method clearCell(x:Int, z:Int)
	Rem
	Clear a specific cell of all walls, but presevere the dungeon's outermost edges if necessary.
	x: cell column.
	z: cell row.
	End Rem
	
		If (x =< (SizeX - 1)) And (z =< (SizeZ - 1))
			Local cell:TDungeonCell = Dungeon[x, z]
			If (Not (x = 0)) Then cell.WallW = False
			If (Not (z = 0)) Then cell.WallN = False
			If (Not (x = (SizeX - 1))) Then cell.WallE = False
			If (Not (z = (SizeZ - 1))) Then cell.WallS = False
		EndIf

	EndMethod


	Method makeAreas(qty:Int = 1, maxsizex:Int = 4, maxsizez:Int = 4)
	Rem
	Create a number of areas in the dungeon at random locations and of random sizes.
	qty: Quantity of areas to create. Minimum 1.
	maxsizex: Maximum possible area width. Minimum 4.
	maxsizez: Maximum possible area height. Minimum 4.
	EndRem
	
		If qty <= 0 Then qty = 1
		If maxsizex <= 3 Then maxsizex = 0.4 * SizeX
		If maxsizez <= 3 Then maxsizez = 0.4 * SizeZ
	
		For Local n:Int = 1 To qty
			createArea(n, Rand(0, SizeX - maxsizex), Rand(0, SizeZ - maxsizez), Rand(3, maxsizex), Rand(3, maxsizez), Rand(0, 1), Rand(0, 2), Rand(1, 4), Rand(0, 1))
		Next
		
	EndMethod

	
	Method getWallGrid:Byte[,]()
	Rem
	Create a grid representation of the dungeon's walls. 
	Most applications utilise such a data structure for dungeon processing. 
	Returns: 2d array of byte values. True = wall. False = no wall.
	NOTE: The returned grid dimensions will be double the TDungeon sizes.
	NOTE2:'Double' walls are ignored.
			ie: North walls correspond to the South walls of the upper cell,
				South walls correspond to the North walls of the lower cell,
				East walls correspond to the West walls of the right cell,
				West walls correspond to the East walls of the left cell.
	EndRem
		
		Local arr:Byte[SizeX * 2 + 1, SizeZ * 2 + 1]
	
		For Local x:Int = 0 To SizeX - 1 
			Local ax:Int = x * 2 + 1
			For Local z:Int = 0 To SizeZ - 1 
				Local az:Int = z * 2 + 1
				If Dungeon[x, z].WallN = True 
					arr[ax, az - 1] = True
					arr[ax - 1, az - 1] = True
					arr[ax + 1, az - 1] = True
				EndIf
				If Dungeon[x, z].WallS = True 
					arr[ax, az + 1] = True
					arr[ax - 1, az + 1] = True
					arr[ax + 1, az + 1] = True
				EndIf
				If Dungeon[x, z].WallW = True 
					arr[ax - 1, az] = True
					arr[ax - 1, az + 1] = True
					arr[ax - 1, az - 1] = True
				EndIf
				If Dungeon[x, z].WallE = True 
					arr[ax + 1, az] = True
					arr[ax + 1, az - 1] = True
					arr[ax + 1, az + 1] = True
				EndIf
			Next
		Next	
	
		Return arr
	
	EndMethod


	Method getAreaGrid:Byte[,]()
	Rem
	Create a grid representation of the dungeon's area ids. 
	Returns: 2d array of byte values. Values = ids.
	NOTE: The returned grid dimensions will be double the TDungeon sizes.
	EndRem
		Local arr:Byte[SizeX * 2 + 1, SizeZ * 2 + 1]
	
		For Local x:Int = 0 To SizeX - 1 
			Local ax:Int = x * 2 + 1
			For Local z:Int = 0 To SizeZ - 1 
				Local az:Int = z * 2 + 1
				If Dungeon[x, z].AreaID <> 0
					arr[ax, az] = Dungeon[x, z].AreaID
					arr[ax, az + 1] = Dungeon[x, z].AreaID
					arr[ax , az - 1] = Dungeon[x, z].AreaID
					arr[ax + 1, az] = Dungeon[x, z].AreaID
					arr[ax + 1, az + 1] = Dungeon[x, z].AreaID
					arr[ax + 1, az - 1] = Dungeon[x, z].AreaID
					arr[ax - 1, az] = Dungeon[x, z].AreaID
					arr[ax - 1, az + 1] = Dungeon[x, z].AreaID
					arr[ax - 1, az - 1] = Dungeon[x, z].AreaID
				EndIf
			Next
		Next	
	
		Return arr
	
	EndMethod

EndType


Type TDungeonCell
	Rem
	Utility class used by TDungeon.
	EndRem 
	
	Field WallN:Int = True		
	Field WallS:Int = True 
	Field WallE:Int	= True
	Field WallW:Int	= True
	
	Field X:Int
	Field Z:Int
	
	Field AreaID:Byte = 0

EndType
