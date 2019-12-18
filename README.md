

# My Calendar

This is a small tool written in Swift 5, which is also the course assignment of Mobile Internet Technology. It can be used as a notepad for daily business. The original idea was to mimic Google Calendar, which I later found was really elaborate.

There have been several refactorings during my implementation, one of which rebuilded the entire project, so I replaced the repository. Previous commits can be seen at [My-Calendar](https://github.com/KSDeng/My-Calendar)

At first, I intended to use the Firebase backend, so I named the project MyCalendar-firebase. Later, however, I faced some problems involving local storage and cloud storage synchronization, and it was kind of complicated and the time was tight, so I had to give up. Therefore, the current implementation has nothing to do with Firebase, just ignore the project name!. I'll have a try to use CloudKit in the future, after all, it's not blocked in China. (

Thanks to [Prof. Chun Cao](https://ccao.cc/en/) for his guidance and help, and wish you a happy new year ☺ (2020).

## Features

* UI design idea: mimic Google Calendar.
* Dynamic loading of statutory holidays through holiday API.
* Add, edit and delete all-day events, non-all-day events, and multi day events, including date rationality checks.
* Search, select and display locations based on MapKit
* Local notification, custom notification settings.
* Invitations
* Persistence based on CoreData



# 我的日历

这是我自己写的一个小工具，也是《移动互联技术》这门课的课程作业，可以作为平时事务的记事本用。最初的想法是模仿Google Calendar，那玩意儿真的很精致，我比它多的一个功能就是能通过地图来选地点。

中间经过了几次重构，其中一次重建了整个项目，于是干脆把仓库也换了，之前的commit 在 [My-Calendar](https://github.com/KSDeng/My-Calendar)

一开始打算用上firebase后端，因此项目命名为MyCalendar-firebase，后来发现涉及到本地存储和云存储同步的问题，比较复杂，加上时间紧迫，只好作罢。因此现在的实现跟firebase没半毛钱关系，以后有机会试试CloudKit吧，毕竟那个没被墙 (

感谢[曹春](https://ccao.cc/en/)老师的指导和帮助，给大家拜个早年 ☺。

##  功能

* UI界面设计思路：仿照Google Calendar
* 通过节假日API动态加载法定节假日、调休日

* 全天事件、非全天事件、多天事件的添加、编辑和删除，包括日期合理性的检查
* 基于MapKit搜索并选择地点、地点的展示
* 事件通知(Local Notification)的设置、通知时间的自定义
* 添加邀请对象
* 基于CoreData的持久化



# 部分功能展示 Display of some features

**Please download *README.pdf to see the effects.***

















