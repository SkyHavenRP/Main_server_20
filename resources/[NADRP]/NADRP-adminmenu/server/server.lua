-- Variables
local NADRP = exports['NADRP-core']:GetCoreObject()
local frozen = false
local permissions = {
    ['kill'] = 'god',
    ['ban'] = 'admin',
    ['noclip'] = 'admin',
    ['kickall'] = 'admin',
    ['kick'] = 'admin'
}

-- Get Dealers
NADRP.Functions.CreateCallback('test:getdealers', function(source, cb)
    cb(exports['NADRP-drugs']:GetDealers())
end)

-- Get Players
NADRP.Functions.CreateCallback('test:getplayers', function(source, cb) -- WORKS
    local players = {}
    for k, v in pairs(NADRP.Functions.GetPlayers()) do
        local targetped = GetPlayerPed(v)
        local ped = NADRP.Functions.GetPlayer(v)
        players[#players+1] = {
            name = ped.PlayerData.charinfo.firstname .. ' ' .. ped.PlayerData.charinfo.lastname .. ' | (' .. GetPlayerName(v) .. ')',
            id = v,
            coords = GetEntityCoords(targetped),
            cid = ped.PlayerData.charinfo.firstname .. ' ' .. ped.PlayerData.charinfo.lastname,
            citizenid = ped.PlayerData.citizenid,
            sources = GetPlayerPed(ped.PlayerData.source),
            sourceplayer= ped.PlayerData.source

        }
    end
        -- Sort players list by source ID (1,2,3,4,5, etc) --
        table.sort(players, function(a, b)
            return a.id < b.id
        end)
        ------
    cb(players)
end)

NADRP.Functions.CreateCallback('NADRP-admin:server:getrank', function(source, cb)
    local src = source
    if NADRP.Functions.HasPermission(src, 'god') or IsPlayerAceAllowed(src, 'command') then
        cb(true)
    else
        cb(false)
    end
end)

-- Functions

local function tablelength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-- Events

RegisterNetEvent('NADRP-admin:server:GetPlayersForBlips', function()
    local src = source
    local players = {}
    for k, v in pairs(NADRP.Functions.GetPlayers()) do
        local targetped = GetPlayerPed(v)
        local ped = NADRP.Functions.GetPlayer(v)
        players[#players+1] = {
            name = ped.PlayerData.charinfo.firstname .. ' ' .. ped.PlayerData.charinfo.lastname .. ' | ' .. GetPlayerName(v),
            id = v,
            coords = GetEntityCoords(targetped),
            cid = ped.PlayerData.charinfo.firstname .. ' ' .. ped.PlayerData.charinfo.lastname,
            citizenid = ped.PlayerData.citizenid,
            sources = GetPlayerPed(ped.PlayerData.source),
            sourceplayer= ped.PlayerData.source
        }
    end
    TriggerClientEvent('NADRP-admin:client:Show', src, players)
end)

RegisterNetEvent('NADRP-admin:server:kill', function(player)
    TriggerClientEvent('hospital:client:KillPlayer', player.id)
end)

RegisterNetEvent('NADRP-admin:server:revive', function(player)
    TriggerClientEvent('hospital:client:Revive', player.id)
end)

RegisterNetEvent('NADRP-admin:server:kick', function(player, reason)
    local src = source
    if NADRP.Functions.HasPermission(src, permissions['kick']) or IsPlayerAceAllowed(src, 'command')  then
        TriggerEvent('NADRP-log:server:CreateLog', 'bans', 'Player Kicked', 'red', string.format('%s was kicked by %s for %s', GetPlayerName(player.id), GetPlayerName(src), reason), true)
        DropPlayer(player.id, Lang:t("info.kicked_server") .. ':\n' .. reason .. '\n\n' .. Lang:t("info.check_discord") .. NADRP.Config.Server.discord)
    end
end)

RegisterNetEvent('NADRP-admin:server:ban', function(player, time, reason)
    local src = source
    if NADRP.Functions.HasPermission(src, permissions['ban']) or IsPlayerAceAllowed(src, 'command') then
        local time = tonumber(time)
        local banTime = tonumber(os.time() + time)
        if banTime > 2147483647 then
            banTime = 2147483647
        end
        local timeTable = os.date('*t', banTime)
        MySQL.Async.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            GetPlayerName(player.id),
            NADRP.Functions.GetIdentifier(player.id, 'license'),
            NADRP.Functions.GetIdentifier(player.id, 'discord'),
            NADRP.Functions.GetIdentifier(player.id, 'ip'),
            reason,
            banTime,
            GetPlayerName(src)
        })
        TriggerClientEvent('chat:addMessage', -1, {
            template = "<div class=chat-message server'><strong>ANNOUNCEMENT | {0} has been banned:</strong> {1}</div>",
            args = {GetPlayerName(player.id), reason}
        })
        TriggerEvent('NADRP-log:server:CreateLog', 'bans', 'Player Banned', 'red', string.format('%s was banned by %s for %s', GetPlayerName(player.id), GetPlayerName(src), reason), true)
        if banTime >= 2147483647 then
            DropPlayer(player.id, Lang:t("info.banned") .. '\n' .. reason .. Lang:t("info.ban_perm") .. NADRP.Config.Server.discord)
        else
            DropPlayer(player.id, Lang:t("info.banned") .. '\n' .. reason .. Lang:t("info.ban_expires") .. timeTable['day'] .. '/' .. timeTable['month'] .. '/' .. timeTable['year'] .. ' ' .. timeTable['hour'] .. ':' .. timeTable['min'] .. '\n🔸 Check our Discord for more information: ' .. NADRP.Config.Server.discord)
        end
    end
end)

RegisterNetEvent('NADRP-admin:server:spectate')
AddEventHandler('NADRP-admin:server:spectate', function(player)
    local src = source
    local targetped = GetPlayerPed(player.id)
    local coords = GetEntityCoords(targetped)
    TriggerClientEvent('NADRP-admin:client:spectate', src, player.id, coords)
end)

RegisterNetEvent('NADRP-admin:server:freeze')
AddEventHandler('NADRP-admin:server:freeze', function(player)
    local target = GetPlayerPed(player.id)
    if not frozen then
        frozen = true
        FreezeEntityPosition(target, true)
    else
        frozen = false
        FreezeEntityPosition(target, false)
    end
end)

RegisterNetEvent('NADRP-admin:server:goto', function(player)
    local src = source
    local admin = GetPlayerPed(src)
    local coords = GetEntityCoords(GetPlayerPed(player.id))
    SetEntityCoords(admin, coords)
end)

RegisterNetEvent('NADRP-admin:server:intovehicle', function(player)
    local src = source
    local admin = GetPlayerPed(src)
    -- local coords = GetEntityCoords(GetPlayerPed(player.id))
    local targetPed = GetPlayerPed(player.id)
    local vehicle = GetVehiclePedIsIn(targetPed,false)
    local seat = -1
    if vehicle ~= 0 then
        for i=0,8,1 do
            if GetPedInVehicleSeat(vehicle,i) == 0 then
                seat = i
                break
            end
        end
        if seat ~= -1 then
            SetPedIntoVehicle(admin,vehicle,seat)
            TriggerClientEvent('NADRP:Notify', src, Lang:t("sucess.entered_vehicle"), 'success', 5000)
        else
            TriggerClientEvent('NADRP:Notify', src, Lang:t("error.no_free_seats"), 'danger', 5000)
        end
    end
end)


RegisterNetEvent('NADRP-admin:server:bring', function(player)
    local src = source
    local admin = GetPlayerPed(src)
    local coords = GetEntityCoords(admin)
    local target = GetPlayerPed(player.id)
    SetEntityCoords(target, coords)
end)

RegisterNetEvent('NADRP-admin:server:inventory', function(player)
    local src = source
    TriggerClientEvent('NADRP-admin:client:inventory', src, player.id)
end)

RegisterNetEvent('NADRP-admin:server:cloth', function(player)
    TriggerClientEvent('NADRP-clothing:client:openMenu', player.id)
end)

RegisterNetEvent('NADRP-admin:server:setPermissions', function(targetId, group)
    local src = source
    if NADRP.Functions.HasPermission(src, 'god') or IsPlayerAceAllowed(src, 'command') then
        NADRP.Functions.AddPermission(targetId, group[1].rank)
        TriggerClientEvent('NADRP:Notify', targetId, Lang:t("info.rank_level")..group[1].label)
    end
end)

RegisterNetEvent('NADRP-admin:server:SendReport', function(name, targetSrc, msg)
    local src = source
    if NADRP.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command') then
        if NADRP.Functions.IsOptin(src) then
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = true,
                args = {Lang:t("info.admin_report")..name..' ('..targetSrc..')', msg}
            })
        end
    end
end)

RegisterNetEvent('NADRP-admin:server:Staffchat:addMessage', function(name, msg)
    local src = source
    if NADRP.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command') then
        if NADRP.Functions.IsOptin(src) then
            TriggerClientEvent('chat:addMessage', src, Lang:t("info.staffchat")..name, 'error', msg)
        end
    end
end)

RegisterNetEvent('NADRP-admin:server:SaveCar', function(mods, vehicle, hash, plate)
    local src = source
    local Player = NADRP.Functions.GetPlayer(src)
    local result = MySQL.Sync.fetchAll('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })
    if result[1] == nil then
        MySQL.Async.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            Player.PlayerData.license,
            Player.PlayerData.citizenid,
            vehicle.model,
            vehicle.hash,
            json.encode(mods),
            plate,
            0
        })
        TriggerClientEvent('NADRP:Notify', src, Lang:t("success.success_vehicle_owner"), 'success', 5000)
    else
        TriggerClientEvent('NADRP:Notify', src, Lang:t("error.failed_vehicle_owner"), 'error', 3000)
    end
end)

-- Commands

NADRP.Commands.Add('blips', Lang:t("commands.blips_for_player"), {}, false, function(source)
    local src = source
    TriggerClientEvent('NADRP-admin:client:toggleBlips', src)
end, 'admin')

NADRP.Commands.Add('names', Lang:t("commands.player_name_overhead"), {}, false, function(source)
    local src = source
    TriggerClientEvent('NADRP-admin:client:toggleNames', src)
end, 'admin')

NADRP.Commands.Add('coords', Lang:t("commands.coords_dev_command"), {}, false, function(source)
    local src = source
    TriggerClientEvent('NADRP-admin:client:ToggleCoords', src)
end, 'admin')

NADRP.Commands.Add('noclip', Lang:t("commands.toogle_noclip"), {}, false, function(source)
    local src = source
    TriggerClientEvent('NADRP-admin:client:ToggleNoClip', src)
end, 'admin')

NADRP.Commands.Add('admincar', Lang:t("commands.save_vehicle_garage"), {}, false, function(source, args)
    local ply = NADRP.Functions.GetPlayer(source)
    TriggerClientEvent('NADRP-admin:client:SaveCar', source)
end, 'admin')

NADRP.Commands.Add('announce', Lang:t("commands.make_announcement"), {}, false, function(source, args)
    local msg = table.concat(args, ' ')
    if msg == '' then return end
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 0, 0},
        multiline = true,
        args = {"Announcement", msg}
    })
end, 'admin')

NADRP.Commands.Add('admin', Lang:t("commands.open_admin"), {}, false, function(source, args)
    TriggerClientEvent('NADRP-admin:client:openMenu', source)
end, 'admin')

NADRP.Commands.Add('report', Lang:t("info.admin_report"), {{name='message', help='Message'}}, true, function(source, args)
    local src = source
    local msg = table.concat(args, ' ')
    local Player = NADRP.Functions.GetPlayer(source)
    TriggerClientEvent('NADRP-admin:client:SendReport', -1, GetPlayerName(src), src, msg)
    TriggerEvent('NADRP-log:server:CreateLog', 'report', 'Report', 'green', '**'..GetPlayerName(source)..'** (CitizenID: '..Player.PlayerData.citizenid..' | ID: '..source..') **Report:** ' ..msg, false)
end)

NADRP.Commands.Add('staffchat', Lang:t("commands.staffchat_message"), {{name='message', help='Message'}}, true, function(source, args)
    local msg = table.concat(args, ' ')
    TriggerClientEvent('NADRP-admin:client:SendStaffChat', -1, GetPlayerName(source), msg)
end, 'admin')

NADRP.Commands.Add('givenuifocus', Lang:t("commands.nui_focus"), {{name='id', help='Player id'}, {name='focus', help='Set focus on/off'}, {name='mouse', help='Set mouse on/off'}}, true, function(source, args)
    local playerid = tonumber(args[1])
    local focus = args[2]
    local mouse = args[3]
    TriggerClientEvent('NADRP-admin:client:GiveNuiFocus', playerid, focus, mouse)
end, 'admin')

NADRP.Commands.Add('warn', Lang:t("commands.warn_a_player"), {{name='ID', help='Player'}, {name='Reason', help='Mention a reason'}}, true, function(source, args)
    local targetPlayer = NADRP.Functions.GetPlayer(tonumber(args[1]))
    local senderPlayer = NADRP.Functions.GetPlayer(source)
    table.remove(args, 1)
    local msg = table.concat(args, ' ')
    local myName = senderPlayer.PlayerData.name
    local warnId = 'WARN-'..math.random(1111, 9999)
    if targetPlayer ~= nil then
		TriggerClientEvent('chat:addMessage', targetPlayer.PlayerData.source, { args = { "SYSTEM", Lang:t("info.warning_chat_message")..GetPlayerName(source).."," .. Lang:t("info.reason") .. ": "..msg }, color = 255, 0, 0 })
		TriggerClientEvent('chat:addMessage', source, { args = { "SYSTEM", Lang:t("info.warning_staff_message")..GetPlayerName(targetPlayer.PlayerData.source)..", for: "..msg }, color = 255, 0, 0 })
        MySQL.Async.insert('INSERT INTO player_warns (senderIdentifier, targetIdentifier, reason, warnId) VALUES (?, ?, ?, ?)', {
            senderPlayer.PlayerData.license,
            targetPlayer.PlayerData.license,
            msg,
            warnId
        })
    else
        TriggerClientEvent('NADRP:Notify', source, Lang:t("error.not_online"), 'error')
    end
end, 'admin')

NADRP.Commands.Add('checkwarns', Lang:t("commands.check_player_warning"), {{name='id', help='Player'}, {name='Warning', help='Number of warning, (1, 2 or 3 etc..)'}}, false, function(source, args)
    if args[2] == nil then
        local targetPlayer = NADRP.Functions.GetPlayer(tonumber(args[1]))
        local result = MySQL.Sync.fetchAll('SELECT * FROM player_warns WHERE targetIdentifier = ?', { targetPlayer.PlayerData.license })
        TriggerClientEvent('chat:addMessage', source, 'SYSTEM', 'warning', targetPlayer.PlayerData.name..' has '..tablelength(result)..' warnings!')
    else
        local targetPlayer = NADRP.Functions.GetPlayer(tonumber(args[1]))
        local warnings = MySQL.Sync.fetchAll('SELECT * FROM player_warns WHERE targetIdentifier = ?', { targetPlayer.PlayerData.license })
        local selectedWarning = tonumber(args[2])
        if warnings[selectedWarning] ~= nil then
            local sender = NADRP.Functions.GetPlayer(warnings[selectedWarning].senderIdentifier)
            TriggerClientEvent('chat:addMessage', source, 'SYSTEM', 'warning', targetPlayer.PlayerData.name..' has been warned by '..sender.PlayerData.name..', Reason: '..warnings[selectedWarning].reason)
        end
    end
end, 'admin')

NADRP.Commands.Add('delwarn', Lang:t("commands.delete_player_warning"), {{name='id', help='Player'}, {name='Warning', help='Number of warning, (1, 2 or 3 etc..)'}}, true, function(source, args)
    local targetPlayer = NADRP.Functions.GetPlayer(tonumber(args[1]))
    local warnings = MySQL.Sync.fetchAll('SELECT * FROM player_warns WHERE targetIdentifier = ?', { targetPlayer.PlayerData.license })
    local selectedWarning = tonumber(args[2])
    if warnings[selectedWarning] ~= nil then
        local sender = NADRP.Functions.GetPlayer(warnings[selectedWarning].senderIdentifier)
        TriggerClientEvent('chat:addMessage', source, 'SYSTEM', 'warning', 'You have deleted warning ('..selectedWarning..') , Reason: '..warnings[selectedWarning].reason)
        MySQL.Async.execute('DELETE FROM player_warns WHERE warnId = ?', { warnings[selectedWarning].warnId })
    end
end, 'admin')

NADRP.Commands.Add('reportr', Lang:t("commands.reply_to_report"), {{name='id', help='Player'}, {name = 'message', help = 'Message to respond with'}}, false, function(source, args, rawCommand)
    local src = source
    local playerId = tonumber(args[1])
    table.remove(args, 1)
    local msg = table.concat(args, ' ')
    local OtherPlayer = NADRP.Functions.GetPlayer(playerId)
    if msg == '' then return end
    if not OtherPlayer then return TriggerClientEvent('NADRP:Notify', src, 'Player is not online', 'error') end
    if not NADRP.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command') ~= 1 then return end
    TriggerClientEvent('chat:addMessage', playerId, {
        color = {255, 0, 0},
        multiline = true,
        args = {'Admin Response', msg}
    })
    TriggerClientEvent('chat:addMessage', src, {
        color = {255, 0, 0},
        multiline = true,
        args = {'Report Response ('..playerId..')', msg}
    })
    TriggerClientEvent('NADRP:Notify', src, 'Reply Sent')
    TriggerEvent('NADRP-log:server:CreateLog', 'report', 'Report Reply', 'red', '**'..GetPlayerName(src)..'** replied on: **'..OtherPlayer.PlayerData.name.. ' **(ID: '..OtherPlayer.PlayerData.source..') **Message:** ' ..msg, false)
end, 'admin')

NADRP.Commands.Add('setmodel', Lang:t("commands.change_ped_model"), {{name='model', help='Name of the model'}, {name='id', help='Id of the Player (empty for yourself)'}}, false, function(source, args)
    local model = args[1]
    local target = tonumber(args[2])
    if model ~= nil or model ~= '' then
        if target == nil then
            TriggerClientEvent('NADRP-admin:client:SetModel', source, tostring(model))
        else
            local Trgt = NADRP.Functions.GetPlayer(target)
            if Trgt ~= nil then
                TriggerClientEvent('NADRP-admin:client:SetModel', target, tostring(model))
            else
                TriggerClientEvent('NADRP:Notify', source, Lang:t("error.not_online"), 'error')
            end
        end
    else
        TriggerClientEvent('NADRP:Notify', source, Lang:t("error.failed_set_model"), 'error')
    end
end, 'admin')

NADRP.Commands.Add('setspeed', Lang:t("commands.set_player_foot_speed"), {}, false, function(source, args)
    local speed = args[1]
    if speed ~= nil then
        TriggerClientEvent('NADRP-admin:client:SetSpeed', source, tostring(speed))
    else
        TriggerClientEvent('NADRP:Notify', source, Lang:t("error.failed_set_speed"), 'error')
    end
end, 'admin')

NADRP.Commands.Add('reporttoggle', Lang:t("commands.report_toggle"), {}, false, function(source, args)
    local src = source
    NADRP.Functions.ToggleOptin(src)
    if NADRP.Functions.IsOptin(src) then
        TriggerClientEvent('NADRP:Notify', src, Lang:t("success.receive_reports"), 'success')
    else
        TriggerClientEvent('NADRP:Notify', src, Lang:t("error.no_receive_report"), 'error')
    end
end, 'admin')

NADRP.Commands.Add('kickall', Lang:t("commands.kick_all"), {}, false, function(source, args)
    local src = source
    if src > 0 then
        local reason = table.concat(args, ' ')
        if NADRP.Functions.HasPermission(src, 'god') or IsPlayerAceAllowed(src, 'command') then
            if reason and reason ~= '' then
                for k, v in pairs(NADRP.Functions.GetPlayers()) do
                    local Player = NADRP.Functions.GetPlayer(v)
                    if Player then
                        DropPlayer(Player.PlayerData.source, reason)
                    end
                end
            else
                TriggerClientEvent('NADRP:Notify', src, Lang:t("info.no_reason_specified"), 'error')
            end
        end
    else
        for k, v in pairs(NADRP.Functions.GetPlayers()) do
            local Player = NADRP.Functions.GetPlayer(v)
            if Player then
                DropPlayer(Player.PlayerData.source, Lang:t("info.server_restart") .. NADRP.Config.Server.discord)
            end
        end
    end
end, 'god')

NADRP.Commands.Add('setammo', Lang:t("commands.ammo_amount_set"), {{name='amount', help='Amount of bullets, for example: 20'}, {name='weapon', help='Name of the weapen, for example: WEAPON_VINTAGEPISTOL'}}, false, function(source, args)
    local src = source
    local weapon = args[2]
    local amount = tonumber(args[1])

    if weapon ~= nil then
        TriggerClientEvent('NADRP-weapons:client:SetWeaponAmmoManual', src, weapon, amount)
    else
        TriggerClientEvent('NADRP-weapons:client:SetWeaponAmmoManual', src, 'current', amount)
    end
end, 'admin')
