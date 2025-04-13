extends Node2D

@onready var metronome_first: AudioStreamPlayer = $MetronomeFirst
@onready var metronome_other: AudioStreamPlayer = $MetronomeOther
@onready var failure: AudioStreamPlayer = $Failure
@onready var beatSound: AudioStreamPlayer = $BeatSound

@export var music_player : AudioStreamPlayer;
@onready var game_music_player: AudioStreamPlayer = $GameMusicPlayer

@onready var timing_label: Label = $CanvasLayer/VBoxContainer/TimingLabel
@onready var timing_slider: HSlider = $CanvasLayer/VBoxContainer/HBoxContainer/TimingSlider

@onready var ratings: HBoxContainer = $CanvasLayer/RatingsHBoxContainer
@onready var rating_label: Label = $CanvasLayer/RatingsHBoxContainer/RatingsVBoxContainer/RatingLabel
@onready var error_label: Label = $CanvasLayer/RatingsHBoxContainer/RatingsVBoxContainer/ErrorLabel

@onready var perfect_rating: AudioStreamPlayer = $RatingSounds/PerfectRating
@onready var great_rating: AudioStreamPlayer = $RatingSounds/GreatRating
@onready var passable_rating: AudioStreamPlayer = $RatingSounds/PassableRating
@onready var bad_rating: AudioStreamPlayer = $RatingSounds/BadRating
@onready var fail_rating: AudioStreamPlayer = $RatingSounds/FailRating

@onready var menu: HBoxContainer = $CanvasLayer/Menu

@onready var music_volume_slider: HSlider = $CanvasLayer/Menu/VBoxContainer/MusicVolumeSlider
@onready var music_volume_text: Label = $CanvasLayer/Menu/VBoxContainer/MusicVolumeText
@onready var sfx_volume_text: Label = $CanvasLayer/Menu/VBoxContainer/SFXVolumeText
@onready var delay_text: Label = $CanvasLayer/Menu/VBoxContainer/DelayText
@onready var delay_slider: HSlider = $CanvasLayer/Menu/VBoxContainer/DelaySlider

@onready var crowd_layer: ParallaxLayer = $ParallaxBackground/CrowdLayer

@export var inputOffset: float = 0.0;
@export var errorMargin : float = 0.3;
@export var playMetronome : bool = false

const perfect : float = 0.95;
const great : float = 0.85;
const passable : float = 0.7;
const bad : float = 0.5;

@export var startGameBeats : int = 8;

var validBeat : bool = false;
var beatSubmitted : bool = false
var beatsHit : int = 0;
var beatsMissed : int = 0;
var numberOfBeats : int = 0;
var countedBeats : int = 0;
var noInputBeats : int = 0;
 
var menuMode = true;

var missedBeatMessages = [
	"Oof-",
	"Missed-",
	"Almost-",
	"Crud-",
	"Uh-",
	"Yikes-",
	"Oomph-",
	"Agh-",
	"Ugh-",
	"Yeesh-",
	"Ack-",
	"Heck-",
	"Just barely-",
	"Mh-",
	"Gah-"
]

var noInputMessages = [
	"Oops-",
	"Uh?",
	"Hello?",
	"Bud?",
	"Pal?",
	"Ya there?",
	"What's wrong?",
	"Did you leave?",
	"Are you alive?",
	"Need a medic?",
	"Lost your brain?",
	"Hola?",
	"Hallo?",
	"Bonjour?",
	"..."
]

func _ready() -> void:
	setMusicVolume(music_volume_slider.value)
	delay_text.text = "Delay: %.2f Beats" % inputOffset
	delay_slider.value = inputOffset

func switchMusicPlayer(player):
	music_player.deactivate()
	music_player = player;
	validBeat = false;
	beatSubmitted = false
	beatsHit = 0;
	beatsMissed = 0;
	numberOfBeats = 0;
	countedBeats = 0;
	noInputBeats = 0;
	music_player.activate()

func _input(event):
	if event.is_action_pressed("input_beat"):
		beatSound.play()
		var result = music_player.getBeat(inputOffset,errorMargin)
		#print(result)
		var error = result.error;
		if (result.isBeatCountable):
			if (result.beatFailed):
				timing_label.text = getFailMessage(0);
				failedBeat();
			else:
				timing_slider.value = error;
				timing_label.text = "%.2f Beats" % error;
				beatsHit += 1
		else:
			timing_label.text = "Wait!";
	if event.is_action_pressed("close_game"):
		get_tree().quit()

func getFailMessage(failType) -> String:
	match(failType):
		0: # Missed Beat
			return missedBeatMessages[randi() % missedBeatMessages.size()]
		1: # No Input
			return noInputMessages[min(noInputBeats,noInputMessages.size()-1)]
	return "Whoops-" 

func failedBeat() -> void:
	if (menuMode):
		beatsHit = 0
	beatsMissed += 1;
	failure.play();
 
func checkMenu():
	if (not menuMode):
		return;
	if (beatsHit > startGameBeats - 1):
		menuMode = false
		menu.hide()
		crowd_layer.show()
		switchMusicPlayer(game_music_player);

func _on_music_player_beat(beat) -> void:
	checkMenu()
	if (not playMetronome):
		return
	if (beat == 0):
		metronome_first.play();
	else:
		metronome_other.play();
	pass # Replace with function body.

func _on_music_player_finished() -> void:
	var averageError = music_player.getAverageError();
	var totalError = music_player.getTotalError();
	countedBeats = music_player.countedNumberOfBeats;
	
	var score : float = float(countedBeats-beatsMissed)/float(countedBeats);
	score -= abs(averageError);
	
	if (score > perfect):
		rating_label.text = "Perfect!"
		perfect_rating.play()
	elif (score > great):
		rating_label.text = "Great!"
		great_rating.play()
	elif (score > passable):
		rating_label.text = "Passable."
		passable_rating.play()
	elif (score > bad):
		rating_label.text = "Bad..."
		bad_rating.play()
	else:
		rating_label.text = "Fail..."
		fail_rating.play()
	
	error_label.text = "Score: %.2f%%" % (score*100.0)
	error_label.text += "\n"
	error_label.text += "Missed Beats: %d/%d Beats" % [beatsMissed, countedBeats]
	error_label.text += "\n"
	error_label.text += "Average Error: +/-%.2f Beats" % averageError
	error_label.text += "\n"
	error_label.text += "Total Error: %.2f Beats" % totalError
	ratings.show()

func _on_music_player_intro() -> void:
	print("Start now!")
	pass # Replace with function body.

func _on_music_player_ending() -> void:
	timing_label.text = "We're done!";
	print("You're done!")
	pass # Replace with function body.

func _on_music_player_no_input() -> void:
	failedBeat();
	timing_label.text = getFailMessage(1)
	noInputBeats += 1
	pass # Replace with function body.


func _on_music_player_get_ready(beat: Variant) -> void:
	if (beat < 5):
		playMetronome = true;
	if (beat < 4):
		timing_label.text = str(beat)
	if (beat <= 0):
		timing_label.text = "GO!";
		playMetronome = false
	pass # Replace with function body.


func _on_music_volume_slider_value_changed(value: float) -> void:
	setMusicVolume(value)
	pass # Replace with function body.

func setMusicVolume(value):
	music_volume_text.text = "Music Volume: %.0f%%" % (value*100)
	for node in self.get_children():
		if (node is AudioStreamPlayer and node.is_in_group("MusicPlayers")):
			node.volume_linear = value;

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	sfx_volume_text.text = "SFX Volume: %.0f%%" % (value*100)
	for node in self.get_children():
		if (node is AudioStreamPlayer and not node.is_in_group("MusicPlayers")):
			node.volume_linear = value;
	pass # Replace with function body.


func _on_metronome_toggle_toggled(toggled_on: bool) -> void:
	playMetronome = toggled_on;
	pass # Replace with function body.

func _on_delay_slider_value_changed(value: float) -> void:
	delay_text.text = "Delay: %.2f Beats" % value
	inputOffset = value;
	pass # Replace with function body.
