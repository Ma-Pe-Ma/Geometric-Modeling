extends Node

@export var tab_container : TabContainer;
@export var point_picker : PointPicker3D;
@export var play_scene : PlayScene;

func _ready() -> void:	
	tab_container.tab_changed.connect(func(tabID : int):
		match(tabID):
			0:
				play_scene.activate_camera()
				play_scene.set_max_division_size(point_picker.picker_gui.division_slider.value)
				set_node_state(point_picker, false)
				play_scene.generate_coaster_mesh(point_picker.get_point_list(), point_picker.get_basis_list())
				
				for control_point_marker in point_picker.get_children() as Array[Node3D]:
					control_point_marker.hide()
			1:
				for control_point_marker in point_picker.get_children() as Array[Node3D]:
					control_point_marker.show()
				
				play_scene.coaster_mesh.hide()
				set_node_state(point_picker, true)
				point_picker.activate_camera()
	)	

	tab_container.tab_changed.emit(0)

func set_node_state(node : Node, state : bool) -> void:
	node.set_process(state)
	node.set_physics_process(state)
	node.set_process_unhandled_input(state)
	node.set_process_input(state)
