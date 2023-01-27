//
//  SettingsViewController.swift
//  Star Party
//
//  Created by Dakota Havel on 1/26/23.
//

// import SwiftUI
// import UIKit
//
//// MARK: - SettingsViewController
//
// class SettingsViewController: UIViewController {
//    override func viewDidLoad() {
//
//    }
// }
//
//// MARK: - SettingsViewControllerRepresentation
//
// struct SettingsViewControllerRepresentation: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> SettingsViewController {
//        return SettingsViewController()
//    }
//
//    func updateUIViewController(_ uiViewController: SettingsViewController, context: Context) {
//    }
//
//    typealias UIViewControllerType = SettingsViewController
// }
//
//// MARK: - SettingsViewController_Preview
//
// struct SettingsViewController_Preview: PreviewProvider {
//    static var previews: some View {
//        Color(UIColor.systemBackground)
//            .sheet(isPresented: .constant(true)) {
//                SettingsViewControllerRepresentation().ignoresSafeArea()
//            }
//    }
// }

import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {
    @AppStorage(UserSettingsKeys.kApodApi) var nasaKey: String = "DEMO_KEY"

    var body: some View {
        VStack(alignment: .leading) {
            Text("Settings").font(.title)
            Form {
                Section(header: Text("API Keys")) {
                    VStack(spacing: 6) {
                        HStack {
                            Text("Nasa Open API")
                            Spacer()
                            Text("[Link](https://api.nasa.gov/)")
                        }

                        Text("APOD Viewer relies on NASA's open API, without this set it uses DEMO_KEY \n\nDEMO_KEY limits: \n 30 requests per hour \n 50 requests per day \n\nWith Key:\n 1,000 requests per hour")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    VStack(spacing: 0) {
                        TextField("Nasa Key", text: $nasaKey)
                            .modifier(TextFieldClearButton(text: $nasaKey))
                            .background(Color.gray.opacity(0.1))

                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray).opacity(1)
                    }
                }

//                Section(header: Text("Onboarding")) {
//
//                }
            }
            .cornerRadius(16)
        }
        .padding()
    }
}

// MARK: - SettingsView_Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
