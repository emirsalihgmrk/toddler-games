extends Node2D
class_name SparkleBurst

## A small, colorful one-shot burst of sparkles + an expanding ring.
## Self-contained: spawn it, call burst(), and it frees itself when done.
## Centralised here so every mini-game can reuse the same "correct!" pop.

const COLORS := [
	Color(1.00, 0.22, 0.22),
	Color(1.00, 0.60, 0.00),
	Color(1.00, 0.93, 0.00),
	Color(0.18, 0.84, 0.18),
	Color(0.18, 0.60, 1.00),
	Color(0.70, 0.18, 1.00),
	Color(1.00, 0.28, 0.80),
	Color(0.18, 0.93, 0.88),
]

var _life := 0.75
var _t    := 0.0
var _parts: Array = []

func _ready() -> void:
	z_index = 100  # draw above the game pieces

## Kick off the burst. Call right after adding the node to the tree.
func burst(count := 14) -> void:
	for i in count:
		var ang := randf() * TAU
		var spd := randf_range(140.0, 360.0)
		_parts.append({
			pos    = Vector2.ZERO,
			vel    = Vector2(cos(ang), sin(ang)) * spd,
			size   = randf_range(6.0, 13.0),
			col    = COLORS[i % COLORS.size()],
			spin   = randf() * TAU,
			spin_v = randf_range(-7.0, 7.0),
		})

func _process(delta: float) -> void:
	_t += delta
	if _t >= _life:
		queue_free()
		return
	var damp := pow(0.08, delta)  # ease outward motion to a stop
	for p in _parts:
		p.vel *= damp
		p.pos += p.vel * delta
		p.spin += p.spin_v * delta
	queue_redraw()

func _draw() -> void:
	var k := 1.0 - (_t / _life)  # 1 -> 0 over lifetime

	# Expanding, fading ring.
	var ring_r: float = lerp(6.0, 70.0, 1.0 - k)
	draw_arc(Vector2.ZERO, ring_r, 0.0, TAU, 32, Color(1, 1, 1, k * 0.6), 4.0, true)

	# Sparkles.
	for p in _parts:
		var c: Color = p.col
		c.a = k
		_draw_sparkle(p.pos, p.size * (0.5 + 0.5 * k), p.spin, c)

func _draw_sparkle(center: Vector2, radius: float, rot: float, col: Color) -> void:
	const SPIKES := 4
	var pts := PackedVector2Array()
	for i in SPIKES * 2:
		var r: float = radius if i % 2 == 0 else radius * 0.4
		var a := rot + PI * float(i) / float(SPIKES)
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	draw_colored_polygon(pts, col)
