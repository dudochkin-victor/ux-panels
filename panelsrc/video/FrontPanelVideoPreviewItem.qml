/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Panels 0.1

//FrontPanelVideoPreviewItem - class for standard Video content items in the
//front panel - this contains standard visual properties that are common


FrontPanelContentPreviewItem{

    id: fpVideoPreview
    property alias text: fpText.text
    property bool imagePlayStatus: false
    clip: true

    Image{
        id: playPauseButton
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        source: imagePlayStatus?"image://theme/panels/pnl_btn_pause_up"
        :"image://theme/panels/pnl_btn_play_up"
    }
    Image{
        opacity: 0.7 //THEME
        anchors.bottom: parent.bottom
        source: "image://theme/panels/pnl_infopanel_lrg"
        width: parent.width

        Text{
            id:fpText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: panelSize.contentSideMargin
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: theme_fontPixelSizeLarge
            color: panelColors.textColor
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
        }
    }
}
