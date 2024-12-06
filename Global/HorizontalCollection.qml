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
    property var search
    property int itemWidth: vpx(150)
    property int itemHeight: itemWidth*1.5
    property alias collectionList: collectionList
    property alias currentIndex: collectionList.currentIndex
    property alias title: collectiontitle.text
    property alias model: collectionList.model
    property alias delegate: collectionList.delegate
    property bool showBoxes: false

    signal activateSelected
    signal listHighlighted

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

		//property var collection

        focus: root.focus
        anchors {
            top: collectiontitle.bottom; topMargin: vpx(10)
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        spacing: vpx(12)

        snapMode: ListView.SnapOneItem 
        orientation: ListView.Horizontal
		preferredHighlightBegin: globalMargin
		preferredHighlightEnd: parent.width - globalMargin
		highlightRangeMode: ListView.StrictlyEnforceRange
		highlightMoveDuration: 200
        highlight: highlightcomponent
        keyNavigationWraps: true

        currentIndex: collection.index

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
			positionViewAtIndex(currentIndex, ListView.Visible)
		}

        model: search.games ? search.games : api.allGames

        delegate: showBoxes ? boxartDelegate : dynamicDelegate

        Component {
        id: boxartDelegate

            BoxArtGridItem {
                selected: ListView.isCurrentItem && collectionList.focus
                width: itemWidth
                height: itemHeight
				showTitle: settings.AlwaysShowTitles === "Yes"
				onActivate: {
					if (selected) {
						activateSelected();
					} else {
						collectionList.currentIndex = index;
					}
				}
				onHighlighted: {
					listHighlighted();
					collectionList.currentIndex = index;
				}
            }
        }

        Component {
        id: dynamicDelegate

            DynamicGridItem {
                selected: ListView.isCurrentItem && collectionList.focus
                width: itemWidth
                height: itemHeight
				showTitle: settings.AlwaysShowTitles === "Yes"
                onActivate: {
                    if (selected) {
                        activateSelected();
                    } else {
                        collectionList.currentIndex = index;
                    }
                }
				onHighlighted: {
					listHighlighted();
					collectionList.currentIndex = index;
				}
            }
        }

        Component {
        id: highlightcomponent

            ItemHighlight {
                width: collectionList.cellWidth
                height: collectionList.cellHeight
                game: search ? search.currentGame(collectionList.currentIndex) : ""
                selected: collectionList.focus
                boxArt: showBoxes
            }
        }

		Keys.onLeftPressed: {
			sfxNav.play();
			collectionList.decrementCurrentIndex()
		}
		Keys.onRightPressed: {
			sfxNav.play();
			collectionList.incrementCurrentIndex()
		}

    }

}
