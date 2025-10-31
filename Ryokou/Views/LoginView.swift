import SwiftUI

struct LoginView: View {
    // App-level persistence
    @AppStorage("auth.isLoggedIn") private var storedIsLoggedIn: Bool = false
    @AppStorage("auth.username")   private var storedUsername: String = ""
    
    @State var vm: AuthViewModel = .init()
    @FocusState private var focused: Field?
    @State private var showPassword = false
    
    enum Field { case email, password }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue.opacity(0.25), .purple.opacity(0.25)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Welcome back").font(.largeTitle).bold()
                    Text("Sign in to continue your trip planning")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                
                // Card
                VStack(spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: "envelope.fill").foregroundStyle(.secondary)
                        TextField("Email", text: $vm.email)
                            .textInputAutocapitalization(.never)
                            .textContentType(.username)
                            .keyboardType(.emailAddress)
                            .submitLabel(.next)
                            .focused($focused, equals: .email)
                            .onSubmit { focused = .password }
                    }
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    HStack(spacing: 10) {
                        Image(systemName: "lock.fill").foregroundStyle(.secondary)
                        Group {
                            if showPassword {
                                TextField("Password (min 6 chars)", text: $vm.password)
                            } else {
                                SecureField("Password (min 6 chars)", text: $vm.password)
                            }
                        }
                        .textContentType(.password)
                        .submitLabel(.go)
                        .focused($focused, equals: .password)
                        
                        Button { showPassword.toggle() } label: {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    if let err = vm.errorMessage {
                        Text(err)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button {
                        Task {
                            await vm.signIn { isLogged, user in
                                storedIsLoggedIn = isLogged
                                storedUsername   = user
                            }
                        }
                    } label: {
                        ZStack {
                            Text(vm.isLoading ? "Signing in…" : "Sign In")
                                .fontWeight(.semibold)
                                .opacity(vm.isLoading ? 0.001 : 1)
                            if vm.isLoading { ProgressView().tint(.white) }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(vm.canSubmit ? Color.accentColor : Color.accentColor.opacity(0.4),
                                    in: Capsule())
                        .foregroundStyle(.white)
                    }
                    .disabled(!vm.canSubmit)
                    .padding(.top, 6)
                }
                .padding(20)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.08), radius: 18, y: 8)
                .padding(.horizontal, 24)
                
                if storedIsLoggedIn {
                    VStack(spacing: 8) {
                        Label("Signed in as \(storedUsername)", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.secondary)
                        Button("Sign out") {
                            vm.signOut {
                                storedIsLoggedIn = false
                                storedUsername   = ""
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .transition(.opacity)
                }
                
                Spacer(minLength: 20)
            }
        }
        // Keep VM in sync with storage
        .onAppear { vm.bootstrap(isLoggedIn: storedIsLoggedIn, username: storedUsername) }
        .onChange(of: storedIsLoggedIn) { _, new in vm.update(isLoggedIn: new) }
        .onChange(of: storedUsername)   { _, new in vm.update(username: new) }
    }
}
