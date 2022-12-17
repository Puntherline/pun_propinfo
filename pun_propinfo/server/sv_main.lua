-- ####################### Variables #######################
local currently_updating = false
local http_status_codes = {
	["400"] = "Bad request",
	["401"] = "Unauthorized",
	["403"] = "Forbidden",
	["404"] = "Not found",
	["405"] = "Method not allowed",
	["406"] = "Not acceptable",
	["407"] = "Proxy authentication required",
	["408"] = "Request timed out",
	["409"] = "Conflict",
	["410"] = "Gone",
	["425"] = "Too early",
	["429"] = "Too many requests",
	["451"] = "Unavailable for legal reasons",
	["500"] = "Internal server error",
	["501"] = "Not implemented",
	["502"] = "Bad gateway",
	["503"] = "Service unavailable",
	["504"] = "Gateway timeout",
	["505"] = "HTTP version not supported",
	["506"] = "Variant also negotiates",
	["507"] = "Insufficient storage",
	["508"] = "Loop detected",
	["510"] = "Not extended",
	["511"] = "Network authentication required"
}
local props_to_skip = {}



-- ####################### Functions #######################
-- Print additional info if debug is enabled
function debugPrint(...)
	if config.debug == true then
		print("^5[Debug]: " .. ... .. "^7")
	end
end

-- Updating the proplist
function updateProplist(source, vehicle_list)
	currently_updating = true

	-- Get online proplist depending on config selection
	PerformHttpRequest(
		"https://raw.githubusercontent.com/Puntherline/pun_propinfo/main/misc/proplist_index_" .. config.proplist_type .. ".json",
		function(http_code, result_data, result_headers)

			-- Status code isn't OK, abort
			if http_code ~= 200 then
				local code = http_status_codes[tostring(http_code)] or http_code
				print("^1[Warn]: ^7Proplist update has failed, aborting.")
				print("HTTP status code: " .. code)
				currently_updating = false
				return
			end

			debugPrint("Successfully fetched https://raw.githubusercontent.com/Puntherline/pun_propinfo/main/misc/proplist_index_" .. config.proplist_type .. ".json")

			-- Decode data
			local decoded_result = json.decode(result_data)

			-- Creating a backup of the client-sided proplist.lua
			local file_path = GetResourcePath(GetCurrentResourceName()) .. "/client/"
			local timestamp = ""
			if config.create_proplist_backup == true then
				timestamp = os.date("%Y-%m-%d_%H-%M-%S")
				local main_file = io.open(file_path .. "proplist.lua", "r")
				local backup_file = io.open(file_path .. "backups/proplist_" .. timestamp .. ".lua", "w")
				backup_file:write(main_file:read("*all"))
				backup_file:close()
				main_file:close()
				debugPrint("Created backup of proplist.lua")
			end

			-- Preparing proplist.lua
			local main_file = io.open(file_path .. "proplist.lua", "w")
			main_file:write("proplist = {\n")

			debugPrint("Prepared the new proplist.lua file")

			-- If the update was started by a user, insert vehicles first
			if source ~= 0 then
				debugPrint("Proplist update started by client: Adding vehicles first")
				for i = 1, #vehicle_list do
					main_file:write("	[tostring(`" .. vehicle_list[i] .. "`)] = \"" .. vehicle_list[i] .. "\",\n")
					props_to_skip[vehicle_list[i]] = true
				end
			end

			-- Iterating online proplist index
			if decoded_result ~= nil then
				for i = 1, #decoded_result do
					local wait_timer = tonumber(config.wait_timer) or 250
					local continue = false

					Wait(wait_timer)

					-- Get the specified proplist
					PerformHttpRequest(
						decoded_result[i],
						function(http_code_2, result_data_2, result_headers_2)

							-- Status code isn't OK, inform user but continue with next URL
							if http_code_2 ~= 200 then
								local code_2 = http_status_codes[tostring(http_code_2)] or http_code_2
								print("^1[Warn]: ^7Fetching a proplist has failed.")
								print("Proplist URL: " .. decoded_result[i])
								print("HTTP status code: " .. code_2)
								continue = true
								return
							end
							debugPrint("Successfully fetched proplist from " .. decoded_result[i])

							local bmStart = os.clock() * 1000

							-- Iterate every line
							for line in string.gmatch(result_data_2, "[^\r\n]+") do

								-- Make sure that the line is safe to create code with
								if (
									not line:find("`") and
									not line:find("\"") and
									not line:find("+") and
									not line:find("}") and
									not line:find("=") and
									not line:find(",")
								) then
									if props_to_skip[line] == nil then
										main_file:write("	[tostring(`" .. line .. "`)] = \"" .. line .. "\",\n")
										props_to_skip[line] = true
									end
								end
							end

							debugPrint("Took " .. math.floor((os.clock() * 1000) - bmStart) .. "ms to build.")

							continue = true
						end
					)

					while not continue do
						Wait(0)
					end
				end
			else
				props_to_skip = {}
				main_file:write("}")
				main_file:close()

				-- Restoring backup
				local backup_file = io.open(file_path .. "backups/proplist_" .. timestamp .. ".lua", "r")
				main_file = io.open(file_path .. "proplist.lua", "w")
				main_file:write(backup_file:read("*all"))
				main_file:close()
				backup_file:close()

				-- Informing server/user
				if source == 0 then
					print("^1[Warn]: ^7Proplist index was empty, either the URL changed or it was edited recently. A backup has been restored.")
				else
					TriggerClientEvent("pun_propinfo:s_c:notify", source, "[Warn]: Proplist index was empty, either the URL changed or it was edited recently. A backup has been restored.")
				end
				return
			end

			-- Clear table that contains lines to free up memory
			props_to_skip = {}

			-- Closing proplist.lua saving all changes
			main_file:write("}")
			main_file:close()
			print("^3[Info] ^7Successfully built proplist.lua, ensure the resource to apply changes!")
			if source == 0 then
				print("Since this was executed via the server, addon vehicles couldn't be added.")
				print("If you want addon vehicles to also show their hashes and names, update the proplist via the in game menu.")
			else
				TriggerClientEvent("pun_propinfo:s_c:notify", source, "Finished updating the list, ensure the resource to apply changes!")
			end

			-- Getting proplist version we just installed
			debugPrint("Fetching proplist version we just installed")
			local new_proplist_version = ""
			PerformHttpRequest(
				"https://raw.githubusercontent.com/Puntherline/pun_propinfo/main/misc/version.json",
				function(http_code_2, result_data_2, result_headers_2)

					-- Status code isn't OK, abort
					if http_code_2 ~= 200 then
						local code = http_status_codes[tostring(http_code_2)] or http_code_2
						print("^1[Warn]: ^7Getting version of freshly installed proplist failed.")
						print("HTTP status code: " .. code)
						new_proplist_version = "unknown"
						return
					end

					new_proplist_version = json.decode(result_data_2).proplist[string.lower(config.proplist_type)]
				end
			)

			-- Waiting for result
			while new_proplist_version == "" do
				Wait(0)
			end

			-- Updating version.json
			local version_file_path = GetResourcePath(GetCurrentResourceName()) .. "/server/version.json"
			local version_file = io.open(version_file_path, "r")
			local decoded_version_file_content = json.decode(version_file:read("*all"))
			version_file:close()

			version_file = io.open(version_file_path, "w")
			local updated_version_file_content = {
				script = decoded_version_file_content.script,
				proplist_type = string.lower(config.proplist_type),
				proplist_version = new_proplist_version
			}

			version_file:write(json.encode(updated_version_file_content))
			version_file:close()

			debugPrint("Successfully updated local version.json file!")

			currently_updating = false
		end
	)
end



-- ####################### Version checks #######################
CreateThread(function()
	debugPrint("pun_propinfo is starting up.")

	-- Get currently installed script and proplist version as well as proplist type
	local file_path = GetResourcePath("pun_propinfo") .. "/server/version.json"
	local version_file = io.open(file_path, "r")
	if version_file == nil then
		print("^1[Warn]: ^7pun_propinfo/server/version.json not found, unable to do version and proplist checks!")
		print("To fix this, go to ^0https://github.com/Puntherline/pun_propinfo/releases ^7and download the latest release.")
		return
	end
	local current_version = json.decode(version_file:read("*all"))
	version_file:close()

	-- Prevent modified version.json to screw up checks
	local script_version = current_version.script or "unknown"
	local proplist_type = current_version.proplist_type or "unknown"
	local proplist_version = current_version.proplist_version or "unknown"
	debugPrint("Current version info: " .. script_version .. " (script) | " .. proplist_version .. " (proplist version) | " .. proplist_type .. " (proplist type)")

	-- Installed proplist doesn't match config
	if proplist_type ~= config.proplist_type:lower() then
		print("^3[Info]: ^7Installed proplist type doesn't match config, unable to do proplist checks!")
		print("To fix this, execute ^3propinfo update ^7followed by ^3ensure pun_propinfo^7!")
		print("You can also open the in-game UI via ^3propinfo ^7and trigger the update from there.")
		config.proplist_update_check = false -- Disabling proplist checks
	end

	-- Start main loop only if either or both config update settings are true
	if config.proplist_update_check == true or config.script_update_check == true then
		debugPrint("Starting update loop and running first check since we just started.")
		local startup = true
		local checked_today = false
		while true do

			-- Check if it's at most 2 minutes past midnight or if we just started
			if math.fmod(os.time(), 86400) <= 120 or startup == true then
				startup = false

				-- Only run if we didn't check today already
				if checked_today == false then
					checked_today = true

					-- Fetch online version.json
					PerformHttpRequest(
						"https://raw.githubusercontent.com/Puntherline/pun_propinfo/main/misc/version.json",
						function(http_code, result_data, result_headers)

							-- Status code isn't OK, abort
							if http_code ~= 200 then
								local code = http_status_codes[tostring(http_code)] or http_code
								print("^1[Warn]: ^7Main update check has failed, aborting update check.")
								print("Checking again tomorrow. HTTP status code: " .. code)
								return
							end

							-- Decode data
							local decoded_result = json.decode(result_data)
							local online_script_version = decoded_result.script
							local online_proplist_version = decoded_result.proplist[proplist_type] or "NIL"

							-- Compare script versions
							if config.script_update_check == true then
								if online_script_version ~= script_version then
									print("^3[Info]: ^7A new script version for pun_propinfo is available: ^2" .. online_script_version .. " ^7> ^1" .. script_version .. "^7")
									print("Visit ^0https://github.com/Puntherline/pun_propinfo/releases ^7for the download.")
								end
							end

							-- Compare proplist versions
							if config.proplist_update_check == true then
								if online_proplist_version ~= proplist_version then
									print("^3[Info]: ^0A new proplist version for pun_propinfo is available: ^2" .. online_proplist_version .. " ^7> ^1" .. proplist_version .. " ^7(Type: " .. proplist_type .. ")")
									print("To update the proplist, simply run ^3propinfo update ^7or update the proplist in game via the UI.")
								end
							end

							debugPrint("Done checking online versions.")
						end
					)
				end
			else
				checked_today = false
			end
			Wait(60000)
		end
	end
end)



-- ####################### Command to open NUI (client) or update lists (server) #######################
RegisterCommand("propinfo", function(source, args, raw_command)
	local _source = source
	local action = args[1] or ""

	-- Executed by server
	if _source == 0 then
		if action:lower() == "update" then
			debugPrint("\"propinfo update\" executed by server, updating proplist.")
			updateProplist(_source)
		else
			print("The only propinfo command that works from the console is \"^3propinfo update^7\".")
		end

	-- Executed by user
	else

		-- Whether or not this user can update and use the proplist
		local update_perm = IsPlayerAceAllowed(_source, "propinfo_update")
		local use_perm = IsPlayerAceAllowed(_source, "propinfo_use")
		debugPrint("Player " .. GetPlayerName(_source) .. " used propinfo. According to the config:")
		debugPrint("Anybody can use the command: " .. tostring(config.anybody_use_command) .. " | Anybody can update: " .. tostring(config.anybody_can_update))
		debugPrint("According to the ace perms:")
		debugPrint("Using permission (propinfo_use): " .. tostring(use_perm))
		debugPrint("Updating permission (update_perm): " .. tostring(update_perm))

		-- Anybody/this user is allowed to use the command
		if config.anybody_use_command == true or use_perm then
			local _update_perm = update_perm or config.anybody_can_update
			TriggerClientEvent("pun_propinfo:s_c:openNui", _source, _update_perm)
			debugPrint("Conclusion: Player is allowed to open UI. Allow update permission: " .. tostring(_update_perm))
		else
			TriggerClientEvent("pun_propinfo:s_c:notify", _source, "You lack the required permissions to open the menu.")
		end
	end
end, false)



-- ####################### Update proplist via client side #######################
RegisterNetEvent("pun_propinfo:c_s:requestProplistUpdate")
AddEventHandler("pun_propinfo:c_s:requestProplistUpdate", function(vehicle_list)
	local _source = source

	-- Check permission first
	if IsPlayerAceAllowed(_source, "propinfo_update") then
		if not currently_updating then
			updateProplist(_source, vehicle_list)
		else
			TriggerClientEvent("pun_propinfo:s_c:notify", _source, "The list is already being updated.")
		end
	end
end)