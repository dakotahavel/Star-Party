//
//  SwiftUIExtensions.swift
//  Star Party
//
//  Created by Dakota Havel on 1/27/23.
//

import SwiftUI

extension View {
    func asHosted() -> UIHostingController<Self> {
        return UIHostingController(rootView: self)
    }
}
