extends Node

class Helpers:
	static func T2Fs(t: Transform3D) -> PackedFloat32Array:
		var buffer: PackedFloat32Array
		buffer.resize(12)
		var i: int = 0
		var varr: Array[Vector3] = [t.basis[0], t.basis[1], t.basis[2], t.origin]
		for vec in varr:
			for val in [vec.x, vec.y, vec.z]:
				buffer[i] = val
				i += 1
		return buffer

	static func Ts2Fs(ts: Array[Transform3D]) -> PackedFloat32Array:
		var buffer: PackedFloat32Array
		buffer.resize(12 * len(ts))
		var i = 0
		for t in ts:
			var chunk = T2Fs(t)
			for val in chunk:
				buffer[i] = val
				i += 1

		return buffer
	
	static func circle4D(steps: int, fill_c: float, closed: bool) -> Array[Transform3D]:
		var points: PackedVector3Array
		var tangents: PackedVector3Array 
		if closed:
			steps += 1
		points.resize(steps)
		tangents.resize(steps)
		for i in range(steps):
			var phase = float(i)/(steps-1) * TAU * fill_c
			points[i] = Vector3(cos(phase), 0, sin(phase))
			tangents[i] = Vector3(-sin(phase), 0, cos(phase))
		
		
		var transforms: Array[Transform3D]
		transforms.resize(steps)
		for i in range(steps):
			var z: Vector3 = -tangents[i]
			var y = Vector3(0, 1, 0)
			var x = y.cross(z)
			transforms.set(i, Transform3D(x, y, z, points[i]))
		return transforms
	
	static func TsoXT(ts: Array[Transform3D], t: Transform3D) -> Array[Transform3D]:
		var result: Array[Transform3D]
		result.resize(len(ts))
		for i in range(len(ts)):
			var a = ts.get(i)
			var b = t*a.origin
			a.origin = b
			result.set(i, a)
			
		return result
		
