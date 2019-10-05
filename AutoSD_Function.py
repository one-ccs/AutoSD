#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  AutoSD_Function.py
#
#  Copyright 2019 one-ccs <one-ccs@foxmail.com>

import os
import time
import msvcrt

global active

def sys_init():
    """初始化窗口标题、色彩、大小"""

    os.system('title AutoSd by one-ccs')
    os.system('color 0a')
    os.system('mode con: cols=40 lines=26')

def show_tip():
    """显示表头"""

    view = "=======================================\n" \
    + "~                                     ~\n" \
    + "~           ☢ 自动关机程序 ☢          ~\n" \
    + "~                                     ~\n" \
    + "---------------------------------------\n"
    print(view)

def show_time():
    """格式化显示当前时间信息"""

    real_date = time.strftime('%Y-%m-%d', time.localtime())
    real_week = time.strftime('%w', time.localtime())
    real_time = time.strftime('%H:%M:%S', time.localtime())
    real_day = time.strftime('%j', time.localtime())
    real_weeks = ('星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六')
    time_display = '     ' + real_date + '  ' + real_weeks[int(real_week)] \
    + '  ' + real_time + '\n\n' + '             今年第 ' + real_day + ' 天\r'
    print(time_display)

def show_menu():
    """显示菜单"""

    view = "\n1、定时--关机\n\n" \
    + "2、定时--重启\n\n" \
    + "3、定时--注销\n\n" \
    + "4、清除--任务\n\n" \
    + "5、刷新\n\n" \
    + "6、退出\n"
    print(view)

def get_integer(info = "请输入数字："):
    """获取整型数据

    info-提示信息"""

    num = 'a'

    while (not num.isdigit()):
        num = input(info)

    return num

def my_shutdown(command):
    """执行关机指令

       command(0-关机;1-重启;2-注销;3-清除计划;other-再次输入)"""

    if command != 3:

        time_down = get_integer("请输入定时时间(s):")

    if command == 0:
        cmd = '关机'
        command = 'shutdown /s /t '
    elif command == 1:
        cmd = '重启'
        command = 'shutdown /r /t '
    elif command == 2:
        cmd = '注销'
        command = 'shutdown /l /f'
    elif command == 3:
        os.system("shutdown /a")
        input("已清除计划任务，按回车键继续...")
        os.system("cls")
        return 0

    a = 0
    for i in rev_nums(time_down):
        if msvcrt.kbhit():
            msvcrt.getch()
            return 0

        #sys.stdout.write("\r%ds 后%s，按任意键取消..." %(i, cmd))
        print("\r%ds 后%s，按任意键取消..." %(i, cmd), end = '')
        if int(i) == 30 and command != 'shutdown /l /f':
            a += 1
            command = command + "30"
            os.system(command)
        elif int(i) < 30 and a == 0:
            command = command + str(time_down)
            os.system(command)
            a += 1
        time.sleep(1)

def get_choice(choose):
    """根据获取的 choose 执行相应指令"""

    if int(choose) == 1:
        my_shutdown(0)
        input("\n按回车键继续...")
        os.system("cls")
    elif int(choose) == 2:
        my_shutdown(1)
        input("\n按回车键继续...")
        os.system("cls")
    elif int(choose) == 3:
        my_shutdown(2)
        input("\n按回车键继续...")
        os.system("cls")
    elif int(choose) == 4:
        my_shutdown(3)
        return
    elif int(choose) == 5:
        os.system("cls")
        return
    elif int(choose) == 6:
        active = False
        return
    else:
        print("Error!")
        input("按回车键继续")
        os.system("cls")
        return
    os.system('cls')

# ~ def rev_nums(final):
    # ~ """返回一个从 final 到 0 的整型数组"""
    # ~ array = list(range(int(final), -1, -1))

    # ~ return array


def main():
    return 0

if __name__ == '__main__':
    main()
