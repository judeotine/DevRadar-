import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            Text("DevRadar")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 180))
    }
}

#Preview {
    AppIconView()
        .previewLayout(.fixed(width: 1024, height: 1024))
}

