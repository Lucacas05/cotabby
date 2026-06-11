import SwiftUI

/// "Appearance" detail pane of the redesigned Settings window.
///
/// This pane owns the visual configuration surface for inline and popup suggestions: render mode,
/// field indicator visibility, key hints, ghost color, opacity, and size. It exists as its own
/// boundary because these controls answer a different product question from General settings:
/// not "should the app run?", but "how much visual presence should autocomplete have while I type?"
struct AppearancePaneView: View {
    @ObservedObject var suggestionSettings: SuggestionSettingsModel

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        SettingsPaneScaffold {
            Section("Live Preview") {
                SuggestionAppearancePreviewView(
                    ghostColor: selectedGhostTextColor,
                    ghostOpacity: suggestionSettings.ghostTextOpacity,
                    fontSize: suggestionSettings.maximumGhostTextFontSize,
                    keycapLabel: suggestionSettings.acceptanceHintLabel,
                    showsFieldIndicator: suggestionSettings.showIndicator,
                    mirrorPreference: suggestionSettings.mirrorPreference
                )
                .frame(maxWidth: .infinity)
            }

            Section("Suggestion Display") {
                LabeledContent {
                    Picker("Render Mode", selection: mirrorPreferenceBinding) {
                        ForEach(MirrorPreference.allCases) { preference in
                            Label(
                                preference.displayLabel,
                                systemImage: preference.systemImageName
                            )
                            .tag(preference)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .frame(width: 320)
                } label: {
                    SettingsRowLabel(
                        title: "Render Mode",
                        description: "Auto chooses inline ghost text when caret geometry is reliable and a popup when it is not."
                    )
                }

                Toggle(isOn: showIndicatorBinding) {
                    SettingsRowLabel(
                        title: "Field Indicator",
                        description: "Show a small neutral app mark at the edge of supported text fields."
                    )
                }

                Toggle(isOn: showAcceptanceHintBinding) {
                    SettingsRowLabel(
                        title: "Accept-Key Hint",
                        description: "Show the accept shortcut next to ghost text so the insertion gesture stays visible."
                    )
                }

                Toggle(isOn: menuBarWordCountVisibleBinding) {
                    SettingsRowLabel(
                        title: "Menu Bar Word Count",
                        description: "Show a running count of accepted words next to the menu bar icon."
                    )
                }
            }

            Section("Ghost Text") {
                LabeledContent("Color") {
                    HStack(spacing: 8) {
                        ForEach(GhostTextColorPreset.all) { preset in
                            ghostColorSwatch(for: preset)
                        }
                    }
                }

                LabeledContent("Opacity") {
                    HStack(spacing: 10) {
                        TickMarkSlider(
                            value: ghostTextOpacityBinding,
                            range: SuggestionSettingsModel.minimumGhostTextOpacity
                                ... SuggestionSettingsModel.maximumGhostTextOpacity,
                            step: SuggestionSettingsModel.ghostTextOpacityStep
                        )
                        .frame(minWidth: 220, idealWidth: 280, maxWidth: 320)

                        Text(ghostTextOpacityLabel)
                            .font(.callout)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                            .frame(width: 44, alignment: .trailing)
                    }
                }

                LabeledContent("Maximum Size") {
                    HStack(spacing: 10) {
                        TickMarkSlider(
                            value: maximumGhostTextFontSizeBinding,
                            range: SuggestionSettingsModel.minimumGhostTextFontSize
                                ... SuggestionSettingsModel.maximumGhostTextFontSizeLimit,
                            step: SuggestionSettingsModel.ghostTextFontSizeStep
                        )
                        .frame(minWidth: 220, idealWidth: 280, maxWidth: 320)

                        Text(ghostTextFontSizeLabel)
                            .font(.callout)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                            .frame(width: 44, alignment: .trailing)
                    }
                }
            }

            Section("Defaults") {
                LabeledContent {
                    Button {
                        suggestionSettings.resetAppearance()
                    } label: {
                        Label("Restore Defaults", systemImage: "arrow.counterclockwise")
                    }
                    .disabled(!suggestionSettings.hasCustomAppearance)
                } label: {
                    SettingsRowLabel(
                        title: "Appearance Settings",
                        description: "Restore the visual defaults without changing engines, writing preferences, shortcuts, or app rules."
                    )
                }
            }
        }
    }

    private var showIndicatorBinding: Binding<Bool> {
        Binding(
            get: { suggestionSettings.showIndicator },
            set: { suggestionSettings.setShowIndicator($0) }
        )
    }

    private var showAcceptanceHintBinding: Binding<Bool> {
        Binding(
            get: { suggestionSettings.showAcceptanceHint },
            set: { suggestionSettings.setShowAcceptanceHint($0) }
        )
    }

    private var mirrorPreferenceBinding: Binding<MirrorPreference> {
        Binding(
            get: { suggestionSettings.mirrorPreference },
            set: { suggestionSettings.setMirrorPreference($0) }
        )
    }

    private var menuBarWordCountVisibleBinding: Binding<Bool> {
        Binding(
            get: { suggestionSettings.isMenuBarWordCountVisible },
            set: { suggestionSettings.setMenuBarWordCountVisible($0) }
        )
    }

    private var ghostTextOpacityBinding: Binding<Double> {
        Binding(
            get: { suggestionSettings.ghostTextOpacity },
            set: { suggestionSettings.setGhostTextOpacity($0) }
        )
    }

    private var maximumGhostTextFontSizeBinding: Binding<Double> {
        Binding(
            get: { suggestionSettings.maximumGhostTextFontSize },
            set: { suggestionSettings.setMaximumGhostTextFontSize($0) }
        )
    }

    /// Mirrors the overlay's automatic fallback (`GhostSuggestionView.ghostColor`) so the Automatic
    /// swatch previews the same gray the user will actually see.
    private var automaticGhostTextColor: Color {
        colorScheme == .dark
            ? Color(red: 0.65, green: 0.65, blue: 0.65)
            : Color(red: 0.45, green: 0.45, blue: 0.45)
    }

    private var ghostTextOpacityLabel: String {
        "\(Int((suggestionSettings.ghostTextOpacity * 100).rounded()))%"
    }

    private var ghostTextFontSizeLabel: String {
        "\(Int(suggestionSettings.maximumGhostTextFontSize.rounded())) pt"
    }

    private var selectedGhostTextColor: Color {
        if let customColor = SuggestionTextColorCodec.color(
            fromHex: suggestionSettings.customSuggestionTextColorHex
        ) {
            return customColor
        }
        return automaticGhostTextColor
    }

    @ViewBuilder
    private func ghostColorSwatch(for preset: GhostTextColorPreset) -> some View {
        let isSelected = GhostTextColorPreset.matching(
            hex: suggestionSettings.customSuggestionTextColorHex
        ) == preset

        Button {
            suggestionSettings.setCustomSuggestionTextColorHex(preset.hex)
        } label: {
            Circle()
                .fill(swatchFill(for: preset))
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .strokeBorder(
                            Color.primary.opacity(isSelected ? 0.9 : 0.18),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        }
        .buttonStyle(.plain)
        .help(preset.name)
        .accessibilityLabel(preset.name)
        .accessibilityValue(isSelected ? "Selected" : "")
    }

    private func swatchFill(for preset: GhostTextColorPreset) -> Color {
        guard let hex = preset.hex,
              let color = SuggestionTextColorCodec.color(fromHex: hex)
        else {
            return automaticGhostTextColor
        }

        return color
    }
}

/// Visual sample for the Appearance pane.
///
/// It owns no product state: `AppearancePaneView` passes already-resolved values from
/// `SuggestionSettingsModel`, and this view renders a compact sample. Keeping it separate prevents
/// the preview from becoming a second overlay implementation; the real floating window remains
/// owned by `OverlayController`.
private struct SuggestionAppearancePreviewView: View {
    let ghostColor: Color
    let ghostOpacity: Double
    let fontSize: Double
    let keycapLabel: String?
    let showsFieldIndicator: Bool
    let mirrorPreference: MirrorPreference

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.red.opacity(0.78))
                    .frame(width: 8, height: 8)
                Circle()
                    .fill(Color.yellow.opacity(0.78))
                    .frame(width: 8, height: 8)
                Circle()
                    .fill(Color.green.opacity(0.78))
                    .frame(width: 8, height: 8)

                Text("Writing")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)

                Spacer()
            }
            .frame(height: 10)

            VStack(alignment: .leading, spacing: 10) {
                Text("Project brief")
                    .font(.system(size: 13, weight: .semibold))

                Text("The release notes are ready.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)

                suggestionLine

                Text("Review the final details before publishing.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 152, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(nsColor: .textBackgroundColor))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.primary.opacity(0.14), lineWidth: 1)
        }
        .overlay(alignment: .trailing) {
            if showsFieldIndicator {
                FieldIndicatorPreviewIcon()
                    .padding(.trailing, 8)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Suggestion appearance preview")
    }

    @ViewBuilder
    private var suggestionLine: some View {
        if mirrorPreference == .alwaysMirror {
            popupPreview
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            inlineEditorPreview
        }
    }

    private var inlineEditorPreview: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("The launch is")
                .foregroundStyle(.primary)

            Text(" ready for review")
                .foregroundStyle(ghostColor.opacity(ghostOpacity))

            if let keycapLabel {
                SuggestionPreviewKeycap(label: keycapLabel)
                    .padding(.leading, 6)
            }
        }
        .font(.system(size: CGFloat(fontSize)))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var popupPreview: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("ready for review")
                .foregroundStyle(ghostColor.opacity(ghostOpacity))

            if let keycapLabel {
                SuggestionPreviewKeycap(label: keycapLabel)
            }
        }
        .font(.system(size: CGFloat(fontSize)))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.primary.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 5, y: 2)
    }
}

private struct FieldIndicatorPreviewIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color(red: 0.18, green: 0.19, blue: 0.21))

            Image(systemName: "sparkle")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 20, height: 20)
        .fixedSize()
    }
}

private struct SuggestionPreviewKeycap: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.system(size: 10, weight: .medium, design: .rounded))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.primary.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color.primary.opacity(0.18), lineWidth: 1)
            )
            .fixedSize()
    }
}
