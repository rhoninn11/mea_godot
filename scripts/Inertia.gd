extends Resource
class_name Inertia

@export var k1: float = 0
@export var k2: float = 0
@export var k3: float = 0


static func init(in_data: InertConfig) -> Inertia:
	var inertia := Inertia.new()
	var f_helper := in_data.freq * PI
	inertia.k1 = in_data.zeta / f_helper
	inertia.k2 = 1 / (4 * f_helper * f_helper)
	inertia.k3 = (in_data.r * inertia.k1) / 2
	return inertia	


var y: float = 0
var y_d: float = 0

func simulate(target: float, delta: float) -> void:
	var x_d = 0;
	var x = target;

	var y_d_d = (x + self.k3 * x_d - self.y - self.k1 * self.y_d)/ self.k2
	self.y = self.y + delta * self.y_d
	self.y_d = self.y_d + delta * y_d_d	

func result() -> float:
	return y;
