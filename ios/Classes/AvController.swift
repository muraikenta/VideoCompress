
import AVFoundation
import MobileCoreServices

class AvController: NSObject {
    public func getVideoAsset(_ url:URL)->AVURLAsset {
        return AVURLAsset(url: url)
    }
    
    public func getVideoTrack(_ asset: AVURLAsset)->AVAssetTrack? {
        var videoTrack : AVAssetTrack? = nil
        let group = DispatchGroup()
        group.enter()
        asset.loadValuesAsynchronously(forKeys: ["tracks"], completionHandler: {
            var error: NSError? = nil;
            let status = asset.statusOfValue(forKey: "tracks", error: &error)
            if (status == .loaded) {
                videoTrack = asset.tracks(withMediaType: AVMediaType.video).first
            }
            group.leave()
        })
        group.wait()
        return videoTrack
    }
    
    public func getTracks(_ asset: AVURLAsset)->(videoTrack: AVAssetTrack?, audioTrack: AVAssetTrack?) {
        var videoTrack : AVAssetTrack? = nil
        var audioTrack : AVAssetTrack? = nil
        let group = DispatchGroup()
        group.enter()
        asset.loadValuesAsynchronously(forKeys: ["tracks"], completionHandler: {
            var error: NSError? = nil;
            let status = asset.statusOfValue(forKey: "tracks", error: &error)
            if (status == .loaded) {
                videoTrack = asset.tracks(withMediaType: AVMediaType.video).first
                audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first
            }
            group.leave()
        })
        group.wait()
        return (videoTrack, audioTrack)
    }
    
    public func getVideoOrientation(_ path:String)-> Int? {
        let url = Utility.getPathUrl(path)
        let asset = getVideoAsset(url)
        guard let track = getVideoTrack(asset) else {
            return nil
        }
        let size = track.naturalSize
        let txf = track.preferredTransform
        if size.width == txf.tx && size.height == txf.ty {
            return 0
        } else if txf.tx == 0 && txf.ty == 0 {
            return 90
        } else if txf.tx == 0 && txf.ty == size.width {
            return 180
        } else {
            return 270
        }
    }
    
    public func getMetaDataByTag(_ asset:AVAsset,key:String)->String {
        for item in asset.commonMetadata {
            if item.commonKey?.rawValue == key {
                return item.stringValue ?? "";
            }
        }
        return ""
    }
}
