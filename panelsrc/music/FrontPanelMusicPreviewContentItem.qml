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
    id: fpMusicPreview

    contentHeight: (width * .4) //THEME - VERIFY
    width: parent.width

    property alias imageSource: fpImage.source
    property alias text: fpMainText.text
    property alias descriptionText: fpDescriptionText.text
    property bool imagePlayStatus: false

    property bool isCurrentlyPlayingLayout: false
    signal backButtonClicked()
    signal playButtonClicked()
    signal forwardButtonClicked()

    mouseAreaActive: true

    Image{
        id: fpImage
        anchors.top: parent.itemTop.bottom
        anchors.left: parent.left
        anchors.bottom: parent.itemBottom.top
        asynchronous: true

        height: parent.height
        width: height
        fillMode: Image.PreserveAspectFit

        Component.onCompleted: {
            if ((fpImage.status == Image.Error) || (fpImage.status == Image.Null)) {
                fpImage.source = "image://theme/media/music_thumb_med";
            }
        }

        Image{
            visible: fpMusicPreview.isCurrentlyPlayingLayout
            anchors.verticalCenter: playPauseButton.verticalCenter
            anchors.right: playPauseButton.left
            anchors.left: parent.left
            height: playPauseButton.height
            width: height
            source: "image://theme/panels/pnl_btn_previous_up"


            MouseArea {
                anchors.fill: parent
                onClicked: {
                    fpMusicPreview.backButtonClicked();
                }
            }
        }


        Image{
            id: playPauseButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            height: fpMusicPreview.isCurrentlyPlayingLayout?
                    sourceSize.height/2 : sourceSize.height
            width: fpMusicPreview.isCurrentlyPlayingLayout? sourceSize.width/2
            :sourceSize.width
            source: imagePlayStatus?"image://theme/panels/pnl_btn_pause_up"
            :"image://theme/panels/pnl_btn_play_up"

            MouseArea {
                anchors.fill: parent
                onPressAndHold: {
                    var posInItem = fpMusicPreview.mapFromItem(playPauseButton, mouse.x, mouse.y);
                    fpMusicPreview.pressAndHold(posInItem);
                }
                onClicked: {
                    fpMusicPreview.playButtonClicked();
                }
            }
        }

        Image{
            anchors.verticalCenter: playPauseButton.verticalCenter
            anchors.right:parent.right
            anchors.left: playPauseButton.right
            visible: fpMusicPreview.isCurrentlyPlayingLayout
            height: playPauseButton.height
            width: height
            source: "image://theme/panels/pnl_btn_next_up"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    fpMusicPreview.forwardButtonClicked();
                }
            }
        }
    }

    Item{
        anchors.top: parent.itemTop.bottom
        anchors.bottom: parent.itemBottom.top
        anchors.left: fpImage.right
        anchors.right: parent.right

        Text {
            id: fpMainText
            font.pixelSize: theme_fontPixelSizeLarge //THEME - VERIFY
            color: panelColors.textColor
            anchors.top: parent.top
            anchors.topMargin: font.pixelSize/2
            anchors.left: parent.left
            anchors.leftMargin: { return Math.round(fpMusicPreview.width/30); }
            anchors.right: parent.right
            anchors.rightMargin: { return Math.round(fpMusicPreview.width/30); }
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
        }

        Text {
            id: fpDescriptionText
            font.pixelSize: theme_fontPixelSizeLarge //THEME - VERIFY
            color: panelColors.textColor
            anchors.top: fpMainText.bottom
            anchors.topMargin: font.pixelSize/2
            anchors.left: fpMainText.left
            anchors.right: fpMainText.right
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
        }
    }
}
