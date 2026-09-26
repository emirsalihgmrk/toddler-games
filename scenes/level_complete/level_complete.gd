extends CanvasLayer
class_name LevelComplete

signal completed

func _ready() -> void:
	var vp_size := get_viewport().get_visible_rect().size
	$BG.size               = vp_size
	$UI.size               = vp_size
	$UI/Center.size        = vp_size
	await get_tree().process_frame
	_animate()

func start(stream: AudioStream) -> void:
	$Audio.stream = stream
	$Audio.play()
	$Audio.finished.connect(func(): completed.emit())

func _animate() -> void:
	var label: Label = $UI/Center/VBox/CongratsLabel

	label.pivot_offset = label.size / 2.0

	# Pulse scale
	var tw_s := create_tween().set_loops()
	tw_s.tween_property(label, "scale", Vector2(1.09, 1.09), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw_s.tween_property(label, "scale", Vector2(1.0,  1.0 ), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Rainbow color cycle
	var cols := [
		Color(1.0, 0.2, 0.3),
		Color(1.0, 0.6, 0.0),
		Color(1.0, 0.9, 0.0),
		Color(0.2, 0.85, 0.2),
		Color(0.2, 0.6,  1.0),
		Color(0.7, 0.2,  1.0),
		Color(1.0, 0.3,  0.8),
	]
	var tw_c := create_tween().set_loops()
	for c in cols:
		tw_c.tween_property(label, "modulate", c, 0.38).set_trans(Tween.TRANS_SINE)
