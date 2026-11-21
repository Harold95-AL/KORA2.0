extends Area2D
@export var story_id: String = ""

func _ready() -> void:
	body_entered.connect(func(body: Node2D) -> void:
		if body is KoraPlayer:
			NarrativeManager.trigger(story_id))

