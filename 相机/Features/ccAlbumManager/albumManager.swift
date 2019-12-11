//
//  albumManager.swift
//  相机
//
//  Created by cc on 2019/12/11.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import UIKit
import Photos

class albumManager: NSObject {
    
    //获取相册资源
    class func loadPhotoFromAlbum() -> Array<PHAsset>{
        
        var assets:Array<PHAsset> = Array.init()
        
        let options = PHFetchOptions.init()
        
        //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
        
        let result :PHFetchResult<PHAssetCollection> = getCollection();
        result.enumerateObjects { (collection, index, stop) in
            let fetchAssets = PHAsset.fetchAssets(in: collection, options: options)
            fetchAssets.enumerateObjects { (asset, index, stop) in
                assets.append(asset)
            }
        }
        return assets;
    }
    //请求视频资源
    class func requestVideoSource(asset:PHAsset,handler: @escaping (AVAsset) -> ()){
        
        let options = PHVideoRequestOptions.init()
        options.version = .current
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .fastFormat

        let imageManager = PHImageManager.init()
        imageManager.requestAVAsset(forVideo: asset, options: options) { (asset, audioMix, stop) in
            handler(asset!)
        }
    }
    //请求图片资源
    class func requestImageSource(asset:PHAsset,handler: @escaping (Data) -> ()){
        
        let options = PHImageRequestOptions.init()
        options.version = .current
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .fastFormat
        options.resizeMode = .none
        options.isSynchronous = true
        
        let imageManager = PHImageManager.init()
        imageManager.requestImageData(for: asset, options: options) { (data, dataUTI, orientation, stop) in
            handler(data!)
        }
    }
    
    //请求相册权限
    class func requestAuthorization(handler: @escaping (Bool) -> ()){
        PHPhotoLibrary.requestAuthorization { (status) in
            handler (status == .authorized ? true:false)
        }
    }
    //获取相册权限
    class func getAlbumAuthorizationStatus() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    //获取资源
    class func getCollection() -> PHFetchResult<PHAssetCollection>{
        
        let smartOptions = PHFetchOptions()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                           subtype: .albumRegular,
                                                           options: smartOptions)
        return smartAlbums
    }
    
    //获取视频的关键帧
    class func getVideoCurrentImage(second:Double,asset:AVAsset) -> UIImage {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(second, preferredTimescale: 600)
        var actualTime:CMTime = CMTimeMake(value: 0,timescale: 0)
        let imageRef:CGImage = try! generator.copyCGImage(at: time, actualTime: &actualTime)
        let currentImage = UIImage(cgImage: imageRef)
        
        return currentImage
        
    }

}
