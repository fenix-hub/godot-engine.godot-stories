tool
extends VBoxContainer
class_name Tweet

signal selected(tweet)

onready var avatar_texture : TextureRect = $AvatarContainer/Avatar
onready var avatar_status : TextureRect = $AvatarContainer/Avatar/Status
onready var name_lbl : Label = $Name

var texture_off : StreamTexture = load("res://addons/twitter_status/resources/img/circle2_off.png")
var viewed : bool = false
var user : String = ""
var username : String = ""
var user_url : String = ""
var text : String = ""
var avatar_url : String = ""
var preview_url : String = ""
var data : Dictionary = {}
var preview_img : ImageTexture = null
var avatar_img : ImageTexture = null
var url : String = ""

func _ready():
	connect_signals()
	set_viewed(viewed)

func connect_signals():
	$Avatar.connect("request_completed", self, "_on_Avatar_request_completed")
	$Preview.connect("request_completed", self, "_on_Preview_request_completed")
	avatar_texture.connect("gui_input", self, "_on_Avatar_gui_input")

func create_tweet(tweet_data : Dictionary, tweet_user : Dictionary, tweet_media : Dictionary) -> void:
	set_data(tweet_data)
	set_user(tweet_user.name)
	set_username(tweet_user.username)
	set_tweet_text(tweet_data.text)
	set_avatar_url(tweet_user.profile_image_url)
	if not tweet_media.empty() : if tweet_media.preview_image_url != "": set_preview_url(tweet_media.preview_image_url)

func set_user(tweet_user : String) -> void:
	user = tweet_user

func set_username(tweet_username : String) -> void:
	username = "@%s" % tweet_username
	user_url = "https://twitter.com/%s" % tweet_username
	name_lbl.set_text(username)
	avatar_texture.set_tooltip(username)

func set_data(tweet_data : Dictionary) -> void:
	data = tweet_data

func set_tweet_text(tweet_text : String) -> void:
	var tweet_url : String = tweet_text.substr(tweet_text.find_last("https://t.co/"),23)
	if tweet_url != "" and tweet_text.ends_with(tweet_url[tweet_url.length()-1]):
		url = tweet_url
		text = tweet_text.replace(" %s" % url,"")
	else : text = tweet_text


func set_avatar_url(tweet_avatar_url : String) -> void:
	avatar_url = tweet_avatar_url
	$Avatar.request(avatar_url)

func set_preview_url(tweet_preview_url : String) -> void:
	preview_url = tweet_preview_url
	$Preview.request(preview_url)

func encode_buffer(image : Image, url : String, buffer : PoolByteArray) -> Image:
	match url.get_extension():
		"jpg":
			image.load_jpg_from_buffer(buffer)
		"jpeg":
			image.load_jpg_from_buffer(buffer)
		"png":
			image.load_png_from_buffer(buffer)
	return image

func _on_Avatar_request_completed(result : int, response_code : int, headers : Array, avatar : PoolByteArray):
	if result == 0:
		if response_code == 200:
			var image : Image = Image.new()
			image = encode_buffer(image, avatar_url, avatar)
			var texture : ImageTexture = ImageTexture.new()
			texture.create_from_image(image)
			avatar_img = texture
			avatar_texture.set_texture(texture)

func _on_Preview_request_completed(result : int, response_code : int, headers : Array, preview : PoolByteArray):
	if result == 0:
		if response_code == 200:
			var image : Image = Image.new()
			image = encode_buffer(image, preview_url, preview)
			var texture : ImageTexture = ImageTexture.new()
			texture.create_from_image(image)
			preview_img = texture

func set_viewed(is_viewed : bool):
	viewed = is_viewed
	if viewed: 
		avatar_status.set_texture(texture_off)
		avatar_status.set_material(null)

func _on_Avatar_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		set_viewed(true)
		emit_signal("selected", self)

