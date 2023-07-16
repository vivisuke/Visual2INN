extends Node2D

enum {
	AF_SIGMOID = 0, AF_TANH, AF_RELU, AF_LEAKY_RELU,	# 活性化関数種別
	WI_1 = 0, WI_001, WI_XAVIER, WI_HE,					# 重み標準偏差・初期化方法
}
# ニューロンクラス、N入力１出力
# 活性化関数：シグモイド・tanh・ReLU etc ?
class Neuron:
	func _init(n_in, af, deviation:float):
		n_input = n_in
		actv_func = af
		# 重みベクター初期化
		vec_weight.resize(n_input+1)
		init_weight(deviation)		# 指定標準偏差で乱数生成
	func init_weight(deviation:float):
		if false:
			for i in range(n_input+1):
				vec_weight[i] = randfn(0.0, deviation)
		else:
			if n_input == 2:
				vec_weight[0] = sin(randf_range(0.0, 2*PI))
				var th = randf_range(0.0, 2*PI)
				vec_weight[1] = cos(th)
				vec_weight[2] = sin(th)
			else:
				vec_weight[0] = sin(randf_range(0.0, 2*PI))
				var sum2 = 0.0
				for i in range(1, n_input+1):
					vec_weight[i] = randfn(0.0, deviation)
					sum2 += vec_weight[i] * vec_weight[i]
				var sq = sqrt(sum2)
				for i in range(1, n_input+1):
					vec_weight[i] /= sq
	func sigmoid(x): return 1.0/(1.0 + exp(-x))
	func ReLU(x): return x if x > 0.0 else 0.0
	func LeakyReLU(x): return x if x > 0.0 else 0.01*x
	func forward(inp: Array):
		a = vec_weight[0]
		for i in range(n_input):
			a += vec_weight[i+1] * inp[i]
		if actv_func == AF_TANH: y = tanh(a)
		elif actv_func == AF_SIGMOID: y = sigmoid(a)
		elif actv_func == AF_RELU: y = ReLU(a)
		elif actv_func == AF_LEAKY_RELU: y = LeakyReLU(a)
		#print("a = ", a, ", y = ", y)
	func backward(inp: Array, grad: float):
		upgrad = []		# 上流勾配
		var dyda
		if actv_func == AF_TANH: dyda = (1.0 - y*y)			# tanh
		elif actv_func == AF_SIGMOID: dyda = y * (1.0 - y)	# sigmoid
		elif actv_func == AF_RELU: dyda = (0.0 if y <= 0 else 1.0)		# ReLU
			#if y <= 0: dyda = 0.0
			#else: dyda = 1.0
		elif actv_func == AF_LEAKY_RELU: dyda = (0.01 if y <= 0 else 1.0)		# Leaky ReLU
		var dydag = dyda * grad
		upgrad.push_back(dydag)		# for b
		#print("∂L/∂y = ", grad)
		#print("∂y/∂a = ", dyda)
		for i in range(n_input):	# for w1, w2, ...
			upgrad.push_back(dydag * inp[i])
	var n_input		# 入力データ数
	var actv_func	# 活性化関数種別
	var vec_weight = []		# [b, w1, w2, w3, ... wN] 重みベクター
	var a					# a = b + w1*x1 + w2*x2 + ... wN*xN
	var y					# y = af(a)
	var upgrad				# 上流勾配
#
enum {
	OP_AND = 0, OP_OR, OP_NAND,
	OP_GT,		# x1 > x2
	OP_XOR,
	#
	LU_MINI_BATCH = 0, LU_ONLINE, LU_RANDOM_8,
}
const boolean_pos = [[0, 0], [1, 0], [0, 1], [1, 1]]
const boolean_pos_tanh = [[-1, -1], [1, -1], [-1, 1], [1, 1]]
var vec_weight11_init		# 重み初期値
var vec_weight12_init		# 重み初期値
var vec_weight2_init		# 第２層重み初期値
var n_iteration = 0			# 学習回数
var ope = OP_XOR
var actv_func = AF_SIGMOID
var false_0 = true			# false for false: -1.0
var ALPHA = 0.1				# 学習率
var norm = 0.1				# 重み初期化時標準偏差
#var neuron
var grad_11
var grad_12
var grad_2
#var first_layer = [0, 0]	# 第1層ニューロン
var neuron_11				# 第1層ニューロン その1
var neuron_12				# 第1層ニューロン その2
var neuron_2				# 第2層ニューロン

# Called when the node enters the scene tree for the first time.
func _ready():
	neuron_11 = Neuron.new(2, AF_SIGMOID, norm)
	neuron_12 = Neuron.new(2, AF_SIGMOID, norm)
	neuron_2 = Neuron.new(2, AF_SIGMOID, norm)
	vec_weight11_init = neuron_11.vec_weight.duplicate()
	vec_weight12_init = neuron_12.vec_weight.duplicate()
	vec_weight2_init = neuron_2.vec_weight.duplicate()
	$GraphRect1.ope = ope
	$GraphRect2.to_plot_boolean = false
	update_view()
	$LearnRate.text = "%.3f" % ALPHA
	pass # Replace with function body.
func update_view():
	$ItrLabel.text = "Iteration: %d" % n_iteration
	$Weight11Label.text = "[b, w1, w2] =\n  [%.2f, %.2f, %.2f]" % neuron_11.vec_weight
	$Weight12Label.text = "[b, w1, w2] =\n  [%.2f, %.2f, %.2f]" % neuron_12.vec_weight
	$Weight2Label.text = "[b, w1, w2] =\n  [%.2f, %.2f, %.2f]" % neuron_2.vec_weight
	$GraphRect1.vv_weight = [neuron_11.vec_weight, neuron_12.vec_weight]
	$GraphRect1.queue_redraw()
	$GraphRect2.vv_weight = [neuron_2.vec_weight]
	$GraphRect2.queue_redraw()
	forward_and_backward()
	pass
func teacher_value(inp:Array):
	if ope == OP_AND: return 1.0 if inp[0] != 0 && inp[1] != 0.0 else 0.0		# AND
	elif ope == OP_OR: return 1.0 if inp[0] != 0 || inp[1] != 0.0 else 0.0		# OR
	elif ope == OP_NAND: return 0.0 if inp[0] != 0 && inp[1] != 0.0 else 1.0	# NAND
	elif ope == OP_GT: return 1.0 if inp[0] > inp[1] else 0.0					# x1 > x2
	elif ope == OP_XOR: return 1.0 if inp[0] != inp[1] else 0.0					# XOR
	return 0.0
func teacher_value_ex(inp:Array):
	var t = teacher_value(inp)
	if actv_func != AF_SIGMOID && t == 0.0: t = -1.0
	#if !false_0 && t == 0.0: t = -1.0
	return t
func forward_and_backward():
	grad_11 = [0.0, 0.0, 0.0]
	grad_12 = [0.0, 0.0, 0.0]
	grad_2 = [0.0, 0.0, 0.0]
	var vec_inp2 = []
	var vec_tv = []
	var sumLoss = 0.0
	var n_data = 0		# ミニバッチデータ数カウンタ
	for i in range(boolean_pos.size()):		# ミニバッチの各データについて
		n_data += 1
		var t = teacher_value_ex(boolean_pos[i])	# 教師値
		vec_tv.push_back(t)
		#var inp = boolean_pos[i]
		#var inp = boolean_pos[i] if actv_func == AF_SIGMOID else boolean_pos_tanh[i]
		var inp = boolean_pos[i] if false_0 else boolean_pos_tanh[i]
		neuron_11.forward(inp)
		neuron_12.forward(inp)
		var inp2 = [neuron_11.y, neuron_12.y]		# 第２層入力
		vec_inp2.push_back(inp2)
		neuron_2.forward(inp2)
		var y = neuron_2.y
		if actv_func == AF_RELU:
			y = 1.0 if y > 0.0 else -1.0
		var d = y - t
		sumLoss += d * d / 2.0
		#
		neuron_2.backward(inp2, d)
		for k in range(grad_2.size()):
			grad_2[k] += neuron_2.upgrad[k]
		neuron_11.backward(inp, neuron_2.upgrad[0])
		neuron_12.backward(inp, neuron_2.upgrad[1])
		for k in range(grad_11.size()):
			grad_11[k] += neuron_11.upgrad[k]
			grad_12[k] += neuron_12.upgrad[k]
	print(vec_inp2)
	$GraphRect2.vec_tv = vec_tv
	$GraphRect2.vec_input = vec_inp2
	$GraphRect2.queue_redraw()
	var loss = sumLoss / n_data
	$LossLabel.text = "Loss = %.3f" % loss
	$Grad11Label.text = "∂L/∂[b, w1, w2] =\n  [%.2f, %.2f, %.2f]" % grad_11
	$Grad12Label.text = "∂L/∂[b, w1, w2] =\n  [%.2f, %.2f, %.2f]" % grad_12
	$Grad2Label.text = "∂L/∂[b, w1, w2] =\n  [%.2f, %.2f, %.2f]" % grad_2

func do_train():
	n_iteration += 1
	for i in range(neuron_2.vec_weight.size()):
		neuron_11.vec_weight[i] -= grad_11[i] * ALPHA
		neuron_12.vec_weight[i] -= grad_12[i] * ALPHA
		neuron_2.vec_weight[i] -= grad_2[i] * ALPHA
	update_view()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $TrainButton.button_pressed:
		do_train()
	pass


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://top_scene.tscn")
	pass # Replace with function body.


func _on_reset_button_pressed():
	n_iteration = 0
	neuron_11.init_weight(norm)
	neuron_12.init_weight(norm)
	neuron_2.init_weight(norm)
	vec_weight11_init = neuron_11.vec_weight.duplicate()
	vec_weight12_init = neuron_12.vec_weight.duplicate()
	vec_weight2_init = neuron_2.vec_weight.duplicate()
	update_view()
	pass # Replace with function body.


func _on_rewind_button_pressed():
	n_iteration = 0
	neuron_11.vec_weight = vec_weight11_init.duplicate()
	neuron_12.vec_weight = vec_weight12_init.duplicate()
	neuron_2.vec_weight = vec_weight2_init.duplicate()
	update_view()
	pass # Replace with function body.


func _on_train_button_pressed():
	pass # Replace with function body.


func _on_ope_button_item_selected(index):
	ope = index
	$GraphRect1.ope = ope
	#$GraphRect1.queue_redraw()
	forward_and_backward()
	update_view()
	pass # Replace with function body.


func _on_actv_func_button_item_selected(index):
	actv_func = index
	neuron_11.actv_func = actv_func
	neuron_12.actv_func = actv_func
	neuron_2.actv_func = actv_func
	$GraphRect1.actv_func = actv_func
	#$GraphRect1.queue_redraw()
	forward_and_backward()
	update_view()
	pass # Replace with function body.
func _on_false_val_button_item_selected(index):
	false_0 = index == 0
	$GraphRect1.false_0 = false_0
	forward_and_backward()
	update_view()
	pass # Replace with function body.
