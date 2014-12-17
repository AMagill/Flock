Generated font atlas with AngelCode BMFont from: http://www.angelcode.com/products/bmfont/

To convert to SDF, generate atlas at 8x desired size, then in Photoshop:
	Put atlas on new layer, delete black pixels, fill white with #808080
	Make background layer completely black
	Layer style outer glow; normal, 100% opacity, #808080, precise, 128px
	Layer style inner glow; normal, 100% opacity, #ffffff, precise, center, 128px
	Flatten image
	Rescale to 1/8 size
	Save

Beware color management!  Maybe convert to sGray space.