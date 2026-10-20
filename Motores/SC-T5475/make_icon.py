"""Genera icono moderno Epson T5475 - plotter azul + gota tinta. @Ricker"""
from PIL import Image, ImageDraw
import os
BASE = os.path.dirname(os.path.abspath(__file__))
S = 256
img = Image.new('RGBA', (S, S), (0, 0, 0, 0))
d = ImageDraw.Draw(img)
# fondo redondeado azul degradado simulado
for i in range(S):
    r = int(30 + (47-30)*i/S); g = int(64 + (124-64)*i/S); b = int(175 + (246-175)*i/S)
    d.line([(0, i), (S, i)], fill=(r, g, b, 255))
# recorte redondeado
mask = Image.new('L', (S, S), 0)
md = ImageDraw.Draw(mask)
md.rounded_rectangle([0, 0, S, S], radius=56, fill=255)
# cuerpo impresora blanco
d.rounded_rectangle([48, 96, 208, 170], radius=14, fill=(255, 255, 255, 255))
d.rectangle([70, 60, 186, 100], fill=(226, 232, 240, 255))
d.rectangle([78, 70, 178, 92], fill=(30, 64, 175, 255))
d.rectangle([90, 130, 166, 142], fill=(47, 124, 246, 255))
# papel saliendo
d.rectangle([90, 150, 166, 196], fill=(255, 255, 255, 255), outline=(148, 163, 184, 255), width=3)
d.line([(100, 165), (156, 165)], fill=(47, 124, 246, 255), width=4)
d.line([(100, 176), (156, 176)], fill=(148, 163, 184, 255), width=3)
# gota verde check
d.ellipse([176, 150, 226, 200], fill=(22, 163, 74, 255), outline=(255, 255, 255, 255), width=5)
d.line([(187, 175), (196, 184), (215, 162)], fill=(255, 255, 255, 255), width=7, joint='curve')
img.putalpha(mask)
# combina fondo + alpha final
out = Image.new('RGBA', (S, S), (0, 0, 0, 0))
out.paste(img, (0, 0), mask)
out.save(os.path.join(BASE, 'Epson_T5475.ico'), sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
out.save(os.path.join(BASE, 'Epson_T5475.png'))
print('Icono OK')
