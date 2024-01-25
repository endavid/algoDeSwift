extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation.x = clamp(rotation.x, -1, 1)

func _input(event):
	if Input.is_key_pressed(KEY_E):
		rotate_y(0.1)
	if Input.is_key_pressed(KEY_W):
		rotate_y(-0.1)
	if Input.is_key_pressed(KEY_Z):
		translate(Vector3(0,0,0.2))
	if Input.is_key_pressed(KEY_X):
		translate(Vector3(0,0,-0.2))
	if Input.is_key_pressed(KEY_DOWN):
		translate(Vector3(0,-0.3,0))
	if Input.is_key_pressed(KEY_UP):
		translate(Vector3(0,0.3,0))
	if Input.is_key_pressed(KEY_RIGHT):
		translate(Vector3(0.2,0,0))
	if Input.is_key_pressed(KEY_LEFT):
		translate(Vector3(-0.2,0,0))
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if event is InputEventMouseMotion:
			rotate(Vector3.UP, event.relative.x * 0.001)
			rotate_object_local(Vector3.RIGHT, event.relative.y * 0.001)
