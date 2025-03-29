class_name BSpline extends AbstractCurveGenerator

var order : int = 3

func _init(points : Array[Vector3]):
	super(points)

func generate_knot_points():
	knot_points.clear()
	
	for i in range(points.size() + order):
		knot_points.push_back(float(i))

func generate_drawable_points(divisionNumber : int = 50) -> Array[Vector3]:
	if points.size() < order:
		return []
	
	generate_knot_points()
	
	var newDrawablePoints : Array[Vector3] = []
	
	for u_i in range(divisionNumber + 1):
		var step : float = (knot_points[points.size()] - knot_points[order - 1]) / divisionNumber
		var u : float = knot_points[order - 1] + float(u_i) * step
		
		var drawablePoint : Vector3 = Vector3()
		
		for pointIndex in range(points.size()):
			drawablePoint += points[pointIndex] * gen_normalized_bspline(pointIndex, order, u)
		
		newDrawablePoints.push_back(drawablePoint)
	
	return newDrawablePoints	

func gen_normalized_bspline(i : int, k : int, u : float) -> float:
	if k == 1:		
		if knot_points[i] <= u && u < knot_points[i + 1]:
			return 1
			
		return 0
	
	var part1 : float = (u - knot_points[i]) / (knot_points[i + k - 1] - knot_points[i]) * gen_normalized_bspline(i, k - 1, u)
	var part2 : float = (knot_points[i + k] - u) / (knot_points[i + k] - knot_points[i + 1]) * gen_normalized_bspline(i + 1, k - 1, u)
	
	return part1 + part2
