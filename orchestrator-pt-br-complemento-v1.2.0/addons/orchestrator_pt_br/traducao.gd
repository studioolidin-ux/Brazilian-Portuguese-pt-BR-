@tool
extends Translation
## Catálogo restrito a textos de apresentação. Nenhum nome é gravado no grafo.

var _messages: Dictionary = {}
var _cache: Dictionary = {}
var _normalized: Dictionary = {}
var _preferred: Dictionary = {}
var _templates: Array[Dictionary] = []

func _init() -> void:
	for filename: String in ["api_pt_BR.json", "pt_BR.json", "revisado_pt_BR.json"]:
		var path := "res://addons/orchestrator_pt_br/" + filename
		if not FileAccess.file_exists(path):
			continue
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if parsed is Dictionary:
			_messages.merge(parsed, true)
			if filename != "api_pt_BR.json":
				_preferred.merge(parsed, true)
	for key: String in _messages:
		_normalized[_normalize(key)] = _messages[key]
	var patterns: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://addons/orchestrator_pt_br/modelos_pt_BR.json"))
	if patterns is Dictionary:
		for pattern: String in patterns:
			var fragments: PackedStringArray = []
			for fragment in pattern.split("%s"):
				var escaped := fragment
				for symbol in ["\\", ".", "^", "$", "*", "+", "?", "{", "}", "[", "]", "|", "(", ")"]:
					escaped = escaped.replace(symbol, "\\" + symbol)
				fragments.append(escaped)
			var regex := RegEx.new()
			if regex.compile("(?s)^" + "(.+?)".join(fragments) + "$") == OK:
				_templates.append({"regex": regex, "target": patterns[pattern]})

func _get_message(source: StringName, _context: StringName) -> StringName:
	var text := String(source)
	if _preferred.has(text):
		return StringName(_preferred[text])
	if text.length() < 150 and _preferred.has(text.capitalize()):
		return StringName(_preferred[text.capitalize()])
	if _messages.has(text):
		return StringName(_messages[text])
	if _cache.has(text):
		return StringName(_cache[text])
	var result := ""
	if text.contains("\n") and _normalized.has(_normalize(text)):
		var columns := 0
		for line in text.split("\n"):
			columns = maxi(columns, line.length())
		result = _wrap(String(_normalized[_normalize(text)]), maxi(columns, 25))
	if result.is_empty():
		result = _dynamic(text)
	if result.is_empty() and TranslationServer.has_domain(&"godot.editor"):
		var native := String(TranslationServer.get_or_add_domain(&"godot.editor").translate(source))
		if native != text:
			result = native
	_cache[text] = result
	return StringName(result)

func _dynamic(text: String) -> String:
	# Enumerações qualificadas (Classe.Enum) também são identificadores válidos.
	for prefix: String in ["Switch on ", "Switch On "]:
		if text.begins_with(prefix):
			return "Escolher conforme " + caption(text.trim_prefix(prefix))
	for template in _templates:
		var match_result: RegExMatch = template.regex.search(text)
		if match_result:
			var arguments: Array = []
			for index in range(1, match_result.get_group_count() + 1):
				arguments.append(match_result.get_string(index))
			return String(template.target) % arguments
	if text.contains("\n\n"):
		var paragraphs: PackedStringArray = []
		for paragraph in text.split("\n\n"):
			paragraphs.append(caption(paragraph))
		var combined := "\n\n".join(paragraphs)
		if combined != text:
			return combined
	# Prefixos visuais conhecidos. O trecho que identifica a classe/função é preservado.
	for pair in [
		["Extends ", "Herda de "], ["Change Type: ", "Alterar tipo: "],
		["Emit Signal ", "Emitir sinal "], ["Call Function ", "Chamar função "],
		["Get ", "Obter "], ["Set ", "Definir "], ["Make ", "Compor "],
		["Break ", "Decompor "], ["Function ", "Função "],
		["Property ", "Propriedade "], ["Variable ", "Variável "],
		["About ", "Sobre "], ["Parent: ", "Classe base: "],
		["Switch on ", "Escolher conforme "], ["Switch On ", "Escolher conforme "],
		["Break Pin Link to ", "Desconectar pino de "],
		["Straighten Connection to ", "Alinhar conexão com "],
		["Jump to ", "Ir para "], ["Hint:\n", "Dica:\n"]]:
		if text.begins_with(pair[0]) and text.length() > pair[0].length():
			var rest := text.substr(pair[0].length())
			# Não criar rótulos mistos como 'Obter Open Error'.
			if _messages.has(rest) or ClassDB.class_exists(rest) or rest.contains("_"):
				return pair[1] + String(_messages.get(rest, rest))
	if text.ends_with(" Event"):
		var event := text.trim_suffix(" Event")
		if _messages.has(event):
			return "Evento: " + String(_messages[event])
	if text.begins_with("Use "):
		for pair in [
			[" to insert a reroute node on the connection.", " para inserir um nó de redirecionamento na conexão."],
			[" to remove the reroute and disconnect both sides.", " para remover o redirecionamento e desconectar os dois lados."],
			[" to dissolve the reroute and keep the connection.", " para remover o redirecionamento e manter a conexão."]]:
			if text.ends_with(pair[0]):
				return "Use " + text.trim_prefix("Use ").trim_suffix(pair[0]) + pair[1]
	return ""

func caption(text: String) -> String:
	var translated := String(_get_message(StringName(text), &""))
	return text if translated.is_empty() else translated

func search_key(text: String) -> String:
	var result := text.to_lower().replace("_", " ").replace("-", " ")
	for pair in [["áàâãä", "a"], ["éèêë", "e"], ["íìîï", "i"], ["óòôõö", "o"], ["úùûü", "u"], ["ç", "c"]]:
		for letter in pair[0]:
			result = result.replace(letter, pair[1])
	return _normalize(result)

func help_title(text: String) -> String:
	var parts := text.split(": ", true, 1)
	if parts.size() < 2:
		return caption(text)
	var categories: PackedStringArray = []
	for part in parts[0].split(" > "):
		categories.append(caption(part))
	return " > ".join(categories) + ": " + caption(parts[1])

func help_body(text: String) -> String:
	var exact := caption(text)
	if exact != text:
		return exact
	var templates := [
		["Returns the value of property '", "'", "Retorna o valor da propriedade '%s'."],
		["Set the value of property '", "'", "Define o valor da propriedade '%s'."],
		["Creates a new instance of '", "'.", "Cria uma instância de '%s'."],
		["Free the memory used by the '", "' instance.", "Libera a memória usada pela instância de '%s'."],
		["Creates an event callback '", "', called automatically by Godot's object lifecycle.", "Cria o evento '%s', chamado automaticamente durante o ciclo de vida do objeto na Godot."],
		["Performs a switch/match based on the input value for a '", "' enum.", "Escolhe o caminho de execução conforme o valor de entrada da enumeração '%s'."],
		["Calls the specified built-in Godot function '", "'.", "Chama a função interna '%s' da Godot."],
		["Calls the script function '", "'.", "Chama a função '%s' do script."],
		["Obtain a reference to the ", " singleton.", "Obtém uma referência à instância única %s."],
		["Get a reference to the project autoload ", ".", "Obtém uma referência ao carregamento automático %s do projeto."],
		["Get the value of the variable '", "' in the orchestration.", "Obtém o valor da variável '%s' no script visual."],
		["Sets the value of the variable '", "' in the orchestration.", "Define o valor da variável '%s' no script visual."]]
	var paragraphs: PackedStringArray = []
	for paragraph in text.split("\n\n"):
		var localized := caption(paragraph)
		if localized == paragraph:
			for pattern in templates:
				if paragraph.begins_with(pattern[0]) and paragraph.ends_with(pattern[1]):
					localized = pattern[2] % paragraph.trim_prefix(pattern[0]).trim_suffix(pattern[1])
					break
		paragraphs.append(localized)
	return "\n\n".join(paragraphs)

func _normalize(text: String) -> String:
	return " ".join(text.replace("\n", " ").replace("\r", " ").split(" ", false))

func _wrap(text: String, columns: int) -> String:
	var lines: PackedStringArray = []
	for paragraph in text.split("\n"):
		var line := ""
		for word in paragraph.split(" ", false):
			if not line.is_empty() and line.length() + 1 + word.length() > columns:
				lines.append(line)
				line = ""
			line += (" " if not line.is_empty() else "") + word
		lines.append(line)
	return "\n".join(lines)
