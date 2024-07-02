class_name Playable

extends Node

var rng = RandomNumberGenerator.new()

var path	:	String
#var name	:	String
var album	:	String
var artist	:	String
var metadata:	Array = Array()
var isDir	:	bool = false
var volume	:	int = 0#db
var children:	Array = Array()

var weight = 1
var mute	:	bool = false
var solo	:	bool = false

func _init(_path: String):
	path = _path

func _to_string():
	return path

func get_weight():
	if mute:
		return 0
	return weight

func weightedRandomChild():
	var totalWeight = 0
	var soloWeight = 0
	var soloChildren = Array()
	for child in children:
		if child.solo:
			print("Solo", child.name)
			soloWeight += child.weight
			soloChildren.append(child)
		if child.mute:
			continue
		totalWeight += child.weight
	var randomWeight = rng.randf()
	if soloChildren.size() > 0:
		randomWeight *= soloWeight
		for child in soloChildren:
			randomWeight -= child.weight
			if randomWeight <= 0:
				return child
	randomWeight *= totalWeight
	for child in children:
		if child.mute:
			continue
		randomWeight -= child.weight
		if randomWeight <= 0:
			return child

func ChooseSong():
	x.volume += volume
	if isDir:
		#print("Dir: " + name)
		var child = weightedRandomChild()
		#print("Child: " + child.name)
		if child.isDir:
			return child.ChooseSong()
		else:
			#print("Returning:" + child.path)
			x.volume += child.volume
			return child
	else:
		#print("Song: " + name)
		return self

# Saving Logic
func Pack():
	var data = {
		"name"	:	name,
		"album"	:	album,
		"artist":	artist,
		"metadata":	metadata,
		"path"	:	path,
		"isDir"	:	isDir,
		"weight":	weight,
		"volume":	volume,
		"mute"	:	mute,
		"solo"	:	solo,
	}
	if isDir:
		data["children"] = []
		for child in children:
			data["children"].append(child.Pack())
	return data

func UnPack(data : Dictionary):
	for key in data.keys():
		match key:
			"name":
				name = data[key]
			"album":
				album = data[key]
			"artist":
				artist = data[key]
			"metadata":
				metadata = data[key]
			"path":
				path = data[key]
			"isDir":
				isDir = data[key]
			"weight":
				weight = data[key]
			"volume":
				volume = data[key]
			"mute":
				mute = data[key]
			"solo":
				solo = data[key]
			"children":
				if isDir:
					for item in data["children"]:
						print("Looking for ", item["name"])
						var matchingChild = children.filter(func(input : Playable): return item["path"] == input.path).front()
						if matchingChild != null:
							print(item["name"], " found")
							matchingChild.UnPack(item)
