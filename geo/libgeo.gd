extends Node

# interop
class Itop:
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

	static func pkd_xform(ts: Array[Transform3D]) -> PackedFloat32Array:
		var buffer: PackedFloat32Array
		buffer.resize(len(ts)*T_SIZE)
		var i = 0
		for t in ts:
			for val in t_flat(t):
				buffer[i] = val
				i += 1

		return buffer
	
	# packed
	static func pkd_2d(unpacked_2d: Array[Vector2]) -> PackedVector2Array:
		var ops_memory: PackedVector2Array;
		ops_memory.resize(len(unpacked_2d))
		for i in range(len(ops_memory)):
			ops_memory[i] = unpacked_2d[i];
		return ops_memory;
	
	# unpacked
	static func unpkd_2d(packed_2d: PackedVector2Array) -> Array[Vector2]:
		var ops_memory: Array[Vector2];
		ops_memory.resize(len(packed_2d));
		for i in range(len(packed_2d)):
			ops_memory[i] = packed_2d[i];
		return ops_memory;

	static func xforms_from_2d(data_2d: PackedVector4Array) -> Array[Transform3D]:
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
	
	static func xforms_from_3d(pos_3d_arr: PackedVector3Array, normal_3d_arr: PackedVector3Array, tangent_3d_arr: PackedVector3Array) -> Array[Transform3D]:
		assert(len(normal_3d_arr) == len(tangent_3d_arr))
		assert(len(pos_3d_arr) == len(tangent_3d_arr))
		assert(len(pos_3d_arr) >= 2)
		
		var transforms: Array[Transform3D]
		transforms.resize(len(pos_3d_arr))
		for i in range(len(transforms)):
			var pos_v = pos_3d_arr[i] 
			var z: = tangent_3d_arr[i]
			var y: = normal_3d_arr[i]

			var x = y.cross(z)
			var t = Transform3D(x,y,z, pos_v)
			transforms.set(i, t)
		return transforms

class Math:
	static func scale_m(scale: float) -> Transform3D:
		return Transform3D.IDENTITY.scaled(Vector3.ONE*scale)
	
	static func ts_xforms_origin(ts: Array[Transform3D], ts_: Array[Transform3D]) -> Array[Transform3D]:
		var result: Array[Transform3D]
		result.resize(len(ts))
		for i in range(len(ts)):
			var a = ts.get(i)
			var b = ts_.get(i)*a.origin
			a.origin = b
			result.set(i, a)
			
		return result

	static func form_sxform(ts: Array[Transform3D], t: Transform3D, alloc: bool = false) -> Array[Transform3D]:
		var out_forms: Array[Transform3D];
		out_forms = out_forms if alloc else ts;
		out_forms.resize(len(ts))
		for i in range(len(ts)):
			out_forms[i] = t * ts[i];

		return out_forms;


	static func ts_xform_orgin(ts: Array[Transform3D], t: Transform3D) -> Array[Transform3D]:
		var result: Array[Transform3D]
		result.resize(len(ts))
		for i in range(len(ts)):
			var a = ts.get(i)
			var b = t*a.origin
			a.origin = b
			result.set(i, a)
			
		return result
	
	static func scale_along_xforms(ts: Array[Transform3D], samples: PackedFloat32Array, alloc: bool = false) -> Array[Transform3D]:
		assert(len(ts) == len(samples))

		var ts_new: Array[Transform3D]
		ts_new = ts_new if alloc else ts;
		ts_new.resize(len(ts))

		var show: bool = true 
		for i in range(len(ts)):
			# var xform = ts[i]
			var scale := samples[i] * Vector3.ONE
			var t_s = Transform3D.IDENTITY.scaled(scale)
			if show:
				show = false
				print(t_s);

			ts_new[i] = ts[i] * t_s
		
		return ts_new
	
	static func scale_along_xforms_o(xforms: Array[Transform3D], scale: float, alloc: bool = false) -> Array[Transform3D]:
		var num: = len(xforms)
		var xforms_out: Array[Transform3D]	
		xforms_out = xforms_out if alloc else xforms;
		for i in range(num):
			xforms_out[i].origin = xforms[i].origin * scale;
		
		return xforms_out

		
	
	static func sin_along(ts: Array[Transform3D], dir: Vector3) -> Array[Transform3D]:
		var moved: Array[Transform3D] = []
		moved.resize(len(ts))

		for i in range(len(ts)):
			var prog := float(i)/float(len(ts) - 1)
			moved[i] = ts[i].translated(dir * prog)

		return moved;
	

	static func ops2d_move(arr2D: PackedVector2Array, delta: Vector2) -> PackedVector2Array:
		var memory: = arr2D
		for i in range(arr2D.size()):
			var moved = arr2D[i] + delta
			memory[i] = moved
		return memory 

	static func ops2d_rotate(arr2D: PackedVector2Array, turn: float) -> PackedVector2Array:
		var memory: = arr2D
		var rad_angle = TAU * turn
		for i in range(arr2D.size()):
			memory[i] = arr2D[i].rotated(rad_angle)
		return memory 
		
	static func ops2d_scale(arr2D: PackedVector2Array, scale: Vector2) -> PackedVector2Array:
		var memory: = arr2D
		for i in range(arr2D.size()):
			memory[i] = arr2D[i] * scale
		return memory
	
	static func ops3d_move(arr2D: Array[Transform3D], delta: Vector3) -> Array[Transform3D]:
		var memory: = arr2D
		for i in range(arr2D.size()):
			memory[i].origin += delta;
		return memory 

	# static func ops3d_rotate(arr2D: Array[Transform3D], turn: float) -> Array[Transform3D]:
	# 	var memory: = arr2D
	# 	var rad_angle = TAU * turn
	# 	for i in range(arr2D.size()):
	# 		memory[i] = arr2D[i].rotated(rad_angle)
	# 	return memory 
		
	# static func ops3d_scale(arr2D: Array[Transform3D], scale: Vector2) -> Array[Transform3D]:
	# 	var memory: = arr2D
	# 	for i in range(arr2D.size()):
	# 		memory[i] = arr2D[i] * scale
	# 	return memory

	static func not_identified(prev: Vector2, curr: Vector2, next: Vector2, len: float) -> PackedVector2Array:
		var from_prev :=  (curr - prev).normalized()
		var from_next :=  (curr - next).normalized()
		# var central := -(from_prev + from_next).normalized()

		var data := PackedVector2Array([
			from_prev * len,
			Vector2.ZERO,
			from_next * len
		])
		return data
	
	static func not_identified2(prev: Vector2, curr: Vector2, next: Vector2, len: float) -> PackedVector2Array:
		var from_prev :=  (curr - prev).normalized()
		var from_next :=  (curr - next).normalized()
		var central := (from_prev + from_next).normalized()

		var data := PackedVector2Array([
			Vector2.ZERO,
			-central * len
		])
		return data
	
	static func recalc_fill(n: int, fill: float, closed: bool) -> float:
		assert(n >= 2)
		if not closed:
			fill = fill - (fill/n)
		return fill
	
	static func calc_angles(pnts: PackedVector2Array) -> PackedVector2Array:
		var n := len(pnts)
		assert(n >= 2)
		var data: PackedVector2Array
		data.resize(n)

		var info: String = ""
		for i in range(n):
			var prev_idx = i
			var curr_idx = (i+1)%n 
			var next_idx = (i+2)%n 
			var from_prev = (pnts[curr_idx]-pnts[prev_idx])
			var from_next = (pnts[curr_idx]-pnts[next_idx])
			
			var angle := from_prev.angle_to(from_next)
			i = curr_idx
			data[i].x = angle
			data[i].y = (PI/2 - angle/2) * 2
			info += "idx: %d, a: %.02f, hmm: %.02f | "%[i, data[i].x, data[i].y] 


		print(info)
		
		return data

class Shapes:
	class Profiles:
		# Ciekawe czy dotrzemy kidyś do mombius stripa
		static func square(size: float = 1.0) -> PackedVector2Array:
			var data: PackedVector2Array 
			data.resize(4)

			var off = size/2.0
			data[0] = Vector2(-off, off)
			data[1] = Vector2(off, off)
			data[2] = Vector2(off, -off)
			data[3] = Vector2(-off, -off)
			
			return data
		
		static func right_triangle(
			size: Vector2 = Vector2.ONE,
			just_x_positive: bool = false,
			just_y_positive: bool = false,
			) -> PackedVector2Array:

			var data: PackedVector2Array 
			data.resize(3)

			data[0] = Vector2(-0.5, 0.5)
			data[1] = Vector2(0.5, -0.5)
			data[2] = Vector2(-0.5, -0.5)

			if just_x_positive:
				Math.ops2d_move(data, Vector2(0.5,0))
			if just_y_positive:
				Math.ops2d_move(data, Vector2(0,0.5))
			Math.ops2d_scale(data, size)
			return data
		
		static func convex_rounded(pnts: PackedVector2Array, corner_r: float = 0.1, res: int = 16) -> PackedVector2Array:
			var n = len(pnts)
			assert(n >= 3)
			
			var angle_data := Math.calc_angles(pnts)
			
			var position_arr: Array[PackedVector2Array]
			var tang_arr: Array[PackedVector2Array]
			position_arr.resize(n)
			tang_arr.resize(n)
			for i in range(n):
				position_arr[i] = Shapes.circle_2D_pos(res, angle_data[i].y/TAU, true)
				tang_arr[i] = Shapes.circle_2d_tang(res, angle_data[i].y/TAU, true)
			
			# hardcoded for triangle, needs generalization for other convexes
			var cumulated := 0.0
			for i in range(n):
				Math.ops2d_rotate(position_arr[i], cumulated/TAU)
				cumulated += angle_data[i].y
			
			# Math.ops2d_rotate(position_arr[1], angle_data[0].y/TAU)
			# Math.ops2d_rotate(position_arr[2], (angle_data[1].y + angle_data[0].y)/TAU)
		
			for i in range(n):
				var correction_flip := Vector2(-1, 1)
				Math.ops2d_scale(position_arr[i], correction_flip*corner_r)
				Math.ops2d_scale(tang_arr[i], correction_flip)

			var offs := Memory.copy(pnts)
			for i in range(n):
				var prev = pnts[i]
				var curr_idx = (i + 1)%n
				var curr = pnts[curr_idx]
				var next = pnts[(i + 2)%n]
				Math.not_identified(prev, curr, next, 1)

				var from_prev :=  (curr - prev).normalized()
				var from_next :=  (curr - next).normalized()
				var central := -(from_prev + from_next).normalized()
				var inset_len := corner_r/sin(angle_data[curr_idx].x/2)
				Math.ops2d_move(position_arr[curr_idx], central*inset_len)
			
			for i in range(n):
				Math.ops2d_move(position_arr[i], offs[i])
			return Memory.join(position_arr)

		static func convex_rounded_tang(pnts: PackedVector2Array) -> PackedVector2Array:
			var n = len(pnts)
			assert(n >= 3)

			var angle_data := Math.calc_angles(pnts)
			
			var segs: Array[PackedVector2Array]
			segs.resize(n)
			for i in range(n):
				segs[i] = Shapes.circle_2d_tang(16, angle_data[i].y/TAU, true)
			
			Math.ops2d_rotate(segs[1], angle_data[0].y/TAU)
			Math.ops2d_rotate(segs[2], (angle_data[1].y + angle_data[0].y)/TAU)
		
			for seg in segs:
				var correction_flip := Vector2(-1, 1)
				Math.ops2d_scale(seg, correction_flip)

			return Memory.join(segs)

		static func half_i(res: int, spacing: float) -> PackedVector2Array:
			assert(res > 4 && spacing >= 0)

			var top: = Shapes.circle_2D_pos(res, 0.25, true)
			Math.ops2d_move(top, Vector2(0, spacing))
			top.reverse()
			
			var bot: = Shapes.circle_2D_pos(res, 0.25, true)
			Math.ops2d_rotate(bot, 0.5)
			Math.ops2d_move(bot, Vector2(2,0))
			# bot.reverse()
			top.append_array(bot)
			Math.ops2d_move(top, Vector2(0, 1))
			top.append(Vector2.ZERO)
			return top

		static func profile_form_half(half_profile: PackedVector2Array) -> PackedVector2Array:
			var left_copy := Math.ops2d_scale(Memory.copy(half_profile), Vector2(1, 1))
			var right_copy := Math.ops2d_scale(Memory.copy(half_profile), Vector2(-1, 1))

			var cropy: = right_copy.slice(1, len(right_copy)-1)	
			cropy.reverse()
			left_copy.append_array(cropy)
			return left_copy;

		

	static func empty_1d(num: int) -> Array[float]:
		var empty: Array[float];
		empty.resize(num)
		return empty;

	static func empty_2d(num: int) -> PackedVector2Array: 
		var empty: PackedVector2Array;
		empty.resize(num)
		return empty;
	
	static func empty_3d(num: int) -> Array[Vector3]:
		var empty: Array[Vector3];
		empty.resize(num)
		return empty;

	static func empty_4d(num: int) -> PackedVector4Array:
		var empty: PackedVector4Array;
		empty.resize(num)
		return empty;

	static func empty_xform(num: int) -> Array[Transform3D]:
		var empty: Array[Transform3D];
		empty.resize(num)
		return empty;

	static func line_1d(steps: int, length: float = 1) -> Array[float]:
		var res: Array[float];
		res.resize(steps);
		for i in range(steps):
			res[i] = float(i)/(steps-1)*length;
		return res;
	
	enum Axis {AX_X, AX_Y, AX_Z}
	static func line_xform(axis: Axis, length: float = 1, flip: bool = false) -> Array[Transform3D]:
		var mem := empty_xform(2)	
		mem[0].basis.x = Vector3.BACK
		mem[0].basis.y = Vector3.UP
		mem[0].basis.z = Vector3.RIGHT

		var shuffle: int = 0
		if axis == Axis.AX_Y:
			shuffle = 1
		if axis == Axis.AX_X:
			shuffle = 2
		for i in range(shuffle):
			var scratch = mem[0].basis.z
			mem[0].basis.z = mem[0].basis.y
			mem[0].basis.y = mem[0].basis.x
			mem[0].basis.x = scratch

		var grounding = mem[0].basis
		mem[1].basis = grounding;

		mem[1].origin = grounding.z * length * 0.5
		mem[0].origin = -grounding.z * length * 0.5

		return mem
	
	static func phase_1d(num: int, fill_c: float) -> PackedFloat32Array:
		var arc := line_1d(num, fill_c)
		for i in range(len(arc)):
			arc[i] *= TAU
		return arc
	
	static func up_1d_to_3d_y(one_d: Array[float]) -> Array[Vector3]:
		var data_3d = empty_3d(len(one_d));
		
		for i in range(len(one_d)):
			data_3d[i] = Vector3(0, one_d[i], 0);
		return data_3d;

	static func up_3d_to_4d(tri_d: Array[Vector3]) -> Array[Transform3D]:
		var data_4d = empty_xform(len(tri_d));
		for i in range(len(tri_d)):
			data_4d[i] = Transform3D.IDENTITY;
			data_4d[i].origin = tri_d[i];
		return data_4d;

	static func phi_circle_2d_pos(phases: PackedFloat32Array) -> PackedVector2Array:
		var pos_2d_arr: PackedVector2Array
		pos_2d_arr.resize(len(phases))
		for i in range(len(phases)):	
			var phi := phases[i]
			pos_2d_arr[i] = Vector2(cos(phi), sin(phi))
		return pos_2d_arr;
		
	static func phi_circle_2d_tangent(phases: PackedFloat32Array) -> PackedVector2Array:
		var normal_2d_arr: PackedVector2Array
		normal_2d_arr.resize(len(phases))
		for i in range(len(phases)):	
			var phi := phases[i]
			normal_2d_arr[i] = Vector2(-sin(phi), cos(phi))
		return normal_2d_arr;

	static func circle_2D_pos(points_num: int, fill_c: float, closed: bool) -> PackedVector2Array:
		fill_c = Math.recalc_fill(points_num, fill_c, closed)
		var phase_arr = phase_1d(points_num, fill_c)
		return phi_circle_2d_pos(phase_arr)
	
	static func circle_2d_tang(points_num: int, fill_c: float, closed: bool) -> PackedVector2Array:
		fill_c = Math.recalc_fill(points_num, fill_c, closed)
		var phase_arr = phase_1d(points_num, fill_c)
		return phi_circle_2d_tangent(phase_arr)

	static func circle_4d(num: int, fill_c: float, closed: bool, flip: bool = false) -> Array[Transform3D]:
		assert(num >= 2)
		if not closed:
			fill_c = fill_c - (fill_c/num)
		
		var phi_arr := phase_1d(num, fill_c)
		var pos_arr := phi_circle_2d_pos(phi_arr)
		var flip_scale := Vector2(-1, 1)
		if flip:
			Libgeo.Math.ops2d_scale(pos_arr, flip_scale)
		var tangent_arr := phi_circle_2d_tangent(phi_arr)
		if flip:	
			Libgeo.Math.ops2d_scale(tangent_arr, flip_scale)
	
		var pos_off: = -pos_arr[0]
		# pos_off = Vector2.ZERO
		Libgeo.Math.ops2d_move(pos_arr, pos_off)
		var pos_norm_arr := Memory.shuffle(pos_arr, tangent_arr)
		return Itop.xforms_from_2d(pos_norm_arr)
	
	static func line_y_4d(steps: int, length: float) -> Array[Transform3D]:
		var line = line_1d(steps, length);
		var transforms: Array[Transform3D]
		transforms.resize(steps)
		for i in range(steps):
			transforms[i] = Transform3D.IDENTITY;
			transforms[i].origin.y = line[i];
		
		return transforms;

class Tools:
	class DataBound extends Object:
		@export var m_min: Vector2;
		@export var m_max: Vector2;

	static func bound_info(dots_2d: PackedVector2Array):
		assert(len(dots_2d) >= 1)
		var _min: Vector2 = dots_2d[0];
		var _max: Vector2 = dots_2d[0];

		var d_bnd: DataBound
		d_bnd.m_min = _min
		d_bnd.m_max = _max
		for p in dots_2d:
			var less_x: = _min.x > p.x;
			var less_y: = _min.y > p.y;
			var more_x: = p.x > _max.x;
			var more_y: = p.y > _max.y;
			if less_x:
				_min.x = p.x;
			if less_y:
				_min.y = p.y;
			if more_x:
				_max.x = p.x;
			if more_y:
				_max.y = p.y
		
		var informat = "| l <-> r | %.02f <-> %.02f || d <-> u | %02f <-> %02f |" 
		print(informat%[_min.x, _max.x, _min.y, _max.y])
	
	static func sample_curve(curve: Curve, num: int) -> PackedFloat32Array:
		var samples: PackedFloat32Array;
		samples.resize(num)
		for i in range(num):
			var prog := float(i)/float(num - 1)
			samples[i] = curve.sample(prog)
		
		return samples
	
class Memory:
	static func copy(a: PackedVector2Array) -> PackedVector2Array:
		var b: PackedVector2Array
		b.resize(len(a))

		for i in range(len(b)):
			b[i] = a[i]
		return b

	static func shuffle(pos: PackedVector2Array, tangents: PackedVector2Array) -> PackedVector4Array:
		assert(len(pos) == len(tangents))
		var pos_norm_arr := Shapes.empty_4d(len(pos))
		for i in range(len(pos)):
			pos_norm_arr[i] = Vector4(pos[i].x, pos[i].y, tangents[i].x, tangents[i].y)
		return pos_norm_arr

	static func data_2d(num: int, val: Vector2 = Vector2.ZERO) -> PackedVector2Array:
		var empty: PackedVector2Array;
		empty.resize(num)
		for i in range(len(empty)):
			empty[i] = val
		return empty;
		
	static func data_3d(num: int, val: Vector3 = Vector3.ZERO) -> PackedVector3Array:
		var empty: PackedVector3Array;
		empty.resize(num)
		for i in range(len(empty)):
			empty[i] = val
		return empty;
	
	static func join(memories: Array[PackedVector2Array]) -> PackedVector2Array:
		var collector: PackedVector2Array
		collector.resize(0)
		for memory in memories:
			collector.append_array(memory)
		
		return collector
