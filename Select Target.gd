extends Button

@export var spaceship: RigidBody2D 
var is_selecting_location := false
var popup_label: Label = null

func _ready() -> void:
	pressed.connect(_on_select_location_button_pressed)

func _on_select_location_button_pressed() -> void:
	if is_selecting_location:
		return # Prevent creating duplicate labels if clicked twice
		
	is_selecting_location = true
	print("Click anywhere in the world to pick a position...")
	
	# Spawn the label ONCE when selection starts
	popup_label = Label.new()
	popup_label.text = "Click on a planet"
	popup_label.add_theme_font_size_override("font_size", 32)
	popup_label.global_position = Vector2(700, 700)
	add_child(popup_label)

func _unhandled_input(event: InputEvent) -> void:
	if not is_selecting_location:
		return

	# Cancel selection if Right Click or Escape is pressed
	if event.is_action_pressed("ui_cancel") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed):
		print("Selection canceled.")
		_clear_selection()
		return

	# Detect Left Mouse Button click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if spaceship == null:
			push_error("Spaceship reference is missing!")
			_clear_selection()
			return

		var selected_world_position = spaceship.get_global_mouse_position()
		
		var min_distance: float = INF
		var planets = get_tree().get_nodes_in_group("gravity_sources")
		var target_planet: Node2D = null
		
		for planet in planets:
			if planet.name != "Sun":
				var distance = planet.global_position.distance_to(selected_world_position)
				if distance < min_distance:
					min_distance = distance
					target_planet = planet

		spaceship.target_planet = target_planet
		print("Selected World Position: ", selected_world_position)
		print(target_planet)

		_clear_selection()
		get_viewport().set_input_as_handled()

func _clear_selection() -> void:
	is_selecting_location = false
	if popup_label != null and is_instance_valid(popup_label):
		popup_label.queue_free()
		popup_label = null
