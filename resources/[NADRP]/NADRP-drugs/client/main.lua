denalifw = exports['denalifw-core']:GetCoreObject()

RegisterNetEvent('denalifw-drugs:AddWeapons', function()
    Config.Dealers[2]["products"][#Config.Dealers[2]["products"]+1] = {
        name = "weapon_snspistol",
        price = 5000,
        amount = 1,
        info = {
            serie = tostring(denalifw.Shared.RandomInt(2) .. denalifw.Shared.RandomStr(3) .. denalifw.Shared.RandomInt(1) .. denalifw.Shared.RandomStr(2) .. denalifw.Shared.RandomInt(3) .. denalifw.Shared.RandomStr(4))
        },
        type = "item",
        slot = 5,
        minrep = 200,
    }
    Config.Dealers[3]["products"][#Config.Dealers[3]["products"]+1] = {
        name = "weapon_snspistol",
        price = 5000,
        amount = 1,
        info = {
            serie = tostring(denalifw.Shared.RandomInt(2) .. denalifw.Shared.RandomStr(3) .. denalifw.Shared.RandomInt(1) .. denalifw.Shared.RandomStr(2) .. denalifw.Shared.RandomInt(3) .. denalifw.Shared.RandomStr(4))
        },
        type = "item",
        slot = 5,
        minrep = 200,
    }
end)