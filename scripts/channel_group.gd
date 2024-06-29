extends Channel

@export var folder: Texture
@export var folderOpen: Texture

func OnFolderToggled(toggled_on):
	$"MarginContainer/Controls/Child Margins".visible = toggled_on
	if toggled_on:
		$"MarginContainer/Controls/Weight Control/MarginContainer3/ExpandButton".icon = folderOpen
	else:
		$"MarginContainer/Controls/Weight Control/MarginContainer3/ExpandButton".icon = folder



