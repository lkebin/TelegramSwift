//
//  ChatPresentationUtils.swift
//  Telegram
//
//  Created by keepcoder on 23/12/2017.
//  Copyright © 2017 Telegram. All rights reserved.
//

import Cocoa
import TGUIKit
import TelegramCoreMac
import SwiftSignalKitMac
import PostboxMac

final class ChatMediaPresentation : Equatable {
    
    private let isIncoming: Bool
    private let isBubble: Bool
    
    let activityBackground: NSColor
    let activityForeground: NSColor
    let waveformBackground: NSColor
    let waveformForeground: NSColor
    let text: NSColor
    let grayText: NSColor
    let link: NSColor
    
    init(isIncoming: Bool, isBubble: Bool, activityBackground: NSColor, activityForeground: NSColor, text: NSColor, grayText: NSColor, link: NSColor, waveformBackground: NSColor, waveformForeground: NSColor) {
        self.isIncoming = isIncoming
        self.isBubble = isBubble
        self.activityForeground = activityForeground
        self.activityBackground = activityBackground
        self.text = text
        self.grayText = grayText
        self.link = link
        self.waveformBackground = waveformBackground
        self.waveformForeground = waveformForeground
    }
    
    static func make(for message: Message, account: Account, renderType: ChatItemRenderType) -> ChatMediaPresentation {
        let isIncoming: Bool = message.isIncoming(account, renderType == .bubble)
        return ChatMediaPresentation(isIncoming: isIncoming,
                                     isBubble: renderType == .bubble,
                                     activityBackground: theme.chat.activityBackground(isIncoming, renderType == .bubble),
                                     activityForeground: theme.chat.activityForeground(isIncoming, renderType == .bubble),
                                     text: theme.chat.textColor(isIncoming, renderType == .bubble),
                                     grayText: theme.chat.grayText(isIncoming, renderType == .bubble),
                                     link: theme.chat.linkColor(isIncoming, renderType == .bubble),
                                     waveformBackground: theme.chat.waveformBackground(isIncoming, renderType == .bubble),
                                     waveformForeground: theme.chat.waveformForeground(isIncoming, renderType == .bubble))
    }
    
    var fileThumb: CGImage {
        if isBubble {
            return isIncoming ? theme.icons.chatFileThumbBubble_incoming : theme.icons.chatFileThumbBubble_outgoing
        } else {
            return theme.icons.chatFileThumb
        }
    }
    
    
    var pauseThumb: CGImage {
        if isBubble {
            return isIncoming ? theme.icons.chatMusicPauseBubble_incoming : theme.icons.chatMusicPauseBubble_outgoing
        } else {
            return theme.icons.chatMusicPause
        }
    }
    var playThumb: CGImage {
        if isBubble {
            return isIncoming ? theme.icons.chatMusicPlayBubble_incoming : theme.icons.chatMusicPlayBubble_outgoing
        } else {
            return theme.icons.chatMusicPlay
        }
    }
    
    static var Empty: ChatMediaPresentation {
        return ChatMediaPresentation(isIncoming: false, isBubble: false, activityBackground: theme.colors.blueFill, activityForeground: .white, text: theme.colors.text, grayText: theme.colors.grayText, link: theme.colors.link, waveformBackground: theme.colors.waveformBackground, waveformForeground: theme.colors.waveformForeground)
    }
    
    static func ==(lhs: ChatMediaPresentation, rhs: ChatMediaPresentation) -> Bool {
        return lhs === rhs
    }
}

private func generatePercentageImage(color: NSColor, value: Int, font: NSFont) -> CGImage {
    return generateImage(CGSize(width: 36.0, height: 16.0), rotatedContext: { size, context in
    
        
        context.clear(CGRect(origin: CGPoint(), size: size))
        
        
        let layout = TextViewLayout(.initialize(string: "\(value)%", color: color, font: font), maximumNumberOfLines: 1, alignment: .right)
        layout.measure(width: size.width)
        if !layout.lines.isEmpty {
            let line = layout.lines[0]
            context.textMatrix = CGAffineTransform(scaleX: 1.0, y: -1.0)
            let penOffset = CGFloat( CTLineGetPenOffsetForFlush(line.line, layout.penFlush, Double(size.width))) + line.frame.minX
            
            context.setAllowsAntialiasing(true)
            context.setShouldAntialias(true)
            context.setShouldSmoothFonts(false)
            context.setAllowsFontSmoothing(false)
            
            context.textPosition = CGPoint(x: penOffset, y: line.frame.minY)

            CTLineDraw(line.line, context)
        }
        
    })!
}


struct TelegramChatColors {
    
    private let generatedPercentageAnimationImages:[CGImage]
    
    private let generatedPercentageAnimationImagesIncomingBubbled:[CGImage]
    private let generatedPercentageAnimationImagesOutgoingBubbled:[CGImage]
    
    private let generatedPercentageAnimationImagesPlain:[CGImage]
    
    private let generatedPercentageAnimationImagesIncomingBubbledPlain:[CGImage]
    private let generatedPercentageAnimationImagesOutgoingBubbledPlain:[CGImage]
    
    private let palette: ColorPalette
    init(_ palette: ColorPalette, _ bubbled: Bool) {
        self.palette = palette
        
        
        var images:[CGImage] = []
        for i in 0 ... 100 {
            images.append(generatePercentageImage(color: palette.textBubble_incoming, value: i, font: .bold(12)))
        }
        self.generatedPercentageAnimationImagesIncomingBubbled = images
       
        images.removeAll()
        for i in 0 ... 100 {
            images.append(generatePercentageImage(color: palette.textBubble_outgoing, value: i, font: .bold(12)))
        }
        self.generatedPercentageAnimationImagesOutgoingBubbled = images
        
        images.removeAll()
        for i in 0 ... 100 {
            images.append(generatePercentageImage(color: palette.text, value: i, font: .bold(12)))
        }
        self.generatedPercentageAnimationImages = images
         images.removeAll()
        
        for i in 0 ... 100 {
            images.append(generatePercentageImage(color: palette.textBubble_incoming, value: i, font: .normal(12)))
        }
        self.generatedPercentageAnimationImagesIncomingBubbledPlain = images
        
        images.removeAll()
        for i in 0 ... 100 {
            images.append(generatePercentageImage(color: palette.textBubble_outgoing, value: i, font: .normal(12)))
        }
        self.generatedPercentageAnimationImagesOutgoingBubbledPlain = images
        
        images.removeAll()
        for i in 0 ... 100 {
            images.append(generatePercentageImage(color: palette.text, value: i, font: .normal(12)))
        }
        self.generatedPercentageAnimationImagesPlain = images
        images.removeAll()
    }
    
    func pollPercentAnimatedIcons(_ incoming: Bool, _ bubbled: Bool, selected: Bool, from fromValue: CGFloat, to toValue: CGFloat, duration: Double) -> [CGImage] {
        let minimumFrameDuration = 1.0 / 60
        let numberOfFrames = max(1, Int(duration / minimumFrameDuration))
        var images: [CGImage] = []
        
        let generated = bubbled ? incoming ? (selected ? generatedPercentageAnimationImagesIncomingBubbled : generatedPercentageAnimationImagesIncomingBubbledPlain) : (selected ? generatedPercentageAnimationImagesOutgoingBubbled : generatedPercentageAnimationImagesOutgoingBubbledPlain) : (selected ? generatedPercentageAnimationImages : generatedPercentageAnimationImagesPlain)
        
        for i in 0 ..< numberOfFrames {
            let t = CGFloat(i) / CGFloat(numberOfFrames)
            let value = (1.0 - t) * fromValue + t * toValue
            images.append(generated[Int(round(value))])
        }
        return images
    }
    
    func pollPercentAnimatedIcon(_ incoming: Bool, _ bubbled: Bool, selected: Bool, value: Int) -> CGImage {
        let generated = bubbled ? incoming ? (selected ? generatedPercentageAnimationImagesIncomingBubbled : generatedPercentageAnimationImagesIncomingBubbledPlain) : (selected ? generatedPercentageAnimationImagesOutgoingBubbled : generatedPercentageAnimationImagesOutgoingBubbledPlain) : (selected ? generatedPercentageAnimationImages : generatedPercentageAnimationImagesPlain)
        return generated[max(min(generated.count - 1, value), 0)]
    }
    
    func activityBackground(_ incoming: Bool, _ bubbled: Bool) -> NSColor {
        return bubbled ? incoming ? palette.fileActivityBackgroundBubble_incoming : palette.fileActivityBackgroundBubble_outgoing : palette.fileActivityBackground
    }
    func activityForeground(_ incoming: Bool, _ bubbled: Bool) -> NSColor {
        return bubbled ? incoming ? palette.fileActivityForegroundBubble_incoming : palette.fileActivityForegroundBubble_outgoing : palette.fileActivityForeground
    }
    
    func webPreviewActivity(_ incoming: Bool, _ bubbled: Bool) -> NSColor {
        return bubbled ? incoming ? palette.webPreviewActivityBubble_incoming : palette.webPreviewActivityBubble_outgoing : palette.webPreviewActivity
    }
    func pollOptionBorder(_ incoming: Bool, _ bubbled: Bool) -> NSColor {
        return (bubbled ? incoming ?  grayText(incoming, bubbled) : grayText(incoming, bubbled) : palette.grayText).withAlphaComponent(0.2)
    }
    func pollOptionUnselectedImage(_ incoming: Bool, _ bubbled: Bool) -> CGImage {
        return bubbled ? incoming ? theme.icons.chatPollVoteUnselectedBubble_incoming :  theme.icons.chatPollVoteUnselectedBubble_outgoing : theme.icons.chatPollVoteUnselected
    }
    
    func waveformBackground(_ incoming: Bool, _ bubbled: Bool) -> NSColor {
        return bubbled ? incoming ? palette.waveformBackgroundBubble_incoming : palette.waveformBackgroundBubble_outgoing : palette.waveformBackground
    }
    func waveformForeground(_ incoming: Bool, _ bubbled: Bool) -> NSColor {
        return bubbled ? incoming ? palette.waveformForegroundBubble_incoming : palette.waveformForegroundBubble_outgoing : palette.waveformForeground
    }
    
    func backgroundColor(_ incoming: Bool, _ bubbled: Bool) -> NSColor {
        return bubbled ? incoming ? palette.bubbleBackground_incoming : palette.bubbleBackground_outgoing : palette.background
    }
    
    func backgoundSelectedColor(_ incoming: Bool, _ bubbled: Bool) -> NSColor {
        return bubbled ? incoming ? palette.bubbleBackgroundHighlight_incoming : palette.bubbleBackgroundHighlight_outgoing : palette.background
    }
    
    func bubbleBorderColor(_ incoming: Bool, _ bubbled: Bool) -> NSColor {
        return incoming ? palette.bubbleBorder_incoming : palette.bubbleBorder_outgoing//.clear//palette.bubbleBorder_outgoing
    }
    
    func textColor(_ incoming: Bool, _ bubbled: Bool) -> NSColor {
        return bubbled ? incoming ? palette.textBubble_incoming : palette.textBubble_outgoing : palette.text
    }
    
    func monospacedPreColor(_ incoming: Bool, _ bubbled: Bool) -> NSColor {
        return bubbled ? incoming ? palette.monospacedPreBubble_incoming : palette.monospacedPreBubble_outgoing : palette.monospacedPre
    }
    func monospacedCodeColor(_ incoming: Bool, _ bubbled: Bool) -> NSColor {
        return bubbled ? incoming ? palette.monospacedCodeBubble_incoming : palette.monospacedCodeBubble_outgoing : palette.monospacedCode
    }
    
    func selectText(_ incoming: Bool, _ bubbled: Bool) -> NSColor {
        return bubbled ? incoming ? palette.selectTextBubble_incoming : palette.selectTextBubble_outgoing : palette.selectText
    }
    
    func grayText(_ incoming: Bool, _ bubbled: Bool) -> NSColor {
        return bubbled ? incoming ? palette.grayTextBubble_incoming : palette.grayTextBubble_outgoing : palette.grayText
    }
    
    func linkColor(_ incoming: Bool, _ bubbled: Bool) -> NSColor {
        return bubbled ? incoming ? palette.linkBubble_incoming : palette.linkBubble_outgoing : palette.link
    }
    
    func channelViewsIcon(_ item: ChatRowItem) -> CGImage {
        return item.isStateOverlayLayout ? theme.icons.chatChannelViewsOverlayBubble : item.hasBubble ? item.isIncoming ? theme.icons.chatChannelViewsInBubble_incoming : theme.icons.chatChannelViewsInBubble_outgoing : theme.icons.chatChannelViewsOutBubble
    }
    func stateStateIcon(_ item: ChatRowItem) -> CGImage {
        return item.isFailed ? theme.icons.sentFailed : (item.isStateOverlayLayout ? theme.icons.chatReadMarkOverlayBubble1 : item.hasBubble ? item.isIncoming ? theme.icons.chatReadMarkInBubble1_incoming : theme.icons.chatReadMarkInBubble1_outgoing : theme.icons.chatReadMarkOutBubble1)
    }
    func readStateIcon(_ item: ChatRowItem) -> CGImage {
        return item.isStateOverlayLayout ? theme.icons.chatReadMarkOverlayBubble2 : item.hasBubble ? item.isIncoming ? theme.icons.chatReadMarkInBubble2_incoming : theme.icons.chatReadMarkInBubble2_outgoing : theme.icons.chatReadMarkOutBubble2
    }
    
    func instantPageIcon(_ incoming: Bool, _ bubbled: Bool) -> CGImage {
        return bubbled ? incoming ? theme.icons.chatInstantViewBubble_incoming : theme.icons.chatInstantViewBubble_outgoing : theme.icons.chatInstantView
    }
    
    func sendingFrameIcon(_ item: ChatRowItem) -> CGImage {
        return item.isStateOverlayLayout ? theme.icons.chatSendingOverlayFrame : item.hasBubble ? item.isIncoming ? theme.icons.chatSendingInFrame_incoming : theme.icons.chatSendingInFrame_outgoing : theme.icons.chatSendingOutFrame
    }
    func sendingHourIcon(_ item: ChatRowItem) -> CGImage {
        return item.isStateOverlayLayout ? theme.icons.chatSendingOverlayHour : item.hasBubble ? item.isIncoming ? theme.icons.chatSendingInHour_incoming : theme.icons.chatSendingInHour_outgoing : theme.icons.chatSendingOutHour
    }
    func sendingMinIcon(_ item: ChatRowItem) -> CGImage {
        return item.isStateOverlayLayout ? theme.icons.chatSendingOverlayMin : item.hasBubble ? item.isIncoming ? theme.icons.chatSendingInMin_incoming : theme.icons.chatSendingInMin_outgoing : theme.icons.chatSendingOutMin
    }
    
    func chatCallIcon(_ item: ChatCallRowItem) -> CGImage {
        if item.hasBubble {
            return !item.isIncoming ? (item.failed ? theme.icons.chatFailedCallBubble_outgoing : theme.icons.chatCallBubble_outgoing) : (item.failed ? theme.icons.chatFailedCallBubble_incoming : theme.icons.chatCallBubble_outgoing)
        } else {
            return !item.isIncoming ? (item.failed ? theme.icons.chatFailedCall_outgoing : theme.icons.chatCall_outgoing) : (item.failed ? theme.icons.chatFailedCall_incoming : theme.icons.chatCall_outgoing)
        }
    }
    
    func chatCallFallbackIcon(_ item: ChatCallRowItem) -> CGImage {
        return item.hasBubble ? item.isIncoming ? theme.icons.chatFallbackCallBubble_incoming : theme.icons.chatFallbackCallBubble_outgoing : theme.icons.chatFallbackCall
    }
    
    func peerName(_ index: Int) -> NSColor {
        let array = [theme.colors.groupPeerNameRed,
                     theme.colors.groupPeerNameOrange,
                     theme.colors.groupPeerNameViolet,
                     theme.colors.groupPeerNameGreen,
                     theme.colors.groupPeerNameCyan,
                     theme.colors.groupPeerNameLightBlue,
                     theme.colors.groupPeerNameBlue]
        
        return array[index]
    }
    
    func replyTitle(_ item: ChatRowItem) -> NSColor {
        return item.hasBubble ? (item.isIncoming ? theme.colors.chatReplyTitleBubble_incoming : theme.colors.chatReplyTitleBubble_outgoing) : theme.colors.chatReplyTitle
    }
    func replyText(_ item: ChatRowItem) -> NSColor {
        return item.hasBubble ? (item.isIncoming ? theme.colors.chatReplyTextEnabledBubble_incoming : theme.colors.chatReplyTextEnabledBubble_outgoing) : theme.colors.chatReplyTextEnabled
    }
    func replyDisabledText(_ item: ChatRowItem) -> NSColor {
        return item.hasBubble ? (item.isIncoming ? theme.colors.chatReplyTextDisabledBubble_incoming : theme.colors.chatReplyTextDisabledBubble_outgoing) : theme.colors.chatReplyTextDisabled
    }
}
