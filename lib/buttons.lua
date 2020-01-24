local component = require("component")
local unicode = require("unicode")
local pull_e = require('event').pull
local gpu = component.proxy(component.list("gpu")())

local W, H = gpu.getResolution()
local b_color, f_color = gpu.getBackground(), gpu.getForeground()

local buttons = {}

buttons.tButtons = {
--    {
--        visible = false,
--        X = 1,
--        Y = 7,
--        W = 7,
--        H = 1,
--        color = 0xffffff,
--        textColor = 0,
--        text = 'reboot',
--        action = function()
--            computer.shutdown(true)
--        end
--    }
}

function buttons.setbuttons(dict)
	buttons.tButtons = dict
end

function buttons.drawButton(n) -- функция рисования кнопки
    gpu.setBackground(buttons.tButtons[n].color) -- задаем цвет кнопки
    gpu.setForeground(buttons.tButtons[n].textColor) -- задаем цвет текста
    gpu.fill(buttons.tButtons[n].X, buttons.tButtons[n].Y, buttons.tButtons[n].W, buttons.tButtons[n].H, ' ') -- заливаем область
    gpu.set(buttons.tButtons[n].X+(buttons.tButtons[n].W/2)-(#buttons.tButtons[n].text/2), buttons.tButtons[n].Y+(buttons.tButtons[n].H/2), buttons.tButtons[n].text) -- пишем текст по центру
end

function buttons.toggleVisible(n) -- переключение видимости кнопки
    if buttons.tButtons[n].visible then -- если кнопка видима
        buttons.tButtons[n].visible = false -- отключаем
        gpu.setBackground(b_color) -- берем цвет фона, полученный при старте программы
        gpu.fill(buttons.tButtons[n].X, buttons.tButtons[n].Y, buttons.tButtons[n].W, buttons.tButtons[n].H, ' ') -- стираем кнопку
    else -- если кнопка не активна
        buttons.tButtons[n].visible = true -- активируем
        buttons.drawButton(n) -- запускаем отрисовку
    end
end

function buttons.blink(n) -- мигание кнопки
    buttons.tButtons[n].color, buttons.tButtons[n].textColor = buttons.tButtons[n].textColor, buttons.tButtons[n].color -- меняем местами цвета фона и текста
    buttons.drawButton(n) -- отрисовываем кнопку
    os.sleep(0.09) -- делаем задержку
    buttons.tButtons[n].color, buttons.tButtons[n].textColor = buttons.tButtons[n].textColor, buttons.tButtons[n].color -- меняем цвета обратно
    buttons.drawButton(n) -- перерисовываем кнопку
end

gpu.fill(1, 1, W, H, ' ') -- очищаем экран

for i = 1, #buttons.tButtons do
    buttons.toggleVisible(i) -- активируем каждую кнопку
end

function buttons.main()
	while true do
		local tEvent = {pull_e('touch')} -- ждем клика
		for i = 1, #buttons.tButtons do -- перебираем все кнопки
			if buttons.tButtons[i].visible then -- если кнопка активна
				if tEvent[3] >= buttons.tButtons[i].X and tEvent[3] <= buttons.tButtons[i].X+buttons.tButtons[i].W and tEvent[4] >= buttons.tButtons[i].Y and tEvent[4] <= buttons.tButtons[i].Y+buttons.tButtons[i].H then -- если клик произведен в пределах кнопки
				buttons.blink(i) -- мигнуть кнопкой
				buttons.tButtons[i].action() -- выполнить назначенный код
				break
				end
			end
		end
	end
end
