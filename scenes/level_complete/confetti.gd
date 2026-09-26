extends Node2D

const COLORS = [
	Color(1.00, 0.22, 0.22),
	Color(1.00, 0.60, 0.00),
	Color(1.00, 0.93, 0.00),
	Color(0.18, 0.84, 0.18),
	Color(0.18, 0.60, 1.00),
	Color(0.70, 0.18, 1.00),
	Color(1.00, 0.28, 0.80),
	Color(0.18, 0.93, 0.88),
]
const COUNT := 180

var _pieces: Array = []
var _sw: float
var _sh: float

func _ready() -> void:
	var vp := get_viewport_rect()
	_sw = vp.size.x
	_sh = vp.size.y
	for i in COUNT:
		_pieces.append(_spawn(true))

func _spawn(scatter_y: bool) -> Dictionary:
	return {
		x   = randf() * _sw,
		y   = -20.0 if not scatter_y else randf() * _sh,
		vx  = randf_range(-55.0, 55.0),
		vy  = randf_range(130.0, 270.0),
		rot = randf() * TAU,
		rv  = randf_range(-3.5, 3.5),
		w   = randf_range(8.0, 16.0),
		h   = randf_range(4.0,  9.0),
		col = COLORS[randi() % COLORS.size()],
	}

func _process(delta: float) -> void:
	for p in _pieces:
		p.x   += p.vx * delta
		p.y   += p.vy * delta
		p.rot += p.rv * delta
		if p.y > _sh + 20.0:
			p.merge(_spawn(false), true)
	queue_redraw()

func _draw() -> void:
	for p in _pieces:
		draw_set_transform(Vector2(p.x, p.y), p.rot)
		draw_rect(Rect2(-p.w * 0.5, -p.h * 0.5, p.w, p.h), p.col)
	draw_set_transform(Vector2.ZERO, 0.0)
