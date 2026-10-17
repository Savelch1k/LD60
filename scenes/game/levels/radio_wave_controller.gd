extends Node3D
## Attach this script to the Main_room root.
## It assigns independent oscilloscope materials to gadget/screen1 and gadget/screen2.

const WAVE_SHADER: Shader = preload("res://scenes/game/levels/radio_wave_screen.gdshader")

@export_group("Screen 1 — tuning")
@export_range(2.0, 35.0, 0.5) var tuning_frequency: float = 15.0
@export_range(0.05, 0.4, 0.01) var tuning_amplitude: float = 0.20

@export_group("Screen 2 — calibration")
@export_range(2.0, 35.0, 0.5) var calibration_frequency: float = 15.0
@export_range(0.05, 0.4, 0.01) var calibration_amplitude: float = 0.20
@export_range(-1.0, 1.0, 0.01) var calibration_phase: float = 0.38
@export_range(0.5, 1.5, 0.01) var calibration_scale: float = 0.92

@export_group("CRT look")
@export var noise_strength: float = 0.012
@export var glow_strength: float = 1.8

var _screen1_material: ShaderMaterial
var _screen2_material: ShaderMaterial

func _ready() -> void:
	var screen1 := get_node_or_null("gadget/WaveScreen1") as MeshInstance3D
	var screen2 := get_node_or_null("gadget/WaveScreen2") as MeshInstance3D

	if screen1 == null or screen2 == null:
		push_error("RadioWaveController: expected nodes gadget/screen1 and gadget/screen2.")
		return

	_screen1_material = _make_material(0)
	_screen2_material = _make_material(1)
	screen1.material_override = _screen1_material
	screen2.material_override = _screen2_material
	_update_materials()

func _process(_delta: float) -> void:
	# Uniforms are updated only when needed; TIME animates the shader by itself.
	pass

func _make_material(mode: int) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = WAVE_SHADER
	material.set_shader_parameter("display_mode", mode)
	material.set_shader_parameter("noise_strength", noise_strength)
	material.set_shader_parameter("glow_strength", glow_strength)
	return material

func _update_materials() -> void:
	if _screen1_material == null or _screen2_material == null:
		return

	_screen1_material.set_shader_parameter("frequency", tuning_frequency)
	_screen1_material.set_shader_parameter("amplitude", tuning_amplitude)

	_screen2_material.set_shader_parameter("frequency", calibration_frequency)
	_screen2_material.set_shader_parameter("amplitude", calibration_amplitude)
	_screen2_material.set_shader_parameter("phase_offset", calibration_phase)
	_screen2_material.set_shader_parameter("frequency_scale", calibration_scale)

func set_tuning_frequency(value: float) -> void:
	tuning_frequency = clampf(value, 2.0, 35.0)
	if _screen1_material:
		_screen1_material.set_shader_parameter("frequency", tuning_frequency)

func set_calibration_phase(value: float) -> void:
	calibration_phase = clampf(value, -1.0, 1.0)
	if _screen2_material:
		_screen2_material.set_shader_parameter("phase_offset", calibration_phase)

func set_calibration_scale(value: float) -> void:
	calibration_scale = clampf(value, 0.5, 1.5)
	if _screen2_material:
		_screen2_material.set_shader_parameter("frequency_scale", calibration_scale)

func set_calibration_amplitude(value: float) -> void:
	calibration_amplitude = clampf(value, 0.05, 0.4)
	if _screen2_material:
		_screen2_material.set_shader_parameter("amplitude", calibration_amplitude)
