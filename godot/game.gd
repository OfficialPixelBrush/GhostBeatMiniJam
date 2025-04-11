extends Node2D

@onready var metronome_first: AudioStreamPlayer = $MetronomeFirst
@onready var metronome_other: AudioStreamPlayer = $MetronomeOther

@onready var music_player: AudioStreamPlayer = $MusicPlayer

@onready var indicator_1: Sprite2D = $Indicators/indicator_1
@onready var indicator_2: Sprite2D = $Indicators/indicator_2
@onready var indicator_3: Sprite2D = $Indicators/indicator_3
@onready var indicator_4: Sprite2D = $Indicators/indicator_4

func _on_music_player_beat(beat) -> void:
	print(beat)
	indicator_1.hide()
	indicator_2.hide()
	indicator_3.hide()
	indicator_4.hide()
	
	if (beat == 0):
		metronome_first.play();
		indicator_1.show()
	else:
		metronome_other.play();
		match(beat):
			1:
				indicator_2.show()
			2:
				indicator_3.show()
			3:
				indicator_4.show()
	pass # Replace with function body.
