
//
//  encodeManager.swift
//  相机
//
//  Created by cc on 2019/12/9.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class encodeManager:NSObject {
    
    var assetWrite: AVAssetWriter!
    var videoInput: AVAssetWriterInput!
    var audioInput: AVAssetWriterInput!
    var videoSize: CGSize!
    var videoBitRate: Float!
    var videoFrameRate: Float!
    var audioSamplerate: Float!
    var audioBitRate: Float!
    var audioChannels: Int!
    var transfrom: CGAffineTransform!
    
    func encoder(transfrom:CGAffineTransform,path:String,videoSize:CGSize,videoFrameRate:Float,videoBitRate:Float,audioSamplerate:Float,audioBitRate:Float,audioChannels:Int){
        self.transfrom = transfrom
        self.videoSize = videoSize
        self.videoFrameRate = videoFrameRate
        self.videoBitRate = videoBitRate
        self.audioBitRate = audioBitRate
        self.audioSamplerate = audioSamplerate
        self.audioChannels = audioChannels
        
        
        let url = NSURL.fileURL(withPath: path);
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch{
                print("\(error.localizedDescription)")
            }
        }
        do {
            try self.assetWrite = AVAssetWriter.init(url: url, fileType: .mp4)
            //初始化写入媒体类型为MP4类型
            self.assetWrite?.shouldOptimizeForNetworkUse = true;
        } catch{
            print("\(error.localizedDescription)")
        }
        
        initVideo()
        initAudio()
        
    }
    
    //录制视频的一些配置，分辨率，编码方式等等
    func initVideo(){
        
        let videoCompressionProps:[String: Any] = [
            AVVideoMaxKeyFrameIntervalKey:String(self.videoFrameRate),
            AVVideoAverageBitRateKey:String(self.videoBitRate),
            AVVideoH264EntropyModeKey:AVVideoH264EntropyModeCABAC]
        
        let settings:[String: Any] = [
            AVVideoCodecKey:"\(AVVideoCodecH264)",
            AVVideoCompressionPropertiesKey:videoCompressionProps,
            AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill,
            AVVideoWidthKey:"\(self.videoSize.width)",
            AVVideoHeightKey:"\(self.videoSize.height)"]
        
        self.videoInput = AVAssetWriterInput.init(mediaType: .video, outputSettings: settings);
        //表明输入是否应该调整其处理为实时数据源的数据
        self.videoInput.expectsMediaDataInRealTime = true;
        self.videoInput.transform = self.transfrom;
        //将视频输入源加入
        self.assetWrite.add(self.videoInput)
    }
    
    //音频的一些配置包括音频各种这里为AAC,音频通道、采样率和音频的比特率
    func initAudio(){
        
        let settings:[String: Any] = [
            AVFormatIDKey:NSNumber(value: kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey:NSNumber(value: self.audioChannels),
            AVSampleRateKey:NSNumber(value: self.audioSamplerate),
            AVEncoderBitRateKey:NSNumber(value: self.audioBitRate)]
        
        self.audioInput = AVAssetWriterInput.init(mediaType: .audio, outputSettings: settings);
        //表明输入是否应该调整其处理为实时数据源的数据
        self.audioInput.expectsMediaDataInRealTime = true;
        //输入源加入
        self.assetWrite.add(self.audioInput)
    }
    
    //完成视频录制时调用
    func finishWithCompletionHandler(handler: @escaping () -> Void){
        self.assetWrite.finishWriting {
            self.assetWrite = nil
            handler();
        };
    }
    
    //通过这个方法写入数据
    func encodeFrame(sampleBuffer:CMSampleBuffer,isVideo:Bool) -> Bool {
        //开始写入
        return autoreleasepool { () -> Bool in
            if CMSampleBufferDataIsReady(sampleBuffer){
                if self.assetWrite.status == .unknown && isVideo{
                    let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                    self.assetWrite.startWriting()
                    self.assetWrite.startSession(atSourceTime: startTime)
                }
                
                var success:Bool = true
                if isVideo{
                    if  self.videoInput.isReadyForMoreMediaData {
                        success = self.videoInput.append(sampleBuffer)
                    }
                }else{
                    if  self.audioInput.isReadyForMoreMediaData {
                        success = self.audioInput.append(sampleBuffer)
                    }
                }
                return success
            }
            return true
        }
    }
}

