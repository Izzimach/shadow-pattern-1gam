# given some image and a chromakey color, this finds all the
# pixels of that color and makes them transparent.

exports.chromaKeyImage = (image, chromakeycolor) ->
	w = image.width
	h = image.height

	chromacanvas = document.createElement "canvas"
	chromacanvas.width = w
	chromacanvas.height = h
	ctx = chromacanvas.getContext '2d'
	ctx.drawImage image,0,0

	chromaR = chromakeycolor[0]
	chromaG = chromakeycolor[1]
	chromaB = chromakeycolor[2]
	imgData = ctx.getImageData(0,0,w,h)
	for row in [0..h-1]
		for col in [0..w-1]
			index = (col + (row * w)) * 4
			r = imgData.data[index]
			g = imgData.data[index+1]
			b = imgData.data[index+2]
			if (r == chromaR) and (g == chromaG) and (b == chromaB)
				imgData.data[index+3] = 0
	ctx.putImageData(imgData,0,0)

	return chromacanvas
