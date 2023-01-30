//
//  OnboardingView.swift
//  Star Party
//
//  Created by Dakota Havel on 1/27/23.
//

import SwiftUI

// MARK: - OnboardingView

struct OnboardingView: View, NavigationHostable {
    var navigationHost: UINavigationController?

    @AppStorage(UserSettingsKeys.kSkipOnboarding) var skipOnboarding: Bool = false

    let welcomeText: String =
        """
        Welcome to my demo app, Star Party, which is currently just a glorified NASA Astronomy Picture of the Day (APOD) viewer.

        The main purpose is to show my knowledge and desire for doing iOS development. The app is a mixture of programmatic UIKit and SwiftUI, as I would expect existing apps to be at this time. SwiftUI is mostly used for simple views like this one and the settings view, and UIKit everywhere else.

        Whats Here:
            Programmatic UIKit mixed with SwiftUI
            UICollectionView - Compositional Layout
            URLSession cancellable tasks for smooth scrolling

        Whats Coming:
            CoreData - reduce network usage, better sorting and filtering of APODs
            CollectionView layout choice - grid view or whole image list

        """

    let setupKeysText: String = "I have avoided building my own server in this project to stay focused on iOS instead, the downside to that is the need for heavy users to input their own API keys for public services I'm using. These can be set in the settings screen at any time."

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                VStack {
                    Text("Hi, I'm Dakota").font(.title)
                        .padding()
                    VStack(alignment: .leading) {
                        Text(welcomeText)
                    }
                }

                Text("""

                """)

                VStack(alignment: .leading) {
                    Text(setupKeysText)
                    HStack {
                        Button("Take me there") {
                            let home = ImagesCollectionViewController()
                            navigationHost?.setViewControllers([TodaysApodViewController(), home], animated: true)
                            home.perform(#selector(home.showSettings))
                            UserSettingsManager.setSkipOnboarding(true)
                        }
                        Spacer()
                        Button("Continue with demo key") {
                            navigationHost?.setViewControllers([TodaysApodViewController()], animated: true)
                            UserSettingsManager.setSkipOnboarding(true)
                        }
                    }
                    .padding()
                }
            }.padding(EdgeInsets(top: 0, leading: 16, bottom: 24, trailing: 16))
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            if let navigationHost {
                navigationHost.navigationBar.isHidden = true
            }
        }
        .onDisappear {
            if let navigationHost {
                navigationHost.navigationBar.isHidden = false
            }
        }
    }
}

// MARK: - OnboardingView_Previews

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
