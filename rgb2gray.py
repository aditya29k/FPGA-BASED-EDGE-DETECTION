import cv2

# RGB TO GRAY

image = cv2.imread(r"C:\iverilog\bin\codes\FPGA_EDGE_DETECTION\donkey.jpg")

if image is None:
    print("Error: Image not found")
else:

    image_sized = cv2.resize(image, (640,480))
    gray = cv2.cvtColor(image_sized, cv2.COLOR_BGR2GRAY)
    gray_sized = cv2.resize(gray, (640, 480))

    cv2.imwrite(r"C:\iverilog\bin\codes\FPGA_EDGE_DETECTION\donkey_gray.jpg", gray_sized)

    cv2.imshow("ORIGINAL IMAGE", image_sized)
    cv2.imshow("GRAYSCALE IMAGE", gray_sized)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

# GRAY TO MEM FILE

pixel = gray_sized.flatten()

with open(r"C:\iverilog\bin\codes\FPGA_EDGE_DETECTION\donkey.mem", "w") as f:
    for i in pixel:
        f.write(f"{i:02X}\n")