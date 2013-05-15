/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1 as Labs
import MeeGo.Components 0.1
import MeeGo.Settings 0.1
import MeeGo.Panels 0.1

Item {
    id: bubbleContainer
    width: childrenRect.width + 20
    height: childrenRect.height + 10
    property alias offset: rectangularBubble.offset
    property alias dlgX: rectangularBubble.x
    property alias dlgY: rectangularBubble.y

    onVisibleChanged:{
        networkListModel.initWifi()
    }

    TopItem {
        id: topItem
    }

    NetworkListModel {
        id: networkListModel
        property bool wifiEnabled
        property bool wifiAvailable

	Component.onCompleted: {
            defaultNetRoute = defaultRoute;
            changeConnectedText();
	}

        onStateChanged: {
            changeConnectedText();
        }

        onDefaultTechnologyChanged: {
            changeConnectedText();
        }

        onDefaultRouteChanged: {
            defaultNetRoute = defaultRoute;
            changeConnectedText();
        }

        onTechnologiesChanged: {
            networkListModel.initWifi()
        }
        onEnabledTechnologiesChanged: {
            wifiToggle.on = (networkListModel.enabledTechnologies.indexOf("wifi") != -1)
        }

        function initWifi()
        {
            for(var i=0 in availableTechnologies) {
                if (availableTechnologies[i] == "wifi") {
                    wifiAvailable = true
                }
            }

            for(var i=0 in enabledTechnologies) {
                if (enabledTechnologies[i] == "wifi") {
                    wifiEnabled = true;
                }
            }
        }
    }

    property QtObject defaultNetRoute: null
    property string connectedText: "";

    onDefaultNetRouteChanged: changeConnectedText()

    Connections {
        target: defaultNetRoute
        onNameChanged: {
            console.log("defaultNetRoute.nameChanged: " + defaultNetRoute.name);
            changeConnectedText();
        }
    }

    function changeConnectedText() {
        //if we don't have a connection, we're not connected
        if (defaultNetRoute == null)
            connectedText = qsTr("No connection currently");
        else {
            if (networkListModel.defaultTechnology == "ethernet")
                connectedText = qsTr("Wired")
            else if ((networkListModel.defaultTechnology == "wifi")
                     || (networkListModel.defaultTechnology == "cellular")
                     || (networkListModel.defaultTechnology == "wimax")
                     || (networkListModel.defaultTechnology == "bluetooth"))
                connectedText = qsTr("Connected to %1").arg(defaultNetRoute.name);
            else if (networkListModel.defaultTechnology == "")
                connectedText = qsTr("Connecting...");
            else {
                console.log("Unhandled technology type: " + networkListModel.defaultTechnology + ", dNR.name: " + defaultNetRoute.name)
                connectedText = qsTr("Connected by %1").arg(networkListModel.defaultTechnology);
            }
        }

        //defaultNetRoute.name;// qsTr("No connection currently.")
                       //"Connected to %1" (ssid)
                       //WiMax/3g: Connected to %1 (operator name)
                       //BT: Connected to %1 (bt dev name)
                       //Wired: "Wired"
                       //precedence: default route
    }


    MouseArea {
        id: maDlg
        parent: topItem.topItem
        anchors.fill: parent
        onClicked: {
            bubbleContainer.visible = false;
        }
        visible: bubbleContainer.visible

        Labs.RectangularBubble {
            id: rectangularBubble

            width: childrenRect.width+15
            height: childrenRect.height+10


            //This is SUCH a hack!
            //We can't adjust the y in the calling code,
            //as, since the height is now dynamically calculated,
            //the wifiDialog.height is 0 initially.
            //So, instead, we adjust it in here, every time we
            //become visible... <sigh>
            //There's really gotta be a better way...

            property bool yAdjusted: false
            property bool xAdjusted: false

            onYChanged: {
                if (!yAdjusted) {
                    yAdjusted = true;
                    y -= (height/2);
                }
            }

            onXChanged: {
                if (!xAdjusted) {
                    xAdjusted = true;
                    //Adjust for the finger
                    x += 5;
                }
            }

            onVisibleChanged: {
                if (!visible) {
                    yAdjusted = false;
                    xAdjusted = false;
                }
            }

            Item{
                id:wifiRectangle

                anchors.top: parent.top
                anchors.topMargin: 5
                height: childrenRect.height + 10
                width: { return Math.max(childrenRect.width + 20, parent.width - 4); }

                Text{
                    id: wifiText
                    text: qsTr("Wi-Fi")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.rightMargin: 5
                    color: panelColors.textColor
                    height: paintedHeight
                    width: paintedWidth
                }

                ToggleButton{
                    id: wifiToggle

                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.verticalCenter: wifiText.verticalCenter

                    on:  (networkListModel.enabledTechnologies.indexOf("wifi") != -1)
                    onToggled: {
                        if(wifiToggle.on)
                            networkListModel.enableTechnology("wifi");
                        else
                            networkListModel.disableTechnology("wifi");
                    }
                }
            }

            Rectangle{
                id: wifiRectangleborder1
                anchors.top: wifiRectangle.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 4
                height: 1
                color: panelColors.separatorColor
            }

	    Text {
	        id: txtCurConn
		anchors.top: wifiRectangleborder1.bottom
                anchors.left: parent.left
		anchors.leftMargin: 10
                anchors.topMargin: 4
                width: paintedWidth
                text: connectedText
                color: panelColors.textColor
	    }

            Rectangle{
                id: wifiRectangleborder2
                anchors.top: txtCurConn.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 4
                height: 1
                color: panelColors.separatorColor
            }

            Button {
                id : wifiSettings
                text: qsTr("Wi-Fi settings")
                anchors.top: wifiRectangleborder2.bottom
                anchors.topMargin: 5
                anchors.leftMargin:5
                anchors.rightMargin:5
                anchors.bottomMargin:5
                anchors.horizontalCenter: parent.horizontalCenter

                onClicked:{
                    spinnerContainer.startSpinner();
                    appsModel.launch("meego-qml-launcher --opengl  --app meego-ux-settings --cmd showPage --cdata Connections --fullscreen")
                    bubbleContainer.visible = false;
                }
            }
        }
    }
}



