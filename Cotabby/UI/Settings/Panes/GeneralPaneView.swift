import SwiftUI

/// File overview:
/// "General" detail pane of the redesigned Settings window. Groups app-wide status, launch
/// behavior, and non-visual suggestion behavior into macOS-native grouped form sections.
/// Visual controls live in `AppearancePaneView`; keeping them out of General prevents two panes
/// from competing to explain the same display state.
struct GeneralPaneView: View {
    @ObservedObject var suggestionSettings: SuggestionSettingsModel
    @ObservedObject var launchAtLoginService: LaunchAtLoginService
    let onShowWelcome: () -> Void
    let clearEmojiHistory: () -> Void

    var body: some View {
        SettingsPaneScaffold {
            if let supportURL = ProductIdentity.supportURL {
                Section {
                    HStack(spacing: 12) {
                        Text("Enjoying \(ProductIdentity.displayName)?")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                        Link(destination: supportURL) {
                            HStack(spacing: 5) {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.pink)
                                Text("Support")
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                            .foregroundStyle(Color.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .listRowBackground(Color.blue)
                }
            }

            Section("Status") {
                Toggle(isOn: globallyEnabledBinding) {
                    SettingsRowLabel(
                        title: "Enable Globally",
                        description: "Turn \(ProductIdentity.displayName) off everywhere without quitting the app."
                    )
                }

                Toggle(isOn: fastModeEnabledBinding) {
                    SettingsRowLabel(
                        title: "Fast Mode",
                        description: "Skip the screenshot-based context step for faster suggestions. " +
                            "Suggestions rely only on the text you've typed."
                    )
                }

                Toggle(isOn: launchAtLoginBinding) {
                    SettingsRowLabel(
                        title: "Open at Login",
                        description: launchAtLoginDescription
                    )
                }
                // Disabled only when macOS reports the login item as unavailable (e.g. the app isn't
                // in /Applications); the description then explains how to fix it.
                .disabled(!launchAtLoginService.state.canToggle)
            }

            Section("Behavior") {
                Toggle(isOn: clipboardContextEnabledBinding) {
                    SettingsRowLabel(
                        title: "Include Clipboard Context",
                        description: "Let suggestions reference whatever you most recently copied."
                    )
                }

                Toggle(isOn: multiLineEnabledBinding) {
                    SettingsRowLabel(
                        title: "Allow Multi-line Suggestions",
                        description: "Allow continuations that span more than one line. Off keeps suggestions to a single line."
                    )
                }

                Toggle(isOn: autoAcceptTrailingPunctuationBinding) {
                    SettingsRowLabel(
                        title: "Accept Punctuation With Word",
                        description: "When you accept a word, also accept the punctuation that follows it " +
                            "(commas, periods) so you don't have to type it."
                    )
                }

                Toggle(isOn: emojiPickerEnabledBinding) {
                    SettingsRowLabel(
                        title: "Inline Emoji Picker",
                        description: "Type a name like :smile to search inline, then press your accept-word " +
                            "shortcut to insert the selected emoji."
                    )
                }
            }

            if suggestionSettings.isEmojiPickerEnabled {
                Section("Emoji Suggestions") {
                    LabeledContent {
                        HStack(spacing: 8) {
                            ForEach(EmojiSkinTone.allCases, id: \.self) { tone in
                                skinToneOption(for: tone)
                            }
                        }
                    } label: {
                        SettingsRowLabel(
                            title: "Skin Tone",
                            description: "For non-default tones, suggestions show your selected tone first " +
                                "and keep the default emoji next."
                        )
                    }

                    LabeledContent {
                        HStack(spacing: 8) {
                            ForEach(EmojiGender.allCases, id: \.self) { gender in
                                emojiGenderOption(for: gender)
                            }
                        }
                    } label: {
                        SettingsRowLabel(
                            title: "People Emoji Style",
                            description: "Choose person, man, or woman variants when an emoji offers them."
                        )
                    }

                    LabeledContent {
                        Button("Clear History") {
                            clearEmojiHistory()
                        }
                    } label: {
                        SettingsRowLabel(
                            title: "Emoji History",
                            description: "Forget recently and frequently used emoji so the picker ranks from scratch."
                        )
                    }
                }
            }

            Section("Help") {
                LabeledContent("Onboarding") {
                    Button("Open Welcome Guide") {
                        onShowWelcome()
                    }
                }
            }
        }
    }

    // MARK: - Bindings

    private var globallyEnabledBinding: Binding<Bool> {
        Binding(
            get: { suggestionSettings.isGloballyEnabled },
            set: { suggestionSettings.setGloballyEnabled($0) }
        )
    }

    private var multiLineEnabledBinding: Binding<Bool> {
        Binding(
            get: { suggestionSettings.isMultiLineEnabled },
            set: { suggestionSettings.setMultiLineEnabled($0) }
        )
    }

    private var emojiPickerEnabledBinding: Binding<Bool> {
        Binding(
            get: { suggestionSettings.isEmojiPickerEnabled },
            set: { suggestionSettings.setEmojiPickerEnabled($0) }
        )
    }

    private var autoAcceptTrailingPunctuationBinding: Binding<Bool> {
        Binding(
            get: { suggestionSettings.autoAcceptTrailingPunctuation },
            set: { suggestionSettings.setAutoAcceptTrailingPunctuation($0) }
        )
    }

    private var clipboardContextEnabledBinding: Binding<Bool> {
        Binding(
            get: { suggestionSettings.isClipboardContextEnabled },
            set: { suggestionSettings.setClipboardContextEnabled($0) }
        )
    }

    private var fastModeEnabledBinding: Binding<Bool> {
        Binding(
            get: { suggestionSettings.isFastModeEnabled },
            set: { suggestionSettings.setFastModeEnabled($0) }
        )
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { launchAtLoginService.state.isEnabled },
            set: { launchAtLoginService.setEnabled($0) }
        )
    }

    /// An enabled login item has nothing to explain, so never surface a leftover detail/error string
    /// under a working toggle. Otherwise prefer the OS-provided status detail (approval needed / move
    /// to Applications), then any registration error from the most recent toggle attempt, falling back
    /// to the plain explanation — so the row reflects real login-item state, not just the switch.
    private var launchAtLoginDescription: String {
        if launchAtLoginService.state.isEnabled {
            return "Start \(ProductIdentity.displayName) automatically when you log in to your Mac."
        }
        return launchAtLoginService.state.detail
            ?? launchAtLoginService.lastErrorMessage
            ?? "Start \(ProductIdentity.displayName) automatically when you log in to your Mac."
    }

    @ViewBuilder
    private func skinToneOption(for tone: EmojiSkinTone) -> some View {
        let isSelected = suggestionSettings.preferredEmojiSkinTone == tone

        Button {
            suggestionSettings.setPreferredEmojiSkinTone(tone)
        } label: {
            ZStack(alignment: .bottomTrailing) {
                Text(tone.sampleGlyph)
                    .font(.system(size: 19))
                    .frame(width: 34, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(isSelected ? Color.accentColor.opacity(0.16) : Color.primary.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .strokeBorder(
                                isSelected ? Color.accentColor : Color.primary.opacity(0.16),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                        .background(Circle().fill(Color(nsColor: .controlBackgroundColor)))
                        .offset(x: 3, y: 3)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
        .buttonStyle(.plain)
        .help("\(tone.displayName) skin tone")
        .accessibilityLabel("\(tone.displayName) skin tone")
        .accessibilityValue(isSelected ? "Selected" : "")
    }

    @ViewBuilder
    private func emojiGenderOption(for gender: EmojiGender) -> some View {
        let isSelected = suggestionSettings.preferredEmojiGender == gender

        Button {
            suggestionSettings.setPreferredEmojiGender(gender)
        } label: {
            ZStack(alignment: .bottomTrailing) {
                Text(gender.sampleGlyph)
                    .font(.system(size: 19))
                    .frame(width: 34, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(isSelected ? Color.accentColor.opacity(0.16) : Color.primary.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .strokeBorder(
                                isSelected ? Color.accentColor : Color.primary.opacity(0.16),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                        .background(Circle().fill(Color(nsColor: .controlBackgroundColor)))
                        .offset(x: 3, y: 3)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
        .buttonStyle(.plain)
        .help("\(gender.displayName) variant")
        .accessibilityLabel("\(gender.displayName) variant")
        .accessibilityValue(isSelected ? "Selected" : "")
    }

}
