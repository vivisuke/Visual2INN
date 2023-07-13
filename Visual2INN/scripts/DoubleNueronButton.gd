extends TextureButton


const NODE_RADIUS = 25.0
const Y_LINE = 40
const LR_SPC = 30
const TB_SPC = 60
var X_INPUT = 70
var X_ACT = 175
var X_INPUT_2 = 175
var X_ACT_2 = 245
var X_OUTPUT = 280
var Y_1 = 75+10
var Y_X1 = 150+10
var Y_X2 = 225+10
var X_WEIGHT = 120
var X_AF = 225

var self_rect
var r_width
var r_height
var initialized = false
var selected = false

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
# Called when the node enters the scene tree for the first time.
func _ready():
	self_rect = self.get_rect()
	r_width = self_rect.size.x
	r_height = self_rect.size.y
	print(self_rect.position)
	print(self_rect.size)
	#
	X_INPUT = LR_SPC + NODE_RADIUS
	X_INPUT_2 = r_width / 2.0
	X_ACT = (X_INPUT + X_INPUT_2) / 2.0
	X_OUTPUT = r_width - (LR_SPC + NODE_RADIUS)
	X_ACT_2 = (X_INPUT_2 + X_OUTPUT) / 2.0
	X_WEIGHT = (X_INPUT + X_ACT) / 2.0
	X_AF = (X_ACT + X_OUTPUT) / 2.0
	#
	Y_1 = TB_SPC + NODE_RADIUS
	Y_X1 = r_height / 2.0
	Y_X2 = r_height - (TB_SPC + NODE_RADIUS)
	#
	#add_label(Vector2(X_WEIGHT, Y_X1-10-45), "*b")
	#add_label(Vector2(X_WEIGHT, Y_X1-10), "*w1")
	#add_label(Vector2(X_WEIGHT, Y_X1-10+45), "*w2")
	#add_label(Vector2(X_AF, Y_X1-10), "h()")
	#
	add_label_raw(Vector2(X_INPUT, Y_LINE-24), "Affine")
	add_label_raw(Vector2(X_ACT+10, Y_LINE-24), "ActvFunc")
	add_label_raw(Vector2(X_INPUT_2+20, Y_LINE-24), "Affine")
	add_label_raw(Vector2(X_ACT_2+20, Y_LINE-24), "ActvFunc")
	#
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func point_in_rect(ctrl: Control, pnt: Vector2) -> bool:
	var pos = ctrl.position
	var sz = ctrl.size
	return (pnt.x >= pos.x && pnt.x < pos.x + sz.x &&
			pnt.y >= pos.y && pnt.y < pos.y + sz.y)
func _input(event):
	if event is InputEventMouseButton:
		var mpos = get_global_mouse_position()
		if point_in_rect(self, mpos):
			selected = !event.is_released()
			print(event.is_released())
			print(get_local_mouse_position())
			queue_redraw()
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
	draw_line(Vector2(X_INPUT, Y_1), Vector2(X_ACT, Y_X1), Color.DARK_GRAY)
	draw_line(Vector2(X_INPUT, Y_X1), Vector2(X_ACT, Y_X1), Color.DARK_GRAY)
	draw_line(Vector2(X_INPUT, Y_X2), Vector2(X_ACT, Y_X1), Color.DARK_GRAY)
	draw_line(Vector2(X_INPUT, Y_1), Vector2(X_ACT, Y_X2), Color.DARK_GRAY)
	draw_line(Vector2(X_INPUT, Y_X1), Vector2(X_ACT, Y_X2), Color.DARK_GRAY)
	draw_line(Vector2(X_INPUT, Y_X2), Vector2(X_ACT, Y_X2), Color.DARK_GRAY)
	draw_line(Vector2(X_ACT, Y_X1), Vector2(X_OUTPUT, Y_X1), Color.DARK_GRAY)
	draw_line(Vector2(X_ACT, Y_X2), Vector2(X_INPUT_2, Y_X2), Color.DARK_GRAY)
	draw_line(Vector2(X_INPUT_2, Y_1), Vector2(X_ACT_2, Y_X1), Color.DARK_GRAY)
	draw_line(Vector2(X_INPUT_2, Y_X1), Vector2(X_ACT_2, Y_X1), Color.DARK_GRAY)
	draw_line(Vector2(X_INPUT_2, Y_X2), Vector2(X_ACT_2, Y_X1), Color.DARK_GRAY)
	# ノード
	draw_circle_outline(Vector2(X_INPUT, Y_1), NODE_RADIUS, Color("#e0e0e0"), "1")
	draw_circle_outline(Vector2(X_INPUT, Y_X1), NODE_RADIUS, Color.WHITE, "x1")
	draw_circle_outline(Vector2(X_INPUT, Y_X2), NODE_RADIUS, Color.WHITE, "x2")
	draw_circle_outline(Vector2(X_ACT, Y_X1), NODE_RADIUS, Color.WHITE, "a")
	draw_circle_outline(Vector2(X_ACT, Y_X2), NODE_RADIUS, Color.WHITE, "a")
	draw_circle_outline(Vector2(X_INPUT_2, Y_1), NODE_RADIUS, Color("#e0e0e0"), "1")
	draw_circle_outline(Vector2(X_INPUT_2, Y_X1), NODE_RADIUS, Color.WHITE, "x1")
	draw_circle_outline(Vector2(X_INPUT_2, Y_X2), NODE_RADIUS, Color.WHITE, "x2")
	draw_circle_outline(Vector2(X_ACT_2, Y_X1), NODE_RADIUS, Color.WHITE, "a")
	draw_circle_outline(Vector2(X_OUTPUT, Y_X1), NODE_RADIUS, Color.WHITE, "y")
	# 上部線
	draw_line(Vector2(X_INPUT-NODE_RADIUS+5, Y_LINE), Vector2(X_ACT-5, Y_LINE), Color.BLACK)
	draw_line(Vector2(X_ACT+5, Y_LINE), Vector2(X_INPUT_2-5, Y_LINE), Color.BLACK)
	draw_line(Vector2(X_INPUT_2+5, Y_LINE), Vector2(X_ACT_2-5, Y_LINE), Color.BLACK)
	draw_line(Vector2(X_ACT_2+5, Y_LINE), Vector2(X_OUTPUT+NODE_RADIUS-5, Y_LINE), Color.BLACK)
	#
	initialized = true
	pass
