import QtQuick 2.0
import SortFilterProxyModel 0.2

Item {
id: root
    
    readonly property alias games: gamesFiltered
    function currentPlatform(index) { return api.collections.get(gamesFiltered.mapToSource(index)) }
    property int max: gamesFiltered.count

    SortFilterProxyModel {
    id: gamesFiltered

        sourceModel: api.collections
        filters: IndexFilter { maximumIndex: max - 1 }
    }

    property var collection: {
        return {
            name:       "Platforms",
            shortName:  "platforms",
            games:  gamesFiltered
        }
    }
}
