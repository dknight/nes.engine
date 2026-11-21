#!/usr/bin/env lua

-- NES memory usage report
--
-- Analyzes memory allocation using the linker configuration
-- and map file. Reports used and available memory, and utilization
-- percentage for each memory region.

-- Path to the linker configuration file.
-- Assumes nes.cfg is located in the project root by default.
NES_CONFIG = "nes.cfg"

local script_path = arg[0]
local nesfile_path = arg[1]

-- Error reporter helper
local function report_error(err)
	return string.format("error: %s", err)
end

-- Parse MEMORY section of nes.cfg
local function parse_memory_config()
	local mem_data = {}

	local pattern = '([%w_]+):%s*start=%$(%x+),%s*size=%$(%x+),%s*type=(%w+),%s*file=([^,;]+)'

	for line in io.lines(NES_CONFIG) do
		local name, start, size, mem_type, file = line:match(pattern)

		if name ~= nil then
			table.insert(mem_data, {
				name = name,
				start = tonumber(start, 16),
				size = tonumber(size, 16),
				mem_type = mem_type,
				file = file,
			})
		end
	end

	return mem_data
end

-- Parse SEGMENTS section of nes.cfg
local function parse_segment_config()
	local segment_data = {}
	local in_segments = false

	local pattern = '^%s*([%w_]+):%s*load=([%w_]+)'

	for line in io.lines(NES_CONFIG) do
		if not in_segments then
			if line:match('^%s*SEGMENTS%s*{') then
				in_segments = true
			end
		else
			if line:match('^%s*}%s*$') then
				break
			end

			local name, load = line:match(pattern)

			if name ~= nil then
				table.insert(segment_data, {
					name = name,
					load = load,
				})
			end
		end
	end

	return segment_data
end

-- Parse segment list from linker map file
local function parse_map_segment_file()
	local segment_usage = {}
	local pattern = '^([%w_]+)%s+(%x+)%s+(%x+)%s+(%x+)%s+(%x+)%s*$'

	local found_segment_list = false
	local found_segment_data = false

	for line in io.lines(nesfile_path) do
		if not found_segment_list then
			if line:match('^Segment list:') then
				found_segment_list = true
			end
		else
			local name, start, finish, size, align = line:match(pattern)

			if name then
				found_segment_data = true

				table.insert(segment_usage, {
					name = name,
					start = tonumber(start, 16),
					finish = tonumber(finish, 16),
					size = tonumber(size, 16),
					align = tonumber(align, 16),
				})
			elseif found_segment_data and line:match('^%s*$') then
				break
			end
		end
	end

	return segment_usage
end

-- Match linker segments with MEMORY regions and calculate usage
local function build_memory_report(mem_data, segment_data, usage_data)
	local usage_by_segment = {}
	local used_by_memory = {}
	local report = {}

	for _, segment in ipairs(usage_data) do
		usage_by_segment[segment.name] = segment.size
	end

	for _, segment in ipairs(segment_data) do
		local size = usage_by_segment[segment.name] or 0
		local load = segment.load

		used_by_memory[load] = (used_by_memory[load] or 0) + size
	end

	for _, memory in ipairs(mem_data) do
		local used = used_by_memory[memory.name] or 0

		table.insert(report, {
			name = memory.name,
			total = memory.size,
			used = used,
			available = memory.size - used,
			usage = (used / memory.size) * 100,
		})
	end

	return report
end

-- Usage helper, prints how to use the script
local function help()
	print(string.format("Usage: lua %s <filename.map>", script_path))
end

local function main()
	local errors = {}
	local mem_data
	local segment_data
	local usage_data

	if not nesfile_path then
		print(report_error("map filename is required"))
		help()
		os.exit(1)
	end

	mem_data = parse_memory_config()
	if #mem_data == 0 then
		table.insert(
			errors,
			report_error("cannot get memory data from " .. NES_CONFIG)
		)
	end

	segment_data = parse_segment_config()
	if #segment_data == 0 then
		table.insert(
			errors,
			report_error("cannot get segment data from " .. NES_CONFIG)
		)
	end

	usage_data = parse_map_segment_file()
	if #usage_data == 0 then
		table.insert(
			errors,
			report_error("cannot read map file")
		)
	end

	if #errors ~= 0 then
		print(table.concat(errors, "\n"))
		help()
		os.exit(1)
	end

	local report = build_memory_report(
		mem_data,
		segment_data,
		usage_data
	)

	table.insert(report, 2, {
		name = "STACK",
		used = 0x100,
		total = 0x100,
		available = 0,
		usage = 100,
		reserved = true,
	})

	for _, memory in ipairs(report) do
		local label = memory.reserved and "Reserved" or "Used"

		print(string.format(
			"%-10s %-8s %5d / %5d bytes (%5.1f%%) Available: %5d bytes",
			memory.name,
			label,
			memory.used,
			memory.total,
			memory.usage,
			memory.available
		))
	end
end

main()
