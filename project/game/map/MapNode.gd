extends Control
class_name MapNode

signal pressed

onready var button = $Button

enum {EMPTY, ENEMY, ELITE, BOSS, SHOP, REST, SMITH, EVENT, LABORATORY, TREASURE}

const ALPHA_SPEED = 6
const SCALE_SPEED = 3
const TARGET_SCALE = 1.2

const IMAGES = [preload("res://assets/images/map/elementCircle.png"),
		preload("res://assets/images/map/enemy.png"),
		preload("res://assets/images/map/elite.png"),
		preload("res://assets/images/map/boss-open2.png"),
		preload("res://assets/images/map/shop.png"),
		preload("res://assets/images/map/descanso.png"),
		preload("res://assets/images/map/smith.png"),
		preload("res://assets/images/map/event.png"),
		preload("res://assets/images/map/laboratory.png"),
		preload("res://assets/images/map/treasure.png")]
const LEGEND = ["", "Enemy", "Elite", "Boss",
		"Shop", "Rest", "Reagent Smith", "Event", "Laboratory", "Treasure"]

var encounter : Encounter
var is_leaf := true
var map_tree_children := []
var map_lines := []
var paths_revealed := false
var type := EMPTY
var mouse_over = false
var tooltips_enabled := false
var block_tooltips := false
var camera = null

func _process(dt):
	if mouse_over and type != EMPTY:
		$Button.rect_scale.x = min($Button.rect_scale.x + SCALE_SPEED*dt, TARGET_SCALE)
		$Button.rect_scale.y = min($Button.rect_scale.y + SCALE_SPEED*dt, TARGET_SCALE)
	else:
		$Button.rect_scale.x = max($Button.rect_scale.x - SCALE_SPEED*dt, 1)
		$Button.rect_scale.y = max($Button.rect_scale.y - SCALE_SPEED*dt, 1)


func disable():
	disable_tooltips()
	block_tooltips = true


func enable():
	block_tooltips = false


func get_alpha():
	return modulate.a


func fade_in():
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1),
								.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()


func set_camera(cam):
	camera = cam


func set_type(new_type:int):
	if new_type == type:
		return
	
	type = new_type
	button.texture_normal = IMAGES[type]
	button.disabled = type == EMPTY
	
	if type == ENEMY:
		encounter = EncounterManager.get_random_encounter()
	elif type == ELITE:
		encounter = EncounterManager.get_random_elite_encounter()
	elif type == BOSS:
		encounter = EncounterManager.get_random_boss_encounter()


func should_autoreveal() -> bool:
	return type in [EMPTY, SHOP, REST, SMITH, LABORATORY, TREASURE]


func disable_tooltips():
	if tooltips_enabled:
		tooltips_enabled = false
		TooltipLayer.clean_tooltips()


func get_node_tooltip():
	var tooltip = {}
	tooltip = {"title": LEGEND[type], "text": "", \
			   "title_image": IMAGES[type]}
	return tooltip


func _on_Button_pressed():
	mouse_over = false
	emit_signal("pressed")


func _on_Button_mouse_entered():
	mouse_over = true


func _on_Button_mouse_exited():
	mouse_over = false


func _on_TooltipCollision_enable_tooltip():
	if block_tooltips or type == EMPTY:
		return
	
	tooltips_enabled = true
	var tooltip = get_node_tooltip()
	TooltipLayer.add_tooltip($TooltipPosition.global_position - camera.get_offset(), \
							tooltip.title, tooltip.text, tooltip.title_image, true)


func _on_TooltipCollision_disable_tooltip():
	disable_tooltips()
