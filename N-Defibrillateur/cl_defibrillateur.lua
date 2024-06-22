---------------------------------------------------------------
ESX = exports['es_extended']:getSharedObject()
local lib = exports['ox_lib']
----------------------------------------------------------------
--------------------------------------------- defibrillateur
local isUseDefibrillateur = false
local DefibrillateurZones = {}

local function drawNativeText(str)
    -- Configuration des propriétés du texte
    SetTextFont(0)           -- Définit la police du texte
    SetTextProportional(1)   -- Texte proportionnel à l'écran
    SetTextScale(0.35, 0.35) -- Définit la taille du texte
    SetTextCentre(true)      -- Centre le texte
    SetTextDropshadow(0, 0, 0, 0, 255) -- Ajoute une ombre au texte
    SetTextEdge(1, 0, 0, 0, 255)       -- Définit les contours du texte
    SetTextEntry("STRING")
    AddTextComponentString(str)
    
    -- Positionnement du texte
    SetTextJustification(0) -- Alignement du texte (0 = gauche, 1 = centré, 2 = droite)
    SetTextWrap(0.0, 1.0)   -- Définit où le texte doit s'enrouler sur l'écran

    -- Dessine le texte à l'écran
    DrawText(0.495, 0.05)     -- Les coordonnées (x, y) pour placer le texte (0.5, 0.05 pour le haut et centré)
end

RegisterNetEvent('esx:defibrillateur:use')
AddEventHandler('esx:defibrillateur:use', function()
    if not isUseDefibrillateur then
        isUseDefibrillateur = true
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local boneIndex = GetPedBoneIndex(playerPed, 57005) -- Bone index pour la main droite

        -- Charge le modèle
        local model = GetHashKey('defibrillateur_automatique')
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(1)
        end

        -- Crée l'objet dans la main du joueur
        local Defibrillateur = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
        AttachEntityToEntity(Defibrillateur, playerPed, boneIndex, 0.36, 0.0, 0.04, 30.0, -90.0, -110.0, true, true, false, true, 1, true)

        -- Crée une copie de l'objet au sol devant le joueur sans collision (local)
        local groundDefibrillateur = CreateObject(model, coords.x, coords.y + 1.0, coords.z - 1.0, false, true, true)
        SetEntityHeading(groundDefibrillateur, GetEntityHeading(playerPed))
        SetEntityCollision(groundDefibrillateur, false, false)

        -- Boucle pour vérifier les commandes du joueur
        while DoesEntityExist(Defibrillateur) do
            Citizen.Wait(0)

            drawNativeText("[E] Placer | [X] Annuler")

            -- Met à jour la position et l'orientation de l'objet au sol devant le joueur
            local playerCoords = GetEntityCoords(playerPed)
            local playerForward = GetEntityForwardVector(playerPed)
            local stickCoords = playerCoords + playerForward * 1.0
            SetEntityCoordsNoOffset(groundDefibrillateur, stickCoords.x, stickCoords.y, stickCoords.z - 0.95, true, true, true)
            SetEntityHeading(groundDefibrillateur, GetEntityHeading(playerPed))
            PlaceObjectOnGroundProperly(groundDefibrillateur)

            -- Rend le stop stick transparent
            SetEntityAlpha(groundDefibrillateur, 150, false)  -- 150 est la valeur de transparence (0-255)


            -- Trouve le véhicule le plus proche
            local vehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 5.0, 0, 70)

            if vehicle and DoesEntityExist(vehicle) then
                -- Marque le véhicule comme une entité de mission pour éviter qu'il despawn
                SetEntityAsMissionEntity(vehicle, true, true)
            end

            if IsControlJustReleased(0, 73) then -- 73 correspond à la touche X
                DeleteObject(Defibrillateur)
                DeleteObject(groundDefibrillateur)
                isUseDefibrillateur = false
                break
            end

            if IsControlJustReleased(0, 38) then -- 38 correspond à la touche E
                DeleteObject(Defibrillateur)
                DeleteObject(groundDefibrillateur)
                isUseDefibrillateur = false
                
                RequestAnimSet( "move_ped_crouched" )
                while ( not HasAnimSetLoaded( "move_ped_crouched" ) ) do 
                    Citizen.Wait( 100 )
                end 
            
                SetPedMovementClipset( playerPed, "move_ped_crouched", 0.25 )  

                TriggerServerEvent('esx:defibrillateur:place')

                if lib:progressCircle({
                    duration = 1000,
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = false,
                    disable = {
                        car = true,
                        move = true
                    },
                    anim = {
                        dict = 'pickup_object',
                        clip = 'putdown_low'
                    },
                }) then         
                    local model = GetHashKey('defibrillateur_automatique')
                    local DefibrillateurShared = CreateObject(model, stickCoords.x, stickCoords.y, stickCoords.z, true, true, true)
                    SetEntityHeading(DefibrillateurShared, GetEntityHeading(playerPed))
            
                    -- Place correctement l'objet sur le sol en fonction du terrain
                    PlaceObjectOnGroundProperly(DefibrillateurShared)

                    -- Paramètres de la zone ciblable
                    local zoneParameters = {
                        coords = vector3(stickCoords.x, stickCoords.y, stickCoords.z - 1.0),
                        size = vector3(2.0, 2.0, 2.0),
                        rotation = 0,
                        debug = false,
                        drawSprite = false,
                        options = {
                            {
                                label = "Utilisation",
                                icon = "fa-solid fa-arrow-right",
                                onSelect = function(data)
                                    TriggerEvent('esx:defibrillateur:start')
                                end
                            },
                            {
                                label = "Ramasser",
                                icon = "fa-solid fa-hand",
                                onSelect = function(data)

                                    RequestAnimSet( "move_ped_crouched" )
                                    while ( not HasAnimSetLoaded( "move_ped_crouched" ) ) do 
                                        Citizen.Wait( 100 )
                                    end 
                                
                                    SetPedMovementClipset( playerPed, "move_ped_crouched", 0.25 )        
                        
                                    if lib:progressCircle({
                                        duration = 1000,
                                        position = 'bottom',
                                        useWhileDead = false,
                                        canCancel = false,
                                        disable = {
                                            car = true,
                                            move = true
                                        },
                                        anim = {
                                            dict = 'pickup_object',
                                            clip = 'putdown_low'
                                        },
                                    }) then       
                                                            
                                        -- Logique pour ramasser ou détruire le stop stick
                                        DeleteObject(DefibrillateurShared)
                                    
                                        -- Trouve et supprime la zone ciblable correspondante
                                        for i, v in ipairs(DefibrillateurZones) do
                                            if v.entity == DefibrillateurShared then
                                                exports.ox_target:removeZone(v.zoneId)
                                                table.remove(DefibrillateurZones, i) -- Supprime l'entrée de la table
                                                break
                                            end
                                        end

                                        ResetPedMovementClipset( playerPed, 0 )
                                        TriggerServerEvent('esx:defibrillateur:recup')
                                    end
                                
                                    -- Actions supplémentaires ici, comme une notification
                                end                        
                            }
                        },
                        distance = 2.0
                    }
            
                    -- Ajoute la zone ciblable et enregistre son ID
                    local zoneId = exports.ox_target:addBoxZone(zoneParameters)
                    table.insert(DefibrillateurZones, {entity = DefibrillateurShared, zoneId = zoneId})

                    ResetPedMovementClipset( playerPed, 0 )
                end
                    
                break
            end
        end
    end
end)

local isStarted = false

RegisterNetEvent('esx:defibrillateur:start')
AddEventHandler('esx:defibrillateur:start', function()
    if not isStarted then
        local playerPed = PlayerPedId() -- Obtenir le Ped du joueur actuel
        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer() -- Trouver le joueur le plus proche

        if closestPlayer ~= -1 and closestDistance <= 3.0 then -- Si un joueur est assez proche
            local targetPed = GetPlayerPed(closestPlayer) -- Obtenir le Ped du joueur le plus proche

            if IsPedDeadOrDying(targetPed, 1) then -- Vérifier si le joueur le plus proche est mort ou en train de mourir
                local targetCoords = GetEntityCoords(targetPed) -- Récupérer les coordonnées du joueur le plus proche
                -- Le joueur le plus proche est mort ou en train de mourir, appliquer le défibrillateur
                TriggerServerEvent('esx:defibrillateur:revive', GetPlayerServerId(closestPlayer), targetCoords)
                isStarted = true
            else
                ESX.ShowNotification("Aucun joueur inconscient à proximité.")
            end
        else
            ESX.ShowNotification("Aucun joueur inconscient à proximité.")
        end
    end
end)

RegisterNetEvent('esx:defibrillateur:revive')
AddEventHandler('esx:defibrillateur:revive', function(targetPlayerId, targetCoords)
    local playerPed = GetPlayerPed(-1) -- Obtenez le Ped du joueur actuel
    local playerCoords = GetEntityCoords(playerPed) -- Obtenez les coordonnées actuelles du joueur
    local distance = #(playerCoords - vector3(targetCoords.x, targetCoords.y, targetCoords.z)) -- Calculez la distance

    -- Vérifiez si la distance est inférieure ou égale à 5
    if distance <= 5.0 then
        -- Le joueur est à proximité des coordonnées cibles
        local currentPlayerId = GetPlayerServerId(PlayerId()) -- Obtenez l'ID serveur du joueur actuel
        print("Le joueur est à proximité pour la réanimation.")
        
        -- Envoyer le message NUI pour démarrer la chanson
        SendNUIMessage({
            action = "startSong"
        })

        Wait(50000)

        if isStarted then isStarted = false end

        if currentPlayerId == targetPlayerId then
            TriggerEvent('esx_ambulancejob:revive')
        end
    end
end)

