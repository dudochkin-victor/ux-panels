/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

// Panel.qml
//
// The simple version of a panel that expects a VisualItemModel to contain
// its content. Use DynamicPanel for dynamic loading of panel content from
// QML files.
//
// See: DynamicPanel.qml, myslate/MySlatePanel.qml

SimplePanel {
    id: panelContainer
    panelComponent: flickableContent

    // set this to a VisualItemModel containing the contents of your panel
    property VisualItemModel panelContent

    Component {
        id: flickableContent
        ListView{
            id: panelScroll
            anchors.fill: parent
            flickableDirection: Flickable.VerticalFlick

            // lock scroll area width to our width, so no horizontal movement
//            contentWidth: width
//            contentHeight: panelContents.height
            clip: true
            //boundsBehavior: Flickable.StopAtBounds

            // lock all movement when contents don't need to scroll
            interactive: (childrenRect.height > height)
            onInteractiveChanged: {
                if (!interactive)
                    contentY = 0;
            }


//            Column {
 //               id: panelContents
 //               width: parent.width
   //             Repeater {
     //               id: panelRepeater
                    model: panelContainer.panelContent
       //         }
         //   }
        }
    }
}
