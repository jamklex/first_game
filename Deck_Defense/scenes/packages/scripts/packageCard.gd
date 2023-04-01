extends Control

class_name PackageCard

var card:Control
var afterRevealDoneFunctionHolder:Control
var afterRevealDoneFunction:String
var afterShowDoneFunctionHolder:Control
var afterShowDoneFunction:String
var animationPlayer:AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	animationPlayer = $AnimationPlayer
	card = get_node("back") as Control
	custom_minimum_size = card.custom_minimum_size


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func setVisibility(newVisibility:bool):
	card.visible = newVisibility
	
	
func setOnRevealDoneFinished(objectWithFunction, functionName):
	afterRevealDoneFunctionHolder = objectWithFunction
	afterRevealDoneFunction = functionName
	
	
func setOnShowDoneFinished(objectWithFunction, functionName):
	afterShowDoneFunctionHolder = objectWithFunction
	afterShowDoneFunction = functionName
	
	
func scaleCardToZero():
	card.scale = Vector2(0,0)


func playShowAnimation():
	animationPlayer.play("packageCard/show")
	

func playRevealAnimation():
	animationPlayer.play("packageCard/reveal")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "packageCard/reveal" and afterRevealDoneFunctionHolder:
		afterRevealDoneFunctionHolder.call(afterRevealDoneFunction)
	if anim_name == "packageCard/show" and afterShowDoneFunctionHolder:
		afterShowDoneFunctionHolder.call(afterShowDoneFunction)
