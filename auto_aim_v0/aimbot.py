"""
Modified from project AIMBOT-YOLO
Original Author: monokim
project website: https://github.com/monokim/AIMBOT-YOLO
project video: https://www.youtube.com/watch?v=vQlb0tK1DH0
"""
import math
import cv2
import numpy as np
# import pyautogui
import win32api
import win32con
import win32gui
import win32ui
import keyboard
from PIL import ImageGrab
from time import sleep
import time
import mss


def mousexy(a, b):  # Move mouse
    x = int(a / 4)
    y = int(b / 3)
    win32api.mouse_event(win32con.MOUSEEVENTF_MOVE, x, y, 0, 0)


def targeting(monitor):
    ini_frame_time = time.time()  # used to record the time at which we processed frames
    # Get image of screen
    frame = cv2.cvtColor(np.array(sct.grab(monitor)), cv2.COLOR_BGRA2RGB)
    # frame = np.array(ImageGrab.grab(bbox=(cfx, cfy, cfx+cfw, cfy+cfh)))
    # frame = np.array(pyautogui.screenshot(region=region))
    frame_height, frame_width = frame.shape[:2]

    # Detection
    blob = cv2.dnn.blobFromImage(frame, 1 / 255.0, (416, 416), swapRB=True, crop=False)
    net.setInput(blob)
    layerOutputs = net.forward(ln)

    boxes = []
    confidences = []

    for output in layerOutputs:
        for detection in output:
            scores = detection[5:]
            classID = np.argmax(scores)
            confidence = scores[classID]
            if confidence > std_confidence and classID == 0:
                box = detection[:4] * np.array([frame_width, frame_height, frame_width, frame_height])
                (centerX, centerY, width, height) = box.astype("int")
                x = int(centerX - (width / 2))
                y = int(centerY - (height / 2))
                box = [x, y, int(width), int(height)]
                boxes.append(box)
                confidences.append(float(confidence))

    indices = cv2.dnn.NMSBoxes(boxes, confidences, 0.5, 0.4)

    # Calculate distance for picking the closest enemy from crosshair
    if len(indices) > 0:
        print(f"Detected:{len(indices)}")
        min = 99999
        min_at = 0
        for i in indices.flatten():
            (x, y) = (boxes[i][0], boxes[i][1])
            (w, h) = (boxes[i][2], boxes[i][3])
            cv2.rectangle(frame, (x, y), (x + w, y + h), (255, 51, 0), 2)

            dist = math.sqrt(math.pow(frame_width / 2 - (x + w / 2), 2) + math.pow(frame_height / 2 - (y + h / 2), 2))
            if dist < min:
                min = dist
                min_at = i

        # Distance of the closest from crosshair
        x = int(boxes[min_at][0] + boxes[min_at][2] / 2 - frame_width / 2)
        y = int(boxes[min_at][1] + boxes[min_at][3] / 2 - frame_height / 2) - boxes[min_at][3] * 0.4  # For head shot
        mousexy(x, y)

    size_scale = 3
    fps = str(int(1 / (time.time() - ini_frame_time)))
    font = cv2.FONT_HERSHEY_SIMPLEX
    frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    frame = cv2.resize(frame, (frame.shape[1] // size_scale, frame.shape[0] // size_scale))
    cv2.putText(frame, fps, (10, 40), font, 1, (127, 255, 0), 3, cv2.LINE_AA)  # show fps
    cv2.imshow("frame", frame)
    cv2.waitKey(1)
    # sleep(0.001)


aim_mode = 0  # 选择加载模型
while not (aim_mode == "1" or aim_mode == "2"):
    aim_mode = input("你想要的自瞄模式是?(1:快速, 2:标准): ")

if aim_mode == "1":
    CONFIG_FILE = './yolov4-tiny.cfg'
    WEIGHT_FILE = './yolov4-tiny.weights'
    std_confidence = 0.3
else:
    CONFIG_FILE = './yolov4.cfg'
    WEIGHT_FILE = './yolov4.weights'
    std_confidence = 0.7

net = cv2.dnn.readNetFromDarknet(CONFIG_FILE, WEIGHT_FILE)
net.setPreferableBackend(cv2.dnn.DNN_BACKEND_CUDA)
net.setPreferableTarget(cv2.dnn.DNN_TARGET_CUDA)
if cv2.cuda.getCudaEnabledDeviceCount():
    print("正在使用GPU......")
else:
    print("正在使用CPU......")

ln = net.getLayerNames()
ln = [ln[i[0] - 1] for i in net.getUnconnectedOutLayers()]

windclass = 'CrossFire'    # Notepad3 CrossFire
hwnd = win32gui.FindWindow(windclass, None)
rect = win32gui.GetClientRect(hwnd)  # Get rect of Window
dc = win32gui.GetDC(0)
dcObj = win32ui.CreateDCFromHandle(dc)

if (rect[2] - rect[0]) / (rect[3] - rect[1]) > 1.7:
    cf_modifier = 4 / 3
else:
    cf_modifier = 1

cfh = int((rect[3] - rect[1]) * 3/5)  # 416*416 (rect[3] - rect[1]) 608*608
cfw = int(cfh * cf_modifier)
cfx = int(rect[0] + (rect[2] - rect[0] - cfw) / 2)
cfy = int(rect[1] + (rect[3] - rect[1] - cfh) / 2)
point = win32gui.ClientToScreen(hwnd, (cfx, cfy))  # get client area
region = {"top": point[1], "left": point[0], "width": cfw, "height": cfh}
print(f"x, y, w, h: {cfx, cfy, cfw, cfh}")  # confirm client area
aim = False
sct = mss.mss()


while win32gui.FindWindow(windclass, None):
    rect = win32gui.GetClientRect(hwnd)
    cfx = int(rect[0] + (rect[2] - rect[0] - cfw) / 2)
    cfy = int(rect[1] + (rect[3] - rect[1] - cfh) / 2)
    point = win32gui.ClientToScreen(hwnd, (cfx, cfy))
    region = {"top": point[1], "left": point[0], "width": cfw, "height": cfh}
    if keyboard.is_pressed('i'):
        aim = not aim
    if aim:
        targeting(region)
        dcObj.DrawFocusRect((point[0], point[1], point[0] + cfw, point[1] + cfh))
    else:
        cv2.destroyAllWindows()
        sleep(0.05)
