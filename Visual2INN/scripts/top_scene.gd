extends Node2D

const SCREEN_WD = 500
const N_PAGE = 3			# ページ数

#var page = 0				# ページインデックス [0, N_PAGE)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Panels.position = Vector2(-SCREEN_WD*g.page, 0)
	disable_befor_next_button()
	pass # Replace with function body.

func disable_befor_next_button():
	$BeforeButton.disabled = g.page == 0
	$NextButton.disabled = g.page == N_PAGE - 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_single_nueron_button_pressed():
	print("single_nueron_button_pressed()")
	get_tree().change_scene_to_file("res://single_neuron_scene.tscn")
	pass # Replace with function body.


func _on_double_layer_button_pressed():
	get_tree().change_scene_to_file("res://double_layer_scene.tscn")
	pass # Replace with function body.


func _on_before_button_pressed():
	g.page -= 1
	disable_befor_next_button()
	var tw = get_tree().create_tween()
	tw.tween_property($Panels, "position", Vector2(-SCREEN_WD*g.page, 0), 0.5)
	#$Panels.position = Vector2(0, 0)
	pass # Replace with function body.


func _on_next_button_pressed():
	g.page += 1
	disable_befor_next_button()
	var tw = get_tree().create_tween()
	tw.tween_property($Panels, "position", Vector2(-SCREEN_WD*g.page, 0), 0.5)
	#$Panels.position = Vector2(SCREEN_WD, 0)
	pass # Replace with function body.


func _on_double_layer_real_button_pressed():
	print("double_layer_real_button_pressed()")
	get_tree().change_scene_to_file("res://double_layer_real.tscn")
	pass # Replace with function body.


func _on_softmax_button_pressed():
	get_tree().change_scene_to_file("res://softmax_scene.tscn")
	pass # Replace with function body.
