class_name RationalBSpline extends BSpline

func _init(points : Array[Vector2]):
	super(points)

func generateDrawablePoints(divisionNumber : int = 50) -> Array[Vector2]:
	generateParameterList()
	
	var newDrawablePoints : Array[Vector2] = []
	
	var normalisedBaseCache : Array[float] = [];
	normalisedBaseCache.resize((divisionNumber + 1) * points.size());
	
	var normalisedBaseDenominatorCache : Array[float] = [];
	normalisedBaseDenominatorCache.resize(divisionNumber + 1)
	normalisedBaseDenominatorCache.fill(0.0)
	print("---")
	for u_i in range(divisionNumber + 1):
		var u : float = parameterList[order - 1] + float(u_i) * (parameterList[points.size() + 1] - parameterList[order - 1]) / divisionNumber		
		
		for index in range(points.size()):
			var cacheIndex : int = u_i * points.size() + index
			normalisedBaseCache[cacheIndex] = weights[index] * generateNormalizedBSplineFunction(index, order, u)
			normalisedBaseDenominatorCache[u_i] += normalisedBaseCache[cacheIndex]
	
	for u_i in range(divisionNumber + 1):
		var nominatorCache : float = normalisedBaseDenominatorCache[u_i]
		var drawablePoint : Vector2 = Vector2()
	
		for index in range(points.size()):
			drawablePoint += (normalisedBaseCache[u_i * points.size() + index] / nominatorCache) * points[index]
		
		newDrawablePoints.push_back(drawablePoint)
	
	return newDrawablePoints
	
