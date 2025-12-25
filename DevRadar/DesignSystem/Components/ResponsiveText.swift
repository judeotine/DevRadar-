import SwiftUI

extension View {
    func responsiveText() -> some View {
        self
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}

