extends Node2D

var PORT = 8910
var avancee = false
var ip_list = []
var peer

var first_player = 1
var second_player = 0

@onready var all_ui = $CenterContainer

@onready var multi_mode_group = $"CenterContainer/VBoxContainer/multi mode"
@onready var serveur_group = $CenterContainer/VBoxContainer/serveur
@onready var avancee_group = $CenterContainer/VBoxContainer/avancee
@onready var join_group = $CenterContainer/VBoxContainer/serveur/VBoxContainer/code_join
@onready var avancee_details_group = $CenterContainer/VBoxContainer/avancee/VBoxContainer/avancee_details

@onready var host_button = $CenterContainer/VBoxContainer/serveur/VBoxContainer/host
@onready var line_edit_code = $CenterContainer/VBoxContainer/serveur/VBoxContainer/code_join/code
@onready var ip_line_edit = $CenterContainer/VBoxContainer/avancee/VBoxContainer/avancee_details/enter_ip
@onready var ip_display = $CenterContainer/VBoxContainer/avancee/VBoxContainer/avancee_details/ip
@onready var coop = $"CenterContainer/VBoxContainer/multi mode/VBoxContainer/HBoxContainer/coop"
@onready var duel = $"CenterContainer/VBoxContainer/multi mode/VBoxContainer/HBoxContainer/duel"

@export var player_number = 0
@export var poseur_scene : PackedScene

func _ready():
	peer = ENetMultiplayerPeer.new()
	ip_list = ipv4_adress()
	ip_display.text = "\n".join(ip_list)
	$refresh_ip.start(1)
	multiplayer.peer_connected.connect(player_joined)
	
func ipv4_adress():
	var ip_list_ = []
	for address in IP.get_local_addresses():
			if (address.split('.').size() == 4):
				ip_list_.append(address)
	return ip_list_

func _on_host_pressed():
	var address = ip_list[0]
	var code = address.right(address.length() - address.rfind(".") - 1)
	peer.create_server(PORT)
	if not avancee:
		peer.set_bind_ip(address)
		host_button.text = "CODE : "+code
	else:
		var written_ip = ip_line_edit.text
		if written_ip == "":
			peer.set_bind_ip(ip_list[0])
			host_button.text = ip_list[0]
		else:
			peer.set_bind_ip(written_ip)
			host_button.text = written_ip
	
	player_number=1
	avancee_group.visible = false
	multi_mode_group.visible = false
	join_group.visible = false
	host_button.disabled = true
	
	multiplayer.multiplayer_peer = peer

func _on_join_pressed():
	var address = ip_list[0]
	var code = line_edit_code.text
	address = address.left(address.rfind(".") + 1) + str(code)
	if not avancee:
		peer.create_client(address,PORT)

	else:
		var written_ip = ip_line_edit.text
		if written_ip == "":
			peer.create_client(ip_list[0], PORT)
		else:
			peer.create_client(written_ip, PORT)
	player_number=1
	all_ui.visible = false
	multiplayer.multiplayer_peer = peer

func player_joined(id):
	if id != 1:
		Event.second_player = id
	player_number+=1
	start_game()

func _on_avancee_button_down():
	avancee = not avancee
	line_edit_code.visible = not avancee
	avancee_details_group.visible = avancee
	
func start_game():
	Event.current_peer = peer
	Event.current_player = peer.get_unique_id()
	if peer.get_unique_id() != 1:
		Event.second_player = peer.get_unique_id()
	get_tree().change_scene_to_file("res://duel/duel.tscn")

func _on_duel_pressed():
	if duel.button_pressed == true:
		coop.button_pressed = false
	else:
		coop.button_pressed = true

func _on_coop_pressed():
	if coop.button_pressed == true:
		duel.button_pressed = false
	else:
		duel.button_pressed = true

func _on_back_pressed():
	peer.close()
	get_tree().change_scene_to_file("res://obj/menu.tscn")

func _on_refresh_ip_timeout():
	ip_list = ipv4_adress()
	ip_display.text = "\n".join(ip_list)
	$refresh_ip.start(1)
