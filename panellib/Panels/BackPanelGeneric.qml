/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1
import MeeGo.Panels 0.1


SimplePanel {
    id: backPanelGeneric

    signal clearHistClicked(variant btnPos)

    property Component bpContent
    property bool clearButtonVisible :true
    property string subheaderText

    isBackPanel: true

    panelComponent: backPanel

    Component {
        id: backPanel
        Flickable {
            id: bpComp
            interactive: (height < contentHeight)
            anchors.fill: parent
            contentHeight: backPanelCol.height
            clip: true
            Column {
                id: backPanelCol
                width: parent.width
                FrontPanelSubHeader{
                    visible: true
                    text: subheaderText
                }
                BackPanelMessageTextItem
                {
                    id: bpMessage
                    width: parent.width
                }

                Loader {
                    width: parent.width
                    sourceComponent: bpContent
                }
                Item {
                    visible:backPanelGeneric.clearButtonVisible
                    width: parent.width
                    height: bpClearButton.height + 2*panelSize.contentTopMargin
                    Button {
                        id: bpClearButton
                        text: qsTr("Clear history")
                        anchors.bottomMargin: panelSize.contentTopMargin
                        anchors.topMargin: panelSize.contentTopMargin
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            var btnXY = topItem.topItem.mapFromItem(bpComp,
                                                                    (x+(width/2)),
                                                                    y);
                            backPanelGeneric.clearHistClicked(btnXY)
                        }
                    }
                }
                FrontPanelSubHeader{
                    visible: true
                    text: qsTr("Panels")
                }
                BackPanelIconTextItem {
                    imageSource: "image://meegotheme/icons/settings/everyday-settings"
                    text: qsTr("Manage panels")
                    onClicked: {
                        spinnerContainer.startSpinner();
                        appsModel.launch("meego-qml-launcher --opengl --app meego-ux-settings --cmd showPage --cdata Panels --fullscreen")
                    }
                }
            }
        }
    }
}

