

![](https://github.com/KSDeng/My-Calendar2/blob/master/pic/initUI.JPG?raw=true)

![](https://github.com/KSDeng/My-Calendar2/blob/master/pic/addTask.JPG?raw=true)

![](https://github.com/KSDeng/My-Calendar2/blob/master/pic/map.JPG?raw=true)



![](https://github.com/KSDeng/My-Calendar2/blob/master/pic/noti_present.JPG?raw=true)

# My Calendar

At first, I intended to use the Firebase backend, so I named the project MyCalendar-firebase. Later, however, I faced some problems involving local storage and cloud storage synchronization, and it was kind of complicated and the time was tight, so I had to give up. Therefore, the current implementation has nothing to do with Firebase, just ignore the project name!. I'll have a try to use CloudKit in the future, after all, it's not blocked in China. (



## Features

* UI design idea: mimic Google Calendar.
* Dynamic loading of statutory holidays through holiday API.
* Add, edit and delete all-day events, non-all-day events, and multi day events, including date rationality checks.
* Search, select and display locations based on MapKit
* Local notification, custom notification settings.
* Invitations
* Persistence based on CoreData



# 我的日历

一开始打算用上firebase后端，因此项目命名为MyCalendar-firebase，后来发现涉及到本地存储和云存储同步的问题，比较复杂，加上时间紧迫，只好作罢。因此现在的实现跟firebase没半毛钱关系，以后有机会试试CloudKit吧，毕竟那个没被墙 (

##  功能

* UI界面设计思路：仿照Google Calendar
* 通过节假日API动态加载法定节假日、调休日

* 全天事件、非全天事件、多天事件的添加、编辑和删除，包括日期合理性的检查
* 基于MapKit搜索并选择地点、地点的展示
* 事件通知(Local Notification)的设置、通知时间的自定义
* 添加邀请对象
* 基于CoreData的持久化









