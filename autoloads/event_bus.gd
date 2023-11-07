extends Node

signal joints_updating


func emit_joints_updating():
    joints_updating.emit()


class NopassAreas:
    var nopass_area_dict: Dictionary = {}
    var group_tag = {} # 各个连通组

    func update_nopass_area(nopass_area: PackedVector2Array, node_id: int):
        nopass_area_dict[node_id] = nopass_area

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

    func cmp(a, b) -> bool:
        return nopass_area_dict[a][0].x < nopass_area_dict[b][1].x

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

        Logger.debug("Pre", pre)
        Logger.debug("Keys", keys)
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
        Logger.debug("Group Tag", group_tag)
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

    func find(x: int, pre: Array):
        while pre[x] != x:
            x = pre[x]
        return x

    func join(x: int, y: int, pre: Array):
        var px = find(x, pre)
        var py = find(y, pre)
        if px != py:
            pre[py] = px

    func generate_final_rects() -> PackedVector2Array:
        var keys = nopass_area_dict.keys()
        keys.sort_custom(cmp)
        # 生成最终目标区域
        var combined_area: PackedVector2Array = []
        var start_points := []
        Logger.debug("Group Tag", group_tag)
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

var nopass_areas = NopassAreas.new()
var fullscreen_nopass_flag := false


func update_nopass_area(nopass_area: PackedVector2Array, node_id: int):
    nopass_areas.update_nopass_area(nopass_area, node_id)
    var area := nopass_areas.init_dectect_overlaps()
    #TODO 几个区域合在一起时，一起拖动后会闪一下
    DisplayServer.window_set_mouse_passthrough(area)
    fullscreen_nopass_flag = false


func set_fullscreen_nopass_area():
    if fullscreen_nopass_flag:
        return
    DisplayServer.window_set_mouse_passthrough([])
    fullscreen_nopass_flag = true

