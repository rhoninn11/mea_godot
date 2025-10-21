extends Node3D

var m_ring_len: int = 64;
var m_ring_off: int = 0;

var ma_xforms: Array[Transform3D];
var ma_xform_bytes: PackedFloat32Array;

func _ready() -> void:
	ma_xforms.resize(m_ring_len);
	m_ring_off = 0;

func _process(_delta: float) -> void:
	ma_xforms[m_ring_off] = self.global_transform;
	m_ring_off = (m_ring_off + 1)%m_ring_len;

func give_xforms() -> Array[Transform3D]:
	return ma_xforms;
