class_name GameConst extends RefCounted

#region Inputs
const INPUT_SELECT: String = "select"
const INPUT_START: String = "start"
const INPUT_MOVE_UP: String = "move_up"
const INPUT_MOVE_DOWN: String = "move_down"
const INPUT_MOVE_LEFT: String = "move_left"
const INPUT_MOVE_RIGHT: String = "move_right"
const INPUT_JUMP: String = "jump"
const INPUT_INTERACT: String = "interact"
#endregion
#region CollisionLayers
const COLLISION_WORLD: int = 0
const COLLISION_PLAYER: int = 1
const COLLISION_ENEMY: int = 2
const COLLISION_INTERACTABLE: int = 3
#endregion
