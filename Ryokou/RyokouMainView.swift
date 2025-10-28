//
//  ContentView.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/23/25.
//

import SwiftUI
import SwiftData

struct RyokouMainView: View {
//    @AppStorage("auth.isLoggedIn") private var storedIsLoggedIn: Bool = false
//    @AppStorage("auth.username")   private var storedUsername: String = ""
    
//    @State private var vm = AuthViewModel()
    
    var body: some View {
        
//        Group {
//            if storedIsLoggedIn {
//                MainTabView(username: storedUsername) {
//                    vm.signOut {
//                        storedIsLoggedIn = false
//                        storedUsername   = ""
//                    }
//                }
//            } else {
//                LoginView(vm: vm)
//            }
//        }
//        .animation(.easeInOut, value: storedIsLoggedIn)
        RyokouTabView()
    }
}
