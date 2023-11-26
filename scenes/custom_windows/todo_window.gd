class_name TodoWidget
extends "res://scenes/custom_windows/main_window.gd"

# @export var todo_item: PackedScene
signal closed

@onready var todo_edit: LineEdit = %TodoTextEdit
@onready var todo_items: VBoxContainer = %ToDos
@onready var done_revealer: VBoxContainer = %DoneRevealer
@onready var done_group: VBoxContainer = %Done

var todo_item_scene = preload("res://scenes/components/todo_item.tscn")
var todo_nodes = []


func _ready():
    super()
    # 居中显示
    global_position = (get_viewport_rect().size - size) * 0.5
    update_todos()


func update_todos():
    if todo_nodes.size() != 0:
        for node in todo_nodes:
            node.queue_free()
        todo_nodes.clear()

    for todo in Global.todo_list.get_todos():
        add_item_to_group(todo, todo_items)

    var dones = Global.todo_list.get_dones()
    done_revealer.visible = dones.size() != 0

    for todo in dones:
        add_item_to_group(todo, done_group)


func add_item_to_group(data, group_node: Node):
    var todo_item_instance = todo_item_scene.instantiate()
    group_node.add_child(todo_item_instance)
    todo_item_instance.set_data(data)
    todo_item_instance.owner = self # 从脚本初始化的节点的owner为null，需要手动设置
    todo_nodes.append(todo_item_instance)


func close():
    Global.todo_list.serialize()
    queue_free()


func _on_line_edit_text_submitted(new_text: String):
    # Logger.info(new_text)
    Global.todo_list.add_item(new_text)
    todo_edit.text = ""
    update_todos()
    # Logger.info(ProjectSettings.globalize_path("user://todo_data.json"))


func _on_close_button_pressed():
    closed.emit()


func _on_clear_button_pressed():
    Global.todo_list.clear_dones()
    update_todos()
