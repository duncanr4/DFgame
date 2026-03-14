extends RefCounted
class_name OverworldPopulationService

static func describe_climate(temperature: float, moisture: float) -> String:
	var temp_label := "Mild"
	if temperature < 0.3:
		temp_label = "Cold"
	elif temperature < 0.55:
		temp_label = "Cool"
	elif temperature < 0.75:
		temp_label = "Warm"
	else:
		temp_label = "Hot"
	var moisture_label := "moderate rainfall"
	if moisture < 0.3:
		moisture_label = "low rainfall"
	elif moisture < 0.6:
		moisture_label = "moderate rainfall"
	else:
		moisture_label = "heavy rainfall"
	return "%s climate with %s" % [temp_label, moisture_label]

static func format_resource_list(resources: Array[String]) -> String:
	var items: Array[String] = []
	for entry: String in resources:
		items.append(String(entry))
	if items.is_empty():
		return "None"
	if items.size() == 1:
		return items[0]
	if items.size() == 2:
		return "%s and %s" % [items[0], items[1]]
	var combined := ""
	for index in range(items.size()):
		if index == items.size() - 1:
			combined += "and %s" % items[index]
		else:
			combined += "%s, " % items[index]
	return combined
