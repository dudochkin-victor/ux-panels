/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

//FrontPanelContentPreviewItem - class for standard preview content items in the
//front panel - this contains standard visual properties that are common


FrontPanelContentItem{

    width: parent.width
    contentHeight: (width/16)*9    //THEME - VERIFY

    property alias imageSource: fpImage.source
    property bool imagePlayStatus: false

    mouseAreaActive: true

    Image {
        id: fpImage
        visible: true
        anchors.top:  parent.itemTop.bottom
        anchors.bottom:  parent.itemBottom.top
        anchors.left: parent.left
        anchors.right: parent.right
        //anchors.fill: parent
        asynchronous: true

        fillMode: Image.PreserveAspectCrop
    }

}
