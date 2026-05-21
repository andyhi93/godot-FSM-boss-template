extends State  

# 💡 物理與控制提示：
# - 控制速度：修改 `core.velocity` (例如：Vector2.ZERO 是靜止)
# - 計時器：變數 `time` 會自動記錄進入這個狀態後經過了幾秒
# - 任務完成：把 `is_complete` 設為 true，大腦就會接手切換下一招

#func do_update(_delta: float):
	# TODO 1：讓 Boss 停在原地不准動
	
	
	# TODO 2：如果發呆時間 (time) 超過 2.0 秒，標記狀態為完成 (is_complete)
