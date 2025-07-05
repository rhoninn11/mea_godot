extends Node

class Interop:
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

class Math:
	static func ts_xform_orgin(ts: Array[Transform3D], t: Transform3D) -> Array[Transform3D]:
		var result: Array[Transform3D]
		result.resize(len(ts))
		for i in range(len(ts)):
			var a = ts.get(i)
			var b = t*a.origin
			a.origin = b
			result.set(i, a)
			
		return result
	
	static func ts_scale_along(ts: Array[Transform3D], scale: Curve) -> Array[Transform3D]:
		var ts_new: Array[Transform3D] = []
		ts_new.resize(len(ts))
		for i in range(len(ts)):
			var prog := float(i)/float(len(ts) - 1)
			print("halo")
			var s := scale.sample(prog)
			var t_s = Transform3D.IDENTITY.scaled(Vector3(s,s,s))
			ts_new[i] = ts[i] * t_s
		
		return ts_new

class Shapes:
	# retun data of position and normal vector, both packed as Vector2 inside single Vector4
	static func circle_2D(steps: int, fill_c: float, closed: bool) -> PackedVector4Array:
		var gen_steps = steps
		if closed:
			gen_steps += 1

		var pos_tangent_data: PackedVector4Array
		pos_tangent_data.resize(gen_steps)
		for i in range(steps):
			var phase = float(i)/(steps-1) * TAU * fill_c
			var pos = Vector2(cos(phase), sin(phase))
			var normal = Vector2(-sin(phase), cos(phase))
			pos_tangent_data[i] = Vector4(pos[0], pos[1], normal[0], normal[1])
		
		return pos_tangent_data
	
	static func transfer_3d_from_data_2d(data_2d: PackedVector4Array) -> Array[Transform3D]:

		var transforms: Array[Transform3D]
		transforms.resize(len(data_2d))
		for i in range(len(transforms)):
			var dp: Vector4 = data_2d[i]
			var pos: Vector3 = Vector3(dp[0], 0, dp[1])
			var z: Vector3 = -Vector3(dp[2], 0, dp[3])

			var y = Vector3(0, 1, 0)
			var x = y.cross(z)
			var t = Transform3D(x,y,z, pos)
			transforms.set(i, t)
		return transforms

	static func circle_4d(steps: int, fill_c: float, closed: bool) -> Array[Transform3D]:
		var data_2d = circle_2D(steps, fill_c, closed)
		return transfer_3d_from_data_2d(data_2d)
		
