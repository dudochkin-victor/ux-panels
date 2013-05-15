/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

//FrontPanelGridView - class for standard grid view in the
//front panel - this contains standard visual properties that are common

Item {
    id: fpGridView

    width: parent.width
    height: itemTopLine.height + itemBG.height+ itemBottomLine.height
    //TODO 2011/01/18 JEA - FIX THIS! some strange interactions with FrontPanelContentItem, not sure what's going
    //on, so we manually implement a FPCI in here for now... :(



    property alias model: fpGrid.model
    property Component delegate: standardDelegate
    property int colCount: 3
    //If you leave rowCount as 0, the GridView will
    //auto-size to the content
    property int rowCount: 0

    property alias count: fpGrid.count

    Image {
        id: itemTopLine
        source: "image://theme/panels/pnl_list_top"
        width: parent.width
        height: sourceSize.height
        anchors.top: parent.top
    }

    Image {
        id: itemBG
        source: "image://theme/panels/pnl_list_bg"
        width: parent.width
        height: fpGrid.height
        anchors.top: itemTopLine.bottom

        GridView {
            id: fpGrid
            height: {
                if (!rowCount)
                    return (cellHeight*Math.ceil(count/fpGridView.colCount));
                else
                    return (cellHeight * fpGridView.rowCount);
            }
            snapMode: GridView.SnapToRow
            clip: false
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.left: parent.left
            interactive: false //(contentHeight > height)
            cellWidth: (width/fpGridView.colCount)-1
            cellHeight: cellWidth
            delegate: fpGridView.delegate
        }
    }

    Image {
        id: itemBottomLine
        source: "image://theme/panels/pnl_list_bottom"
        width: parent.width
        height: 1//sourceSize.height
        anchors.bottom: parent.bottom
    }

    Component {
        id: standardDelegate
        FrontPanelGridImageItem {
            width: fpGrid.cellWidth
            height: width
            imageSource: image
        }
    }
}
