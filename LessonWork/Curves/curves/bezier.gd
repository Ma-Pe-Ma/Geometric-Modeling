class_name Bezier extends AbstractCurveGenerator

var binomial_coefficients : Array[int] = []

func _init(points : Array[Vector3]):
	super(points)
	binomial_coefficients = gen_binomial_coeff(points.size())

func generate_drawable_points(divisionNumber : int = 50) -> Array[Vector3]:
	return gen_with_recursion(divisionNumber)
	#return gen_with_bernstein(divisionNumber)

func gen_with_recursion(divisionNumber : int) -> Array[Vector3]:
	var newDrawablePoints : Array[Vector3] = []
	
	for i in range(divisionNumber + 1):
		var t : float = float(i) / divisionNumber
		
		var resultPoints : Array[Vector3] = calc_bezier_recursive(t, points)		
		newDrawablePoints.push_back(resultPoints[0])
	
	return newDrawablePoints

func calc_bezier_recursive(t : float, points : Array[Vector3]) -> Array[Vector3]:
	if points.size() == 1:
		return points
	
	var newPointSet : Array[Vector3] = []
	
	for index in range(1, points.size()):
		var newPoint : Vector3 = t * points[index - 1] + (1 - t) * points[index]		
		newPointSet.append(newPoint)
	
	return calc_bezier_recursive(t, newPointSet)

func gen_with_bernstein(divisionNumber : int):
	var newDrawablePoints : Array[Vector3] = []
	
	for i in range(divisionNumber + 1):
		var t : float = float(i) / divisionNumber
	
		var newPoint : Vector3 = Vector3()	
		for index in range(points.size()):			
			newPoint += points[index] * binomial_coefficients[index] * (t ** index) * ((1 - t) ** (points.size() - 1 - index))
	
		newDrawablePoints.push_back(newPoint)
			
	return newDrawablePoints

func gen_binomial_coeff(n) -> Array[int]:
	if n == 0:
		return [1]
	
	var previousRowPolinoms : Array[int] = [1, 1]
		
	for i in range(2, n):		
		var currentRowPolinoms : Array[int] = [1]
		
		for j in range(1, i):
			currentRowPolinoms.push_back(previousRowPolinoms[j - 1] + previousRowPolinoms[j])
		
		currentRowPolinoms.push_back(1)
		
		previousRowPolinoms = currentRowPolinoms
	
	return previousRowPolinoms
