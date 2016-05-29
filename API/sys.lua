os.loadAPI("/doorOS/API/encrypt")

--Base System API
--Should Handle background stuff
--e.g. first start, loading and decrypting user stuff, etc.

--Variablen
_ver = 0.1
_verstr = "0.1"
key = ""
usrData = {
	Username = "",
	Password = "",
	Language = "",
}
lang = {
	Username = "Username",
	Password = "Password",
}

function getKey()
	shell.run("pastebin get sUzJjBgz /.tmp")
	local file = fs.open("/.tmp","r")
	key = file.readAll()
	file.close()
	fs.delete("/.tmp")
	return key
end
--Funktionen
function clear(bg, fg)
	term.setCursorPos(1,1)
	term.setBackgroundColor(bg)
	term.setTextColor(fg)
	term.clear()
end

function readUsrData()
	local file = fs.open("/doorOS/sys/usrData","r")
	local inhalt = file.readAll()
	local inhalt = textutils.unseralize(inhalt)
	usrData = inhalt
	file.close()
	return usrData
end

function writeUsrData(dataTable)
	if dataTable == nil or dataTable == "" then dataTable = usrData end
	local file = fs.open("/doorOS/sys/usrData","w")
	file.write(textutils.serialize(dataTable))
	file.close()
end

function loadLanguage(languageFile)
	local file = fs.open("/doorOS/languages/"..languageFile, "r")
	local inhalt = file.readAll()
	lang = textutils.unserialize(inhalt)
	return lang
end

function firstStart()
	missing = 0
	left = 0
	maximum = 0
	selected = 0
	clear(colors.blue, colors.white)
	oldTerm = term.native()
	grayWindow = window.create(oldTerm, 15, 5, 20, 10)
	term.redirect(grayWindow)
	term.setBackgroundColor(colors.lightGray)
	term.clear()
	term.setCursorPos(1,1)
	term.write("Welcome to")
	term.setCursorPos(1,2)
	term.write("the Installation.")
	term.setCursorPos(2, 9)
	term.setBackgroundColor(colors.lime)
	term.write("Exit")
	term.setCursorPos(16, 9)
	term.write("Next")
	running = true
	page1 = true
	while running do
		local event, button, x, y = os.pullEventRaw()

		if page1 and event == "mouse_click" and button == 1 and x >= 16 and x <= 19  and y == 13 then
			running = false
			page1 = false
			term.redirect(oldTerm)
			clear(colors.black, colors.white)
			break
		elseif page1 and event == "mouse_click" and button == 1 and x >= 30 and x <= 33 and y == 13 then
			page1 = false
			clear(colors.lightGray, colors.white)
			page2 = true
			listBox = window.create(term.current(), 2, 2, 18, 6)
			listBox.setBackgroundColor(colors.gray)
			listBox.setTextColor(colors.white)
			listBox.clear()
			langList = fs.list("/doorOS/languages/")
			left = #langList-6
			if left < 0 then left = 0 end
			maximum = #langList
			term.redirect(listBox)
			for _, file in ipairs(langList) do
				if _ == 7 then
					break
				else
					term.write(file)
					local x, y = term.getCursorPos()
					term.setCursorPos(1,y+1)
				end

			end
			term.redirect(grayWindow)
			term.setBackgroundColor(colors.lime)
			term.setTextColor(colors.white)
			term.setCursorPos(2, 9)
			term.write("Next")
			term.setBackgroundColor(colors.lightGray)
			usrData.Language = "English"
		elseif page2 and event == "mouse_scroll" and button == -1 and missing > 0 and x >= 16 and x <= 33 and y <= 11 and y >= 6 then
			term.redirect(listBox)
			term.scroll(-1)
			term.setCursorPos(1,1)
			if missing == selected then
				term.setBackgroundColor(colors.lightBlue)
				term.clearLine()
			end
			term.write(langList[missing])
			term.setBackgroundColor(colors.gray)
			missing = missing-1
			left = left+1
			term.redirect(grayWindow)
		elseif page2 and event == "mouse_scroll" and button == 1 and left > 0 and x >= 16 and x <= 33 and y >= 6 and y <= 11 then
			term.redirect(listBox)
			term.scroll(1)
			term.setCursorPos(1,6)
			if missing+6+1 == selected then
				term.setBackgroundColor(colors.lightBlue)
				term.clearLine()
			end
			term.write(langList[missing+6+1])
			term.setBackgroundColor(colors.gray)
			missing = missing+1
			left = left-1
			term.redirect(grayWindow)
		elseif page2 and event == "mouse_click" and button == 1 and x >= 16 and x <= 33 and y >= 6 and y <= 11 then
			local y = y-5
			selected = missing+y
			markLang(selected)
			usrData.Language = langList[selected]
		elseif page2 and event == "mouse_click" and button == 1 and x >= 16 and x <= 19 and y == 13 and selected == 0 then
			term.setCursorPos(6, 9)
			term.setBackgroundColor(colors.lightGray)
			term.setTextColor(colors.red)
			term.write("Please select.")
		elseif page2 and event == "mouse_click" and button == 1 and x >= 16 and x <= 19 and y == 13 and selected > 0 then
			loadLanguage(usrData.Language)
			page2 = false
			listBox.setVisible(false)
			clear(colors.lightGray, colors.white)
			page3 = true
			usrTxtBx = window.create(term.current(), 2, 2, 18, 1)
			usrTxtBx.setBackgroundColor(colors.gray)
			usrTxtBx.setTextColor(colors.lime)
			usrTxtBx.clear()
			usrTxtBx.write(lang.Username)
			pwTxtBx = window.create(term.current(), 2, 4, 18, 1)
			pwTxtBx.setBackgroundColor(colors.gray)
			pwTxtBx.setTextColor(colors.lime)
			pwTxtBx.clear()
			pwTxtBx.write(lang.Password)
			term.setCursorPos(2, 9)
			term.setBackgroundColor(colors.lime)
			term.setTextColor(colors.white)
			term.write("Finish")
		elseif page3 and event == "mouse_click" and button == 1 and x >= 16 and x <= 33 and y == 6 then
			term.redirect(usrTxtBx)
			term.setCursorPos(1,1)
			term.setBackgroundColor(colors.gray)
			term.setTextColor(colors.lime)
			term.clearLine()
			usrData.Username = read()
			term.redirect(grayWindow)
			usrTxtBx.setCursorPos(1,1)
			usrTxtBx.write(usrData.Username)
		elseif page3 and event == "mouse_click" and button == 1 and x >= 16 and x <= 33 and y == 8 then
			term.redirect(pwTxtBx)
			term.setCursorPos(1,1)
			term.setBackgroundColor(colors.gray)
			term.setTextColor(colors.lime)
			term.clearLine()
			usrData.Password = read()
			term.redirect(grayWindow)
			pwTxtBx.setCursorPos(1,1)
			pwTxtBx.write(usrData.Password)
		elseif page3 and event == "mouse_click" and button == 1 and x >= 16 and x <= 21 and y == 13 then
			if usrData.Username == nil or usrData.Username == "" then
				term.redirect(usrTxtBx)
				term.setBackgroundColor(colors.gray)
				term.setTextColor(colors.red)
				term.clear()
				term.setCursorPos(1,1)
				term.write(lang.Username)
				term.redirect(grayWindow)
			elseif usrData.Password == nil or usrData.Password == "" then
				term.redirect(pwTxtBx)
				term.setBackgroundColor(colors.gray)
				term.setTextColor(colors.red)
				term.clear()
				term.setCursorPos(1,1)
				term.write(lang.Password)
				term.redirect(grayWindow)
			else

				local pw = encrypt.encrypt(usrData.Password, key)
				usrData.Password = pw
				writeUsrData()
				term.redirect(oldTerm)
				grayWindow.setVisible(false)
				clear(colors.black, colors.white)
				break
			end
		end
	end
end

function markLang(number)
	listBox.setBackgroundColor(colors.gray)
	listBox.setTextColor(colors.white)
	listBox.clear()
	term.redirect(listBox)
	term.setCursorPos(1,1)
	local counter = 1
	repeat
		local current = missing+counter
		if current == number then
			term.setBackgroundColor(colors.lightBlue)
			term.clearLine()
		end
		term.write(langList[current])
		local x, y = term.getCursorPos()
		term.setCursorPos(1, y+1)
		term.setBackgroundColor(colors.gray)
		counter = counter+1
	until counter == 7
	term.redirect(grayWindow)
end

getKey()
firstStart()