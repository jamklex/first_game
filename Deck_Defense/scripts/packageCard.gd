extends Control

class_name PackageCard

var card:Control
var afterAnimationDoneFunctionHolder:Control
var afterAnimationDoneFunction:String
# Called when the node enters the scene tree for the first time.
func _ready():
	card = get_node("Card") as Control
	custom_minimum_size = card.custom_minimum_size


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func setVisibility(newVisibility:bool):
	card.visible = newVisibility
	
	
func setOnAnimationFinished(objectWithFunction, functionName):
	afterAnimationDoneFunctionHolder = objectWithFunction
	afterAnimationDoneFunction = functionName
	
	
func scaleCardToZero():
	card.scale = Vector2(0,0)


func playAnimation():
	var animationPlayer = $AnimationPlayer
	animationPlayer.play("packageCard/reveal")


func _on_animation_player_animation_finished(anim_name):
	if afterAnimationDoneFunctionHolder:
		afterAnimationDoneFunctionHolder.call(afterAnimationDoneFunction)
