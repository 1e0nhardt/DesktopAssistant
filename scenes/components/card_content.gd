extends TextEdit


func _ready():
    for child in get_children(true):
        if child is VScrollBar:
            print(child.name)
            # 修改样式
            child.hide()