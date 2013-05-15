/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

Item {

    width: parent.width
    height: bpListView.height
    property alias model: bpListView.model
    property Component listDelegate: standardSettingsDelegate

    ListView {

        interactive: false
        id:bpListView

        anchors.right: parent.right
        anchors.left: parent.left
        //anchors.leftMargin: 20 //THEME
        //anchors.rightMargin:20 //THEME
        delegate: listDelegate

        height: contentHeight
        clip:true
    }

    Component {
        id: standardSettingsDelegate
        BackPanelTextToggleItem {
            text: settingsTitle
            propName: custPropName
            onToggled: {
                bpListView.model.setProperty(index, "isVisible", isOn);
            }
        }
    }

}
