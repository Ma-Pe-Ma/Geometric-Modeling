class_name PointPicker3D extends PointPicker

@export var camera_button_group : ButtonGroup;

@export var cameraXY : Camera3D;
@export var cameraZX : Camera3D;
@export var cameraYZ : Camera3D;

@export var marker3DDummy : Node3D; 

var camera_id : int = 0
var cameras : Array[Camera3D] = []

func _ready() -> void:
	super._ready()
	cameras = [cameraXY, cameraZX, cameraYZ]
	
	for button in camera_button_group.get_buttons():
		button.pressed.connect(func ():
			self.camera_id = camera_button_group.get_buttons().find(camera_button_group.get_pressed_button())
			self.activate_camera()
		)

func activate_camera() -> void:
	self.cameras[self.camera_id].make_current()

func get_control_points() -> Array[Vector3]:
	var controlPoints : Array[Vector3] = []	
	for child in get_children() as Array[Node3D]:
		controlPoints.push_back(child.position)
		
	return controlPoints

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			for child in get_children() as Array[Node]:
				var position_difference : Vector3 = transform_mouse_coord_to_world(get_viewport().get_mouse_position()) - child.position
				position_difference[2 - camera_id] = 0.0
				
				if position_difference.length() < 15:
					dragged = child
					return
					
			var new_marker = marker3DDummy.duplicate() as Node3D
			new_marker.position = transform_mouse_coord_to_world(get_viewport().get_mouse_position())
			new_marker.show()
			add_child(new_marker)
			
			self.add_weight_input()
			self.draw_current_curve()

		if event.is_released():
			if dragged != null:
				dragged = null
				
				self.draw_current_curve()

	if event is InputEventMouseMotion:
		if dragged != null:			
			dragged.position = transform_mouse_coord_to_world(get_viewport().get_mouse_position(), dragged.position[2 - camera_id])
			
			self.draw_current_curve()

func transform_mouse_coord_to_world(mouse_position : Vector2, third_coordinate : float = 0.0) -> Vector3:
	var viewport_size : Vector2i = get_viewport().size
	var c : float = 800

	var x : float = 0.0	
	if mouse_position.x < (viewport_size.x - viewport_size.y) / 2:
		x = - c / 2.0
	elif (viewport_size.x + viewport_size.y) / 2 < mouse_position.x:
		x = c / 2.0
	else:
		var a : float = c / viewport_size.y
		var b : float = c / 2.0 - a * (viewport_size.x + viewport_size.y) / 2.0		
		x = a * mouse_position.x + b
	
	var y : float = - c / viewport_size.y * mouse_position.y + c / 2
	y = clamp(y, -c/2, c/2)
	
	var woorld_coordinate : Vector3 = Vector3()
	match(camera_id):
		0:
			woorld_coordinate = Vector3(x, y, third_coordinate)
		1:
			woorld_coordinate = Vector3(y, third_coordinate, x)
		2:
			woorld_coordinate = Vector3(third_coordinate, x, y)
	
	return woorld_coordinate
