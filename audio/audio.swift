//
//  audio.swift
//  audio
//
//  Created by user2 on 29/02/24.
//

import SwiftUI

struct AudioUploadView: View {
    @StateObject private var audioPicker = AudioPicker()

    var body: some View {
        VStack {
            if let audioURL = audioPicker.audioURL {
                Text("Audio selected: \(audioURL.lastPathComponent)")
                Button("Upload Audio") {
                    audioPicker.uploadAudio(audioURL: audioURL)
                }
            } else {
                Button("Select Audio") {
                    audioPicker.selectAudio()
                }
            }
        }
        .alert(isPresented: $audioPicker.showAlert) {
            Alert(title: Text("Error"), message: Text(audioPicker.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}
