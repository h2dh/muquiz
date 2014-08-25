//
//  Track.swift
//  muquiz
//
//  Created by Hannah Reuterdahl on 14/08/14.
//  Copyright (c) 2014 game. All rights reserved.
//

import Foundation

class Track {
    var title : String
    var artist : String
    var cover : UIImage
    
    init(title: String, artist:String, cover:UIImage) {
        self.title = title
        self.cover = cover
        self.artist = artist
    }
    
    func getNewTrack() {
        NSLog("Get new track")
    }
}

