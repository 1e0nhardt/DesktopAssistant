extends PanelContainer

@onready var tag_container: HBoxContainer = %TagContainer
@onready var tag_edit: LineEdit = %TagEdit

var tag_button_scene = preload("res://scenes/components/tag_button.tscn")


func _on_line_edit_text_submitted(new_text: String):
    tag_edit.text = ""
    
    var tag_button = tag_button_scene.instantiate() as TagButton
    tag_container.add_child(tag_button)
    tag_button.setup(new_text)
    tag_container.show()

