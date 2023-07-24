extends TextureButton

const NODE_RADIUS = 25.0
const Y_LINE = 40+20
const LR_SPC = 30
#const TB_SPC = 60
const TOP_SPC = 70
const BTM_SPC = 20
var X_INPUT = 70
var X_ACT = 175
var X_SOFTMAX
var X_INPUT_2 = 175
var X_ACT_2 = 245
var X_OUTPUT = 280
var Y_1 = 75+10
var Y_X1 = 150+10
var Y_X2 = 225+10
var Y_P1
var Y_P2
var X_WEIGHT = 120
var X_AF = 225

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
	#X_INPUT_2 = r_width / 2.0
	#X_ACT = (X_INPUT + X_INPUT_2) / 2.0
	X_OUTPUT = r_width - (LR_SPC + NODE_RADIUS)
	X_ACT = X_INPUT + (X_OUTPUT - X_INPUT) / 3.0
	X_SOFTMAX = X_INPUT + (X_OUTPUT - X_INPUT) * 2.0 / 3.0
	#X_ACT_2 = (X_INPUT_2 + X_OUTPUT) / 2.0
	#X_WEIGHT = (X_INPUT + X_ACT) / 2.0
	#X_AF = (X_ACT + X_OUTPUT) / 2.0
	#
	Y_1 = TOP_SPC + NODE_RADIUS
	#Y_X1 = r_height / 2.0
	Y_X2 = r_height - (BTM_SPC + NODE_RADIUS)
	Y_X1 = (Y_1 + Y_X2) / 2.0
	Y_P1 = (Y_1 + Y_X1) / 2.0
	Y_P2 = (Y_X1 + Y_X2) / 2.0
	pass # Replace with function body.


func add_label(pos: Vector2, txt: String):
	var dx = 4 if txt.length() == 1 else 8
	var lbl = Label.new()
	lbl.add_theme_color_override("font_color", Color.BLACK)
	lbl.text = txt
	lbl.position = pos - Vector2(dx, 12)
	add_child(lbl)
func add_label_raw(pos: Vector2, txt: String):
	var lbl = Label.new()
	lbl.add_theme_color_override("font_color", Color.BLACK)
	lbl.text = txt
	lbl.position = pos
	add_child(lbl)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func draw_circle_outline(pos: Vector2, radius, col, txt: String):
	draw_circle(pos, radius, col)
	draw_arc(pos, radius, 0.0, 2*PI, 128, Color.BLACK, 0.75, true)
	if !initialized:
		add_label(pos, txt)
func _draw():
	# 背景＋影 描画
	var style_box = StyleBoxFlat.new()      # 影、ボーダなどを描画するための矩形スタイルオブジェクト
	style_box.bg_color = Color.WHITE if !selected else Color.LIGHT_CYAN  # 矩形背景色
	style_box.shadow_offset = Vector2(0, 4)     # 影オフセット
	style_box.shadow_size = 8                   # 影（ぼかし）サイズ
	style_box.shadow_color = Color.GRAY
	draw_style_box(style_box, Rect2(Vector2(0, 0), self.size))      # style_box に設定した矩形を描画
	# エッジ
	draw_line(Vector2(X_INPUT, Y_1), Vector2(X_ACT, Y_P1), Color.DARK_GRAY)
	draw_line(Vector2(X_INPUT, Y_X1), Vector2(X_ACT, Y_P1), Color.DARK_GRAY)
	draw_line(Vector2(X_INPUT, Y_X2), Vector2(X_ACT, Y_P1), Color.DARK_GRAY)
	draw_line(Vector2(X_INPUT, Y_1), Vector2(X_ACT, Y_P2), Color.DARK_GRAY)
	draw_line(Vector2(X_INPUT, Y_X1), Vector2(X_ACT, Y_P2), Color.DARK_GRAY)
	draw_line(Vector2(X_INPUT, Y_X2), Vector2(X_ACT, Y_P2), Color.DARK_GRAY)
	draw_line(Vector2(X_ACT, Y_P1), Vector2(X_OUTPUT, Y_P1), Color.DARK_GRAY)
	draw_line(Vector2(X_ACT, Y_P2), Vector2(X_OUTPUT, Y_P2), Color.DARK_GRAY)
	# ノード
	draw_circle_outline(Vector2(X_INPUT, Y_1), NODE_RADIUS, Color("#e0e0e0"), "1")
	draw_circle_outline(Vector2(X_INPUT, Y_X1), NODE_RADIUS, Color.WHITE, "x1")
	draw_circle_outline(Vector2(X_INPUT, Y_X2), NODE_RADIUS, Color.WHITE, "x2")
	draw_circle_outline(Vector2(X_ACT, Y_P1), NODE_RADIUS, Color.WHITE, "a1")
	draw_circle_outline(Vector2(X_ACT, Y_P2), NODE_RADIUS, Color.WHITE, "a2")
	#draw_circle_outline(Vector2(X_INPUT_2, Y_1), NODE_RADIUS, Color("#e0e0e0"), "1")
	#draw_circle_outline(Vector2(X_INPUT_2, Y_X1), NODE_RADIUS, Color.WHITE, "x1")
	#draw_circle_outline(Vector2(X_INPUT_2, Y_X2), NODE_RADIUS, Color.WHITE, "x2")
	#draw_circle_outline(Vector2(X_ACT_2, Y_X1), NODE_RADIUS, Color.WHITE, "a")
	draw_circle_outline(Vector2(X_OUTPUT, Y_P1), NODE_RADIUS, Color.WHITE, "P1")
	draw_circle_outline(Vector2(X_OUTPUT, Y_P2), NODE_RADIUS, Color.WHITE, "P2")
	#
