//
//  PhotoLibraryManager.swift
//  mikeTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import UIKit
import Photos

enum PhotoSaveResult {
    case success
    case permissionDenied
    case saveFailed(Error)
}

struct PhotoLibraryManager {
    @MainActor
    static func saveImage(_ image: UIImage, completion: @escaping (PhotoSaveResult) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            performSave(image, completion: completion)
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        performSave(image, completion: completion)
                    } else {
                        completion(.permissionDenied)
                    }
                }
            }
            
        case .denied, .restricted:
            completion(.permissionDenied)
            
        @unknown default:
            completion(.permissionDenied)
        }
    }
    
    private static func performSave(_ image: UIImage, completion: @escaping (PhotoSaveResult) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(.success)
                } else if let error = error {
                    completion(.saveFailed(error))
                } else {
                    completion(.saveFailed(NSError(domain: "PhotoSave", code: -1)))
                }
            }
        }
    }
}
