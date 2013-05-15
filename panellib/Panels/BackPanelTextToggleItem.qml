/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1

//BackPanelTextToggleItem  - class for standard toggle items in the
//back panel - this contains standard visual properties that are common

BackPanelContentItem {
    id: backPanelTextToggleItem
    property alias text: bpText.text
    property string propName: ""
    property variant defaultVal: true

    signal toggled(bool isOn)

    contentHeight: bpToggleButton.height + bpToggleButton.anchors.topMargin + bpToggleButton.anchors.bottomMargin

    width: parent.width

    Text {
        id: bpText
        font.pixelSize: theme_fontPixelSizeLarge
        color: panelColors.textColor
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: panelSize.contentSideMargin
        anchors.right: bpToggleButton.left
        anchors.rightMargin: anchors.leftMargin
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
    }

    ToggleButton{
        id: bpToggleButton
        anchors.topMargin: panelSize.contentTopMargin
        anchors.bottomMargin: anchors.topMargin
        anchors.right: parent.right
        anchors.rightMargin: panelSize.contentSideMargin
        anchors.top: parent.itemTop.bottom

        property bool initialVal

        on: {
            initialVal = panelObj.getCustomProp(custPropName, defaultVal)
            backPanelTextToggleItem.toggled(initialVal);
            return initialVal;
        }

        onToggled:{
            backPanelTextToggleItem.toggled(isOn);
            panelObj.setCustomProp(custPropName, isOn);
        }
    }

}
