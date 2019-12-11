//
//  cameraManager+privateMethod.swift
//  相机
//
//  Created by mac on 2019/12/4.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import AVFoundation

extension cameraManager{
    
     //MARK: -配置session
    func configSession() ->AVCaptureSession{
        
        let session = AVCaptureSession.init()

         //添加后置摄像头的输出
         if session.canAddInput(self.cameraInput!) {
             session.addInput(self.cameraInput!)
         }
         //添加后置麦克风的输出
         if session.canAddInput(self.audioMicInput!) {
             session.addInput(self.audioMicInput!)
         }
         //添加视频输出
         if session.canAddOutput(self.videoOutput!) {
             session.addOutput(self.videoOutput!)
         }
         //添加音频输出
         if session.canAddOutput(self.audioOutput!) {
             session.addOutput(self.audioOutput!)
         }
         //添加图像输出
         if session.canAddOutput(self.imageOutput!) {
             session.addOutput(self.imageOutput!)
         }
        //分辨率
        if session.canSetSessionPreset(.hd1280x720) {
            session.sessionPreset = .hd1280x720
        }
        return session
     }
     
     //MARK: -获取设备连接
    func getDeviceConnect(mediaType:AVMediaType,outPut:AVCaptureOutput) -> AVCaptureConnection {
         return outPut.connection(with: mediaType)!
     }
    //MARK: -重置连接设备
    func setDeviceConnection(mediaType:AVMediaType,outPut:AVCaptureOutput,device:AVCaptureDevice) -> AVCaptureConnection{
        // 重新获取连接并设置视频的方向、是否镜像
        let connection = getDeviceConnect(mediaType: mediaType, outPut: outPut)
        connection.videoOrientation = .portrait
        
        if  device.position == AVCaptureDevice.Position.front
            && self.videoConnection?.isVideoMirroringSupported == true
        {
            connection.isVideoMirrored = true;
        }
        return connection
    }
     //MARK: -设置/切换预览图层
    func setPreviewLayer(previewView:UIView,frame:CGRect) {
         if (self.previewLayer != nil) {
             self.previewLayer!.removeFromSuperlayer()
             self.previewLayer = nil;
         }
         self.previewLayer = AVCaptureVideoPreviewLayer.init(session: self.session)
         self.previewLayer!.frame = frame;
         self.previewLayer!.videoGravity = .resizeAspectFill;
         previewView.layer.addSublayer(self.previewLayer!)
     }
     
     //MARK: -获取设备输出。1:视频 2:音频 3:图片 4:二维码
    func getDeviceOutput(outPutType:Int) -> Any {
         var captureOutput:Any!
         if outPutType == 1 {
             captureOutput = AVCaptureVideoDataOutput.init()
             let captureOutput_video = (captureOutput as! AVCaptureVideoDataOutput)
             captureOutput_video.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)] as [String : Any]
             captureOutput_video.alwaysDiscardsLateVideoFrames = true
             captureOutput_video.setSampleBufferDelegate(self, queue: self.queue)
         }
         if outPutType == 2 {
             captureOutput = AVCaptureAudioDataOutput.init()
             let captureOutput_audio = (captureOutput as! AVCaptureAudioDataOutput)
             captureOutput_audio.setSampleBufferDelegate(self, queue: self.queue)
         }
         if outPutType == 3 {
             captureOutput = AVCaptureStillImageOutput.init()
             (captureOutput as! AVCaptureStillImageOutput).outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG];
         }
         if outPutType == 4 {
            captureOutput = AVCaptureMetadataOutput.init()
            (captureOutput as! AVCaptureMetadataOutput).setMetadataObjectsDelegate(self, queue: self.queue)
            //设置扫描范围
            (captureOutput as! AVCaptureMetadataOutput).rectOfInterest = CGRect(x: 02, y: 0.2, width: 0.8, height: 0.8)
         }
         return captureOutput as Any
     }
     
    //MARK: -获取摄像头/mic
    func getDeviceInput(position:AVCaptureDevice.Position,mediaType:AVMediaType) -> AVCaptureDeviceInput?{
         let device = self.getCaptureDevice(position: position,mediaType: mediaType)
         var deviceInput:AVCaptureDeviceInput? = nil
         if device != nil {
             do {
                 deviceInput = try AVCaptureDeviceInput.init(device: device!)
             } catch {
                 print(error.localizedDescription)
             }
         }else{
             return nil
         }
         return deviceInput;
     }
    func getEncodeManager(config:cameraConfig) -> encodeManager{
        let encode = encodeManager.init()
        encode.encoder(transfrom: config.transfrom, path: config.videoPath, videoSize: config.videoSize, videoFrameRate: config.videoFrameRate, videoBitRate: config.videoBitRate, audioSamplerate: config.audioSamplerate, audioBitRate: config.audioBitRate, audioChannels: config.audioChannels)
        return encode
    }
     //MARK: -获取device
    func getCaptureDevice(position:AVCaptureDevice.Position,mediaType:AVMediaType) -> AVCaptureDevice? {
         if mediaType == .video {
             let devices = AVCaptureDevice.devices(for: mediaType)
             for device in devices{
                 if device.position == position {
                     return device
                 }
             }
             return nil
         }
         if mediaType == .audio {
             return AVCaptureDevice.default(for: .audio)
         }
         return nil
     }
    
    //MARK: -获取摄像头方向
    func getCameraPosition() -> AVCaptureDevice.Position?{
        return self.cameraInput!.device.position;
    }
    
    //MARK: -获取摄像头设备
    func getCameraDevice(position:AVCaptureDevice.Position!) -> AVCaptureDevice?{
        let devices = AVCaptureDevice.devices(for: .video)
        for device in devices{
            if device.position == position {
                if device.supportsSessionPreset(self.session.sessionPreset) {
                    return device;
                }
            }
        }
        return nil;
    }
    //MARK: -改变设备属性前一定要首先调用lockForConfiguration方法加锁,调用完之后使用unlockForConfiguration方法解锁.
    func changeDevicePropertySafety(handler: @escaping (AVCaptureDevice?) -> Void) {
        let device = self.cameraInput?.device;
        do {
            try device!.lockForConfiguration()
            self.session.beginConfiguration()
            handler(device)
            device!.unlockForConfiguration()
            self.session.commitConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }
    //MARK: -Timer
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updataSecond), userInfo: nil, repeats: true)
        //调用fire()会立即启动计时器
        timer!.fire()
    }
    func stopTimer() {
        if timer != nil {
             timer!.invalidate()
             timer = nil
         }
     }
    
    // 3.定时操作
    @objc func updataSecond() {
        recordTime! += 0.1;
        if timerBlock != nil {
            timerBlock!(recordTime ?? 0)
        }
    }
}
