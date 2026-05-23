#4颜色，功能（英文GO/TRICK）,name名字,编号
extends Node
static var CARDS = {}

const ACARDS = {
# 陆地 LAND (示例原样保留)
	"前进1格_L" : ["LAND","GO","前进1格","前进1格_L",],
	"前进1格_LS" : ["LAND","GO","前进1格","前进1格_LS",],
	"前进1格_LD" : ["LAND","GO","前进1格","前进1格_LD",],
	"前进1格_LF" : ["LAND","GO","前进1格","前进1格_LF",],
	"前进1格_LQ" : ["LAND","GO","前进1格","前进1格_LQ",],

	"前进2格_L" : ["LAND","GO","前进2格","前进2格_L",],
	"前进2格_LA" : ["LAND","GO","前进2格","前进2格_LA",],
	"前进2格_LS" : ["LAND","GO","前进2格","前进2格_LS",],
	"前进2格_LD" : ["LAND","GO","前进2格","前进2格_LD",],

	"前进3格_L" : ["LAND","GO","前进3格","前进3格_L",],
	"前进3格_LA" : ["LAND","GO","前进3格","前进3格_LA",],
	"前进3格_LS" : ["LAND","GO","前进3格","前进3格_LS",],

	# 草地 GRASS (统一格式)
	"前进1格_G" : ["GRASS","GO","前进1格","前进1格_G",],
	"前进1格_GA" : ["GRASS","GO","前进1格","前进1格_GA",],
	"前进1格_GS" : ["GRASS","GO","前进1格","前进1格_GS",],
	"前进1格_GD" : ["GRASS","GO","前进1格","前进1格_GD",],
	"前进1格_GF" : ["GRASS","GO","前进1格","前进1格_GF",],

	"前进2格_G" : ["GRASS","GO","前进2格","前进2格_G",],
	"前进2格_GA" : ["GRASS","GO","前进2格","前进2格_GA",],
	"前进2格_GS" : ["GRASS","GO","前进2格","前进2格_GS",],
	"前进2格_GD" : ["GRASS","GO","前进2格","前进2格_GD",],

	"前进3格_G" : ["GRASS","GO","前进3格","前进3格_G",],
	"前进3格_GA" : ["GRASS","GO","前进3格","前进3格_GA",],
	"前进3格_GS" : ["GRASS","GO","前进3格","前进3格_GS",],

	# 粉色 PINK (统一格式)
	"前进1格_P" : ["PINK","GO","前进1格","前进1格_P",],
	"前进1格_PA" : ["PINK","GO","前进1格","前进1格_PA",],
	"前进1格_PS" : ["PINK","GO","前进1格","前进1格_PS",],
	"前进1格_PD" : ["PINK","GO","前进1格","前进1格_PD",],
	"前进1格_PF" : ["PINK","GO","前进1格","前进1格_PF",],

	"前进2格_P" : ["PINK","GO","前进2格","前进2格_P",],
	"前进2格_PA" : ["PINK","GO","前进2格","前进2格_PA",],
	"前进2格_PS" : ["PINK","GO","前进2格","前进2格_PS",],
	"前进2格_PD" : ["PINK","GO","前进2格","前进2格_PD",],

	"前进3格_P" : ["PINK","GO","前进3格","前进3格_P",],
	"前进3格_PA" : ["PINK","GO","前进3格","前进3格_PA",],
	"前进3格_PS" : ["PINK","GO","前进3格","前进3格_PS",],

	# 河流 RIVER (统一格式)
	"前进1格_R" : ["RIVER","GO","前进1格","前进1格_R",],
	"前进1格_RA" : ["RIVER","GO","前进1格","前进1格_RA",],
	"前进1格_RS" : ["RIVER","GO","前进1格","前进1格_RS",],
	"前进1格_RD" : ["RIVER","GO","前进1格","前进1格_RD",],
	"前进1格_RF" : ["RIVER","GO","前进1格","前进1格_RF",],

	"前进2格_R" : ["RIVER","GO","前进2格","前进2格_R",],
	"前进2格_RA" : ["RIVER","GO","前进2格","前进2格_RA",],
	"前进2格_RS" : ["RIVER","GO","前进2格","前进2格_RS",],
	"前进2格_RD" : ["RIVER","GO","前进2格","前进2格_RD",],

	"前进3格_R" : ["RIVER","GO","前进3格","前进3格_R",],
	"前进3格_RA" : ["RIVER","GO","前进3格","前进3格_RA",],
	"前进3格_RS" : ["RIVER","GO","前进3格","前进3格_RS",],

	# 万能 UNIVERSAL (统一格式)
	"前进1格_U" : ["UNIVERSAL","GO","前进1格","前进1格_U",],
	"前进1格_UA" : ["UNIVERSAL","GO","前进1格","前进1格_UA",],
	"前进1格_US" : ["UNIVERSAL","GO","前进1格","前进1格_US",],


	"前进2格_U" : ["UNIVERSAL","GO","前进2格","前进2格_U",],
	"前进2格_UA" : ["UNIVERSAL","GO","前进2格","前进2格_UA",],


	"前进3格_U" : ["UNIVERSAL","GO","前进3格","前进3格_U",],

	

	"交换人生_U":["UNIVERSAL","TRICK","交换人生","交换人生_U"],
	"交换人生_L":["LAND","TRICK","交换人生","交换人生_L"],
	"交换人生_G":["GRASS","TRICK","交换人生","交换人生_G"],
	"交换人生_P":["PINK","TRICK","交换人生","交换人生_P"],
	"交换人生_R":["RIVER","TRICK","交换人生","交换人生_R"],
	
	"无中生有" : ["UNIVERSAL","TRICK","无中生有","无中生有"],
	"无中生有A" : ["UNIVERSAL","TRICK","无中生有","无中生有A"],
	"无中生有S" : ["UNIVERSAL","TRICK","无中生有","无中生有S"],
	"无中生有D" : ["UNIVERSAL","TRICK","无中生有","无中生有D"],
	"无中生有F" : ["UNIVERSAL","TRICK","无中生有","无中生有F"],
	"无中生有E" : ["UNIVERSAL","TRICK","无中生有","无中生有E"],
	
	
	"重铸_U" : ["UNIVERSAL","TRICK","重铸","重铸_U"],
	"重铸_UA" : ["UNIVERSAL","TRICK","重铸","重铸_UA"],
	
	"重铸_L" : ["LAND","TRICK","重铸","重铸_L"],
	"重铸_LA" : ["LAND","TRICK","重铸","重铸_LA"],
	
	"重铸_G" : ["GRASS","TRICK","重铸","重铸_G"],
	"重铸_GA" : ["GRASS","TRICK","重铸","重铸_GA"],
	
	"重铸_P" : ["PINK","TRICK","重铸","重铸_P"],
	"重铸_PA" : ["PINK","TRICK","重铸","重铸_PA"],
	
	"重铸_R" : ["RIVER","TRICK","重铸","重铸_R"],
	"重铸_RA" : ["RIVER","TRICK","重铸","重铸_RA"],
	
	
	"化险为夷" : ["UNIVERSAL","TRICK","化险为夷","化险为夷"],
	"化险为夷A" : ["UNIVERSAL","TRICK","化险为夷","化险为夷A"],
	"化险为夷S" : ["UNIVERSAL","TRICK","化险为夷","化险为夷S"],
	"化险为夷D" : ["UNIVERSAL","TRICK","化险为夷","化险为夷D"],
	"化险为夷F" : ["UNIVERSAL","TRICK","化险为夷","化险为夷F"],
	"化险为夷E" : ["UNIVERSAL","TRICK","化险为夷","化险为夷E"],
	
	
	
	"乾坤重置" : ["UNIVERSAL","TRICK","乾坤重置","乾坤重置"],
	"乾坤重置A" : ["UNIVERSAL","TRICK","乾坤重置","乾坤重置A"],
	
	
	"点染一格_L" : ["LAND","TRICK","点染一格","点染一格_L"],
	"点染一格_G" : ["GRASS","TRICK","点染一格","点染一格_G"],
	"点染一格_P" : ["PINK","TRICK","点染一格","点染一格_P"],
	"点染一格_R" : ["RIVER","TRICK","点染一格","点染一格_R"],\
	
	"点染一格_LA" : ["LAND","TRICK","点染一格","点染一格_LA"],
	"点染一格_GA" : ["GRASS","TRICK","点染一格","点染一格_GA"],
	"点染一格_PA" : ["PINK","TRICK","点染一格","点染一格_PA"],
	"点染一格_RA" : ["RIVER","TRICK","点染一格","点染一格_RA"],
	
	"点染一格_LS" : ["LAND","TRICK","点染一格","点染一格_LS"],
	"点染一格_GS" : ["GRASS","TRICK","点染一格","点染一格_GS"],
	"点染一格_PS" : ["PINK","TRICK","点染一格","点染一格_PS"],
	"点染一格_RS" : ["RIVER","TRICK","点染一格","点染一格_RS"],
	
	
	"障碍重重_U" : ["UNIVERSAL","TRICK","障碍重重","障碍重重_U"],
	"障碍重重_L" : ["LAND","TRICK","障碍重重","障碍重重_L"],
	"障碍重重_G" : ["GRASS","TRICK","障碍重重","障碍重重_G"],
	"障碍重重_P" : ["PINK","TRICK","障碍重重","障碍重重_P"],
	"障碍重重_R" : ["RIVER","TRICK","障碍重重","障碍重重_R"],
	
	"障碍重重_UA" : ["UNIVERSAL","TRICK","障碍重重","障碍重重_UA"],
	"障碍重重_LA" : ["LAND","TRICK","障碍重重","障碍重重_LA"],
	"障碍重重_GA" : ["GRASS","TRICK","障碍重重","障碍重重_GA"],
	"障碍重重_PA" : ["PINK","TRICK","障碍重重","障碍重重_PA"],
	"障碍重重_RA" : ["RIVER","TRICK","障碍重重","障碍重重_RA"],

	"障碍重重_LS" : ["LAND","TRICK","障碍重重","障碍重重_LS"],
	"障碍重重_GS" : ["GRASS","TRICK","障碍重重","障碍重重_GS"],
	"障碍重重_PS" : ["PINK","TRICK","障碍重重","障碍重重_PS"],
	"障碍重重_RS" : ["RIVER","TRICK","障碍重重","障碍重重_RS"],
	
	
	"原地待命_U" : ["UNIVERSAL","TRICK","原地待命","原地待命_U"],
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
func _process(delta: float) -> void:
	if CARDS.size() < 5:
		var keyss = ACARDS.keys()
	# 2. 打乱key顺序
		keyss.shuffle()
		for k in keyss:
			CARDS[k] = ACARDS[k]
	
	
