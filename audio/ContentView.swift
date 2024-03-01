//
//  ContentView.swift
//  audio
//
//  Created by user2 on 29/02/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isUserAuthenticated = false

    var body: some View {
        if isUserAuthenticated {
            AudioUploadView()
        } else {
            SignInView(isUserAuthenticated: $isUserAuthenticated)
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

