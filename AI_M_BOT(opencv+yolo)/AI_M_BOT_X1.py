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

from win32con import VK_LBUTTON, VK_END, PROCESS_ALL_ACCESS, SPI_GETMOUSE, SPI_SETMOUSE, SPI_GETMOUSESPEED, SPI_SETMOUSESPEED
from ctypes import windll, c_long, c_ulong, Structure, Union, c_int, POINTER, sizeof
from multiprocessing import Process, Array, Pipe, freeze_support, JoinableQueue
from win32api import GetAsyncKeyState, GetCurrentProcessId, OpenProcess
from win32process import SetPriorityClass, ABOVE_NORMAL_PRIORITY_CLASS
from sys import exit, executable, platform
from math import sqrt, pow, ceil
from collections import deque
from statistics import median
from time import sleep, time
from platform import release
from random import uniform
import numpy as np
import pywintypes
import win32gui
import pynvml
import queue
import mss
import cv2
import os


# ↓↓↓↓↓↓↓↓↓ 简易鼠标行为模拟,使用SendInput函数 ↓↓↓↓↓↓↓↓↓
LONG = c_long
DWORD = c_ulong
ULONG_PTR = POINTER(DWORD)

class MOUSEINPUT(Structure):
    _fields_ = (('dx', LONG),
                ('dy', LONG),
                ('mouseData', DWORD),
                ('dwFlags', DWORD),
                ('time', DWORD),
                ('dwExtraInfo', ULONG_PTR))

class _INPUTunion(Union):
    _fields_ = (('mi', MOUSEINPUT), ('mi', MOUSEINPUT))

class INPUT(Structure):
    _fields_ = (('type', DWORD),
                ('union', _INPUTunion))

def SendInput(*inputs):
    nInputs = len(inputs)
    LPINPUT = INPUT * nInputs
    pInputs = LPINPUT(*inputs)
    cbSize = c_int(sizeof(INPUT))
    return windll.user32.SendInput(nInputs, pInputs, cbSize)

def Input(structure):
    return INPUT(0, _INPUTunion(mi=structure))

def MouseInput(flags, x, y, data):
    return MOUSEINPUT(x, y, data, flags, 0, None)

def Mouse(flags, x=0, y=0, data=0):
    return Input(MouseInput(flags, x, y, data))

def sp_mouse_xy(x, y):
    return SendInput(Mouse(0x0001, x, y))

def sp_mouse_down(key = 'LButton'):
    if key == 'LButton':
        return SendInput(Mouse(0x0002))
    elif key == 'RButton':
        return SendInput(Mouse(0x0008))

def sp_mouse_up(key = 'LButton'):
    if key == 'LButton':
        return SendInput(Mouse(0x0004))
    elif key == 'RButton':
        return SendInput(Mouse(0x0010))
# ↑↑↑↑↑↑↑↑↑ 简易鼠标行为模拟,使用SendInput函数 ↑↑↑↑↑↑↑↑↑


# 截图类
class WindowCapture:
    # 类属性
    hwnd = ''  # 窗口句柄
    windows_class = ''  # 窗口类名
    total_w, total_h = 0, 0  # 窗口内宽高
    cut_w, cut_h = 0, 0  # 截取宽高
    offset_x, offset_y = 0, 0  # 窗口内偏移x,y
    actual_x, actual_y = 0, 0  # 截图左上角屏幕位置x,y
    left_corner = [0, 0]  # 窗口左上角屏幕位置
    sct = mss.mss()  # 初始化mss截图

    # 构造函数
    def __init__(self, window_class, window_hwnd):
        self.windows_class = window_class
        try:
            self.hwnd = win32gui.FindWindow(window_class, None)
        except pywintypes.error:
            self.hwnd = window_hwnd
        if not self.hwnd:
            raise Exception(f'\033[1;31;40m窗口类名未找到: {window_class}')
        self.update_window_info()

    def update_window_info(self):
        try:
            # 获取窗口数据
            window_rect = win32gui.GetWindowRect(self.hwnd)
            client_rect = win32gui.GetClientRect(self.hwnd)
            self.left_corner = win32gui.ClientToScreen(self.hwnd, (0, 0))
        except pywintypes.error:
            pass

        # 确认截图相关数据
        self.total_w = client_rect[2] - client_rect[0]
        self.total_h = client_rect[3] - client_rect[1]
        self.cut_h = self.total_h // 2
        self.cut_w = self.cut_h
        if self.windows_class == 'CrossFire':  # 画面实际4:3简单拉平
            self.cut_w = int(self.cut_w * (self.total_w / self.total_h) * 3 / 4)
        self.offset_x = (self.total_w - self.cut_w) // 2 + self.left_corner[0] - window_rect[0]
        self.offset_y = (self.total_h - self.cut_h) // 2 + self.left_corner[1] - window_rect[1]
        self.actual_x = window_rect[0] + self.offset_x
        self.actual_y = window_rect[1] + self.offset_y

    def get_cut_info(self):
        return self.cut_w, self.cut_h

    def get_actual_xy(self):
        return self.actual_x, self.actual_y

    def get_window_left(self):
        return win32gui.GetWindowRect(self.hwnd)[0]

    def get_region(self):
        self.update_window_info()
        return (self.actual_x, self.actual_y, self.actual_x + self.cut_w, self.actual_y + self.cut_h)

    def grab_screenshot(self):
        return cv2.cvtColor(np.array(self.sct.grab(self.get_region())), cv2.COLOR_RGBA2RGB)


# 分析类
class FrameDetection:
    # 类属性
    side_length = 416  # 输入尺寸
    std_confidence = 0  # 置信度阀值
    conf_thd = 0.4  # 置信度阀值
    nms_thd = 0.3  # 非极大值抑制
    win_class_name = ''  # 窗口类名
    class_names = ''  # 检测类名
    CONFIG_FILE = ['./']
    WEIGHT_FILE = ['./']
    COLORS = []
    model = ''  # 建立模型
    net = ''  # 建立网络

    # 构造函数
    def __init__(self, hwnd_value):
        self.win_class_name = win32gui.GetClassName(hwnd_value)
        self.std_confidence = {
            'Valve001': 0.45,
            'CrossFire': 0.45,
        }.get(self.win_class_name, 0.5)

        load_file('yolov4-tiny', self.CONFIG_FILE, self.WEIGHT_FILE)
        self.net = cv2.dnn.readNet(self.CONFIG_FILE[0], self.WEIGHT_FILE[0])  # 读取权重与配置文件
        self.model = cv2.dnn_DetectionModel(self.net)
        self.model.setInputParams(size=(self.side_length, self.side_length), scale=1/255, swapRB=False)
        try:
            with open('classes.txt', 'r') as f:
                self.class_names = [cname.strip() for cname in f.readlines()]
        except FileNotFoundError:
            self.class_names = ['live-body', 'dead-body']
        for i in range(len(self.class_names)):
            self.COLORS.append(tuple(np.random.randint(256, size=3).tolist()))

        # 检测并设置在GPU上运行图像识别
        if cv2.cuda.getCudaEnabledDeviceCount():
            self.net.setPreferableBackend(cv2.dnn.DNN_BACKEND_CUDA)
            gpu_eval = check_gpu()
            if gpu_eval == 2:
                self.net.setPreferableTarget(cv2.dnn.DNN_TARGET_CUDA_FP16)
            else:
                self.net.setPreferableTarget(cv2.dnn.DNN_TARGET_CUDA)
            gpu_message = {
                2: '小伙电脑顶呱呱啊',
                1: '战斗完全木得问题',
            }.get(gpu_eval, '您的显卡配置不够')
            print(gpu_message)
        else:
            self.net.setPreferableBackend(cv2.dnn.DNN_BACKEND_OPENCL)
            self.net.setPreferableTarget(cv2.dnn.DNN_TARGET_OPENCL)
            print('您没有可识别的N卡')

    def detect(self, frames):
        try:
            if frames.any():
                frame_height, frame_width = frames.shape[:2]
            frame_height += 0
            frame_width += 0
        except (cv2.error, AttributeError, UnboundLocalError):
            return

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

        # 初始化返回数值
        x0, y0, fire_range, fire_pos, fire_close, fire_ok = 0, 0, 0, 0, 0, 0

        # 检测
        classes, scores, boxes = self.model.detect(frames, self.conf_thd, self.nms_thd)
        threat_list = []

        # 画框
        for (classid, score, box) in zip(classes, scores, boxes):
            if score > self.std_confidence:
                color = self.COLORS[int(classid) % len(self.COLORS)]
                label = self.class_names[classid[0]] + ': ' + str(round(score[0], 3))
                x, y, w, h = box
                cv2.rectangle(frames, (x, y), (x + w, y + h), color, 2)
                cv2.putText(frames, label, (int(x + w/2 - 4*len(label)), int(y + h/2 - 8)), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 2)

                # 计算威胁指数(正面画框面积的平方根除以鼠标移动到目标距离)
                if classid == 0:
                    h_factor = (0.1875 if h > w else 0.5)
                    dist = sqrt(pow(frame_width / 2 - (x + w / 2), 2) + pow(frame_height / 2 - (y + h * h_factor), 2))
                    threat_var = -(pow(w * h, 1/2) / dist if dist else 999)
                    threat_list.append([threat_var, box])

        if len(threat_list):
            threat_list.sort(key=lambda x:x[0])
            x_tht, y_tht, w_tht, h_tht = threat_list[0][1]

            # 指向距离最近威胁的位移
            x0 = x_tht + (w_tht - frame_width) / 2
            if h_tht > w_tht:
                y1 = y_tht + h_tht / 8 - frame_height / 2  # 爆头优先
                y2 = y_tht + h_tht / 4 - frame_height / 2  # 击中优先
                fire_close = (1 if frame_width / w_tht <= 8 else 0)
                if abs(y1) <= abs(y2) or fire_close:
                    y0 = y1
                    fire_range = w_tht / 8
                    fire_pos = 1
                else:
                    y0 = y2
                    fire_range = w_tht / 4
                    fire_pos = 2
            else:
                y0 = y_tht + (h_tht - frame_height) / 2
                fire_range = min(w_tht, h_tht) / 2
                fire_pos = 0

            xpos = x0 + frame_width / 2
            ypos = y0 + frame_height / 2
            cv2.line(frames, (frame_width // 2, frame_height // 2), (int(xpos), int(ypos)), (0, 0, 255), 2)

            # 查看是否已经指向目标
            if 1/4 * w_tht > abs(frame_width / 2 - x_tht - w_tht / 2) and 2/5 * h_tht > abs(frame_height / 2 - y_tht - h_tht / 2):
                fire_ok = 1

        return len(threat_list), int(x0), int(y0), int(ceil(fire_range)), fire_pos, fire_close, fire_ok, frames


# 简单检查gpu是否够格
def check_gpu():
    pynvml.nvmlInit()
    gpu_handle = pynvml.nvmlDeviceGetHandleByIndex(0)  # 默认卡1
    gpu_name = pynvml.nvmlDeviceGetName(gpu_handle)
    memory_info = pynvml.nvmlDeviceGetMemoryInfo(gpu_handle)
    pynvml.nvmlShutdown()
    if b'RTX' in gpu_name:
        return 2
    memory_total = memory_info.total / 1024 / 1024
    if memory_total > 3000:
        return 1
    return 0


# 高DPI感知
def set_dpi():
    if int(release()) >= 7:
        try:
            windll.shcore.SetProcessDpiAwareness(1)
        except:
            windll.user32.SetProcessDPIAware()
    else:
        exit(0)


# 确认窗口句柄与类名
def get_window_info():
    supported_games = 'Valve001 CrossFire LaunchUnrealUWindowsClient LaunchCombatUWindowsClient'
    test_window = 'Notepad3 PX_WINDOW_CLASS Notepad Notepad++'
    class_name = ''
    hwnd_var = ''
    testing_purpose = False
    while not hwnd_var:  # 等待游戏窗口出现
        hwnd_active = win32gui.GetForegroundWindow()
        try:
            class_name = win32gui.GetClassName(hwnd_active)
        except pywintypes.error:
            continue

        if class_name not in (supported_games + test_window):
            print('请使支持的游戏/程序窗口成为活动窗口...')
        else:
            try:
                hwnd_var = win32gui.FindWindow(class_name, None)
            except pywintypes.error:
                print('您正使用沙盒')
                hwnd_var = hwnd_active
            print('已找到窗口')
            if class_name in test_window:
                testing_purpose = True
        sleep(3)
    return class_name, hwnd_var, testing_purpose


# 重启脚本
def restart():
    windll.shell32.ShellExecuteW(None, 'runas', executable, __file__, None, 1)
    exit(0)


# 退出脚本
def close():
    show_proc.terminate()
    detect_proc.terminate()


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
    if not (os.path.isfile(cfg_file) and os.path.isfile(weights_file)):
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
    _ = os.system('cls')


# 移动鼠标(并射击)
def control_mouse(a, b, fps_var, ranges, rate, go_fire, win_class, move_rx, move_ry):
    recoil_control = 0
    move_range = sqrt(pow(a, 2) + pow(b, 2))
    DPI_Var = windll.user32.GetDpiForWindow(window_hwnd_name) / 96
    enhanced_holdback = win32gui.SystemParametersInfo(SPI_GETMOUSE)
    if enhanced_holdback[1]:
        win32gui.SystemParametersInfo(SPI_SETMOUSE, [0, 0, 0], 0)
    mouse_speed = win32gui.SystemParametersInfo(SPI_GETMOUSESPEED)
    if mouse_speed != 10:
        win32gui.SystemParametersInfo(SPI_SETMOUSESPEED, 10, 0)

    if fps_var and arr[17] and arr[11]:
        if move_range > 6 * ranges:
            a = uniform(0.9 * a, 1.1 * a)
            b = uniform(0.9 * b, 1.1 * b)
        a /= DPI_Var
        b /= DPI_Var
        fps_factor = pow(fps_var/3, 1/3)
        x0 = {
            'CrossFire': a / 2.719 * (client_ratio / (4/3)) / fps_factor,  # 32
            'Valve001': a * 1.667 / fps_factor,  # 2.5 + mouse acceleration
            'LaunchCombatUWindowsClient': a * 1.319 / fps_factor,  # 10.0
            'LaunchUnrealUWindowsClient': a / 2.557 / fps_factor,  # 20
        }.get(win_class, a / fps_factor)
        (y0, recoil_control) = {
            'CrossFire': (b / 2.719 * (client_ratio / (4/3)) / fps_factor, 2),  # 32
            'Valve001': (b * 1.667 / fps_factor, 2),  # 2.5 + mouse acceleration
            'LaunchCombatUWindowsClient': (b * 1.319 / fps_factor, 2),  # 10.0
            'LaunchUnrealUWindowsClient': (b / 2.557 / fps_factor, 5),  # 20
        }.get(win_class, (b / fps_factor, 2))

        move_rx, x0 = track_opt(move_rx, a, x0)
        move_ry, y0 = track_opt(move_ry, b, y0)

        if arr[12] == 1 or arr[14]:
            y0 += (recoil_control * shoot_times[0])  # 简易压枪

        sp_mouse_xy(int(round(x0)), int(round(y0)))

    # 不分敌友射击
    if win_class != 'CrossFire':
        if (go_fire or move_range < ranges) and arr[11]:
            if (time() * 1000 - up_time[0]) > rate:
                if not GetAsyncKeyState(VK_LBUTTON):
                    sp_mouse_down()
                    press_time[0] = int(time() * 1000)
                    if (time() * 1000 - up_time[0]) <= 175:
                        shoot_times[0] += 1
                        if shoot_times[0] > 10:
                            shoot_times[0] = 10

        if GetAsyncKeyState(VK_LBUTTON):
            if (time() * 1000 - press_time[0]) > 30.6 or not arr[11]:
                sp_mouse_up()
                up_time[0] = int(time() * 1000)

    if (time() * 1000 - up_time[0]) > 175:
        shoot_times[0] = 0

    if enhanced_holdback[1]:
        win32gui.SystemParametersInfo(SPI_SETMOUSE, enhanced_holdback, 0)
    if mouse_speed != 10:
        win32gui.SystemParametersInfo(SPI_SETMOUSESPEED, mouse_speed, 0)

    return move_rx, move_ry


# 追踪优化
def track_opt(record_list, range_m, move):
    if len(record_list):
        if abs(median(record_list) - range_m) <= 15 and range_m <= 80:
            record_list.append(range_m)
        else:
            record_list.clear()
        if len(record_list) > show_fps[0] / 10 and arr[4]:
            move *= (show_fps[0] // 20)
            record_list.clear()
    else:
        record_list.append(range_m)

    return record_list, move


# 转变状态
def check_status(exit0, mouse):
    if GetAsyncKeyState(VK_END):  # End
        exit0 = True
    if GetAsyncKeyState(0x31):  # 1
        mouse = 1
        arr[15] = 1
    if GetAsyncKeyState(0x32):  # 2
        mouse = 2
        arr[15] = 2
    if GetAsyncKeyState(0x33) or GetAsyncKeyState(0x34):  # 3,4
        mouse = 0
        arr[15] = 0
    if GetAsyncKeyState(0x46):  # F
        arr[17] = 1
    if GetAsyncKeyState(0x4A):  # J
        arr[17] = 0
    if GetAsyncKeyState(0x50):  # P
        close()
        restart()

    return exit0, mouse


# 多线程展示效果
def show_frames(output_pipe, array):
    set_dpi()
    cv2.namedWindow('Show frame', cv2.WINDOW_KEEPRATIO)
    cv2.moveWindow('Show frame', 0, 0)
    cv2.destroyAllWindows()
    font = cv2.FONT_HERSHEY_SIMPLEX  # 效果展示字体
    fire_target_show = ['middle', 'head', 'chest']
    while True:
        show_img = output_pipe.recv()
        show_color = {
            0: (127, 127, 127),
            1: (255, 255, 0),
            2: (0, 255, 0)
        }.get(array[4])
        try:
            img_ex = np.zeros((1, 1, 3), np.uint8)
            show_str0 = str('{:03.0f}'.format(array[3]))
            show_str1 = 'Detected ' + str('{:02.0f}'.format(array[11])) + ' targets'
            show_str2 = 'Aiming at ' + fire_target_show[array[12]] + ' position'
            show_str3 = 'Fire rate is at ' + str('{:02.0f}'.format((10000 / (array[13] + 306)))) + ' RPS'
            show_str4 = 'Please enjoy coding ^_^' if array[17] else 'Please enjoy coding @_@'
            if show_img.any():
                show_img = cv2.resize(show_img, (array[5], array[5]))
                img_ex = cv2.resize(img_ex, (array[5], int(array[5] / 2)))
                cv2.putText(show_img, show_str0, (int(array[5] / 25), int(array[5] / 12)), font, array[5] / 600, (127, 255, 0), 2, cv2.LINE_AA)
                cv2.putText(img_ex, show_str1, (10, int(array[5] / 9)), font, array[5] / 450, show_color, 1, cv2.LINE_AA)
                cv2.putText(img_ex, show_str2, (10, int(array[5] / 9) * 2), font, array[5] / 450, show_color, 1, cv2.LINE_AA)
                cv2.putText(img_ex, show_str3, (10, int(array[5] / 9) * 3), font, array[5] / 450, show_color, 1, cv2.LINE_AA)
                cv2.putText(img_ex, show_str4, (10, int(array[5] / 9) * 4), font, array[5] / 450, show_color, 1, cv2.LINE_AA)
                show_image = cv2.vconcat([show_img, img_ex])
                cv2.imshow('Show frame', show_image)
                cv2.waitKey(1)
        except (AttributeError, cv2.error):
            cv2.destroyAllWindows()


# 分析进程
def detection(que, array, frame_in):
    Analysis = FrameDetection(array[0])
    array[1] = 1
    while True:
        if not que.empty():
            try:
                frame = que.get_nowait()
                que.task_done()
                array[1] = 2
                if array[10]:
                    array[11], array[7], array[8], array[9], array[12], array[14], array[16], frame = Analysis.detect(frame)
                frame_in.send(frame)
            except (queue.Empty, TypeError):
                continue
        array[1] = 1


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
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # 滑稽
    Conan = -1
    while not (2 >= Conan >= 0):
        user_choice = input('柯南能在本程序作者有生之年完结吗?(1:能, 2:能, 0:不能): ')
        try:
            Conan = int(user_choice)
        except ValueError:
            print('呵呵...请重新输入')
        else:
            if not (2 >= Conan >= 0):
                print('请在给定范围选择')

    # 初始化变量以及提升进程优先级
    if platform == 'win32':
        pid = GetCurrentProcessId()
        handle = OpenProcess(PROCESS_ALL_ACCESS, True, pid)
        SetPriorityClass(handle, ABOVE_NORMAL_PRIORITY_CLASS)
    else:
        os.nice(1)
    queue = JoinableQueue()  # 初始化队列
    frame_output, frame_input = Pipe(False)  # 初始化管道(receiving,sending)
    press_time, up_time, show_fps = [0], [0], [1]
    process_time = deque()
    exit_program = False
    test_win = [False]
    move_record_x = []
    move_record_y = []
    shoot_times = [0]

    # 如果文件不存在则退出
    check_file('yolov4-tiny')

    # 分享数据以及展示新进程
    arr = Array('i', range(21))
    '''
    0  窗口句柄
    1  分析进程状态
    2  缺省
    3  截图FPS整数值
    4  控制鼠标
    5  左侧距离除数
    6  使用GPU/CPU(1/0)
    7  鼠标移动x
    8  鼠标移动y
    9  鼠标开火r
    10 柯南
    11 敌人数量
    12 瞄准位置
    13 射击速度
    14 敌人近否
    15 所持武器
    16 指向身体
    17 自瞄自火
    '''

    show_proc = Process(target=show_frames, args=(frame_output, arr,))
    show_proc.start()
    arr[1] = 0  # 分析进程状态
    arr[2] = 0  # 缺省
    arr[3] = 0  # FPS值
    arr[4] = 0  # 控制鼠标
    arr[7] = 0  # 鼠标移动x
    arr[8] = 0  # 鼠标移动r
    arr[9] = 0  # 鼠标开火r
    arr[10] = Conan  # 柯南
    arr[11] = 0  # 敌人数量
    arr[12] = 0  # 瞄准位置(0中1头2胸)
    arr[13] = 944  # 射击速度
    arr[14] = 0  # 敌人近否
    arr[15] = 0  # 所持武器(0无1主2副)
    arr[16] = 0  # 指向身体
    arr[17] = 1  # 自瞄/自火
    detect_proc = Process(target=detection, args=(queue, arr, frame_input,))

    # 寻找读取游戏窗口类型并确认截取位置
    window_class_name, window_hwnd_name, test_win[0] = get_window_info()
    arr[0] = window_hwnd_name

    # 等待游戏画面完整出现(拥有大于0的长宽)
    window_ready = 0
    while not window_ready:
        sleep(1)
        win_client_rect = win32gui.GetClientRect(window_hwnd_name)
        if win_client_rect[2] - win_client_rect[0] > 0 and win_client_rect[3] - win_client_rect[1] > 0:
            window_ready = 1
    client_ratio = (win_client_rect[2] - win_client_rect[0]) / (win_client_rect[3] - win_client_rect[1])

    # 初始化截图类
    win_cap = WindowCapture(window_class_name, window_hwnd_name)

    # 开始分析进程
    detect_proc.start()

    # 等待分析类初始化
    while not arr[1]:
        sleep(4)

    # 清空命令指示符面板
    clear()

    ini_sct_time = 0  # 初始化计时
    small_float = np.finfo(np.float64).eps  # 初始化一个尽可能小却小得不过分的数

    while True:
        screenshot = win_cap.grab_screenshot()

        try:
            screenshot.any()
            arr[5] = (150 if win_cap.get_window_left() - 10 < 150 else win_cap.get_window_left() - 10)
        except (AttributeError, pywintypes.error):
            break

        queue.put_nowait(screenshot)
        queue.join()

        exit_program, arr[4] = check_status(exit_program, arr[4])

        if exit_program:
            break

        if win32gui.GetForegroundWindow() == window_hwnd_name and not test_win[0]:
            if arr[4]:  # 是否需要控制鼠标
                if arr[15] == 1:  # 主武器
                    arr[13] = (944 if arr[14] or arr[12] != 1 else 1694)
                elif arr[15] == 2:  # 副武器
                    arr[13] = (694 if arr[14] or arr[12] != 1 else 944)
                move_record_x, move_record_y = control_mouse(arr[7], arr[8], show_fps[0], arr[9], arr[13] / 10, arr[16], window_class_name, move_record_x, move_record_y)

        time_used = time() - ini_sct_time
        ini_sct_time = time()
        current_fps = 1 / (time_used + small_float)
        process_time.append(current_fps)
        if len(process_time) > 119:
            process_time.popleft()

        show_fps[0] = median(process_time)  # 计算fps
        arr[3] = int(show_fps[0])

    close()
    exit(0)
