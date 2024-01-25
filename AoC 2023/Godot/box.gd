extends Node3D

func setAABB(aabb):
	var size = aabb.size
	var pos = aabb.position
	var half = size / 2
	$Mesh.position = pos + half
	$Mesh.scale = size
	
func moveDown(dy):
	$Mesh.position.y -= dy
		
func getColor():
	var material = $Mesh.get_surface_override_material(0)
	if material == null:
		return Color.WHITE
	return material.albedo_color
	
func setColor(color):
	var material = $Mesh.get_surface_override_material(0)
	if material == null:
		material = StandardMaterial3D.new()
		$Mesh.set_surface_override_material(0, material)
	material.albedo_color = color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
