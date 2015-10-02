tbtn = Button {
	Parent = mainWindow,
	Text = "BTN",

	PosX = 10, PosY = 50
}

function tbtn:OnClick(  )
	print "OK MAN"
	 MessageBox("mensaje", "lide-framework")
end