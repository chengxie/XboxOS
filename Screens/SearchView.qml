import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import "../Global"

FocusScope {
id: root
	
	property var searchList: searchAllGames ? listAllGames : listCollectionGames
	property var currentList: {
		if (searchAllGames) {
			return searchTerm.length > 0 ? searchList : listRecommended
		} else {
			return listCollectionGames
		}
	}

	Component.onCompleted: {
		if (storedCollectionGameIndex > -1 || (searchTerm.length > 0 && searchList.games.count > 0)) {
			resultsGrid.focus = true
		} else {
			keyboard.focus = true
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
			left: parent.left; leftMargin: globalMargin
		}
		onChangeFocus: {
			if (searchList.games.count) {
				resultsGrid.focus = true
			}
		}
		onSearchTextChanged: {
			searchTerm = searchText
			resultsGrid.currentIndex = currentList.games.count > 0 ? 0 : -1
		}
	}

	Item {
		id: searchResultsContainer
		anchors {
			top: header.bottom;
            bottom: parent.bottom; bottomMargin: globalMargin
			left: keyboard.right; leftMargin: globalMargin
			right: parent.right; rightMargin: globalMargin
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
					text: currentList.collection.name
					color: "white"
					font.family: titleFont.name
					font.pixelSize: vpx(24)
					visible: searchTerm.length === 0
				}

				Rectangle {
					anchors.fill: parent
					anchors.leftMargin: globalMargin
					visible: searchTerm.length > 0
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
						font.pixelSize: vpx(24)
						text: searchTerm
						//onTextChanged: {
							//gamesFiltered.searchTerm = text;
						//}
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
            gameList: currentList //searchTerm.length == 0 ? listRecommended : searchList

			Rectangle {
				anchors.fill: parent
				color: "transparent"
				visible: !searchList.games.count

				Text {
					text: "There are no matches for your search"
					color: "white"
					font.pixelSize: vpx(26)
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
			searchTerm = ""
            previousScreen();
        }
	}

    // Helpbar buttons
    ListModel {
        id: searchviewHelpModel

        ListElement {
            name: "Back"
            button: "cancel"
        }
        ListElement {
            name: "Toggle favorite"
            button: "details"
        }
        ListElement {
            name: "View details"
            button: "accept"
        }
    }

    onFocusChanged: { 
        if (focus) { 
            currentHelpbarModel = searchviewHelpModel;
        }
    }
}
