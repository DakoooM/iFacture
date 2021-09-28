local iFacture = {
	openClientMenu  = "F6"
    Config = {
        sharedObject = "esx:getSharedObject"
    }
}

CreateThread(function()
    while ESX == nil do
        TriggerEvent(iFacture.Config.sharedObject, function(obj) ESX = obj end)
        Wait(1)
    end
    while not ESX.IsPlayerLoaded() do Wait(2) end
    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
    ESX.PlayerData.job = job;
end)

iFacture.BoardInput = function(meTexting, text, TestIncase, Maximum)
	AddTextEntry(meTexting, text)
	DisplayOnscreenKeyboard(1, meTexting, "", TestIncase, "", "", "", Maximum)
	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do Wait(0) end
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Wait(500)
		return result
	else
		Wait(500)
		return nil
	end
end

local clientMenuOpened = false;
local mainClientMenu = RageUI.CreateMenu("Facturation", "Facturer", 80, 100)
mainClientMenu.Closed = function()
    clientMenuOpened = false;
end

iFacture.openClientMenu = function()
    if ESX.PlayerData.job.name ~= "unemployed" then
        if clientMenuOpened == false then
            if clientMenuOpened then
                clientMenuOpened = false;
            else
                RageUI.Visible(mainClientMenu, true)
                clientMenuOpened = true;
                CreateThread(function()
                    while clientMenuOpened do
                        Wait(1)
                        RageUI.IsVisible(mainClientMenu, function()
                            RageUI.Separator("Votre Entreprise: " ..ESX.PlayerData.job.label)
                            
                            RageUI.Button("Créer une facture", nil, {}, true, {
                                onActive = function()
                                    local player, distance = ESX.Game.GetClosestPlayer()
                                    local otherCoordPlayer = GetEntityCoords(GetPlayerPed(player))
                                    if not IsPedInAnyVehicle(PlayerPedId(), false) then
                                        if player ~= -1 and distance <= 2.5 then
                                            DrawMarker(22, otherCoordPlayer.x , otherCoordPlayer.y , otherCoordPlayer.z+1.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 0, 0, 255 , false, false, 0.0, true, false, false, false)
                                        end
                                    end
                                end,
                                onSelected = function()
                                    local factureNumber = iFacture.BoardInput("GET_FACTURE_MONTANT", "Montant de la facture", "", 15)
                                    if factureNumber == nil or factureNumber == "" then
                                        ESX.ShowNotification("~r~<C>Facturation</C>\n~o~Veuillez rentrez un prix de la facture")
                                    else
                                        if tonumber(factureNumber) then
                                            local player, distance = ESX.Game.GetClosestPlayer()
                                            if (player ~= -1 and distance <= 2.5) then
                                                local factureReason = iFacture.BoardInput("GET_FACTURE_REASON", "Raison de la facture", "", 50)
                                                if factureReason == nil or factureReason == "" or not tostring(factureReason) then
                                                   return ESX.ShowNotification("~r~<C>Facturation</C>\n~o~Veuillez rentrez une raison de la facture")
                                                end
                                                TriggerServerEvent("iFacture:openMenuForOtherPlayer", {
                                                    PlayerId = GetPlayerServerId(player),
                                                    createdBy = GetPlayerName(PlayerId()),
                                                    montant = tonumber(factureNumber),
                                                    entreprise = ESX.PlayerData.job.label,
                                                    reason = tostring(factureReason)
                                                })
                                            else
                                                ESX.ShowNotification("~r~<C>Facturation</C>~o~\nIl n'y a aucun joueur autour de vous")
                                            end
                                        else
                                            ESX.ShowNotification("~r~<C>Facturation</C>\n~o~Veuillez rentrez un nombre")
                                        end
                                    end
                                end
                            })
                        end)
                    end
                end)
            end
        end
    else
        print("Vous ne pouvez ouvir cela sans avoir de métier")
    end
end

local IndexforPaymentMethod = 1;
local serverMenuOpened = false;
local mainServerMenu = RageUI.CreateMenu("Facturation", "Vous avez recu une facture", 80, 100)
mainServerMenu.Closable = false;

iFacture.openServerMenu = function(montant, entreprise, createdBy, playerId, reason)
    if serverMenuOpened == false then
        if serverMenuOpened then
            serverMenuOpened = false;
        else
            RageUI.Visible(mainServerMenu, true);
            serverMenuOpened = true;
            CreateThread(function()
                while serverMenuOpened do
                    Wait(1)
                    RageUI.IsVisible(mainServerMenu, function()
                        RageUI.Separator("Crée par: ~b~" ..tostring(createdBy).. "~s~")
                        RageUI.Separator("Montant: ~g~" ..tostring(montant).. "$~s~")
                        RageUI.Separator("Entreprise: " ..tostring(entreprise).. "")

                        RageUI.List("Payez la facture", {{Name = "Liquide"}, {Name = "Banque"}}, IndexforPaymentMethod, "Raison: " ..reason, {}, true, {
                            onListChange = function(Index)
                                IndexforPaymentMethod = Index;
                            end,
                            onSelected = function(Index, Button)
                                if Button.Name == "Liquide" then
                                    ESX.TriggerServerCallback("iFacture:payOrNot", function(hasMoney) 
                                        if (hasMoney) then
                                            ESX.ShowNotification("~g~<C>Paiement</C>\n~o~Vous avez payez " ..tostring(montant).. "$")
                                            RageUI.CloseAll()
                                            serverMenuOpened = false;
                                        else
                                            ESX.ShowNotification("~r~<C>Facturation</C>\n~o~Vous n'avez pas assez d'argent")
                                        end
                                    end, "cash", montant, playerId)
                                elseif Button.Name == "Banque" then
                                    ESX.TriggerServerCallback("iFacture:payOrNot", function(hasMoney) 
                                        if (hasMoney) then
                                            ESX.ShowNotification("~g~<C>Paiement</C>\n~o~Vous avez payez " ..tostring(montant).. "$")
                                            RageUI.CloseAll()
                                            serverMenuOpened = false;
                                        else
                                            ESX.ShowNotification("~r~<C>Facturation</C>\n~o~Vous n'avez pas assez d'argent")
                                        end
                                    end, "bank", montant, playerId)
                                end
                            end
                        })

                        RageUI.Button("Refuser la Facture", nil, {}, true, {
                            onSelected = function()
                                ESX.ShowNotification("~r~<C>Facturation</C>\n~o~Vous avez refusé la facture de " ..tostring(createdBy))
                                TriggerServerEvent("iFacture:notPayThisIs", {source = playerId})
                                RageUI.CloseAll()
                                serverMenuOpened = false;
                            end
                        })
                    end)
                end
            end)
        end
    end
end

RegisterNetEvent("iFacture:openThis")
AddEventHandler("iFacture:openThis", function(montant, entreprise, createdBy, PlayerId, reason)
    iFacture.openServerMenu(montant, entreprise, createdBy, PlayerId, reason)
end)

Keys.Register("F7", "facture", "open f6 menu facture", iFacture.openClientMenu)
