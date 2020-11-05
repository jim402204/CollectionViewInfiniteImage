//
//  FileManager.swift
//  HomeWork
//
//  Created by 江俊瑩 on 2020/11/5.
//  Copyright © 2020 Jim. All rights reserved.
//

import UIKit

class FileManagerObject {
    
    static let share = FileManagerObject()
    
    private init(){}
    
    let tempDirectory = FileManager.default.temporaryDirectory
    
    func dateWriteToFileWithTmp(data: Data, url: URL) {
        
        let imageFileUrl = tempDirectory.appendingPathComponent(url.lastPathComponent)
        print("imageFileUrl: \(imageFileUrl)")
        
        do {
            try data.write(to: imageFileUrl)
        } catch let error {
            print("error: \(error)")
        }
    }
    
    func fetchTmpFileImage(url: URL, finishHandle: ((UIImage?)->())? = nil) {
        
        DispatchQueue.global().async {
            let imageFileUrl = self.tempDirectory.appendingPathComponent(url.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: imageFileUrl.path) {
                
                DispatchQueue.main.async {
                    finishHandle?(UIImage(contentsOfFile: imageFileUrl.path))
                }
            }
        }
    }
    
}


