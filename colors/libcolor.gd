extends Node

class Utils:
	static func color_data(color_arr: Array[Color]) -> PackedFloat32Array:
		var num := len(color_arr)
		var data: PackedFloat32Array
		data.resize(num * 4)
		for i in range(num):
			var blend := color_arr[i];
			data[4*i] = blend.r
			data[4*i + 1] = blend.g
			data[4*i + 2] = blend.b
			data[4*i + 3] = blend.a
		
		return data

	static func gradient(hue_a: float, hue_b: float, num: int) -> PackedFloat32Array:
		var color_a: Color = Color.from_ok_hsl(hue_a, 0.62, 0.2)
		var color_b: Color = Color.from_ok_hsl(hue_b, 0.62, 0.2)
		
		var col_arr: Array[Color];
		col_arr.resize(num)
		for i in range(num):
			var prog: float = float(i)/float(num-1);
			col_arr[i] = color_a.lerp(color_b, prog)

		# data.fill(0.1)
		return color_data(col_arr)

	
	static func ok_gradient(ok_a: Vector3, ok_b: Vector3, num: int) -> PackedFloat32Array:
		var col_arr: Array[Color];
		col_arr.resize(num)
		for i in range(num):
			var prog: float = float(i)/float(num-1);
			var ok_vals := ok_a.lerp(ok_b, prog);
			col_arr[i] = Color.from_ok_hsl(ok_vals.x, ok_vals.y, ok_vals.z)

		return color_data(col_arr)