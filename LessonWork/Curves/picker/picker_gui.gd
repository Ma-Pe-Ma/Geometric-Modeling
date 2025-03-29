class_name PickerGUI extends Control

@export var gui_panel : Control;
@export var weight_panel : Control;
@export var button_group : ButtonGroup;
@export var reset_button : Button;
@export var length_label : Label;
@export var weight_container : VBoxContainer;
@export var division_slider = Slider;
@export var division_label = Label

func _ready() -> void:
	self.division_slider.value_changed.connect(func(value : int):
		division_label.text = str(value)
	)
	
	self.division_slider.value_changed.emit(division_slider.value)
