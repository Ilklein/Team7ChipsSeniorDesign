with open("triangles.txt", "w") as triangles:

    def generate_Triangle(x0, x1, x2, y0, y1, y2):#, c0, c1, c2):
        triangles.write(f"{x0},{x1},{x2},{y0},{y1},{y2}\n")
    
    # # FLOATS TOO!!!!!!
    
    #triangle of size 1
    generate_Triangle(30.0, 31.0, 31.0, 55.0, 55.0, 50.0)
    
    # # clockwise triangle
    generate_Triangle(85.0, 90.0, 75.0, 200.0, 120.0, 100.0)
    
    # # triangle in upper left
    generate_Triangle(0.0, 10.0, 0.0, 0.0, 0.0, 10.0)

    # triangle in upper right
    generate_Triangle(310.0, 320.0, 320.0, 0.0, 0.0, 10.0)

    # triangle in lower left
    generate_Triangle(0.0, 10.0, 0.0, 230.0, 240.0, 240.0)

    # triangle in lower right
    generate_Triangle(320.0, 320.0, 310.0, 230.0, 240.0, 240.0)

    # triangle in middle
    generate_Triangle(75.0, 90.0, 85.0, 100.0, 120.0, 200.0)
    # overlapping triangles
    generate_Triangle(150.0, 200.0, 160.0, 20.0, 30.0, 50.0)
    generate_Triangle(180.0, 225.0, 250.0, 25.0, 32.0, 40.0)
    # same triangle
    generate_Triangle(100.0, 120.0, 110.0, 75.0, 70.0, 90.0)
    generate_Triangle(100.0, 120.0, 110.0, 75.0, 70.0, 90.0)
    
    # # big triangle
    generate_Triangle(25.0, 200.0, 300.0, 100.0, 50.0, 150.0)
        
    # triangle of size 1
    generate_Triangle("30.40", "31.10", "31.70", "55.20", "55.60", "50.50")

    # clockwise triangle
    generate_Triangle("85.30", "90.70", "75.20", "200.40", "120.80", "100.60")

    # # triangle in upper left
    generate_Triangle("0.20", "10.60", "0.70", "0.30", "0.50", "10.40")

    # # triangle in upper right
    generate_Triangle("310.50", "320.70", "320.20", "0.40", "0.30", "10.80")

    # # triangle in lower left
    generate_Triangle("0.60", "10.20", "0.30", "230.70", "240.90", "240.10")

    # # triangle in lower right
    generate_Triangle("320.40", "320.90", "310.50", "230.60", "240.30", "240.80")

    # triangle in middle
    generate_Triangle("75.10", "90.80", "85.60", "100.20", "120.40", "200.90")

    # # overlapping triangles
    generate_Triangle("150.30", "200.60", "160.40", "20.90", "30.20", "50.80")
    generate_Triangle("180.50", "225.70", "250.40", "25.60", "32.30", "40.90")

    # # same triangle
    generate_Triangle("100.20", "120.80", "110.40", "75.30", "70.60", "90.10")
    generate_Triangle("100.20", "120.80", "110.40", "75.30", "70.60", "90.10")

    # # big triangle
    generate_Triangle("25.50", "200.30", "300.70", "100.90", "50.20", "150.60")


    #entire area of screen filled
    
    