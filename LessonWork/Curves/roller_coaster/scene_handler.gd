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
				set_marker_scale(0.5)	
			1:
				set_node_state(point_picker, true)
				point_picker.activate_camera()
				set_marker_scale(1.0)
	)	

	tab_container.tab_changed.emit(0)

func set_node_state(node : Node, state : bool):
	node.set_process(state)
	node.set_physics_process(state)
	node.set_process_unhandled_input(state)
	node.set_process_input(state)

func set_marker_scale(scale : float = 1.0) -> void:
	for child in point_picker.get_children() as Array[Node3D]:
		child.scale = Vector3(scale, scale, scale)
