import os
import time

os.system("title 自动关机程序 by one-ccs")
os.system("color 0a")
os.system("mode con: cols=40 lines=26")

date = time.strftime('%F %A %T', time.localtime(time.time()))
days = time.strftime('%j', time.localtime(time.time()))
real_time = '     ' + date + '\n\n             今年第 ' + days + '天'

print('''========================================
~                                      ~
~     请选择要进行的操作，然后回车     ~
~                                      ~
----------------------------------------''')
print(real_time, '\n')
print('''1、定时--关机\n
2、定时--重新启动\n
3、定时--注销\n
4、清除--计划任务\n
5、刷新\n
6、退出\n''')
input('按回车键继续...')
