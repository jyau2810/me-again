extends RefCounted
class_name MeSaveCodec

## Versioned JSON envelope for the six-key global state.
##
## Runtime-only data never enters the `state` object. Unknown keys and malformed
## values are removed by [MeGameSchema] on decode and before every encode.

const Schema = preload("res://scripts/domain/game_schema.gd")
const CURRENT_VERSION := 1


static func encode_state(state: Dictionary) -> String:
	var payload := {
		"saveVersion": CURRENT_VERSION,
		"state": Schema.sanitize_state(state),
	}
	return JSON.stringify(payload, "\t", true)


static func decode_text(text: String) -> Dictionary:
	if text.strip_edges().is_empty():
		return _failure("save file is empty")

	var json := JSON.new()
	var parse_error := json.parse(text)
	if parse_error != OK:
		return _failure(
			"invalid JSON at line %d: %s" % [json.get_error_line(), json.get_error_message()]
		)

	var payload: Variant = json.data
	if typeof(payload) != TYPE_DICTIONARY:
		return _failure("save root must be an object")

	var payload_dict: Dictionary = payload
	var raw_state: Variant
	var requires_rewrite := false

	if payload_dict.has("saveVersion"):
		var raw_version: Variant = payload_dict.get("saveVersion")
		if typeof(raw_version) != TYPE_INT and typeof(raw_version) != TYPE_FLOAT:
			return _failure("saveVersion must be numeric")
		var version := int(raw_version)
		if version != CURRENT_VERSION:
			return _failure("unsupported saveVersion: %d" % version)
		if not payload_dict.has("state"):
			return _failure("versioned save is missing state")
		raw_state = payload_dict.get("state")
	else:
		# Pre-version flat saves are accepted once and rewritten to the envelope.
		raw_state = payload_dict
		requires_rewrite = true

	if typeof(raw_state) != TYPE_DICTIONARY:
		return _failure("state must be an object")

	var sanitized_state: Dictionary = Schema.sanitize_state(raw_state)
	if raw_state != sanitized_state:
		requires_rewrite = true

	return {
		"ok": true,
		"state": sanitized_state,
		"error": "",
		"requiresRewrite": requires_rewrite,
	}


static func _failure(message: String) -> Dictionary:
	return {
		"ok": false,
		"state": Schema.default_state(),
		"error": message,
		"requiresRewrite": false,
	}
