extends SceneTree

func _init():
	print("\n==============================================")
	print("       Student Works Checkpoint Test          ")
	print("==============================================\n")
	
	var passed = true
	
	# 1. Check Autoloads in ProjectSettings
	var has_screenshake = ProjectSettings.has_setting("autoload/ScreenShake")
	var has_hitstop = ProjectSettings.has_setting("autoload/HitStop")
	
	print("Checking Autoloads:")
	if has_screenshake and has_hitstop:
		print("  [OK] ScreenShake and HitStop Autoloads configured.")
	else:
		print("  [FAIL] Missing ScreenShake or HitStop in Autoloads.")
		passed = false
		
	# 2. Check source code for implemented 'Juice' functions
	print("\nChecking Game Feel Implementation:")
	var core_script: Script = load("res://Scripts/FSM/Core.gd")
	var boss_script: Script = load("res://Scripts/Boss/boss.gd")
	var player_script: Script = load("res://Scripts/Player.gd")
	
	var scripts_to_check = [core_script, boss_script, player_script]
	
	var found_shake = false
	var found_stop = false
	var found_flash = false
	
	for script in scripts_to_check:
		if script == null: continue
		var src = script.source_code
		
		# Allow different variations of calling these functions
		if "ScreenShake.shake" in src: found_shake = true
		if "HitStop.stop" in src: found_stop = true
		if "flash(" in src: found_flash = true
			
	if found_shake:
		print("  [OK] ScreenShake.shake is called.")
	else:
		print("  [FAIL] ScreenShake.shake is not called in Core, Boss, or Player scripts.")
		passed = false
		
	if found_stop:
		print("  [OK] HitStop.stop is called.")
	else:
		print("  [FAIL] HitStop.stop is not called in Core, Boss, or Player scripts.")
		passed = false
		
	if found_flash:
		print("  [OK] flash() is called.")
	else:
		print("  [FAIL] flash() is not called in Core, Boss, or Player scripts.")
		passed = false
		
	print("\n==============================================")
	if passed:
		print("  ✅ CHECKPOINT PASSED! Great job!")
	else:
		print("  ❌ CHECKPOINT FAILED. Keep trying!")
	print("==============================================\n")
	
	# Exit with appropriate code
	if passed:
		quit(0)
	else:
		quit(1)
