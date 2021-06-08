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
import win32api
import keyboard
from collections import deque
from os import system
from os import path
import ctypes
import sys
import pywintypes


# 重启脚本
def restart():
    ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, __file__, None, 1)
    sys.exit(0)


# 检测是否存在配置与权重文件
def check_file(file, config_filename, weight_filename):
    cfg_filename = file + ".cfg"
    weights_filename = file + ".weights"
    if path.isfile(cfg_filename) and path.isfile(weights_filename):
        config_filename[0] += cfg_filename
        weight_filename[0] += weights_filename
        return
    else:
        print(f"请下载{file}相关文件!!!")
        sleep(3)
        sys.exit(0)


# 检查是否为管理员权限
def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except OSError as err:
        print("OS error: {0}".format(err))
        return False


# 清空命令指示符输出
def clear():
    _ = system("cls")


# 获取截图区域
def get_region(window_hwnd):
    # 获取窗口坐标数据
    rect = win32gui.GetClientRect(window_hwnd)

    # 通过窗口宽高比例确认截取区域宽高比例
    cut_modifier = 1
    if window_class[0] == "CrossFire":
        cut_modifier = (rect[2] - rect[0]) / (rect[3] - rect[1])
        cut_modifier /= (4 / 3)

    # 确认截取区域(宽高+左上角顶端坐标)
    cut_h = int((rect[3] - rect[1]) * 2 / 3)
    cut_w = int(cut_h * cut_modifier)
    inner_cut_x = int(rect[0] + (rect[2] - rect[0] - cut_w) / 2)
    inner_cut_y = int(rect[1] + (rect[3] - rect[1] - cut_h) / 2)
    cut_point = win32gui.ClientToScreen(hwnd, (inner_cut_x, inner_cut_y))  # 读取客户端内点相对全屏位置
    region = {"top": cut_point[1], "left": cut_point[0], "width": cut_w, "height": cut_h}
    return region


# 获取到屏幕左侧距离
def get_left(window_hwnd):
    distance_left = win32gui.ClientToScreen(window_hwnd, (0, 0))  # 读取客户端与屏幕左侧间距
    return distance_left[0]


# 截图转换为frame
def shot_screen(region_screen):
    try:
        frame = cv2.cvtColor(np.array(sct.grab(region_screen)), cv2.COLOR_BGRA2RGB)
    except cv2.error:
        frame = False
    return frame


# 移动鼠标
def mouse_move(a, b):  # Move mouse
    if window_class[0] == "CrossFire":
        x1 = int(a / 3)
        y1 = int(b / 4)
    elif window_class[0] == "Valve001":
        x1 = int(a / 1.2)
        y1 = int(b / 1.6)
    else:
        x1 = int(a / 3)
        y1 = int(b / 4)
    mouse_event(win32con.MOUSEEVENTF_MOVE, x1, y1, 0, 0)

    # 不分敌友射击
    if window_class[0] != "CrossFire":
        if math.sqrt(math.pow(a, 2) + math.pow(b, 2)) < 22:
            if (time.time() - button_time[1]) > 0.15:
                if not win32api.GetAsyncKeyState(win32con.VK_LBUTTON):
                    mouse_event(win32con.MOUSEEVENTF_LEFTDOWN, 0, 0)
                    button_time[0] = time.time()
            mouse_event(win32con.MOUSEEVENTF_MOVE, 0, 8, 0, 0)
        else:
            if (time.time() - button_time[0]) > 0.05:
                if win32api.GetAsyncKeyState(win32con.VK_LBUTTON):
                    button_time[1] = time.time()
            mouse_event(win32con.MOUSEEVENTF_LEFTUP, 0, 0)


# Press the green button in the gutter to run the script.
if __name__ == "__main__":
    # 检查管理员权限
    if not is_admin():
        restart()

    # 初始化变量
    sct = mss.mss()  # mss截图
    screenshot_time = deque()  # 截图用时
    aim = False  # 自瞄开关
    show_frame = False  # 展示开关
    begin = False  # 初始化检测
    show_fps = 0  # 效果展示帧数
    font = cv2.FONT_HERSHEY_SIMPLEX  # 效果展示字体
    CONFIG_FILE = ["./"]
    WEIGHT_FILE = ["./"]
    check_window = [0]
    i_pressed_times = 0
    o_pressed_times = 0
    p_pressed_times = 0
    button_time = [time.time(), time.time()]
    move_mouse = True
    hwnd = 0  # 窗口句柄

    # 选择加载模型
    aim_mode = 0
    while not (3 >= aim_mode >= 1):
        user_input = input("你想要的自瞄模式是?(1:极速, 2:标准, 3:高精): ")
        try:
            aim_mode = int(user_input)
        except ValueError:
            print("呵呵...请重新输入")

    check_file("yolov4-tiny-vvv", CONFIG_FILE, WEIGHT_FILE)
    std_confidence = 0.7
    if aim_mode == 1:  # 极速自瞄
        side_length = 416
    elif aim_mode == 2:  # 标准自瞄
        side_length = 512
    elif aim_mode == 3:  # 高精自瞄
        side_length = 608

    # 读取权重与配置文件
    net = cv2.dnn.readNetFromDarknet(CONFIG_FILE[0], WEIGHT_FILE[0])

    # 检测并设置在GPU上运行图像识别
    if cv2.cuda.getCudaEnabledDeviceCount():
        processor = " [使用GPU]"
        net.setPreferableBackend(cv2.dnn.DNN_BACKEND_CUDA)
        net.setPreferableTarget(cv2.dnn.DNN_TARGET_CUDA)
    else:
        processor = " [使用CPU]"

    # 读取YOLO神经网络内容
    ln = net.getLayerNames()
    ln = [ln[i[0] - 1] for i in net.getUnconnectedOutLayers()]

    # 寻找读取游戏窗口类型并确认截取位置
    supported_games = "Valve001 CrossFire Notepad3 LaunchUnrealUWindowsClient"  # Notepad3为了测试
    while not hwnd:  # 等待游戏窗口出现
        hwnd_active = win32gui.GetForegroundWindow()
        window_class = [win32gui.GetClassName(hwnd_active)]
        if window_class[0] not in supported_games:
            print("未启动可支持游戏!!!请启动后重试!!!")
        else:
            hwnd = win32gui.FindWindow(window_class[0], None)
        sleep(5)
    regions = get_region(hwnd)

    # 爆头位置
    if window_class[0] == "CrossFire" or window_class[0] == "Valve001":
        head_pos = 0.4
    else:
        head_pos = 0.4

    while True:
        if not begin:
            begin = True
            print("程序初始化完成")

        check_window[0] += 1
        if check_window[0] > 59:
            check_window[0] = 0
            hwnd = win32gui.FindWindow(window_class[0], None)
            try:
                regions = get_region(hwnd)  # 更新窗口位置
            except pywintypes.error:
                break

        # 1键/2键控制瞄准
        if keyboard.is_pressed("1") or keyboard.is_pressed("2"):
            move_mouse = True

        # 3键/4键取消瞄准
        if keyboard.is_pressed("3") or keyboard.is_pressed("4"):
            move_mouse = False

        # o键控制展示
        if keyboard.is_pressed("o"):
            if o_pressed_times == 0:
                o_pressed_times = time.time()
            if time.time() - o_pressed_times > 0.3:
                show_frame = not show_frame
                o_pressed_times = 0
        else:
            o_pressed_times = 0

        # i键控制开关
        if keyboard.is_pressed("i"):
            if i_pressed_times == 0:
                i_pressed_times = time.time()
            if time.time() - i_pressed_times > 0.3:
                aim = not aim
                i_pressed_times = 0
        else:
            i_pressed_times = 0

        # p键控制重启
        if keyboard.is_pressed("p"):
            if p_pressed_times == 0:
                p_pressed_times = time.time()
            if time.time() - p_pressed_times > 0.3:
                restart()
        else:
            p_pressed_times = 0

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
        try:
            if frames.any():
                frame_height, frame_width = frames.shape[:2]
        except AttributeError:  # 游戏窗口意外最小化后不强制(报错)退出
            continue

        # 画实心框避免错误检测武器与手
        if window_class[0] == "CrossFire":
            cv2.rectangle(frames, (int(frame_width*11/16), int(frame_height*3/5)), (frame_width, frame_height), (127, 127, 127), cv2.FILLED)
            cv2.rectangle(frames, (0, int(frame_height*3/5)), (int(frame_width*5/16), frame_height), (127, 127, 127), cv2.FILLED)
        elif window_class[0] == "Valve001":
            cv2.rectangle(frames, (int(frame_width*3/4), int(frame_height*2/3)), (frame_width, frame_height), (127, 127, 127), cv2.FILLED)
            cv2.rectangle(frames, (0, int(frame_height*2/3)), (int(frame_width*1/4), frame_height), (127, 127, 127), cv2.FILLED)

        # 检测
        blob = cv2.dnn.blobFromImage(frames, 1 / 255.0, (side_length, side_length), swapRB=True, crop=False)  # 转换为二进制大型对象
        net.setInput(blob)
        layerOutputs = net.forward(ln)  # 前向传播

        boxes = []
        confidences = []

        # 检测目标,计算框内目标到框中心距离
        for output in layerOutputs:
            for detection in output:
                scores = detection[5:]
                classID = np.argmax(scores)
                confidence = scores[classID]
                if confidence > std_confidence and classID == 0:  # 人类/body为0
                    box = detection[:4] * np.array([frame_width, frame_height, frame_width, frame_height])
                    (centerX, centerY, width, height) = box.astype("int")
                    x = int(centerX - (width / 2))
                    y = int(centerY - (height / 2))
                    box = [x, y, int(width), int(height)]
                    boxes.append(box)
                    confidences.append(float(confidence))

        # 移除重复
        indices = cv2.dnn.NMSBoxes(boxes, confidences, 0.5, 0.4)

        # 画框,计算距离框中心距离最小的威胁目标
        if len(indices) > 0:
            max_var = 0
            max_at = 0
            for i in indices.flatten():
                (x, y) = (boxes[i][0], boxes[i][1])
                (w, h) = (boxes[i][2], boxes[i][3])
                cv2.rectangle(frames, (x, y), (x + w, y + h), (255, 36, 0), 2)

                # 计算威胁指数(正面画框面积除以鼠标移动到近似爆头点距离)
                threat_var = math.sqrt(boxes[i][2] * boxes[i][3]) / math.sqrt(math.pow(frame_width / 2 - (x + w / 2), 2) + math.pow(frame_height / 2 - (y + h / 10), 2))
                if threat_var > max_var:
                    max_var = threat_var
                    max_at = i

            # 移动鼠标指向距离最近的威胁
            if move_mouse:
                x = int(boxes[max_at][0] + boxes[max_at][2] / 2 - frame_width / 2)
                y = int(boxes[max_at][1] + boxes[max_at][3] / 10 - frame_height / 2)  # 爆头优先
                mouse_move(x, y)

        # 防止按住不放
        elif len(indices) <= 0 and window_class[0] != "CrossFire":
            mouse_event(win32con.MOUSEEVENTF_LEFTUP, 0, 0)

        # 展示效果
        if show_frame:
            frames = cv2.cvtColor(frames, cv2.COLOR_BGR2RGB)  # 颜色转换回正常

            # 动态改变自瞄显示框大小
            try:
                left_distance = get_left(hwnd)
                if left_distance < frames.shape[1]:
                    if left_distance > 0:
                        size_scale = int(math.ceil(frames.shape[1] / left_distance))
                        frames = cv2.resize(frames, (frames.shape[1] // size_scale, frames.shape[0] // size_scale))

                cv2.putText(frames, str(show_fps), (10, 25), font, 0.5, (127, 255, 0), 2, cv2.LINE_AA)  # show fps
                cv2.imshow("frame", frames)
                cv2.waitKey(1)
            except pywintypes.error:
                print("窗口不可见!!!")

        else:
            cv2.destroyAllWindows()

        # 计算用时与帧率
        time_used = time.time() - ini_frame_time
        if time_used:
            fps = 1 / time_used
            screenshot_time.append(fps)
            if len(screenshot_time) > 29:
                screenshot_time.popleft()

        show_fps = round(mean(screenshot_time), 1)  # 计算fps
        if move_mouse:  # 控制瞄准标识
            print(f"\033[1;32;40m{processor} \033[1;36;40mFPS={show_fps}; \033[1;31;40m检测{len(indices)}人", end="\r")
        else:
            print(f"\033[0m{processor} FPS={show_fps}; 检测{len(indices)}人", end="\r")

    sys.exit(0)
