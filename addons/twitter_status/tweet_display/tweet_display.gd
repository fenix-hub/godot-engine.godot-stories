tool
extends WindowDialog

onready var avatar_texture : TextureRect = $Container/Tweet/User/Avatar
onready var preview_texture : TextureRect = $Container/Tweet/Preview
onready var user_lbl : LinkButton = $Container/Tweet/User/Data/HBoxContainer/Name
onready var text : RichTextLabel = $Container/Tweet/Text
onready var time_lbl : Label = $Container/Tweet/User/Data/HBoxContainer/Time
onready var username_lbl : Label = $Container/Tweet/User/Data/Username
onready var url : LinkButton = $Container/Tweet/User/Url

var current_tweet : Tweet
var display_size : Vector2 = get_rect().size

# Called when the node enters the scene tree for the first time.
func _ready():
	user_lbl.connect("pressed", self, "_on_user_pressed")
	url.connect("pressed", self, "_on_url_connected")

func display_tweet(tweet : Tweet):
	url.hide()
	current_tweet = tweet
	preview_texture.set_texture(tweet.preview_img)
	user_lbl.set_text(tweet.user)
	username_lbl.set_text(tweet.username)
	text.clear()
	text.append_bbcode(tweet.text)
	avatar_texture.set_texture(tweet.avatar_img)
	time_lbl.set_text(tweet.data.created_at)
	user_lbl.set_tooltip(tweet.user_url)
	if tweet.url != "" : url.show()
	url.set_tooltip(tweet.url)
	popup()

func _on_user_pressed():
	OS.shell_open(current_tweet.user_url)

func _on_url_connected():
	OS.shell_open(current_tweet.url)
