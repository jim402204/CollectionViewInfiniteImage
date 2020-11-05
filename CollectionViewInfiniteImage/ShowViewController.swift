//
//  ShowViewController.swift
//  HomeWork
//
//  Created by Jim on 2020/2/17.
//  Copyright © 2020 Jim. All rights reserved.
//

import UIKit

class ShowViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let collectionViewReuseID = String(describing: CollectionViewCell.self)
    var models = [Model]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configtrueCollectionView()
        callAPI()
    }

}

extension ShowViewController {
    
    func configtrueCollectionView() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: collectionViewReuseID, bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: collectionViewReuseID)
        
        //storyboard 估計值要打開 寬度約束優先權設定變低
//        codeLayout()
    }
    
    func codeLayout() {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.estimatedItemSize = .zero

        let length = floor((UIScreen.main.bounds.width - 3) / 4)
        layout.itemSize = CGSize(width: length, height: length)
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
    }
    
    func callAPI() {
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let decoder = JSONDecoder()
        
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/photos") else { return }
        
        session.dataTask(with: url) { (data, urlResponse, error) in
            
            guard error == nil else { return print("error: \(String(describing: error))") }
            guard let data = data else { return }
//            print("data: \(String.init(bytes: data, encoding: .utf8))")
            
            guard let model = try? decoder.decode([Model].self, from: data) else { return assertionFailure("decoder fail") }
//            print("model: \(model)")    //photos?albumId=1 共50子筆
            
            self.models = model
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }.resume()
        
    }
    
}


extension ShowViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewReuseID, for: indexPath) as! CollectionViewCell
        let row = indexPath.row
        
        if models.count > 0 {
            
            item.idLabel.text = "\(models[row].id)"
            item.titleLabel.text = models[row].title
            let urlString = models[indexPath.row].url
            
//            if let url = URL(string: urlString) {
//                FileManagerObject.share.fetchTmpFileImage(url: url) { image in
//                    item.showImageView.image = image
//                }
//            }
            
            //1.先撈先前的              //3.cell reused 放掉image = nil
            item.showImageView.image = UIImageView.imagePool[row]
            //2.沒有才打api   省流量
            if let url = URL(string: urlString), item.showImageView.image == nil {
                item.showImageView.showImage(index: row, url: url)
            }
            //會蓋掉 表示 沒有判斷image == nil 又繼續打api
            
            
            limitTaskCount()
            
            limitModelCount()
        }
        
        return item
    }
    
    /// 限制當前能執行thread的最大數量 避免滑動後task滯後情況   選擇array 先進後出 將來不及執行的task cancel
    func limitTaskCount() {
        
        DispatchQueue.global().sync { //一直觸發 選擇同步 避免多次remove 造成同意記憶體多次釋放 閃退
            print("count \(UIImageView.taskPool.count)")
            
            if UIImageView.taskPool.count > 100 {
                
                let relaseSequence = (0...29)
                
                let needCancelArray = UIImageView.taskPool[relaseSequence]
                needCancelArray.forEach { $0.cancel() }
                
                if UIImageView.taskPool.count > relaseSequence.count {
                    UIImageView.taskPool.removeSubrange(relaseSequence)
                }
            }
        }
    }
    
    /// 限制儲存的model數量 避免app記憶體炸了
    func limitModelCount() {
        
        DispatchQueue.global().sync {
            
            if UIImageView.imagePool.count > 200 {
                let filter = UIImageView.imagePool.keys.sorted()
                //            print("filter: \(filter)")
                
                let limitNumber = 100
                let removeCounts = UIImageView.imagePool.count - (UIImageView.imagePool.count - limitNumber)
                let removeArray = filter[0...(removeCounts - 1)]
                //            print("removeArray: \(removeArray)")
                
                removeArray.forEach{ UIImageView.imagePool[$0] = nil }
            }
        }
    }
    
    
}

