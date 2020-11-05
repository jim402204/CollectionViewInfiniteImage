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
            
            if let url = URL(string: urlString) {
                FileManagerObject.share.fetchTmpFileImage(url: url) { image in
                    item.showImageView.image = image
                }
            }
            
            //1.先撈先前的              //3.cell reused 放掉image = nil
//            item.showImageView.image = UIImageView.mapping[row]
            //2.沒有才打api   省流量
            if let url = URL(string: urlString), item.showImageView.image == nil {
                item.showImageView.showImage(index: row, url: url)
            }
            //會蓋掉 表示 沒有判斷image == nil 又繼續打api
        }
        
        return item
    }
    
}

