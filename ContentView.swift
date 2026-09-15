import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var pipManager: PiPManager
    @State private var provider: NavigationProvider = .waze

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.035, green: 0.055, blue: 0.09), Color(red: 0.02, green: 0.025, blue: 0.045)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 7) {
                    Text("DRIVEDASH")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .tracking(2.4)
                        .foregroundStyle(.cyan)
                    Text("Native PiP Test")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("First prove that a native Picture-in-Picture window can stay above real navigation.")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.62))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                Picker("Navigation", selection: $provider) {
                    ForEach(NavigationProvider.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)

                PiPPlayerHost()
                    .environmentObject(pipManager)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.12), lineWidth: 1)
                    }
                    .padding(.horizontal, 24)

                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(pipManager.isPictureInPictureActive ? Color.green : Color.orange)
                            .frame(width: 8, height: 8)
                        Text(pipManager.statusMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.75))
                    }

                    Button {
                        pipManager.startDrive(using: provider)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "car.fill")
                            Text("Start Drive")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.cyan)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 24)
                    .disabled(!pipManager.isReady)
                }

                Spacer(minLength: 8)

                Text("Prototype only — no MyGarage integration yet.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.38))
                    .padding(.bottom, 8)
            }
            .padding(.top, 28)
        }
    }
}
