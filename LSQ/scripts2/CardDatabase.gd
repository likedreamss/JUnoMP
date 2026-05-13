#4颜色，功能（英文GO/TRICK）,name名字,编号
extends Node
static var CARDS = {}

const ACARDS = {
	"前进1格_L" : ["LAND","GO","前进1格","前进1格_L",],
	"前进2格_l" : ["LAND","GO","前进2格","前进2格_L",],
	"前进3格_L" : ["LAND","GO","前进3格","前进3格_L",],
	
	"前进1格_G" : ["GRASS","GO","前进1格","前进1格_G",],
	"前进2格_G" : ["GRASS","GO","前进2格","前进2格_G",],
	"前进3格_G" : ["GRASS","GO","前进3格","前进3格_G",],
	
	"前进1格_P" : ["PINK","GO","前进1格","前进1格_P",],
	"前进2格_P" : ["PINK","GO","前进2格","前进2格_P",],
	"前进3格_P" : ["PINK","GO","前进3格","前进3格_P",],
	
	"前进1格_R" : ["RIVER","GO","前进1格","前进1格_R"],
	"前进2格_R" : ["RIVER","GO","前进2格","前进2格_R"],
	"前进3格_R" : ["RIVER","GO","前进3格","前进3格_R"],
	
	"前进1格_U" : ["UNIVERSAL","GO","前进1格","前进1格_U"],
	"前进2格_U" : ["UNIVERSAL","GO","前进2格","前进2格_U"],
	"前进3格_U" : ["UNIVERSAL","GO","前进3格","前进3格_U"],
	
	
	
	"无中生有" : ["UNIVERSAL","TRICK","无中生有","无中生有"],
	
	"重铸_U" : ["UNIVERSAL","TRICK","重铸","重铸_U"],
	"重铸_L" : ["LAND","TRICK","重铸","重铸_L"],
	"重铸_G" : ["GRASS","TRICK","重铸","重铸_G"],
	"重铸_P" : ["PINK","TRICK","重铸","重铸_P"],
	"重铸_R" : ["RIVER","TRICK","重铸","重铸_R"],
	
	
	"化险为夷" : ["UNIVERSAL","TRICK","化险为夷","化险为夷"],
	
	
	"乾坤重置" : ["UNIVERSAL","TRICK","乾坤重置","乾坤重置"],
	
	
	"点染一格_U" : ["UNIVERSAL","TRICK","点染一格","点染一格_U"],
	"点染一格_L" : ["LAND","TRICK","点染一格","点染一格_L"],
	"点染一格_G" : ["GRASS","TRICK","点染一格","点染一格_G"],
	"点染一格_P" : ["PINK","TRICK","点染一格","点染一格_P"],
	"点染一格_R" : ["RIVER","TRICK","点染一格","点染一格_R"],
	
	
	"障碍重重_U" : ["UNIVERSAL","TRICK","障碍重重","障碍重重_U"],
	"障碍重重_L" : ["LAND","TRICK","障碍重重","障碍重重_L"],
	"障碍重重_G" : ["GRASS","TRICK","障碍重重","障碍重重_G"],
	"障碍重重_P" : ["PINK","TRICK","障碍重重","障碍重重_P"],
	"障碍重重_R" : ["RIVER","TRICK","障碍重重","障碍重重_R"],
	
	
	
	"原地待命_L" : ["LAND","TRICK","原地待命","原地待命_L"],
	"原地待命_G" : ["GRASS","TRICK","原地待命","原地待命_G"],
	"原地待命_P" : ["PINK","TRICK","原地待命","原地待命_P"],
	"原地待命_R" : ["RIVER","TRICK","原地待命","原地待命_R"],


	"束手待毙_L" : ["LAND","TRICK","束手待毙","束手待毙_L"],
	"束手待毙_G" : ["GRASS","TRICK","束手待毙","束手待毙_G"],
	"束手待毙_P" : ["PINK","TRICK","束手待毙","束手待毙_P"],
	"束手待毙_R" : ["RIVER","TRICK","束手待毙","束手待毙_R"],
	
	
	"韬光养晦_L" : ["LAND","TRICK","韬光养晦","韬光养晦_L"],
	"韬光养晦_G" : ["GRASS","TRICK","韬光养晦","韬光养晦_G"],
	"韬光养晦_P" : ["PINK","TRICK","韬光养晦","韬光养晦_P"],
	"韬光养晦_R" : ["RIVER","TRICK","韬光养晦","韬光养晦_R"],
	
	
	"釜底抽薪_L" : ["LAND","TRICK","釜底抽薪","釜底抽薪_L"],
	"釜底抽薪_G" : ["GRASS","TRICK","釜底抽薪","釜底抽薪_G"],
	"釜底抽薪_P" : ["PINK","TRICK","釜底抽薪","釜底抽薪_P"],
	"釜底抽薪_R" : ["RIVER","TRICK","釜底抽薪","釜底抽薪_R"],


}
func _ready() -> void:
	var keys = ACARDS.keys()
	# 2. 打乱key顺序
	keys.shuffle()
	for k in keys:
		CARDS[k] = ACARDS[k]
