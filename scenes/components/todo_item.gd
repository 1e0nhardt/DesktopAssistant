extends PanelContainer

@onready var todo_label: Label = $HBoxContainer/Label
@onready var checked_button: TextureButton = $HBoxContainer/CheckedButton
@onready var important_button: TextureButton = $HBoxContainer/ImportantButton

var item_data: Global.TodoItem
var not_important_icon := preload("res://assets/icons/collection.svg")
var important_icon := preload("res://assets/icons/collection_selected.svg")
var todo_icon := preload("res://assets/icons/icon_circle.png")
var done_icon := preload("res://assets/icons/wancheng.png")


func set_data(data: Global.TodoItem):
    # Logger.debug("Data", data)
    item_data = data
    todo_label.text = data.content
    checked_button.texture_normal = done_icon if item_data.done else todo_icon
    important_button.texture_normal = important_icon if item_data.important else not_important_icon


func _on_checked_button_pressed():
    item_data.done = not item_data.done
    owner.update_todos()


func _on_important_button_pressed():
    item_data.important = not item_data.important
    # change sprite
    important_button.texture_normal = important_icon if item_data.important else not_important_icon
