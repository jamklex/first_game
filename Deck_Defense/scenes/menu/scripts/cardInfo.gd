extends Panel

class_name CardInfo

func setCardInfo(id:int, desc:String):
	var card = $MarginContainer/HBoxContainer/Card as Card
	card.initialize_from_id(id)
	var descLabel = $MarginContainer/HBoxContainer/desc
	descLabel.text = desc
