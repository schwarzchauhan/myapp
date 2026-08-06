import AppIntents
import SwiftUI
import SwiftData

enum NavigationPage: Hashable {
    case page1
    case page2
    case page3(search: String?)
}

@main struct MyApp: App {
    
    init() {
        let manager = CalendarManager.shared
        AppDependencyManager.shared.add(dependency: manager)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
//                .task {
//                    await FlightBookingIndexer.reindexSavedBooking()
//                }
        }
        .modelContainer(CalendarManager.shared.modelContainer)
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
                    navigationPath.append(.page3(search: nil))
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
                case .page3(let search):
                    PageThreeView(searchTerm: search)
                }
            }
        }
        .onAppear {
            openBookingIfNeeded()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                openBookingIfNeeded()
            }
        }
    }

    private func openBookingIfNeeded() {
        guard ItineraryService.shared.consumeOpenLatestBookingRequest() else { return }
        let search = ItineraryService.shared.consumePendingFlightSearch()
        navigationPath = [.page3(search: search)]
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
