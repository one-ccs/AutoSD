#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <windows.h>
#include <conio.h>

int main() {
start:
    system("title 自动关机程序 by one-ccs");
    system("color 0a");
    system("mode con cols=40 lines=26");
//获取系统时间
    int choose = 0;
    int RealSec, RealMin, RealHour, Real_mday, Real_mon, RealYear, Real_wday, Real_yday;
    char *wday = "nothing";
    time_t timep;
    struct tm *p;
    time (&timep);
    p=gmtime(&timep);
    RealSec = p -> tm_sec;                //秒
    RealMin = p -> tm_min;                //分
    RealHour = 8 + p -> tm_hour;          //时
    Real_mday = p -> tm_mday;             //日
    Real_mon = 1 + p -> tm_mon;           //月
    RealYear = 1900 + p -> tm_year;       //年
    Real_wday = p -> tm_wday;             //星期 – 取值区间为[0,6]，其中0代表星期天，1代表星期一，以此类推
    switch(Real_wday) {
        case 0:
            wday = "星期日";
            break;
        case 1:
            wday = "星期一";
            break;
        case 2:
            wday = "星期二";
            break;
        case 3:
            wday = "星期三";
            break;
        case 4:
            wday = "星期四";
            break;
        case 5:
            wday = "星期五";
            break;
        case 6:
            wday = "星期六";
            break;
        default:
            wday = "Error!";
    }
    Real_yday = p -> tm_yday;             //当年累计天数
//Time_End
    printf(
           "=======================================\n"
           "~                                     ~\n"
           "~    请选择要进行的操作，然后回车     ~\n"
           "~        注：定时任务不显示警告       ~\n"
           "---------------------------------------\n\n"
    );
    printf("  %d年%d月%d日  %s  %d时%d分%d秒\n\n"
           "             今年第 %d 天\n\n"
           , RealYear, Real_mon, Real_mday, wday, RealHour
           , RealMin, RealSec, Real_yday
    );
    printf(
           "1、定时--关机\n\n"
           "2、定时--重新启动\n\n"
           "3、定时--注销\n\n"
           "4、清除--计划任务\n\n"
           "5、刷新\n\n"
           "6、退出\n\n"
    );
    while(1) {
        int timekeeping = 0;
        printf("请输入任一个数字：");
        scanf("%d", &choose);
        switch(choose) {
            case 1:
                printf("请输入定时时间(s)：\r");
                scanf("%d", &timekeeping);
                while(timekeeping) {
                    if(kbhit()) {
                        getch();
                        goto start;
                    }
                    printf(
                           "%ds 后自动关机，按任意键取消...\r"
                           , timekeeping
                    );
                    Sleep(1000);
                    timekeeping--;
                }
                system("shutdown /s /f");
                system("cls");
                goto start;
                break;
            case 2:
                printf("请输入定时时间(s)：\r");
                scanf("%d", &timekeeping);
                while(timekeeping) {
                    if(kbhit()) {
                        getch();
                        goto start;
                    }
                    printf(
                           "%ds 后自动重启，按任意键取消...\r"
                           , timekeeping
                    );
                    Sleep(1000);
                    timekeeping--;
                }
                system("shutdown /r /f");
                system("cls");
                goto start;
                break;
            case 3:
                printf("请输入定时时间(s)：\r");
                scanf("%d", &timekeeping);
                while(timekeeping) {
                    if(kbhit()) {
                        getch();
                        goto start;
                    }
                    printf(
                           "%ds 后自动注销，按任意键取消...\r"
                           , timekeeping
                    );
                    Sleep(1000);
                    timekeeping--;
                }
                system("shutdown /l /f");
                system("cls");
                goto start;
                break;
            case 4:
                system("shutdown /a");
                printf("已成功清除计划任务。\n");
                system("pause");
                system("cls");
                goto start;
                break;
            case 5:
                system("cls");
                goto start;
                break;
            case 6:
                exit(0);
                break;
            default:
                printf("Error!\n");
        }
    }
    system("pause");
    return 0;
}
