extends TextureButton

const NODE_RADIUS = 30.0
const Y_LINE = 40
const LR_SPC = 60
const TB_SPC = 60
var X_INPUT = 70
var X_ACT = 175
var X_OUTPUT = 280
var Y_1 = 75+10
var Y_X1 = 150+10
var Y_X2 = 225+10
const X_WEIGHT = 120
const X_AF = 225

var self_rect
var r_width
var r_height
var initialized = false
var selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self_rect = self.get_rect()
	r_width = self_rect.size.x
	r_height = self_rect.size.y
	print(self_rect.position)
	print(self_rect.size)
	#
	X_INPUT = LR_SPC + NODE_RADIUS
	X_ACT = r_width / 2.0
	X_OUTPUT = r_width - (LR_SPC + NODE_RADIUS)
	#
	Y_1 = TB_SPC + NODE_RADIUS
	Y_X1 = r_height / 2.0
	Y_X2 = r_height - (TB_SPC + NODE_RADIUS)

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

func draw_circle_outline(pos: Vector2, radius, col, txt: String):
	draw_circle(pos, radius, col)
	draw_arc(pos, radius, 0.0, 2*PI, 128, Color.BLACK, 0.75, true)
	##if !initialized:
	##	add_label(pos, txt)
func _draw():
	# 背景＋影 描画
	var style_box = StyleBoxFlat.new()      # 影、ボーダなどを描画するための矩形スタイルオブジェクト
	style_box.bg_color = Color.WHITE if !selected else Color.LIGHT_CYAN  # 矩形背景色
	style_box.shadow_offset = Vector2(0, 4)     # 影オフセット
	style_box.shadow_size = 8                   # 影（ぼかし）サイズ
	style_box.shadow_color = Color.GRAY
	draw_style_box(style_box, Rect2(Vector2(0, 0), self.size))      # style_box に設定した矩形を描画
	# エッジ
	draw_line(Vector2(X_INPUT, Y_1), Vector2(X_ACT, Y_X1), Color.DARK_GRAY)
	draw_line(Vector2(X_INPUT, Y_X1), Vector2(X_ACT, Y_X1), Color.DARK_GRAY)
	draw_line(Vector2(X_INPUT, Y_X2), Vector2(X_ACT, Y_X1), Color.DARK_GRAY)
	draw_line(Vector2(X_ACT, Y_X1), Vector2(X_OUTPUT, Y_X1), Color.DARK_GRAY)
	# ノード
	draw_circle_outline(Vector2(X_INPUT, Y_1), NODE_RADIUS, Color("#e0e0e0"), "1")
	draw_circle_outline(Vector2(X_INPUT, Y_X1), NODE_RADIUS, Color.WHITE, "x1")
	draw_circle_outline(Vector2(X_INPUT, Y_X2), NODE_RADIUS, Color.WHITE, "x2")
	draw_circle_outline(Vector2(X_ACT, Y_X1), NODE_RADIUS, Color.WHITE, "a")
	draw_circle_outline(Vector2(X_OUTPUT, Y_X1), NODE_RADIUS, Color.WHITE, "y")
	pass
