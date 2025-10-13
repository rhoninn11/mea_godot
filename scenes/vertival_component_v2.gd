class_name VerticalComponentInert
extends VerticalComponent

# TODO: Stąd chciałbym przenieś inercję trochę wyżej

var inertia_x: Inertia = null;
var inertia_y: Inertia = null;
func _ready() -> void:
	var cfg_inertia := InertConfig.new();
	self.inertia_x = Inertia.init(cfg_inertia)
	self.inertia_y = Inertia.init(cfg_inertia)

	assert(inertia_x && inertia_y)

# func _process(delta: float) -> void:
# 	var mouse_capture := ControlContext.control_state == self.active_on
# 	simulate(delta, mouse_capture);

func simulate(_delta: float, cond: bool):
	var target = super.fn_val();
	self.inertia_x.simulate(target.x, _delta);
	self.inertia_y.simulate(target.y, _delta);

	super.simulate(_delta, cond);


func fn_val() -> Vector2:
	return Vector2(
		self.inertia_x.result(),
		self.inertia_y.result()
	)
