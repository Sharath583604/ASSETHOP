//
//  ContentView.swift
//  Khoriggo
//
//  Created by Sharath on 30/10/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header

                if let link = viewModel.receivedLink {
                    Card(title: "Received Link", icon: "arrow.down.circle.fill") {
                        DetailRow(title: "Link", value: link.url.absoluteString)
                        DetailRow(title: "Type", value: link.kind.title)
                        DetailRow(title: "Record ID", value: link.recordID ?? "none")
                        DetailRow(title: "Back URL", value: link.backURL ?? "none")
                        DetailRow(title: "VDMS ID", value: link.vdmsID ?? "none")
                        DetailRow(title: "Server", value: link.server ?? "none")
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Card(title: "URL", icon: "link.circle") {
                    DetailRow(title: "LINK", value: "\(viewModel.assetURL != nil ? viewModel.assetURL : viewModel.workOrderURL)")
                }
                
                Card(title: "VDMS", icon: "building.2.fill") {
                    IDField(placeholder: "VDMS ID", text: $viewModel.vdmsID, capitalize: true)
                }

                Card(title: "Work Order", icon: "wrench.and.screwdriver.fill") {
                    IDField(placeholder: "Corrigo work order ID (optional)", text: $viewModel.workOrderID)
                    OpenButton(title: "Open Work Order", url: viewModel.workOrderURL) { openURL($0) }
                }

                Card(title: "Asset", icon: "shippingbox.fill") {
                    IDField(placeholder: "Corrigo asset ID (optional)", text: $viewModel.assetID)
                    OpenButton(title: "Open Asset", url: viewModel.assetURL) { openURL($0) }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .scrollDismissesKeyboard(.interactively)
        // Entry point for deep links: khoriggo://asset/<id>?back_url=...
        .onOpenURL { url in
            withAnimation(.spring(duration: 0.5)) {
                viewModel.handle(url)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Image(systemName: "link.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.tint)
            Text("AssetHop")
                .font(.title.bold())
            Text(viewModel.server)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Small building blocks

private struct Card<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct IDField: View {
    let placeholder: String
    @Binding var text: String
    var capitalize = false

    var body: some View {
        TextField(placeholder, text: $text)
            .textInputAutocapitalization(capitalize ? .characters : .never)
            .autocorrectionDisabled()
            .padding(12)
            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 10))
    }
}

private struct OpenButton: View {
    let title: String
    let url: URL?
    let open: (URL) -> Void

    var body: some View {
        Button {
            if let url { open(url) }
        } label: {
            Label(title, systemImage: "arrow.up.right")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

private struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.footnote)
                .textSelection(.enabled)
        }
    }
}

#Preview {
    ContentView()
}
