extends VBoxContainer

@onready var title_container: HBoxContainer = $GroupTitle
@onready var done_container: VBoxContainer = $Done
@onready var checked_button: TextureButton = %CheckedButton


func _ready():
    done_container.visible = false


func _on_checked_button_pressed():
    # Logger.debug("Pressed")
    done_container.visible = not done_container.visible
    checked_button.material.set_shader_parameter("rotation", 90 * int(done_container.visible))
