import cv2
import numpy as np

row_width = 30
height = 30
image = r"C:\iverilog\bin\codes\FPGA_EDGE_DETECTION\mem_recv.mem"

with open(image, "r") as file:
    pixel = file.read().splitlines() # .splitlines add each element into list of strings ["0A", "1F", ...]

pixel_int = []

for i in pixel:
    val = int(i, 16)
    pixel_int.append(val)

final_image = np.array(pixel_int, dtype = np.uint16).reshape((height, row_width))

cv2.imwrite(r"C:\iverilog\bin\codes\FPGA_EDGE_DETECTION\final_out.jpg", final_image)
cv2.imshow("SOBELLED IMAGE", final_image)
cv2.waitKey(0)
cv2.destroyAllWindows