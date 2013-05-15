/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

//FrontPanelGridImageItem - base class for standard content image items
// put in a grid in the Front panel - this contains standard
//visual properties that are common

Item {
    id: fpGridElementItem
    property alias imageSource: fpImage.source
    property alias imageFillMode: fpImage.fillMode
    property int padding: 0
    property string fallbackImageSource: ""

    signal clicked(variant mouse)
    signal pressAndHold(variant mouse)

    Image{
        id: fpImage
        anchors.fill: parent
        anchors.margins: parent.padding
        fillMode: Image.PreserveAspectFit
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        asynchronous: true

	onStatusChanged: {
            if ((status == Image.Error) && (fpGridElementItem.fallbackImageSource != "")) {
                source = fpGridElementItem.fallbackImageSource;
            }
	}

        MouseArea{
            anchors.fill: parent
            onClicked:{
                fpGridElementItem.clicked(mouse)
            }
            onPressAndHold: {
                fpGridElementItem.pressAndHold(mouse)
            }

        }
    }
}
