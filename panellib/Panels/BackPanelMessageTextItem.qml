/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

BackPanelContentItem{

    contentHeight: bpText.paintedHeight
    + bpText.anchors.topMargin
    + bpText.anchors.bottomMargin

    property alias text: bpText.text

    Text {
        id: bpText
        text: qsTr("To show items on the front of the panel select ON, to hide select OFF")
        anchors.left: parent.left
        anchors.leftMargin: panelSize.contentSideMargin
        anchors.right:  parent.right
        anchors.rightMargin: panelSize.contentSideMargin
        anchors.top: parent.itemTop.bottom
        anchors.topMargin: panelSize.contentTopMargin
        anchors.bottomMargin: anchors.topMargin
        horizontalAlignment: Text.AlignLeft

        font.pixelSize: theme_fontPixelSizeLarge
        color: panelColors.textColor
        wrapMode: Text.Wrap
    }
}



