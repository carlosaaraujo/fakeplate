ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({
    ['username'] = Config.WebhookName,
    ['avatar_url'] = Config.WebhookAvatarUrl,
    ['embeds'] = {{
        ['author'] = {
            ['name'] = 'Sistema de placas falsas',
            ['icon_url'] = 'https://images3.memedroid.com/images/UPLOADED354/5d508d4f0dc59.jpeg'
        },
        ['footer'] = {
            ['text'] = 'Iniciado e funcionando com sucesso'
        },
        ['color'] = 12914,
        ['description'] = 'Iniciado e funcionando com sucesso ✅',
        ['timestamp'] = os.date('!%Y-%m-%dT%H:%M:%SZ')
    }}
}), {['Content-Type'] = 'application/json' })

Citizen.CreateThread(function()
	local char = Config.PlateLetters
	char = char + Config.PlateNumbers
	if Config.PlateUseSpace then char = char + 1 end

	if char > 8 then
		print(('[fakeplate] [^3WARNING^7] Plate character count reached, %s/8 characters!'):format(char))
	end
end)

ESX.RegisterServerCallback('fakeplate:isPlateTaken', function(source, cb, plate)
	MySQL.Async.fetchAll('SELECT 1 FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(result)
		cb(result[1] ~= nil)
	end)
end)

ESX.RegisterUsableItem('fakeplate', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getInventoryItem('bread') ~= nil then
	   TriggerClientEvent('fakeplate:newPlate', source)
    else
        xPlayer.showNotification('Você esqueceu uma ferramenta!')
    end
end)

ESX.RegisterUsableItem('oldplate', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getInventoryItem('bread') ~= nil then
	   TriggerClientEvent('fakeplate:oldPlate', source)
    else
        xPlayer.showNotification('Você esqueceu uma ferramenta!')
    end
end)

RegisterServerEvent('fakeplate:useOld')
AddEventHandler('fakeplate:useOld', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('oldplate', 1)
end)

RegisterServerEvent('fakeplate:useFake')
AddEventHandler('fakeplate:useFake', function()
	local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.canSwapItem('fakeplate', 1, 'oldplate', 1) then
        xPlayer.removeInventoryItem('fakeplate', 1)
        xPlayer.addInventoryItem('oldplate', 1)
    else
        xPlayer.showNotification('Espaço não suficiente no inventário.')
    end
end)

RegisterServerEvent('fakeplate:dclog')
AddEventHandler('fakeplate:dclog', function(text, text2)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    dclog(xPlayer, text, text2)
end)

function dclog(xPlayer, text, text2)
    local playerName = Sanitize(xPlayer.getName())
    
    for k, v in ipairs(GetPlayerIdentifiers(xPlayer.source)) do
        if string.match(v, 'discord:') then
            identifierDiscord = v
        end
        if string.match(v, 'ip:') then
            identifierIp = v
        end
    end
	
	local discord_webhook = GetConvar('discord_webhook', Config.DiscordWebhook)
	if discord_webhook == '' then
	  return
	end
	local headers = {
	  ['Content-Type'] = 'application/json'
	}
	local data = {
        ['username'] = Config.WebhookName,
        ['avatar_url'] = Config.WebhookAvatarUrl,
        ['embeds'] = {{
          ['author'] = {
            ['name'] = 'Sistema de placas falsas',
            ['icon_url'] = 'https://images3.memedroid.com/images/UPLOADED354/5d508d4f0dc59.jpeg'
          },
          ['footer'] = {
              ['text'] = 'Iniciado e funcionando com sucesso ✅'
          },
          ['color'] = 12914,
          ['timestamp'] = os.date('!%Y-%m-%dT%H:%M:%SZ')
        }}
      }
    text = '**'..text..'**\n🆔 **ID**: '..tonumber(xPlayer.source)..'\n💻 **Steam:** '..xPlayer.identifier..'\n📋 **Nome do jogador:** '..xPlayer.getName()
    if identifierDiscord ~= nil then
        text = text..'\n🛰️ **Discord:** <@'..string.sub(identifierDiscord, 9)..'>'
        identifierDiscord = nil
    end
    if identifierIp ~= nil then
        text = text..'\n🌐 **Ip:** '..string.sub(identifierIp, 4)
        identifierIp = nil
    end
    data['embeds'][1]['description'] = text
	PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end

function Sanitize(str)
	local replacements = {
		['&' ] = '&amp;',
		['<' ] = '&lt;',
		['>' ] = '&gt;',
		['\n'] = '<br/>'
	}

	return str
		:gsub('[&<>\n]', replacements)
		:gsub(' +', function(s)
			return ' '..('&nbsp;'):rep(#s-1)
		end)
end