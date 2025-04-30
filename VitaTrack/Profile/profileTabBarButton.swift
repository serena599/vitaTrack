import SwiftUI

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    var useGreenFill: Bool = false

    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(isSelected || useGreenFill ? .foodPrimary : .foodGray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
    }
}
