extends Node

var count_down_amount = 30


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

    func clear_dones():
        todo_list = get_todos()

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


class CardDatabase:
    var _db: SQLite
    var _db_name := "user://data"
    var _table_name := "cards"
    var _tag := ""

    func _init(verbosity_level : int = SQLite.VERBOSE, reset := false):
        _db = SQLite.new()
        _db.path = _db_name
        _db.verbosity_level = verbosity_level
        # Open the database using the db_name found in the path variable
        _db.open_db()

        if not table_exists():
            init_table()
        
        if reset:
            _db.drop_table(_table_name)
            init_table()
    
    func init_table():
        var table_dict : Dictionary = Dictionary()
        table_dict["id"] = {"data_type":"int", "primary_key": true, "not_null": true, "auto_increment": true}
        table_dict["title"] = {"data_type":"text", "not_null": true}
        table_dict["content"] = {"data_type":"text", "not_null": true}
        table_dict["tags"] = {"data_type":"text", "not_null": true}
        table_dict["timestamp"] = {"data_type":"real", "not_null": true}

        _db.create_table(_table_name, table_dict)
    
    func table_exists() -> bool:
        _db.query("SELECT count(*) AS 'exist' FROM sqlite_master WHERE type='table' AND name='%s';" % _table_name)
        return _db.query_result[0]['exist'] == 1
    
    func insert(title: String, content: String, tags: String):
        var row_dict := {
            "title": title, 
            "content": content, 
            "tags": tags, 
            "timestamp": Time.get_unix_time_from_system()
        }
        _db.insert_row(_table_name, row_dict)
    
    func update(id: int, title: String, content: String, tags: String):
        _db.update_rows(_table_name, "id = %s" % id, {
            "title": title,
            "content": content,
            "tags": tags, 
            "timestamp": Time.get_unix_time_from_system()
        })
    
    func delete(id: int):
        _db.delete_rows(_table_name, "id = %s" % id)
        # _db.query("DELETE FROM %s WHERE should_be_delete(id);" % _table_name)
    
    func query_all(limit=8, offset=0) -> Array[Dictionary]:
        # _db.query("SELECT * FROM %s;" % _table_name) # 正序
        # _db.query("SELECT * FROM %s ORDER BY id desc" % _table_name) # 倒序
        _db.query("SELECT * FROM %s ORDER BY id desc LIMIT %d OFFSET %d;" % [_table_name, limit, offset]) # 分页
        return _db.query_result
    
    func query_all_count() -> int:
        _db.query("SELECT count(*) AS amount FROM %s ;" % _table_name)
        return _db.query_result[0]["amount"]
    
    func query_by_tag(tag: String, limit=8, offset=0):
        _tag = tag
        _db.create_function("has_tags", has_tags, 1)
        # _db.query("SELECT * FROM %s WHERE has_tags(tags);" % _table_name)
        _db.query("SELECT * FROM %s WHERE has_tags(tags) ORDER BY id desc LIMIT %d OFFSET %d;" % [_table_name, limit, offset])
        return _db.query_result
    
    func query_ids_by_tag(tag: String, limit=8, offset=0):
        _tag = tag
        _db.create_function("has_tags", has_tags, 1)
        # _db.query("SELECT * FROM %s WHERE has_tags(tags);" % _table_name)
        _db.query("SELECT id FROM %s WHERE has_tags(tags) ORDER BY id desc LIMIT %d OFFSET %d;" % [_table_name, limit, offset])
        return _db.query_result

    func query_tag_count(tag: String) -> int:
        _tag = tag
        _db.create_function("has_tags", has_tags, 1)
        _db.query("SELECT count(*) AS amount FROM %s WHERE has_tags(tags);" % _table_name)
        return _db.query_result[0]["amount"]

    func query_by_id(id: int) -> Dictionary:
        _db.query("SELECT * FROM %s WHERE id=%s;" % [_table_name, id])
        return _db.query_result[0]

    func close():
        _db.close_db()
    
    func has_tags(tags: String):
        for tag in _tag.split(","):
            if tags.find(_tag) == -1:
                return false
        return true


var todo_list := TodoList.new().deserialize()
var card_db := CardDatabase.new()


func test():
    if true:
        return

    # card_db.insert("t1", "contnelktalk", "dev, test")
    # card_db.insert("t2", "dontnelkfdsglk", "dev, test")
    # card_db.insert("t3", "eontnesadflk", "dev, test")
    # card_db.insert("t4", "fonthfdsktalk", "dev, test")

    Logger.debug("Cards", card_db.query_all())
    # Logger.debug("Cards test", card_db.query_by_tag("test"))
    # Logger.debug("Cards dev", card_db.query_by_tag("dev, test"))