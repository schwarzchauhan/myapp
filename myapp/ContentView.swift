import AppIntents
import SwiftUI

enum NavigationPage: Hashable {
    case page1
    case page2
    case page3
}

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    ItineraryShortcut.updateAppShortcutParameters()
                }
        }
    }
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var navigationPath: [NavigationPage] = []
    let viewModel = ItineraryViewModel()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 20) {
                Button("Fetch") {
                    viewModel.setItineraries()
                }
                .buttonStyle(.borderedProminent)

                Divider()
                    .padding(.vertical)

                Button("Flight") {
                    navigationPath.append(.page1)
                }
                .buttonStyle(.bordered)

                Button("Hotel") {
                    navigationPath.append(.page2)
                }
                .buttonStyle(.bordered)

                Button("My Booking") {
                    navigationPath.append(.page3)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Home")
            .navigationDestination(for: NavigationPage.self) { page in
                switch page {
                case .page1:
                    PageOneView()
                case .page2:
                    PageTwoView()
                case .page3:
                    PageThreeView()
                }
            }
        }
        .onAppear {
            openLatestBookingIfNeeded()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                openLatestBookingIfNeeded()
            }
        }
    }

    private func openLatestBookingIfNeeded() {
        guard ItineraryService.shared.consumeOpenLatestBookingRequest() else { return }
        navigationPath = [.page3]
    }
}

struct PageTwoView: View {
    var body: some View {
        VStack {
            Text("Welcome to Page 2")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.green)
        }
        .navigationTitle("Page 2")
    }
}

#Preview {
    ContentView()
}


