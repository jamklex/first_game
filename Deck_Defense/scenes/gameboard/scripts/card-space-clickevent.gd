extends HBoxContainer

func _ready():
	pass

func send_place_request(spot, event):
	if Util.is_mouse_click(event):
		Properties.selected_card_spot = spot

func _on_0_gui_input(event):
	send_place_request(0, event)

func _on_1_gui_input(event):
	send_place_request(1, event)

func _on_2_gui_input(event):
	send_place_request(2, event)

func _on_3_gui_input(event):
	send_place_request(3, event)

func _on_4_gui_input(event):
	send_place_request(4, event)

func _on_5_gui_input(event):
	send_place_request(5, event)

func _on_6_gui_input(event):
	send_place_request(6, event)

func _on_7_gui_input(event):
	send_place_request(7, event)

func _on_8_gui_input(event):
	send_place_request(8, event)

func _on_9_gui_input(event):
	send_place_request(9, event)
