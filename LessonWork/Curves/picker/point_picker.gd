class_name PointPicker extends Node

@export var picker_gui : PickerGUI;
@export var abstract_line_drawer : AbstractLineDrawer;

var dragged : Node = null
var weights : Array[float] = []

var curve_types : Array = [Lagrange, Bezier, BSpline, RationalBezier, RationalBSpline]
var curve_type : int = 0

var drawable_points : Array[Vector3] = []
var basis_list : Array[Basis] = []

func _ready():
	# clear points
	self.picker_gui.reset_button.pressed.connect(func ():
		self.picker_gui.lengthLabel.text = "Length: %.2f" % 0
		
		for child in get_children():
			child.queue_free()

		self.abstract_line_drawer.clear_points()
		
		for child in self.picker_gui.weight_container.get_children():
			child.queue_free()
	)
	
	# change curve type
	for button in picker_gui.button_group.get_buttons():
		button.pressed.connect(func ():
			self.curve_type = picker_gui.button_group.get_buttons().find(picker_gui.button_group.get_pressed_button())
			
			if self.curve_type > 2:
				picker_gui.weight_panel.show()
			else:
				picker_gui.weight_panel.hide()
			
			draw_current_curve()
		)
	self.picker_gui.division_slider.value_changed.connect(draw_current_curve)

func get_control_points() -> Array[Vector3]:
	var control_points : Array[Vector3] = []	
	for child in get_children() as Array[Node]:
		control_points.push_back(Vector3(child.position.x, child.position.y, 0))
		
	return control_points

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			for child in get_children() as Array[Node]:
				var diff = (get_viewport().get_mouse_position() - child.position).length()
				if diff < 15:
					dragged = child
					return
		
			var sprite : Sprite2D = Sprite2D.new()
			sprite.position = get_viewport().get_mouse_position()
			sprite.scale = Vector2(0.1, 0.1)
			sprite.texture = load("res://icon.svg")
			add_child(sprite)
			
			self.add_weight_input()
			self.draw_current_curve()

		if event.is_released():
			if dragged != null:
				dragged = null
				
				self.draw_current_curve()

	if event is InputEventMouseMotion:
		if dragged != null:
			dragged.position = get_viewport().get_mouse_position()
			
			self.draw_current_curve()

func draw_current_curve(division : int = 50) -> void:	
	if get_children().size() < 2:
		picker_gui.length_label.text = "Length: %.2f" % 0
		return
		
	self.abstract_line_drawer.clear_points()
		
	var control_points : Array[Vector3] = get_control_points()
	
	var current_curve : AbstractCurveGenerator = (self.curve_types[self.curve_type].new(control_points) as AbstractCurveGenerator)
	self.weights = self.get_weights()
	current_curve.set_weights(self.weights)
	self.drawable_points = current_curve.generate_drawable_points(picker_gui.division_slider.value)
	self.generate_triad()
	
	var length : float = 0
		
	if self.drawable_points.size() > 0:
		abstract_line_drawer.draw_points(self.drawable_points)
		length = abstract_line_drawer.get_length()

	picker_gui.length_label.text = "Length: %.2f" % length

func get_weights() -> Array[float]:
	var weights : Array[float] = []
	
	for child in picker_gui.weight_container.get_children() as Array[Node]:
		var line_edit : LineEdit = child.get_child(1)
		weights.push_back(line_edit.text.to_int())
		
	return weights

func add_weight_input() -> void:
	if picker_gui.weight_container.get_children().size() < get_children().size():
		var hbox : HBoxContainer = HBoxContainer.new()
		var label : Label = Label.new()
		label.text = "W%d" % (picker_gui.weight_container.get_children().size() + 1)
		var textEdit : LineEdit = LineEdit.new()
		textEdit.text = "1.0"
		textEdit.text_changed.connect(func(new_text : String):
			var weight_index = 0
					
			for weight_node_index in picker_gui.weight_container.get_children().size():
				if picker_gui.weight_container.get_child(weight_node_index).get_child(1) == textEdit:
					weight_index = weight_node_index
			
			if new_text.length() == 0:
				textEdit.text = "1.0"
				weights[weight_index] = 1.0
				self.draw_current_curve()
			elif not new_text.is_valid_float():							
				textEdit.text = str(weights[weight_index])		
			else:
				weights[weight_index] = new_text.to_float() if not abs(new_text.to_float()) < 0.01  else 1.0
				self.draw_current_curve()
		)
		
		textEdit.text
		
		hbox.add_child(label)
		hbox.add_child(textEdit)
		hbox.set_position(Vector2(15, 15 + picker_gui.weight_container.get_children().size() * 40))
		
		picker_gui.weight_container.add_child(hbox)
		
func generate_triad():	
	basis_list.clear()
	basis_list.push_back(Basis())
	basis_list.push_back(Basis())
	
	var previous_tangent = drawable_points[1] - drawable_points[0]
	
	if drawable_points.size() > 2:
		for index in range(2, drawable_points.size()):
			var current_tangent : Vector3 = (drawable_points[index] - drawable_points[index - 1]).normalized()			
			var tangent_diff : Vector3 = current_tangent - previous_tangent
			var current_binormal : Vector3 = current_tangent.cross(tangent_diff).normalized()			
			var current_normal : Vector3 = current_binormal.cross(current_tangent).normalized()			
			
			basis_list.push_back(Basis(current_tangent, current_normal, current_binormal))
			
			previous_tangent = current_tangent

func get_basis_list() -> Array[Basis]:
	return basis_list

func get_point_list() -> Array[Vector3]:
	return drawable_points
