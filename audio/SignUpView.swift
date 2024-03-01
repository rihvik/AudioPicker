//
//  SignUpView.swift
//  audio
//
//  Created by user2 on 01/03/24.
//

import SwiftUI
import Firebase

struct SignInView: View {
    @Binding var isUserAuthenticated: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSignUp = false

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if isSignUp {
                Button("Sign Up") {
                    signUp()
                }
            } else {
                Button("Sign In") {
                    signIn()
                }
            }

            Button(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up") {
                isSignUp.toggle()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let _ = authResult {
                self.isUserAuthenticated = true
            } else if let error = error {
                self.alertMessage = error.localizedDescription
                self.showAlert = true
            }
        }
    }

    private func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let _ = authResult {
                self.isUserAuthenticated = true
            } else if let error = error {
                self.alertMessage = error.localizedDescription
                self.showAlert = true
            }
        }
    }
}
