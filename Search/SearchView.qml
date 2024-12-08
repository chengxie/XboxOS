import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import "../Global"
import "../Lists"


FocusScope {
id: root
	
	property var collection: api.allGames 
	property alias searchText: searchInput.text
	property alias gamesFiltered: searchAllGames.games

	Item {
	id: searchAllGames
		property alias games: gamesFiltered
		function currentGame(index) { return collection.get(gamesFiltered.mapToSource(index)) }
		property int max: gamesFiltered.count
		SortFilterProxyModel {
		id: gamesFiltered
			sourceModel: api.allGames
			property string searchTerm: ""
			property bool hasResults: count > 0
			filters: [
				RegExpFilter {
					roleName: "title";
					pattern: "^" + gamesFiltered.searchTerm.trim().replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&') + ".+";
					caseSensitivity: Qt.CaseInsensitive;
					enabled: gamesFiltered.searchTerm !== "";
				}
			]
		}
	}

    Rectangle {
    id: header
        anchors {
            top:    parent.top
            left:   parent.left
            right:  parent.right
        }
        height: globalMargin//vpx(35)
        color: theme.primary
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
				color: theme.primary

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


		GridViewBox {
        id: resultsGrid
            anchors {
                top: searchBar.bottom;
                bottom: parent.bottom; bottomMargin: helpMargin + vpx(40)
            }
			width: parent.width
			numColumns: 5
            gameList: searchText.length === 0 ? listRecommended : searchAllGames

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

			Keys.onLeftPressed: {
				if (currentIndex % numColumns === 0) {
					sfxNav.play();
					keyboard.focus = true;
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
