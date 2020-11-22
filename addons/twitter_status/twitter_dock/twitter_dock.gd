tool
extends Control

var plugin_path : String = ProjectSettings.globalize_path("user://").replace("app_userdata/"+ProjectSettings.get_setting('application/config/name')+"/","twitter")+"/"
var token_file : String = "token.dat"

onready var tweets_container : HBoxContainer = $Container/RecentTweets/TwitterStatus
onready var tweet_display : WindowDialog = $TweetDisplay
onready var settings_panel : WindowDialog = $SettingsPanel

var twitter_tweet : PackedScene = preload("res://addons/twitter_status/twitter_tweet/twitter_tweet.tscn")
var token : String = ""
var max_results : int = 30

func request_tweets():
	var tweet_fields : String = PoolStringArray(["source","attachments","author_id","created_at"]).join(",")
	var media_fields : String = PoolStringArray(["url","preview_image_url"]).join(",")
	var user_fields : String = PoolStringArray(["id","name","url","profile_image_url","username"]).join(",")
	var expansions : String = PoolStringArray(["author_id","attachments.media_keys"]).join(",")
	var endpoint : String = "https://api.twitter.com/2/tweets/search/recent?query=GodotEngine&max_results=%s&tweet.fields=%s&media.fields=%s&user.fields=%s&expansions=%s"%[max_results,tweet_fields, media_fields, user_fields, expansions]
	$HTTPRequest.request(endpoint,["Authorization: Bearer "+token],true,HTTPClient.METHOD_GET)

# Called when the node enters the scene tree for the first time.
func _ready():
	name = "Recent Tweets"
	connect_signals()
	load_token()
	request_tweets()

func connect_signals():
	$HTTPRequest.connect("request_completed", self, "_on_HTTPRequest_request_completed")
	$Container/Settings.connect("pressed", self, "_on_settings_pressed")
	settings_panel.get_node("Container/ButtonContainer/Close").connect("pressed", settings_panel, "hide")
	settings_panel.get_node("Container/ButtonContainer/Accept").connect("pressed", self, "_on_settings_confirmed")

func _on_HTTPRequest_request_completed(result_code, response_code, headers, body):
	assert(token != "", "No Twitter Auth token found.")
	for tweet_ in tweets_container.get_children(): if tweet_ is HBoxContainer: tweet_.free()
	var result : Dictionary = JSON.parse(body.get_string_from_utf8()).result
	var tweet_data : Array = result.data
	var tweet_users : Array = result.includes.users
	var tweet_media : Array = result.includes.media
	var tw_data : Dictionary
	var tw_media : Dictionary
	var tw_user : Dictionary
	for data in tweet_data:
		if data.text.begins_with("RT"): continue
		tw_data = data
		tw_user = {}
		tw_media = {}
		var user_id : String = data.author_id
		for user in tweet_users: 
			if user.id == user_id:
				tw_user = user
				for media in tweet_media:
					if data.keys().has("attachments") and data.attachments.keys().has("media_keys"):
						if media.media_key == data.attachments.media_keys[0] and "preview_image_url" in media.keys():
							tw_media = media
							continue
		var tweet : Tweet = twitter_tweet.instance()
		tweets_container.add_child(tweet)
		tweet.create_tweet(tw_data, tw_user, tw_media)
		tweet.connect("selected", self, "_on_tweet_selected")

func _on_tweet_selected(tweet : Tweet):
	tweet_display.display_tweet(tweet)


func _on_settings_pressed():
	settings_panel.get_node("Container/TokenContainer/Token").set_text(token)
	settings_panel.popup()

func _on_settings_confirmed():
	settings_panel.hide()
	var new_token : String = settings_panel.get_node("Container/TokenContainer/Token").get_text()
	token = new_token
	save_token(token)
	request_tweets()

func load_token():
	var directory : Directory = Directory.new()
	var file : File = File.new()
	if not directory.dir_exists(plugin_path):
		directory.make_dir_recursive(plugin_path)
	else:
		if directory.file_exists(plugin_path+token_file):
			file.open_encrypted_with_pass(plugin_path+token_file, File.READ, OS.get_unique_id())
			token = file.get_as_text()
		else:
			save_token("")

func save_token(_token : String):
	var file : File = File.new()
	file.open_encrypted_with_pass(plugin_path+token_file, File.WRITE, OS.get_unique_id())
	file.store_line(_token)
