class_name Bezier extends AbstractCurveGenerator

var binomialCoefficients : Array[int] = []

func _init(points : Array[Vector2]):
	super(points)
	binomialCoefficients = generateBinomialCoefficients(points.size())

func generateDrawablePoints(divisionNumber : int = 50) -> Array[Vector2]:
	return generateWithRecursion(divisionNumber)
	#return generateWithBernstein(divisionNumber)

func generateWithRecursion(divisionNumber : int) -> Array[Vector2]:
	var newDrawablePoints : Array[Vector2] = []
	
	for i in range(divisionNumber + 1):
		var t : float = float(i) / divisionNumber
		
		var resultPoints : Array[Vector2] = calculateBezierRecursivePoints(t, points)		
		newDrawablePoints.push_back(resultPoints[0])
	
	return newDrawablePoints

func calculateBezierRecursivePoints(t : float, points : Array[Vector2]) -> Array[Vector2]:
	if points.size() == 1:
		return points
	
	var newPointSet : Array[Vector2] = []
	
	for index in range(1, points.size()):
		var newPoint : Vector2 = t * points[index - 1] + (1 - t) * points[index]		
		newPointSet.append(newPoint)
	
	return calculateBezierRecursivePoints(t, newPointSet)

func generateWithBernstein(divisionNumber : int):
	var newDrawablePoints : Array[Vector2] = []
	
	for i in range(divisionNumber + 1):
		var t : float = float(i) / divisionNumber
	
		var newPoint : Vector2 = Vector2()	
		for index in range(points.size()):			
			newPoint += points[index] * binomialCoefficients[index] * (t ** index) * ((1 - t) ** (points.size() - 1 - index))
	
		newDrawablePoints.push_back(newPoint)
			
	return newDrawablePoints

func generateBinomialCoefficients(n) -> Array[int]:
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
