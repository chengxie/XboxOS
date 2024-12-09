// gameOS theme
// Copyright (C) 2018-2020 Seth Powell 
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtGraphicalEffects 1.0

Item {
id: root

	LinearGradient {
		anchors {
			left: parent.left; right: parent.right
			bottom: parent.bottom
		}
		height: vpx(150)
		start: Qt.point(0, height)
		end: Qt.point(0, 0)
		gradient: Gradient {
			GradientStop { position: 0.0; color: "#FF000000" }
			GradientStop { position: 1.0; color: "#00000000" }
		}
	} 

    Component {
        id: buttonhelpDelegate
        Row {
            spacing: vpx(10)
            Image {
                source: "../assets/images/controller/" + processButtonArt(button) + ".png"
                width: vpx(30)
                height: vpx(30)
                asynchronous: true
            }
            Text { 
                text: name
                font.family: subtitleFont.name
                font.pixelSize: vpx(16)
                color: theme.text
                height: parent.height
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    ListView {
        anchors.fill: parent
		anchors.rightMargin: globalMargin
        model: currentHelpbarModel
        delegate: buttonhelpDelegate
        orientation: ListView.Horizontal
        layoutDirection: Qt.RightToLeft
        spacing: vpx(20)
    }

    visible: currentHelpbarModel ? true : false

    // Processes the button and will display the correct art based on the button mappings set in Pegasus
    // Necessary as we can't use script in the ListModel
    function processButtonArt(button) {
        var buttonModel;
        switch (button) {
            case "accept":
            buttonModel = api.keys.accept;
            break;
            case "cancel":
            buttonModel = api.keys.cancel;
            break;
            case "filters":
            buttonModel = api.keys.filters;
            break;
            case "details":
            buttonModel = api.keys.details;
            break;
            case "nextPage":
            buttonModel = api.keys.nextPage;
            break;
            case "prevPage":
            buttonModel = api.keys.prevPage;
            break;
            case "pageUp":
            buttonModel = api.keys.pageUp;
            break;
            case "pageDown":
                buttonModel = api.keys.pageDown;
                break;
            default:
            buttonModel = api.keys.accept;
        }

        for (let i = 0; buttonModel.length; i++) {
            if (buttonModel[i].name().includes("Gamepad")) {
            var buttonValue = buttonModel[i].key.toString(16)
            return buttonValue.substring(buttonValue.length-1, buttonValue.length);
            }
        }
    }
    
}
