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
    
    static var imagePool = [Int : UIImage]()
    
    static var taskPool = [URLSessionDataTask]()
    
    func showImage(index: Int, url:URL) {
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: url) { (data, response , error) in
            
            if let error = error {
                return print("Down fail:  \(error)")
            }
            
            guard let data = data else { return assertionFailure("data is nil") }
            
//            FileManagerObject.share.dateWriteToFileWithTmp(data: data, url: url)
            
            DispatchQueue.main.async {
                UIImageView.imagePool[index] = UIImage(data: data)
                
                if self.image == nil {  //4. self.image 是reused的 為nil 表示現在是第一打api
                    self.image = UIImageView.imagePool[index]
//                    FileManagerObject.share.fetchTmpFileImage(url: url) { [weak self] image in
//                        self?.image = image
//                    }
                }
            }
        }
        
        
        UIImageView.taskPool.append(task)
        
        task.resume()
    }
    
    /// 限制當前能執行thread的最大數量 避免滑動後task滯後情況   選擇array 先進後出 將來不及執行的task cancel
    static func limitTaskCount(maxLimit: Int = 100, relaseAmount: ClosedRange<Int> = (0...29)) {
        
        DispatchQueue.global().sync { //一直觸發 選擇同步 避免多次remove 造成同意記憶體多次釋放 閃退
//            print("count \(UIImageView.taskPool.count)")
            
            if UIImageView.taskPool.count > maxLimit {
                
                let relaseSequence = relaseAmount
                
                let needCancelArray = UIImageView.taskPool[relaseSequence]
                needCancelArray.forEach { $0.cancel() }
                
                if UIImageView.taskPool.count > relaseSequence.count {
                    UIImageView.taskPool.removeSubrange(relaseSequence)
                }
            }
        }
    }
    
    /// 限制儲存的model數量 避免app記憶體炸了
    static func limitModelCount(maxLimit: Int = 200, relaseAmount: Int = 100 ) {
        
        let limitAmount = relaseAmount
        let removeCounts = UIImageView.imagePool.count - (UIImageView.imagePool.count - limitAmount)
        
        DispatchQueue.global().async {
            
            if UIImageView.imagePool.count > maxLimit {
                let filter = UIImageView.imagePool.keys.sorted()
                //            print("filter: \(filter)")
                
                let removeArray = filter[0...(removeCounts - 1)]
                //            print("removeArray: \(removeArray)")
                DispatchQueue.global().sync {
                    removeArray.forEach{ UIImageView.imagePool[$0] = nil }
                }
            }
        }
    }
    
}
