# AssetHop

A small iOS app (SwiftUI, MVVM) that opens Sclera work order and asset pages.
Other apps can launch it with a deep link; the app fills in the IDs and lets the
user open the matching page.

## What it does

1. Shows fields for a **VDMS ID**, a **work order ID** and an **asset ID**.
2. **Open Work Order** / **Open Asset** open the Sclera page in the browser:

   ```
   <server>/admin/vdms/<vdms id>/work_order/<work order id>
   <server>/admin/vdms/<vdms id>/assets/<asset id>
   ```

3. When another app opens a `khoriggo://` link, the app fills the fields from the
   link and shows the link's details. It does **not** open anything by itself.

The record ID is optional. With an ID the button opens that record; with the ID
left empty it opens the list page without an ID:

   ```
   <server>/admin/vdms/<vdms id>/work_order
   <server>/admin/vdms/<vdms id>/assets
   ```

Only the VDMS ID is required. A button stays disabled while it is empty.

## Deep link format

```
khoriggo://asset/<asset id>?back_url=<url>
khoriggo://workorder/<work order id>?back_url=<url>
```

Example (`back_url` is percent-encoded):

```
khoriggo://asset/9100?back_url=https%3A%2F%2Fapp.sclera.com%2Fadmin%2Fvdms%2FVDMS870%2Fassets%2F9100
```

| Part of the link | Used for |
|---|---|
| Host: `asset` or `workorder` | Which record type it is |
| Last path piece (`9100`) | The record ID (optional; e.g. `khoriggo://asset?back_url=...` has none) |
| `back_url` | Shown on screen; the source of the server and VDMS ID |
| Scheme + host of `back_url` | The server (e.g. `https://app.sclera.com`) |
| Path segment after `/vdms/` in `back_url` | The VDMS ID (e.g. `VDMS870`) |

Links that don't use the `khoriggo` scheme or use another host are ignored. A link
with no record ID is accepted and clears that record's ID field. If `back_url` is missing, or has no `/vdms/<id>`, the current
server and VDMS ID stay as they were.

Defaults before any link arrives: server `https://qa-app.sclera.com`, VDMS ID
`VDMS870`. Both are set in `ViewModels/ContentViewModel.swift`.

## How a link flows through the app

```
Another app opens khoriggo://...
  1. iOS finds the scheme            Khoriggo-Info.plist  (CFBundleURLSchemes)
  2. App launches / comes forward    Khoriggo/KhoriggoApp.swift
  3. Entry point                     Views/ContentView.swift      .onOpenURL
  4. Parse the link                  Models/DeepLink.swift        DeepLink(url:)
  5. Fill the fields                 ViewModels/ContentViewModel.swift   handle(_:)
  6. Screen updates                  "Received Link" card appears, fields are filled
  7. User taps an Open button        ContentViewModel builds the URL, openURL(url) opens it
```

## Project structure

```
Khoriggo/
├── KhoriggoApp.swift                 App entry; shows ContentView
├── Models/
│   └── DeepLink.swift                Parses an incoming link into plain values
├── ViewModels/
│   └── ContentViewModel.swift        Screen state, handle(url), builds Sclera URLs
└── Views/
    └── ContentView.swift             The screen (cards, fields, buttons)
Khoriggo-Info.plist                   Registers the khoriggo:// URL scheme
```

- **Model** (`DeepLink`): takes a `URL`, returns the type, record ID (if any), back
  URL, server and VDMS ID, or `nil` if the link isn't valid.
- **ViewModel** (`ContentViewModel`): holds `server`, `vdmsID`, `workOrderID`,
  `assetID` and `receivedLink`. `workOrderURL` and `assetURL` are `nil` only while
  the VDMS ID is empty.
- **View** (`ContentView`): displays the state and calls `viewModel.handle(url)`
  from `.onOpenURL`. It has no parsing or URL-building logic.

## Testing a link

In the iOS Simulator:

```
xcrun simctl openurl booted "khoriggo://asset/9100?back_url=https%3A%2F%2Fapp.sclera.com%2Fadmin%2Fvdms%2FVDMS870%2Fassets%2F9100"
xcrun simctl openurl booted "khoriggo://workorder/1234?back_url=https%3A%2F%2Fapp.sclera.com%2Fadmin%2Fvdms%2FVDMS870%2Fwork_order%2F1234"
```

Expected: the "Received Link" card appears, the VDMS ID, server and the matching
ID field are filled, and the Open button for that record becomes enabled.

## Configuration

| What | Where |
|---|---|
| URL scheme name (`khoriggo`) | `Khoriggo-Info.plist` **and** `DeepLink.swift` (`url.scheme == "khoriggo"`) — keep them the same |
| Default server and VDMS ID | `ViewModels/ContentViewModel.swift` |
| Page paths (`work_order`, `assets`) | `ViewModels/ContentViewModel.swift` |

## Requirements

- Xcode, iOS 18 or later.
- `Khoriggo-Info.plist` is merged with the generated Info.plist
  (`INFOPLIST_FILE` in the project's build settings).

## Limitations

- Only custom-scheme links (`khoriggo://`) are handled. Opening AssetHop from an
  `https://` link (universal links) would need Associated Domains and a hosted
  `apple-app-site-association` file on `app.sclera.com`.
- The Open buttons open the Sclera page in Safari (via `openURL`), not inside the app.
- The server is whatever the link's `back_url` says, so links should only come from
  trusted apps.
