Config = {}
Config.Version = '1.0'

Config.ESX = true


Config.Damage = 0.0

Config.Weather = true
Config.KeepSnowOnGround = true
Config.MeltEnabled = true
Config.MeltIntervalSeconds = 60 
Config.MeltAmount = 0.5
Config.StartDurability = 100
Config.SnowHandling = {
	Enabled = true,
	TractionMultiplier = 1.25,
	LowSpeedTractionLossMultiplier = 0.85,
}

-- Snowman crafting / spawn config
Config.Snowman = {
	Props = {
		'xm3_prop_xm3_snowman_01a',
		'xm3_prop_xm3_snowman_01b',
		'xm3_prop_xm3_snowman_01c',
	},
	RequiredSnowballs = 5,
	BreakSpeed = 4.0,
	CheckInterval = 700,
}
