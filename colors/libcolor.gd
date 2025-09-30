extends Node

class Utils:
    static func gradient(hue_a: float, hue_b: float, num: int) -> PackedFloat32Array:
        var data: PackedFloat32Array
        data.resize(num * 4)

        var color_a: Color = Color.from_ok_hsl(hue_a, 0.62, 0.2)
        var color_b: Color = Color.from_ok_hsl(hue_b, 0.62, 0.2)

        for i in range(num):
            var prog: float = float(i)/float(num-1);
            var blend = color_a.lerp(color_b, prog)
            print(blend, "with prog: ", prog)
            data[4*i] = blend.r
            data[4*i + 1] = blend.g
            data[4*i + 2] = blend.b
            data[4*i + 3] = blend.a

        # data.fill(0.1)
        return data