import SwiftUI

// Frosted background view using a blur effect
struct FrostedBackgroundView: View {
    var body: some View {
        BlurView(style: .light) // Reduced frosting effect
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(radius: 10)
            .padding()
    }
}

// Helper view to create a blur effect using UIViewRepresentable
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

// Custom alert view with frosted background and two animated buttons
struct CustomAlertView: View {
    let title: String
    let message: String
    let primaryButtonTitle: String
    let secondaryButtonTitle: String
    let onPrimaryButtonTapped: () -> Void
    let onSecondaryButtonTapped: () -> Void
    let animation: Animation

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top)
                .multilineTextAlignment(.center) // Allow for longer titles
                .frame(maxWidth: .infinity, alignment: .center)

            Text(message)
                .font(.body)
                .foregroundColor(.primary)
                .padding([.leading, .trailing])
                .multilineTextAlignment(.center) // Allow for longer messages

            Divider()
                .background(Color.primary)
                .padding([.leading, .trailing])

            HStack(spacing: 16) {
                Button(action: {
                    withAnimation(.easeInOut) { // Ensure easeInOut animation
                        onPrimaryButtonTapped()
                    }
                }) {
                    Text(primaryButtonTitle)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.clear) // Lower key button
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.primary, lineWidth: 1)
                        )
                }

                Button(action: {
                    withAnimation(.easeInOut) { // Ensure easeInOut animation
                        onSecondaryButtonTapped()
                    }
                }) {
                    Text(secondaryButtonTitle)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.clear) // Lower key button
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.primary, lineWidth: 1)
                        )
                }
            }
            .padding([.leading, .trailing, .bottom])
        }
        .background(FrostedBackgroundView())
        .cornerRadius(16)
        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale.combined(with: .opacity)))
        .padding()
    }
}
// Custom modifier to present the custom alert
struct CustomAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let primaryButtonTitle: String
    let secondaryButtonTitle: String
    let onPrimaryButtonTapped: () -> Void
    let onSecondaryButtonTapped: () -> Void
    let animation: Animation

    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: isPresented ? 2 : 0)
            
            if isPresented {
                CustomAlertView(
                    title: title,
                    message: message,
                    primaryButtonTitle: primaryButtonTitle,
                    secondaryButtonTitle: secondaryButtonTitle,
                    onPrimaryButtonTapped: {
                        withAnimation(.easeInOut) { // Ensure easeInOut animation
                            isPresented = false
                        }
                        onPrimaryButtonTapped()
                    },
                    onSecondaryButtonTapped: {
                        withAnimation(.easeInOut) { // Ensure easeInOut animation
                            isPresented = false
                        }
                        onSecondaryButtonTapped()
                    },
                    animation: animation
                )
            }
        }
    }
}

extension View {
    func customAlert(isPresented: Binding<Bool>, title: String, message: String, primaryButtonTitle: String, secondaryButtonTitle: String, onPrimaryButtonTapped: @escaping () -> Void, onSecondaryButtonTapped: @escaping () -> Void, animation: Animation = .easeInOut(duration: 0.5)) -> some View {
        self.modifier(CustomAlertModifier(isPresented: isPresented, title: title, message: message, primaryButtonTitle: primaryButtonTitle, secondaryButtonTitle: secondaryButtonTitle, onPrimaryButtonTapped: onPrimaryButtonTapped, onSecondaryButtonTapped: onSecondaryButtonTapped, animation: animation))
    }
}

// Sheet view containing the animation logic and custom alert
struct SheetView: View {
    @Binding var showSheet: Bool
    @State private var showAlert = false
    @State private var animate = false

    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    animate = true
                }
                // Delay the presentation of the alert until the animation is complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showAlert = true
                }
            }) {
                Text("Show Alert")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            // Example views to demonstrate the animation
            Rectangle()
                .fill(animate ? Color.blue : Color.gray)
                .frame(width: animate ? 200 : 100, height: animate ? 200 : 100)
                .animation(.easeInOut(duration: 0.5), value: animate) // Explicit animation with value binding
            
            Text(animate ? "Animating..." : "Static")
                .foregroundColor(animate ? .blue : .gray)
                .animation(.easeInOut(duration: 0.5), value: animate) // Explicit animation with value binding
        }
        .customAlert(isPresented: $showAlert, title: "This is a much longer alert title spanning two lines", message: "This is a much longer message that explains the details of the alert. It should also handle multiline text and be displayed in a readable format without any layout issues.", primaryButtonTitle: "Dismiss to Sheet", secondaryButtonTitle: "Dismiss to Main", onPrimaryButtonTapped: {
            showAlert = false
        }, onSecondaryButtonTapped: {
            showAlert = false
            showSheet = false
        }, animation: .spring())
    }
}

// Main view presenting the sheet
struct MainView: View {
    @State private var showSheet = false

    var body: some View {
        VStack {
            Button(action: {
                showSheet = true
            }) {
                Text("Present Sheet")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .sheet(isPresented: $showSheet) {
            SheetView(showSheet: $showSheet)
        }
    }
}

// Entry point of the app
@main
struct CustomAlertApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

#Preview {
  MainView()
}

