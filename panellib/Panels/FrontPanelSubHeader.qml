/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

//FrontPanelSubHeader - base class for standard headers in the
//Front panel - this contains standard visual properties that are common

Item {

    width: parent.width
    height: subHeaderImg.height

    property bool collapsed: false
    property alias arrowVisible: fpSubHeaderImage.visible
    property alias text: fpSubHeaderText.text

    signal arrowClicked(bool collapsed);

    Image {
        id: subHeaderImg
        source: (panelObj.Color == "" ? "image://theme/panels/pnl_mytablet_subtitlebar" :
                 "image://theme/panels/pnl_subtitlebar_" + panelObj.Color)
        height: sourceSize.height
        width: parent.width
        onStatusChanged: {
            if (status == Image.Error) {
                //If we can't load the colored titlebar, fall back to default
                source = "image://theme/panels/pnl_mytablet_subtitlebar"
            }
        }
    }

    Text {
        id: fpSubHeaderText
        font.pixelSize: theme_fontPixelSizeLarge
        color: panelColors.textColor
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: panelSize.contentSideMargin
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
    }

    Image {
        id: fpSubHeaderImage
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: fpSubHeaderText.anchors.leftMargin //THEME
        rotation: collapsed? 90 : 0
        source:  "image://theme/panels/pnl_icn_arrowdown"
        visible: false

        Behavior on rotation {
            RotationAnimation { duration: 100 }
        }
    }

    MouseArea{
        anchors.fill: parent
        onClicked:{
            collapsed=!collapsed
            fpSubHeaderImage.parent.arrowClicked(collapsed);
        }
        visible: fpSubHeaderImage.visible
    }

}
