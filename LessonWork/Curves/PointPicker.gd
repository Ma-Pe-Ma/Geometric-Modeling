extends Line2D

@export var guiPanel : Panel;
@export var weightPanel : Panel;
@export var buttonGroup : ButtonGroup;
@export var resetButton : Button;
@export var lengthLabel : Label;

var dragged : Node2D = null
var weightContainer : VBoxContainer;
var weights : Array[float] = []

var curveTypes : Array = [Lagrange, Bezier, BSpline, RationalBezier, RationalBSpline]
var curveType : int = 0

var drawablePoints : Array[Vector2] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	weightContainer = weightPanel.get_child(1).get_child(0)
	
	# clear points
	self.resetButton.pressed.connect(func ():
		lengthLabel.text = "Length: %.2f" % 0
		
		for child in get_children():
			child.queue_free()

		self.clear_points()
		
		for child in weightContainer.get_children():
			child.queue_free()
	)
	
	# change curve type
	for button in buttonGroup.get_buttons():
		button.pressed.connect(func ():
			curveType = buttonGroup.get_buttons().find(buttonGroup.get_pressed_button())
			
			if curveType > 2:
				weightPanel.show()
			else:
				weightPanel.hide()
			
			drawCurrentCurve()
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			for child in get_children() as Array[Node2D]:
				var diff = (get_viewport().get_mouse_position() - child.position).length()
				if diff < 15:
					dragged = child
					return
		
			var sprite : Sprite2D = Sprite2D.new()
			sprite.position = get_viewport().get_mouse_position()
			sprite.scale = Vector2(0.1, 0.1)
			sprite.texture = load("res://icon.svg")
			add_child(sprite)
			
			self.addWeightInput()
			self.drawCurrentCurve()

		if event.is_released():
			if dragged != null:
				dragged = null
				
				self.drawCurrentCurve()

	if event is InputEventMouseMotion:
		if dragged != null:
			dragged.position = get_viewport().get_mouse_position()
			
			self.drawCurrentCurve()

func drawCurrentCurve() -> void:	
	if get_children().size() < 2:
		lengthLabel.text = "Length: %.2f" % 0
		return
		
	self.clear_points()
		
	var controlPoints : Array[Vector2] = []	
	for child in get_children() as Array[Node2D]:
		controlPoints.push_back(child.position)
	
	var currentCurve : AbstractCurveGenerator = (self.curveTypes[self.curveType].new(controlPoints) as AbstractCurveGenerator)
	self.weights = self.getWeights()
	currentCurve.setWeights(self.weights)
	self.drawablePoints = currentCurve.generateDrawablePoints()
	
	var length : float = 0
	
	if self.drawablePoints.size() > 0:	
		self.add_point(self.drawablePoints[0])
		
		for index in range(1, self.drawablePoints.size()):
			length += (drawablePoints[index] - drawablePoints[index -1]).length()		
			self.add_point(drawablePoints[index])

	lengthLabel.text = "Length: %.2f" % length

func getWeights() -> Array[float]:
	var weights : Array[float] = []
	
	for child in weightContainer.get_children() as Array[Node2D]:
		var lineEdit : LineEdit = child.get_child(1)
		weights.push_back(lineEdit.text.to_int())
		
	return weights

func addWeightInput() -> void:
	if weightContainer.get_children().size() < get_children().size():
		var hbox : HBoxContainer = HBoxContainer.new()
		var label : Label = Label.new()
		label.text = "W%d" % (weightContainer.get_children().size() + 1)
		var textEdit : LineEdit = LineEdit.new()
		textEdit.text = "1.0"
		textEdit.text_changed.connect(func(new_text : String):
			var weightIndex = 0
					
			for weightNodeIndex in weightContainer.get_children().size():
				if weightContainer.get_child(weightNodeIndex).get_child(1) == textEdit:
					weightIndex = weightNodeIndex
			
			if new_text.length() == 0:
				textEdit.text = "1.0"
				weights[weightIndex] = 1.0
				self.drawCurrentCurve()
			elif not new_text.is_valid_float():							
				textEdit.text = str(weights[weightIndex])		
			else:
				weights[weightIndex] = new_text.to_float() if not abs(new_text.to_float()) < 0.01  else 1.0
				self.drawCurrentCurve()
		)
		
		textEdit.text
		
		hbox.add_child(label)
		hbox.add_child(textEdit)
		hbox.set_position(Vector2(15, 15 + weightContainer.get_children().size() * 40))
		
		weightContainer.add_child(hbox)
