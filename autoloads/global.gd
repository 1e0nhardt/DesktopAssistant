extends Node

class TodoItem:
    var _data_dict: Dictionary = {}
    var done: bool:
        set(value):
            _data_dict["done"] = value
        get:
            return _data_dict["done"]

    var important: bool:
        set(value):
            _data_dict["important"] = value
        get:
            return _data_dict["important"]

    var create_date:
        get:
            return _data_dict["create_date"]

    var id:
        get:
            return _data_dict["id"]

    var content:
        get:
            return _data_dict["content"]

    func init(text: String, _id: int):
        _data_dict = {
            "id": _id,
            "done": false,
            "important": false,
            "content": text,
            "create_date": Time.get_datetime_string_from_system(false, true)
        }
        return self

    func init_with_dict(dict: Dictionary):
        _data_dict = dict
        return self

    func _to_string():
        return str(_data_dict)


class TodoList:
    var _id: int = 0
    var todo_list = []

    func add_item(text: String):
        todo_list.append(TodoItem.new().init(text, _id))
        _id += 1

    func delete_item(id: int):
        for t in todo_list:
            if t.id == id:
                todo_list.erase(t)
                return

    func get_todos() -> Array:
        return todo_list.filter(func (x): return not x.done)

    func get_dones() -> Array:
        return todo_list.filter(func (x): return x.done)

    func serialize():
        var todo_item_dicts = []
        Logger.debug("Todo List", todo_list)
        for t in todo_list:
            todo_item_dicts.append(t._data_dict)
        var f = FileAccess.open("user://todo_data.json", FileAccess.WRITE)
        f.store_string(JSON.stringify(todo_item_dicts, "\t"))
        f.close()

    func deserialize() -> TodoList:
        if not FileAccess.file_exists("user://todo_data.json"):
            return self

        var data = JSON.parse_string(FileAccess.get_file_as_string("user://todo_data.json"))
        for d in data:
            todo_list.append(TodoItem.new().init_with_dict(d))
        _id = todo_list[-1].id + 1
        return self

    func _to_string():
        var todo_item_dicts = []
        for t in todo_list:
            todo_item_dicts.append(t._data_dict)
        return str(todo_item_dicts)



var todo_list := TodoList.new().deserialize()
