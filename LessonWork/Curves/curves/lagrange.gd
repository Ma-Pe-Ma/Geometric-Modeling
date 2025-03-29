class_name Lagrange extends AbstractCurveGenerator

var lagrangeParameterExponential : float = 0.0

func _init(points : Array[Vector3]):
	super(points)

func generate_knot_points() -> void:
	knot_points.clear()	
	knot_points.push_back(0)
	
	var totalLength = 0
	
	for j in range(1, self.points.size()):
		totalLength += (self.points[j] - self.points[j - 1]).length() ** lagrangeParameterExponential
		
	for i in range(1, self.points.size()):
		var u = knot_points[-1] + (self.points[i] - self.points[i - 1]).length() ** lagrangeParameterExponential / totalLength 
		self.knot_points.push_back(u)

func generate_drawable_points(divisionNumber : int = 50) -> Array[Vector3]:
	generate_knot_points()
	
	var newDrawablePoints : Array[Vector3] = []	
	
	for u_i in range(divisionNumber + 1):
		var u = float(u_i) * (knot_points[-1] - knot_points[0]) / divisionNumber
		var p = Vector3(0, 0, 0)
		
		for i in range(points.size()):
			var L = 1
			
			for j in range(knot_points.size()):
				if j == i:
					continue
					
				L *= (u - knot_points[j]) / (knot_points[i] - knot_points[j])
			
			p += self.points[i] * L
			
		newDrawablePoints.push_back(p)
	
	return newDrawablePoints	
