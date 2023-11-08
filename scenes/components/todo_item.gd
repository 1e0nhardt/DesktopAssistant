extends PanelContainer

@onready var todo_label: Label = $HBoxContainer/Label

var item_data: Global.TodoItem


func set_data(data: Global.TodoItem):
    Logger.debug("Data", data)
    item_data = data
    todo_label.text = data.content


func _on_checked_button_pressed():
    item_data.done = not item_data.done
    #TODO change sprite
    owner.update_todos()


func _on_important_button_pressed():
    item_data.important = not item_data.important
    #TODO change sprite
