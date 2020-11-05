//
//  Model.swift
//  HomeWork
//
//  Created by Jim on 2020/2/18.
//  Copyright © 2020 Jim. All rights reserved.
//

import Foundation

struct Model: Decodable {
    
    var id: Int
    var albumId: Int
    var title: String
    var url: String
    var thumbnailUrl: String
}
