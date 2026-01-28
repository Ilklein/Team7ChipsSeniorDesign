

# Read in plot, format data for RGB then plot it

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import csv

class color:
    
    def __init__(self, r, g, b, a):
        self.red = r
        self.green = g
        self.blue = b
        self.alpha = a
        
screen = []
with open("C:/intelFPGA/20.1/out_screen.txt", newline='') as csvfile:

    plotreader = csv.reader(csvfile, delimiter=',')
    for i,row in enumerate(plotreader):
        new_row = []
        for j,num in enumerate(row):
            num = num.strip()
            if not num.isdigit():
                # Skip empty or invalid entries
                continue
            decimal = int(num)
            r = ((decimal >> 11) & 0x1F) / 31.0
            g = ((decimal >> 6) & 0x1F) / 31.0
            b = ((decimal >> 1) & 0x1F) / 31.0
            a = decimal & 1
            c = color(r,g,b,a)
            new_row.append(c)
        screen.append(new_row)
# Now screen contains our screen as a 2D list of colors objects. Time to print them 


# Convert your screen (2D list of color objects) into a NumPy array
img = np.zeros((len(screen), len(screen[0]), 4))  # 4 for RGBA
for i in range(len(screen)):
    for j in range(len(screen[0])):
        c = screen[i][j]
        img[i, j, :] = [c.red, c.green, c.blue, 1]



plt.imshow(img)
plt.axis('off')
plt.savefig("./test.png", bbox_inches='tight', pad_inches=0)






