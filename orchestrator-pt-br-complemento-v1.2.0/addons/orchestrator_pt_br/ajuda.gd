@tool
extends Node
## Exibe uma cópia traduzida da ajuda montada por add_text(), sem modificar a original.

var catalog: Translation
var _title_source: RichTextLabel
var _body_source: RichTextLabel
var _title: RichTextLabel
var _body: RichTextLabel
var _box: VBoxContainer
var _last_title := "\u0001"
var _last_body := "\u0001"
var _elapsed := 0.0

func initialize(source: Node, translation: Translation) -> void:
	catalog = translation
	var labels: Array[RichTextLabel] = []
	for child in source.get_children():
		if child is RichTextLabel:
			labels.append(child)
	if labels.size() < 2:
		queue_free()
		return
	_title_source = labels[0]
	_body_source = labels[1]
	_title_source.hide()
	_body_source.hide()
	_box = VBoxContainer.new()
	_box.name = "AjudaEmPortugues"
	_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	source.add_child(_box)
	_title = RichTextLabel.new()
	_title.name = "TituloTraduzido"
	_title.theme_type_variation = _title_source.theme_type_variation
	_title.fit_content = true
	_title.bbcode_enabled = false
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_box.add_child(_title)
	_body = RichTextLabel.new()
	_body.name = "DescricaoTraduzida"
	_body.theme_type_variation = _body_source.theme_type_variation
	_body.bbcode_enabled = false
	_body.custom_minimum_size = Vector2(0, maxf(80, _body_source.custom_minimum_size.y))
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.scroll_active = true
	_box.add_child(_body)
	refresh()

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= 0.08:
		_elapsed = 0.0
		refresh()

func refresh() -> void:
	if not is_instance_valid(_body_source):
		return
	var title_text := _title_source.get_parsed_text()
	var body_text := _body_source.get_parsed_text()
	if title_text != _last_title:
		_last_title = title_text
		_title.text = catalog.help_title(title_text)
	if body_text != _last_body:
		_last_body = body_text
		_body.text = catalog.help_body(body_text)

func cleanup() -> void:
	set_process(false)
	if is_instance_valid(_title_source):
		_title_source.show()
	if is_instance_valid(_body_source):
		_body_source.show()
	if is_instance_valid(_box):
		_box.queue_free()
	queue_free()
