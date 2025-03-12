class_name RationalBezier extends Bezier

func _init(points : Array[Vector2]):
	super(points)

func generateDrawablePoints(divisionNumber : int = 50) -> Array[Vector2]:
	var newDrawablePoints : Array[Vector2] = []
	
	var bernsteinCache : Array[float] = []
	bernsteinCache.resize((divisionNumber + 1) * points.size())
	
	var bernsteinNominatorCache : Array[float] = []
	bernsteinNominatorCache.resize(divisionNumber + 1)
	bernsteinNominatorCache.fill(0.0)
	
	for t_i in range(divisionNumber + 1):
		var t : float = float(t_i) / divisionNumber
	
		for index in range(points.size()):
			var cacheIndex : int = t_i * points.size() + index			
			bernsteinCache[cacheIndex] = weights[index] * binomialCoefficients[index] * (t ** index) * ((1 - t) ** (points.size() - 1 - index))
			bernsteinNominatorCache[t_i] += bernsteinCache[cacheIndex]
	
	for t_i in range(divisionNumber + 1):
		var nominatorCache : float = bernsteinNominatorCache[t_i]		
		var drawablePoint : Vector2 = Vector2()
		
		for i in range(points.size()):			
			drawablePoint += (bernsteinCache[t_i * points.size() + i] / nominatorCache) * points[i]
		
		newDrawablePoints.push_back(drawablePoint)			
			
	return newDrawablePoints
	
