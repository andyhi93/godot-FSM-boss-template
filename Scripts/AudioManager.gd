extends Node

# 在 Inspector 中動態新增音效與音樂的清單
@export var sfx_list: Array[AudioEntry] = []
@export var music_list: Array[AudioEntry] = []

@export_group("Global Volume Settings")
@export_range(0, 1) var master_volume: float = 1.0:
	set(value):
		master_volume = value
		if is_node_ready(): set_master_volume(value)

@export_range(0, 1) var music_volume: float = 1.0:
	set(value):
		music_volume = value
		if is_node_ready(): set_music_volume(value)

@export_range(0, 1) var sfx_volume: float = 1.0:
	set(value):
		sfx_volume = value
		if is_node_ready(): set_sfx_volume(value)

# 用來快速查詢的字典 (Key: 名稱, Value: AudioEntry)
var sfx_dict: Dictionary = {}
var music_dict: Dictionary = {}
var sfx_pitch_counters: Dictionary = {} # 追蹤每個音效目前播到第幾個音高

# 內建的播放器
@onready var music_player = AudioStreamPlayer.new()

func _ready():
	# 設定音樂播放器的 Bus (記得在 Godot 下方的 Audio 分頁建立名為 "Music" 的 Bus)
	add_child(music_player)
	music_player.bus = "Music"
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	for entry in sfx_list:
		if entry and entry.name != "":
			sfx_dict[entry.name] = entry
	
	for entry in music_list:
		if entry and entry.name != "":
			music_dict[entry.name] = entry
			
	print("--- AudioManager 註冊完畢 ---")
	print("已載入音效: ", sfx_dict.keys())
	print("已載入音樂: ", music_dict.keys())

# 播放音效 (SFX)
func play_sfx(sound_name: String):
	if sfx_dict.has(sound_name):
		var entry = sfx_dict[sound_name]
		var player = AudioStreamPlayer.new()
		add_child(player)
		
		player.stream = entry.stream
		player.volume_db = entry.volume_db # 套用個別音效的音量
		
		# --- 音高處理邏輯 ---
		var pitch = 1.0
		if entry.pitch_min != entry.pitch_max:
			if entry.pitch_steps > 1:
				var step_index = 0
				if entry.pitch_random:
					# 模式 A：純隨機挑選
					step_index = randi() % entry.pitch_steps
				else:
					# 模式 B：按順序循環 (1 -> 2 -> 3 -> 1)
					step_index = sfx_pitch_counters.get(sound_name, 0)
					sfx_pitch_counters[sound_name] = (step_index + 1) % entry.pitch_steps
				
				# 計算對應段數的音高
				pitch = lerp(entry.pitch_min, entry.pitch_max, float(step_index) / (entry.pitch_steps - 1))
			else:
				# 模式 C：無段數限制的純隨機
				pitch = randf_range(entry.pitch_min, entry.pitch_max)
		
		player.pitch_scale = pitch
		# --------------------
		
		player.bus = "SFX" # 設定 SFX 的 Bus
		player.play()
		
		if entry.loop:
			player.finished.connect(player.play)
		else:
			player.finished.connect(player.queue_free)
	else:
		push_warning("AudioManager: 找不到音效名稱 -> " + sound_name)

# 播放音樂 (Music)
func play_music(music_name: String):
	if music_dict.has(music_name):
		var entry = music_dict[music_name]
		if music_player.stream == entry.stream and music_player.playing:
			return
			
		music_player.stream = entry.stream
		music_player.volume_db = entry.volume_db # 套用個別音樂的音量
		music_player.play()
		
		if music_player.finished.is_connected(music_player.play):
			music_player.finished.disconnect(music_player.play)
			
		if entry.loop:
			music_player.finished.connect(music_player.play)
	else:
		push_warning("AudioManager: 找不到音樂名稱 -> " + music_name)

# --- 音量控制功能 (線性 0.0 ~ 1.0 轉為分貝) ---

# 調整主音量 (Master)
func set_master_volume(value: float):
	_set_bus_volume("Master", value)

# 調整音樂音量 (Music)
func set_music_volume(value: float):
	_set_bus_volume("Music", value)

# 調整音效音量 (SFX)
func set_sfx_volume(value: float):
	_set_bus_volume("SFX", value)

func _set_bus_volume(bus_name: String, value: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		# 將 0.0~1.0 的線性值轉為 Godot 使用的分貝值
		var db = linear_to_db(clamp(value, 0.0, 1.0))
		AudioServer.set_bus_volume_db(bus_index, db)
	else:
		push_warning("AudioManager: 找不到音量 Bus -> " + bus_name)

func stop_music():
	music_player.stop()
