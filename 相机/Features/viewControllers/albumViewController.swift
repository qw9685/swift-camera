//
//  albumViewController.swift
//  相机
//
//  Created by cc on 2019/12/11.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import UIKit
import Photos

class albumCell : UICollectionViewCell {
    
    lazy var button_back:UIButton = {
        let button = UIButton.init(frame: self.bounds)
        return button
    }();
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(button_back)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class albumViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:albumCell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as! albumCell
        
        let model:albumModel = models[indexPath.item]
        
        albumManager.requestImageSource(asset: model.asset!) { (data) in
            let image = UIImage.init(data: data)
            cell.button_back.setBackgroundImage(image, for: .normal)
        }
        
        
        return cell
    }
    
    var models:Array<albumModel> = []
    
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: kScreenWidth/3, height: kScreenWidth/3)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        
        let collectioView = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: layout)
        collectioView.delegate = self
        collectioView.dataSource = self
        collectioView.register(albumCell.self, forCellWithReuseIdentifier: "albumCell")
        return collectioView;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(collectionView)
        
        if albumManager.getAlbumAuthorizationStatus() == false {
            albumManager.requestAuthorization { (isAuthorization) in
                if isAuthorization == true {
                    self.getResource()
                    self.collectionView.reloadData()
                }
            }
            return
        }
        self.getResource()
        self.collectionView.reloadData()
    }
    
    func getResource(){
        
        let assets: Array<PHAsset> = albumManager.loadPhotoFromAlbum()
        for asset in assets {
            let model = albumModel.init()
            model.asset = asset
            models.append(model)
        }
    }
}
