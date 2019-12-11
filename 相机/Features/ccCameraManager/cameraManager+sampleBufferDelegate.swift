//
//  cameraManager+sampleBufferDelegate.swift
//  相机
//
//  Created by cc on 2019/12/9.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension cameraManager{
    
    //MARK: -AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //录制 禁止输入
        if self.isCapturing == false{
            return
        }
        // 进行数据编码
        let isVideo = connection == self.videoOutput?.connection(with: .video)!
        
        synchronized(lock: self) {
            
            let isAppend:Bool = self.encode!.encodeFrame(sampleBuffer: sampleBuffer, isVideo: isVideo)
            if isAppend == false{
                self.encode?.finishWithCompletionHandler {
                    if self.recordFinishBlock != nil{
                        self.recordFinishBlock!()
                    }
                }
            }
        }
    }
    //MARK: -AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        
    }    
    //锁
    func synchronized(lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
}
