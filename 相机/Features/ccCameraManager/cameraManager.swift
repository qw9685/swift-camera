//
//  cameraManager.swift
//  相机
//
//  Created by mac on 2019/12/4.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import AVFoundation

class cameraManager: NSObject,AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate{
    
    // 新线程进行输出流
    let queue = DispatchQueue(label: "camera.queue")
    
    var cameraInput: AVCaptureDeviceInput?;//摄像头输入
    var audioMicInput: AVCaptureDeviceInput?;//麦克风输入
    var session: AVCaptureSession!;//捕获视频的会话
    
    var audioConnection: AVCaptureConnection?;//音频录制连接
    var videoConnection: AVCaptureConnection?;//视频录制连接

    var previewLayer: AVCaptureVideoPreviewLayer?;//捕获到的视频呈现的layer
    var previewView: UIView!;//捕获到的视频呈现的View

    var videoOutput: AVCaptureVideoDataOutput?;//视频输出
    var audioOutput: AVCaptureAudioDataOutput?;//音频输出
    var imageOutput: AVCaptureStillImageOutput?;//图片输出
        
    var config:cameraConfig?
    var isCapturing:Bool = false
    var encode:encodeManager?
    var recordTime:Float?
    var timer:Timer?
    
    var timerBlock: (( _ time:Float) -> Void)?
    var recordFinishBlock: (() -> Void)?

    convenience init(previewView:UIView,config:cameraConfig) {
        self.init()
        
        self.config = config;
        
        self.previewView = previewView
        self.cameraInput = getDeviceInput(position: .back, mediaType: .video)
        self.audioMicInput = getDeviceInput(position: .back, mediaType: .audio)
        
        self.videoOutput = getDeviceOutput(outPutType: 1) as? AVCaptureVideoDataOutput
        self.audioOutput = getDeviceOutput(outPutType: 2) as? AVCaptureAudioDataOutput
        self.imageOutput = getDeviceOutput(outPutType: 3) as? AVCaptureStillImageOutput
        
        self.session = configSession();
        
        self.videoConnection = getDeviceConnect(mediaType: .video, outPut: self.videoOutput!)
        self.audioConnection = getDeviceConnect(mediaType: .audio, outPut: self.audioOutput!)

        //设置视频的方向
        self.videoConnection?.videoOrientation = .portrait;
        
        setPreviewLayer(previewView: previewView, frame: previewView.bounds)
    }

}
