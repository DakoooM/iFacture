TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

RegisterServerEvent("iFacture:openMenuForOtherPlayer")
AddEventHandler("iFacture:openMenuForOtherPlayer", function(s)
    local source = tonumber(source)
    TriggerClientEvent("iFacture:openThis", s.PlayerId, s.montant, s.entreprise, s.createdBy, source, s.reason)
    TriggerClientEvent("esx:showNotification", s.PlayerId, "~g~<C>Nouveau</C>~s~\nVous avez recu une facture de " ..s.montant.. "$ crée par " ..GetPlayerName(source))
    TriggerClientEvent("esx:showNotification", source, "~g~<C>Succès</C>~s~\nVous avez envoyez une facture de " ..s.montant.. "$ a " ..GetPlayerName(s.PlayerId))
end)

RegisterServerEvent("iFacture:notPayThisIs")
AddEventHandler("iFacture:notPayThisIs", function(s)
    TriggerClientEvent("esx:showNotification", s.source, "~r~<C>Attention</C>~o~\n" ..GetPlayerName(source).. " a refusée de payez votre facture")
end)

ESX.RegisterServerCallback("iFacture:payOrNot", function(src, Callback, type, money, playerId)
    local player = ESX.GetPlayerFromId(src)
    local otherPlayer = ESX.GetPlayerFromId(playerId)
    local money = tonumber(money)

    if type == "bank" then
        local getBankMoney = player.getAccount(type).money
        if getBankMoney >= money then
            if (otherPlayer) then
                Callback(true)
                player.removeAccountMoney(type, money);
                otherPlayer.addAccountMoney(type, money);
                TriggerClientEvent("esx:showNotification", otherPlayer.source, "~g~<C>Paiement</C>~s~\nVous avez recu " ..tostring(money).. "$ de " ..player.getName())
            else
                Callback(false)
            end
        else
            Callback(false)
        end
    elseif type == "cash" then
        local getCashMoney = player.getMoney()
        if getCashMoney >= money then
            if (otherPlayer) then
                player.removeMoney(money)
                otherPlayer.addMoney(money)
                TriggerClientEvent("esx:showNotification", otherPlayer.source, "~g~<C>Paiement</C>~s~\nVous avez recu " ..tostring(money).. "$ de " ..player.getName())
                Callback(true)
            else
                Callback(false)
            end
        else
            Callback(false)
        end
    end
end)