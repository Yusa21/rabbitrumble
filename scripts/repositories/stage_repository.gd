extends Node
# Singleton that uses a separate resource file for stage management

# Preload the collection resource (you'll create this as a .tres file)
var stage_collection: StageCollection = preload("res://resources/stage_collection.tres")

func _ready() -> void:
    print("StageRepository singleton loaded with %d stages" % stage_collection.stages.size())

# Returns the stage data by ID, or null if not found
func load_stage_data_by_id(id: String):
    var stage = stage_collection.get_stage_by_id(id)
    if stage == null:
        push_error("Stage not found: " + id)
    return stage

# Get all available stage IDs
func get_all_stage_ids() -> Array[String]:
    return stage_collection.get_all_ids()

# Check if a stage exists
func has_stage(id: String) -> bool:
    return stage_collection.get_stage_by_id(id) != null

# Get all stages as array
func get_all_stages() -> Array:
    return stage_collection.stages.duplicate()