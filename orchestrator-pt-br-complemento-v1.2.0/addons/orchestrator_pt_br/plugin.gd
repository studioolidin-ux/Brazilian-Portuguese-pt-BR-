@tool
extends EditorPlugin
## Atua exclusivamente nos controles do editor. Não escreve recursos ou scripts.

const DOMAIN: StringName = &"orchestrator.pt_BR.interface"
const Catalog = preload("res://addons/orchestrator_pt_br/traducao.gd")
const SearchAdapter = preload("res://addons/orchestrator_pt_br/busca.gd")
const HelpAdapter = preload("res://addons/orchestrator_pt_br/ajuda.gd")
var _translation: Translation
var _changed: Dictionary = {}
var _adapters: Array[WeakRef] = []
var _active := false

func _enter_tree() -> void:
	_translation = Catalog.new()
	_translation.locale = "pt_BR"
	var domain := TranslationServer.get_or_add_domain(DOMAIN)
	domain.set_locale_override("pt_BR")
	domain.add_translation(_translation)
	_active = true
	get_tree().node_added.connect(_on_node_added)
	# Diálogos nativos podem ser janelas irmãs do controle principal do editor.
	_scan.call_deferred(get_tree().root)

func _exit_tree() -> void:
	_active = false
	for reference in _adapters:
		var adapter = reference.get_ref()
		if is_instance_valid(adapter):
			adapter.cleanup()
	_adapters.clear()
	if get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.disconnect(_on_node_added)
	for record: Dictionary in _changed.values():
		var node: Node = record.ref.get_ref()
		if not is_instance_valid(node):
			continue
		_restore_domain(node, record.domain)
		node.auto_translate_mode = record.mode
		if node is LineEdit and record.has("placeholder"):
			node.placeholder_text = record.placeholder
		node.notification(NOTIFICATION_TRANSLATION_CHANGED)
	_changed.clear()
	if TranslationServer.has_domain(DOMAIN):
		TranslationServer.get_or_add_domain(DOMAIN).remove_translation(_translation)
	_translation = null

func _on_node_added(node: Node) -> void:
	# node_added acontece durante a construção C++; aguarde os controles terminarem.
	_localize.call_deferred(weakref(node))

func _scan(node: Node) -> void:
	if not _active or not is_instance_valid(node):
		return
	_localize(weakref(node))
	for child in node.get_children(true):
		_scan(child)

func _belongs_to_orchestrator(node: Node) -> bool:
	var current := node
	while is_instance_valid(current):
		if String(current.get_class()).begins_with("OrchestratorEditor"):
			return true
		current = current.get_parent()
	return false

func _localize(reference: WeakRef) -> void:
	if not _active:
		return
	var node: Node = reference.get_ref()
	if not is_instance_valid(node) or not node.is_inside_tree():
		return
	if not (node is Control or node is Window) or not _belongs_to_orchestrator(node):
		return
	var id := node.get_instance_id()
	if _changed.has(id):
		return
	_changed[id] = {"ref": reference, "domain": node.get_translation_domain(), "mode": node.auto_translate_mode}
	node.tree_exiting.connect(_forget.bind(id), CONNECT_ONE_SHOT)
	# O domínio muda apenas a renderização. get_text(), IDs e metadados permanecem iguais.
	node.set_translation_domain(DOMAIN)
	if node is LineEdit or node is TextEdit:
		# Texto digitado, código, caminhos e valores nunca são traduzidos.
		node.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		if node is LineEdit:
			_changed[id].placeholder = node.placeholder_text
			node.placeholder_text = node.tr(node.placeholder_text)
	elif node.auto_translate_mode != Node.AUTO_TRANSLATE_MODE_DISABLED or _is_action_results(node):
		node.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_ALWAYS
	node.notification(NOTIFICATION_TRANSLATION_CHANGED)
	if node.get_class() == "OrchestratorEditorActionMenu":
		var adapter := SearchAdapter.new()
		node.add_child(adapter)
		adapter.initialize(node, _translation)
		_adapters.append(weakref(adapter))
	elif node.get_class() == "OrchestratorEditorHelpBit":
		var adapter := HelpAdapter.new()
		node.add_child(adapter)
		adapter.initialize(node, _translation)
		_adapters.append(weakref(adapter))

func _restore_domain(node: Node, previous: StringName) -> void:
	if previous == DOMAIN:
		node.set_translation_domain_inherited()
	else:
		node.set_translation_domain(previous)

func _forget(id: int) -> void:
	if not _changed.has(id):
		return
	var record: Dictionary = _changed[id]
	var node: Node = record.ref.get_ref()
	if is_instance_valid(node):
		_restore_domain(node, record.domain)
		node.auto_translate_mode = record.mode
		if node is LineEdit and record.has("placeholder"):
			node.placeholder_text = record.placeholder
	_changed.erase(id)

func _is_action_results(node: Node) -> bool:
	if not node is Tree:
		return false
	var parent := node.get_parent()
	while is_instance_valid(parent):
		if parent.get_class() == "OrchestratorEditorActionMenu":
			return true
		parent = parent.get_parent()
	return false
