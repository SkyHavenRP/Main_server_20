local denalifw = exports['denalifw-core']:GetCoreObject()
local PaymentTax = 15
local Bail = {}

RegisterNetEvent('denalifw-tow:server:DoBail', function(bool, vehInfo)
    local src = source
    local Player = denalifw.Functions.GetPlayer(src)
    if bool then
        if Player.PlayerData.money.cash >= Config.BailPrice then
            Bail[Player.PlayerData.citizenid] = Config.BailPrice
            Player.Functions.RemoveMoney('cash', Config.BailPrice, "tow-paid-bail")
            TriggerClientEvent('denalifw:Notify', src, 'You Have The Deposit of $'..Config.BailPrice..',- paid', 'success')
            TriggerClientEvent('denalifw-tow:client:SpawnVehicle', src, vehInfo)
        elseif Player.PlayerData.money.bank >= Config.BailPrice then
            Bail[Player.PlayerData.citizenid] = Config.BailPrice
            Player.Functions.RemoveMoney('bank', Config.BailPrice, "tow-paid-bail")
            TriggerClientEvent('denalifw:Notify', src, 'You Have Paid The Deposit Of $'..Config.BailPrice..' Paid', 'success')
            TriggerClientEvent('denalifw-tow:client:SpawnVehicle', src, vehInfo)
        else
            TriggerClientEvent('denalifw:Notify', src, 'Note Enough Money, The Deposit Is $'..Config.BailPrice..'', 'error')
        end
    else
        if Bail[Player.PlayerData.citizenid] ~= nil then
            Player.Functions.AddMoney('bank', Bail[Player.PlayerData.citizenid], "tow-bail-paid")
            Bail[Player.PlayerData.citizenid] = nil
            TriggerClientEvent('denalifw:Notify', src, 'You Got Back $'..Config.BailPrice..' From The Deposit', 'success')
        end
    end
end)

RegisterNetEvent('denalifw-tow:server:nano', function()
    local xPlayer = denalifw.Functions.GetPlayer(tonumber(source))
	xPlayer.Functions.AddItem("cryptostick", 1, false)
	TriggerClientEvent('inventory:client:ItemBox', source, denalifw.Shared.Items["cryptostick"], "add")
end)

RegisterNetEvent('denalifw-tow:server:11101110', function(drops)
    local src = source
    local Player = denalifw.Functions.GetPlayer(src)
    local drops = tonumber(drops)
    local bonus = 0
    local DropPrice = math.random(150, 170)
    if drops > 5 then
        bonus = math.ceil((DropPrice / 10) * 5)
    elseif drops > 10 then
        bonus = math.ceil((DropPrice / 10) * 7)
    elseif drops > 15 then
        bonus = math.ceil((DropPrice / 10) * 10)
    elseif drops > 20 then
        bonus = math.ceil((DropPrice / 10) * 12)
    end
    local price = (DropPrice * drops) + bonus
    local taxAmount = math.ceil((price / 100) * PaymentTax)
    local payment = price - taxAmount

    Player.Functions.AddJobReputation(1)
    Player.Functions.AddMoney("bank", payment, "tow-salary")
    TriggerClientEvent('chatMessage', source, "JOB", "warning", "You Received Your Salary From: $"..payment..", Gross: $"..price.." (From What $"..bonus.." Bonus) In $"..taxAmount.." Tax ("..PaymentTax.."%)")
end)

denalifw.Commands.Add("npc", "Toggle Npc Job", {}, false, function(source, args)
	TriggerClientEvent("jobs:client:ToggleNpc", source)
end)

denalifw.Commands.Add("tow", "Place A Car On The Back Of Your Flatbed", {}, false, function(source, args)
    local Player = denalifw.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "tow"  or Player.PlayerData.job.name == "mechanic" then
        TriggerClientEvent("denalifw-tow:client:TowVehicle", source)
    end
end)