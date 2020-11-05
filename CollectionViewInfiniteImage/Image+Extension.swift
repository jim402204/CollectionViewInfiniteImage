//
//  Image+Extension.swift
//  HomeWork
//
//  Created by Jim on 2020/2/18.
//  Copyright © 2020 Jim. All rights reserved.
//

import Foundation

import UIKit

extension UIImageView {
    
    static var mapping = [Int : UIImage]()
    
    func showImage(index: Int, url:URL) {
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: url) { (data, response , error) in
            
            if let error = error {
                return print("Down fail:  \(error)")
            }
            
            guard let data = data else { return assertionFailure("data is nil") }
            
            FileManagerObject.share.dateWriteToFileWithTmp(data: data, url: url)
            
            DispatchQueue.main.async {
//                UIImageView.mapping[index] = UIImage(data: data)
                
                if self.image == nil {  //4. self.image 是reused的 為nil 表示現在是第一打api
//                    self.image = UIImageView.mapping[index]
                    FileManagerObject.share.fetchTmpFileImage(url: url) { [weak self] image in
                        self?.image = image
                    }
                }
            }
        }
        
        task.resume()
    }
    
}
