import SwiftUI

struct UploadView: View {
  var body: some View {
    VStack(spacing: 0) {
      // Logo at the top
      Image("SignAILOGO")
        .resizable()
        .scaledToFit()
        .frame(height: 32)
        .padding(.top, 36)
        .padding(.bottom, 16)
      // Upload prompt
      HStack {
        Text("Click here to upload your video")
          .font(Font.custom("Montserrat", size: 29).weight(.bold))
          .foregroundColor(Color(red: 1, green: 0.48, blue: 0))
        Spacer()
      }
      .padding(.horizontal, 32)
      // Glass container for upload area and nav bar
      GlassEffectContainer(spacing: 40) {
        VStack(spacing: 0) {
          // Upload area with Liquid Glass
          ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
              .fill(
                LinearGradient(gradient: Gradient(colors: [Color(red: 1, green: 0.82, blue: 0.77), Color(red: 1, green: 0.96, blue: 0.78), Color(red: 1, green: 0.79, blue: 0.56)]), startPoint: .topLeading, endPoint: .bottomTrailing)
              )
              .frame(width: 343, height: 343)
              .overlay(
                RoundedRectangle(cornerRadius: 20)
                  .stroke(style: StrokeStyle(lineWidth: 3, dash: [10]))
                  .foregroundColor(Color(red: 1, green: 0.48, blue: 0))
              )
            Image(systemName: "arrow.up.to.line")
              .resizable()
              .scaledToFit()
              .frame(width: 48, height: 48)
              .foregroundColor(Color(red: 1, green: 0.48, blue: 0))
          }
          .padding(.top, 16)
          .glassEffect(.regular, in: .rect(cornerRadius: 20))
          // Choose file button
          Button(action: {}) {
            Text("Choose file")
              .font(Font.custom("Inter", size: 16).weight(.bold))
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .frame(height: 44)
              .background(Color(red: 1, green: 0.48, blue: 0))
              .cornerRadius(22)
          }
          .padding(.horizontal, 65)
          .padding(.top, 28)
          // Helper text
          Text("or click on the coloured area")
            .font(Font.custom("Montserrat", size: 10).weight(.light))
            .foregroundColor(.gray)
            .padding(.top, 8)
        }
        Spacer()
        // Bottom navigation bar with Liquid Glass
        HStack(spacing: 0) {
          Spacer()
          Image(systemName: "gearshape")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundColor(.white)
          Spacer()
          Image(systemName: "house")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundColor(.white)
          Spacer()
          Image(systemName: "person.circle")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundColor(.white)
          Spacer()
        }
        .frame(height: 60)
        .background(Color(red: 1, green: 0.48, blue: 0).opacity(0.85))
        .glassEffect(.regular, in: .rect(cornerRadius: 0))
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
  }
}

struct UploadView_Previews: PreviewProvider {
  static var previews: some View {
    UploadView()
  }
}
