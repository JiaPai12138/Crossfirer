'''
Detection code modified from project AIMBOT-YOLO
Detection code Author: monokim
Detection project website: https://github.com/monokim/AIMBOT-YOLO
Detection project video: https://www.youtube.com/watch?v=vQlb0tK1DH0
Screenshot method from: https://www.youtube.com/watch?v=WymCpVUPWQ4
Screenshot method code modified from project: opencv_tutorials
Screenshot method code Author: Ben Johnson (learncodebygaming)
Screenshot method website: https://github.com/learncodebygaming/opencv_tutorials
'''

from math import sqrt, pow, ceil, floor
from multiprocessing import Process, Array, Pipe, freeze_support, JoinableQueue
from win32con import SRCCOPY, MOUSEEVENTF_MOVE, VK_LBUTTON, MOUSEEVENTF_LEFTDOWN, MOUSEEVENTF_LEFTUP
from win32api import mouse_event, GetAsyncKeyState
from keyboard import is_pressed
from collections import deque
from os import system, path, chdir
from ctypes import windll
from sys import exit, executable
from time import sleep, time
from platform import release
from statistics import mean
import queue
import numpy as np
import cv2
import win32gui
import win32ui
import pywintypes
import nvidia_smi


# 截图类
class WindowCapture:
    # 类属性
    total_w = 0  # 窗口内宽
    total_h = 0  # 窗口内高
    cut_w = 0  # 截取宽
    cut_h = 0  # 截取高
    hwnd = None  # 窗口句柄
    offset_x = 0  # 窗口内偏移x
    offset_y = 0  # 窗口内偏移y
    actual_x = 0  # 截图左上角屏幕位置x
    actual_y = 0  # 截图左上角屏幕位置y
    left_var = 0  # 窗口距离左侧距离

    # 构造函数
    def __init__(self, window_class):
        self.hwnd = win32gui.FindWindow(window_class, None)
        if not self.hwnd:
            raise Exception(f'\033[1;31;40m窗口类名未找到: {window_class}')

        # 获取窗口数据
        window_rect = win32gui.GetWindowRect(self.hwnd)
        client_rect = win32gui.GetClientRect(self.hwnd)
        left_corner = win32gui.ClientToScreen(self.hwnd, (0, 0))

        # 确认截图相关数据
        self.left_var = window_rect[0]
        self.total_w = client_rect[2] - client_rect[0]
        self.total_h = client_rect[3] - client_rect[1]
        self.cut_h = int(self.total_h * 2 / 3)
        self.cut_w = self.cut_h
        if window_class == 'CrossFire':  # 画面实际4:3简单拉平
            self.cut_w = int(self.cut_w * (self.total_w / self.total_h) / 4 * 3)
        self.offset_x = (self.total_w - self.cut_w) // 2 + left_corner[0] - window_rect[0]
        self.offset_y = (self.total_h - self.cut_h) // 2 + left_corner[1] - window_rect[1]
        self.actual_x = window_rect[0] + self.offset_x
        self.actual_y = window_rect[1] + self.offset_y

    def get_screenshot(self):
        # 获取截图相关
        try:
            wDC = win32gui.GetWindowDC(self.hwnd)
            dcObj = win32ui.CreateDCFromHandle(wDC)
            cDC = dcObj.CreateCompatibleDC()
            dataBitMap = win32ui.CreateBitmap()
            dataBitMap.CreateCompatibleBitmap(dcObj, self.cut_w, self.cut_h)
            cDC.SelectObject(dataBitMap)
            cDC.BitBlt((0, 0), (self.cut_w, self.cut_h), dcObj, (self.offset_x, self.offset_y), SRCCOPY)

            # 转换使得opencv可读
            signedIntsArray = dataBitMap.GetBitmapBits(True)
            cut_img = np.frombuffer(signedIntsArray, dtype='uint8')
            cut_img.shape = (self.cut_h, self.cut_w, 4)

            # 释放资源
            dcObj.DeleteDC()
            cDC.DeleteDC()
            win32gui.ReleaseDC(self.hwnd, wDC)
            win32gui.DeleteObject(dataBitMap.GetHandle())

            # 去除alpha
            cut_img = cut_img[..., :3]

            # 转换减少错误
            cut_img = np.ascontiguousarray(cut_img)
            return cut_img
        except (pywintypes.error, win32ui.error, ValueError):
            return None

    def get_cut_info(self):
        return self.cut_w, self.cut_h

    def get_actual_xy(self):
        return self.actual_x, self.actual_y

    def get_window_left(self):
        self.left_var = win32gui.GetWindowRect(self.hwnd)[0]
        return self.left_var


# 分析类
class FrameDetection:
    # 类属性
    side_length = 0  # 输入尺寸
    std_confidence = 0  # 置信度阀值
    win_class_name = ''  # 窗口类名
    CONFIG_FILE = ['./']
    WEIGHT_FILE = ['./']
    net = ''  # 建立网络
    ln = ''

    # 构造函数
    def __init__(self, aim_mode, hwnd_value, gpu_level):
        if aim_mode == 1:  # 极速自瞄
            self.side_length = 416
        elif aim_mode == 2:  # 标准自瞄
            self.side_length = 512
        elif aim_mode == 3:  # 高精自瞄
            self.side_length = 608

        self.win_class_name = win32gui.GetClassName(hwnd_value)
        if self.win_class_name == 'Valve001':
            self.std_confidence = 0.4
        elif self.win_class_name == 'CrossFire':
            self.std_confidence = 0.5
        else:
            self.std_confidence = 0.5

        load_file('yolov4-tiny-vvv', self.CONFIG_FILE, self.WEIGHT_FILE)
        self.net = cv2.dnn.readNetFromDarknet(self.CONFIG_FILE[0], self.WEIGHT_FILE[0])  # 读取权重与配置文件

        # 读取YOLO神经网络内容
        self.ln = self.net.getLayerNames()
        self.ln = [self.ln[i[0] - 1] for i in self.net.getUnconnectedOutLayers()]

        # 检测并设置在GPU上运行图像识别
        if cv2.cuda.getCudaEnabledDeviceCount():
            self.net.setPreferableBackend(cv2.dnn.DNN_BACKEND_CUDA)
            self.net.setPreferableTarget(cv2.dnn.DNN_TARGET_CUDA)
            if not check_gpu(gpu_level):
                print('您的显卡配置不够')
        else:
            print('您的没有可识别的N卡')

    def detect(self, frame):
        try:
            frames = np.array(frame)  # 从队列中读取帧
            try:
                if frames.any():
                    frame_height, frame_width = frames.shape[:2]
            except AttributeError:  # 游戏窗口意外最小化后不强制(报错)退出
                return
        except cv2.error:
            return

        try:
            frame_height += 0
            frame_width += 0
        except UnboundLocalError:
            return

        # 初始化返回数值
        x, y, fire_range, fire_pos = 0, 0, 0, 0

        # 画实心框避免错误检测武器与手
        if self.win_class_name == 'CrossFire':
            cv2.rectangle(frames, (int(frame_width*3/5), int(frame_height*3/4)), (frame_width, frame_height), (127, 127, 127), cv2.FILLED)
            cv2.rectangle(frames, (0, int(frame_height*3/4)), (int(frame_width*2/5), frame_height), (127, 127, 127), cv2.FILLED)
            if frame_width / frame_height > 1.3:
                frame_width = int(frame_width / 4 * 3)
                dim = (frame_width, frame_height)
                frames = cv2.resize(frames, dim, interpolation=cv2.INTER_AREA)
        elif self.win_class_name == 'Valve001':
            cv2.rectangle(frames, (int(frame_width*3/4), int(frame_height*3/5)), (frame_width, frame_height), (127, 127, 127), cv2.FILLED)
            cv2.rectangle(frames, (0, int(frame_height*3/5)), (int(frame_width*1/4), frame_height), (127, 127, 127), cv2.FILLED)

        # 检测
        blob = cv2.dnn.blobFromImage(frames, 1 / 255.0, (self.side_length, self.side_length), swapRB=False, crop=False)  # 转换为二进制大型对象
        self.net.setInput(blob)
        layerOutputs = self.net.forward(self.ln)  # 前向传播

        boxes = []
        confidences = []

        # 检测目标,计算框内目标到框中心距离
        for output in layerOutputs:
            for detection in output:
                scores = detection[5:]
                classID = np.argmax(scores)
                confidence = scores[classID]
                if confidence > self.std_confidence and classID == 0:  # 人类/body为0
                    box = detection[:4] * np.array([frame_width, frame_height, frame_width, frame_height])
                    (centerX, centerY, width, height) = box.astype('int')
                    x = int(centerX - (width / 2))
                    y = int(centerY - (height / 2))
                    box = [x, y, int(width), int(height)]
                    boxes.append(box)
                    confidences.append(float(confidence))

        # 移除重复
        indices = cv2.dnn.NMSBoxes(boxes, confidences, 0.3, 0.3)

        # 画框,计算距离框中心距离最小的威胁目标
        if len(indices) > 0:
            max_var = 0
            max_at = 0
            for j in indices.flatten():
                (x, y) = (boxes[j][0], boxes[j][1])
                (w, h) = (boxes[j][2], boxes[j][3])
                cv2.rectangle(frames, (x, y), (x + w, y + h), (0, 36, 255), 2)
                cv2.putText(frames, str(round(confidences[j], 3)), (x, y), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 2, cv2.LINE_AA)

                # 计算威胁指数(正面画框面积的平方根除以鼠标移动到目标距离)
                if h / w > 1.5:
                    dist = sqrt(pow(frame_width / 2 - (x + w / 2), 2) + pow(frame_height / 2 - (y + h * 3/16), 2))
                else:
                    dist = sqrt(pow(frame_width / 2 - (x + w / 2), 2) + pow(frame_height / 2 - (y + h / 2), 2))

                if dist:
                    threat_var = pow(boxes[j][2] * boxes[j][3], 1/2) / dist
                    if threat_var > max_var:
                        max_var = threat_var
                        max_at = j
                else:
                    max_at = j
                    break

            # 指向距离最近威胁的位移
            x = boxes[max_at][0] + (boxes[max_at][2] - frame_width) / 2
            if boxes[max_at][3] / boxes[max_at][2] > 1.5:
                y1 = boxes[max_at][1] + boxes[max_at][3] / 8 - frame_height / 2  # 爆头优先
                y2 = boxes[max_at][1] + boxes[max_at][3] / 4 - frame_height / 2  # 击中优先
                if abs(y1) <= abs(y2) or frame_width / boxes[max_at][2] <= 8:
                    y = y1
                    fire_range = ceil(boxes[max_at][2] / 5)  # 头宽约占肩宽二点五分之一
                    fire_pos = 1
                else:
                    y = y2
                    fire_range = ceil(boxes[max_at][2] / 3)
                    fire_pos = 2
            else:
                y = boxes[max_at][1] + (boxes[max_at][3] - frame_height) / 2
                fire_range = ceil(min(boxes[max_at][2], boxes[max_at][3]) / 2)
                fire_pos = 0

        return len(indices), int(x), int(y), int(fire_range), fire_pos, frames


# 简单检查gpu是否够格
def check_gpu(level):
    nvidia_smi.nvmlInit()
    handle = nvidia_smi.nvmlDeviceGetHandleByIndex(0)  # 默认卡1
    info = nvidia_smi.nvmlDeviceGetMemoryInfo(handle)
    memory_total = info.total / 1024 / 1024
    nvidia_smi.nvmlShutdown()
    if level == 1 and memory_total > 4092:  # 正常值为4096,减少损耗误报
        return True
    elif level == 2 and memory_total > 6140:  # 正常值为6144,减少损耗误报
        return True
    return False


# 高DPI感知
def set_dpi():
    if int(release()) >= 7:
        windll.user32.SetProcessDPIAware()
    else:
        exit(0)


# 确认窗口句柄与类名
def get_window_info():
    supported_games = 'Valve001 CrossFire LaunchUnrealUWindowsClient LaunchCombatUWindowsClient'
    test_window = 'Notepad3 PX_WINDOW_CLASS Notepad++'
    class_name = ''
    hwnd_var = ''
    testing_purpose = False
    while not hwnd_var:  # 等待游戏窗口出现
        hwnd_active = win32gui.GetForegroundWindow()
        try:
            class_name = win32gui.GetClassName(hwnd_active)
        except pywintypes.error:
            continue

        if class_name not in supported_games and class_name not in test_window:
            print('请使支持的游戏/程序窗口成为活动窗口...')
        else:
            hwnd_var = win32gui.FindWindow(class_name, None)
            print('已找到窗口')
            if class_name in test_window:
                testing_purpose = True
        sleep(3)
    return class_name, hwnd_var, testing_purpose


# 重启脚本
def restart():
    windll.shell32.ShellExecuteW(None, 'runas', executable, __file__, None, 1)
    exit(0)


# 加载配置与权重文件
def load_file(file, config_filename, weight_filename):
    cfg_filename = file + '.cfg'
    weights_filename = file + '.weights'
    config_filename[0] += cfg_filename
    weight_filename[0] += weights_filename
    return


# 检测是否存在配置与权重文件
def check_file(file):
    cfg_file = file + '.cfg'
    weights_file = file + '.weights'
    if not (path.isfile(cfg_file) and path.isfile(weights_file)):
        print(f'请下载{file}相关文件!!!')
        sleep(3)
        exit(0)


# 检查是否为管理员权限
def is_admin():
    try:
        return windll.shell32.IsUserAnAdmin()
    except OSError as err:
        print('OS error: {0}'.format(err))
        return False


# 清空命令指示符输出
def clear():
    _ = system('cls')


# 移动鼠标(并射击)
def control_mouse(a, b, fps_var, ranges, win_class):
    if fps_var:
        if win_class == 'CrossFire':
            x0 = a / 4 / (fps_var / 21.6)  # 32
            y0 = b / 4 / (fps_var / 16.2)
        elif win_class == 'Valve001':
            x0 = a / 1.56 / (fps_var / 36)  # 2.5
            y0 = b / 1.56 / (fps_var / 27)
        elif win_class == 'LaunchCombatUWindowsClient':
            x0 = a / (fps_var / 24)  # 10.0
            y0 = b / (fps_var / 18)
        else:
            x0 = a / (fps_var / 20)
            y0 = b / (fps_var / 15)
        mouse_event(MOUSEEVENTF_MOVE, int(round(x0)), int(round(y0)), 0, 0)

    # 不分敌友射击
    if win_class != 'CrossFire':
        if floor(sqrt(pow(a, 2) + pow(b, 2))) <= ranges:
            if (time() * 1000 - press_time[0]) > 150:
                if not GetAsyncKeyState(VK_LBUTTON):
                    mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0)
                    up_time[0] = int(time() * 1000)
        else:
            if (time() * 1000 - up_time[0]) > 50:
                if GetAsyncKeyState(VK_LBUTTON):
                    press_time[0] = int(time() * 1000)
                mouse_event(MOUSEEVENTF_LEFTUP, 0, 0)


# 转变状态
def check_status(exit0, mouse):
    if is_pressed('end'):
        exit0 = True
    if is_pressed('1') or is_pressed('2'):
        mouse = True
    if is_pressed('3') or is_pressed('4'):
        mouse = False
    if is_pressed('i'):
        arr[4] = 0
    if is_pressed('o'):
        arr[4] = 1
    if is_pressed('p'):
        show_proc.terminate()
        detect1_proc.terminate()
        # detect2_proc.terminate()
        restart()

    return exit0, mouse


# 多线程展示效果
def show_frames(output_pipe, array):
    set_dpi()
    cv2.namedWindow('Show frame')
    cv2.moveWindow('Show frame', 0, 0)
    cv2.destroyAllWindows()
    font = cv2.FONT_HERSHEY_SIMPLEX  # 效果展示字体
    while True:
        show_img = output_pipe.recv()
        try:
            if show_img.any():
                try:
                    show_img = cv2.resize(show_img, (show_img.shape[1] // array[5], show_img.shape[0] // array[5]))
                except ZeroDivisionError:
                    show_img = cv2.resize(show_img, (show_img.shape[1] // temp_division, show_img.shape[0] // temp_division))
                cv2.putText(show_img, str(array[3]), (10, 25), font, 0.5, (127, 255, 0), 2, cv2.LINE_AA)
                cv2.imshow('Show frame', show_img)
                cv2.waitKey(1)
                if array[5]:
                    temp_division = array[5]
        except AttributeError:
            cv2.destroyAllWindows()


# 第一分析进程(主)
def detection1(que, array, frame_in):
    Analysis1 = FrameDetection(array[10], array[0], 2)
    array[1] = 1
    while True:
        if not que.empty():
            try:
                frame1 = que.get_nowait()
                que.task_done()
                array[1] = 2
                array[11], array[7], array[8], array[9], array[12], frame = Analysis1.detect(frame1)

                if array[4]:
                    frame_in.send(frame)
                else:
                    frame_in.send(0)
            except (queue.Empty, TypeError):
                continue
        array[1] = 1


# 第二分析进程(备)
def detection2(que, array):
    Analysis2 = FrameDetection(array[10], array[0], 2)
    array[2] = 1
    while True:
        if array[1] == 2 and not que.empty():
            try:
                frame2 = que.get_nowait()
                que.task_done()
                array[2] = 2
                array[11], array[7], array[8], array[9], array[12], frame = Analysis2.detect(frame2)
            except (queue.Empty, TypeError):
                continue
        array[2] = 1


# 主程序
if __name__ == '__main__':
    # 为了Pyinstaller顺利生成exe
    freeze_support()

    # 检查管理员权限
    if not is_admin():
        restart()

    # 设置高DPI不受影响
    set_dpi()

    # 设置工作路径
    chdir(path.dirname(path.abspath(__file__)))

    # 选择分析输入大小
    aim_mode = 0
    while not (3 >= aim_mode >= 1):
        user_input = input('你想要的自瞄模式是?(1:极速, 2:标准, 3:高精): ')
        try:
            aim_mode = int(user_input)
        except ValueError:
            print('呵呵...请重新输入')

    # 初始化变量
    queue = JoinableQueue()  # 初始化队列
    frame_output, frame_input = Pipe(False)  # 初始化管道(receiving,sending)
    press_time, up_time, show_fps = [0], [0], [1]
    process_time = deque()
    move_mouse = False
    exit_program = False
    fire_target = ["中", "头", "胸"]

    # 如果文件不存在则退出
    check_file('yolov4-tiny-vvv')

    # 分享数据以及展示新进程
    arr = Array('i', range(21))
    '''
    0  窗口句柄
    1  第一分析进程状态
    2  第二分析进程状态
    3  截图FPS整数值
    4  开关特效显示
    5  左侧距离除数
    6  使用GPU/CPU(1/0)
    7  鼠标移动x
    8  鼠标移动y
    9  鼠标开火r
    10 自瞄模式
    11 敌人数量
    12 瞄准位置
    13
    '''

    show_proc = Process(target=show_frames, args=(frame_output, arr,))
    show_proc.start()
    arr[1] = 0  # 第一分析进程状态
    arr[2] = 0  # 第二分析进程状态
    arr[3] = 0  # FPS值
    arr[4] = 0  # 开关效果展示
    arr[7] = 0  # 鼠标移动x
    arr[8] = 0  # 鼠标移动r
    arr[9] = 0  # 鼠标开火r
    arr[10] = aim_mode  # 自瞄模式
    arr[11] = 0  # 敌人数量
    arr[12] = 0  # 瞄准位置
    detect1_proc = Process(target=detection1, args=(queue, arr, frame_input,))
    # detect2_proc = Process(target=detection2, args=(queue, arr,))

    # 寻找读取游戏窗口类型并确认截取位置
    window_class_name, window_hwnd, test_win = get_window_info()
    arr[0] = window_hwnd

    # 等待游戏画面完整出现(拥有大于0的长宽)
    window_ready = 0
    while not window_ready:
        sleep(1)
        win_client_rect = win32gui.GetClientRect(window_hwnd)
        if win_client_rect[2] - win_client_rect[0] > 0 and win_client_rect[3] - win_client_rect[1] > 0:
            window_ready = 1

    # 初始化截图类
    win_cap = WindowCapture(window_class_name)

    # 开始分析进程
    detect1_proc.start()
    # detect2_proc.start()

    # 等待分析类初始化
    while not arr[1]:  # and arr[2]
        sleep(1)

    # 清空命令指示符面板
    clear()

    while True:
        ini_sct_time = time()  # 计时
        screenshot = win_cap.get_screenshot()  # 截屏
        try:
            screenshot.any()
        except AttributeError:
            break
        queue.put_nowait(screenshot)
        queue.join()

        exit_program, move_mouse = check_status(exit_program, move_mouse)

        if exit_program:
            break

        if win32gui.GetForegroundWindow() == window_hwnd:
            if arr[11] and move_mouse:
                control_mouse(arr[7], arr[8], show_fps[0], arr[9], window_class_name)
            elif GetAsyncKeyState(VK_LBUTTON) and window_class_name != 'CrossFire' and not test_win:
                mouse_event(MOUSEEVENTF_LEFTUP, 0, 0)  # 防止一次性按太长时间

        if arr[4]:
            try:
                if win_cap.get_window_left() > 0:
                    if window_class_name == 'CrossFire' and screenshot.shape[1] / screenshot.shape[0] > 1.7:
                        screenshot.shape[1] *= 4/3
                    arr[5] = int(ceil(screenshot.shape[1] / win_cap.get_window_left()))
                else:
                    arr[4] = 0  # 全屏或屏幕靠左不显示效果
            except pywintypes.error:
                break

        time_used = time() - ini_sct_time
        if time_used:  # 防止被0除
            current_fps = 1 / time_used
            process_time.append(current_fps)
            if len(process_time) > 59:
                process_time.popleft()

            show_fps[0] = mean(process_time)  # 计算fps
            arr[3] = int(show_fps[0])

        if move_mouse:
            print(f'\033[0;30;42m FPS={show_fps[0]:.2f}\033[0;30;43m 检测{arr[11]}人\033[0;30;46m 瞄准{fire_target[arr[12]]}部\033[0m', end='\r')
        else:
            print(f' FPS={show_fps[0]:.2f} 检测{arr[11]}人 瞄准{fire_target[arr[12]]}部', end='\r')

    detect1_proc.terminate()
    # detect2_proc.terminate()
    show_proc.terminate()
    exit(0)
