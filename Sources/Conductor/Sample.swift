import SwiftUI

@available(iOS 14, *)
struct Sample: View {
    @StateObject var router = NavigationRouter()
    
    var body: some View {
        NavigationStack(router: router) {
            VStack {
                Text("Root")
                    .padding()
                
                Button("Login") {
                    router.navigate { it in
                        it.goToFirst(LoginScreen())
                    }
                }
                .padding()
            }
            .navigationTitle("Root")
        } routes: {
            NavigationStackScreen(LoginScreen.self) { login in
                LoginView()
            }
            
            NavigationStackScreen(HomeScreen.self) { home in
                HomeView()
            }
        }
    }
}

struct LoginScreen: Hashable {}

struct HomeScreen: Hashable {
    let session: String
}

@available(iOS 14, *)
struct LoginView: View {
    @Environment(\.navigationRouter) var router: NavigationRouter
    
    var body: some View {
        VStack {
            Text("Login")
                .padding()
            
            Button("Home (push)") {
                router.navigate { it in
                    it.push(HomeScreen(session: "sess"))
                }
            }
            .padding()
            
            Button("Home (go)") {
                router.navigate { it in
                    it.goToFirst(HomeScreen(session: "sess"))
                }
            }
            .padding()
        }
        .navigationTitle("Login")
    }
}

@available(iOS 14, *)
struct HomeView: View {
    @Environment(\.navigationRouter) var router: NavigationRouter
    
    var body: some View {
        VStack {
            Text("Home")
                .padding()
            
            Button("Login (push)") {
                router.navigate { it in
                    it.push(LoginScreen())
                }
            }
            .padding()
            
            Button("Login (go)") {
                router.navigate { it in
                    it.goToFirst(LoginScreen())
                }
            }
            .padding()
            
            Button("Root") {
                router.navigate { it in
                    it.popToRoot()
                }
            }
            .padding()
            
            Button("Pop to") {
                router.navigate { it in
                    it.popToLast(LoginScreen.self)
                }
            }
            .padding()
            
            Button("Party") {
                router.navigate { it in
                    it.popToRoot()
                    it.push(LoginScreen())
                    it.goToFirst(HomeScreen(session: "sess-1"))
                    it.push(LoginScreen())
                    it.pop(1)
                    it.push(LoginScreen())
                    it.push(HomeScreen(session: "sess-2"))
                    it.popToFirst(LoginScreen.self)
                    it.push(HomeScreen(session: "sess-3"))
                    it.push(LoginScreen())
                    it.push(HomeScreen(session: "sess-4"))
                    it.popToLast(LoginScreen.self)
                }
            }
            .padding()
        }
        .navigationTitle("Home")
    }
}
