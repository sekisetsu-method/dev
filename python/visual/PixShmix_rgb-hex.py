import Image
import string

im = Image.open("a_helv.jpg")
im = im.convert()
seq = im.getdata()

imSize = im.size
imX = imSize[0]
imY = imSize[1]

#start
f = file("a.htm","w")
imgSeqLen = len(seq)
pixel = 0

#strAppInfo = "<sup>Image generated by PixelShmixel, a Python script by Arlo Emerson, Lante Corp. 2002</sup><br>"

strTableHeader = "<table cellpadding=0 border=0 cellspacing=0"
strTableHeader += " width="
strTableHeader += str(imX)
strTableHeader += " height="
strTableHeader += str(imY)
strTableHeader += ">"

myList = []
intRow = 0
intColumn = 0
blnStartRow = 1

myList.append(strTableHeader)

while pixel < imgSeqLen:
	intColumn = intColumn + 1
	# start row
	if blnStartRow == 1:
		myList.append("<tr>")
		blnStartRow = 0
	# append cell
	myList.append("<td ")
	myList.append("bgcolor=")

	sRGB = seq[pixel]
	#sRGB = sRGB[1:len(sRGB)-1]

	#sRGB = string.split(sRGB,",")
	sRed = sRGB[0]
	sGrn = sRGB[1]
	sBlu = sRGB[2]
	sRed = hex(int(sRed))
	sGrn = hex(int(sGrn))
	sBlu = hex(int(sBlu))

	sRed = sRed[2:len(sRed)]
	sGrn = sGrn[2:len(sGrn)]
	sBlu = sBlu[2:len(sBlu)]

	if len(sRed) == 1:
		sRed = "0" + sRed
	if len(sGrn) == 1:
		sGrn = "0" + sGrn
	if len(sBlu) == 1:
		sBlu = "0" + sBlu
	sNewRGB = (sRed + sGrn + sBlu)

	myList.append(sNewRGB)
	myList.append(" />")

	# close row
	if intRow < imY:
		if intColumn == imX:
			intColumn = 0 #reset column counter
			myList.append("</tr>")
			blnStartRow = 1
			intRow = intRow + 1
	pixel = pixel + 1

myList.append("</table>")
myList.append(strAppInfo)

f.writelines(myList)