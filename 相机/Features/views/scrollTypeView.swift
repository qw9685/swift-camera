//
//  scrollTypeView.swift
//  相机
//
//  Created by mac on 2019/12/2.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class scrollViewPageCell: UICollectionViewCell {
    lazy var label_title:UILabel = {
        var label = UILabel.init(frame: self.bounds);
        label.textColor = .black;
        label.font = UIFont.systemFont(ofSize: 12);
        label.textAlignment = .center
        return label;
    }();
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label_title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class scrollTypeView: UIView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    lazy var label_title:UILabel = {
        var label = UILabel.init(frame: CGRect(x: 0, y: 40, width: kScreenWidth, height: 20));
        label.textColor = .white;
        label.font = UIFont.systemFont(ofSize: 12);
        label.textAlignment = .center
        return label;
    }();
    
    lazy var collectionView:UICollectionView = {
        
        var layout = UICollectionViewFlowLayout.init();
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        var collectionView = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40), collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(scrollViewPageCell.self, forCellWithReuseIdentifier: "scrollViewPageCell")
        return collectionView
    }();
    
    lazy var button_play:UIButton = {
        var button = UIButton.init()
        button.setBackgroundImage(UIImage.init(named: "ic_shutter"), for: .normal)
        button.layer.cornerRadius = 70/2;
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(buttonPlayClick), for: .touchUpInside)
        return button;
    }()
    
    lazy var button_circle:UIButton = {
        var button = UIButton.init()
        button.backgroundColor = .red
        button.layer.cornerRadius = 70/2;
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(buttonCircleClick), for: .touchUpInside)
        return button;
    }()
    
    lazy var button_cameraSwtch:UIButton = {
        var button = UIButton.init()
        button.addTarget(self, action: #selector(buttonCameraSwtchClick), for: .touchUpInside)
        button.setBackgroundImage(UIImage.init(named: "ic_change"), for: .normal)
        return button;
    }()

    //完成回调
    var didSelectIndexBlock: (( _ index:Int) -> Void)?
    
    //点击回调
    var didSelectItemBlock: (( _ index:Int) -> Void)?
    //录像
    var didSelectRecordBlock: (() -> Void)?
    //前后置
    var didSelectcameraSwitchBlock: (() -> Void)?
    //缩略图
    var didSelectCircleBlock: (() -> Void)?
    
    var index:Int?
    
    //自定义init
    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = .clear
        addSubview(collectionView);
        addSubview(button_play)
        addSubview(button_cameraSwtch)
        addSubview(label_title)
        addSubview(button_circle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonPlayClick(){
        if self.didSelectRecordBlock != nil{
            self.didSelectRecordBlock!();
        }
    }
    @objc func buttonCircleClick(){
        if self.didSelectCircleBlock != nil{
            self.didSelectCircleBlock!();
        }
    }
    @objc func buttonCameraSwtchClick(){
        if self.didSelectcameraSwitchBlock != nil{
            self.didSelectcameraSwitchBlock!();
        }
    }
    
    func setIndex(index:Int) -> (){
        self.index = index
        label_title.isHidden = self.index != 1
        if self.didSelectIndexBlock != nil{
            self.didSelectIndexBlock!(index)
        }
        collectionView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.button_play.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.centerX.equalTo(self)
            ConstraintMaker.centerY.equalTo(self).offset(20)
            ConstraintMaker.width.height.equalTo(70)
        }
        self.button_cameraSwtch.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.right.equalTo(self).offset(-20)
            ConstraintMaker.centerY.equalTo(self.button_play)
            ConstraintMaker.height.width.equalTo(50)
         }
        self.button_circle.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.left.equalTo(self).offset(20)
            ConstraintMaker.centerY.equalTo(self.button_play)
            ConstraintMaker.height.width.equalTo(70)
         }
    }
    
    //背景透传
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return nil;
        }
        return hitView;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kScreenWidth/2, height: 40);
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath.row)")
        if didSelectItemBlock != nil {
            didSelectItemBlock!(indexPath.item)
            setIndex(index: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
       let cell:scrollViewPageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "scrollViewPageCell", for: indexPath) as! scrollViewPageCell
        
        if indexPath.item == self.index {
            cell.label_title.font = UIFont.systemFont(ofSize: 16)
            cell.label_title.textColor = .red
        }else{
            cell.label_title.font = UIFont.systemFont(ofSize: 12)
            cell.label_title.textColor = .black
        }
        
        switch indexPath.item {
        case 0: cell.label_title.text = "拍照"
        case 1: cell.label_title.text = "视频"
        default: break
        }
        return cell
    }

}
