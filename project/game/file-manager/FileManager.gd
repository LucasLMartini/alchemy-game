extends Node

var dungeon = false
var continue_game = false


func save_and_quit():
	save_game()
	get_tree().quit()


func save_game():
	save_profile()
	if current_run_exists():
		save_run()


func load_game():
	load_profile()


func load_profile():
	var profile_file = File.new()
	if not profile_file.file_exists("user://profile.save"):
		print("Profile file not found. Starting a new profile file.")
		save_profile()
		
	var err = profile_file.open("user://profile.save", File.READ)
	if err != OK:
		push_error("Error trying to open profile whilst loading:" + str(err))
		
	while profile_file.get_position() < profile_file.get_len():
		# Get the saved dictionary from the next line in the save file
		var data = parse_json(profile_file.get_line())
		Profile.set_save_data(data)
		
	profile_file.close()
	save_profile()

func save_profile():
	var profile_file = File.new()
	var err = profile_file.open("user://profile.save", File.WRITE)
	if err != OK:
		push_error("Error trying to open profile whilst saving:" + str(err))
	var profile_data = Profile.get_save_data()
	profile_file.store_line(to_json(profile_data))
	profile_file.close()


func current_run_exists():
	return not not dungeon


func set_current_run(dungeon_ref):
	dungeon = dungeon_ref


func run_file_exists():
	var run_file = File.new()
	return run_file.file_exists("user://run.save")


func delete_run_file():
	create_run_backup()
	var run_file = File.new()
	if run_file.file_exists("user://run.save"):
		var dir = Directory.new()
		dir.remove("user://run.save")
	else:
		#Run file not found. Aborting deletion.
		return


func save_run():
	assert(dungeon, "Dungeon reference invalid.")
	create_run_backup()
	var run_file = File.new()
	var err = run_file.open("user://run.save", File.WRITE)
	if err != OK:
		push_error("Error trying to open run file whilst saving:" + str(err))
	var run_data = dungeon.get_save_data()
	run_file.store_line(to_json(run_data))
	run_file.close()


func create_run_backup():
	var run_file = File.new()
	if not run_file.file_exists("user://run.save"):
		return
	
	var err = run_file.open("user://run.save", File.READ)
	if err != OK:
		push_error("Error trying to open run file whilst creating backup:" + str(err))
	
	var backup_file = File.new()
	err = backup_file.open("user://run.backup", File.WRITE)
	if err != OK:
		push_error("Error trying to open backup run file:" + str(err))
	
	while run_file.get_position() < run_file.get_len():
		var data = parse_json(run_file.get_line())
		backup_file.store_line(to_json(data))
	run_file.close()
	backup_file.close()

func load_run():
	var run_file = File.new()
	if not run_file.file_exists("user://run.save"):
		push_error("Run file not found. Aborting load.")
		return
	var err = run_file.open("user://run.save", File.READ)
	if err != OK:
		push_error("Error trying to run file whilst loading:" + str(err))
	assert(dungeon, "Dungeon reference invalid.")
	while run_file.get_position() < run_file.get_len():
		var data = parse_json(run_file.get_line())
		dungeon.set_save_data(data)
		
	run_file.close()
	
	
	

