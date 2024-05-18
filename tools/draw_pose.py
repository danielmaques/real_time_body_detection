import cv2
import numpy as np


import math

def euclidean_distance(point1, point2):
    x1, y1 = point1
    x2, y2 = point2
    return math.sqrt((x2 - x1)**2 + (y2 - y1)**2)

# Create a blank 100x100 image
#image = cv2.imread("/home/freshbooks/Downloads/Frente.jpg")
#image = cv2.resize(image, dsize=(1000, 1000))
image = np.zeros((1000, 1000, 3), np.uint8)

connections = [
        ["leftShoulder", "rightShoulder"],
        ["leftShoulder", "leftHip"],
        ["rightShoulder", "rightHip"],
        ["rightShoulder", "rightElbow"],
        ["rightWrist", "rightElbow"],
        ["leftHip", "rightHip"],
        ["leftHip", "leftKnee"],
        ["rightHip", "rightKnee"],
        ["rightKnee", "rightAnkle"],
        ["leftKnee", "leftAnkle"],
        ["leftElbow", "leftShoulder"],
        ["leftWrist", "leftElbow"],
    ]

# Define 12 points and their names
points = {'rightWrist': (863, 403), 'rightElbow': (742, 347), 'rightShoulder': (621, 256), 'rightHip': (582, 521), 'rightKnee': (575, 703), 'rightAnkle': (600, 863), 'leftWrist': (131, 400), 'leftElbow': (278, 334), 'leftShoulder': (390, 252), 'leftHip': (408, 519), 'leftKnee': (403, 694), 'leftAnkle': (374, 860)}


selected_point = None

def draw_points(img):
    for i in connections:
        cv2.line(img, points[i[0]], points[i[1]], (0, 255, 255), 2)

    for point_name, (x, y) in points.items():
        color = (0, 255, 0) if point_name == selected_point else (255, 0, 0)
        cv2.circle(img, (x, y), 5, color, -1)
        cv2.putText(img, point_name, (x - 15, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.4, (255, 255, 255), 1)

def click_event(event, x, y, flags, param):
    global selected_point

    if event == cv2.EVENT_LBUTTONDOWN:
        min_dist = min([euclidean_distance((x, y), (px, py)) for point_name, (px, py) in points.items()])
        for point_name, (px, py) in points.items():
            if selected_point == point_name:
                points[point_name] = (x, y)
                break
            elif selected_point is None and round(euclidean_distance((x, y), (px, py)), 3) == round(min_dist, 3):
                selected_point = point_name
                break

    print(f"Points: {points}")

cv2.namedWindow("Image")
cv2.setMouseCallback("Image", click_event)

while True:
    image_copy = image.copy()
    draw_points(image_copy)
    cv2.imshow("Image", image_copy)

    key = cv2.waitKey(1) & 0xFF
    if key == 27:  # Press 'Esc' to exit
        break
    elif key == ord('c'):  # Check for 'c' key press
        selected_point = None


cv2.destroyAllWindows()