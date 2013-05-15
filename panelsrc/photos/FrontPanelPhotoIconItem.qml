/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Panels 0.1

FrontPanelContentItem {
    id: fpPhotoIconItem
    property alias imageSource: fpImage.source
    property alias text: fpText.text

    contentHeight: fpImage.height
    mouseAreaActive: true

    Image {
        id: fpImage
        height: panelSize.contentItemHeight
        width: height
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    Text {
        id: fpText
        font.pixelSize: theme_fontPixelSizeLarge
        color: panelColors.textColor
        anchors.left: fpImage.right
        anchors.leftMargin: (fpImage.width/4)
        anchors.right: parent.right
        anchors.rightMargin: panelSize.contentSideMargin
        anchors.verticalCenter: parent.verticalCenter
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
    }
}
