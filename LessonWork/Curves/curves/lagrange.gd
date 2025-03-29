class_name Lagrange extends AbstractCurveGenerator

var lagrangeParameterExponential : float = 0.0

func _init(points : Array[Vector2]):
	super(points)

func generateParameterList() -> void:
	parameterList.clear()	
	parameterList.push_back(0)
	
	var totalLength = 0
	
	for j in range(1, self.points.size()):
		totalLength += (self.points[j] - self.points[j - 1]).length() ** lagrangeParameterExponential
		
	for i in range(1, self.points.size()):
		var u = parameterList[-1] + (self.points[i] - self.points[i - 1]).length() ** lagrangeParameterExponential / totalLength 
		self.parameterList.push_back(u)

func generateDrawablePoints(divisionNumber : int = 50) -> Array[Vector2]:
	generateParameterList()
	
	var newDrawablePoints : Array[Vector2] = []	
	
	for u_i in range(divisionNumber + 1):
		var u = float(u_i) * (parameterList[-1] - parameterList[0]) / divisionNumber
		var p = Vector2(0, 0)
		
		for i in range(points.size()):
			var L = 1
			
			for j in range(parameterList.size()):
				if j == i:
					continue
					
				L *= (u - parameterList[j]) / (parameterList[i] - parameterList[j])
			
			p += self.points[i] * L
			
		newDrawablePoints.push_back(p)
	
	return newDrawablePoints	
