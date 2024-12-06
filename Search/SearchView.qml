import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import "../Global"
import "../GridView"


FocusScope {
id: root
	property alias searchText: searchInput.text


    SortFilterProxyModel {
        id: gamesFiltered
        sourceModel: api.allGames
        property string searchTerm: ""

        filters: [
            RegExpFilter {
                roleName: "title";
                pattern: "^" + gamesFiltered.searchTerm.trim().replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&') + ".+";
                caseSensitivity: Qt.CaseInsensitive;
                enabled: gamesFiltered.searchTerm !== "";
            }
        ]

        property bool hasResults: count > 0
    }

    Rectangle {
    id: header
        anchors {
            top:    parent.top
            left:   parent.left
            right:  parent.right
        }
        height: globalMargin//vpx(35)
        color: theme.main
        z: 5
    }

	Keyboard {
	id: keyboard
		width: parent.width * 0.25
		anchors {
			top: header.bottom;
			bottom: parent.bottom
			left: parent.left; leftMargin: globalMargin//parent.width * 0.03
		}
		focus: true
	}

	Item {
		id: searchResultsContainer
		anchors {
			top: header.bottom;
            bottom: parent.bottom; bottomMargin: globalMargin
			left: keyboard.right; leftMargin: globalMargin//parent.width * 0.03
			right: parent.right; rightMargin: globalMargin//parent.width * 0.03
		}

		Rectangle {
		id: searchBar
			anchors.top: parent.top
			width: parent.width
			height: vpx(50)
			color: "transparent"
			z: 5

			Rectangle {
				anchors {
					top: parent.top
					left: parent.left; leftMargin: -globalMargin
					right: parent.right
				}
				height: vpx(35)
				color: theme.main

				Text {
				id: searchPlaceholder
					anchors.fill: parent
					anchors.leftMargin: globalMargin
					text: "Recommended games"
					color: "white"
					font.family: titleFont.name
					font.pixelSize: 24
					visible: searchText.length === 0
				}

				Rectangle {
					anchors.fill: parent
					anchors.leftMargin: globalMargin
					visible: searchText.trim().length > 0
					color: parent.color

					Image {
					id: searchIcon
						source: "../assets/images/key/search.svg"
						width: height
						height: vpx(28)
						anchors {
							left: parent.left; leftMargin: vpx(5)
							verticalCenter: parent.verticalCenter
						}
					}

					Text {
					id: searchInput
						color: "white"
						anchors.fill: parent
						leftPadding: vpx(40)
						font.family: titleFont.name
						font.pixelSize: 24
						onTextChanged: {
							gamesFiltered.searchTerm = text.trim();
						}
					}
				}
			}
		}


        GridView {
        id: resultsGrid

			GridSpacer {
				id: fakebox
				width: vpx(100); height: vpx(100)
				games: listRecommended.games
			}

            property real cellHeightRatio: fakebox.paintedHeight / fakebox.paintedWidth
            property real savedCellHeight: cellWidth * settings.WideRatio
			property int numColumns: 5

            anchors {
                top: searchBar.bottom;
                bottom: parent.bottom; bottomMargin: helpMargin + vpx(40)
            }
			width: parent.width
	
            cellWidth: width / numColumns
            cellHeight: (cellWidth) * cellHeightRatio + vpx(40)

            preferredHighlightBegin: vpx(0)
            preferredHighlightEnd: resultsGrid.height - helpMargin - vpx(35)
            highlightRangeMode: GridView.StrictlyEnforceRange
            highlightMoveDuration: 200
            highlight: highlightcomponent
            keyNavigationWraps: false
			displayMarginBeginning: cellHeight * 2
			displayMarginEnd: cellHeight * 2

            Component.onCompleted: {
				currentIndex = 0
                positionViewAtIndex(currentIndex, GridView.Visible);
            }
 
            model: searchText.length === 0 ? listRecommended.games : gamesFiltered
            delegate: BoxArtGridItem {
				selected:	GridView.isCurrentItem && resultsGrid.focus
				width:      GridView.view.cellWidth
				height:     GridView.view.cellHeight
				verticalSpacing: vpx(40)
				horizontalSpacing: vpx(12)
				showTitle: settings.AlwaysShowTitles === "Yes"
				onActivate: {
					if (selected) {
						gameDetails(modelData);
					} else {
						resultsGrid.currentIndex = index;
					}
				}
				onHighlighted: {
					resultsGrid.currentIndex = index;
				}
			}

            Component {
            id: highlightcomponent

                ItemHighlight {
                    width: resultsGrid.cellWidth
                    height: resultsGrid.cellHeight
                    selected: resultsGrid.focus
                    boxArt: true
                }
            }

			Rectangle {
				anchors.fill: parent
				color: "transparent"
				visible: !gamesFiltered.hasResults

				Text {
					text: "There are no matches for your search"
					color: "white"
					font.pixelSize: 26
					anchors.centerIn: parent
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
			}

			Keys.onDownPressed: {
				sfxNav.play();
				moveCurrentIndexDown()
			}

			Keys.onUpPressed: {
				sfxNav.play();
				moveCurrentIndexUp()
			}

			Keys.onRightPressed: {
				sfxNav.play();
				moveCurrentIndexRight()
			}

			Keys.onLeftPressed: {
				sfxNav.play();
				if (resultsGrid.currentIndex % numColumns === 0) {
					keyboard.focus = true;
				} else {
					moveCurrentIndexLeft()
				}
			}

			Keys.onPressed: {
				sfxNav.play();
				if (!event.isAutoRepeat && api.keys.isCancel(event)) {
					event.accepted = true;
					keyboard.focus = true;
				}
			}
		}
	}


    Keys.onPressed: {
        // Back
        if (api.keys.isCancel(event) && !event.isAutoRepeat) {
            event.accepted = true;
            previousScreen();
        }
	}
}
