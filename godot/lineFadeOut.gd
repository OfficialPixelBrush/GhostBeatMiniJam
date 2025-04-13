extends Line2D
@onready var fade_tween := get_tree().create_tween()

var fade_duration := 0.2  # Or whatever duration you want

func _ready() -> void:
	no_fade_out()

func no_fade_in():
	modulate.a = 1.0

func no_fade_out():
	modulate.a = 0.0

func fade_in() -> void:
	fade_tween.kill()  # Ensure old tween is stopped
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(self, "modulate:a", 1.0, fade_duration)
	await fade_tween.finished

func fade_out() -> void:
	fade_tween.kill()
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	await fade_tween.finished
