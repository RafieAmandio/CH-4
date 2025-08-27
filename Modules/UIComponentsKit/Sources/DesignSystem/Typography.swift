//
//  Typography.swift
//  UIComponentsKit
//
//  Created by Dwiki on 15/08/25.
//

import SwiftUI

public enum AppFont {
    public static let headingLargest = Font.custom("Urbanist-Bold", size: 40)
    
    public static let headingLargeBold = Font.custom("Urbanist-Bold", size: 30)
    public static let headingLargeSemiBold = Font.custom("Urbanist-SemiBold", size: 30)
    
    public static let headingMediumBold = Font.custom("Urbanist-Bold", size: 25)
                                                      
    public static let headingSmallBold = Font.custom("Urbanist-Bold", size: 20)
    
    public static let bodySmallSemibold = Font.custom("Urbanist-SemiBold", size: 17)
    public static let bodySmallMedium = Font.custom("Urbanist-Medium", size: 17)
    public static let bodySmallRegular = Font.custom("Urbanist-Regular", size: 17)
    public static let bodySmallBold = Font.custom("Urbanist-Bold", size: 18)

    
    
    // Fixed Inter font names - no underscores, no hyphens before weight
    public static let interSmallRegular = Font.custom("Inter28pt-Regular", size: 12)
    public static let interLargeRegular = Font.custom("Inter28pt-Regular", size: 36)

    public static let interSmallMedium = Font.custom("Inter28pt-Medium", size: 12)
    public static let interLargeMedium = Font.custom("Inter28pt-Medium", size: 36)

    public static let interSmallSemiBold = Font.custom("Inter28pt-SemiBold", size: 12)
    public static let interMidSemiBold = Font.custom("Inter28pt-SemiBold", size: 16)
    
    public static let interSmallBold = Font.custom("Inter28pt-Bold", size: 12)
    
    
  
    // card fonts
    public static let cardHead1 = Font.custom("Inter28pt-Bold", size: 24)
    public static let cardHead2 = Font.custom("Inter28pt-Bold", size: 20)
    public static let cardDetail = Font.custom("Inter28pt-Medium", size: 20)
    public static let cardText = Font.custom("Inter28pt-Medium", size: 13)
    public static let cardTap = Font.custom("Urbanist-SemiBold", size: 16)
    
    public static let inter30Bold = Font.custom("Inter28pt-Bold", size: 30)
    public static let inter14Regular = Font.custom("Inter28pt-Regular", size: 14)
    
    
    // WHAT WE ARE CURRENTLY USING!
    // Main Title
    public static let interLargeBold = Font.custom("Inter28pt-Bold", size: 36)
    // Title 1
    public static let interLargeSemiBold = Font.custom("Inter28pt-SemiBold", size: 30)
    // Textbox text
    public static let interMidMedium = Font.custom("Inter28pt-Medium", size: 16)
    // Caption text
    public static let interMidRegular = Font.custom("Inter28pt-Regular", size: 16)
    // List title
    public static let interMidBold = Font.custom("Inter28pt-Bold", size: 16)
    
    
}

