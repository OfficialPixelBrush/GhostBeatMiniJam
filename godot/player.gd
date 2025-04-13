extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_head: AnimatedSprite2D = $PartsSkeletonContainer/Parts/PlayerBody/PlayerHead

func beat():
	player_head.animation = "default"
	animation_player.stop()
	animation_player.play("hit_beat");
	animation_player.advance(0)

func missBeat():
	player_head.animation = "miss"
	animation_player.stop()
	animation_player.play("hit_beat");
	animation_player.advance(0)
