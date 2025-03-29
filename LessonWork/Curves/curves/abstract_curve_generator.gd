class_name AbstractCurveGenerator

var knot_points : Array[float] = []

var points : Array[Vector3] = []
var weights : Array[float] = []

func _init(points : Array[Vector3]):
	self.points = points

func generate_knot_points():
	pass

# generate points for polyline
func generate_drawable_points(divisionNumber : int = 50) -> Array[Vector3]:
	return []

func set_weights(weights : Array[float]) ->void:
	self.weights = weights
