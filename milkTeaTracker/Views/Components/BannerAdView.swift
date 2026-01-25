//
//  BannerAdView.swift
//  milkTeaTracker
//
//  SwiftUI wrapper for Google AdMob banner ads.
//

import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

/// SwiftUI view that displays a Google AdMob banner ad
struct BannerAdView: View {
    let adUnitID: String
    
    @State private var adHeight: CGFloat = 50
    @State private var isAdLoaded = false
    
    init(adUnitID: String = AuthConfig.currentBannerAdUnitID) {
        self.adUnitID = adUnitID
    }
    
    var body: some View {
        Group {
            #if canImport(GoogleMobileAds)
            if AdManager.shared.shouldShowAds() {
                GeometryReader { geometry in
                    if geometry.size.width > 0 {
                        BannerAdViewRepresentable(
                            adUnitID: adUnitID,
                            containerWidth: geometry.size.width,
                            adHeight: $adHeight,
                            isAdLoaded: $isAdLoaded
                        )
                        .onAppear {
                            print("[BannerAdView] Appearing with width: \(geometry.size.width), adUnitID: \(adUnitID)")
                        }
                    }
                }
                .frame(height: isAdLoaded ? adHeight : 60)
                .frame(maxWidth: .infinity)
                .opacity(isAdLoaded ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: isAdLoaded)
            }
            #else
            // Placeholder when SDK is not available (for previews/simulators)
            if FeatureFlags.showAds {
                placeholderAd
            }
            #endif
        }
    }
    
    private var placeholderAd: some View {
        HStack {
            Spacer()
            VStack(spacing: 4) {
                Text("Ad Placeholder")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("(GoogleMobileAds SDK not installed)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
        }
        .frame(height: 50)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#if canImport(GoogleMobileAds)
/// UIViewRepresentable wrapper for BannerView (formerly GADBannerView)
@MainActor
struct BannerAdViewRepresentable: UIViewRepresentable {
    let adUnitID: String
    let containerWidth: CGFloat
    @Binding var adHeight: CGFloat
    @Binding var isAdLoaded: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIView {
        print("[BannerAd] makeUIView called with containerWidth: \(containerWidth)")
        
        // Create a container view
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        // Create the banner view with proper size
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.delegate = context.coordinator
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Get the root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootViewController
            print("[BannerAd] rootViewController set successfully")
        } else {
            print("[BannerAd] Warning: No rootViewController available")
        }
        
        containerView.addSubview(bannerView)
        
        // Center the banner in the container
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        // Store reference to banner view in coordinator
        context.coordinator.bannerView = bannerView
        
        // Load the ad immediately since we have the width
        let request = Request()
        bannerView.load(request)
        print("[BannerAd] Ad request sent with adUnitID: \(adUnitID)")
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No need to do anything here - ad is loaded in makeUIView
    }
    
    class Coordinator: NSObject, BannerViewDelegate {
        let parent: BannerAdViewRepresentable
        var bannerView: BannerView?
        
        init(_ parent: BannerAdViewRepresentable) {
            self.parent = parent
        }
        
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("[BannerAd] Ad received successfully, size: \(bannerView.adSize.size)")
            Task { @MainActor in
                self.parent.adHeight = bannerView.adSize.size.height
                self.parent.isAdLoaded = true
            }
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("[BannerAd] Failed to receive ad: \(error.localizedDescription)")
            Task { @MainActor in
                self.parent.isAdLoaded = false
            }
        }
        
        func bannerViewWillPresentScreen(_ bannerView: BannerView) {
            print("[BannerAd] Will present screen")
        }
        
        func bannerViewWillDismissScreen(_ bannerView: BannerView) {
            print("[BannerAd] Will dismiss screen")
        }
        
        func bannerViewDidDismissScreen(_ bannerView: BannerView) {
            print("[BannerAd] Did dismiss screen")
        }
    }
}
#endif

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        Text("Content above ad")
        BannerAdView()
        Text("Content below ad")
    }
    .padding()
}
