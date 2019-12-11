//
//  cameraManager+publicMethod.swift
//  相机
//
//  Created by mac on 2019/12/4.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import AVFoundation

extension cameraManager{
        
    //MARK: -开始录制
    func startRecord(){
        if self.isCapturing == false{
            self.encode = getEncodeManager(config: self.config!)//重置编码器
            self.recordTime = 0;
            self.isCapturing = true;
            self.startTimer()
        }
    }    
    //MARK: -停止录制
    func stopRecord(){
        if self.isCapturing == true{
            self.isCapturing = false;
            self.stopTimer()
            self.encode?.finishWithCompletionHandler {
                if self.recordFinishBlock != nil{
                    self.recordFinishBlock!()
                }
            }
        }
    }
    //MARK: -拍照
    func takePhoto(handler: @escaping (UIImage?) -> Void){
        
        let imageConnection = self.setDeviceConnection(mediaType: .video, outPut: self.imageOutput!, device: self.cameraInput!.device)

        if imageConnection.isVideoOrientationSupported{
            imageConnection.videoOrientation = self.config!.orientation;
        }
        
        self.imageOutput!.captureStillImageAsynchronously(from: imageConnection, completionHandler: { (imageDataSampleBuffer, error) in
            //buffer转换
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!)
            let image = UIImage.init(data: imageData!)
            handler(image)
        });
    }
    //MARK: -session开启关闭
    func sessionStop(){
        if self.session.isRunning {
            self.session.stopRunning()
        }
    }
    func sessionStart(){
        if self.session.isRunning == false {
            self.session.startRunning()
        }
    }
    //MARK: -闪光灯
    func setFocusMode(){
        self.changeDevicePropertySafety { (device) in
            
            var mode:AVCaptureDevice.TorchMode = AVCaptureDevice.TorchMode.auto
            if device?.torchMode == AVCaptureDevice.TorchMode.off{
                mode = AVCaptureDevice.TorchMode.on
            }
            if device?.torchMode == AVCaptureDevice.TorchMode.on{
                mode = AVCaptureDevice.TorchMode.off
            }
            
            if device?.isTorchModeSupported(mode) == true{
                device?.torchMode = mode
            }
        }
    }
    func getFocusMode() -> Bool{
        let device = self.cameraInput?.device
        return device?.torchMode == AVCaptureDevice.TorchMode.off
    }
    //MARK: -切换摄像头
    func switchCameraPosition(handler: @escaping () -> Void){
        let position = getCameraPosition()
        assert(position != nil, "position == nil")
        let device = getCameraDevice(position: position)
        assert(device != nil, "device == nil")
        
        let position_current:AVCaptureDevice.Position
        
        if position == AVCaptureDevice.Position.front{
            position_current = AVCaptureDevice.Position.back
        }else{
            position_current = AVCaptureDevice.Position.front;
        }
        
        // 获取摄像头设备
        let device_current = getCameraDevice(position: position_current)
        
        changeDevicePropertySafety { (device) in
            
            let sessionPreset = self.session.sessionPreset
            
            do {
                let input = try AVCaptureDeviceInput.init(device: device_current!)
                self.session.removeInput(self.cameraInput!)
                if self.session.canAddInput(input){
                    self.session.addInput(input)
                    self.cameraInput = input;
                }
                self.session.sessionPreset = sessionPreset
                self.videoConnection = self.setDeviceConnection(mediaType: .video, outPut: self.videoOutput!, device: device_current!)
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    //MARK: -聚焦点
    func setFocusCursorWithPoint(point:CGPoint){
        changeDevicePropertySafety { (device) in
            
            let cameraPoint = self.previewLayer?.captureDevicePointConverted(fromLayerPoint: point)
            
            if device!.isFocusPointOfInterestSupported {
                device!.focusPointOfInterest = cameraPoint!
                device!.focusMode = AVCaptureDevice.FocusMode.autoFocus
            }
            if device!.isExposurePointOfInterestSupported {
                device!.exposurePointOfInterest = cameraPoint!
                device!.exposureMode = AVCaptureDevice.ExposureMode.autoExpose
            }
        }
    }
    
    //MARK: -设置焦距
    func setVideoScaleAndCropFactor(scale:CGFloat){
        
        let device = self.cameraInput?.device
        
        do {
            try device?.lockForConfiguration()
        } catch {
            print("\(error.localizedDescription)")
        }
        device?.ramp(toVideoZoomFactor: scale, withRate: 10)
    }
}
