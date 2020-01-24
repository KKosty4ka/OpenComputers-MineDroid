local component = require("component")
local unicode = require("unicode")
local pull_e = require('event').pull
local gpu = component.proxy(component.list("gpu")())

local W, H = gpu.getResolution()
local b_color, f_color = gpu.getBackground(), gpu.getForeground()

local buttons = {}

local tButtons = {
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

local function buttons.setButtons(dict)
	tButtons = dict
end

local function buttons.drawButton(n) -- функция рисования кнопки
    gpu.setBackground(tButtons[n].color) -- задаем цвет кнопки
    gpu.setForeground(tButtons[n].textColor) -- задаем цвет текста
    gpu.fill(tButtons[n].X, tButtons[n].Y, tButtons[n].W, tButtons[n].H, ' ') -- заливаем область
    gpu.set(tButtons[n].X+(tButtons[n].W/2)-(#tButtons[n].text/2), tButtons[n].Y+(tButtons[n].H/2), tButtons[n].text) -- пишем текст по центру
end

local function buttons.toggleVisible(n) -- переключение видимости кнопки
    if tButtons[n].visible then -- если кнопка видима
        tButtons[n].visible = false -- отключаем
        gpu.setBackground(b_color) -- берем цвет фона, полученный при старте программы
        gpu.fill(tButtons[n].X, tButtons[n].Y, tButtons[n].W, tButtons[n].H, ' ') -- стираем кнопку
    else -- если кнопка не активна
        tButtons[n].visible = true -- активируем
        buttons.drawButton(n) -- запускаем отрисовку
    end
end

local function buttons.blink(n) -- мигание кнопки
    tButtons[n].color, tButtons[n].textColor = tButtons[n].textColor, tButtons[n].color -- меняем местами цвета фона и текста
    buttons.drawButton(n) -- отрисовываем кнопку
    os.sleep(0.09) -- делаем задержку
    tButtons[n].color, tButtons[n].textColor = tButtons[n].textColor, tButtons[n].color -- меняем цвета обратно
    buttons.drawButton(n) -- перерисовываем кнопку
end

gpu.fill(1, 1, W, H, ' ') -- очищаем экран

for i = 1, #tButtons do
    buttons.toggleVisible(i) -- активируем каждую кнопку
end

local function buttons.main()
	while true do
		local tEvent = {pull_e('touch')} -- ждем клика
		for i = 1, #tButtons do -- перебираем все кнопки
			if tButtons[i].visible then -- если кнопка активна
				if tEvent[3] >= tButtons[i].X and tEvent[3] <= tButtons[i].X+tButtons[i].W and tEvent[4] >= tButtons[i].Y and tEvent[4] <= tButtons[i].Y+tButtons[i].H then -- если клик произведен в пределах кнопки
				buttons.blink(i) -- мигнуть кнопкой
				tButtons[i].action() -- выполнить назначенный код
				break
				end
			end
		end
	end
end
