extends AbstractLineDrawer

var line : Line2D = Line2D.new()

func _init() -> void:
	line.width = 2
	add_child(line)

func clear_points() -> void:
	line.clear_points()

func draw_points(points : Array[Vector3]) -> void:
	self.length = 0.0
	
	line.add_point(Vector2(points[0].x, points[0].y))
		
	for index in range(1, points.size()):
		length += (points[index] - points[index -1]).length()		
		line.add_point(Vector2(points[index].x, points[index].y))
