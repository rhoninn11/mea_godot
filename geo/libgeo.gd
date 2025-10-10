extends Node

class Interop:
	const T_SIZE: int = 12
	static func t_flat(t: Transform3D) -> PackedFloat32Array:
		var buffer: PackedFloat32Array
		buffer.resize(12)

		buffer[0] = t.basis.x.x
		buffer[1] = t.basis.y.x
		buffer[2] = t.basis.z.x
		buffer[3] = t.origin.x

		buffer[4] = t.basis.x.y
		buffer[5] = t.basis.y.y
		buffer[6] = t.basis.z.y
		buffer[7] = t.origin.y
		
		buffer[8] = t.basis.x.z
		buffer[9] = t.basis.y.z
		buffer[10] = t.basis.z.z
		buffer[11] = t.origin.z

		return buffer

	static func Ts2Fs(ts: Array[Transform3D]) -> PackedFloat32Array:
		var buffer: PackedFloat32Array
		buffer.resize(len(ts)*T_SIZE)
		var i = 0
		for t in ts:
			for val in t_flat(t):
				buffer[i] = val
				i += 1

		return buffer
	


class Math:
	static func scale_m(scale: float) -> Transform3D:
		return Transform3D.IDENTITY.scaled(Vector3(scale,scale,scale))
	
	static func ts_xforms_origin(ts: Array[Transform3D], ts_: Array[Transform3D]) -> Array[Transform3D]:
		var result: Array[Transform3D]
		result.resize(len(ts))
		for i in range(len(ts)):
			var a = ts.get(i)
			var b = ts_.get(i)*a.origin
			a.origin = b
			result.set(i, a)
			
		return result

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
	
	static func sin_along(ts: Array[Transform3D], dir: Vector3) -> Array[Transform3D]:
		var moved: Array[Transform3D] = []
		moved.resize(len(ts))

		for i in range(len(ts)):
			var prog := float(i)/float(len(ts) - 1)
			moved[i] = ts[i].translated(dir * prog)

		return moved;

class Shapes:
	static func empty_1d(num: int) -> Array[float]:
		var empty: Array[float];
		empty.resize(num)
		return empty;
	
	static func empty_3d(num: int) -> Array[Vector3]:
		var empty: Array[Vector3];
		empty.resize(num)
		return empty;

	static func empty_4d(num: int) -> Array[Transform3D]:
		var empty: Array[Transform3D];
		empty.resize(num)
		return empty;

	static func line_1d(steps: int, length: float = 1) -> Array[float]:
		var res: Array[float];
		res.resize(steps);
		for i in range(steps):
			res[i] = float(i)/(steps-1)*length;
		return res;
	
	static func up_1d_to_3d_y(one_d: Array[float]) -> Array[Vector3]:
		var data_3d = empty_3d(len(one_d));
		
		for i in range(len(one_d)):
			data_3d[i] = Vector3(0, one_d[i], 0);
		return data_3d;

	static func up_3d_to_4d(tri_d: Array[Vector3]) -> Array[Transform3D]:
		var data_4d = empty_4d(len(tri_d));
		for i in range(len(tri_d)):
			data_4d[i] = Transform3D.IDENTITY;
			data_4d[i].origin = tri_d[i];
		return data_4d;



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
	
	static func line_y_4d(steps: int, length: float) -> Array[Transform3D]:
		var line = line_1d(steps, length);
		var transforms: Array[Transform3D]
		transforms.resize(steps)
		for i in range(steps):
			transforms[i] = Transform3D.IDENTITY;
			transforms[i].origin.y = line[i];
		
		return transforms;
