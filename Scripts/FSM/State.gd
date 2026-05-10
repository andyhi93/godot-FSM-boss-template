# res://Scripts/FSM/State.gd
extends Node
class_name State # 註冊為全局類別，這樣其他腳本就能繼承它

# 定義一個訊號，當狀態想要切換時呼叫
# 參數：發送訊號的狀態本身, 想切換過去的狀態節點名稱 (String)
signal transitioned(state, new_state_name)

# 讓狀態可以輕易取得 Boss 本身 (由 StateMachine 灌入)
var boss: CharacterBody2D

# --- 以下三個是留給新手填寫的「空抽屜」 ---

# 當剛進入這個狀態時，會執行一次 (例如：播放動畫、重置計時器)
func enter():
	pass

# 每一幀都會執行 (處理邏輯、數學、按鍵輸入)
func update(_delta: float):
	pass

# 每一物理幀都會執行 (處理移動、碰撞)
func physics_update(_delta: float):
	pass

# 當要離開這個狀態時，會執行一次 (例如：清除特效)
func exit():
	pass
