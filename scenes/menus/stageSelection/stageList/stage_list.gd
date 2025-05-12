extends VBoxContainer

var event_bus
var stage_entry
@onready var template_stage_entry = get_node("%TemplateStage")

func _ready() -> void:
    # Hide the template as we don't want it visible
    if template_stage_entry:
        template_stage_entry.visible = false

func initialize(bus, unlocked_stages, completed_stages):
    event_bus = bus
    show_all_unlocked_stages(unlocked_stages, completed_stages)

func show_all_unlocked_stages(unlocked, completed):
    # Clear existing entries first (except the template)
    for child in get_children():
        if child != template_stage_entry and child.visible:
            child.queue_free()
    
    # Create a new instance for each unlocked stage
    for stage in unlocked:
        stage_entry = template_stage_entry.duplicate()
        stage_entry.visible = true
        
        # Important: Add the child to the scene tree before calling _ready
        add_child(stage_entry)
        
        # Allow the node to initialize its child references 
        await get_tree().process_frame
        
        # Check if this stage's ID is in the completed list
        var is_completed = completed.has(stage.id)
        
        # Initialize the stage entry with data
        stage_entry.initialize(
            str(stage.number),  # Convert to string in case it's a number
            stage.name,
            stage.difficulty,
            is_completed,
            stage  # Pass the entire stage data
        )
        
        # Connect the stage's custom signal to our event bus
        stage_entry.connect("stage_clicked", _on_stage_entry_clicked)

# Handle click from stage entry
func _on_stage_entry_clicked(stage_data):
    if event_bus:
        print("Forwarding stage clicked to event bus: ", stage_data.name)
        event_bus.emit_signal("stage_clicked", stage_data)
        
        # Connect signal for when stage is selected (if needed)
        stage_entry.connect("gui_input", _on_stage_selected.bind(stage))
        
        # Add the new stage entry to the container
        add_child(stage_entry)

# Remove the old click handler since we're now using signals
# func _on_stage_selected(event, stage):
#    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
#        if event_bus:
#            # Emit a signal through the event bus when a stage is selected
#            event_bus.emit_signal("stage_clicked", stage)