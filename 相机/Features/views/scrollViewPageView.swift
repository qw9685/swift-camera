//
//  scrollViewPageView.swift
//  相机
//
//  Created by mac on 2019/12/2.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit


class scrollViewPageView: UIView,UIScrollViewDelegate{
    
    lazy var imageView_focus : UIImageView = {
        var imageView = UIImageView.init(image: UIImage.init(named: "对焦"))
        return imageView
    }();
    lazy var imageView_flash : UIImageView = {
        var imageView = UIImageView.init(frame: CGRect(x: 20, y: 20, width: 50, height: 50))
        imageView.isUserInteractionEnabled = true
        let ges = UITapGestureRecognizer.init(target: self, action: #selector(flashClick))
        imageView.addGestureRecognizer(ges)
        return imageView
    }();
    lazy var scrollView_page : UIScrollView = {
        var scrollView = UIScrollView.init()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true;
        scrollView.bounces = false//取消弹性
        scrollView.delegate = self
        let ges = UITapGestureRecognizer.init(target: self, action: #selector(gesClick(ges:)))
        scrollView.addGestureRecognizer(ges)
        
        let ges_double = UIPinchGestureRecognizer.init(target: self, action: #selector(gesPinchClick(ges:)))
        ges_double.delaysTouchesBegan = true;
        ges.require(toFail: ges_double)
        scrollView.addGestureRecognizer(ges_double)
        
        return scrollView
    }();
    
    lazy var view_type : scrollTypeView = {
        var view = scrollTypeView.init()
        
        view.didSelectItemBlock = {(index:Int) ->() in
            switch index {
            case 0: self.scrollView_page.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            case 1: self.scrollView_page.setContentOffset(CGPoint(x: kScreenWidth, y: 0), animated: false)
            case 2: self.scrollView_page.setContentOffset(CGPoint(x: 2*kScreenWidth, y: 0), animated: false)
                
            default: break
            }
        }
        return view
    }();
    
    //点击屏幕
    var gesClickBlock: ((_ point:CGPoint) -> Void)?
    //捏合屏幕
    var gesPinchClickBlock: ((_ scale:CGFloat) -> Void)?
    //闪光灯
    var gesFlashClickBlock: (() -> Void)?

    var views:Array<UIView>!
    
    convenience init(views:Array<UIView>) {
        self.init()
        
        self.views = views
        
        addSubview(scrollView_page)
        addSubview(view_type)
        addSubview(imageView_flash)
        scrollView_page.addSubview(imageView_focus)
        imageView_flash.image = UIImage.init(named: "ic_iight-open")

        imageView_focus.isHidden = true
        view_type.setIndex(index: 0)
        
        let contentSize_width = CGFloat(views.count) * kScreenWidth
        scrollView_page.contentSize = CGSize(width: contentSize_width, height: kScreenHeight)
        
        for subView in views {
            scrollView_page.addSubview(subView)
        }
    }
    @objc func flashClick(){
        if gesFlashClickBlock != nil{
            gesFlashClickBlock!();
        }
    }
    
    @objc func gesClick(ges:UITapGestureRecognizer){
        
        let point = ges.location(in: scrollView_page)
        imageView_focus.bounds = CGRect(x: 0, y: 0, width: 70, height: 70)
        imageView_focus.center = point
        imageView_focus.isHidden = false
        imageView_focus.image = UIImage.init(named: "对焦")

        UIView.animate(withDuration: 0.3, animations: {
            self.imageView_focus.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
        }) { (finish) in
            self.imageView_focus.isHidden = true
            if self.gesClickBlock != nil{
                self.gesClickBlock!(point)
            }
        }
    }
    @objc func gesPinchClick(ges:UIPinchGestureRecognizer){
        
        let scale = ges.scale;
        ges.scale = max(scale, 1.0)
        
        if scale < 1.0 || scale > 3.0{
            return;
        }
        
        print("捏合：\(scale)")
        if self.gesPinchClickBlock != nil {
            self.gesPinchClickBlock!(scale);
        }
    }
    
    //布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView_page.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.edges.equalTo(self)
        }
        
        view_type.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.right.left.bottom.equalTo(self)
            ConstraintMaker.height.equalTo(150)
        }
        
        for (index,subView) in views.enumerated() {
            subView.snp.makeConstraints { (ConstraintMaker) in
                ConstraintMaker.width.top.height.equalTo(self)
                ConstraintMaker.left.equalTo(CGFloat(index)*kScreenWidth)
            }
        }
    }
    
    //UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index:Int = Int(scrollView.contentOffset.x/kScreenWidth);
        view_type.setIndex(index: index)
    }
    //边界不可滑动
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
        if scrollView.contentOffset.x < 0 {
            scrollView.contentOffset.x = 0;
        }
        if scrollView.contentOffset.x > kScreenWidth*2 {
            scrollView.contentOffset.x = kScreenWidth*2;
        }
    }
}
