import numpy as np
import csv
import math
def extractDec(d):
    dec = d % 1 #d is now just the decimal
    six_bit = math.floor(((dec) * 64 + .5))
    return six_bit/64

def normalize(d):
    dec = d % 1 #d is now just the decimal
    six_bit = math.floor(((dec) * 64 + .5))
    return math.floor(d) + six_bit/64
    
    
#screen = np.zeros((240, 320), dtype=int)
screen = {}
rtlScreen = {}
gold_screen = [[0 for i in range(321)] for j in range(241)]
c0 = 63489
c1 = 1985
c2 = 63
t = 1

color = 1
with open("triangles.txt","r") as triangleList:
    for l in triangleList:
        point = l.split(",")
        
        x0s = point[0].split(".")
        x0 = (int(x0s[0]),int(x0s[1]))
        decx0 = extractDec(float(point[0]))
        x0f = math.floor(float(point[0])) + decx0
        #print(f"x0f: {x0f}")
        
        x1s = point[1].split(".")
        x1 = (int(x1s[0]),int(x1s[1]))
        decx1 = extractDec(float(point[1]))
        x1f = math.floor(float(point[1])) + decx1
        
        x2s = point[2].split(".")
        x2 = (int(x2s[0]),int(x2s[1]))
        decx2 = extractDec(float(point[2]))
        x2f = math.floor(float(point[2])) + decx2
        
        y0s = point[3].split(".")
        y0 = (int(y0s[0]),int(y0s[1]))
        decy0 = extractDec(float(point[3]))
        y0f = math.floor(float(point[3])) + decy0
        
        y1s = point[4].split(".")
        y1 = (int(y1s[0]),int(y1s[1]))
        decy1 = extractDec(float(point[4]))
        y1f = math.floor(float(point[4])) + decy1
        
        y2s = point[5].split(".")
        y2 = (int(y2s[0]),int(y2s[1]))
        decy2 = extractDec(float(point[5]))
        y2f = math.floor(float(point[5])) + decy2
        
        # area = .5* x0f * (y1f - y2f) + x1f * (y2f - y0f) + x2f * (y0f - y1f)
        area = ((x1f - x0f) * (y2f - y0f) - (x2f - x0f) * (y1f - y0f))
        if area == 0:
            area = 1
        
        
        xmax = max(math.floor(x0f+.5), math.floor(x1f+.5), math.floor(x2f+.5))
        xmin = min(math.floor(x0f+.5), math.floor(x1f+.5), math.floor(x2f+.5))
        
        ymax = max(math.floor(y0f+.5), math.floor(y1f+.5), math.floor(y2f+.5))
        ymin = min(math.floor(y0f+.5), math.floor(y1f+.5), math.floor(y2f+.5))
        
        # print(f"x0f: {x0f}, x1f: {x1f}, x2f: {x2f}")
        # print(f"rounded 310.5: {math.floor(x0f+.5)}")
        # print(f"xmax {xmax}, xmin {xmin}, ymax {ymax}, ymin {ymin}")
        x = xmin + .5
        y = ymin + .5
        e1 = round((x - x0f),4) * round((-y1f + y0f),4) - round((-y + y0f),4) * round((x1f - x0f),4)
        e2 = round((x - x1f),4) * round((-y2f + y1f),4) - round((-y + y1f),4) * round((x2f - x1f),4)
        e3 = round((x - x2f),4) * round((-y0f + y2f),4) - round((-y + y2f),4) * round((x0f - x2f),4)
        
        e1 = normalize(e1)
        e2 = normalize(e2)
        e3 = normalize(e3)
        
        e1 = round(e1,4)
        e2 = round(e2,4)
        e3 = round(e3,4)
        
        e1_prev = e1 
        e2_prev = e2
        e3_prev = e3

        
        s1x = round((-y1f + y0f),4)
        s1y = round((x1f - x0f),4)
        s2x = round((-y2f + y1f),4)
        s2y = round((x2f - x1f),4)
        s3x = round((-y0f + y2f),4)
        s3y = round((x0f - x2f),4)
        # if(e1 >= 0 and e2 >= 0 and e3 >= 0): #in the triangle
        #             screen[(xmin,ymin)] = color
                    
        for i in range(ymin,ymax + 1):
            for j in range(xmin,xmax + 1):
                
                
                
                x = j + .5
                y = i + .5
                
                # l0_area = 0.5 * (x1f * (y2f - i) + x2f * (i - y1f) + j * (y1f - y2f))
                # l1_area = 0.5 * (x2f * (y0f - i) + x0f * (i - y2f) + j * (y2f - y0f))
                # l2_area = 0.5 * (x0f * (y1f - i) + x1f * (i - y0f) + j * (y0f - y1f))
                

                e1_adjusted = e1 - .5 * s1x - .5 * s1y
                
                l0 = e1_adjusted / area
                l0 = normalize(l0)
                w0 = int(c0 * l0)
                
                w0 = w0 >> 11
                w0 = w0 & 31
                # print(f"({w0},",end="")
                w0 = w0 << 11
                
                e2_adjusted = e2 - .5 * s2x - .5 * s2y
                l1 = e2_adjusted / area
                l1 = normalize(l1)
                w1 = int(c1 * l1)
                
                w1 = w1 >> 6
                w1 = w1 & 31
                # print(f"{w1},",end="")
                w1 = w1 << 6
                    
                e3_adjusted = e3 - .5 * s3x - .5 * s3y
                l2 = e3_adjusted / area
                l2 = normalize(l2)
                w2 = int(l2 * c2)
                
                w2 = w2 >> 1
                w2 = w2 & 31
                # print(f"{w2})", end="")
                w2 = w2 << 1

                
                # print(f"y: {y}, x: {x}, w0: {w0}, w1: {w1}, w2: {w2}")
                color = w0 + w1 + w2 + t
                
                # print(f"x: {x}, y: {y} ", end="")
                # print(f"({e1},{e2},{e3})")
                # print(f"({l0*64}, {64*l1}, {64*l2}), ", end="")
                # print(f"({color}), ", end="")
                
                if(e1 >= 0 and e2 >= 0 and e3 >= 0): #in the triangle
                    screen[(i,j)] = color
                    # print(f"{i}, {j}, {color}")
                e1 = e1 + s1x
                e2 = e2 + s2x
                e3 = e3 + s3x
            # print(" ")
            e1_prev = e1_prev + s1y
            e1 = e1_prev
            
            e2_prev = e2_prev + s2y
            e2 = e2_prev
            
            e3_prev = e3_prev + s3y
            e3 = e3_prev
    with open("C:/intelFPGA/20.1/out.txt","r") as rtlList:
        for line in rtlList:
            p = line.split(",")
            x = int(p[0])
            y = int(p[1])
            c = int(p[2])
            rtlScreen[(y,x)] = c
    different = False
    if(rtlScreen.keys() == screen.keys()):
        for rtlcolor, goldcolor in zip (rtlScreen.values(), screen.values()):
            r_rtl = (rtlcolor >> 11) & 31
            g_rtl = (rtlcolor >> 6) & 31
            b_rtl = (rtlcolor >> 1) & 31
            
            r_gold = (rtlcolor >> 11) & 31
            g_gold = (rtlcolor >> 6) & 31
            b_gold = (rtlcolor >> 1) & 31
            if(abs(r_rtl - r_gold) > 3 or abs(g_rtl - g_gold) > 3 or abs(b_rtl - b_gold) > 3 ):
                different = True
                print("FAIL")

    else:
        different = True
    if different:
        print("FAIL")
    else:
        print("SUCCESS!")
        # print("GOLD")
        # diff = screen.keys() - rtlScreen.keys()
        # print(f"In gold but not rtl: {diff}")
        # diff = rtlScreen.keys() - screen.keys()
        # print(f"In rtl but not gold: {diff}")

    for key, val in screen.items():
        # print(f"Y: {key[0]}, X: {key[1]}")
        gold_screen[key[0]][key[1]] = val
    with open("gold_plot.txt", "w") as goldplt:
        for i in range (0,15):
            for j in range (0,15):
                goldplt.write(f"{gold_screen[i][j]},")
                # print(f"{gold_screen[i][j]},",end="")
            # print(" ")
            goldplt.write("\n")
        
    # check if it matches out.txt
    # for key, val in screen.items():
    #     print(f"{key}: {val}")
    # with open("/mnt/c/intelFPGA/20.1/out.txt", newline='') as csvfile:

    #     plotreader = csv.reader(csvfile, delimiter=',')
    #     for i,row in enumerate(plotreader):
    #         new_row = []
    #         for j,num in enumerate(row):
    #             num = num.strip()
    #             if not num.isdigit():
    #                 # Skip empty or invalid entries
    #                 continue


                    



