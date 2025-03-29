class_name RationalBSpline extends BSpline

func _init(points : Array[Vector3]):
	super(points)

func generate_drawable_points(divisionNumber : int = 50) -> Array[Vector3]:
	if points.size() < order:
		return []
	
	generate_knot_points()
	
	var normalisedBaseCache : Array[float] = [];
	normalisedBaseCache.resize((divisionNumber + 1) * points.size());
	
	var normalisedBaseDenominatorCache : Array[float] = [];
	normalisedBaseDenominatorCache.resize(divisionNumber + 1)
	normalisedBaseDenominatorCache.fill(0.0)

	for u_i in range(divisionNumber + 1):
		var step : float = (knot_points[points.size()] - knot_points[order - 1]) / divisionNumber
		var u : float = knot_points[order - 1] + float(u_i) * step
		
		for index in range(points.size()):
			var cacheIndex : int = u_i * points.size() + index
			normalisedBaseCache[cacheIndex] = weights[index] * gen_normalized_bspline(index, order, u)
			normalisedBaseDenominatorCache[u_i] += normalisedBaseCache[cacheIndex]
	
	var newDrawablePoints : Array[Vector3] = []
	
	for u_i in range(divisionNumber + 1):
		var nominatorCache : float = normalisedBaseDenominatorCache[u_i]
		var drawablePoint : Vector3 = Vector3()
	
		for index in range(points.size()):
			drawablePoint += (normalisedBaseCache[u_i * points.size() + index] / nominatorCache) * points[index]
		
		newDrawablePoints.push_back(drawablePoint)
	
	return newDrawablePoints
	
