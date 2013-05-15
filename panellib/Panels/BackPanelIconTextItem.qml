/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

//BackPanelIconTextItem - base class for standard content items in the
//back panel - this contains standard visual properties that are common


BackPanelContentItem {
    id: bpITI
    property alias imageSource: bpImage.source
    property alias text: bpText.text
    property bool zoomImage: false

    height: panelSize.contentItemHeight

    Image {
        id: bpImage
        height: (bpITI.zoomImage ? width : sourceSize.width)
        width: (bpITI.zoomImage ? panelSize.contentIconSize : sourceSize.width) //THEME - VERIFY
        fillMode: Image.PreserveAspectCrop
        anchors.left: parent.left
        anchors.leftMargin: panelSize.contentSideMargin
        anchors.verticalCenter: parent.verticalCenter
        asynchronous: true
    }

    Text {
        id: bpText
        font.pixelSize: theme_fontPixelSizeLarge //THEME - VERIFY
        color: panelColors.textColor
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: (((bpImage.status == Image.Error) || (bpImage.status == Image.Null)) ? parent.left : bpImage.right )
        anchors.leftMargin: (((bpImage.status == Image.Null) || (bpImage.status == Image.Error)) ? panelSize.contentSideMargin : (bpImage.width/4))
        anchors.right: parent.right
        anchors.rightMargin: panelSize.contentSideMargin
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
    }
}
