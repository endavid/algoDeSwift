extends Node3D

@export var title: String
@export var fallSpeed: float
@export var colors: PackedColorArray
@export_file("*.txt") var input

enum SimulationState { Stopped, Started, Counting, Finished }

var box = preload("res://box.tscn")
var boxes = []
var aabbs = []
var volume
var simState = SimulationState.Stopped
var fallingPieces = []
var timeToFall = 1.0
var timeFalling = 0.0

class IntAABB:
	var x0: int
	var y0: int
	var z0: int
	var x1: int
	var y1: int
	var z1: int
		
	func asAABB():
		var pos = Vector3(x0, y0, z0)
		var size = Vector3(x1-x0+1, y1-y0+1, z1-z0+1)
		return AABB(pos, size)
		
	func moveDown():
		y0 -= 1
		y1 -= 1
	
	func duplicate():
		return IntAABB.new(x0, y0, z0, x1, y1, z1)
		
	func copy(other):
		x0 = other.x0
		y0 = other.y0
		z0 = other.z0
		x1 = other.x1
		y1 = other.y1
		z1 = other.z1

	@warning_ignore("shadowed_variable")
	func _init(x0, y0, z0, x1, y1, z1):
		self.x0 = x0
		self.y0 = y0
		self.z0 = z0
		self.x1 = x1
		self.y1 = y1
		self.z1 = z1

class VoxelVolume:
	var width: int
	var depth: int
	var height: int
	var data: PackedInt32Array
	
	func index(x, y, z):
		return y * width * depth + z * width + x
	
	func place(value, aabb):
		for x in range(aabb.x0, aabb.x1 + 1):
			for y in range(aabb.y0, aabb.y1 + 1):
				for z in range(aabb.z0, aabb.z1 + 1):
					data[index(x,y,z)] = value
	
	func remove(aabb):
		for x in range(aabb.x0, aabb.x1 + 1):
			for y in range(aabb.y0, aabb.y1 + 1):
				for z in range(aabb.z0, aabb.z1 + 1):
					data[index(x,y,z)] = 0
					
	func collisionsBelow(aabb):
		var colliders = {}
		var y = aabb.y0 - 1
		if y == 0:
			return {0: true}
		for x in range(aabb.x0, aabb.x1 + 1):
			for z in range(aabb.z0, aabb.z1 + 1):
				var c = data[index(x,y,z)]
				if c != 0:
					colliders[c] = true
		return colliders
		
	# for Part 2
	func collisionsAbove(aabb):
		var colliders = {}
		var y = aabb.y1 + 1
		if y == height:
			return colliders
		for x in range(aabb.x0, aabb.x1 + 1):
			for z in range(aabb.z0, aabb.z1 + 1):
				var c = data[index(x,y,z)]
				if c != 0:
					colliders[c] = true
		return colliders
		
	func dumpRow(y):
		var i = index(0, y, 0)
		for z in range(0, depth):
			var s = data.slice(i + z * width, i + (z+1) * width)
			print(s)
		
	@warning_ignore("shadowed_variable")
	func _init(width, height, depth):
		self.width = width
		self.height = height
		self.depth = depth
		self.data = PackedInt32Array()
		self.data.resize(width * depth * height)

func loadFile(file):
	print(file)
	var bbs = []
	var f = FileAccess.open(input, FileAccess.READ)
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		var p = line.split("~")
		if len(p) < 2:
			continue
		var p0 = Array(p[0].split(",")).map(func(n): return int(n))
		var p1 = Array(p[1].split(",")).map(func(n): return int(n))
		var aabb = IntAABB.new(p0[0], p0[2], p0[1], p1[0], p1[2], p1[1])
		bbs.append(aabb)
	return bbs

# Called when the node enters the scene tree for the first time.
func _ready():
	# fallSpeed in units / sec; timeToFall in seconds
	timeToFall = 1 / fallSpeed
	aabbs = loadFile(input)
	var i = 0
	var width = 0
	var depth = 0
	var height = 0
	for aabb in aabbs:
		if aabb.x1 > width:
			width = aabb.x1
		if aabb.y1 > height:
			height = aabb.y1
		if aabb.z1 > depth:
			depth = aabb.z1
		var b = box.instantiate()
		b.setAABB(aabb.asAABB())
		b.setColor(colors[i])
		add_child(b)
		boxes.append(b)
		i = (i + 1) % len(colors)
	width += 1
	height += 1
	depth += 1
	print("Volume: %d x %d x %d" % [width, height, depth])
	volume = VoxelVolume.new(width, height, depth)
	for id in len(aabbs):
		volume.place(id+1, aabbs[id])

func findFallingPieces():
	var falling = []
	for id in len(aabbs):
		if nuked.has(id): # part 2 animation
			continue
		var aabb = aabbs[id]
		var colliders = volume.collisionsBelow(aabb)
		if len(colliders) == 0:
			falling.append(id)
			volume.remove(aabb)
			aabb.moveDown()
			volume.place(id+1, aabb)
	return falling

func updateBoxPositions():
	for id in len(aabbs):
		boxes[id].setAABB(aabbs[id].asAABB())
		
# these are pieces that if removed, something else will fall
func findEssentials():
	var essentials = {}
	for id in len(aabbs):
		var aabb = aabbs[id]
		var colliders = volume.collisionsBelow(aabb)
		if len(colliders) == 1 && !colliders.has(0):
			# a single piece below, and it's not the floor
			var colliderId = colliders.keys()[0] - 1
			essentials[colliderId] = true
	return essentials

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if simState == SimulationState.Counting:
		# Part 2
		if essentials.is_empty():
			simState = SimulationState.Finished
			var text = "%d blocks moved" % [totalCount]
			print(text)
			$CanvasLayer/Label.text = text
			resetState()
		else:
			totalCount += simulateRemovingOne()
		return
	if simState != SimulationState.Started:
		return
	if len(fallingPieces) > 0:
		# animate falling pieces
		for id in fallingPieces:
			boxes[id].moveDown(delta * fallSpeed)
		timeFalling += delta
		if timeFalling < timeToFall:
			return
	updateBoxPositions()
	fallingPieces = findFallingPieces()
	#print(fallingPieces)
	timeFalling = 0
	if len(fallingPieces) == 0:
		var essentialDict = findEssentials()
		essentials = essentialDict.keys()
		if essentials.is_empty():
			simState = SimulationState.Finished
			print("Finished!")
			$CanvasLayer/Label.text = "Finished!"
		else:
			simState = SimulationState.Counting
			print("Counting...")
			$CanvasLayer/Label.text = "Counting..."
		var disposable = len(aabbs) - len(essentials)
		print("There are %d essential pieces" % [len(essentials)])
		print("There are %d disposable pieces" % [disposable])
		# Part 2
		gameState = GameState.new(volume, aabbs, essentials)
		totalCount = 0

func dumpVolume():
	for y in range(1, 6):
		print("row %d: " % [y])
		volume.dumpRow(y)

func _input(event):
	if Input.is_key_pressed(KEY_SPACE):
		if simState == SimulationState.Stopped:
			print("Start!")
			$CanvasLayer/Label.text = "Falling pieces..."
			simState = SimulationState.Started
		elif simState == SimulationState.Finished:
			if !gameState.blockList.is_empty():
				for id in gameState.blockList:
					var aabb = aabbs[id]
					volume.remove(aabb)
					remove_child(boxes[id])
					nuked[id] = true
				simState = SimulationState.Started

# Part 2
class GameState:
	var volumeData: PackedInt32Array
	var blockData: Array
	var blockList: Array
	
	func _init(volume, aabbs, essentials):
		volumeData = volume.data.duplicate()
		for aabb in aabbs:
			blockData.append(aabb.duplicate())
		blockList = essentials.duplicate()
		
var gameState: GameState
var essentials = []
var totalCount = 0
var nuked = {}

func resetState():
	volume.data = gameState.volumeData.duplicate()
	for i in len(aabbs):
		aabbs[i].copy(gameState.blockData[i])
	updateBoxPositions()

func simulateRemovingOne():
	if essentials.is_empty():
		return 0
	var id = essentials.pop_front()
	resetState()
	var aabb = aabbs[id]
	volume.remove(aabb)
	var moved = {}
	var fallingPieces = findFallingPieces()
	while !fallingPieces.is_empty():
		for k in fallingPieces:
			moved[k] = true
		fallingPieces = findFallingPieces()
	updateBoxPositions()
	return len(moved)

