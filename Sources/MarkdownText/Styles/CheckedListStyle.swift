import SwiftUI

public protocol ChecklistMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = CheckListItemMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyCheckListItemMarkdownStyle: ChecklistMarkdownStyle {
    var label: (CheckListItemMarkdownConfiguration) -> AnyView
    init<S: ChecklistMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct CheckListItemMarkdownConfiguration {
    public let level: Int
    public let bullet: ChecklistBulletMarkdownConfiguration
    public let paragraph: ParagraphMarkdownConfiguration

    struct Label: View {
        @Backport.ScaledMetric private var reservedWidth: CGFloat = 25
        @Environment(\.markdownParagraphStyle) private var paragraphStyle
        @Environment(\.markdownChecklistBulletStyle) private var bulletStyle

        public let level: Int
        public let bullet: ChecklistBulletMarkdownConfiguration
        public let paragraph: ParagraphMarkdownConfiguration

        private var space: String {
            Array(repeating: "    ", count: level).joined()
        }

        var body: some View {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(space)

                Backport.Label {
                    paragraphStyle.makeBody(configuration: paragraph)
                } icon: {
                    bulletStyle.makeBody(configuration: bullet)
                        .frame(minWidth: reservedWidth)
                }
            }
        }
    }

    public var label: some View {
        Label(level: level, bullet: bullet, paragraph: paragraph)
    }
}

public struct DefaultChecklistMarkdownStyle: ChecklistMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension ChecklistMarkdownStyle where Self == DefaultChecklistMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct CheckListItemMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyCheckListItemMarkdownStyle(.default)
}

public extension EnvironmentValues {
    var markdownCheckListItemStyle: AnyCheckListItemMarkdownStyle {
        get { self[CheckListItemMarkdownEnvironmentKey.self] }
        set { self[CheckListItemMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownCheckListItemStyle<S>(_ style: S) -> some View where S: ChecklistMarkdownStyle {
        environment(\.markdownCheckListItemStyle, AnyCheckListItemMarkdownStyle(style))
    }
}
