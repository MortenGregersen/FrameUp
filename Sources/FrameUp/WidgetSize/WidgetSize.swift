//
//  File.swift
//  
//
//  Created by Ryan Lintott on 2021-09-17.
//

import SwiftUI

public enum WidgetSize: String, Identifiable {
    case small
    case medium
    case large
    case extraLarge
    
    public var id: String {
        self.rawValue
    }
}

public enum WidgetTarget {
    case designCanvas, homeScreen
}

extension WidgetSize {
    public static var supportedSizesForCurrentDevice: [WidgetSize] {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            if #available(iOS 15.0, *) {
                return [.small, .medium, .large, .extraLarge]
            } else {
                fallthrough
            }
        case .phone:
            return [.small, .medium, .large]
        default:
            return []
        }
    }
    
    /// Smallest widget size possibe for each WidgetFamily
    public static let minimumSizes: [WidgetSize: CGSize] = [
            .small: CGSize(width: 141, height: 141),
            .medium: CGSize(width: 292, height: 141),
            .large: CGSize(width: 292, height: 311),
            .extraLarge: CGSize(width: 540, height: 260)
        ]
    
    public static func sizesForiPhone(screenSize: CGSize) -> [WidgetSize: CGSize] {
        let widgetSizes: ((CGFloat, CGFloat), (CGFloat, CGFloat), (CGFloat, CGFloat))
        
        // source: https://developer.apple.com/design/human-interface-guidelines/widgets/overview/design/
        switch (screenSize.width, screenSize.height) {
        case (428, 926), (428..., _):       widgetSizes = ((170, 170), (364, 170), (364, 382))
        case (414, 896):                    widgetSizes = ((169, 169), (360, 169), (360, 379))
        case (414, 736), (414..., _):       widgetSizes = ((159, 159), (348, 159), (348, 357))
        case (390, 844), (390..., _):       widgetSizes = ((158, 158), (338, 158), (338, 354))
        case (375, 812):                    widgetSizes = ((155, 155), (329, 155), (329, 345))
        case (375, 667), (390..., _):       widgetSizes = ((148, 148), (321, 148), (321, 324))
        case (360, 780), (390..., _):       widgetSizes = ((155, 155), (329, 155), (329, 345))
        case (320, 568), (320..., _):       widgetSizes = ((141, 141), (292, 141), (292, 311))
            
        default: widgetSizes = ((141, 141), (292, 141), (292, 311))
        }
        
        return [
            .small: CGSize(width: widgetSizes.0.0, height: widgetSizes.0.1),
            .medium: CGSize(width: widgetSizes.1.0, height: widgetSizes.1.1),
            .large: CGSize(width: widgetSizes.2.0, height: widgetSizes.2.1)
        ]
    }

    public static func sizesForiPad(screenSize: CGSize, target: WidgetTarget) -> [WidgetSize: CGSize] {
        let widgetSizes: ((CGFloat, CGFloat), (CGFloat, CGFloat), (CGFloat, CGFloat), (CGFloat, CGFloat))
        
        // source: https://developer.apple.com/design/human-interface-guidelines/widgets/overview/design/
        switch target {
        case .designCanvas:
            switch (screenSize.width, screenSize.height) {
            case (1024, 1366), (1024..., _):    widgetSizes = ((170, 170), (378.5, 170), (378.5, 378.5), (795, 378.5))
            case (834, 1194):                   widgetSizes = ((155, 155), (342, 155), (342, 342), (715.5, 342))
            case (834, 1112), (834..., _):      widgetSizes = ((150, 150), (327.5, 150), (327.5, 327.5), (682, 327.5))
            case (820, 1180), (820..., _):      widgetSizes = ((155, 155), (342, 155), (342, 342), (715.5, 342))
            case (810, 1080), (810..., _):      widgetSizes = ((146, 146), (320.5, 146), (320.5, 320.5), (669, 320.5))
            case (768, 1024), (768..., _):      widgetSizes = ((141, 141), (305.5, 141), (305.5, 305.5), (634.5, 305.5))
                
            default: widgetSizes = ((141, 141), (305.5, 141), (305.5, 305.5), (634.5, 305.5))
            }
        case .homeScreen:
            switch (screenSize.width, screenSize.height) {
            case (1024, 1366), (1024..., _):    widgetSizes = ((160, 160), (356, 160), (356, 356), (748, 356))
            case (834, 1194):                   widgetSizes = ((136, 136), (300, 136), (300, 300), (628, 300))
            case (834, 1112), (834..., _):      widgetSizes = ((132, 132), (288, 132), (288, 28 ), (600, 288))
            case (820, 1180), (820..., _):      widgetSizes = ((136, 136), (300, 136), (300, 300), (628, 300))
            case (810, 1080), (810..., _):      widgetSizes = ((124, 124), (272, 124), (272, 272), (568, 272))
            case (768, 1024), (768..., _):      widgetSizes = ((120, 120), (260, 120), (260, 260), (540, 260))
                
            default: widgetSizes = ((120, 120), (260, 120), (260, 260), (540, 260))
            }
        }
        
        return [
            .small: CGSize(width: widgetSizes.0.0, height: widgetSizes.0.1),
            .medium: CGSize(width: widgetSizes.1.0, height: widgetSizes.1.1),
            .large: CGSize(width: widgetSizes.2.0, height: widgetSizes.2.1),
            .extraLarge: CGSize(width: widgetSizes.3.0, height: widgetSizes.3.1)
        ]
    }
    
    public var minimumSize: CGSize {
        Self.minimumSizes[self] ?? .zero
    }
    
    public func sizeForiPhone(screenSize: CGSize) -> CGSize {
        Self.sizesForiPhone(screenSize: screenSize)[self] ?? .zero
    }
    
    public func sizeForiPad(screenSize: CGSize, target: WidgetTarget) -> CGSize {
        Self.sizesForiPad(screenSize: screenSize, target: target)[self] ?? .zero
    }
    
    public func sizeForCurrentDevice(iPadTarget: WidgetTarget = .designCanvas) -> CGSize {
        let screenSize = UIScreen.main.bounds.size
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return sizeForiPad(screenSize: screenSize, target: iPadTarget)
        case .phone:
            return sizeForiPhone(screenSize: screenSize)
        default:
            return .zero
        }
    }
}

