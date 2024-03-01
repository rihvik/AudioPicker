//
//  AudioPicker.swift
//  audio
//
//  Created by user2 on 01/03/24.
//

import SwiftUI
import Firebase
import FirebaseStorage
import MobileCoreServices
import AVFoundation

class AudioPicker: NSObject, ObservableObject {
    @Published var audioURL: URL?
    @Published var isPresented = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    override init() {
        super.init()
        // Set delegate here if needed
    }

    func selectAudio() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio])
        picker.delegate = self
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            print("Failed to get root view controller")
            return
        }
        rootViewController.present(picker, animated: true)
    }

    func uploadAudio(audioURL: URL) {
        guard let audioData = try? Data(contentsOf: audioURL) else {
            print("Failed to load audio data")
            return
        }
        
        // Convert audio data to MP4 format
        guard let mp4Data = convertToMP4(data: audioData) else {
            print("Failed to convert audio data to MP4")
            return
        }
        
        let storageRef = Storage.storage().reference().child("audios").child(UUID().uuidString + ".mp4")
        storageRef.putData(mp4Data, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading audio: \(error.localizedDescription)")
                self.showAlert = true
                self.alertMessage = error.localizedDescription
            } else {
                print("Audio uploaded successfully!")
                self.audioURL = nil // Reset audioURL after successful upload if needed
                // Handle success, if needed
            }
        }
    }

    // Function to convert audio data to MP4 format
    private func convertToMP4(data: Data) -> Data? {
        let audioURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("audio.wav")
        
        do {
            try data.write(to: audioURL)
        } catch {
            print("Failed to write audio data to temporary file:", error)
            return nil
        }
        
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("output.mp4")
        let outputFileType = AVFileType.mp4
        
        let composition = AVMutableComposition()
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        do {
            let sourceAsset = AVURLAsset(url: audioURL)
            let sourceTrack = sourceAsset.tracks(withMediaType: .audio).first!
            
            try audioTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: sourceAsset.duration), of: sourceTrack, at: .zero)
        } catch {
            print("Failed to load audio track:", error)
            return nil
        }
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            print("Failed to create export session")
            return nil
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = outputFileType
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("Audio converted to MP4 successfully")
            case .failed:
                if let error = exportSession.error {
                    print("Failed to convert audio to MP4:", error.localizedDescription)
                } else {
                    print("Failed to convert audio to MP4")
                }
            case .cancelled:
                print("Audio conversion cancelled")
            default:
                print("Unknown status:", exportSession.status.rawValue)
            }
        }
        
        guard let exportURL = exportSession.outputURL else {
            print("Failed to get output URL")
            return nil
        }
        
        do {
            return try Data(contentsOf: exportURL)
        } catch {
            print("Failed to read converted audio data:", error)
            return nil
        }
    }
}

extension AudioPicker: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        audioURL = selectedURL
        uploadAudio(audioURL: selectedURL)
    }
}
