extends TextureButton

export var text = "Button"

onready var label = get_node("Label")

func _ready():
	label.set_text(text)
