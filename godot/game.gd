extends Node2D

@onready var metronome_first: AudioStreamPlayer = $MetronomeFirst
@onready var metronome_other: AudioStreamPlayer = $MetronomeOther
@onready var failure: AudioStreamPlayer = $Failure
@onready var beat: AudioStreamPlayer = $Beat

@onready var music_player: AudioStreamPlayer = $MusicPlayer

@onready var timing_label: Label = $Camera2D/CanvasLayer/VBoxContainer/TimingLabel
@onready var timing_slider: HSlider = $Camera2D/CanvasLayer/VBoxContainer/HBoxContainer/TimingSlider

@onready var ratings: VBoxContainer = $Camera2D/CanvasLayer/HBoxContainer/Ratings
@onready var rating_label: Label = $Camera2D/CanvasLayer/HBoxContainer/Ratings/RatingLabel
@onready var error_label: Label = $Camera2D/CanvasLayer/HBoxContainer/Ratings/ErrorLabel

@export var inputOffset: float = 0.0;
@export var errorMargin : float = 0.3;

@onready var perfect_rating: AudioStreamPlayer = $RatingSounds/PerfectRating
@onready var great_rating: AudioStreamPlayer = $RatingSounds/GreatRating
@onready var passable_rating: AudioStreamPlayer = $RatingSounds/PassableRating
@onready var bad_rating: AudioStreamPlayer = $RatingSounds/BadRating
@onready var fail_rating: AudioStreamPlayer = $RatingSounds/FailRating


const perfect : float = 0.8;
const great : float = 0.6;
const passable : float = 0.4;
const bad : float = 0.2;

var validBeat : bool = false;
var beatSubmitted : bool = false
var beatsHit : int = 0;
var beatsMissed : int = 0;
var numberOfBeats : int = 0;

var playMetronome : bool = false

var missedBeatMessages = [
	"Oof-",
	"Missed-",
	"Almost-",
	"Crud-",
	"Uh-",
	"Yikes-",
	"Oomph-",
	"Agh-"
]

var noInputMessages = [
	"Oops-",
	"Uh?",
	"Hello?",
	"Ya there?",
	"Did you leave?",
	"Are you alive?",
	"What's wrong?",
	"..."
]

func _input(event):
	if event.is_action_pressed("ui_accept"):
		beat.play()
		var result = music_player.getBeat(inputOffset,errorMargin)
		var error = result.error;
		if (result.isBeatCountable):
			if (result.beatFailed):
				timing_label.text = getFailMessage(0);
				failedBeat();
			else:
				timing_slider.value = error;
				timing_label.text = "%.2f Beats" % error;
		else:
			timing_label.text = "Wait!";

func getFailMessage(failType) -> String:
	match(failType):
		0: # Missed Beat
			return missedBeatMessages[randi() % missedBeatMessages.size()]
		1: # No Input
			return noInputMessages[randi() % noInputMessages.size()]
	return "Whoops-"

func failedBeat() -> void:
	beatsMissed += 1;
	failure.play();

func _on_music_player_beat(beat) -> void:
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
	var countedBeats = music_player.countedNumberOfBeats;
	
	var score : float = float(countedBeats-beatsMissed)/float(countedBeats);
	#score -= abs(averageError);
	
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
