extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_head: AnimatedSprite2D = $PartsSkeletonContainer/Parts/PlayerBody/PlayerHead
@onready var line_2d: Line2D = $PartsSkeletonContainer/Parts/PlayerBody/PlayerCannon/Line2D

func beat():
	# Beam
	line_2d.show()
	line_2d.no_fade_in()
	line_2d.fade_out()
	# Player anim
	player_head.animation = "default"
	animation_player.stop()
	animation_player.play("hit_beat");
	animation_player.advance(0)

func missBeat():
	line_2d.hide()
	player_head.animation = "miss"
	animation_player.stop()
	animation_player.play("hit_beat");
	animation_player.advance(0)
