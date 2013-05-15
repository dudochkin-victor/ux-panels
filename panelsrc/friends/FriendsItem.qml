/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Panels 0.1
import MeeGo.Components 0.1

FrontPanelContentItem {
    id: friendItemText

    contentHeight: (header.height + content.height)

    property int maxHeight: panelSize.oneHalf
    property string authorIcon: ""
    property string openUrl: ""

    property alias serviceName: serviceNameText.text
    property string serviceIcon: "" //serviceIconImage.source
    property alias authorName: authorNameText.text
    property alias messageText: contentText.text
    property alias picImage: pictureImage.source
    property alias timeStamp: timestampText.text
    property string itemID: ""
    property string itemType: ""

    property bool moving: false

    signal pressAndHold(string myID, variant mouse)
    signal clicked(string myID)
    signal acceptClicked(string myID)
    signal rejectClicked(string myID)

    MouseArea {
        anchors.fill: parent
        onClicked: friendItemText.clicked(itemID)
        onPressAndHold: friendItemText.pressAndHold(itemID, mouse)
    }

    FrontPanelSubHeader {
        id: header
        anchors.left: parent.left
        anchors.top: parent.itemTop.bottom
        arrowVisible: false
        width: parent.width

//        Image {
//            id: serviceIconImage
//            height: panelSize.oneTwentieth
//            width: height
//            anchors.left: parent.left
//            anchors.leftMargin: panelSize.contentSideMargin
//            anchors.verticalCenter: parent.verticalCenter
//            fillMode: Image.PreserveAspectFit
//            smooth: !friendItemText.moving
//            asynchronous: true
//        }
        Text {
            id: serviceNameText
            anchors.left: parent.left
            anchors.leftMargin: panelSize.contentSideMargin
            anchors.right: parent.right
            anchors.rightMargin: panelSize.contentSideMargin
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: theme_fontPixelSizeLarge
            color: panelColors.textColor
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
        }
    }

    Item {
        id: content
        width: parent.width
        height: contentHeight()
        anchors.left: parent.left
        anchors.top: header.bottom

        function contentHeight() {
            return (timestampText.y + timestampText.height + timestampText.anchors.bottomMargin);
        }

        Image {
            id: authorIconImage
            source: (authorIcon == "" ? "image://theme/im/bg_avatar_nopicture" : authorIcon)

            height: panelSize.oneFourth //sourceSize.height
            width: panelSize.oneFourth //sourceSize.width
            anchors.top: parent.top
            anchors.topMargin: panelSize.contentSideMargin
            anchors.left: parent.left
            anchors.leftMargin: panelSize.contentSideMargin
            fillMode: Image.PreserveAspectFit
            smooth: !friendItemText.moving
            asynchronous: true

            onStatusChanged: {
                if ((status == Image.Error) || (status == Image.Null))
                    source = "image://theme/im/bg_avatar_nopicture";
            }
        }

        Text {
            id: authorNameText
            //width: (parent.width - authorIconImage.width - 20)
            anchors.right: parent.right
            anchors.rightMargin: panelSize.contentSideMargin
            anchors.top: authorIconImage.top
            anchors.left: authorIconImage.right
            anchors.leftMargin: panelSize.contentSideMargin
            color: panelColors.textColor
            font.bold: true
            font.pixelSize: theme_fontPixelSizeLarge
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
        }

        Text {
            id: contentText
            width: authorNameText.width
            anchors.top: authorNameText.bottom
            anchors.topMargin: panelSize.contentTopMargin
            anchors.left: authorNameText.left
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pixelSize: theme_fontPixelSizeLarge
            color: panelColors.textColor
        }

        Image {
            id: pictureImage
            height: panelSize.oneThird //sourceSize.height
            width: panelSize.oneThird //calcPictureImageWidth()
            anchors.top: contentText.bottom
            anchors.topMargin: panelSize.contentTopMargin
            anchors.left: contentText.left
            clip: true
            fillMode: Image.PreserveAspectCrop
            smooth: !friendItemText.moving
            asynchronous: true
            visible: (pictureImage.source == "" ? false : true)
            function calcPictureImageWidth() {

                if (pictureImage.sourceSize.width + authorNameText.anchors.leftMargin
                    + authorIconImage.width + authorIconImage.anchors.leftMargin > content.width) {
                    var size = content.width - (authorNameText.anchors.leftMargin
                        + authorIconImage.width + authorIconImage.anchors.leftMargin + 5);
                    return size;
                } else {
                    return pictureImage.sourceSize.width;
                }
            }
        }


        Button {
            id: acceptBtn
            visible: (friendItemText.itemType == "request")
//            bgSourceUp: "image://theme/panels/pnl_switch_pink_up"
//            bgSourceDn: "image://theme/panels/pnl_switch_pink_dn"
//            height: panelSize.oneTenth
//            width: panelSize.oneFourth
            anchors.top: (pictureImage.visible ? pictureImage.bottom : contentText.bottom)
            anchors.topMargin: panelSize.contentTopMargin
            anchors.left: contentText.left
            text: qsTr("Accept")
            //color: theme_fontColorNormal
            onClicked: {
                friendItemText.acceptClicked(itemID);
            }
        }

        Button {
            id: rejectBtn
            visible: (friendItemText.itemType == "request")
//            height: panelSize.oneTenth
//            width: panelSize.oneFourth
            anchors.top: (pictureImage.visible ? pictureImage.bottom : contentText.bottom)
            anchors.topMargin: panelSize.contentTopMargin
            anchors.left: acceptBtn.right
            anchors.leftMargin: panelSize.contentSideMargin
            text: qsTr("Decline")
            //color: theme_fontColorNormal
            onClicked: {
                friendItemText.rejectClicked(itemID);
            }
        }
        Text {
            id: timestampText
            width: contentText.width
            anchors.top: {
                var obj;
                if (acceptBtn.visible)
                    obj = acceptBtn;
                else if (pictureImage.visible)
                    obj = pictureImage;
                else
                    obj = contentText;

                if ((obj.y + obj.height) < (authorIconImage.y + authorIconImage.height))
                    return authorIconImage.bottom;
                else
                    return obj.bottom;

            }
            anchors.topMargin: panelSize.contentTopMargin
            anchors.left: authorIconImage.left
            anchors.bottomMargin: panelSize.contentTopMargin
            font.pixelSize: theme_fontPixelSizeNormal
            color:theme_fontColorInactive
            anchors.right: contentText.right
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
        }

    }

}
