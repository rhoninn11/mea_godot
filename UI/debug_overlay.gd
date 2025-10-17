extends Control

@onready var text: = $"ColorRect/Label"
@onready var sprite: Sprite2D = $"Sprite2D"

var num: int = 0;
func _ready() -> void:
	print(sprite);
	var x: int = 8;
	var y: int = 8;
	num = y*x;
	spawn_inertias();
	intert_pre_compute();
	sprite.texture = a_textures[0]


var swap_every: float = 0.1;
var swap_timer: float = 0;
var swap_counter: int = 0;

func _process(_delta: float) -> void:
	var dbg_msgs: = UiManager.debug_map;

	var m_str: = ""
	for k in dbg_msgs:
		m_str += "K: %20s | %s\n" % [k, dbg_msgs[k]]
	
	text.text = m_str

	swap_timer += _delta;
	if swap_timer >= swap_every:
		swap_timer -= swap_every;
		swap_counter = (swap_counter+1)%num;
		sprite.texture = a_textures[swap_counter];
		

var a_inertias: Array[Inertia];
var a_images: Array[Image];
var a_textures: Array[ImageTexture];

var tex_x: int = 64
var tex_y: int = 64

func spawn_inertias() -> void: 
	var a_cfgs: Array[InertConfig];

	a_cfgs.resize(num)
	for i in range(num):
		var cfg: = InertConfig.new()
		cfg.m_freq = i*0.05;
		a_cfgs[i] = cfg
	
	a_inertias.resize(num)
	for i in range(num):
		var fresh = Inertia.init(a_cfgs[i]);
		fresh.reset(0)
		a_inertias[i] = fresh;
	
	a_images.resize(num)
	for i in range(num):
		var img: = Image.create(64, 64, false, Image.Format.FORMAT_RH);
		img.fill(Color.BLACK);
		a_images[i] = img;
	
func intert_pre_compute() -> void:
	var last: int = num-1;
	for i in range(num):
		calc_results(i, i == last);

	a_textures.resize(num)
	for i in range(num):
		var tex: = ImageTexture.new();
		tex.set_image(a_images[i])
		a_textures[i] = tex;
		
func calc_results(idx: int, verb: bool) -> void:
	var target: float = 1;
	var sim_time_s: float = 5;
	var y_range: float = 2;
	var y_offset: float = -0.5;

	var sim_step_s: float = 0.005;
	var pix_size_x_s: float = sim_time_s/float(tex_x)
	var pix_size_y_val: float = y_range/float(tex_y)

	var time_now: float = 0;
	var dut: = a_inertias[idx];
	var result: = a_images[idx];
	var pix_idx: int = 0;
	var pix_steps: int = 0;
	var pix_sum: float = 0;
	while time_now < sim_time_s:
		dut.simulate(target, sim_step_s)	
		var pix_idx_next = int(time_now/pix_size_x_s);
		time_now += sim_step_s

		pix_steps += 1;	
		pix_sum += dut.result();

		if pix_idx_next != pix_idx:
			var avg_val: = pix_sum/float(pix_steps);
			var y_val: float = (avg_val - y_offset)/pix_size_y_val
			var y_pix_idx: int = tex_y - clamp(int(y_val), 0, tex_y);
			if verb:
				print("trace ", pix_idx, "x", y_pix_idx)

			result.set_pixel(pix_idx, y_pix_idx, Color.WHITE)
			pix_idx = pix_idx_next;
			
