extends Node3D

func _ready() -> void:	
	generate_direction([Vector3(), Vector3(1.0, 0.0, 0.0)], Color.RED)
	generate_direction([Vector3(), Vector3(0.0, 1.0, 0.0)], Color.GREEN)
	generate_direction([Vector3(), Vector3(0.0, 0.0, 1.0)], Color.BLUE)
	
func generate_direction(points : Array[Vector3], color : Color) -> void:
	var mesh_instance = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	var material = ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	immediate_mesh.surface_add_vertex(points[0])
	immediate_mesh.surface_add_vertex(points[1])
		
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	mesh_instance.scale = Vector3(100, 100, 100)
		
	add_child(mesh_instance)
