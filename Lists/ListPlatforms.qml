import QtQuick 2.0
import SortFilterProxyModel 0.2

Item {
id: root
    
    readonly property alias platforms: platformsFiltered
    function currentPlatform(index) { return api.collections.get(platformsFiltered.mapToSource(index)) }
    property int max: platformsFiltered.count

    SortFilterProxyModel {
    id: platformsFiltered

        sourceModel: api.collections
        filters: IndexFilter { maximumIndex: max - 1 }
    }

    property var collection: {
        return {
            name:       "Platforms",
            shortName:  "platforms",
            platforms:  platformsFiltered
        }
    }
}
