/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

//FrontPanelIconTextItem - base class for standard content items in the
//Front panel - this contains standard visual properties that are common


FrontPanelContentItem {
    id: fpITI
    property alias imageSource: fpImage.source
    property alias text: fpText.text
    property bool zoomImage: false
    property string fallBackImage: ""

    contentHeight: panelSize.contentItemHeight
    mouseAreaActive: true

    Image {
        id: fpImage
        height: (fpITI.zoomImage ? width : sourceSize.height)
        width: (fpITI.zoomImage ? panelSize.contentIconSize : sourceSize.width) //THEME - VERIFY
        fillMode: Image.PreserveAspectCrop
        anchors.left: parent.left
        anchors.leftMargin: panelSize.contentSideMargin
        anchors.verticalCenter: parent.verticalCenter
        asynchronous: true

        Component.onCompleted: {
            if ((fallBackImage != "") && ((fpImage.status == Image.Error) || (fpImage.status == Image.Null))) {
                fpImage.source = fallBackImage;
            }
        }
    }

    Text {
        id: fpText
        font.pixelSize: theme_fontPixelSizeLarge //THEME - VERIFY
        color: panelColors.textColor //THEME - VERIFY
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: (((fpImage.status == Image.Null) || (fpImage.status == Image.Error)) ? parent.left : fpImage.right)
        anchors.leftMargin: ((fpImage.status == Image.Null) || (fpImage.status == Image.Error)) ? panelSize.contentSideMargin : (fpImage.width/4)
        anchors.right: parent.right
        anchors.rightMargin: fpImage.anchors.leftMargin
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
    }
}
