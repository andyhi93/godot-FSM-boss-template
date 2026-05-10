# res://Scripts/FSM/StateMachine.gd
extends Node
class_name StateMachine

# 在屬性面板(Inspector)開放一個欄位，讓你指定一開始是哪個狀態
@export var initial_state: State 

var current_state: State
var states: Dictionary = {}

func _ready():
	# 讓總管稍微等一下，確保 Boss 跟節點已經完全載入
	await owner.ready 
	
	# 抓取底下所有的子節點 (各種狀態)
	for child in get_children():
		if child is State:
			# 將狀態存入字典，並把 Boss 的控制權交給該狀態
			states[child.name.to_lower()] = child
			child.boss = owner # owner 就是這個場景的根節點 (Boss CharacterBody2D)
			# 綁定切換狀態的訊號
			child.transitioned.connect(on_child_transition)
	
	# 啟動初始狀態
	if initial_state:
		initial_state.enter()
		current_state = initial_state

# 總管小姐：把每一幀的更新工作，轉交給「當前正在工作的狀態」
func _process(delta):
	if current_state:
		current_state.update(delta)

# 總管小姐：把物理移動的工作，轉交給「當前正在工作的狀態」
func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

# 當有子節點(狀態)大喊「我要切換狀態！」時，總管會執行這個函式
func on_child_transition(state, new_state_name):
	# 防呆：如果大喊的不是現在正在執行的狀態，就忽略它
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		print("找不到狀態：", new_state_name)
		return
		
	# 舊的狀態下班，新的狀態上班
	if current_state:
		current_state.exit()
		
	new_state.enter()
	current_state = new_state
	# print("切換到狀態：", new_state_name) # 除錯用，確認狀態有切換
