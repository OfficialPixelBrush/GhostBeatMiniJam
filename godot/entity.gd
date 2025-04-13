extends Node2D

@export var animation_player: AnimationPlayer
@export var defeat_particles: GPUParticles2D
@export var parts_skeleton_container: Node2D
@export var fade_duration : float = 1.0
@onready var fade_tween := get_tree().create_tween()

func beat():
	animation_player.play("hit_beat");

func defeat():
	animation_player.play("defeat");
	defeat_particles.restart(true)
	fade_tween.kill()
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	await fade_tween.finished
