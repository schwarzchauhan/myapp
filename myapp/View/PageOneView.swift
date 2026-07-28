//
//  PageOneView.swift
//  myapp
//
//  Created by Harsh Chauhan on 26/07/26.
//

import SwiftUI

struct PageOneView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedFromCity: City?
    @State private var selectedToCity: City?
    @State private var fromSuggestions: [City] = []
    @State private var toSuggestions: [City] = []

    private var canBook: Bool {
        selectedFromCity != nil && selectedToCity != nil
    }

    var body: some View {
        Form {
            CitySearchField(
                title: "From city",
                selectedCity: $selectedFromCity,
                suggestions: $fromSuggestions
            )
            CitySearchField(
                title: "To city",
                selectedCity: $selectedToCity,
                suggestions: $toSuggestions
            )
        }
        .navigationTitle("Flight")
        .safeAreaInset(edge: .bottom) {
            Button("Book") {
                bookFlight()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
            .disabled(!canBook)
            .padding()
            .background(.bar)
        }
    }

    private func bookFlight() {
        guard let fromCity = selectedFromCity,
              let toCity = selectedToCity else { return }

        let booking = FlightBooking(fromCity: fromCity, toCity: toCity)
        ItineraryService.shared.saveFlightBooking(booking)
        dismiss()
    }
}

private struct CitySearchField: View {
    let title: String
    @Binding var selectedCity: City?
    @Binding var suggestions: [City]

    @State private var text = ""
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var searchTask: Task<Void, Never>?
    @State private var suppressSearch = false

    var body: some View {
        Section(title) {
            TextField("Type at least 3 letters", text: $text)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .onChange(of: text) { _, newValue in
                    handleTextChange(newValue)
                }

            if let selectedCity {
                LabeledContent("Selected") {
                    Text("\(selectedCity.name) (\(selectedCity.code))")
                        .foregroundStyle(.secondary)
                }
            }

            if isSearching {
                HStack {
                    ProgressView()
                    Text("Searching…")
                        .foregroundStyle(.secondary)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
        }

        if selectedCity == nil, !suggestions.isEmpty {
            Section("\(title) suggestions") {
                ForEach(suggestions) { city in
                    Button {
                        selectCity(city)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(city.name)
                                    .foregroundStyle(.primary)
                                Text(city.country)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(city.code)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private func handleTextChange(_ value: String) {
        if suppressSearch {
            suppressSearch = false
            return
        }

        searchTask?.cancel()

        if let selected = selectedCity {
            let display = displayText(for: selected)
            if value == display {
                suggestions = []
                isSearching = false
                return
            }
            selectedCity = nil
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        errorMessage = nil

        guard trimmed.count >= 3 else {
            suggestions = []
            isSearching = false
            return
        }

        isSearching = true
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }

            do {
                let results = try await CitySearchService.shared.search(query: trimmed)
                guard !Task.isCancelled else { return }
                if selectedCity == nil {
                    suggestions = results
                } else {
                    suggestions = []
                }
                isSearching = false
            } catch {
                guard !Task.isCancelled else { return }
                suggestions = []
                isSearching = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func selectCity(_ city: City) {
        searchTask?.cancel()
        suppressSearch = true
        selectedCity = city
        suggestions = []
        errorMessage = nil
        isSearching = false
        text = displayText(for: city)
    }

    private func displayText(for city: City) -> String {
        "\(city.name) (\(city.code))"
    }
}

#Preview {
    NavigationStack {
        PageOneView()
    }
}
