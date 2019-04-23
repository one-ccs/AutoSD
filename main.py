#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  main.py
#  
#  Copyright 2019 one-ccs <one-ccs@foxmail.com>
#  


import os
import time
import msvcrt
import sys

def real_time():
    import time
    real_date = time.strftime('%Y-%m-%d', time.localtime())
    real_week = time.strftime('%w', time.localtime())
    real_time = time.strftime('%H:%M:%S', time.localtime())
    real_day = time.strftime('%j', time.localtime())
    real_weeks = ('星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六')
    time_display = '     ' + real_date + '  ' + real_weeks[int(real_week)] \
    + '  ' + real_time + '\n\n' + '             今年第 ' + real_day + ' 天\r'
    return time_display

def tip_display():
    view = "=======================================\n" \
    + "~                                     ~\n" \
    + "~         请选择一个操作并回车        ~\n" \
    + "~                                     ~\n" \
    + "---------------------------------------\n"
    return view

def menu_display():
    view = "\n1、定时--关机\n\n" \
    + "2、定时--重启\n\n" \
    + "3、定时--注销\n\n" \
    + "4、清除--任务\n\n" \
    + "5、刷新\n\n" \
    + "6、退出\n"
    return view

def rev_nums(a):
    a = list(range(int(a), -1, -1))
    return a

def my_shutdown(command):
    import time
    import os
    import sys
    
    if command != 3:
        time_down = input("请输入定时时间:")
    
    if command == 0:
        cmd = '关机'
        command = 'shutdown /s /t ' + str(time_down)
    elif command == 1:
        cmd = '重启'
        command = 'shutdown /r /t ' + str(time_down)
    elif command == 2:
        cmd = '注销'
        command = 'shutdown /l /f'
    elif command == 3:
        os.system("shutdown /a")
        input("已清除计划任务，按任意键继续...")
        os.system("cls")
        return 0;
    
    a = 0
    for i in rev_nums(time_down):
        if msvcrt.kbhit():
            msvcrt.getch()
            return 0
            
        sys.stdout.write("\r%ds 后%s，按任意键取消..." %(i, cmd))
        if int(i) == 30 and command != 'shutdown /l /f':
            a += 1
            os.system(command)
        elif int(i) < 30 and a == 0:
            os.system(command)
            a += 1
        time.sleep(1)

os.system('title AutoSd by one-ccs')
os.system('color 0a')
os.system('mode con: cols=40 lines=26')

while 1:
    print(tip_display())
    print(real_time())
    print(menu_display())
    
    choose = input("请输入数字：")
    if int(choose) == 1:
        my_shutdown(0)
        input("\n按任意键继续...")
        os.system("cls")
    elif int(choose) == 2:
        my_shutdown(1)
        input("\n按任意键继续...")
        os.system("cls")
    elif int(choose) == 3:
        my_shutdown(2)
        input("\n按任意键继续...")
        os.system("cls")
    elif int(choose) == 4:
        my_shutdown(3)
        continue
    elif int(choose) == 5:
        os.system("cls")
        continue
    elif int(choose) == 6:
        sys.exit(0)
    else:
        print("Error!")
        input("按任意键继续")
        os.system("cls")
        continue
