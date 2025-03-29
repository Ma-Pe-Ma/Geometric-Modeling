extends AbstractLineDrawer

func clear_points() -> void:
	for child in get_children() as Array[Node]:
		child.queue_free()

func draw_points(points : Array[Vector3]) -> void:
	self.length = 0.0
	
	var mesh_instance = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	var material = ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	for index in range(1, points.size()):
		immediate_mesh.surface_add_vertex(points[index])
		immediate_mesh.surface_add_vertex(points[index - 1])
		length += (points[index] - points[index - 1]).length()
		
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.WHITE
	
	add_child(mesh_instance)

func get_length() -> float:
	return self.length
