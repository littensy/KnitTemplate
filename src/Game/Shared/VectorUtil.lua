-- Vector Util
-- Stephen Leitnick
-- April 22, 2020

-- Modifications by littensy (July 23, 2020)

--[[

	VectorUtil.Min(vector1, ...)
	VectorUtil.Max(vector1, ...)
	VectorUtil.Abs(vector)
	VectorUtil.ClampXYZ(vector3, vector3Min, vector3Max)
	VectorUtil.ClampMagnitude(vector, maxMagnitude)
	VectorUtil.AngleBetween(vector1, vector2)
	VectorUtil.AngleBetweenSigned(vector1, vector2, axisVector)


	EXAMPLES:

		Min:

			Gets the lowest of one or more vectors.

			local v1 = Vector3.new(100, 0, 0)
			local v2 = Vector3.new(0, 10, 0)
			Min(v1, v2)	== Vector3.new(0, 10, 0)

		Max:

			Gets the highest of one or more vectors.

			local v1 = Vector3.new(100, 0, 0)
			local v2 = Vector3.new(0, 10, 0)
			Max(v1, v2)	== Vector3.new(0, 100, 0)

		Abs:

			Returns the absolute, or non-negative vector, of a given vector.

			Abs(Vector3.new(0, -10, -20))	== Vector3.new(0, 10, 20)
			Abs(Vector3.new(100, 0, -20))	== Vector3.new(100, 0, 20)

		ClampXYZ:

			Clamps the coordinates of a Vector3 so it is within the given bounds.

			min = Vector3.new(-10, -10, -10)
			max = Vector3.new(10, 10, 0)
			ClampXYZ(Vector3.new(0, -10, -20), min, max)	== Vector3.new(0, -10, -10)

		ClampMagnitude:

			Clamps the magnitude of a vector so it is only a certain length.

			ClampMagnitude(Vector3.new(100, 0, 0), 15) == Vector3.new(15, 0, 0)
			ClampMagnitude(Vector3.new(10, 0, 0), 20)  == Vector3.new(10, 0, 0)

		
		AngleBetween:

			Finds the angle (in radians) between two vectors.

			v1 = Vector3.new(10, 0, 0)
			v2 = Vector3.new(0, 10, 0)
			AngleBetween(v1, v2) == math.rad(90)

		
		AngleBetweenSigned:

			Same as AngleBetween, but returns a signed value.

			v1 = Vector3.new(10, 0, 0)
			v2 = Vector3.new(0, 0, -10)
			axis = Vector3.new(0, 1, 0)
			AngleBetweenSigned(v1, v2, axis) == math.rad(90)

--]]


local VectorUtil = {}


function VectorUtil.Min(vector1, ...)
	assert(vector1, "missing argument #1 to 'vector1' (Vector expected)")
	local vectors = table.pack(vector1, ...)
	local minimum, magnitude
	for _,vector in ipairs(vectors) do
		if (not minimum or vector.Magnitude < magnitude) then
			minimum = vector
			magnitude = vector.Magnitude
		end
	end
	return minimum, magnitude
end


function VectorUtil.Max(vector1, ...)
	assert(vector1, "missing argument #1 to 'vector1' (Vector expected)")
	local vectors = table.pack(vector1, ...)
	local maximum, magnitude
	for _,vector in ipairs(vectors) do
		if (not maximum or vector.Magnitude > magnitude) then
			maximum = vector
			magnitude = vector.Magnitude
		end
	end
	return maximum, magnitude
end


function VectorUtil.Abs(vector)
	return Vector3.new(math.abs(vector.X), math.abs(vector.Y), math.abs(vector.Z))
end


function VectorUtil.ClampXYZ(vector3, vector3Min, vector3Max)
	return Vector3.new(
		math.clamp(vector3.X, vector3Min.X, vector3Max.X),
		math.clamp(vector3.Y, vector3Min.Y, vector3Max.Y),
		math.clamp(vector3.Z, vector3Min.Z, vector3Max.Z)
	)
end


function VectorUtil.ClampMagnitude(vector, maxMagnitude)
	return (vector.Magnitude > maxMagnitude and (vector.Unit * maxMagnitude) or vector)
end


function VectorUtil.AngleBetween(vector1, vector2)
	return math.acos(math.clamp(vector1.Unit:Dot(vector2.Unit), -1, 1))
end


function VectorUtil.AngleBetweenSigned(vector1, vector2, axisVector)
	local angle = VectorUtil.AngleBetween(vector1, vector2)
	return angle * math.sign(axisVector:Dot(vector1:Cross(vector2)))
end


return VectorUtil