extends Node

signal joints_updating


func emit_joints_updating():
    joints_updating.emit()

class NopassAreaNaive:
    var nopass_area_dict: Dictionary = {}

    func remove_area(node_id):
        if nopass_area_dict.has(node_id):
            nopass_area_dict.erase(node_id)

    func update_nopass_area(nopass_area: PackedVector2Array, node_id: int):
        if nopass_area.size() == 0:
            remove_area(node_id)
        else:
            nopass_area_dict[node_id] = nopass_area

        return generate_final_polygon()

    # Naive Solution 区域重叠部分会变黑
    func generate_final_polygon() -> PackedVector2Array:
        var combined_area: PackedVector2Array = []
        var start_points := []
        for k in nopass_area_dict:
            combined_area.append_array(nopass_area_dict[k])
            start_points.append(nopass_area_dict[k][0])
            combined_area.append(nopass_area_dict[k][0])
        start_points.reverse()
        combined_area.append_array(PackedVector2Array(start_points))
        return combined_area

class NopassAreaDisjointSet:
    var nopass_area_dict: Dictionary = {}
    var group_tag

    func remove_area(node_id):
        if nopass_area_dict.has(node_id):
            nopass_area_dict.erase(node_id)

    func update_nopass_area(nopass_area: PackedVector2Array, node_id: int):
        if nopass_area.size() == 0:
            remove_area(node_id)
        else:
            nopass_area_dict[node_id] = nopass_area

        return init_dectect_overlaps()

    func merge_rects(rects: Array) -> Array:
        var lu := Vector2(INF, INF)
        var rd := Vector2(-INF, -INF)
        for rect in rects:
            if rect[0].x < lu.x:
                lu.x = rect[0].x
            if rect[0].y < lu.y:
                lu.y = rect[0].y
            if rect[2].x > rd.x:
                rd.x = rect[2].x
            if rect[2].y > rd.y:
                rd.y = rect[2].y
        var ld = Vector2(lu.x, rd.y)
        var ru = Vector2(rd.x, lu.y)
        return [lu, ld, rd, ru, lu] # 闭合矩形

    func find(x: int, pre: Array):
        while pre[x] != x:
            x = pre[x]
        return x

    func join(x: int, y: int, pre: Array):
        var px = find(x, pre)
        var py = find(y, pre)
        if px != py:
            pre[py] = px

    func init_dectect_overlaps() -> PackedVector2Array:
        var keys = nopass_area_dict.keys()
        var pre = range(0, len(keys))
        # keys.sort_custom(cmp)
        for i in len(keys):
            for j in range(i, len(keys)):
                if find(i, pre) == find(j, pre):
                    continue # 已经连通了
                if check_rect_overlap(nopass_area_dict[keys[i]], nopass_area_dict[keys[j]]):
                    join(i, j, pre)

        # Logger.debug("Pre", pre)
        # Logger.debug("Keys", keys)
        group_tag = {}
        for i in range(0, len(keys)):
            var tag = find(i, pre)
            if group_tag.has(tag):
                group_tag[tag].append(i)
            else:
                group_tag[tag] = [i]

        # 生成最终目标区域
        var combined_area: PackedVector2Array = []
        var start_points := []
        # Logger.debug("Group Tag", group_tag)
        for t in group_tag:
            var rects = []
            for ki in group_tag[t]:
                rects.append(nopass_area_dict[keys[ki]])
            var merged_rect = merge_rects(rects)
            combined_area.append_array(merged_rect)
            start_points.append(merged_rect[0])
        start_points.reverse()
        combined_area.append_array(PackedVector2Array(start_points))

        return combined_area

    func check_rect_overlap(r1: Array, r2: Array):
        var r1lu = r1[0]
        var r2lu = r2[0]
        var r1wh = r1[2] - r1lu
        var r2wh = r2[2] - r2lu
        if (r1lu.x <= r2lu.x + r2wh.x and
            r1lu.x + r1wh.x >= r2lu.x and
            r1lu.y <= r2lu.y + r2wh.y and
            r1lu.y + r1wh.y >= r2lu.y):
            return true
        else:
            return false

class NopassAreaGraph:
    var nopass_area_dict: Dictionary = {}
    var adjacency_list: Dictionary = {}
    # var group_tag

    func remove_area(node_id):
        if adjacency_list.has(node_id):
            nopass_area_dict.erase(node_id)
            remove_vertex(node_id)
            Logger.debug("remove", node_id)

    func update_nopass_area(nopass_area: PackedVector2Array, node_id: int):
        if nopass_area.size() == 0:
            remove_area(node_id)
        else:
            nopass_area_dict[node_id] = nopass_area
            if adjacency_list.has(node_id):
                update_vertex(node_id)
            else:
                add_vertex(node_id)

        # 生成最终目标区域
        var combined_area: PackedVector2Array = []
        var start_points := []
        for rect_ids in graph_dfs():
            var rects := []
            for k in rect_ids:
                rects.append(nopass_area_dict[k])
            var merged_rect = merge_rects(rects)
            combined_area.append_array(merged_rect)
            start_points.append(merged_rect[0])
        start_points.reverse()
        combined_area.append_array(PackedVector2Array(start_points))

        # print_graph()

        return combined_area

    func size() -> int:
        return len(adjacency_list)

    func add_vertex(vert: int):
        if adjacency_list.has(vert):
            return

        adjacency_list[vert] = []

        # 如果重叠则添加一条边
        for v in adjacency_list:
            if v == vert:
                continue

            if check_rect_overlap2(vert, v):
                add_edge(vert, v)

    func remove_vertex(vert: int):
        if not adjacency_list.has(vert):
            assert(false, "Vertex not in graph! Remove vertex error")
        # 从邻接表中删除顶点
        adjacency_list.erase(vert)
        # 删除相关边
        for v in adjacency_list:
            if vert in adjacency_list[v]:
                adjacency_list[v].erase(vert)

    func update_vertex(vert: int):
        remove_vertex(vert)
        add_vertex(vert)

    func add_edge(vert1: int, vert2: int):
        if not adjacency_list.has(vert1) or not adjacency_list.has(vert2) or vert1 == vert2:
            assert(false, "Vertex not in graph! Add Edge error")

        adjacency_list[vert1].append(vert2)
        adjacency_list[vert2].append(vert1)

    func remove_edge(vert1: int, vert2: int):
        if not adjacency_list.has(vert1) or not adjacency_list.has(vert2) or vert1 == vert2:
            assert(false, "Vertex not in graph! Remove Edge error")

        adjacency_list[vert1].erase(vert2)
        adjacency_list[vert2].erase(vert1)

    func dfs(vert: int, visited: Dictionary, res: Array):
        res.append(vert)
        visited[vert] = true

        for adj_vert in adjacency_list[vert]:
            if visited[adj_vert]:
                continue
            dfs(adj_vert, visited, res)

    func graph_dfs() -> Array:
        var visited := {}
        for v in adjacency_list:
            visited[v] = false

        var groups = []
        for v in adjacency_list:
            if visited[v]:
                continue

            var vgroup = []
            dfs(v, visited, vgroup)
            groups.append(vgroup)

        return groups

    func print_graph():
        Logger.debug("Adjacency List", adjacency_list)

    # 将重叠的矩形合并为多边形(有亿点复杂)
    # 合并成一个大矩形(简单)
    func merge_rects(rects: Array) -> Array:
        var lu := Vector2(INF, INF)
        var rd := Vector2(-INF, -INF)
        for rect in rects:
            if rect[0].x < lu.x:
                lu.x = rect[0].x
            if rect[0].y < lu.y:
                lu.y = rect[0].y
            if rect[2].x > rd.x:
                rd.x = rect[2].x
            if rect[2].y > rd.y:
                rd.y = rect[2].y
        var ld = Vector2(lu.x, rd.y)
        var ru = Vector2(rd.x, lu.y)
        return [lu, ld, rd, ru, lu] # 闭合矩形

    func check_rect_overlap(r1: Array, r2: Array):
        var r1lu = r1[0]
        var r2lu = r2[0]
        var r1wh = r1[2] - r1lu
        var r2wh = r2[2] - r2lu
        if (r1lu.x <= r2lu.x + r2wh.x and
            r1lu.x + r1wh.x >= r2lu.x and
            r1lu.y <= r2lu.y + r2wh.y and
            r1lu.y + r1wh.y >= r2lu.y):
            return true
        else:
            return false

    func check_rect_overlap2(node_id1: int, node_id2: int):
        var r1 = nopass_area_dict[node_id1]
        var r2 = nopass_area_dict[node_id2]
        return check_rect_overlap(r1, r2)

# var nopass_areas = NopassAreaGraph.new()
# var nopass_areas = NopassAreaNaive.new()
var nopass_areas = NopassAreaDisjointSet.new()
var fullscreen_nopass_flag := false


func update_nopass_area(nopass_area: PackedVector2Array, node_id: int):
    var area = nopass_areas.update_nopass_area(nopass_area, node_id)
    #TODO 几个区域合在一起时，一起拖动后会闪一下
    DisplayServer.window_set_mouse_passthrough(area)
    fullscreen_nopass_flag = false
    # Logger.debug("Area", area)

func set_fullscreen_nopass_area():
    if fullscreen_nopass_flag:
        return
    DisplayServer.window_set_mouse_passthrough([])
    fullscreen_nopass_flag = true

var id = 0

func gen_id() -> int:
    id += 1
    return id
