@tool
extends EditorScript

# 設定我們要掃描的資料夾 (只掃描腳本跟場景，避免掃到圖片或音效)
var folders_to_scan = ["res://Scripts", "res://Scenes"]
var output_text = ""

# 當我們在編輯器按下「執行」時，會觸發這個函式
func _run():
	output_text = "### 🎮 Godot 專案架構與程式碼匯出 ###\n\n"
	
	for folder in folders_to_scan:
		scan_directory(folder)
		
	# 將收集到的純文字，存成一個 txt 檔放在專案根目錄
	var file = FileAccess.open("res://project_export_for_ai.txt", FileAccess.WRITE)
	if file:
		file.store_string(output_text)
		file.close()
		print("✅ 匯出成功！請到專案資料夾尋找 project_export_for_ai.txt")
		
		# 讓 Godot 編輯器重新整理檔案總管，這樣你才看得到新檔案
		EditorInterface.get_resource_filesystem().scan()
	else:
		print("❌ 匯出失敗，無法寫入檔案。")

# 遞迴掃描資料夾
func scan_directory(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# 忽略隱藏檔 (例如 .godot 資料夾)
			if file_name.begins_with("."):
				file_name = dir.get_next()
				continue
				
			var full_path = path + "/" + file_name
			if dir.current_is_dir():
				# 如果是資料夾，就繼續往下挖
				scan_directory(full_path)
			else:
				# 如果是腳本或場景檔，就讀取內容
				if file_name.ends_with(".gd") or file_name.ends_with(".tscn"):
					append_file_content(full_path)
					
			file_name = dir.get_next()

# 讀取檔案並加上 Markdown 格式排版
func append_file_content(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var lang = "gdscript" if file_path.ends_with(".gd") else "text"
		
		output_text += "--- File: " + file_path + " ---\n"
		output_text += "```" + lang + "\n"
		output_text += content + "\n"
		output_text += "```\n\n"
		file.close()
