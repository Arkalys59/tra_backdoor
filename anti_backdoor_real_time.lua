local commandesSuspectes = {
    "start", "stop", "restart", "exec", "run", "server_restart",
    "add_principal", "remove_principal", "give_weapon", "give_money"
}

local fichiersAvecBackdoors = {}

local function enregistrerFichierAvecBackdoor(cheminFichier)
    table.insert(fichiersAvecBackdoors, cheminFichier)
end

local function fichierAvecBackdoorDejaSignale(cheminFichier)
    for _, fichier in ipairs(fichiersAvecBackdoors) do
        if fichier == cheminFichier then
            return true
        end
    end
    return false
end

local function enregistrerActiviteSuspecte(playerId, commande)
    local nomJoueur = GetPlayerName(playerId)
    local messageLog = string.format("Commande suspecte détectée : Joueur : %s (%d), Commande : %s", nomJoueur, playerId, commande)
    print(messageLog)
end

AddEventHandler('chatMessage', function(source, name, message)
    for _, commande in ipairs(commandesSuspectes) do
        if string.find(message, commande) then
            enregistrerActiviteSuspecte(source, commande)
            CancelEvent()
            DropPlayer(source, "Activité suspecte détectée : " .. commande)
            return
        end
    end
end)

RegisterCommand("verif_backdoor", function(source, args, rawCommand)
    local playerId = source
    if estAdmin(playerId) then
        enregistrerActiviteSuspecte(playerId, "verif_backdoor")
        TriggerClientEvent('chat:addMessage', playerId, {
            args = {"^1Anti-Backdoor", "Vérification terminée, aucun problème trouvé."}
        })
    else
        DropPlayer(playerId, "Tentative d'accès non autorisée détectée.")
    end
end, false)

function estAdmin(playerId)
    local adminIdentifiants = {
        "license:abcd1234efgh5678ijkl9012mnop3456qrst7890", -- Remplacez par votre licence FiveM
        -- Ajoutez d'autres identifiants ici si nécessaire
    }

    local identifiantsJoueur = GetPlayerIdentifiers(playerId)
    for _, identifiant in ipairs(identifiantsJoueur) do
        for _, adminIdentifiant in ipairs(adminIdentifiants) do
            if identifiant == adminIdentifiant then
                return true
            end
        end
    end
    return false
end
