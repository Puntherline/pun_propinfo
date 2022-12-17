-- ####################### Variables #######################
local setting_values = {
	idgun = false,
	all_peds_info = false,
	all_vehicles_info = false,
	all_objects_info = false
}
local option_values = {
	idgun_draw_box_around_object = false,
	idgun_draw_text_hash = false,
	idgun_draw_text_name = false,
	idgun_draw_text_pos = false,
	idgun_draw_text_rot = false,
	idgun_draw_box_around_object_r = 150,
	idgun_draw_box_around_object_g = 50,
	idgun_draw_box_around_object_b = 0,
	idgun_draw_box_around_object_a = 100,
	idgun_text_scale = 0.40,
	idgun_text_pos_x = 0.01,
	idgun_text_pos_y = 0.7,
	idgun_text_align_right = false,

	all_peds_info_boxes = false,
	all_peds_info_text_hash = false,
	all_peds_info_text_name = false,
	all_peds_info_text_pos = false,
	all_peds_info_text_rot = false,
	all_peds_info_r = 0,
	all_peds_info_g = 150,
	all_peds_info_b = 50,
	all_peds_info_a = 100,

	all_vehicles_info_boxes = false,
	all_vehicles_info_text_hash = false,
	all_vehicles_info_text_name = false,
	all_vehicles_info_text_pos = false,
	all_vehicles_info_text_rot = false,
	all_vehicles_info_r = 50,
	all_vehicles_info_g = 0,
	all_vehicles_info_b = 150,
	all_vehicles_info_a = 100,

	all_objects_info_boxes = false,
	all_objects_info_text_hash = false,
	all_objects_info_text_name = false,
	all_objects_info_text_pos = false,
	all_objects_info_text_rot = false,
	all_objects_info_r = 150,
	all_objects_info_g = 50,
	all_objects_info_b = 150,
	all_objects_info_a = 100,

	adv_draw_box_distance = 40, -- Draw boxes only LEQ to this
	adv_draw_text_distance = 20, -- Draw text only LEQ to this
	adv_draw_text_max_size = 0.60,
	adv_draw_text_min_size = 0.10,

	adv_idle_msec = 250, -- Wait after checking if setting is enabled
	adv_idgun_get_object_msec = 250, -- Polling interval for idgun
	adv_idgun_ui_update_msec = 50, -- ID Gun UI update interval if change detected
	adv_boxes_get_pause_msec = 1000, -- Pause after getting ped/veh/obj list
	adv_update_entities_wait_msec = 0, -- Pause during getting ped/veh/obj list, smoothes out load
	adv_boxes_data_update_msec = 0, -- Box position update interval
	adv_boxes_draw_boxes_msec = 0, -- Draw box interval, should be 0
	adv_text_draw_text_msec = 0 -- Draw text interval, should be 0
}
local default_option_values = {}
local option_values_sent = false
local idgun_info = {hash = nil, name = nil, pos = nil, rot = nil}
local draw_idgun_box = {}
local draw_ped_box = {}
local draw_vehicle_box = {}
local draw_object_box = {}
local player_pos = GetEntityCoords(PlayerPedId())



-- ####################### Functions #######################
function drawPolys(v)
	-- Starting top left, going counter-clockwise when looking at that side
	-- Top
	DrawPoly(v.t_f_l, v.t_r_l, v.t_r_r, option_values[v.r], option_values[v.g], option_values[v.b], option_values[v.a])
	DrawPoly(v.t_r_r, v.t_f_r, v.t_f_l, option_values[v.r], option_values[v.g], option_values[v.b], option_values[v.a])
	-- Bottom
	DrawPoly(v.b_f_r, v.b_r_r, v.b_r_l, option_values[v.r], option_values[v.g], option_values[v.b], option_values[v.a])
	DrawPoly(v.b_r_l, v.b_f_l, v.b_f_r, option_values[v.r], option_values[v.g], option_values[v.b], option_values[v.a])
	-- Front
	DrawPoly(v.t_f_r, v.b_f_r, v.b_f_l, option_values[v.r], option_values[v.g], option_values[v.b], option_values[v.a])
	DrawPoly(v.b_f_l, v.t_f_l, v.t_f_r, option_values[v.r], option_values[v.g], option_values[v.b], option_values[v.a])
	-- Rear
	DrawPoly(v.t_r_l, v.b_r_l, v.b_r_r, option_values[v.r], option_values[v.g], option_values[v.b], option_values[v.a])
	DrawPoly(v.b_r_r, v.t_r_r, v.t_r_l, option_values[v.r], option_values[v.g], option_values[v.b], option_values[v.a])
	-- Left
	DrawPoly(v.t_f_l, v.b_f_l, v.b_r_l, option_values[v.r], option_values[v.g], option_values[v.b], option_values[v.a])
	DrawPoly(v.b_r_l, v.t_r_l, v.t_f_l, option_values[v.r], option_values[v.g], option_values[v.b], option_values[v.a])
	-- Right
	DrawPoly(v.t_r_r, v.b_r_r, v.b_f_r, option_values[v.r], option_values[v.g], option_values[v.b], option_values[v.a])
	DrawPoly(v.b_f_r, v.t_f_r, v.t_r_r, option_values[v.r], option_values[v.g], option_values[v.b], option_values[v.a])
end

function drawLines(v)
	-- Top
	DrawLine(v.t_f_l, v.t_f_r, 255, 255, 255, option_values[v.a])
	DrawLine(v.t_f_r, v.t_r_r, 255, 255, 255, option_values[v.a])
	DrawLine(v.t_r_r, v.t_r_l, 255, 255, 255, option_values[v.a])
	DrawLine(v.t_r_l, v.t_f_l, 255, 255, 255, option_values[v.a])
	-- Bottom
	DrawLine(v.b_f_l, v.b_f_r, 255, 255, 255, option_values[v.a])
	DrawLine(v.b_f_r, v.b_r_r, 255, 255, 255, option_values[v.a])
	DrawLine(v.b_r_r, v.b_r_l, 255, 255, 255, option_values[v.a])
	DrawLine(v.b_r_l, v.b_f_l, 255, 255, 255, option_values[v.a])
	-- Bottom
	DrawLine(v.t_f_l, v.b_f_l, 255, 255, 255, option_values[v.a])
	DrawLine(v.t_f_r, v.b_f_r, 255, 255, 255, option_values[v.a])
	DrawLine(v.t_r_r, v.b_r_r, 255, 255, 255, option_values[v.a])
	DrawLine(v.t_r_l, v.b_r_l, 255, 255, 255, option_values[v.a])
end



-- ####################### Net Events #######################
-- Receive notification from server
RegisterNetEvent("pun_propinfo:s_c:notify")
AddEventHandler("pun_propinfo:s_c:notify", function(msg)
	print(msg)
end)

-- Opening the NUI
RegisterNetEvent("pun_propinfo:s_c:openNui")
AddEventHandler("pun_propinfo:s_c:openNui", function(update_perm)

	-- Abort if the nui is already open
	if IsNuiFocused() then
		print("NUI is already open, close it before executing 'propinfo'.")
		return
	end

	-- Send option values to nui if not yet sent
	if not option_values_sent then
		SendNuiMessage(json.encode({type = "options", values = option_values}))
		option_values_sent = true
	end

	-- Send message to nui to open and set focus
	SendNuiMessage(json.encode({show = true, type = "menu", admin = update_perm}))
	SetNuiFocus(true, true)
end)



-- ####################### NUI Callbacks #######################
-- Updating proplist via menu button
RegisterNUICallback("requestProplistUpdate", function(data, cb)

	-- Get all vehicle models and request an update
	TriggerServerEvent("pun_propinfo:c_s:requestProplistUpdate", GetAllVehicleModels())
	cb("ok")
end)

-- Close button clicked
RegisterNUICallback("closeMenu", function(data, cb)
	SetNuiFocus(false, false)
	cb("ok")
end)

-- Nui callbacks for the toggles
RegisterNUICallback("setSettingValue", function(data, cb)
	setting_values[data.setting] = data.value
	cb("ok")
end)

-- Nui callbacks for the toggle specific options
RegisterNUICallback("setOptionValue", function(data, cb)
	option_values[data.setting] = data.value
	SetResourceKvp(data.setting, tostring(data.value))
	cb("ok")
end)

-- Resetting all settings and options
RegisterNUICallback("resetSettings", function(data, cb)
	for k, v in pairs(option_values) do
		DeleteResourceKvp(k)
		option_values[k] = default_option_values[k]
	end
	SendNuiMessage(json.encode({type = "options", values = option_values}))
	cb("ok")
end)



-- ####################### Load Resource KVP on start #######################
for k, v in pairs(option_values) do
	default_option_values[k] = v
	local current_kvp = GetResourceKvpString(k)
	if current_kvp ~= nil then
		if current_kvp == "true" then
			option_values[k] = true
		elseif current_kvp == "false" then
			option_values[k] = false
		elseif tonumber(current_kvp) then
			option_values[k] = tonumber(current_kvp)
		end
	end
end



-- ####################### ID Gun Related Threads #######################
local target_object = nil
local new_target_object = nil

-- Getting object player is aiming at and handle inserting into draw_idgun_box
CreateThread(function()
	local success, found_obj = false, nil
	local current_focused_object = nil
	local dim_min, dim_max = vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0)
	local object_hash = 0
	while true do
		while setting_values.idgun do
			success, found_object = GetEntityPlayerIsFreeAimingAt(PlayerId())

			if success then

				-- When pointing at vehicles it gives peds, so handle this accordingly
				if IsEntityAPed(found_object) then
					if GetVehiclePedIsIn(found_object, false) ~= 0 then
						found_object = GetVehiclePedIsIn(found_object)
					end
				end
				target_object = found_object

				-- Update the static values only
				idgun_info.hash = GetEntityModel(target_object)
				idgun_info.name = proplist[tostring(idgun_info.hash)]

				-- If draw box around obj is enabled
				if option_values.idgun_draw_box_around_object then

					-- Update only if it needs to update
					if tostring(target_object) ~= current_focused_object then

						-- Remove entry if one already exists
						if draw_idgun_box[current_focused_object] ~= nil then
							draw_idgun_box[current_focused_object] = nil
						end

						-- Insert new object into draw_idgun_box table
						object_hash = GetEntityModel(target_object)
						dim_min, dim_max = GetModelDimensions(object_hash)
						draw_idgun_box[tostring(target_object)] = {
							hash = object_hash,
							dim_min = dim_min,
							dim_max = dim_max,
							b_r_l = vector3(0.0, 0.0, 0.0),
							b_r_r = vector3(0.0, 0.0, 0.0),
							b_f_l = vector3(0.0, 0.0, 0.0),
							b_f_r = vector3(0.0, 0.0, 0.0),
							t_r_l = vector3(0.0, 0.0, 0.0),
							t_r_r = vector3(0.0, 0.0, 0.0),
							t_f_l = vector3(0.0, 0.0, 0.0),
							t_f_r = vector3(0.0, 0.0, 0.0),
							r = "idgun_draw_box_around_object_r",
							g = "idgun_draw_box_around_object_g",
							b = "idgun_draw_box_around_object_b",
							a = "idgun_draw_box_around_object_a"
						}
						current_focused_object = tostring(target_object)
					end
				end
			end

			Wait(option_values.adv_idgun_get_object_msec)
		end

		Wait(option_values.adv_idle_msec)
	end
end)

-- Update selected ped/vehicle/object info (position and rotation)
CreateThread(function()
	while true do
		while setting_values.idgun and (
			option_values.idgun_draw_text_pos or
			option_values.idgun_draw_text_rot
		) do

			-- Updating or clearing
			if target_object ~= nil then

				-- Only if entity still exists
				if DoesEntityExist(target_object) then
					idgun_info.pos = GetEntityCoords(target_object)
					idgun_info.rot = GetEntityRotation(target_object)
				else
					target_object = nil
					idgun_info.hash = nil
					idgun_info.name = nil
					idgun_info.pos = nil
					idgun_info.rot = nil
				end
			end

			Wait(option_values.adv_idgun_ui_update_msec)
		end

		Wait(option_values.adv_idle_msec)
	end
end)

-- Drawing on-screen text for selected ID Gun ped/vehicle/object
CreateThread(function()
	local line_count, hash, name, pos, rot = 0, "", "", "", ""
	while true do
		while setting_values.idgun and (
			option_values.idgun_draw_text_hash or
			option_values.idgun_draw_text_name or
			option_values.idgun_draw_text_pos or
			option_values.idgun_draw_text_rot
		) do

			if DoesEntityExist(target_object) then
				hash = idgun_info.hash
				name = idgun_info.name or "unk"
				pos = idgun_info.pos or "Calculating..."
				rot = idgun_info.rot or "Calculating..."
			else
				hash = "Nothing selected."
				name = "Nothing selected."
				pos = "Nothing selected."
				rot = "Nothing selected."
			end


			-- Resetting line count
			line_count = 0

			-- Drawing hash
			if option_values.idgun_draw_text_hash then
				BeginTextCommandDisplayText("STRING")
				SetTextOutline()
				SetTextScale(0.0, option_values.idgun_text_scale)
				if option_values.idgun_text_align_right then
					SetTextJustification(2)
					SetTextWrap(-1.0, option_values.idgun_text_pos_x + 0.0001)
				end
				AddTextComponentSubstringPlayerName("Hash: " .. hash)
				EndTextCommandDisplayText(option_values.idgun_text_pos_x, option_values.idgun_text_pos_y)
				line_count = line_count + 1
			end

			-- Drawing name
			if option_values.idgun_draw_text_name then
				BeginTextCommandDisplayText("STRING")
				SetTextOutline()
				SetTextScale(0.0, option_values.idgun_text_scale)
				if option_values.idgun_text_align_right then
					SetTextJustification(2)
					SetTextWrap(-1.0, option_values.idgun_text_pos_x + 0.0001)
				end
				AddTextComponentSubstringPlayerName("Name: " .. name)
				EndTextCommandDisplayText(option_values.idgun_text_pos_x, option_values.idgun_text_pos_y + (line_count * (option_values.idgun_text_scale * 0.06)))
				line_count = line_count + 1
			end

			-- Drawing pos
			if option_values.idgun_draw_text_pos then
				BeginTextCommandDisplayText("STRING")
				SetTextOutline()
				SetTextScale(0.0, option_values.idgun_text_scale)
				if option_values.idgun_text_align_right then
					SetTextJustification(2)
					SetTextWrap(-1.0, option_values.idgun_text_pos_x + 0.0001)
				end
				AddTextComponentSubstringPlayerName("Pos: " .. pos)
				EndTextCommandDisplayText(option_values.idgun_text_pos_x, option_values.idgun_text_pos_y + (line_count * (option_values.idgun_text_scale * 0.06)))
				line_count = line_count + 1
			end

			-- Drawing rot
			if option_values.idgun_draw_text_rot then
				BeginTextCommandDisplayText("STRING")
				SetTextOutline()
				SetTextScale(0.0, option_values.idgun_text_scale)
				if option_values.idgun_text_align_right then
					SetTextJustification(2)
					SetTextWrap(-1.0, option_values.idgun_text_pos_x + 0.0001)
				end
				AddTextComponentSubstringPlayerName("Rot: " .. rot)
				EndTextCommandDisplayText(option_values.idgun_text_pos_x, option_values.idgun_text_pos_y + (line_count * (option_values.idgun_text_scale * 0.06)))
				line_count = line_count + 1
			end

			Wait(option_values.adv_text_draw_text_msec)
		end

		Wait(option_values.adv_idle_msec)
	end
end)

-- Updating offset values to draw the box
CreateThread(function()
	local delete_entities = {}
	local number_handle = 0
	while true do
		while (setting_values.idgun and option_values.idgun_draw_box_around_object) do

			-- Iterate and update draw_idgun_box
			for k, v in pairs(draw_idgun_box) do
				number_handle = tonumber(k)
				if DoesEntityExist(number_handle) then
					draw_idgun_box[k].b_r_l = GetOffsetFromEntityInWorldCoords(number_handle, v.dim_min)
					draw_idgun_box[k].b_r_r = GetOffsetFromEntityInWorldCoords(number_handle, v.dim_max.x, v.dim_min.yz)
					draw_idgun_box[k].b_f_l = GetOffsetFromEntityInWorldCoords(number_handle, v.dim_min.x, v.dim_max.y, v.dim_min.z)
					draw_idgun_box[k].b_f_r = GetOffsetFromEntityInWorldCoords(number_handle, v.dim_max.xy, v.dim_min.z)
					draw_idgun_box[k].t_r_l = GetOffsetFromEntityInWorldCoords(number_handle, v.dim_min.xy, v.dim_max.z)
					draw_idgun_box[k].t_r_r = GetOffsetFromEntityInWorldCoords(number_handle, v.dim_max.x, v.dim_min.y, v.dim_max.z)
					draw_idgun_box[k].t_f_l = GetOffsetFromEntityInWorldCoords(number_handle, v.dim_min.x, v.dim_max.yz)
					draw_idgun_box[k].t_f_r = GetOffsetFromEntityInWorldCoords(number_handle, v.dim_max)
				else
					table.insert(delete_entities, k)
				end
			end

			-- Remove entries from draw_idgun_box
			for _, v in pairs(delete_entities) do
				draw_idgun_box[v] = nil
			end
			delete_entities = {}

			Wait(option_values.adv_boxes_data_update_msec)
		end

		Wait(option_values.adv_idle_msec)
	end
end)

-- Drawing boxes and lines for each specified object in draw_idgun_box
CreateThread(function()
	local number_handle = 0
	while true do
		while (setting_values.idgun and option_values.idgun_draw_box_around_object) do

			-- Iterate draw_idgun_box
			for k, v in pairs(draw_idgun_box) do
				number_handle = tonumber(k)
				if DoesEntityExist(number_handle) then
					if IsEntityOnScreen(number_handle) and #(player_pos - GetEntityCoords(number_handle)) < option_values.adv_draw_box_distance then
						drawPolys(v)
						drawLines(v)
					end
				end
			end

			Wait(option_values.adv_boxes_draw_boxes_msec)
		end

		Wait(option_values.adv_idle_msec)
	end
end)



-- ####################### Ped info related threads #######################
-- Get all peds
CreateThread(function()
	local find_handle, found_ped, success, ped_hash = 0, 0, false, 0
	local dim_min, dim_max = vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0)
	local ped_string_handle = ""
	while true do
		while setting_values.all_peds_info do

			-- Start search for ped
			find_handle, found_ped = FindFirstPed()

			-- Set success to true
			if found_ped ~= nil then
				success = true
			end

			-- Finding next ped loop if success on first
			if success then
				for i = 1, 10000 do

					-- Insert most recent ped into table if not yet inserted
					ped_string_handle = tostring(found_ped)
					if not draw_ped_box[ped_string_handle] and not draw_idgun_box[ped_string_handle] then
						ped_hash = GetEntityModel(found_ped)
						dim_min, dim_max = GetModelDimensions(ped_hash)
						draw_ped_box[ped_string_handle] = {
							hash = ped_hash,
							handle = found_ped,
							name = proplist[tostring(ped_hash)] or "unk",
							dim_min = dim_min,
							dim_max = dim_max,
							b_r_l = vector3(0.0, 0.0, 0.0),
							b_r_r = vector3(0.0, 0.0, 0.0),
							b_f_l = vector3(0.0, 0.0, 0.0),
							b_f_r = vector3(0.0, 0.0, 0.0),
							t_r_l = vector3(0.0, 0.0, 0.0),
							t_r_r = vector3(0.0, 0.0, 0.0),
							t_f_l = vector3(0.0, 0.0, 0.0),
							t_f_r = vector3(0.0, 0.0, 0.0),
							r = "all_peds_info_r",
							g = "all_peds_info_g",
							b = "all_peds_info_b",
							a = "all_peds_info_a"
						}
					end

					-- Look for next ped
					success, found_ped = FindNextPed(find_handle)

					-- Break loop if unsuccessful
					if not success then break end

					-- Wait specified amount of ms
					if option_values.adv_update_entities_wait_msec > -1 then
						Wait(option_values.adv_update_entities_wait_msec)
					end
				end
			end

			-- Success was set to false, end search
			EndFindPed(find_handle)

			Wait(option_values.adv_boxes_get_pause_msec)
		end

		Wait(option_values.adv_idle_msec)
	end
end)

-- Updating offset values to draw the boxes
CreateThread(function()
	local delete_entities = {}
	while true do
		while (setting_values.all_peds_info and option_values.all_peds_info_boxes) do

			-- Iterate and update draw_ped_box
			for k, v in pairs(draw_ped_box) do
				if DoesEntityExist(v.handle) and not draw_idgun_box[k] then
					draw_ped_box[k].b_r_l = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_min)
					draw_ped_box[k].b_r_r = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_max.x, v.dim_min.yz)
					draw_ped_box[k].b_f_l = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_min.x, v.dim_max.y, v.dim_min.z)
					draw_ped_box[k].b_f_r = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_max.xy, v.dim_min.z)
					draw_ped_box[k].t_r_l = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_min.xy, v.dim_max.z)
					draw_ped_box[k].t_r_r = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_max.x, v.dim_min.y, v.dim_max.z)
					draw_ped_box[k].t_f_l = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_min.x, v.dim_max.yz)
					draw_ped_box[k].t_f_r = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_max)
				else
					table.insert(delete_entities, k)
				end
			end

			-- Remove entries from draw_ped_box
			for _, v in pairs(delete_entities) do
				draw_ped_box[v] = nil
			end
			delete_entities = {}

			Wait(option_values.adv_boxes_data_update_msec)
		end

		Wait(option_values.adv_idle_msec)
	end
end)

-- Draw boxes and lines for each ped from draw_ped_box
CreateThread(function()
	while true do
		while (setting_values.all_peds_info and option_values.all_peds_info_boxes) do

			-- Iterate draw_ped_box
			for k, v in pairs(draw_ped_box) do
				if DoesEntityExist(v.handle) then
					if IsEntityOnScreen(v.handle) and #(player_pos - GetEntityCoords(v.handle)) < option_values.adv_draw_box_distance then
						drawPolys(v)
						drawLines(v)
					end
				end
			end

			Wait(option_values.adv_boxes_draw_boxes_msec)
		end

		Wait(option_values.adv_idle_msec)
	end
end)

-- Draw text at ped
CreateThread(function()
	local on_screen, screen_x, screen_y = false, 0, 0
	local ped_coords, ped_distance = vector3(0.0, 0.0, 0.0), 0.0
	local percent_distance, text_size_range, text_size = 0.00, 0.00, 0.00
	local line_count = 0
	while true do
		while setting_values.all_peds_info and (
			option_values.all_peds_info_text_hash or
			option_values.all_peds_info_text_name or
			option_values.all_peds_info_text_pos or
			option_values.all_peds_info_text_rot
		) do

			-- Iterate draw_ped_box
			for k, v in pairs(draw_ped_box) do
				if DoesEntityExist(v.handle) then
					ped_coords = GetEntityCoords(v.handle)
					ped_distance = #(player_pos - GetEntityCoords(v.handle))
					on_screen, screen_x, screen_y = GetScreenCoordFromWorldCoord(table.unpack(ped_coords))

					-- Only draw when on screen and close enough
					if on_screen and ped_distance < option_values.adv_draw_text_distance then

						-- Get percent of distance between 0 and max possible distance
						percent_distance = 1 - (ped_distance / option_values.adv_draw_text_distance)

						-- Get total range of text size
						text_size_range = option_values.adv_draw_text_max_size - option_values.adv_draw_text_min_size

						-- Multiply total range of text size by percent distance and add min text size
						text_size = (text_size_range * percent_distance) + option_values.adv_draw_text_min_size

						-- Resetting line count
						line_count = 0

						-- Drawing hash
						if option_values.all_peds_info_text_hash then
							BeginTextCommandDisplayText("STRING")
							SetTextWrap(-1.0, 2.0)
							SetTextOutline()
							SetTextScale(0.0, text_size)
							AddTextComponentSubstringPlayerName("Hash: " .. v.hash)
							EndTextCommandDisplayText(screen_x, screen_y)
							line_count = line_count + 1
						end

						-- Drawing name
						if option_values.all_peds_info_text_name then
							BeginTextCommandDisplayText("STRING")
							SetTextWrap(-1.0, 2.0)
							SetTextOutline()
							SetTextScale(0.0, text_size)
							AddTextComponentSubstringPlayerName("Name: " .. v.name)
							EndTextCommandDisplayText(screen_x, screen_y + (line_count * (text_size * 0.06)))
							line_count = line_count + 1
						end

						-- Drawing pos
						if option_values.all_peds_info_text_pos then
							BeginTextCommandDisplayText("STRING")
							SetTextWrap(-1.0, 2.0)
							SetTextOutline()
							SetTextScale(0.0, text_size)
							AddTextComponentSubstringPlayerName("Pos: " .. ped_coords)
							EndTextCommandDisplayText(screen_x, screen_y + (line_count * (text_size * 0.06)))
							line_count = line_count + 1
						end

						-- Drawing rot
						if option_values.all_peds_info_text_rot then
							BeginTextCommandDisplayText("STRING")
							SetTextWrap(-1.0, 2.0)
							SetTextOutline()
							SetTextScale(0.0, text_size)
							AddTextComponentSubstringPlayerName("Rot: " .. GetEntityRotation(v.handle))
							EndTextCommandDisplayText(screen_x, screen_y + (line_count * (text_size * 0.06)))
							line_count = line_count + 1
						end
					end
				end
			end

			Wait(option_values.adv_text_draw_text_msec)
		end

		Wait(option_values.adv_idle_msec)
	end
end)



-- ####################### Vehicle info related threads #######################
-- Get all vehicles
CreateThread(function()
	local find_handle, found_vehicle, success, vehicle_hash = 0, 0, false, 0
	local dim_min, dim_max = vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0)
	local vehicle_string_handle = ""
	while true do
		while setting_values.all_vehicles_info do

			-- Start search for vehicle
			find_handle, found_vehicle = FindFirstVehicle()

			-- Set success to true
			if found_vehicle ~= nil then
				success = true
			end

			-- Finding next vehicle loop if success on first
			if success then
				for i = 1, 10000 do

					-- Insert most recent vehicle into table if not yet inserted
					vehicle_string_handle = tostring(found_vehicle)
					if not draw_vehicle_box[vehicle_string_handle] and not draw_idgun_box[vehicle_string_handle] then
						vehicle_hash = GetEntityModel(found_vehicle)
						dim_min, dim_max = GetModelDimensions(vehicle_hash)
						draw_vehicle_box[vehicle_string_handle] = {
							hash = vehicle_hash,
							handle = found_vehicle,
							name = proplist[tostring(vehicle_hash)] or "unk",
							dim_min = dim_min,
							dim_max = dim_max,
							b_r_l = vector3(0.0, 0.0, 0.0),
							b_r_r = vector3(0.0, 0.0, 0.0),
							b_f_l = vector3(0.0, 0.0, 0.0),
							b_f_r = vector3(0.0, 0.0, 0.0),
							t_r_l = vector3(0.0, 0.0, 0.0),
							t_r_r = vector3(0.0, 0.0, 0.0),
							t_f_l = vector3(0.0, 0.0, 0.0),
							t_f_r = vector3(0.0, 0.0, 0.0),
							r = "all_vehicles_info_r",
							g = "all_vehicles_info_g",
							b = "all_vehicles_info_b",
							a = "all_vehicles_info_a"
						}
					end

					-- Look for next vehicle
					success, found_vehicle = FindNextVehicle(find_handle)

					-- Break loop if unsuccessful
					if not success then break end

					-- Wait specified amount of ms
					if option_values.adv_update_entities_wait_msec > -1 then
						Wait(option_values.adv_update_entities_wait_msec)
					end
				end
			end

			-- Success was set to false, end search
			EndFindVehicle(find_handle)

			Wait(option_values.adv_boxes_get_pause_msec)
		end

		Wait(option_values.adv_idle_msec)
	end
end)

-- Updating offset values to draw the boxes
CreateThread(function()
	local delete_entities = {}
	while true do
		while (setting_values.all_vehicles_info and option_values.all_vehicles_info_boxes) do

			-- Iterate and update draw_vehicle_box
			for k, v in pairs(draw_vehicle_box) do
				if DoesEntityExist(v.handle) and not draw_idgun_box[k] then
					draw_vehicle_box[k].b_r_l = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_min)
					draw_vehicle_box[k].b_r_r = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_max.x, v.dim_min.yz)
					draw_vehicle_box[k].b_f_l = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_min.x, v.dim_max.y, v.dim_min.z)
					draw_vehicle_box[k].b_f_r = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_max.xy, v.dim_min.z)
					draw_vehicle_box[k].t_r_l = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_min.xy, v.dim_max.z)
					draw_vehicle_box[k].t_r_r = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_max.x, v.dim_min.y, v.dim_max.z)
					draw_vehicle_box[k].t_f_l = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_min.x, v.dim_max.yz)
					draw_vehicle_box[k].t_f_r = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_max)
				else
					table.insert(delete_entities, k)
				end
			end

			-- Remove entries from draw_vehicle_box
			for _, v in pairs(delete_entities) do
				draw_vehicle_box[v] = nil
			end
			delete_entities = {}

			Wait(option_values.adv_boxes_data_update_msec)
		end

		Wait(option_values.adv_idle_msec)
	end
end)

-- Draw boxes and lines for each vehicle from draw_vehicle_box
CreateThread(function()
	while true do
		while (setting_values.all_vehicles_info and option_values.all_vehicles_info_boxes) do

			-- Iterate draw_vehicle_box
			for k, v in pairs(draw_vehicle_box) do
				if DoesEntityExist(v.handle) then
					if IsEntityOnScreen(v.handle) and #(player_pos - GetEntityCoords(v.handle)) < option_values.adv_draw_box_distance then
						drawPolys(v)
						drawLines(v)
					end
				end
			end

			Wait(option_values.adv_boxes_draw_boxes_msec)
		end

		Wait(option_values.adv_idle_msec)
	end
end)

-- Draw text at vehicle
CreateThread(function()
	local on_screen, screen_x, screen_y = false, 0, 0
	local vehicle_coords, vehice_distance = vector3(0.0, 0.0, 0.0), 0.0
	local percent_distance, text_size_range, text_size = 0.00, 0.00, 0.00
	local line_count = 0
	while true do
		while setting_values.all_vehicles_info and (
			option_values.all_vehicles_info_text_hash or
			option_values.all_vehicles_info_text_name or
			option_values.all_vehicles_info_text_pos or
			option_values.all_vehicles_info_text_rot
		) do

			-- Iterate draw_vehicle_box
			for k, v in pairs(draw_vehicle_box) do
				if DoesEntityExist(v.handle) then
					vehicle_coords = GetEntityCoords(v.handle)
					vehicle_distance = #(player_pos - GetEntityCoords(v.handle))
					on_screen, screen_x, screen_y = GetScreenCoordFromWorldCoord(table.unpack(vehicle_coords))

					-- Only draw when on screen and close enough
					if on_screen and vehicle_distance < option_values.adv_draw_text_distance then

						-- Get percent of distance between 0 and max possible distance
						percent_distance = 1 - (vehicle_distance / option_values.adv_draw_text_distance)

						-- Get total range of text size
						text_size_range = option_values.adv_draw_text_max_size - option_values.adv_draw_text_min_size

						-- Multiply total range of text size by percent distance and add min text size
						text_size = (text_size_range * percent_distance) + option_values.adv_draw_text_min_size

						-- Resetting line count
						line_count = 0

						-- Drawing hash
						if option_values.all_vehicles_info_text_hash then
							BeginTextCommandDisplayText("STRING")
							SetTextWrap(-1.0, 2.0)
							SetTextOutline()
							SetTextScale(0.0, text_size)
							AddTextComponentSubstringPlayerName("Hash: " .. v.hash)
							EndTextCommandDisplayText(screen_x, screen_y)
							line_count = line_count + 1
						end

						-- Drawing name
						if option_values.all_vehicles_info_text_name then
							BeginTextCommandDisplayText("STRING")
							SetTextWrap(-1.0, 2.0)
							SetTextOutline()
							SetTextScale(0.0, text_size)
							AddTextComponentSubstringPlayerName("Name: " .. v.name)
							EndTextCommandDisplayText(screen_x, screen_y + (line_count * (text_size * 0.06)))
							line_count = line_count + 1
						end

						-- Drawing pos
						if option_values.all_vehicles_info_text_pos then
							BeginTextCommandDisplayText("STRING")
							SetTextWrap(-1.0, 2.0)
							SetTextOutline()
							SetTextScale(0.0, text_size)
							AddTextComponentSubstringPlayerName("Pos: " .. vehicle_coords)
							EndTextCommandDisplayText(screen_x, screen_y + (line_count * (text_size * 0.06)))
							line_count = line_count + 1
						end

						-- Drawing rot
						if option_values.all_vehicles_info_text_rot then
							BeginTextCommandDisplayText("STRING")
							SetTextWrap(-1.0, 2.0)
							SetTextOutline()
							SetTextScale(0.0, text_size)
							AddTextComponentSubstringPlayerName("Rot: " .. GetEntityRotation(v.handle))
							EndTextCommandDisplayText(screen_x, screen_y + (line_count * (text_size * 0.06)))
							line_count = line_count + 1
						end
					end
				end
			end

			Wait(option_values.adv_text_draw_text_msec)
		end

		Wait(option_values.adv_idle_msec)
	end
end)



-- ####################### Object info related threads #######################
-- Get all objects
CreateThread(function()
	local find_handle, found_object, success, object_hash = 0, 0, false, 0
	local dim_min, dim_max = vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0)
	local object_string_handle = ""
	while true do
		while setting_values.all_objects_info do

			-- Start search for object
			find_handle, found_object = FindFirstObject()

			-- Set success to true
			if found_object ~= nil then
				success = true
			end

			-- Finding next object loop if success on first
			if success then
				for i = 1, 10000 do
					string_handle = tostring(found_object)

					-- Insert most recent object into table if not yet inserted
					if not draw_object_box[string_handle] and not draw_idgun_box[string_handle] then
						object_hash = GetEntityModel(found_object)
						dim_min, dim_max = GetModelDimensions(object_hash)
						draw_object_box[string_handle] = {
							hash = object_hash,
							handle = found_object,
							name = proplist[tostring(object_hash)] or "unk",
							dim_min = dim_min,
							dim_max = dim_max,
							b_r_l = vector3(0.0, 0.0, 0.0),
							b_r_r = vector3(0.0, 0.0, 0.0),
							b_f_l = vector3(0.0, 0.0, 0.0),
							b_f_r = vector3(0.0, 0.0, 0.0),
							t_r_l = vector3(0.0, 0.0, 0.0),
							t_r_r = vector3(0.0, 0.0, 0.0),
							t_f_l = vector3(0.0, 0.0, 0.0),
							t_f_r = vector3(0.0, 0.0, 0.0),
							r = "all_objects_info_r",
							g = "all_objects_info_g",
							b = "all_objects_info_b",
							a = "all_objects_info_a"
						}
					end

					-- Look for next object
					success, found_object = FindNextObject(find_handle)

					-- Break loop if unsuccessful
					if not success then break end

					-- Wait specified amount of ms
					if option_values.adv_update_entities_wait_msec > -1 then
						Wait(option_values.adv_update_entities_wait_msec)
					end
				end
			end

			-- Success was set to false, end search
			EndFindObject(find_handle)

			Wait(option_values.adv_boxes_get_pause_msec)
		end

		Wait(option_values.adv_idle_msec)
	end
end)

-- Updating offset values to draw the boxes
CreateThread(function()
	local delete_entities = {}
	while true do
		while (setting_values.all_objects_info and option_values.all_objects_info_boxes) do

			-- Iterate and update draw_object_box
			for k, v in pairs(draw_object_box) do
				if DoesEntityExist(v.handle) and not draw_idgun_box[k] then
					draw_object_box[k].b_r_l = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_min)
					draw_object_box[k].b_r_r = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_max.x, v.dim_min.yz)
					draw_object_box[k].b_f_l = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_min.x, v.dim_max.y, v.dim_min.z)
					draw_object_box[k].b_f_r = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_max.xy, v.dim_min.z)
					draw_object_box[k].t_r_l = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_min.xy, v.dim_max.z)
					draw_object_box[k].t_r_r = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_max.x, v.dim_min.y, v.dim_max.z)
					draw_object_box[k].t_f_l = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_min.x, v.dim_max.yz)
					draw_object_box[k].t_f_r = GetOffsetFromEntityInWorldCoords(v.handle, v.dim_max)
				else
					table.insert(delete_entities, k)
				end
			end

			-- Remove entries from draw_object_box
			for _, v in pairs(delete_entities) do
				draw_object_box[v] = nil
			end
			delete_entities = {}

			Wait(option_values.adv_boxes_data_update_msec)
		end

		Wait(option_values.adv_idle_msec)
	end
end)

-- Draw boxes and lines for each object from draw_object_box
CreateThread(function()
	while true do
		while (setting_values.all_objects_info and option_values.all_objects_info_boxes) do

			-- Iterate draw_object_box
			for k, v in pairs(draw_object_box) do
				if DoesEntityExist(v.handle) then
					if IsEntityOnScreen(v.handle) and #(player_pos - GetEntityCoords(v.handle)) < option_values.adv_draw_box_distance then
						drawPolys(v)
						drawLines(v)
					end
				end
			end

			Wait(option_values.adv_boxes_draw_boxes_msec)
		end

		Wait(option_values.adv_idle_msec)
	end
end)

-- Draw text at object
CreateThread(function()
	local on_screen, screen_x, screen_y = false, 0, 0
	local object_coords, object_distance = vector3(0.0, 0.0, 0.0), 0.0
	local percent_distance, text_size_range, text_size = 0.00, 0.00, 0.00
	local line_count = 0
	while true do
		while setting_values.all_objects_info and (
			option_values.all_objects_info_text_hash or
			option_values.all_objects_info_text_name or
			option_values.all_objects_info_text_pos or
			option_values.all_objects_info_text_rot
		) do

			-- Iterate draw_object_box
			for k, v in pairs(draw_object_box) do
				if DoesEntityExist(v.handle) then
					object_coords = GetEntityCoords(v.handle)
					object_distance = #(player_pos - GetEntityCoords(v.handle))
					on_screen, screen_x, screen_y = GetScreenCoordFromWorldCoord(table.unpack(object_coords))

					-- Only draw when on screen and close enough
					if on_screen and object_distance < option_values.adv_draw_text_distance then

						-- Get percent of distance between 0 and max possible distance
						percent_distance = 1 - (object_distance / option_values.adv_draw_text_distance)

						-- Get total range of text size
						text_size_range = option_values.adv_draw_text_max_size - option_values.adv_draw_text_min_size

						-- Multiply total range of text size by percent distance and add min text size
						text_size = (text_size_range * percent_distance) + option_values.adv_draw_text_min_size

						-- Resetting line count
						line_count = 0

						-- Drawing hash
						if option_values.all_objects_info_text_hash then
							BeginTextCommandDisplayText("STRING")
							SetTextWrap(-1.0, 2.0)
							SetTextOutline()
							SetTextScale(0.0, text_size)
							AddTextComponentSubstringPlayerName("Hash: " .. v.hash)
							EndTextCommandDisplayText(screen_x, screen_y)
							line_count = line_count + 1
						end

						-- Drawing name
						if option_values.all_objects_info_text_name then
							BeginTextCommandDisplayText("STRING")
							SetTextWrap(-1.0, 2.0)
							SetTextOutline()
							SetTextScale(0.0, text_size)
							AddTextComponentSubstringPlayerName("Name: " .. v.name)
							EndTextCommandDisplayText(screen_x, screen_y + (line_count * (text_size * 0.06)))
							line_count = line_count + 1
						end

						-- Drawing pos
						if option_values.all_objects_info_text_pos then
							BeginTextCommandDisplayText("STRING")
							SetTextWrap(-1.0, 2.0)
							SetTextOutline()
							SetTextScale(0.0, text_size)
							AddTextComponentSubstringPlayerName("Pos: " .. object_coords)
							EndTextCommandDisplayText(screen_x, screen_y + (line_count * (text_size * 0.06)))
							line_count = line_count + 1
						end

						-- Drawing rot
						if option_values.all_objects_info_text_rot then
							BeginTextCommandDisplayText("STRING")
							SetTextWrap(-1.0, 2.0)
							SetTextOutline()
							SetTextScale(0.0, text_size)
							AddTextComponentSubstringPlayerName("Rot: " .. GetEntityRotation(v.handle))
							EndTextCommandDisplayText(screen_x, screen_y + (line_count * (text_size * 0.06)))
							line_count = line_count + 1
						end
					end
				end
			end

			Wait(option_values.adv_text_draw_text_msec)
		end

		Wait(option_values.adv_idle_msec)
	end
end)



-- ####################### Updating player position if necessary #######################
CreateThread(function()
	while true do
		while (
			(setting_values.idgun and option_values.idgun_draw_box_around_object) or
			(setting_values.all_peds_info and option_values.all_peds_info_boxes) or
			(setting_values.all_peds_info and (option_values.all_peds_info_text_hash or option_values.all_peds_info_text_name or option_values.all_peds_info_text_pos or option_values.all_peds_info_text_rot)) or
			(setting_values.all_vehicles_info and option_values.all_vehicles_info_boxes) or
			(setting_values.all_vehicles_info and (option_values.all_vehicles_info_text_hash or option_values.all_vehicles_info_text_name or option_values.all_vehicles_info_text_pos or option_values.all_vehicles_info_text_rot)) or
			(setting_values.all_objects_info and option_values.all_objects_info_boxes) or
			(setting_values.all_objects_info and (option_values.all_objects_info_text_hash or option_values.all_objects_info_text_name or option_values.all_objects_info_text_pos or option_values.all_objects_info_text_rot))
		) do
			player_pos = GetEntityCoords(PlayerPedId())
			Wait(0)
		end
		Wait(option_values.adv_idle_msec)
	end
end)