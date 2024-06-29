class_name Playable

extends Node

var rng = RandomNumberGenerator.new()
var path: String
#var name: String
var isDir = false
var volume = 0
var children = Array()

var weight = 1
var mute: bool = false
var solo: bool = false

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
	if isDir:
		#print("Dir: " + name)
		var child = weightedRandomChild()
		#print("Child: " + child.name)
		if child.isDir:
			return child.ChooseSong()
		else:
			#print("Returning:" + child.path)
			return child
	else:
		#print("Song: " + name)
		return self

# Saving Logic
func Pack():
	var data = {
		"name": name,
		"path": path,
		"isDir": isDir,
		"weight": weight,
		"volume": volume,
		"mute": mute,
		"solo": solo,
	}
	if isDir:
		data["children"] = []
		for child in children:
			data["children"].append(child.Pack())
	return data

func UnPack(data):
	name	=	data["name"]
	print("Unpacking ", name)
	path	=	data["path"]
	isDir	=	data["isDir"]
	weight	=	data["weight"]
	volume	=	data["volume"]
	mute	=	data["mute"]
	solo	=	data["solo"]
	
	if isDir:
		for item in data["children"]:
			for child in children:
				if child.path == item["path"]:
					print(item["name"], " found")
					child.UnPack(item)
