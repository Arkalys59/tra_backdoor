local motsClesSuspects = {
    "StartResource", "StopResource", "RestartResource", "ExecuteCommand", "AddEventHandler",
    "TriggerServerEvent", "PerformHttpRequest", "LoadResourceFile", "SendNUIMessage", "Citizen.InvokeNative"
}

local fichiersAvecBackdoors = {}
local fichiersAvecErreurs = {}

local function enregistrerErreur(cheminFichier, ligneNum, ligne)
    local fichier = io.open("erreurs_backdoors.txt", "a")
    if fichier then
        fichier:write("Erreur dans le fichier : " .. cheminFichier .. ", ligne " .. ligneNum .. " : " .. ligne .. "\n")
        fichier:close()
    end
end

local function verifierBackdoor(cheminFichier)
    local fichier = io.open(cheminFichier, "r")
    if fichier then
        local ligneNum = 0
        for ligne in fichier:lines() do
            ligneNum = ligneNum + 1
            for _, motCle in ipairs(motsClesSuspects) do
                if string.find(ligne, motCle) then
                    if not fichiersAvecBackdoors[cheminFichier] then
                        print("Backdoor suspecte trouvée dans le fichier : " .. cheminFichier)
                        fichiersAvecBackdoors[cheminFichier] = true
                    end
                    if not fichiersAvecErreurs[cheminFichier] then
                        enregistrerErreur(cheminFichier, ligneNum, ligne)
                        fichiersAvecErreurs[cheminFichier] = true
                    end
                    break
                end
            end
        end
        fichier:close()
    end
end

local function parcourirFichiers(chemin)
    local fichiers = {}
    for fichier in io.popen('dir "' .. chemin .. '" /b'):lines() do
        table.insert(fichiers, fichier)
    end
    return fichiers
end

for i = 0, GetNumResources() - 1 do
    local ressource = GetResourceByFindIndex(i)
    local cheminRessource = GetResourcePath(ressource)

    if cheminRessource then
        for _, fichier in ipairs(parcourirFichiers(cheminRessource)) do
            if fichier:match("%.lua$") then
                local cheminFichier = cheminRessource .. "/" .. fichier
                verifierBackdoor(cheminFichier)
            end
        end
    end
end

print("Vérification des backdoors terminée.")
