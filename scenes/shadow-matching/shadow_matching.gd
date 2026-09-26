extends Control

const SNAP_THRESHOLD  := 90.0
const SHAPE_SETS := [
	["circle", "heart", "star", "triangle"],
	["square", "cloud", "flower", "hexagon"],
]
const LevelCompleteScene = preload("res://scenes/level_complete/level_complete.tscn")

var _shapes        : Array       = []
var _dragging      : TextureRect = null
var _drag_offset   : Vector2
var _item_home_pos : Dictionary  = {}
var _item_home_size: Dictionary  = {}
var _matched_count := 0
var _wobble_tweens : Dictionary  = {}

@onready var right_panel : Panel             = $RightPanel
@onready var snd_pickup  : AudioStreamPlayer = $SndPickup
@onready var snd_correct : AudioStreamPlayer = $SndCorrect
@onready var snd_wrong   : AudioStreamPlayer = $SndWrong
@onready var snd_success : AudioStreamPlayer = $SndSuccess

func _ready() -> void:
	var level_shapes: Array = SHAPE_SETS[GameState.current_level % SHAPE_SETS.size()]
	for i in 4:
		var s_lower: String = level_shapes[i]
		var s_cap: String = s_lower.capitalize()
		_shapes.append(s_cap)
		var tex    := load("res://scenes/shadow-matching/assets/sprites/" + s_lower + ".png") as Texture2D
		var shadow := get_node("Shadow_" + str(i)) as TextureRect
		var drag   := right_panel.get_node("DragItem_" + str(i)) as TextureRect
		shadow.texture = tex
		drag.texture   = tex
		shadow.name    = "Shadow_"   + s_cap
		drag.name      = "DragItem_" + s_cap
		_item_home_pos[s_cap]  = drag.position
		_item_home_size[s_cap] = drag.size
	$BackButton.pressed.connect(_on_back_pressed)
	var delays := [0.0, 0.9, 1.8, 2.7]
	for i in _shapes.size():
		var item := right_panel.get_node("DragItem_" + _shapes[i]) as TextureRect
		_start_wobble(item, delays[i])

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_try_pick_up(event.global_position)
		elif _dragging:
			_try_drop()
	elif event is InputEventMouseMotion and _dragging:
		_dragging.global_position = event.global_position + _drag_offset

func _try_pick_up(gpos: Vector2) -> void:
	for s in _shapes:
		var item := _find_item(s)
		if item and not item.get_meta("matched", false) \
				and item.get_global_rect().has_point(gpos):
			_stop_wobble(item)
			var saved_pos := item.global_position
			item.reparent(self)
			item.global_position = saved_pos
			_dragging    = item
			_drag_offset = saved_pos - gpos
			snd_pickup.play()
			return

func _try_drop() -> void:
	var item  := _dragging
	_dragging  = null
	var shape := item.name.replace("DragItem_", "")

	var closest_shape := ""
	var closest_dist  := INF
	for s in _shapes:
		var shadow := get_node("Shadow_" + s) as TextureRect
		if not shadow.visible:
			continue
		var d := item.get_global_rect().get_center() \
				.distance_to(shadow.get_global_rect().get_center())
		if d < closest_dist:
			closest_dist  = d
			closest_shape = s

	if closest_dist <= SNAP_THRESHOLD:
		if closest_shape == shape:
			_correct_match(item, shape)
		else:
			snd_wrong.play()
			_shake_then_return(item, shape)
	else:
		_return_home(item, shape)

func _correct_match(item: TextureRect, shape: String) -> void:
	var shadow := get_node("Shadow_" + shape) as TextureRect
	item.set_meta("matched", true)
	shadow.hide()
	snd_correct.play()

	var tw := create_tween().set_parallel()
	tw.tween_property(item, "global_position", shadow.global_position, 0.18)
	tw.tween_property(item, "size",            shadow.size,            0.18)
	tw.chain().tween_callback(func(): _start_wobble(item, 0.0))

	_matched_count += 1
	if _matched_count >= _shapes.size():
		tw.chain().tween_interval(0.4)
		tw.chain().tween_callback(_show_level_complete)

func _show_level_complete() -> void:
	var lc := LevelCompleteScene.instantiate() as LevelComplete
	add_child(lc)
	lc.completed.connect(_advance_level)
	lc.start(snd_success.stream)

func _advance_level() -> void:
	GameState.current_level = (GameState.current_level + 1) % SHAPE_SETS.size()
	get_tree().reload_current_scene()

func _return_home(item: TextureRect, shape: String) -> void:
	item.reparent(right_panel, false)
	item.position = _item_home_pos[shape]
	item.size     = _item_home_size[shape]
	_start_wobble(item, 0.6)

func _find_item(shape: String) -> TextureRect:
	if right_panel.has_node("DragItem_" + shape):
		return right_panel.get_node("DragItem_" + shape) as TextureRect
	return get_node_or_null("DragItem_" + shape) as TextureRect

func _shake_then_return(item: TextureRect, shape: String) -> void:
	item.pivot_offset = item.size / 2.0
	var tw := create_tween()
	tw.tween_property(item, "rotation_degrees",  9.0, 0.08).set_trans(Tween.TRANS_SINE)
	tw.tween_property(item, "rotation_degrees", -9.0, 0.12).set_trans(Tween.TRANS_SINE)
	tw.tween_property(item, "rotation_degrees",  7.0, 0.10).set_trans(Tween.TRANS_SINE)
	tw.tween_property(item, "rotation_degrees", -7.0, 0.10).set_trans(Tween.TRANS_SINE)
	tw.tween_property(item, "rotation_degrees",  0.0, 0.08).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(func(): _return_home(item, shape))

func _start_wobble(item: TextureRect, initial_delay: float) -> void:
	item.pivot_offset = item.size / 2.0
	var tw := create_tween().set_loops()
	tw.tween_interval(initial_delay)
	tw.tween_property(item, "rotation_degrees",  4.5, 0.30).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(item, "rotation_degrees", -4.5, 0.60).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(item, "rotation_degrees",  0.0, 0.30).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_interval(2.2)
	_wobble_tweens[item.name] = tw

func _stop_wobble(item: TextureRect) -> void:
	if _wobble_tweens.has(item.name):
		_wobble_tweens[item.name].kill()
		_wobble_tweens.erase(item.name)
	item.rotation_degrees = 0.0

func _on_back_pressed() -> void:
	get_tree().reload_current_scene()
