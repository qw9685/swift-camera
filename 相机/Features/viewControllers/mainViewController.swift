//
//  mainViewController.swift
//  相机
//
//  Created by mac on 2019/12/2.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import SnapKit
import Photos

class mainViewController: UIViewController {
    
    var camera:cameraManager!
    
    private var config:cameraConfig! = {
        let config = cameraConfig.init()
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let videoPath = "\(paths[0])/cache.mp4"
        
        config.videoPath = videoPath
        config.videoSize = CGSize(width: 720, height: 1280)
        config.videoBitRate = 20*1024*1024
        config.videoFrameRate = 24
        config.audioBitRate = 64000
        config.audioSamplerate = 44100
        config.audioChannels = 2
        config.transfrom = .identity
        return config
    }()
    
    lazy var scrollPageView : scrollViewPageView = {
        var scrollView = scrollViewPageView.init(views: self.subViews as! Array<UIView>)
        return scrollView
    }();
    
    lazy var subViews : NSArray = {
        var arrays = NSMutableArray.init()
        for i in 0..<2{
            let view = UIView.init();
            arrays.add(view)
        }
        return arrays;
    }();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        
        setCameraManager()
        setUpViews()
                
        //注册手机屏幕方向切换的通知
        NotificationCenter.default.addObserver(self, selector: #selector(receivedRotation),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
        
        //拍照
        scrollPageView.view_type.didSelectRecordBlock = {()
            
            if self.scrollPageView.view_type.index == 0 {
                //保存图片
                self.camera.takePhoto { (image) in
                    if image != nil{
                        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.saveImage(image:didFinishSavingWithError:contextInfo:)), nil)                    }
                }
            }
            
            if self.scrollPageView.view_type.index == 1 {
                self.camera.isCapturing == true ? self.camera.stopRecord() : self.camera.startRecord()
                self.scrollPageView.view_type.button_play.setBackgroundImage(UIImage.init(named: self.camera.isCapturing == true ? "ic_button" : "ic_shutter"), for: .normal)
                //录制的时间
                self.camera.timerBlock = {(recordTime:Float) ->() in
                    self.scrollPageView.view_type.label_title.text = String(format:"%.1f",recordTime)
                }
                //录制完成 保存相册
                self.camera.recordFinishBlock = {
                    self.saveVideo(videoPath: self.config.videoPath)
                }
            }
        };
        
        //闪光灯
        scrollPageView.gesFlashClickBlock = {()
            self.camera.setFocusMode()
            if self.camera.getFocusMode() == true {
                self.scrollPageView.imageView_flash.image = UIImage.init(named: "ic_iight-open")
            }else{
                self.scrollPageView.imageView_flash.image = UIImage.init(named: "ic_iight-close")
            }
        }
        //前后置
        scrollPageView.view_type.didSelectcameraSwitchBlock = {()
            self.camera.switchCameraPosition {}
        }
        //聚焦
        scrollPageView.gesClickBlock = {(point:CGPoint) ->() in
            self.camera.setFocusCursorWithPoint(point: point)
        }
        //捏合
        scrollPageView.gesPinchClickBlock = {(scale:CGFloat) ->() in            
            self.camera.setVideoScaleAndCropFactor(scale: scale)
        }
        //相册
        scrollPageView.view_type.didSelectCircleBlock = {            
            self.navigationController?.pushViewController(albumViewController.init(), animated: true)
        }
    }
    
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        if error != nil{
            print("保存失败")
        }else{
            print("保存成功")
            self.scrollPageView.view_type.button_circle.setImage(image, for: .normal)
        }
    }

    private func saveVideo(videoPath:String){
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(string: videoPath)!)
        }) { (boo, error) in
            
            if boo{
                DispatchQueue.main.async {
                    //生成视频截图
                    let avAsset = AVAsset(url: URL(fileURLWithPath: self.config.videoPath))
                    let image = albumManager.getVideoCurrentImage(second: 1, asset: avAsset)
                    self.scrollPageView.view_type.button_circle.setImage(image, for: .normal)
                }
                print("保存成功")
            }else{
                print("保存失败")
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollPageView.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.edges.equalTo(self.view)
        }
    }
    
    //设置输出资源方向
    @objc func receivedRotation(){
        
        if self.camera.isCapturing == true {
            return;
        }
        //获得当前运行中设备信息
        let device = UIDevice.current
        config.transfrom = CGAffineTransform(rotationAngle: 0)
        config.orientation = .portrait
        //遍历设备屏幕方向
        switch device.orientation{
        case.portrait:
            print("设备屏幕位于垂直方面，Home键位于下方")
        case.portraitUpsideDown:
            print("设备屏幕位于垂直方面，Home键位于上方")
        case.landscapeLeft:
            print("设备屏幕位于水平方面，Home键位于右侧")
            config.transfrom = CGAffineTransform(rotationAngle: -CGFloat(Double.pi/2))
            config.orientation = .landscapeRight
            
        case.landscapeRight:
            print("设备屏幕位于水平方面，Home键位于左侧")
            config.transfrom = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
            config.orientation = .landscapeLeft
            
        case.faceUp:
            print("设备处于平放，Home键朝上")
        case.faceDown:
            print("设备处于平放，Home键朝下")
        case.unknown:
            print("设备屏幕方向未知")
        default: break
            
        }
    }
    
    func setUpViews(){
        view.addSubview(scrollPageView)
    }
    
    func setCameraManager(){
        self.camera = cameraManager.init(previewView: view, config: config)
        self.camera .sessionStart()
    }
    

}
