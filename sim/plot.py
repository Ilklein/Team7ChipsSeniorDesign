

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
#with open("/mnt/c/intelFPGA/20.1/out.txt", newline='') as csvfile:
with open("./out.txt", newline='') as csvfile:

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
            g = ((decimal >> 5) & 0x1F) / 31.0
            b = ((decimal >> 1) & 0x1F) / 31.0
            a = decimal & 1
            c = color(r,g,b,a)
            new_row.append(c)
        screen.append(new_row)
# Now screen contains our screen as a 2D list of colors objects. Time to print them 
    fig, ax = plt.subplots()
    for i in range(len(screen)):
        for j in range(len(screen[0])):
            print("coordinates: " + str(j) + "," + str(i))
            pixel = patches.Rectangle((j, len(screen) - i - 1), 1, 1, facecolor = (screen[i][j].red, screen[i][j].green, screen[i][j].blue, screen[i][j].alpha) )
            ax.add_patch(pixel)
    print("done")
    ax.set_xlim(0, len(screen[0]))
    ax.set_ylim(0, len(screen))
    ax.set_aspect('equal')
    ax.axis('off')
    plt.show()


