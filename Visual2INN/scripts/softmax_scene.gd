extends Node2D


enum {
	AF_NONE = -1,
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
		else: y = a		# 恒等関数
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
		else: dyda = 1.0		# 恒等関数
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
class Softmax:
	func _init(ninp):
		n_input = ninp
	func forward(inp: Array):
		vec_output.resize(n_input)
		var mxv = inp.max()
		var sum = 0.0
		for i in range(n_input):
			var e = exp(inp[i] - mxv)
			sum += e
			vec_output[i] = e
		for i in range(n_input):
			vec_output[i] /= sum
	var n_input				# 入力次元数
	var vec_output = []
#
const N_MINBATCH_DATA = 10			# ミニバッチデータ数

var n_iteration = 0
#var neuron = [0, 0]
var neuron_1
var neuron_2
var softmax
var norm = 0.1				# 重み初期化時標準偏差
var vec_inp = []			# 入力データ*10セット
var vec_inp_tv = []			# 各入力データに対する教師値 true/false
var grad_1
var grad_2

# Called when the node enters the scene tree for the first time.
func _ready():
	neuron_1 = Neuron.new(2, AF_NONE, norm)
	neuron_2 = Neuron.new(2, AF_NONE, norm)
	softmax = Softmax.new(2)
	vec_inp.resize(N_MINBATCH_DATA)
	vec_inp_tv.resize(N_MINBATCH_DATA)
	$GraphRect.maxv = 3.0
	init_inp()
	update_view()
	pass # Replace with function body.

func init_inp():
	for i in range(N_MINBATCH_DATA):
		vec_inp[i] = [randfn(0.0, 1.0), randfn(0.0, 1.0)]
		#if tchr_func == TF_PP:
		#	vec_inp_tv[i] = vec_inp[i][0] > 0 && vec_inp[i][1] > 0
		#elif tchr_func == TF_MP:
		#	vec_inp_tv[i] = vec_inp[i][0] < 0 && vec_inp[i][1] > 0
		#elif tchr_func == TF_MM:
		#	vec_inp_tv[i] = vec_inp[i][0] < 0 && vec_inp[i][1] < 0
		#elif tchr_func == TF_PM:
		#	vec_inp_tv[i] = vec_inp[i][0] > 0 && vec_inp[i][1] < 0
		vec_inp_tv[i] = vec_inp[i][0] + vec_inp[i][1] > 0.5
	$GraphRect.vec_input = vec_inp
	$GraphRect.vec_tv = vec_inp_tv
	$GraphRect.queue_redraw()
func update_view():
	$ItrLabel.text = "Iteration: %d" % n_iteration
	$WeightLabel_1.text = "[b, w1, w2] = [%.2f, %.2f, %.2f]" % neuron_1.vec_weight
	$WeightLabel_2.text = "[b, w1, w2] = [%.2f, %.2f, %.2f]" % neuron_2.vec_weight
	$GraphRect.vv_weight = [neuron_1.vec_weight, neuron_2.vec_weight]
	$GraphRect.queue_redraw()
	forward_and_backward()
func forward_and_backward():
	grad_1 = [0.0, 0.0, 0.0]
	grad_2 = [0.0, 0.0, 0.0]
	var sumLoss = 0.0
	var n_data = 0		# ミニバッチデータ数カウンタ
	for i in range(vec_inp.size()):		# ミニバッチの各データについて
		n_data += 1
		var t1 = 1.0 if vec_inp_tv[i] else 0.0
		var t2 = 1.0 if !vec_inp_tv[i] else 0.0	# 教師値
		var inp = vec_inp[i]
		neuron_1.forward(inp)
		neuron_2.forward(inp)
		softmax.forward([neuron_1.y, neuron_2.y])
		sumLoss += t1 * log(softmax.vec_output[0])
		sumLoss += t2 * log(softmax.vec_output[1])
		#
		neuron_1.backward(inp, neuron_1.y - t1)
		for k in range(grad_1.size()):
			grad_1[k] += neuron_1.upgrad[k]
		neuron_2.backward(inp, neuron_2.y - t2)
		for k in range(grad_2.size()):
			grad_2[k] += neuron_2.upgrad[k]
	var loss = -sumLoss
	$LossLabel.text = "Loss = %.3f" % loss
	$GradLabel_1.text = "∂L/∂[b, w1, w2] = [%.2f, %.2f, %.2f]" % grad_1
	$GradLabel_2.text = "∂L/∂[b, w1, w2] = [%.2f, %.2f, %.2f]" % grad_2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://top_scene.tscn")
	pass # Replace with function body.
