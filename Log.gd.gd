extends Node

var toast_ui = null

func show(...args):

	var text = ""

	for i in args.size():

		text += str(args[i])

		if i < args.size() - 1:
			text += " "

	print(text)

	if toast_ui:
		toast_ui.show_toast(text)
