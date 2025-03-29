class_name PlayScene extends Node

@export var camera3D : Camera3D;
@export var play_control : PlayControl;
@export var triad : Node3D;
@export var point_picker : PointPicker;

func _ready():
	play_control.radius_slider.value_changed.connect(self.update_camera)
	play_control.angle1_slider.value_changed.connect(self.update_camera)
	play_control.angle2_slider.value_changed.connect(self.update_camera)
	
	play_control.step_slider.value_changed.connect(func(value : int):
		if point_picker.get_point_list().size() > 2:
			if play_control.attach_camera.button_pressed:
				camera3D.basis = point_picker.get_basis_list()[value]
				camera3D.position = point_picker.get_point_list()[value]
				camera3D.rotate_object_local(Vector3(0.0, 1.0, 0.0), deg_to_rad(-90))
			else:
				triad.basis = point_picker.get_basis_list()[value]
				triad.position = point_picker.get_point_list()[value]			
	)
	
	play_control.attach_camera.toggled.connect(func(toggled : bool):
		if toggled:
			if	point_picker.get_point_list().size() > 2:
				var currentStep : int = play_control.step_slider.value
				camera3D.basis = point_picker.get_basis_list()[currentStep]
				camera3D.position = point_picker.get_point_list()[currentStep]
				camera3D.rotate_object_local(Vector3(0.0, 1.0, 0.0), deg_to_rad(-90))
			
			triad.hide()
			play_control.radius_slider.editable = false
			play_control.angle1_slider.editable = false
			play_control.angle2_slider.editable = false
			
		else:
			play_control.radius_slider.editable = true
			play_control.angle1_slider.editable = true
			play_control.angle2_slider.editable = true
			triad.show()
			update_camera(0.0)
	)
	
	update_camera(0.0)

func update_camera(value : float):
	var camera_distance : float = play_control.radius_slider.value
	var ang1 = deg_to_rad(play_control.angle1_slider.value)
	var ang2 = deg_to_rad(play_control.angle2_slider.value)
	
	var z : float = camera_distance * cos(ang2) * cos(ang1) 
	var x : float = camera_distance * cos(ang2) * sin(ang1) 
	var y : float = camera_distance * sin(ang2)

	camera3D.position = Vector3(x, y, z)	
	camera3D.rotation = Vector3(-ang2, ang1, 0.0)

func activate_camera():
	camera3D.make_current()

func set_max_division_size(max_step_size : int):
	play_control.step_slider.max_value = max_step_size
