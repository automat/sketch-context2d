#Summary

- [x]  passed
- [o]  partial passed
- [_]  not passed
- [-]  not supported

---

###[x] 00-fillRect

---

###[x] 01-strokeRect

---

###[o] 02-fillText
- transformation missing

---

###[_] 03-strokeText
- text-layer stroke missing
- transformation missing

---

###[x] 04-lineWidth

---

###[x] 05-lineCap

---

###[x] 06-lineJoin

---

###[_] 07-miterLimit

---

###[x] 08-getLineDash

---

###[x] 09-setLineDash

---

###[-] 10-lineDashOffset

---

###[x] 11-font

---

###[x] 12-textAlign
- LTR / RTL start / end falls back to just left / right

---

###[o] 13-textBaseline
Depends on font information:

![](./summary-assets/13-textBaseline-sample-00.png)
![](./summary-assets/13-textBaseline-sample-01.png)
![](./summary-assets/13-textBaseline-sample-02.png)
![](./summary-assets/13-textBaseline-sample-03.png)
![](./summary-assets/13-textBaseline-sample-04.png)
![](./summary-assets/13-textBaseline-sample-05.png)
![](./summary-assets/13-textBaseline-sample-06.png)
![](./summary-assets/13-textBaseline-sample-07.png)
![](./summary-assets/13-textBaseline-sample-08.png)
![](./summary-assets/13-textBaseline-sample-09.png)

---

###[x] 14-fillStyle

---

###[x] 15-strokeStyle

---

###[x] 16-createLinearGradient

---

###[o] 17-createRadialGradient
- outer / inner radius set doesnt work

---

###[_] 18-createPattern

---

###[x] 19-shadowBlur

---

###[x] 20-shadowColor

---

###[x] 21-shadowOffsetX

---

###[x] 22-shadowOffsetY

---

###[x] 23-beginPath

---

###[x] 24-closePath

---

###[x] 25-moveTo

---

###[x] 26-lineTo

---

###[x] 27-bezierCurveTo

---

###[x] 28-quadraticCurveTo

---

###[x] 29-arc

---

###[x] 30-arcTo

---

###[x] 31-rect

---

###[x] 32-fill

---

###[x] 33-stroke

---

###[o] 34-clip

---

###[x] 35-rotate

---

###[x] 36-scale

---

###[x] 37-translate

---

###[x] 38-transform

---

###[x] 39-setTransform

---

###[x] 40-globalAlpha

---

###[_] 41-globalCompositeOperation

---

###[_] 42-drawImage

---

###[_] 43-createImageData

---

###[_] 44-getImageData

---

###[_] 45-putImageData

---

###[o] 46-save
- not completely tested

---

###[o] 47-restore
- not completely tested

---

###[x] 48-canvas
