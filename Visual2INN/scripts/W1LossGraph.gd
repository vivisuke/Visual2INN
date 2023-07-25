extends ColorRect

var vec_loss = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	pass

func _draw():
	var loss0 = vec_loss.min()
	var loss9 = vec_loss.max()
	for x in range(vec_loss.size()):
		draw_circle(Vector2(x, 100 - (vec_loss[x] - loss0)*10000), 1.0, Color.BLUE)
	pass
