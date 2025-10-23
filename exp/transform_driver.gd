class_name TransformDriver
extends Node3D

var m_ring_len: int = 64;
var m_ring_off: int = 0;

var ma_xforms: Array[Transform3D];
var ma_xform_bytes: PackedFloat32Array;

@export var alt_mode: bool = false;
var m_alt_init: bool = false;
var m_v3_snap: Vector3 = Vector3.ZERO

func _ready() -> void:
	ma_xforms.resize(m_ring_len);
	m_ring_off = 0;

func _push_xform(xform: Transform3D):
	ma_xforms[m_ring_off] = xform;
	m_ring_off = (m_ring_off + 1)%m_ring_len;

func _process(_delta: float) -> void:
	var g_xform: Transform3D = self.global_transform;
	if not alt_mode:
		_push_xform(g_xform)
		return;


	var step_m: float = 0.25;
	var v3_now: = g_xform.origin;
	if not m_alt_init:
		m_alt_init = true;
		m_v3_snap = v3_now;
	
	var pos_delta: = v3_now - m_v3_snap;
	var sq_dist: float = pos_delta.dot(pos_delta)
	
	if step_m*step_m < sq_dist:
		m_v3_snap = v3_now;
		print("new pos: ", m_v3_snap, "distant by from last: ", sqrt(sq_dist))
		_push_xform(g_xform)
			
			



func give_xforms() -> Array[Transform3D]:
	return ma_xforms;
