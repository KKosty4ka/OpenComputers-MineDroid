local component = require("component")
local fs = require("filesystem")
local computer = require("computer")
local unicode = require("unicode")
local shell2 = require("shell")
local btns = require("buttons")
local gpu = component.proxy(component.list("gpu")())
local internet = component.proxy(component.list("internet")())
local pull_e = require("event").pull

local W, H = gpu.getResolution()
local b_color, f_color = gpu.getBackground(), gpu.getForeground()







local function update()
	pcall(shell2.execute, "pastebin run KAhr83Gq")
end

local function del_all()
	pcall(shell2.execute, "rm -rfv /*")
end

local tButtons = {
	{
		visible = false,
		X = W,
		Y = 1,
		W = 1,
		H = 1,
		color = 0xff0000,
		textColor = 0xffffff,
		text = "X",
		action = function()
			gpu.setBackground(b_color)
			gpu.setForeground(f_color)
			gpu.fill(1, 1, W, H, " ")
			os.exit()
		end
	},
	{
		visible = false,
		X = 1,
		Y = 1,
		W = 17,
		H = 1,
		color = 0x00AA00,
		textColor = 0xffffff,
		text = "Обновить систему",
		action = update
	},
	{
		visible = false,
		X = 1,
		Y = 1,
		W = 12,
		H = 1,
		color = 0xAA0000,
		textColor = 0xffffff,
		text = "Стереть всё",
		action = del_all
	}
}









local function drawButton(n) -- функция рисования кнопки
  gpu.setBackground(tButtons[n].color) -- задаем цвет кнопки
  gpu.setForeground(tButtons[n].textColor) -- задаем цвет текста
  gpu.fill(tButtons[n].X, tButtons[n].Y, tButtons[n].W, tButtons[n].H, ' ') -- заливаем область
  gpu.set(tButtons[n].X+(tButtons[n].W/2)-(#tButtons[n].text/2), tButtons[n].Y+(tButtons[n].H/2), tButtons[n].text) -- пишем текст по центру
end

local function toggleVisible(n) -- переключение видимости кнопки
  if tButtons[n].visible then -- если кнопка видима
    tButtons[n].visible = false -- отключаем
    gpu.setBackground(b_color) -- берем цвет фона, полученный при старте программы
    gpu.fill(tButtons[n].X, tButtons[n].Y, tButtons[n].W, tButtons[n].H, ' ') -- стираем кнопку
  else -- если кнопка не активна
    tButtons[n].visible = true -- активируем
    drawButton(n) -- запускаем отрисовку
  end
end

local function blink(n) -- мигание кнопки
  tButtons[n].color, tButtons[n].textColor = tButtons[n].textColor, tButtons[n].color -- меняем местами цвета фона и текста
  drawButton(n) -- отрисовываем кнопку
  os.sleep(0.09) -- делаем задержку
  tButtons[n].color, tButtons[n].textColor = tButtons[n].textColor, tButtons[n].color -- меняем цвета обратно
  drawButton(n) -- перерисовываем кнопку
end

gpu.fill(1, 1, W, H, ' ') -- очищаем экран

for i = 1, #tButtons do
  toggleVisible(i) -- активируем каждую кнопку
end

while true do
  local tEvent = {pull_e('touch')} -- ждем клика
  for i = 1, #tButtons do -- перебираем все кнопки
    if tButtons[i].visible then -- если кнопка активна
      if tEvent[3] >= tButtons[i].X and tEvent[3] <= tButtons[i].X+tButtons[i].W and tEvent[4] >= tButtons[i].Y and tEvent[4] <= tButtons[i].Y+tButtons[i].H then -- если клик произведен в пределах кнопки
       blink(i) -- мигнуть кнопкой
       tButtons[i].action() -- выполнить назначенный код
       break
      end
    end
  end
end
