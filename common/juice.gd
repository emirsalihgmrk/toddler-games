extends Object
class_name Juice

## Central home for the small, shared "juice" animations used across mini-games:
##  - a gentle idle wobble that objects play at rest
##  - a colorful sparkle burst for a correct placement
##
## All methods are static so any scene can call e.g.
##   Juice.start_wobble(item)
##   Juice.celebrate(self, global_center)

const _WOBBLE_META := "juice_wobble_tween"

## Gentle, looping side-to-side wobble. `item` is any Control (e.g. TextureRect).
## `initial_delay` staggers multiple items so they don't wobble in unison.
static func start_wobble(item: Control, initial_delay := 0.0) -> void:
	stop_wobble(item)  # never stack two wobbles on the same item
	item.pivot_offset = item.size / 2.0
	var tw := item.create_tween().set_loops()
	tw.tween_interval(initial_delay)
	tw.tween_property(item, "rotation_degrees",  4.5, 0.30).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(item, "rotation_degrees", -4.5, 0.60).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(item, "rotation_degrees",  0.0, 0.30).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_interval(2.2)
	item.set_meta(_WOBBLE_META, tw)

## Stop an item's wobble and reset its rotation.
static func stop_wobble(item: Control) -> void:
	if item.has_meta(_WOBBLE_META):
		var tw = item.get_meta(_WOBBLE_META)
		if tw is Tween and tw.is_valid():
			tw.kill()
		item.remove_meta(_WOBBLE_META)
	item.rotation_degrees = 0.0

## Play a colorful sparkle burst at `global_pos`. `host` is any node already in
## the scene tree (the burst adds itself as a child and frees itself when done).
static func celebrate(host: Node, global_pos: Vector2, count := 14) -> void:
	var burst := SparkleBurst.new()
	host.add_child(burst)
	burst.global_position = global_pos
	burst.burst(count)
