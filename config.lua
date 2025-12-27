Config = {}

Config.ESX = true


Config.Damage = 0.0

Config.Weather = true
Config.MeltEnabled = true
Config.MeltIntervalSeconds = 60 -- how often durability is reduced per tick
Config.MeltAmount = 0.5 -- how much durability to remove per tick
Config.StartDurability = 100 -- starting durability for new snowballs
-- Vehicle handling adjustments for snow
Config.SnowHandling = {
	Enabled = true,
	-- Multiply these values to increase traction on snow (1.0 = unchanged)
	TractionMultiplier = 1.25,
	-- Multiply low speed traction loss (lower value -> less loss)
	LowSpeedTractionLossMultiplier = 0.85,
}
