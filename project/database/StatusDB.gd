class_name StatusDB

const STATUSES = {
   "arcane_aegis": {
	"title_name": "ST_ARCANE_AEGIS_TITLE",
	"description": "ST_ARCANE_AEGIS_DESC",
	"image": preload("res://assets/images/status/arcane_aegis.png"),
	"intent_title": "ST_ARCANE_AEGIS_INTENT"
	},
   "avenge": {
	"title_name": "ST_AVENGE_TITLE",
	"description": "ST_AVENGE_DESC",
	"image": preload("res://assets/images/status/avenge.png"),
	"intent_title": "ST_AVENGE_INTENT"
	},
   "burning": {
	"title_name": "ST_BURNING_TITLE",
	"description": "ST_BURNING_DESC",
	"image": preload("res://assets/images/status/burning.png"),
	"intent_title": "ST_BURNING_INTENT"
	},
   "concentration": {
	"title_name": "ST_CONCENTRATION_TITLE",
	"description": "ST_CONCENTRATION_DESC",
	"image": preload("res://assets/images/status/concentration.png"),
	"intent_title": "ST_CONCENTRATION_INTENT"
	},
   "confusion": {
	"title_name": "ST_CONFUSION_TITLE",
	"description": "ST_CONFUSION_DESC",
	"image": preload("res://assets/images/status/confusion.png"),
	"intent_title": "ST_CONFUSION_INTENT"
	},
   "curse": {
	"title_name": "ST_CURSE_TITLE",
	"description": "ST_CURSE_DESC",
	"image": preload("res://assets/images/status/curse.png"),
	"intent_title": "ST_CURSE_INTENT"
	},
   "deep_wound": {
	"title_name": "ST_DEEP_WOUND_TITLE",
	"description": "ST_DEEP_WOUND_DESC",
	"image": preload("res://assets/images/status/deep_wound.png"),
	"intent_title": "ST_DEEP_WOUND_INTENT"
	},
   "deviation": {
	"title_name": "ST_DEVIATION_TITLE",
	"description": "ST_DEVIATION_DESC",
	"image": preload("res://assets/images/status/deviation.png"),
	"intent_title": "ST_DEVIATION_INTENT"
	},
   "divine_protection": {
	"title_name": "ST_DIVINE_PROTECTION_TITLE",
	"description": "ST_DIVINE_PROTECTION_DESC",
	"image": preload("res://assets/images/status/divine_protection.png"),
	"intent_title": "ST_DIVINE_PROTECTION_INTENT"
	},
   "dodge": {
	"title_name": "ST_DODGE_TITLE",
	"description": "ST_DODGE_DESC",
	"image": preload("res://assets/images/status/dodge.png"),
	"intent_title": "ST_DODGE_INTENT"
	},
   "enrage": {
	"title_name": "ST_ENRAGE_TITLE",
	"description": "ST_ENRAGE_DESC",
	"image": preload("res://assets/images/status/enrage.png"),
	"intent_title": "ST_ENRAGE_INTENT"
	},
   "evasion": {
	"title_name": "ST_EVASION_TITLE",
	"description": "ST_EVASION_DESC",
	"image": preload("res://assets/images/status/evasion.png"),
	"intent_title": "ST_EVASION_INTENT"
	},
   "freeze": {
	"title_name": "ST_FREEZE_TITLE",
	"description": "ST_FREEZE_DESC",
	"image": preload("res://assets/images/status/freeze.png"),
	"intent_title": "ST_FREEZE_INTENT"
	},
   "hex": {
	"title_name": "ST_HEX_TITLE",
	"description": "ST_HEX_DESC",
	"image": preload("res://assets/images/status/hex.png"),
	"intent_title": "ST_HEX_INTENT"
	},
   "impending_doom": {
	"title_name": "ST_DOOM_TITLE",
	"description": "ST_DOOM_DESC",
	"image": preload("res://assets/images/status/impending_doom.png"),
	"intent_title": "ST_DOOM_INTENT"
	},
   "martyr": {
	"title_name": "ST_MARTYR_TITLE",
	"description": "ST_MARTYR_DESC",
	"image": preload("res://assets/images/status/martyr.png"),
	"intent_title": "ST_MARTYR_INTENT"
	},
   "minion": {
	"title_name": "ST_MINION_TITLE",
	"description": "ST_MINION_DESC",
	"image": preload("res://assets/images/status/minion.png"),
	"intent_title": "ST_MINION_INTENT"
	},
   "perm_strength": {
	"title_name": "ST_PERM_STRENGTH_TITLE",
	"description": "ST_PERM_STRENGTH_DESC",
	"image": preload("res://assets/images/status/perm_strength.png"),
	"intent_title": "ST_PERM_STRENGTH_INTENT"
	},
   "poison": {
	"title_name": "ST_POISON_TITLE",
	"description": "ST_POISON_DESC",
	"image": preload("res://assets/images/status/poison.png"),
	"intent_title": "ST_POISON_INTENT"
	},
   "poison_immunity": {
	"title_name": "ST_POISON_IMU_TITLE",
	"description": "ST_POISON_IMU_DESC",
	"image": preload("res://assets/images/status/poison_immunity.png"),
	"intent_title": "ST_POISON_IMU_INTENT"
	},
   "restrain": {
	"title_name": "ST_RESTRAIN_TITLE",
	"description": "ST_RESTRAIN_DESC",
	"image": preload("res://assets/images/status/restrain.png"),
	"intent_title": "ST_RESTRAIN_INTENT"
	},
   "restrict_major": {
	"title_name": "ST_MAJOR_RESTRICT_TITLE",
	"description": "ST_MAJOR_RESTRICT_DESC",
	"image": preload("res://assets/images/status/restrict_major.png"),
	"intent_title": "ST_MAJOR_RESTRICT_INTENT"
	},
   "restrict_minor": {
	"title_name": "ST_MINOR_RESTRICT_TITLE",
	"description": "ST_MINOR_RESTRICT_DESC",
	"image": preload("res://assets/images/status/restrict_minor.png"),
	"intent_title": "ST_MINOR_RESTRICT_INTENT"
	},
   "retaliate": {
	"title_name": "ST_RETALIATE_TITLE",
	"description": "ST_RETALIATE_DESC",
	"image": preload("res://assets/images/status/retaliate.png"),
	"intent_title": "ST_RETALIATE_INTENT"
	},
   "revenge": {
	"title_name": "ST_REVENGE_TITLE",
	"description": "ST_REVENGE_DESC",
	"image": preload("res://assets/images/status/revenge.png"),
	"intent_title": "ST_REVENGE_INTENT"
	},
   "soulbind": {
	"title_name": "ST_SOULBIND_TITLE",
	"description": "ST_SOULBIND_DESC",
	"image": preload("res://assets/images/status/soulbind.png"),
	"intent_title": "ST_SOULBIND_INTENT"
	},
   "splitting": {
	"title_name": "ST_SPLITTING_TITLE",
	"description": "ST_SPLITTING_DESC",
	"image": preload("res://assets/images/status/splitting.png"),
	"intent_title": "ST_SPLITTING_INTENT"
	},
   "temp_strength": {
	"title_name": "ST_TEMP_STRENGTH_TITLE",
	"description": "ST_TEMP_STRENGTH_DESC",
	"image": preload("res://assets/images/status/temp_strength.png"),
	"intent_title": "ST_TEMP_STRENGTH_INTENT"
	},
   "time_bomb": {
	"title_name": "ST_TIME_BOMB_TITLE",
	"description": "ST_TIME_BOMB_DESC",
	"image": preload("res://assets/images/status/time_bomb.png"),
	"intent_title": "ST_TIME_BOMB_INTENT"
	},
   "tough": {
	"title_name": "ST_TOUGH_TITLE",
	"description": "ST_TOUGH_DESC",
	"image": preload("res://assets/images/status/tough.png"),
	"intent_title": "ST_TOUGH_INTENT"
	},
   "weakness": {
	"title_name": "ST_WEAK_TITLE",
	"description": "ST_WEAK_DESC",
	"image": preload("res://assets/images/status/weakness.png"),
	"intent_title": "ST_WEAK_INTENT"
	},
}

static func get_all_status() -> Dictionary:
	return STATUSES

static func get_from_name(name: String) -> Dictionary:
	if STATUSES.has(name):
		return STATUSES[name]
	else:
		push_error("Given type of status doesn't exist: " + str(name))
		assert(false)
		return {}
