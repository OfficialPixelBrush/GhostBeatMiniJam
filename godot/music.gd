extends AudioStreamPlayer

signal beat(beat)
signal measure

@export var beatsPerMinute : int;
@export var beatsPerMeasure: int;
@export var offset : float = 0;
var beatsPerSecond : float;
var beatTime : float;

var currentBeat : int = -1;
var lastBeat : int = -2;
var currentPosition = 0;

func _ready() -> void:
	beatsPerSecond = beatsPerMinute/60.0;
	beatTime = 1.0/beatsPerSecond;

func _physics_process(delta: float) -> void:
	currentPosition = (self.get_playback_position() + AudioServer.get_time_since_last_mix()) + offset;
	
	if (currentBeat != floor(currentPosition/beatTime)):
		currentBeat = floor(currentPosition/beatTime);
		if (currentBeat != lastBeat):
			lastBeat = currentBeat;
			beat.emit(currentBeat%beatsPerMeasure);
			if (currentBeat == 0):
				measure.emit();
