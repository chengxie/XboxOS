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
import SortFilterProxyModel 0.2
import QtMultimedia 5.9
import "GridView"
import "Global"
import "Screens"
import "GameDetails"
import "ShowcaseView"
import "Search"
import "Settings"
import "Lists"
import "utils.js" as Utils
import "themes.js" as Themes

FocusScope {
id: root

    FontLoader { id: titleFont; source:      "assets/fonts/YaHei-Bold.ttf" }
    FontLoader { id: subtitleFont; source:   "assets/fonts/YaHei-Bold.ttf" }
    FontLoader { id: bodyFont; source:       "assets/fonts/YaHei.ttf" }

    // Pull in our custom lists and define
    ListAllGames    { id: listNone;        max: 0 }
    ListAllGames    { id: listAllGames;    max: settings.ShowcaseColumns }
    ListFavorites   { id: listFavorites;   max: settings.ShowcaseColumns }
    ListLastPlayed  { id: listLastPlayed;  max: settings.ShowcaseColumns }
    ListMostPlayed  { id: listMostPlayed;  max: settings.ShowcaseColumns }
    ListRecommended { id: listRecommended; max: settings.ShowcaseColumns }
    ListPublisher   { id: listPublisher;   max: settings.ShowcaseColumns; publisher: randoPub }
    ListGenre       { id: listGenre;       max: settings.ShowcaseColumns; genre: randoGenre }
	ListPlatforms	{ id: listPlatforms;   max: 0; property int index: -1 }

    property string randoPub: (Utils.returnRandom(Utils.uniqueValuesArray('publisher')) || '')
    property string randoGenre: (Utils.returnRandom(Utils.uniqueValuesArray('genreList'))[0] || '').toLowerCase()

    // Load settings
    property var settings: {
        return {
            GridColumns:                   api.memory.has("Number of columns") ? api.memory.get("Number of columns") : "7",
            GameBackground:                api.memory.has("Game Background") ? api.memory.get("Game Background") : "Screenshot",
            GameLogo:                      api.memory.has("Game Logo") ? api.memory.get("Game Logo") : "Show",
            GameRandomBackground:          api.memory.has("Randomize Background") ? api.memory.get("Randomize Background") : "No",
            GameBlurBackground:            api.memory.has("Blur Background") ? api.memory.get("Blur Background") : "No",
            VideoPreview:                  api.memory.has("Video preview") ? api.memory.get("Video preview") : "Yes",
            HideButtonHelp:                api.memory.has("Hide button help") ? api.memory.get("Hide button help") : "No",
            ColorLayout:                   api.memory.has("Color Layout") ? api.memory.get("Color Layout") : "Dark Green",
			ColorBackground:               api.memory.has("Color Background") ? api.memory.get("Color Background") : "Black",
            MouseHover:                    api.memory.has("Enable mouse hover") ? api.memory.get("Enable mouse hover") : "No",
            AlwaysShowTitles:              api.memory.has("Always show titles") ? api.memory.get("Always show titles") : "No",
            AlwaysShowHighlightedTitles:   api.memory.has("Always show highlighted titles") ? api.memory.get("Always show highlighted titles") : "No",
            BorderHighlight:               api.memory.has("Border highlight") ? api.memory.get("Border highlight") : "No",
            AllowVideoPreviewAudio:        api.memory.has("Video preview audio") ? api.memory.get("Video preview audio") : "No",
            ShowScanlines:                 api.memory.has("Show scanlines") ? api.memory.get("Show scanlines") : "Yes",
            ShowcaseColumns:               api.memory.has("Number of games showcased") ? api.memory.get("Number of games showcased") : "15",
            ShowcaseFeaturedCollection:    api.memory.has("Featured collection") ? api.memory.get("Featured collection") : "Favorites",
            ShowcaseCollection1:           api.memory.has("Collection 1") ? api.memory.get("Collection 1") : "Recently Played",
            ShowcaseCollection2:           api.memory.has("Collection 2") ? api.memory.get("Collection 2") : "Most Played",
            ShowcaseCollection3:           api.memory.has("Collection 3") ? api.memory.get("Collection 3") : "Top by Publisher",
            ShowcaseCollection4:           api.memory.has("Collection 4") ? api.memory.get("Collection 4") : "Top by Genre",
            ShowcaseCollection5:           api.memory.has("Collection 5") ? api.memory.get("Collection 5") : "None",
        }
    }

	property var modelList: [
		//listFavorites,	
		//listPlatforms,	//首页特殊类型
		getCollection("Favorites"),
		getCollection("Platforms"),
		getCollection(settings.ShowcaseCollection1),
		getCollection(settings.ShowcaseCollection2),
		getCollection(settings.ShowcaseCollection3),
		getCollection(settings.ShowcaseCollection4),
		getCollection(settings.ShowcaseCollection5),
	]

    function getCollection(collectionName) {
        var collection = {
            enabled: collectionName !== "None"
        };

        switch (collectionName) {
            case "Favorites":
                collection.search = listFavorites;
                break;
			case "Platforms":
                collection.search = listPlatforms;
				break;
            case "Recently Played":
                collection.search = listLastPlayed;
                break;
            case "Most Played":
                collection.search = listMostPlayed;
                break;
            case "Recommended":
                collection.search = listRecommended;
                break;
            case "Top by Publisher":
                collection.search = listPublisher;
                break;
            case "Top by Genre":
                collection.search = listGenre;
                break;
            case "None":
                collection.search = listNone;
                break;
            default:
                collection.search = listAllGames;
                break;
        }
		
		collection.index = collection.search.games.count > 0 ? 0 : -1;
        collection.title = collection.search.collection.name;
		collection.shortName = collection.search.collection.shortName;
        return collection;
    }

    // Collections
    property int currentCollectionIndex: 0
    property int currentGameIndex: 0
    property var currentCollection: api.collections.get(currentCollectionIndex)    
    property var currentGame

    // Stored variables for page navigation
    property int storedHomePrimaryIndex: 0
    property int storedCollectionGameIndex: 0
	property int showcaseHeaderMenuIndex: -1

    // Reset the stored game index when changing collections
    onCurrentCollectionIndexChanged: storedCollectionGameIndex = 0

    // Filtering options
    property bool showFavs: false
    property var sortByFilter: ["title", "lastPlayed", "playCount", "rating"]
    property int sortByIndex: 0
    property var orderBy: Qt.AscendingOrder
    property string searchTerm: ""
    property bool steam: currentCollection.name === "Steam"
    function steamExists() {
        for (i = 0; i < api.collections.count; i++) {
            if (api.collections.get(i).name === "Steam") {
                return true;
            }
            return false;
        }
    }

    // Functions for switching currently active collection
    function toggleFavs() {
        showFavs = !showFavs;
    }

    function cycleSort() {
        if (sortByIndex < sortByFilter.length - 1)
            sortByIndex++;
        else
            sortByIndex = 0;
    }

    function toggleOrderBy() {
        if (orderBy === Qt.AscendingOrder)
            orderBy = Qt.DescendingOrder;
        else
            orderBy = Qt.AscendingOrder;
    }

    // Launch the current game
    function launchGame(game) {
        if (game !== null) {
            //if (game.collections.get(0).name === "Steam")
                launchGameScreen();

            saveCurrentState(game);
            game.launch();
        } else {
            //if (currentGame.collections.get(0).name === "Steam")
                launchGameScreen();

            saveCurrentState(currentGame);
            currentGame.launch();
        }
    }

    // Save current states for returning from game
    function saveCurrentState(game) {
        api.memory.set('savedState', root.state);
        api.memory.set('savedCollection', currentCollectionIndex);
        api.memory.set('lastState', JSON.stringify(lastState));
        api.memory.set('lastGame', JSON.stringify(lastGame));
        api.memory.set('storedHomePrimaryIndex', storedHomePrimaryIndex);
        api.memory.set('storedCollectionGameIndex', storedCollectionGameIndex);

        const savedGameIndex = api.allGames.toVarArray().findIndex(g => g === game);
        api.memory.set('savedGame', savedGameIndex);
        api.memory.set('To Game', 'True');
    }

    // Handle loading settings when returning from a game
    property bool fromGame: api.memory.has('To Game');
    function returnedFromGame() {
        lastState                   = JSON.parse(api.memory.get('lastState'));
        lastGame                    = JSON.parse(api.memory.get('lastGame'));
        currentCollectionIndex      = api.memory.get('savedCollection');
        storedHomePrimaryIndex      = api.memory.get('storedHomePrimaryIndex');
        storedCollectionGameIndex   = api.memory.get('storedCollectionGameIndex');

        currentGame                 = api.allGames.get(api.memory.get('savedGame'));
        root.state                  = api.memory.get('savedState');

        // Remove these from memory so as to not clog it up
        api.memory.unset('savedState');
        api.memory.unset('savedGame');
        api.memory.unset('lastState');
        api.memory.unset('lastGame');
        api.memory.unset('storedHomePrimaryIndex');
        api.memory.unset('storedCollectionGameIndex');

        // Remove this one so we only have it when we come back from the game and not at Pegasus launch
        api.memory.unset('To Game');
    }

    // Theme settings
	property var theme: Themes.get(settings.ColorBackground, settings.ColorLayout)
    property real globalMargin: vpx(30)
    property real helpMargin: buttonbar.height
    property int transitionTime: 100

    // State settings
    states: [
        State {
            name: "softwaregridscreen";
        },
		State {
			name: "softwaresearchscreen";
		},
        State {
            name: "showcasescreen";
        },
        State {
            name: "gameviewscreen";
        },
        State {
            name: "settingsscreen";
        },
        State {
            name: "launchgamescreen";
        }
    ]

    property var lastState: []
    property var lastGame: []

    // Screen switching functions
    function softwareScreen() {
        sfxAccept.play();
        lastState.push(state);
        searchTerm = "";
        root.state = "softwaregridscreen";
    }

	function searchScreen() {
		sfxAccept.play();
        lastState.push(state);
        root.state = "softwaresearchscreen";
	}

    function showcaseScreen() {
        sfxAccept.play();
        lastState.push(state);
        root.state = "showcasescreen";
    }

    function settingsScreen() {
        sfxAccept.play();
        lastState.push(state);
        root.state = "settingsscreen";
    }

    function launchGameScreen() {
        sfxAccept.play();
        lastState.push(state);
        root.state = "launchgamescreen";
    }

    function gameDetails(game) {
        sfxAccept.play();
        // As long as there is a state history, save the last game
        if (lastState.length != 0)
            lastGame.push(currentGame);

        // Push the new game
        if (game !== null)
            currentGame = game;

        // Save the state before pushing the new one
        lastState.push(state);
        root.state = "gameviewscreen";
    }


    function previousScreen() {
        sfxBack.play();
        if (state == lastState[lastState.length-1])
            popLastGame();

        state = lastState[lastState.length - 1];
        lastState.pop();
    }

    function popLastGame() {
        if (lastGame.length) {
            currentGame = lastGame[lastGame.length-1];
            lastGame.pop();
        }
    }

    // Set default state to the platform screen
    Component.onCompleted: { 
        root.state = "showcasescreen";
        if (fromGame)
            returnedFromGame();
    }

    // Background
    Rectangle {
    id: background
        anchors.fill: parent
        color: theme.primary
        //Image { source: "assets/images/backgrounds/halo.jpg"; fillMode: Image.PreserveAspectFit; anchors.fill: parent;  opacity: 0.3 }
    }

    ScreenLoader  {
    id: showcaseLoader
        focus: (root.state === "showcasescreen")
        sourceComponent: ShowcaseViewMenu { focus: true }
    }

    ScreenLoader  {
    id: gridviewloader
        focus: (root.state === "softwaregridscreen")
        sourceComponent: GridViewMenu { focus: true }
    }

    ScreenLoader  {
    id: searchviewloader
        focus: (root.state === "softwaresearchscreen")
        sourceComponent: SearchView { focus: true }
    }

    ScreenLoader  {
    id: gameviewloader
        focus: (root.state === "gameviewscreen")
        sourceComponent: GameView { focus: true; game: currentGame }
        onActiveChanged: if (!active) popLastGame();
    }

    ScreenLoader  {
    id: launchgameloader
        focus: (root.state === "launchgamescreen")
        sourceComponent: LaunchGame { focus: true }
    }

    ScreenLoader  {
    id: settingsloader
        focus: (root.state === "settingsscreen")
        sourceComponent: SettingsScreen { focus: true }
    }
    
    // Button help
    property var currentHelpbarModel
    ButtonHelpBar {
    id: buttonbar

        height: vpx(50)
        anchors {
            left: parent.left; right: parent.right; rightMargin: globalMargin
            bottom: parent.bottom
        }
        visible: settings.HideButtonHelp === "No"
    }

    ///////////////////
    // SOUND EFFECTS //
    ///////////////////
    SoundEffect {
        id: sfxNav
        source: "assets/sfx/navigation.wav"
        volume: 1.0
    }

    SoundEffect {
        id: sfxBack
        source: "assets/sfx/back.wav"
        volume: 1.0
    }

    SoundEffect {
        id: sfxAccept
        source: "assets/sfx/accept.wav"
    }

    SoundEffect {
        id: sfxToggle
        source: "assets/sfx/toggle.wav"
    }
    
}

