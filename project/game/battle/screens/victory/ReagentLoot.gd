extends HBoxContainer

signal reagent_looted
signal reagent_sold

onready var get_button = $GetButton
onready var sell_button = $SellButton
onready var sell_label = $SellButton/Label
onready var texture_rect = $TextureRect

const TEXT = "Transmute (%d gold)"

var reagent : String
var upgraded := false
var gold_value : int
var tooltip_enabled := false


func _ready():
	pass


func set_reagent(reagent_name: String):
	reagent = reagent_name
	gold_value = ReagentDB.get_from_name(reagent).gold_value
	texture_rect.texture = ReagentDB.DB[reagent].image
	sell_label.text = TEXT % gold_value


func get_tooltips():
	var tooltips = []
	if reagent:
		var data = ReagentManager.get_data(reagent)
		
		var text
		if not upgraded:
			text = data.tooltip % data.effect.value
		else:
			text = data.tooltip % data.effect.upgraded_value + " Boost " + \
				   data.effect.upgraded_boost.type + " recipes by " + str(data.effect.upgraded_boost.value) + "."
			
		var tooltip = {"title": data.name, "text": text,
				"title_image": data.image.get_path()}
		tooltips.append(tooltip)
	
	return tooltips


func disable_tooltip():
	tooltip_enabled = false
	TooltipLayer.clean_tooltips()


func disable_buttons():
	get_button.disabled = true
	sell_button.disabled = true


func enable_buttons():
	get_button.disabled = false
	sell_button.disabled = false


func _on_GetButton_pressed():
	get_button.disabled = true
	sell_button.disabled = true
	if tooltip_enabled:
		disable_tooltip()
	emit_signal("reagent_looted", self)


func _on_SellButton_pressed():
	sell_button.disabled = true
	if tooltip_enabled:
		disable_tooltip()
	emit_signal("reagent_sold", self)


func _on_Button_mouse_entered():
	AudioManager.play_sfx("hover_button")


func _on_Button_button_down():
	AudioManager.play_sfx("click")


func _on_TooltipCollision_disable_tooltip():
	disable_tooltip()


func _on_TooltipCollision_enable_tooltip():
	var play_sfx = true
	tooltip_enabled = true
	for tooltip in get_tooltips():
		TooltipLayer.add_tooltip($TooltipPosition.global_position, tooltip.title,
				tooltip.text, tooltip.title_image, play_sfx)
		play_sfx = false
