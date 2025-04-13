extends Node2D

@export var animation_player: AnimationPlayer

func beat():
	animation_player.play("hit_beat");
