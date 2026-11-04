//
//  ContentViewModel.swift
//  Khoriggo
//

import Foundation
import Observation

@Observable
final class ContentViewModel {
    // Values shown in the text fields.
    var server = "https://qa-app.sclera.com"
    var vdmsID = "VDMS870"
    var workOrderID = ""
    var assetID = ""

    // The last deep link received, shown on screen.
    var receivedLink: DeepLink?

    // Sclera pages for the current values. The ID is optional: without it the
    // URL points at the list page. Only the VDMS ID is required.
    var workOrderURL: URL? { pageURL(path: "work_order", recordID: workOrderID) }
    var assetURL: URL? { pageURL(path: "assets", recordID: assetID) }


    /// Called when the app is opened from a link. Fills the fields, opens nothing.
    func handle(_ url: URL) {
        guard let link = DeepLink(url: url) else { return }

        receivedLink = link

        if let server = link.server { self.server = server }
        if let vdmsID = link.vdmsID { self.vdmsID = vdmsID }

        switch link.kind {
        case .asset: assetID = link.recordID ?? ""
        case .workOrder: workOrderID = link.recordID ?? ""
        }
    }

    private func pageURL(path: String, recordID: String) -> URL? {
        let vdms = vdmsID.trimmingCharacters(in: .whitespacesAndNewlines)
        let id = recordID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !vdms.isEmpty else { return nil }
        let base = "\(server)/admin/vdms/\(vdms)/\(path)"
        return URL(string: id.isEmpty ? base : "\(base)/\(id)")
    }
}
