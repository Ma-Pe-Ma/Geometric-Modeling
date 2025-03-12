class_name AbstractCurveGenerator

var parameterList : Array[float] = []
var points : Array[Vector2] = []
var weights : Array[float] = []

func _init(points : Array[Vector2]):
	self.points = points

func generateParameterList():
	pass

# generate points for polyline
func generateDrawablePoints(divisionNumber : int = 50) -> Array[Vector2]:
	return []

func setWeights(weights : Array[float]) ->void:
	self.weights = weights
