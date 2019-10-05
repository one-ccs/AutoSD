#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  main.py
#
#  Copyright 2019 one-ccs <one-ccs@foxmail.com>

from AutoSD_Function import *

global active

def main():
    sys_init()

    active = True

    while active:
        show_tip()
        show_time()
        show_menu()
        get_choice(get_integer())

    return 0

if __name__ == '__main__':
    main()
