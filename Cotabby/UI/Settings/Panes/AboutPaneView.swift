import AppKit
import SwiftUI

/// File overview:
/// "About" detail pane of the redesigned Settings window. Consolidates what used to live across
/// three legacy sections (header, support CTA, uninstall) plus a new Acknowledgements modal that
/// lists the third-party packages Cotabby ships with.
struct AboutPaneView: View {
    let appUpdateManager: AppUpdateManager

    @State private var isShowingAcknowledgements = false

    var body: some View {
        SettingsPaneScaffold {
            Section { aboutHeader }
            if ProductIdentity.supportURL != nil {
                Section("Support") { supportRow }
            }
            Section("Resources") { linksRow }
            Section("Uninstall") { uninstallText }
        }
        .sheet(isPresented: $isShowingAcknowledgements) {
            AcknowledgementsView { isShowingAcknowledgements = false }
        }
    }

    @ViewBuilder
    private var aboutHeader: some View {
        HStack(spacing: 12) {
            ProductMarkView(size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(ProductIdentity.displayName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))

                Text(ProductIdentity.tagline)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.secondary)

                Text(appVersionText)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)

            if appUpdateManager.canCheckForUpdates {
                Button("Check for Updates") {
                    appUpdateManager.checkForUpdates()
                }
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var supportRow: some View {
        // Stack the support copy and the call-to-action vertically so the button sits below the
        // paragraphs instead of competing with them on the right edge of the row. `LabeledContent`
        // placed the value column next to the label, which made the wall of text visually compete
        // with a small button — the natural reading order is paragraphs first, then action.
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(
                    "\(ProductIdentity.displayName) starts from a simple belief: AI should run on your device, "
                    + "respect your privacy, and remain open to everyone."
                )

                Text(
                    "If \(ProductIdentity.displayName) has helped you, your support helps keep improving it."
                )
            }
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            if let supportURL = ProductIdentity.supportURL {
                Link(destination: supportURL) {
                    Label("Support \(ProductIdentity.displayName)", systemImage: "heart.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
        }
    }

    @ViewBuilder
    private var linksRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let repoURL = ProductIdentity.repositoryURL {
                Link(destination: repoURL) {
                    Label("GitHub Repository", systemImage: "chevron.left.forwardslash.chevron.right")
                }
            }
            if let documentationURL = ProductIdentity.documentationURL {
                Link(destination: documentationURL) {
                    Label("Documentation", systemImage: "book")
                }
            }
            Button {
                isShowingAcknowledgements = true
            } label: {
                Label("Acknowledgements", systemImage: "doc.text")
            }
            .buttonStyle(.link)
        }
    }

    @ViewBuilder
    private var uninstallText: some View {
        Text(
            "Remove \(ProductIdentity.displayName) from Applications. To fully clean up app data, "
            + "delete its folder under ~/Library/Application Support."
        )
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    /// The app bundle is the canonical source for human-facing version text.
    private var appVersionText: String {
        let shortVersion =
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

        switch (shortVersion, buildNumber) {
        case (let shortVersion?, let buildNumber?) where shortVersion != buildNumber:
            return "Version \(shortVersion) (\(buildNumber))"
        case (let shortVersion?, _):
            return "Version \(shortVersion)"
        case (_, let buildNumber?):
            return "Build \(buildNumber)"
        default:
            return "Unknown version"
        }
    }
}
