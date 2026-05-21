extends CanvasLayer

# 抓取畫面上的 UI 節點
@onready var player_hp_bar = $PlayerHealthBar
@onready var boss_hp_bar = $BossHealthBar
@onready var result_panel = $ResultPanel
@onready var result_label = $ResultPanel/VBoxContainer/ResultLabel

@onready var resume_button = $ResultPanel/VBoxContainer/ResumeButton
@onready var restart_button = $ResultPanel/VBoxContainer/RestartButton
@onready var exit_button = $ResultPanel/VBoxContainer/ExitButton

var is_game_ended: bool = false

func _ready():
	# 遊戲剛開始時，隱藏結算畫面
	result_panel.hide() 
	result_label.text = ""
	is_game_ended = false
	
func _input(event):
	# "ui_cancel" 是 Godot 預設的 ESC 鍵
	if event.is_action_pressed("ui_cancel"):
		# 如果遊戲已經判定結束（玩家死或 Boss 死），按 ESC 直接無視
		if is_game_ended:
			return
			
		# 如果沒結束，就正常切換暫停狀態
		if get_tree().paused:
			resume_game()
		else:
			show_result("Paused", true) # true 代表這只是暫停選單

func update_player_hp(current: int, max_hp: int):
	player_hp_bar.max_value = max_hp
	player_hp_bar.value = current

func update_boss_hp(current: int, max_hp: int):
	boss_hp_bar.max_value = max_hp
	boss_hp_bar.value = current

# 呼叫這個函式來顯示結算畫面
func show_result(message: String, is_pause_menu: bool):
	result_panel.show()
	result_label.text = message
	get_tree().paused = true 
	
	if is_pause_menu:
		is_game_ended = false
		resume_button.show()
		restart_button.hide()
	else:
		is_game_ended = true
		resume_button.hide()
		restart_button.show()
		
func resume_game():
	result_panel.hide()
	get_tree().paused = false

func _on_restart_button_pressed() -> void:
	is_game_ended = false
	result_panel.hide()
	get_tree().paused = false 
	get_tree().reload_current_scene()

func _on_exit_butto_pressed() -> void:
	get_tree().quit()


func _on_resume_button_pressed() -> void:
	resume_game()
