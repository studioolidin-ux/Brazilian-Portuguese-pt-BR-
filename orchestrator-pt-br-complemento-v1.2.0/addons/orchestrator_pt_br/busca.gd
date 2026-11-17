@tool
extends Node
## Filtra os próprios TreeItems do menu nativo; objetos, seleção e callbacks são preservados.

var catalog: Translation
var _menu: ConfirmationDialog
var _native: LineEdit
var _input: LineEdit
var _tree: Tree
var _index: Array[Dictionary] = []
var _last_root: int = 0
var _busy := true
var _dirty := true
var _elapsed := 0.0
var _last_query := ""

func initialize(menu: ConfirmationDialog, translation: Translation) -> void:
	_menu = menu
	catalog = translation
	_native = _find(menu, "LineEdit")
	_tree = _find(menu, "Tree")
	if not _native or not _tree:
		queue_free()
		return
	_input = LineEdit.new()
	_input.name = "PesquisaPortugues"
	_input.size_flags_horizontal = _native.size_flags_horizontal
	_input.custom_minimum_size = _native.custom_minimum_size
	_input.right_icon = _native.right_icon
	_input.clear_button_enabled = true
	_input.placeholder_text = "Pesquisar em português ou pelo nome original"
	var parent := _native.get_parent()
	parent.add_child(_input)
	parent.move_child(_input, _native.get_index())
	_native.hide()
	_input.text_changed.connect(_query_changed)
	_input.gui_input.connect(_keyboard_input)
	_menu.register_text_enter(_input)
	_input.grab_focus.call_deferred()
	if not _native.text.is_empty():
		_native.text = ""
		_native.text_changed.emit("")

func _find(node: Node, type: String) -> Node:
	for child in node.get_children(true):
		if child.is_class(type):
			return child
		var found := _find(child, type)
		if found:
			return found
	return null

func _query_changed(_query: String) -> void:
	_dirty = true
	_elapsed = 0.0

func _keyboard_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode in [KEY_UP, KEY_DOWN, KEY_PAGEUP, KEY_PAGEDOWN]:
		_native.gui_input.emit(event)
		_input.accept_event()

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed < 0.08 or not is_instance_valid(_tree) or not is_instance_valid(_native):
		return
	_elapsed = 0.0
	if not _native.text.is_empty():
		# Favoritos e recentes continuam consultando o menu nativo. Reabrir o conjunto completo.
		_input.text = catalog.caption(_native.text)
		_native.text = ""
		_native.text_changed.emit("")
		_busy = true
		_dirty = true
	if _menu.is_processing():
		_busy = true
		return
	var root := _tree.get_root()
	if not root or not root.get_first_child():
		return
	if _busy or _last_root != root.get_instance_id() or _index.is_empty():
		_index.clear()
		_build_index(root, "", "")
		_last_root = root.get_instance_id()
		_busy = false
		_dirty = true
	if _dirty:
		_filter()
		_dirty = false

func _build_index(parent: TreeItem, raw_path: String, translated_path: String) -> void:
	for item in parent.get_children():
		var raw := item.get_text(0)
		var translated: String = catalog.caption(raw)
		var path := raw_path + " " + raw
		var localized_path := translated_path + " " + translated
		_index.append({"ref": weakref(item), "key": catalog.search_key(path + " " + localized_path), "collapsed": item.collapsed, "selectable": item.is_selectable(0)})
		_build_index(item, path, localized_path)

func _filter() -> void:
	var query: String = catalog.search_key(_input.text)
	var tokens := query.split(" ", false)
	var keep: Dictionary = {}
	var first: TreeItem
	for record in _index:
		var item: TreeItem = record.ref.get_ref()
		if not is_instance_valid(item):
			_busy = true
			return
		var matches := true
		for token in tokens:
			if not record.key.contains(token):
				matches = false
				break
		if matches:
			var ancestor := item
			while ancestor:
				keep[ancestor.get_instance_id()] = true
				ancestor = ancestor.get_parent()
			if not first and record.selectable:
				first = item
	for record in _index:
		var item: TreeItem = record.ref.get_ref()
		item.visible = keep.has(item.get_instance_id())
		if query.is_empty():
			item.collapsed = record.collapsed
		elif item.visible and item.get_first_child():
			item.collapsed = false
	if not query.is_empty():
		_tree.deselect_all()
		if first:
			first.select(0)
			_tree.scroll_to_item(first)
			_tree.cell_selected.emit()
		else:
			_tree.nothing_selected.emit()
	_last_query = query

func cleanup() -> void:
	set_process(false)
	for record in _index:
		var item: TreeItem = record.ref.get_ref()
		if is_instance_valid(item):
			item.visible = true
			item.collapsed = record.collapsed
	if is_instance_valid(_native):
		_native.show()
		_native.text = ""
		_native.text_changed.emit("")
	if is_instance_valid(_input):
		_input.queue_free()
	queue_free()
