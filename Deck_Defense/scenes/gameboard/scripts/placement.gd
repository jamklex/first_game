class_name Placement

var card: Card
var spot: int

static func of(card: Card, spot: int):
	var placement = Placement.new()
	placement.card = card
	placement.spot = spot
	return placement
