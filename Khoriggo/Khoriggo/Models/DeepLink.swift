//
//  DeepLink.swift
//  Khoriggo
//

import Foundation

/// An incoming link such as
/// `khoriggo://asset/9100?back_url=https://app.sclera.com/admin/vdms/VDMS870/assets/9100`
/// or `khoriggo://workorder/1234?back_url=...`. The ID may be left out.
struct DeepLink {
    enum Kind: String {
        case asset
        case workOrder = "workorder"

        var title: String { self == .asset ? "Asset" : "Work Order" }
    }

    let url: URL                // the whole link as received
    let kind: Kind              // asset or work order
    let recordID: String?       // 9100 (nil when the link has no ID)
    let backURL: String?        // the back_url value
    let server: String?         // https://app.sclera.com   (from back_url)
    let vdmsID: String?         // VDMS870                  (from back_url)

    init?(url: URL) {
        guard url.scheme == "khoriggo",
              let host = url.host,
              let kind = Kind(rawValue: host)
        else { return nil }

        let lastPiece = url.lastPathComponent
        let recordID = (lastPiece.isEmpty || lastPiece == "/") ? nil : lastPiece

        let backURL = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == "back_url" }?
            .value
        let back = backURL.flatMap { URL(string: $0) }

        var server: String?
        if let scheme = back?.scheme, let host = back?.host {
            server = "\(scheme)://\(host)"
        }

        // back_url looks like  .../vdms/<vdms id>/...
        var vdmsID: String?
        if let parts = back?.pathComponents, let i = parts.firstIndex(of: "vdms"), i + 1 < parts.count {
            vdmsID = parts[i + 1]
        }

        self.url = url
        self.kind = kind
        self.recordID = recordID
        self.backURL = backURL
        self.server = server
        self.vdmsID = vdmsID
    }
}
