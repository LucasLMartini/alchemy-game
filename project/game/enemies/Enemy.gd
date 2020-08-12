extends Character
class_name Enemy

signal acted
signal action
signal selected
signal action_resolved
signal animation_finished
signal resolved

onready var animation = $Sprite/AnimationPlayer
onready var button = $Sprite/Button
onready var health_bar = $HealthBar
onready var sprite = $Sprite
onready var tween = $Tween

const INTENT = preload("res://game/enemies/Intent.tscn")

const STATUS_BAR_MARGIN = 40
const HEALTH_BAR_MARGIN = 10
const INTENT_MARGIN = 10
const INTENT_W = 50
const INTENT_H = 60

# Highlight constants
const HL_SPEED = 100
const HL_MAX_THICKNESS = 15
const HL_MIN_THICKNESS = 2
const HL_COLOR = Color(0.937255, 1, 0.737255, 0.784314)

var logic
var data
var cur_actions
var just_spawned := false
var tooltip_position := Vector2()
var tooltips_enabled := false
var block_tooltips := false
var _playback_speed := 1.0


func _ready():
	set_button_disabled(true)
	
	#Setup idle animation
	animation.play("idle")
	randomize()
	animation.seek(rand_range(0.0, 2.0))
	randomize()
	_playback_speed = rand_range(1.0, 1.3)
	animation.playback_speed = _playback_speed
	
	#Setup spawn animation
	scale = Vector2(0,0)
	tween.interpolate_property(self, "scale", Vector2(0,0), Vector2(1,1), .2,
			Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.interpolate_property(sprite, "modulate", Color.black, Color.white,
			.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()


func heal(amount : int):
	if amount > 0:
		.heal(amount)
		
		#Animation
		AnimationManager.play("heal", get_center_position())
		
		health_bar.update_visuals(hp, shield)
		yield(health_bar, "animation_completed")
		
	emit_signal("resolved")



func die():
	#Audio
	AudioManager.play_enemy_dies_sfx(data.sfx)
	
	disable_tooltips()
	
	#Death animation
	tween.interpolate_method(self, "set_grayscale", 0, 1, .2, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), .5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	
	yield(tween, "tween_all_completed")
	emit_signal("died", self)


func set_grayscale(value: float):
	$Sprite.material.set_shader_param("grayscale", value)


func drain(source: Character, amount: int):
	#Check for weak status
	amount = int(ceil(2*amount/3.0)) if source.get_status("weak") else amount
	
	var unblocked_dmg = .take_damage(source, amount, "drain")
	
	if unblocked_dmg > 0:
		source.heal(unblocked_dmg)
	
	if hp > 0 and unblocked_dmg > 0:
		AudioManager.play_enemy_hit_sfx(data.sfx)
	
	#TODO: Change for a "drain" animation （￣︶￣）↗　
	AnimationManager.play("regular_attack", get_center_position())
	
	update_status_bar()
	
	var func_state = health_bar.update_visuals(hp, shield)
	if func_state and func_state.is_valid():
		if hp > 0:
			yield(health_bar, "animation_completed")
		else:
			yield(self, "died")
	
	emit_signal("resolved")


func take_damage(source: Character, damage: int, type: String, retaliate := true):
	#Check for weak status
	damage = int(ceil(2*damage/3.0)) if source.get_status("weak") else damage
	
	var unblocked_dmg = .take_damage(source, damage, type, retaliate)
	if hp > 0 and unblocked_dmg > 0:
		AudioManager.play_enemy_hit_sfx(data.sfx)

	#Animations
	if type == "regular":
		AnimationManager.play("regular_attack", get_center_position())
	elif type == "piercing":
		AnimationManager.play("piercing_attack", get_center_position())
	elif type == "crushing":
		AnimationManager.play("crushing_attack", get_center_position())
	elif type == "poison":
		AnimationManager.play("poison", get_center_position())
	
	update_status_bar()
	
	var func_state = health_bar.update_visuals(hp, shield)
	if func_state and func_state.is_valid():
		if hp > 0:
			yield(health_bar, "animation_completed")
		else:
			yield(self, "died")
	
	emit_signal("resolved")


func gain_shield(value):
	if value > 0:
		.gain_shield(value)
		
		#Animation
		AnimationManager.play("shield", get_center_position())
		
		health_bar.update_visuals(hp, shield)
		yield(health_bar, "animation_completed")
	
	emit_signal("resolved")


func reduce_status(status: String, amount: int):
	.reduce_status(status, amount)
	update_status_bar()


func add_status(status: String, amount, positive: bool, extra_args:= {}):
	var has_weak = get_status("weak")
	var damage_mod = get_damage_modifiers()
	.add_status(status, amount, positive, extra_args)
	update_status_bar()
	if has_weak != get_status("weak") or damage_mod != get_damage_modifiers():
		update_intent()
	
	#Animations
	if positive:
		AnimationManager.play("buff", get_center_position())
	else:
		AnimationManager.play("debuff", get_center_position())


func remove_status(status: String):
	.remove_status(status)
	update_status_bar()


func new_turn():
	update_status("start_turn")
	health_bar.update_visuals(hp, shield)


func update_status(type: String):
	.update_status(type)
	update_status_bar()


func act():
	run_action()
	yield(self, "action_resolved")
	
	emit_signal("acted")
	
	if hp > 0:
		logic.update_state()
		update_action()
	


func update_action():
	var state = logic.get_current_state()

	cur_actions = []
	for action in data.actions[state]:
		var act
		if action.name == "damage":
			var value = get_random_value(action.value) if action.value is Array else action.value
			var amount = action.amount if action.has("amount") else 1
			act = ["damage", {"value": value, "type": action.type, "amount": amount}]
		elif action.name == "drain":
			var value = get_random_value(action.value) if action.value is Array else action.value
			var amount = action.amount if action.has("amount") else 1
			act = ["drain", {"value": value, "amount": amount}]
		elif action.name == "self_destruct":
			var value = get_random_value(action.value) if action.value is Array else action.value
			act = ["self_destruct", {"value": value}]
		elif action.name == "shield":
			var value = get_random_value(action.value) if action.value is Array else action.value
			act = ["shield", {"value": value}]
		elif action.name == "status":
			var value = get_random_value(action.value) if action.value is Array else action.value
			var extra_args = action.extra_args if action.has("extra_args") else {}
			act = ["status", {"status": action.status_name, "value": value, \
							  "target": action.target, "positive": action.positive, \
							  "extra_args": extra_args}]
		elif action.name == "spawn":
			act = ["spawn", {"enemy": action.enemy, "minion": action.has("minion")}]
		elif action.name == "add_reagent":
			act = ["add_reagent", {"type": action.type, "value": action.value}]
		elif action.name == "idle":
			var sfx = {"sfx": action.sfx} if action.has("sfx") else {}
			act = ["idle", sfx]
		else:
			push_error("Not a valid action:" + str(action.name))
			assert(false)
		cur_actions.append(act)
	
	update_intent()


func run_action():
	emit_signal("action", self, cur_actions)


#Returns a random value given an interval array [min, max]
func get_random_value(interval : Array):
	randomize()
	return randi()%(interval[1]-interval[0]+1) + interval[0]


func play_animation(name):
	animation.play(name)
	yield(animation, "animation_finished")
	emit_signal("animation_finished")
	animation.play("idle")
	randomize()
	animation.seek(rand_range(0.0, 2.0))
	animation.playback_speed = _playback_speed


func action_resolved():
	emit_signal("action_resolved")


func update_status_bar():
	$StatusBar.clean_removed_status(status_list)
	var status_type = status_list.keys();
	for type in status_type:
		var status = status_list[type]
		$StatusBar.set_status(type, status.amount, status.positive)


func get_center_position():
	return $Sprite.global_position


func setup(enemy_logic, new_texture, enemy_data):
	set_logic(enemy_logic)
	set_life(enemy_data)
	set_image(new_texture)
	data = enemy_data #Store enemy data


func set_logic(enemy_logic):
	logic = load("res://game/enemies/EnemyLogic.gd").new()
	
	for state in enemy_logic.states:
		logic.add_state(state)
	for link in enemy_logic.connections:
		logic.add_connection(link[0], link[1], link[2])
	
	#Get random first state
	randomize()
	enemy_logic.first_state.shuffle()
	logic.set_state(enemy_logic.first_state.front())


func set_life(enemy_data):
	$HealthBar.set_life(max_hp, max_hp)
	$HealthBar.set_enemy_type(enemy_data.size)


#Called when player dies
func disable():
	block_tooltips = true
	disable_tooltips()


func update_tooltip_position():
	var margin = 10
	$TooltipPosition.position = Vector2($Sprite.position.x + $Sprite.texture.get_width() + margin, \
							   			$Sprite.position.y - $Sprite.texture.get_height()/2 -\
										INTENT_MARGIN - INTENT_H)


func set_image(new_texture):
	var margin = 40
	var w = new_texture.get_width()
	var h = new_texture.get_height() - margin
	
	#Update texture
	$Sprite.texture = new_texture

	#Sprite Position
	$Sprite.position.x = 0
	$Sprite.position.y = 0

	#Update health bar position
	$HealthBar.position.x = -$HealthBar.get_width()*$HealthBar.scale.x/2
	$HealthBar.position.y = $Sprite.position.y + h + HEALTH_BAR_MARGIN - h/2
	
	#Update status bar position
	$StatusBar.rect_position.x = $HealthBar.position.x
	$StatusBar.rect_position.y = $HealthBar.position.y + STATUS_BAR_MARGIN
	$StatusBar.setup($HealthBar.get_width()*$HealthBar.scale.x)
	
	#Update intents position
	$Intents.position.y = $Sprite.position.y -INTENT_MARGIN - INTENT_H - h/2
	
	#Update tooltip collision
	var t_w = w
	var t_h = INTENT_H +  INTENT_MARGIN + h + \
			  HEALTH_BAR_MARGIN + $HealthBar.get_height()*$HealthBar.scale.y + \
			  STATUS_BAR_MARGIN + $StatusBar.get_height()
	$TooltipCollision.position = Vector2(0, $Intents.position.y + h/2 + 3*margin/2)
	$TooltipCollision.set_collision_shape(Vector2(t_w, t_h))
	
	# Button
	$Sprite/Button.rect_position = Vector2(-w/2, -h/2)


#Removes first intent (the one in the left)
func remove_intent():
	if $Intents.get_child_count() > 0:
		var intent = $Intents.get_child(0)
		intent.vanish()
		yield(intent, "vanished")
		$Intents.remove_child(intent)
		update_intents_position()


func clear_intents():
	for intent in $Intents.get_children():
		$Intents.remove_child(intent)


func add_intent(texture, value, multiplier):
	var intent = INTENT.instance()
	$Intents.add_child(intent)
	intent.setup(texture, value, multiplier)
	yield(intent, "set_up")
	update_intents_position()


func update_intents_position():
	var int_n = $Intents.get_child_count()
	var separation = 2
	var w = separation * (int_n - 1)
	for intent in $Intents.get_children():
		w += intent.get_width()
	var x = $Sprite.position.x - w/2
	for intent in $Intents.get_children():
		tween.interpolate_property(intent, "position", intent.position, Vector2(x, 0), .2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		x += intent.get_width() + separation
	tween.start()


func set_pos(target_pos):
	randomize()
	var speed = rand_range(2000, 2500)
	var dur = (position - target_pos).length()/speed
	tween.interpolate_property(self, "position", position, target_pos, dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

func update_intent():
	clear_intents()
	for action in cur_actions:
		var intent = IntentManager.create_intent_data(action)
		if intent.has("value"):
			var value = intent.value
			var name = action[0]
			if name == "damage" or name == "drain":
				value += get_damage_modifiers()
				value = int(ceil(2*value/3.0)) if get_status("weak") else value
			if intent.has("multiplier"):
				add_intent(intent.image, value, intent.multiplier)
			else:
				add_intent(intent.image, value, null)
		else:
			add_intent(intent.image, null, null)


func get_width():
	return sprite.texture.get_width()


func get_height():
	return sprite.texture.get_height()


func get_tooltips():
	var tooltips = []

	for action in cur_actions:
		tooltips.append(IntentManager.get_intent_tooltip(action, self))
	
	#Get status tooltips
	for tooltip in $StatusBar.get_status_tooltips():
		tooltips.append(tooltip)
	return tooltips


func set_button_disabled(disable: bool):
	button.visible = not disable
	button.disabled = disable
	
	var color := HL_COLOR
	color.a = 0 if disable else 1
	sprite.material.set_shader_param("highlight_color", color)


func disable_tooltips():
	if tooltips_enabled:
		tooltips_enabled = false
		TooltipLayer.clean_tooltips()


func _on_Button_pressed():
	tween.stop(sprite.material)
	sprite.material.set_shader_param("highlight_thickness", HL_MIN_THICKNESS)
	emit_signal("selected", self)


func _on_Button_mouse_entered():
	var duration = (-sprite.material.get_shader_param("highlight_thickness") +\
			HL_MAX_THICKNESS) / HL_SPEED
	tween.stop(sprite.material)
	tween.interpolate_property(sprite.material,
			"shader_param/highlight_thickness", null, HL_MAX_THICKNESS,
			duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()


func _on_Button_mouse_exited():
	var duration = (sprite.material.get_shader_param("highlight_thickness") -\
			HL_MIN_THICKNESS) / HL_SPEED
	tween.stop(sprite.material)
	tween.interpolate_property(sprite.material,
			"shader_param/highlight_thickness", null, HL_MIN_THICKNESS,
			duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()


func _on_TooltipCollision_enable_tooltip():
	if block_tooltips:
		return
	var play_sfx = true
	tooltips_enabled = true
	for tooltip in get_tooltips():
		update_tooltip_position()
		TooltipLayer.add_tooltip($TooltipPosition.global_position, tooltip.title, \
								 tooltip.text, tooltip.title_image, play_sfx)
		play_sfx = false


func _on_TooltipCollision_disable_tooltip():
	disable_tooltips()
