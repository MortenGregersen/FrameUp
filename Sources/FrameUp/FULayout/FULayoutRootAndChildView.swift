//
//  FULayoutRootAndChildView.swift
//  FrameUp
//
//  Created by Ryan Lintott on 2022-07-18.
//

import SwiftUI

public struct FULayoutSizeKey: PreferenceKey {
    public typealias Value = [Int: CGSize]
    public static let defaultValue: [Int: CGSize] = [:]
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        nextValue().forEach {
            value.updateValue($0.value, forKey: $0.key)
        }
    }
}

/// This generalization doesn't work for some reason
internal struct AnyFULayoutRootView<Content: View>: View {
    let layout: AnyFULayout
    @Binding var contentOffsets: [Int: CGPoint]
    @Binding var frameSize: CGSize?
    let content: Content

    init(_ layout: AnyFULayout, contentOffsets: Binding<[Int: CGPoint]>, frameSize: Binding<CGSize?>, content: () -> Content) {
        self.layout = layout
        self._contentOffsets = contentOffsets
        self._frameSize = frameSize
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            content
        }
        .frame(frameSize, alignment: .topLeading)
        .fixedSize()
        .onPreferenceChange(FULayoutSizeKey.self) {
            self.contentOffsets = layout.contentOffsets(sizes: $0)
            self.frameSize = layout.rect(contentOffsets: contentOffsets, sizes: $0).size
        }
        .id(layout.id)
    }
}

internal struct AnyFULayoutChildView<Content: View>: View {
    let layout: AnyFULayout
    let index: Int
    let contentOffsets: [Int: CGPoint]
    let content: Content
    
    var contentOffset: CGPoint? {
        contentOffsets[index]
    }
    var isInvisible: Bool { contentOffset == nil }
    
    var defaultOffset: CGPoint {
        /// Ensures content is placed inside the frame of existing content
        contentOffsets.first?.value ?? .zero
    }
    
    var body: some View {
        content
            .overlay(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: FULayoutSizeKey.self, value: [index: proxy.size])
                }
            )
            .fixedSize(
                horizontal: layout.fixedSize.contains(.horizontal),
                vertical: layout.fixedSize.contains(.vertical)
            )
            .frame(
                maxWidth: layout.maxItemWidth,
                maxHeight: layout.maxItemHeight,
                alignment: .topLeading
            )
            .alignmentGuide(.leading) { d in
                -(contentOffset ?? defaultOffset).x
            }
            .alignmentGuide(.top) { d in
                -(contentOffset ?? defaultOffset).y
            }
            /// These modifiers are used to ensure initial content sizing uses an invisible view that won't effect the overall frame. Once the offset is known it will appear with the correct placement.
            .fixedSize(horizontal: isInvisible, vertical: isInvisible)
            .frame(width: isInvisible ? .zero : nil, height: isInvisible ? .zero : nil)
            .opacity(isInvisible ? 0 : 1)
            .id(isInvisible ? UUID() : layout.id)
    }
}
