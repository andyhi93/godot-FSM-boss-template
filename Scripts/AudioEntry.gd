extends Resource
class_name AudioEntry

@export var name: String          # 音效的關鍵字
@export var stream: AudioStream   # 音效檔案
@export var loop: bool = false    # 是否要循環播放
@export_range(-80, 24) var volume_db: float = 0.0 # 個別音效的音量調整 (分貝)

@export_group("Pitch Settings")
@export var pitch_min: float = 1.0   # 最低音高 (1.0 是原音)
@export var pitch_max: float = 1.0   # 最高音高
@export var pitch_steps: int = 0    # 分段數 (例如 3)
@export var pitch_random: bool = true # 是否隨機？若為 false 則會按順序 (1->2->3->1) 循環播放
