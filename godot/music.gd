extends AudioStreamPlayer

signal beat(beat)
signal intro
signal ending
signal no_input(noInputBeats)
signal get_ready(beat)

@export var beatsPerMinute : float = 120;
@export var beatsPerMeasure: int = 4;
@export var beatOffset : float = 0;
# What they are in LMMS -1, because it starts counting at 1, while we start with 0
@export var songIntroMeasures: int = -1;
@export var songEndingMeasures: int = -1;
@export var active : bool = true
@export var trial : bool = false

var songIntroBeats : int = 0;
var songEndingBeats : int = 0;

var beatsPerSecond : float;
var beatTime : float;
var totalNumberOfBeats : int;
var countedNumberOfBeats : int;

var currentError : float = 0;
var averageError : float = 0;
var totalError : float = 0;

var currentBeat : int = -1;
var previousBeat : int = -2;

var currentPosition : float = 0.0;
var nextBeat : float;
var lastBeat : float;

var lastInputBeat : int = 0;
var noInputBeats : int = 0;

enum SongStateEnum {
	NOT_STARTED = 0,
	INTRO = 1,
	MIDDLE = 2,
	ENDING = 3,
	STOPPED = 4
}

# Current state of the song
var previousSongState : int = SongStateEnum.NOT_STARTED;
var songState : int = SongStateEnum.INTRO;

func _ready() -> void:
	if (active):
		self.play()
	if (songIntroMeasures != -1):
		songIntroMeasures -= 1
	if (songEndingMeasures != -1):
		songEndingMeasures -= 1
	beatsPerSecond = beatsPerMinute/60.0;
	beatTime = 1.0/beatsPerSecond;
	songIntroBeats = songIntroMeasures * beatsPerMeasure;
	songEndingBeats = songEndingMeasures * beatsPerMeasure;

func activate():
	active = true
	self.play()
	
func deactivate():
	active = false
	self.stop()

func _physics_process(_delta: float) -> void:
	if (songState == SongStateEnum.STOPPED or not active):
		return;
	
	# Current position within the song, aligned with beats
	currentPosition = ((self.get_playback_position() + AudioServer.get_time_since_last_mix()) + beatOffset)/beatTime;
	
	# Calculate Error for this position
	nextBeat = ceil(currentPosition);
	lastBeat = floor(currentPosition);
	if (currentPosition > lastBeat + 0.5):  
		currentError = nextBeat - currentPosition
	else:
		currentError = currentPosition - lastBeat
	
	# Exact beat
	if (currentBeat != int(lastBeat)):
		currentBeat = int(lastBeat);
		if (currentBeat != previousBeat):
			previousBeat = currentBeat;
			
			# Send a beat out
			beat.emit(currentBeat%beatsPerMeasure);
			
			totalNumberOfBeats += 1;
			
			# Check if we're in the intro or ending
			if (songIntroMeasures != -1 and totalNumberOfBeats < songIntroBeats + 1):
				songState = SongStateEnum.INTRO
				get_ready.emit(abs(songIntroBeats - currentBeat) - 1);
			elif (songEndingMeasures != -1 and totalNumberOfBeats > songEndingBeats):
				songState = SongStateEnum.ENDING
			else:
				songState = SongStateEnum.MIDDLE
			
			# Only count beats that are not part of the intro or ending
			if (songState == SongStateEnum.MIDDLE):
				countedNumberOfBeats += 1
				if (lastInputBeat < currentBeat-2 and not trial):
					# Punish player
					calculateError(-1)
					noInputBeats += 1;
					no_input.emit()
			
			# Tell the main function what part of the song we're in now
			if (songState != previousSongState):
				if (previousSongState == SongStateEnum.INTRO):
					intro.emit()
				if (songState == SongStateEnum.ENDING):
					ending.emit()
	previousSongState = songState

func getBeat(offset, errorMargin):
	lastInputBeat = currentBeat;
	var beatFailed = false;
	var error = currentError + offset
	if (abs(error) < errorMargin):
		calculateError(error)
	else:
		beatFailed = true;
	#print("%d/%d" % [songState,SongStateEnum.MIDDLE])
	return {
		"isBeatCountable": songState == SongStateEnum.MIDDLE,
		"error": error,
		"currentBeat": currentBeat,
		"beatFailed": beatFailed,
	}

func calculateError(error):
	averageError += abs(error);
	totalError += error;

func getAverageError() -> float:
	return averageError/float(countedNumberOfBeats);
	
func getTotalError() -> float:
	return totalError;

func getNoInputs() -> int:
	return noInputBeats;

func _on_finished() -> void:
	songState = SongStateEnum.STOPPED
	pass # Replace with function body.
