import SwiftUI

struct CollectionCalendarView: View {
    @EnvironmentObject private var addressStore: ResidentAddressStore
    @EnvironmentObject private var viewModel: CollectionScheduleViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingAddressEditor = false

    private var charcoal: Color {
        colorScheme == .dark ? Color(red: 0.91, green: 0.94, blue: 0.92) : Color(red: 0.15, green: 0.20, blue: 0.18)
    }
    private var green: Color {
        colorScheme == .dark ? Color(red: 0.43, green: 0.83, blue: 0.58) : Color(red: 0.12, green: 0.43, blue: 0.27)
    }
    private var background: Color {
        colorScheme == .dark ? Color(red: 0.08, green: 0.11, blue: 0.10) : Color(red: 0.96, green: 0.97, blue: 0.96)
    }
    private var greenSurface: Color {
        colorScheme == .dark ? Color(red: 0.13, green: 0.23, blue: 0.17) : Color(red: 0.87, green: 0.95, blue: 0.88)
    }
    private var blueSurface: Color {
        colorScheme == .dark ? Color(red: 0.13, green: 0.21, blue: 0.27) : Color(red: 0.89, green: 0.95, blue: 0.99)
    }
    private var blue: Color {
        colorScheme == .dark ? Color(red: 0.57, green: 0.77, blue: 0.94) : Color(red: 0.20, green: 0.39, blue: 0.55)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your bin day")
                            .font(.largeTitle.bold())
                        Text("Collections for your household.")
                            .foregroundStyle(charcoal.opacity(0.8))
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 16) {
                        Label("Your address", systemImage: "mappin.and.ellipse")
                            .font(.headline)
                            .foregroundStyle(blue)
                        if addressStore.hasSavedAddress {
                            Text(addressStore.formattedAddress)
                                .font(.body.weight(.medium))
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text("Add your address to find your bin day.")
                                .foregroundStyle(charcoal.opacity(0.8))
                        }
                        Button {
                            showingAddressEditor = true
                        } label: {
                            Label(addressStore.hasSavedAddress ? "Edit address" : "Add address",
                                  systemImage: addressStore.hasSavedAddress ? "pencil" : "plus")
                                .font(.subheadline.weight(.semibold))
                                .frame(minHeight: 44)
                        }
                        .tint(blue)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(blueSurface, in: RoundedRectangle(cornerRadius: 24))

                    if viewModel.isLoading {
                        ProgressView("Finding your collection day…")
                            .tint(green)
                            .frame(maxWidth: .infinity)
                            .padding(32)
                            .background(greenSurface, in: RoundedRectangle(cornerRadius: 28))
                    } else if let schedule = viewModel.result {
                        VStack(alignment: .leading, spacing: 18) {
                            Image(systemName: "calendar")
                                .font(.system(size: 30, weight: .medium))
                                .foregroundStyle(green)
                                .frame(width: 60, height: 60)
                                .background(green.opacity(0.10), in: RoundedRectangle(cornerRadius: 18))
                                .accessibilityHidden(true)
                            if let day = schedule.collectionDay {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Collection day")
                                        .font(.subheadline.weight(.medium))
                                    Text(day)
                                        .font(.largeTitle.bold())
                                        .foregroundStyle(green)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            if let area = schedule.recyclingArea {
                                Divider().overlay(green.opacity(0.15))
                                Label {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Recycling area")
                                            .font(.subheadline)
                                        Text(area).font(.title3.bold())
                                    }
                                } icon: {
                                    Image(systemName: "arrow.3.trianglepath")
                                        .font(.title2)
                                        .foregroundStyle(green)
                                }
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(greenSurface, in: RoundedRectangle(cornerRadius: 28))
                    }

                    if let error = viewModel.errorMessage {
                        Label {
                            Text(error).fixedSize(horizontal: false, vertical: true)
                        } icon: {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundStyle(.red)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
                        .accessibilityElement(children: .combine)
                    }

                    Button {
                        viewModel.findCollectionDates(address: addressStore.address)
                    } label: {
                        HStack {
                            Text(viewModel.result == nil ? "Check collection day" : "Refresh collection day")
                            Spacer(minLength: 12)
                            Image(systemName: "arrow.clockwise")
                                .accessibilityHidden(true)
                        }
                        .font(.headline)
                        .padding(20)
                        .foregroundStyle(colorScheme == .dark ? Color(red: 0.08, green: 0.16, blue: 0.11) : .white)
                        .background(green, in: RoundedRectangle(cornerRadius: 16))
                        .opacity(addressStore.hasSavedAddress && !viewModel.isLoading ? 1 : 0.45)
                    }
                    .buttonStyle(.plain)
                    .disabled(!addressStore.hasSavedAddress || viewModel.isLoading)
                }
                .padding(20)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .background(background)
            .foregroundStyle(charcoal)
            .navigationTitle("Collections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showingAddressEditor) { AddressEditorView() }
        }
    }
}
