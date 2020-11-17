extends Sprite

enum ObjectType {BASIC, ITEM, CHECKPOINT, ENEMY}

export var dialogs = PoolStringArray()
export(String) var key
export(ObjectType) var type
