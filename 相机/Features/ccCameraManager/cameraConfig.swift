//
//  cameraConfig.swift
//  相机
//
//  Created by cc on 2019/12/9.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import AVFoundation

class cameraConfig: NSObject {

    var videoPath: String!//视频路径
    var transfrom: CGAffineTransform!//图层旋转角度
    var orientation:AVCaptureVideoOrientation!//输出方向
    var videoSize: CGSize!//视频分辨率
    var videoBitRate: Float!//视频码率
    var videoFrameRate: Float!//视频码率
    var audioSamplerate: Float!//音频采样率
    var audioBitRate: Float!//音频比特率
    var audioChannels: Int!//声道
    
}
