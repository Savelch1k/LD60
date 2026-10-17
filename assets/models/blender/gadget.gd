extends Node2D

# 🔹 ПЕРЕМЕННЫЕ
@onready var wave_texture: TextureRect = $WaveContainer/WaveTexture
@onready var calibration_slider: HSlider = $UI/HBoxContainer/CalibrationSlider
@onready var time_label: Label = $UI/StatusLabel

var current_wave_speed = 2.0
var target_wave_speed = 2.0
var wave_amplitude = 0.5

# 🔹 ФУНКЦИЯ: Обновляем волны каждый кадр
func _process(delta):
	var global_time = get_tree().get_ticks_msec() / 1000.0
	wave_material.set_shader_param("time", global_time)
	
	# Обновляем скорость волн от ползунка
	current_wave_speed += (target_wave_speed - current_wave_speed) * delta * 3
	
	# Показываем значение в UI
	time_label.text = "Signal Strength: %.1f%%" % (current_wave_speed * 50)

# 🔹 ФУНКЦИЯ: Калибровка через ползунок
func _on_calibration(value):
	target_wave_speed = 2.0 + value * 3.0  # Минимум: 2, Максимум: 11
	wave_amplitude = 0.5 - (value / 2.0)   # Меняем амплитуду
	
	# Обновляем материал в реальном времени
	if wave_material:
		wave_material.set_shader_param("wave_speed", current_wave_speed)
		wave_material.set_shader_param("amplitude", wave_amplitude)

# 🔹 ФУНКЦИЯ: Сброс волн (старт)
func reset_waves():
	target_wave_speed = 2.0
	wave_amplitude = 0.5
	calibration_slider.value = 0.0
