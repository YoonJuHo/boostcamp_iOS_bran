//
//  Photo.swift
//  Photorama
//
//  Created by JU HO YOON on 2017. 7. 31..
//  Copyright © 2017년 YJH Studio. All rights reserved.
//

import UIKit

class Photo {
    
    let title: String
    let remoteURL: URL
    let photoID: String
    let dateTaken: Date
    var image: UIImage?
    
    init(title: String, remoteURL: URL, photoID: String, dateTaken: Date) {
        self.title = title
        self.remoteURL = remoteURL
        self.photoID = photoID
        self.dateTaken = dateTaken
    }
}

extension Photo: Equatable {
    
    public static func ==(lhs: Photo, rhs: Photo) -> Bool {
        return lhs.photoID == rhs.photoID
    }
}
