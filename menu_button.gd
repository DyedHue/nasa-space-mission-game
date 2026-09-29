extends MenuButton

@onready var text_popup: PopupPanel = $PopupPanel

func _ready() -> void:
	get_popup().visible = false
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	# The popup will automatically position itself right under the shifted button
	var popup_pos = global_position
	popup_pos.y += size.y
	
	text_popup.position = Vector2i(popup_pos)
	text_popup.popup()
