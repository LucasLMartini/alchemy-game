extends Node2D

const ENEMY_FONT = preload("res://game/character/EnemyHealthFont.tres")
const ENEMY_SIZE = {
	"small": 256,
	"medium": 511,
	"big": 963,
}
const PROGRESS_TEXTURE = {
	"small": preload("res://assets/images/ui/Small Enemy Lifebar.png"),
	"medium": preload("res://assets/images/ui/Medium Enemy Lifebar.png"),
	"big": preload("res://assets/images/ui/Huge Enemy Lifebar.png"),
}
const BG_TEXTURE = {
	"small": preload("res://assets/images/ui/Small Enemy Lifebar Holder.png"),
	"medium": preload("res://assets/images/ui/Medium enemy lifebar holder.png"),
	"big": preload("res://assets/images/ui/Huge Enemy Lifebar Holder.png"),
}

onready var label = $Label
onready var shield = $Shield
onready var shield_label = $Shield/Label

func get_width():
	return $Bar.rect_size.x

func get_height():
	return $Bar.rect_size.y

func _ready():
	shield.hide()

func update_shield(value):
	if value > 0:
		shield.show()
		shield_label.text = str(value)
	else:
		shield.hide()

func set_life(hp, max_hp):
	$Bar.max_value = max_hp
	$Bar.value = hp
	$Label.text = str(hp) + "/" + str(max_hp)

func update_life(new_hp):
	$Bar.value = new_hp
	label.text = str(new_hp) + "/" + str($Bar.max_value)

func get_percent():
	return $Bar.value / float($Bar.max_value)

func set_enemy_type(enemy_size):
	var prog_tex
	var bg_tex
	if PROGRESS_TEXTURE.has(enemy_size):
		prog_tex = PROGRESS_TEXTURE[enemy_size]
		bg_tex = BG_TEXTURE[enemy_size]
	else:
		push_error("Not a valid enemy size: " + str(enemy_size))
		assert(false)
	
	$Bar.texture_progress = prog_tex
	$Bar.texture_under = bg_tex
	$Bar.rect_size.x = ENEMY_SIZE[enemy_size]
	$Bar.rect_size.y = 20
	$Label.rect_size = $Bar.rect_size
	$Label.add_font_override("font", ENEMY_FONT)
	$Shield.rect_scale = Vector2(.5,.5)
	$Shield.rect_position.x += 20
	$Shield.rect_position.y += 5
