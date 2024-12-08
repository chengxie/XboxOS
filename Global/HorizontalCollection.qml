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

import QtQuick 2.3
import QtQuick.Layouts 1.11
import "../Lists"
import "../GridView"

FocusScope {
id: root
	property var collection
	property var gameList: collection.search
    property alias currentIndex: collectionList.currentIndex
    property alias title: collectiontitle.text
	property bool showTitles: settings.AlwaysShowTitles === "Yes"
	property bool showHighlightedTitles: showTitles
	property int numColumns: settings.GridColumns ? settings.GridColumns : 6

    signal activateSelected
    signal listHighlighted

	GridSpacer { id: fakebox; collection: gameList.collection }

    Text {
    id: collectiontitle

        text: collection.name
        font.family: subtitleFont.name
        font.pixelSize: vpx(18)
        font.bold: true
        color: theme.text
        opacity: root.focus ? 1 : 0.2
        anchors { left: parent.left; leftMargin: globalMargin; }
    }

    ListView {
    id: collectionList

        focus: root.focus
        anchors {
            top: collectiontitle.bottom; topMargin: spacing
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
		property int cellWidth: (width - globalMargin * 2 + spacing)  / numColumns - spacing
		property int cellHeight: cellWidth * fakebox.ratio
        spacing: (width - globalMargin * 2) / numColumns * 0.09
        snapMode: ListView.SnapOneItem 
        orientation: ListView.Horizontal
		preferredHighlightBegin: globalMargin
		preferredHighlightEnd: parent.width - globalMargin
		highlightRangeMode: ListView.StrictlyEnforceRange
		highlightMoveDuration: 200
        keyNavigationWraps: false

        onFocusChanged: {
            if (focus) {
                currentIndex = collection.index;
			} else {
                collection.index = currentIndex;
            }
        }

		Component.onDestruction: {
			collection.index = currentIndex;
		}

		Component.onCompleted: {
			currentIndex = collection.index
			positionViewAtIndex(currentIndex, ListView.Visible)
		}

        model: gameList.games ? gameList.games : api.allGames
        delegate: BoxArtGridItem {
			selected:				ListView.isCurrentItem && ListView.view.focus
			width:					ListView.view.cellWidth	* (selected ? 1.1 : 1)
			height:					ListView.view.cellHeight * (selected ? 1.1 : 1)
			showTitles:				root.showTitles
			showHighlightedTitles:	root.showHighlightedTitles
			onActivate: {
				if (selected) {
					activateSelected();
				} else {
					ListView.view.currentIndex = index;
				}
			}
			onHighlighted: {
				listHighlighted();
				ListView.view.currentIndex = index;
			}
		}

		Keys.onLeftPressed: { sfxNav.play(); decrementCurrentIndex() }
		Keys.onRightPressed: { sfxNav.play(); incrementCurrentIndex() }

    }

}
