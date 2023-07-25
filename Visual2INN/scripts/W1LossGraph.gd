extends ColorRect

var vec_loss = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	pass
func fy(x, loss0):
	return size.y - (vec_loss[x] - loss0)*10000
func _draw():
	if vec_loss.is_empty(): return
	var loss0 = vec_loss.min()
	var loss9 = vec_loss.max()
	var points : PackedVector2Array
	for x in range(vec_loss.size()):
		#draw_circle(Vector2(x, 100 - (vec_loss[x] - loss0)*10000), 1.0, Color.BLUE)
		var y = fy(x, loss0)
		if y >= 0.0 && y < size.y:
			points.push_back(Vector2(x, y))
	draw_polyline(points, Color.BLUE, 1.0)
	draw_circle(Vector2(50, 100 - (vec_loss[50] - loss0)*10000), 3.0, Color.BLACK)
	pass
