import AppIntents
import SwiftUI
import SwiftData

enum NavigationPage: Hashable {
    case page1
    case page2
    case page3(search: UUID?)
}

@main struct MyApp: App {
    
    
    init() {

    }
    var body: some Scene {
        WindowGroup {
            ContentView()
//                .task {
//                    await FlightBookingIndexer.reindexSavedBooking()
//                }
        }
    }
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var navigationPath: [NavigationPage] = []
    let viewModel = ItineraryViewModel()
    @State private var navigation = NavigationManager.shared
    
    init() {
        let manager = CalendarManager.shared
        AppDependencyManager.shared.add(dependency: manager)
    }

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
                case .page3(let eventID):
                    PageThreeView(searchTerm: eventID)
                }
            }
        }
        .modelContainer(CalendarManager.shared.modelContainer)
        .onAppear {
            openSelectedEventIfNeeded()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                openSelectedEventIfNeeded()
            }
        }
        .onChange(of: navigation.selectedEventID) { _, eventID in
            guard let eventID else { return }
            navigationPath = [.page3(search: eventID)]
            navigation.selectedEventID = nil
        }
    }

    private func openSelectedEventIfNeeded() {
        guard let eventID = navigation.selectedEventID else { return }
        navigationPath = [.page3(search: eventID)]
        navigation.selectedEventID = nil
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
