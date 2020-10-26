extends Node

const REAGENT = preload("res://game/reagents/Reagent.tscn")


func random_type():
	var types = ReagentDB.get_types()
	randomize()
	types.shuffle()
	return types[1]


func create_object(type: String):
	var reagent_data = ReagentDB.get_from_name(type)
	var reagent = REAGENT.instance()
	
	#Duplicate material so shader parameters only affect this object
	var mat_override = reagent.get_node("Image").get_material().duplicate()
	reagent.get_node("Image").set_material(mat_override)
	
	reagent.type = type
	reagent.set_image(reagent_data.image)
	return reagent

func get_data(type: String):
	return ReagentDB.get_from_name(type)

func randomize_reagent(reagent):
	var type = random_type()
	var reagent_data = ReagentDB.get_from_name(type)
	reagent.type = type
	reagent.set_image(reagent_data.image)

func get_tooltip(type: String, upgraded:= false, unstable:= false, burned:= false):
	var data = get_data(type)
	var text
	if not upgraded:
		text = data.tooltip % data.effect.value
	else:
		text = data.tooltip % data.effect.upgraded_value + " Boost " + \
			   data.effect.upgraded_boost.type + " recipes by " + str(data.effect.upgraded_boost.value) + "."
	if unstable:
		text += " It's unstable."
	if burned:
		text += " It's on fire."
	
	var tooltip = {"title": data.name, "text": text, \
				   "title_image": data.image.get_path()}

	return tooltip

func get_substitution_tooltip(type):
	var data = get_data(type)
	if data.substitute.size() <= 0:
		return null
	
	var text = "This reagent can serve as substitute for "
	var plural
	if data.substitute.size() == 1:
		text += "this "
		plural = ""
	else:
		text += "these "
		plural = "s"
	text += "reagent"+plural+":"
	#For some reason \n just erases other images, so using gambiara to properly change lines
	text += "                      "
	for sub_reagent in data.substitute:
		var sub_data = get_data(sub_reagent)
		var path = sub_data.image.get_path()
		text += "[img=48x48]"+path+"[/img]  "
	var tooltip = {"title": "Substitutes", "text": text, \
				   "title_image": data.image.get_path()}
	
	return tooltip

#Given an array of reagents for a recipe, and and array of given reagentes, 
#checks if you can create the recipe with the given reagents, taking into
#consideration substitutions. If possible, will return an array of indexes
#for which reagents to use in the given_reagents array
func get_reagents_to_use(recipe_array: Array, given_reagents : Array):
	var reagent_arrays_to_check = [given_reagents]
	var reagent_arrays_viewed = []
	var correct_reagents
	while not reagent_arrays_to_check.empty():
		var cur_reagents_array = reagent_arrays_to_check.pop_front()
		correct_reagents = try_reagents(recipe_array, cur_reagents_array)
		if correct_reagents:
			return correct_reagents
		else:
			#Previous hand isn't valid, will add all possible 1-substitution available from it
			for i in cur_reagents_array.size():
				var reagent = cur_reagents_array[i]
				if reagent:
					var reagent_data = ReagentManager.get_data(reagent)
					for sub_reagent in reagent_data.substitute:
						var new_array = cur_reagents_array.duplicate(true)
						new_array[i] = sub_reagent
						if reagent_arrays_viewed.find(new_array) == -1:
							reagent_arrays_to_check.append(new_array)
							reagent_arrays_viewed.append(new_array)
	return false

#Checks if the given hand reagents contains all reagents needed for reagent array
func try_reagents(reagent_array, hand_reagents_array):
	var comparing_reagents = reagent_array.duplicate() 
	var correct_reagent_displays := []
	var i = 0
	while not comparing_reagents.empty() and i < hand_reagents_array.size():
		var reagent = hand_reagents_array[i]
		for other in comparing_reagents:
			if reagent == other:
				correct_reagent_displays.append(i)
				comparing_reagents.erase(other)
				break
		i += 1
	if comparing_reagents.empty():
		return correct_reagent_displays
	else:
		return null
