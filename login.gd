extends Control

# 保存用户数据的文件路径（自动存在用户目录，不会丢）
var user_data_path: String = OS.get_user_data_dir() + "/junomp_users.json"

@onready var login_inner: Control = $Login

@onready var main: Control = $Login/Main
@onready var main_submit_button: Button = $Login/Main/Background/MainSubmitButton
@onready var main_register_button: Button = $Login/Main/Background/MainRegisterButton
@onready var main_change_button: Button = $Login/Main/Background/MainChangeButton
@onready var main_account: LineEdit = $Login/Main/Background/MainAccount
@onready var main_password: LineEdit = $Login/Main/Background/MainPassword

@onready var register: Control = $Login/Register
@onready var register_cancel_button: Button = $Login/Register/Background2/RegisterCancelButton
@onready var register_submit_button: Button = $Login/Register/Background2/RegisterSubmitButton
@onready var register_account: LineEdit = $Login/Register/Background2/RegisterAccount
@onready var register_password: LineEdit = $Login/Register/Background2/RegisterPassword
@onready var register_password_2: LineEdit = $Login/Register/Background2/RegisterPassword2

@onready var changepassword: Control = $Login/Changepassword
@onready var change_submit_button: Button = $Login/Changepassword/Background2/ChangeSubmitButton
@onready var change_cancel_button: Button = $Login/Changepassword/Background2/ChangeCancelButton
@onready var change_account: LineEdit = $Login/Changepassword/Background2/ChangeAccount
@onready var change_password: LineEdit = $Login/Changepassword/Background2/ChangePassword
@onready var new_password: LineEdit = $Login/Changepassword/Background2/NewPassword
@onready var new_password_2: LineEdit = $Login/Changepassword/Background2/NewPassword2

@onready var button_sound = $ButtonSound


func _ready() -> void:
	register.visible = false
	changepassword.visible = false
	# 让密码框显示为星号
	main_password.secret = true
	register_password.secret = true
	register_password_2.secret = true
	change_password.secret = true
	new_password.secret = true
	new_password_2.secret = true
	connect_buttons(self)

# 通用界面切换
func switch_screen(screen: String) -> void:
	main.visible = (screen == "main")
	register.visible = (screen == "register")
	changepassword.visible = (screen == "changepassword")

# 清空所有输入框
func clear_all_inputs() -> void:
	main_account.text = ""
	main_password.text = ""
	register_account.text = ""
	register_password.text = ""
	register_password_2.text = ""
	change_account.text = ""
	change_password.text = ""
	new_password.text = ""
	new_password_2.text = ""


# 工具函数：读取本地用户数据
func load_users() -> Dictionary:
	if not FileAccess.file_exists(user_data_path):
		return {}  # 文件不存在，返回空字典
	
	var file = FileAccess.open(user_data_path, FileAccess.READ)
	if not file:
		print("❌ 无法读取用户数据文件！")
		return {}
	
	var json_str = file.get_as_text()
	file.close()
	return JSON.parse_string(json_str)


# 工具函数：保存用户数据到本地
func save_users(users: Dictionary) -> void:
	var file = FileAccess.open(user_data_path, FileAccess.WRITE)
	if not file:
		print("❌ 无法创建用户数据文件！路径：", user_data_path)
		return
	file.store_string(JSON.stringify(users))
	file.close()
	print("✅ 用户数据已保存到：", user_data_path)


# ===================== 登录按钮 =====================
func _on_main_submit_button_pressed() -> void:
	var account = main_account.text.strip_edges()
	var password = main_password.text.strip_edges()

	if account == "" or password == "":
		print("❌ 账号或密码不能为空")
		return

	var users = load_users()

	if not users.has(account):
		print("❌ 账号不存在，请先注册")
		return

	if users[account] != password:
		print("❌ 密码错误")
		return

	print("✅ 登录成功！")
	clear_all_inputs()
	# 【关键】把这里改成你的游戏场景路径！
	get_tree().change_scene_to_file("res://meun.tscn")


# ===================== 注册界面跳转 =====================
func _on_main_register_button_pressed() -> void:
	clear_all_inputs()
	switch_screen("register")


# ===================== 修改密码界面跳转 =====================
func _on_main_change_button_pressed() -> void:
	clear_all_inputs()
	switch_screen("changepassword")


# ===================== 注册取消按钮 =====================
func _on_register_cancel_button_pressed() -> void:
	clear_all_inputs()
	switch_screen("main")


# ===================== 修改密码取消按钮 =====================
func _on_change_cancel_button_pressed() -> void:
	clear_all_inputs()
	switch_screen("main")


# ===================== 注册提交按钮 =====================
func _on_register_submit_button_pressed() -> void:
	var account = register_account.text.strip_edges()
	var password = register_password.text.strip_edges()
	var password2 = register_password_2.text.strip_edges()

	# 基础校验
	if account == "" or password == "" or password2 == "":
		print("❌ 注册信息不完整")
		return
	if password != password2:
		print("❌ 两次输入的密码不一致")
		return
	if password.length() < 4:  # 简单密码长度限制
		print("❌ 密码长度至少4位")
		return

	var users = load_users()

	if users.has(account):
		print("❌ 该账号已被注册")
		return

	# 保存账号密码
	users[account] = password
	save_users(users)

	print("✅ 注册成功！")
	clear_all_inputs()
	switch_screen("main")


# ===================== 修改密码提交按钮 =====================
func _on_change_submit_button_pressed() -> void:
	var account = change_account.text.strip_edges()
	var old_pwd = change_password.text.strip_edges()
	var new_pwd = new_password.text.strip_edges()
	var new_pwd2 = new_password_2.text.strip_edges()

	# 基础校验
	if account == "" or old_pwd == "" or new_pwd == "" or new_pwd2 == "":
		print("❌ 修改密码信息不完整")
		return
	if new_pwd != new_pwd2:
		print("❌ 两次输入的新密码不一致")
		return
	if new_pwd.length() < 4:
		print("❌ 新密码长度至少4位")
		return

	var users = load_users()

	if not users.has(account):
		print("❌ 账号不存在")
		return
	if users[account] != old_pwd:
		print("❌ 原密码错误")
		return

	# 更新密码
	users[account] = new_pwd
	save_users(users)

	print("✅ 密码修改成功！")
	
	clear_all_inputs()
	switch_screen("main")

	

func connect_buttons(node):
	for child in node.get_children():
		if child is Button:
			child.pressed.connect(play_button_sound)
		connect_buttons(child)
	
func play_button_sound():
	button_sound.play()

	
