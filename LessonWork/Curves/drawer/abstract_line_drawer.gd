class_name AbstractLineDrawer extends Node

var length : float = 0.0

func clear_points() -> void:
	pass

func draw_points(points : Array[Vector3]) -> void:
	pass

func get_length() -> float:
	return self.length
