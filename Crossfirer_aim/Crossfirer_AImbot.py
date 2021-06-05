"""
Modified from project AIMBOT-YOLO
Original Author: monokim
Original project website: https://github.com/monokim/AIMBOT-YOLO
Original project video: https://www.youtube.com/watch?v=vQlb0tK1DH0
"""
import math
import mss
import time
import numpy as np
import cv2
from statistics import mean
import win32con
import win32gui
from time import sleep
from win32api import mouse_event
import keyboard
from collections import deque
from os import system


# 清空命令指示符输出
def clear():
    _ = system('cls')


# 获取截图区域
def get_region(window_hwnd):
    # 获取窗口坐标数据
    rect = win32gui.GetClientRect(window_hwnd)

    # 通过窗口宽高比例确认截取区域宽高比例
    cf_modifier = (rect[2] - rect[0]) / (rect[3] - rect[1]) / (4 / 3)

    # 确认截取区域(宽高+左上角顶端坐标)
    cfh = int((rect[3] - rect[1]) * 3 / 5)  # 416*416 (rect[3] - rect[1])
    cfw = int(cfh * cf_modifier)
    inner_cfx = int(rect[0] + (rect[2] - rect[0] - cfw) / 2)
    inner_cfy = int(rect[1] + (rect[3] - rect[1] - cfh) / 2)
    cf_point = win32gui.ClientToScreen(hwnd, (inner_cfx, inner_cfy))  # 读取客户端内点相对全屏位置
    region = {"top": cf_point[1], "left": cf_point[0], "width": cfw, "height": cfh}
    return region


# 获取到屏幕左侧距离
def get_left(window_hwnd):
    distance_left = win32gui.ClientToScreen(window_hwnd, (0, 0))  # 读取客户端与屏幕左侧间距
    return distance_left[0]


# 截图转换为frame
def shot_screen(region_screen):
    frame = cv2.cvtColor(np.array(sct.grab(region_screen)), cv2.COLOR_BGRA2RGB)
    return frame


# 移动鼠标
def mouse_move(a, b):  # Move mouse
    x1 = int(a / 3)
    y1 = int(b / 4)
    mouse_event(win32con.MOUSEEVENTF_MOVE, x1, y1, 0, 0)


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    # 检查管理员权限

    # 初始化mss截图,截图用时,自瞄开关,展示开关,初始化检测,效果展示帧数,效果展示字体
    sct = mss.mss()
    screenshot_time = deque()
    aim = False
    show_frame = False
    begin = False
    show_fps = 0
    font = cv2.FONT_HERSHEY_SIMPLEX

    # 选择加载模型
    aim_mode = 0
    while not (aim_mode == "1" or aim_mode == "2"):
        aim_mode = input("你想要的自瞄模式是?(1:快速, 2:标准): ")

    if aim_mode == "1":  # 快速自瞄
        CONFIG_FILE = './yolov4-tiny.cfg'
        WEIGHT_FILE = './yolov4-tiny.weights'
        std_confidence = 0.3
        side_length = 416
    elif aim_mode == "2":  # 标准自瞄
        CONFIG_FILE = './yolov4.cfg'
        WEIGHT_FILE = './yolov4.weights'
        std_confidence = 0.7
        side_length = 320

    # 读取权重与配置文件
    net = cv2.dnn.readNetFromDarknet(CONFIG_FILE, WEIGHT_FILE)

    # 检测并设置在GPU上运行图像识别
    if cv2.cuda.getCudaEnabledDeviceCount():
        processor = "=GPU"
        net.setPreferableBackend(cv2.dnn.DNN_BACKEND_CUDA)
        net.setPreferableTarget(cv2.dnn.DNN_TARGET_CUDA)
    else:
        processor = "-CPU"

    # 读取YOLO神经网络内容
    ln = net.getLayerNames()
    ln = [ln[i[0] - 1] for i in net.getUnconnectedOutLayers()]

    # 寻找读取穿越火线窗口类型并确认截取位置
    window_class = 'CrossFire'  # Notepad3 CrossFire
    hwnd = win32gui.FindWindow(window_class, None)
    while not hwnd:  # 等待游戏窗口出现
        print("未启动穿越火线!!!请启动后重试!!!")
        hwnd = win32gui.FindWindow(window_class, None)
        sleep(5)
    regions = get_region(hwnd)

    while win32gui.FindWindow(window_class, None):
        if not begin:
            begin = True
            print("程序初始化完成")

        # 更新窗口位置
        regions = get_region(hwnd)

        # o键控制展示
        if keyboard.is_pressed('o'):
            show_frame = not show_frame

        # i键控制开关
        if keyboard.is_pressed('i'):
            aim = not aim

        # 自瞄开关,关则跳过后续
        if not aim:
            clear()
            cv2.destroyAllWindows()
            show_frame = False
            sleep(0.05)
            continue

        display_text = True
        ini_frame_time = time.time()  # 开始记时点

        # 截取帧
        frames = shot_screen(regions)
        frame_height, frame_width = frames.shape[:2]

        # 画实心框避免错误检测武器
        cv2.rectangle(frames, (int(frame_width*11/16), int(frame_height*2/3)), (frame_width, frame_height), (127, 127, 127), cv2.FILLED)
        cv2.rectangle(frames, (0, int(frame_height*2/3)), (int(frame_width*5/16), frame_height), (127, 127, 127), cv2.FILLED)

        # 检测
        blob = cv2.dnn.blobFromImage(frames, 1 / 255.0, (side_length, side_length), swapRB=True, crop=False)  # 转换为二进制大型对象
        net.setInput(blob)
        layerOutputs = net.forward(ln)  # 前向传播

        boxes = []
        confidences = []

        # 检测目标,画框,计算框内目标到框中心距离
        for output in layerOutputs:
            for detection in output:
                scores = detection[5:]
                classID = np.argmax(scores)
                confidence = scores[classID]
                if confidence > std_confidence and classID == 0:  # 人类为0
                    box = detection[:4] * np.array([frame_width, frame_height, frame_width, frame_height])
                    (centerX, centerY, width, height) = box.astype("int")
                    x = int(centerX - (width / 2))
                    y = int(centerY - (height / 2))
                    box = [x, y, int(width), int(height)]
                    boxes.append(box)
                    confidences.append(float(confidence))

        # 移除重复框
        indices = cv2.dnn.NMSBoxes(boxes, confidences, 0.5, 0.4)

        # 计算距离框中心距离最小的人类目标
        if len(indices) > 0:
            min_var = 99999
            min_at = 0
            for i in indices.flatten():
                (x, y) = (boxes[i][0], boxes[i][1])
                (w, h) = (boxes[i][2], boxes[i][3])
                cv2.rectangle(frames, (x, y), (x + w, y + h), (255, 36, 0), 1)

                # 计算最小直线距离
                dist = math.sqrt(math.pow(frame_width / 2 - (x + w / 2), 2) + math.pow(frame_height / 2 - (y + h / 2), 2))
                if dist < min_var:
                    min_var = dist
                    min_at = i

            # 移动鼠标指向距离最近的敌人
            x = int(boxes[min_at][0] + boxes[min_at][2] / 2 - frame_width / 2)
            y = int(boxes[min_at][1] + boxes[min_at][3] / 2 - frame_height / 2) - boxes[min_at][3] * 0.4  # 爆头优先
            mouse_move(x, y)

        # 展示效果
        if show_frame:
            frames = cv2.cvtColor(frames, cv2.COLOR_BGR2RGB)  # 颜色转换回正常

            # 动态改变自瞄显示框大小
            left_distance = get_left(hwnd)
            if left_distance < frames.shape[1]:
                if left_distance > 0:
                    size_scale = int(math.ceil(frames.shape[1] / left_distance))
                    frames = cv2.resize(frames, (frames.shape[1] // size_scale, frames.shape[0] // size_scale))

            cv2.putText(frames, str(show_fps), (10, 25), font, 0.5, (127, 255, 0), 2, cv2.LINE_AA)  # show fps
            cv2.imshow("frame", frames)
            cv2.waitKey(1)
        else:
            cv2.destroyAllWindows()

        # 计算用时与帧率
        time_used = time.time() - ini_frame_time
        if time_used:
            fps = 1 / time_used
            screenshot_time.append(fps)
            if len(screenshot_time) > 20:
                screenshot_time.popleft()

        show_fps = round(mean(screenshot_time), 1)
        print(f"\033[1;32;40m使用{processor}; \033[1;36;40mFPS={show_fps}; \033[1;31;40m检测{len(indices)}人", end="\r")
