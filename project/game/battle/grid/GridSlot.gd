extends Slot

onready var reagent_hint = $MarginContainer/ReagentHint
onready var restrict_chain = $CanvasLayer/RestrictChain

const ALPHA_SPEED = 3

var reagent_hint_name = null

var restricted
var restrained

func _ready():
	type = "grid"

func _process(delta):
	if is_restrained():
		$RestrainedImage.modulate.a = min($RestrainedImage.modulate.a + ALPHA_SPEED*delta, 1)
	else:
		$RestrainedImage.modulate.a = max($RestrainedImage.modulate.a - ALPHA_SPEED*delta, 0)
		
	if is_restricted():
		$RestrictImage.modulate.a = min($RestrictImage.modulate.a + ALPHA_SPEED*delta, 1)
		restrict_chain.modulate.a = min(restrict_chain.modulate.a + ALPHA_SPEED*delta, 1)
		$CanvasLayer.offset = rect_global_position
	else:
		$RestrictImage.modulate.a = max($RestrictImage.modulate.a - ALPHA_SPEED*delta, 0)
		restrict_chain.modulate.a = max(restrict_chain.modulate.a - ALPHA_SPEED*delta, 0)
	
	if get_reagent():
		$FullImage.modulate.a = min($FullImage.modulate.a + 2*ALPHA_SPEED*delta, 1)
		$EmptyImage.modulate.a = max($EmptyImage.modulate.a - ALPHA_SPEED*delta, 0)
	else:
		$FullImage.modulate.a = max($FullImage.modulate.a - ALPHA_SPEED*delta, 0)
		$EmptyImage.modulate.a = min($EmptyImage.modulate.a + 2*ALPHA_SPEED*delta, 1)


func block_highlight_effect():
	var dur = .5
	$Tween.interpolate_property(restrict_chain, "modulate:r", Color.red.r, Color.white.r,
			dur, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.interpolate_property(restrict_chain, "modulate:g", Color.red.g, Color.white.g,
			dur, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.interpolate_property(restrict_chain, "modulate:b", Color.red.b, Color.white.b,
			dur, Tween.TRANS_SINE, Tween.EASE_IN)
			
	$Tween.interpolate_property($RestrainedImage, "modulate:r", Color.red.r, Color.white.r,
			dur, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.interpolate_property($RestrainedImage, "modulate:g", Color.red.g, Color.white.g,
			dur, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.interpolate_property($RestrainedImage, "modulate:b", Color.red.b, Color.white.b,
			dur, Tween.TRANS_SINE, Tween.EASE_IN)

	$Tween.start()


func get_width():
	return $FullImage.rect_size.x

func get_height():
	return $FullImage.rect_size.y

func set_hint(reagent_name):
	if not reagent_name:
		reagent_hint.texture = null
		reagent_hint_name = null
	else:
		reagent_hint.texture = ReagentDB.get_from_name(reagent_name).image
		reagent_hint_name = reagent_name

func get_hint():
	return reagent_hint_name


func hide_effects():
	restrict_chain.hide()

func show_effects():
	restrict_chain.show()


func is_restricted():
	return restricted

func restrict():
	AudioManager.play_sfx("restrict_slot")
	restricted = true
	randomize()
	restrict_chain.rect_rotation = rand_range(0, 360)

func unrestrict():
	restricted = false

func is_restrained():
	return restrained

func restrain():
	AudioManager.play_sfx("restrain_slot")
	restrained = true

func unrestrain():
	AudioManager.play_sfx("unrestrain_slot")
	restrained = false
