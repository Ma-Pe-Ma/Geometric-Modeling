class_name PlayScene extends Node

@export var camera3D : Camera3D;
@export var play_control : PlayControl;
@export var triad : Node3D;
@export var point_picker : PointPicker;

@export_range(50, 200, 10) var tube_radius : float = 100.0
@export_range(3, 32, 1.0) var circumference_division : int = 16

var coaster_mesh : MeshInstance3D = MeshInstance3D.new()

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
			
			triad.basis = point_picker.get_basis_list()[play_control.step_slider.value]
			triad.position = point_picker.get_point_list()[play_control.step_slider.value]
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
	if not play_control.attach_camera.button_pressed and point_picker.get_point_list().size() > 0:
		triad.basis = point_picker.get_basis_list()[play_control.step_slider.value]
		triad.position = point_picker.get_point_list()[play_control.step_slider.value]

func set_max_division_size(max_step_size : int):
	play_control.step_slider.max_value = max_step_size

# manually build up sweeped circle along the curve path
func generate_coaster_mesh(points : Array[Vector3], basis_list : Array[Basis]):		
	var tube_mesh_instance : MeshInstance3D = MeshInstance3D.new()
	var tube_immediate_mesh : ArrayMesh = ArrayMesh.new()
	var tube_material : StandardMaterial3D  = StandardMaterial3D.new()
	
	tube_mesh_instance.mesh = tube_immediate_mesh
	tube_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	var vertices : PackedVector3Array = []
	var indices : PackedInt32Array = []
	
	var angle_step = 2 * PI / circumference_division

	for index in range(2, points.size()):
		for radius_i in range(0, circumference_division):
			var angle : float = angle_step * radius_i			
			
			var x_comp = tube_radius * cos(angle) * basis_list[index].y
			var y_comp = tube_radius * sin(angle) * basis_list[index].z
			
			var edge_point : Vector3 = points[index] + x_comp + y_comp
			vertices.append(edge_point)
	
	for i in range(2, points.size() - 1):
		for j in range(circumference_division - 1):
			# skip every second square for squared pattern
			if (j % 2 == 0 and i %2 == 0) or (j % 2 == 1 and i %2 == 1):
				continue
			
			indices.append((i - 2) * circumference_division + j)
			indices.append((i - 2) * circumference_division + j + 1)
			indices.append((i - 2 + 1) * circumference_division + j)
			
			indices.append((i - 2) * circumference_division + j + 1)
			indices.append((i - 2 + 1) * circumference_division + j + 1)
			indices.append((i - 2 + 1) * circumference_division + j)
		
		# skip last square for squared pattern
		if i % 2 == 0:
			continue
			
		indices.append((i - 2) * circumference_division + circumference_division - 1)
		indices.append((i - 2) * circumference_division)
		indices.append((i - 2 + 1) * circumference_division + circumference_division - 1)
		
		indices.append((i - 2) * circumference_division)
		indices.append((i - 2 + 1) * circumference_division)
		indices.append((i - 2 + 1) * circumference_division + circumference_division - 1)
	
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	tube_immediate_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	tube_material.albedo_color = Color.BLUE_VIOLET
	tube_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	tube_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tube_immediate_mesh.surface_set_material(0, tube_material)	
	
	self.coaster_mesh.queue_free()
	self.coaster_mesh = tube_mesh_instance
	add_child(tube_mesh_instance)
