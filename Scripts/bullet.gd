extends Area2D

@export var speed: float = 600.0

func _ready():
	# 防呆與效能優化：子彈如果飛到畫面外永遠不消失，電腦會當機。
	# 這行的意思是：等 2 秒後，自動把自己刪除。
	await get_tree().create_timer(2.0).timeout
	queue_free() # queue_free() 是 Godot 裡「刪除節點」的神級指令

func _physics_process(delta):
	# 在 Godot 的 2D 世界裡，預設的「前方」就是「右邊」(Vector2.RIGHT)
	# 我們根據子彈目前的旋轉角度(rotation)，算出它真正面向的方向
	var direction = Vector2.RIGHT.rotated(rotation)
	
	# 讓子彈朝著那個方向等速往前飛
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	# 防呆檢查：我們撞到的東西，是 Boss 嗎？
	if body is Boss:
		# 呼叫我們剛剛在 Boss 身上寫的扣血功能，假設一顆子彈扣 10 滴血
		body.take_damage(1)
		
		# 子彈打到人之後，自己也要毀滅
		queue_free()
