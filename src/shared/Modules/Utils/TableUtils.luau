local TableUtils = {}

function TableUtils.clone<T>(value: T): T
	if typeof(value) ~= "table" then
		return value
	end

	return table.clone(value) :: any
end

function TableUtils.merge(base: { [any]: any }, overrides: { [any]: any }?): { [any]: any }
	local result = TableUtils.clone(base)
	if typeof(overrides) ~= "table" then
		return result
	end

	for key, value in pairs(overrides) do
		result[key] = value
	end

	return result
end

function TableUtils.mergeDeep(base: { [any]: any }, overrides: { [any]: any }?): { [any]: any }
	local result = {}
	for key, value in pairs(base) do
		result[key] = if typeof(value) == "table" then TableUtils.mergeDeep(value, nil) else value
	end

	if typeof(overrides) ~= "table" then
		return result
	end

	for key, value in pairs(overrides) do
		if typeof(value) == "table" and typeof(result[key]) == "table" then
			result[key] = TableUtils.mergeDeep(result[key], value)
		else
			result[key] = value
		end
	end

	return result
end

function TableUtils.isArray(value: any): boolean
	if typeof(value) ~= "table" then
		return false
	end

	local count = 0
	for key in pairs(value) do
		if typeof(key) == "number" then
			count += 1
		end
	end

	return count > 0 and value[1] ~= nil
end

return TableUtils
