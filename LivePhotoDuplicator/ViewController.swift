//
//  ViewController.swift
//  LivePhotoDuplicator
//
//  Created by Aaron Satterfield on 10/4/15.
//  Copyright © 2015 aasatt. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import AVKit
import MediaPlayer
import MobileCoreServices

struct FilePaths {
    static let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0]

    static var originalPath = FilePaths.documentsPath.stringByAppendingString("/VidToLiveMovie.JPG.MOV")
    static var livePath = FilePaths.documentsPath.stringByAppendingString("/")
    static var thumbPath = FilePaths.documentsPath.stringByAppendingString("/VidToLiveMovie.JPG.jpeg")
    
    
}


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIVideoEditorControllerDelegate {
    
    @IBOutlet weak var exportButton: UIButton!
    var livePhotoResources : [PHAssetResource]!
    var livePhoto : PHLivePhoto!
    var moviePlayer : MPMoviePlayerController!
    var imagePicker : UIImagePickerController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleLabel = UILabel(frame: CGRectMake(0,0,200,40))
        titleLabel.text = "Create Movie"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont(name: "SF-UIDisplay-Light", size: 22)
        self.navigationItem.titleView = titleLabel
        
            
        
        self.imagePicker = UIImagePickerController()
        self.imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeLivePhoto as String]
        self.imagePicker.delegate = self
        self.presentImagePicker()
    }
    
    func presentImagePicker () {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true) { () -> Void in
            self.navigationController?.popToRootViewControllerAnimated(true)
            
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print(info)
        self.livePhoto = info[UIImagePickerControllerLivePhoto] as? PHLivePhoto
        if let livePhoto = info["UIImagePickerControllerLivePhoto"] as? PHLivePhoto {
            self.livePhotoResources = PHAssetResource.assetResourcesForLivePhoto(livePhoto)
            print(self.livePhotoResources)
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                picker.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.createMovie()
                })
            }
            
        } else {
            picker.dismissViewControllerAnimated(true) { () -> Void in
                self.navigationController?.popToRootViewControllerAnimated(true)
                
            }
            
        }
        
        
        
        
        
    }
    
    
    
    func createMovie () {
        if livePhotoResources.count > 1 {
            print(livePhotoResources)
            for resource in livePhotoResources {
                if resource.type == PHAssetResourceType.PairedVideo {
                    
                    let options = PHAssetResourceRequestOptions()
                    
                    let movieData = NSMutableData()
                    PHAssetResourceManager().requestDataForAssetResource(resource, options: options, dataReceivedHandler: { (data) -> Void in
                        movieData.appendData(data)
                        }, completionHandler: { (error) -> Void in
                            if error == nil {
                                movieData.writeToFile(FilePaths.originalPath, atomically: true)
                                print("success")
                                
                                let asset = AVURLAsset(URL: NSURL(fileURLWithPath: FilePaths.originalPath))
                                print(asset.metadata)
                                print("success")
                                
                                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                                }
                            } else {
                                
                                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                                    
                                }
                                //self.presentImagePicker()
                                
                                print(error)
                            }
                    })
                    
                } else {
                    let options = PHAssetResourceRequestOptions()
                    
                    let movieData = NSMutableData()
                    PHAssetResourceManager().requestDataForAssetResource(resource, options: options, dataReceivedHandler: { (data) -> Void in
                        movieData.appendData(data)
                        }, completionHandler: { (error) -> Void in
                            if error == nil {
                                print(CGImageSourceCopyMetadataAtIndex(CGImageSourceCreateWithData(movieData, nil)!, 0, nil))
                                movieData.writeToFile(FilePaths.thumbPath, atomically: true)
                                let asset = AVURLAsset(URL: NSURL(fileURLWithPath: FilePaths.thumbPath))
                                print(asset.metadata)
                                print("success")
                            }
                    })
                }
                
                
            }
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                let creationRequest = PHAssetCreationRequest.creationRequestForAsset()
                let options = PHAssetResourceCreationOptions()
                
                creationRequest.addResourceWithType(PHAssetResourceType.PairedVideo, fileURL: NSURL(fileURLWithPath: FilePaths.originalPath), options: options)
                creationRequest.addResourceWithType(PHAssetResourceType.Photo, fileURL: NSURL(fileURLWithPath: FilePaths.thumbPath), options: options)
                
                }, completionHandler: { (success, error) -> Void in
                    if success {
                        print("LIVE PHOTO SAVED")
                    }
                    print(success)
                    print(error)
                    
            })
            
        }
        
        
    }
    
    @IBAction func actionShareVideo(sender: AnyObject) {
        let firstActivityItem = self.livePhoto
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(activityViewController, animated: true, completion: nil)
            
        })
        
        
    
    
    }
}

