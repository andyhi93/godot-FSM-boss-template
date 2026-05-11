extends CanvasLayer

# 開放給編輯器拖曳，用來綁定場景上的實體
@export var player: Core
@export var boss: Core

@onready var player_hp_bar = $PlayerHealthBar
@onready var boss_hp_bar = $BossHealthBar

func _process(_delta):
	# 更新玩家血條
	if player:
		player_hp_bar.max_value = player.max_hp
		player_hp_bar.value = player.current_hp
	else:
		player_hp_bar.value = 0 # 玩家死亡時血條歸零
		
	# 更新 Boss 血條
	if boss:
		boss_hp_bar.max_value = boss.max_hp
		boss_hp_bar.value = boss.current_hp
	else:
		boss_hp_bar.value = 0 # Boss 死亡時血條歸零
