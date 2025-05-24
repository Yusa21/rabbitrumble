extends Resource
class_name StageCollection

# Simple approach - just an array of your stage resources
@export var stages: Array[StageData] = []

# Get stage by ID (assuming your StageData has an id property)
func get_stage_by_id(id: String) -> StageData:
    for stage in stages:
        if stage != null:
            # Adjust this based on how your StageData stores its ID
            if stage.has_method("get_id") and stage.get_id() == id:
                return stage
            elif "id" in stage and stage.id == id:
                return stage
    return null

# Get all stage IDs
func get_all_ids() -> Array[String]:
    var ids: Array[String] = []
    for stage in stages:
        if stage != null:
            if stage.has_method("get_id"):
                ids.append(stage.get_id())
            elif "id" in stage:
                ids.append(stage.id)
    return ids

# Add a new stage
func add_stage(stage_data: StageData) -> void:
    stages.append(stage_data)

# Remove stage by ID
func remove_stage_by_id(id: String) -> bool:
    for i in range(stages.size()):
        var stage = stages[i]
        if stage != null:
            var stage_id = ""
            if stage.has_method("get_id"):
                stage_id = stage.get_id()
            elif "id" in stage:
                stage_id = stage.id
            
            if stage_id == id:
                stages.remove_at(i)
                return true
    return false