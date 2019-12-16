//
//  Location.swift
//  MyCalender-firebase
//
//  Created by DKS_mac on 2019/12/13.
//  Copyright © 2019 dks. All rights reserved.
//

import Foundation

class Location {
    var title: String
    var latitude: Double
    var longitude: Double
    var addrDetail: String?
    var task: Task?
    
    init(title: String, latitude: Double, longitude: Double) {
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
    }
}
