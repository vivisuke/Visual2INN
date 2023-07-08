extends TextureButton

var self_rect
var selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self_rect = self.get_rect()
	print(self_rect.position)
	print(self_rect.size)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseButton:
		selected = !event.is_released()
		print(event.is_released())
		print(get_local_mouse_position())
		queue_redraw()
	pass

func _draw():
	# 背景＋影 描画
	var style_box = StyleBoxFlat.new()      # 影、ボーダなどを描画するための矩形スタイルオブジェクト
	style_box.bg_color = Color.WHITE if !selected else Color.LIGHT_CYAN  # 矩形背景色
	style_box.shadow_offset = Vector2(0, 4)     # 影オフセット
	style_box.shadow_size = 8                   # 影（ぼかし）サイズ
	style_box.shadow_color = Color.GRAY
	draw_style_box(style_box, Rect2(Vector2(0, 0), self.size))      # style_box に設定した矩形を描画
	#var col = Color.WHITE if !is_pressed else Color.AQUAMARINE
	#draw_rect(Rect2(Vector2(0, 0), self_rect.size), col)
	#draw_line(Vector2(0, 0), Vector2(100, 100), Color.BLACK)
	pass
