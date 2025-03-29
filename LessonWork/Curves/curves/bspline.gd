class_name BSpline extends AbstractCurveGenerator

var order : int = 3

func _init(points : Array[Vector2]):
	super(points)

func generateParameterList():
	parameterList.clear()
	
	for i in range(points.size() + order):
		parameterList.push_back(float(i))

func generateDrawablePoints(divisionNumber : int = 50) -> Array[Vector2]:
	if points.size() < order:
		return []
	
	generateParameterList()
	
	var newDrawablePoints : Array[Vector2] = []
	
	for u_i in range(divisionNumber + 1):
		var step : float = (parameterList[points.size()] - parameterList[order - 1]) / divisionNumber
		var u : float = parameterList[order - 1] + float(u_i) * step
		
		var drawablePoint : Vector2 = Vector2()
		
		for pointIndex in range(points.size()):
			drawablePoint += points[pointIndex] * generateNormalizedBSplineFunction(pointIndex, order, u)
		
		newDrawablePoints.push_back(drawablePoint)
	
	return newDrawablePoints	

func generateNormalizedBSplineFunction(i : int, k : int, u : float) -> float:
	if k == 1:		
		if parameterList[i] <= u && u < parameterList[i + 1]:
			return 1
			
		return 0
	
	var part1 : float = (u - parameterList[i]) / (parameterList[i + k - 1] - parameterList[i]) * generateNormalizedBSplineFunction(i, k - 1, u)
	var part2 : float = (parameterList[i + k] - u) / (parameterList[i + k] - parameterList[i + 1]) * generateNormalizedBSplineFunction(i + 1, k - 1, u)
	
	return part1 + part2
